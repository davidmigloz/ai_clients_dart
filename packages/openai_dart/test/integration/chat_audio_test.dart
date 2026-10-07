@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final apiKey = Platform.environment['OPENAI_API_KEY'];
  test(
    'streams one bounded unstored audio response',
    () async {
      final transport = _OneAudioRequestClient(http.Client());
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider(apiKey!),
          retryPolicy: const RetryPolicy(maxRetries: 0),
          timeout: const Duration(seconds: 60),
        ),
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final accumulator = ChatStreamAccumulator();
      final data = StringBuffer();
      final transcript = StringBuffer();
      final text = StringBuffer();
      var audioEvents = 0;
      await for (final event in client.chat.completions.createStream(
        ChatCompletionCreateRequest(
          model: 'gpt-audio-1.5',
          messages: [ChatMessage.user('Say only OK.')],
          modalities: const [ChatModality.text, ChatModality.audio],
          audio: const ChatAudioConfig(
            voice: ChatAudioVoice.alloy,
            format: ChatAudioFormat.pcm16,
          ),
          maxCompletionTokens: 128,
          serviceTier: 'default',
          store: false,
          streamOptions: const StreamOptions(includeUsage: true),
        ),
      )) {
        accumulator.add(event);
        text.write(event.textDelta ?? '');
        if (event.firstChoice?.delta.audio case final audio?) {
          audioEvents++;
          data.write(audio.data ?? '');
          transcript.write(audio.transcript ?? '');
        }
      }
      expect(transport.creationCount, 1);
      final usage = accumulator.usage;
      expect(usage, isNotNull);
      expect(usage!.completionTokens, isNotNull);
      expect(usage.completionTokens, inInclusiveRange(0, 128));
      expect(accumulator.content, text.toString());
      final partial = accumulator.audio;
      var completeAudio = false;
      if (partial != null) {
        expect(audioEvents, greaterThan(0));
        expect(partial.data ?? '', data.toString());
        expect(partial.transcript ?? '', transcript.toString());
        if (partial.isComplete) {
          completeAudio = true;
          final output = accumulator.toChatCompletion().audio!;
          expect(output, partial.toCompleteAudio());
          expect(output.data, data.toString());
          expect(output.transcript, transcript.toString());
          expect(base64Decode(output.data), isA<List<int>>());
          final replay = ChatCompletionCreateRequest(
            model: 'gpt-audio-1.5',
            messages: [ChatMessage.assistant(audio: output)],
          ).toJson();
          final message =
              (replay['messages'] as List<dynamic>).single
                  as Map<String, dynamic>;
          expect(message['audio'], {'id': output.id});
        } else {
          // A bounded or interrupted stream can leave valid partial audio.
          expect(accumulator.toChatCompletion, throwsStateError);
        }
      } else {
        // A token cap, refusal or text fallback can omit audio and all text.
        final completion = accumulator.toChatCompletion();
        expect(completion.audio, isNull);
        expect(completion.text ?? '', text.toString());
      }
      // Bill all input/output at audio rates as a deliberately conservative bound.
      final estimate =
          usage.promptTokens * 32 / 1000000 +
          usage.completionTokens! * 64 / 1000000;
      // Counters only; no request, key, transcript, audio ID or data is logged.
      // ignore: avoid_print
      print(
        'Audio smoke usage: input=${usage.promptTokens}, '
        'output=${usage.completionTokens}, audio_events=$audioEvents, '
        'complete=$completeAudio, conservative_USD=$estimate',
      );
    },
    skip: apiKey == null || apiKey.trim().isEmpty
        ? 'OPENAI_API_KEY is not set.'
        : false,
    timeout: const Timeout(Duration(seconds: 90)),
  );
}

class _OneAudioRequestClient extends http.BaseClient {
  final http.Client _inner;
  int creationCount = 0;
  _OneAudioRequestClient(this._inner);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.method == 'POST') {
      if (++creationCount > 1) {
        throw StateError('Only one paid audio request is permitted.');
      }
      expect(request.url.path, '/v1/chat/completions');
      final body =
          jsonDecode((request as http.Request).body) as Map<String, dynamic>;
      expect(body['model'], 'gpt-audio-1.5');
      expect(body['store'], isFalse);
      expect(body['stream'], isTrue);
      expect(body['max_completion_tokens'], 128);
      expect(body['service_tier'], 'default');
      expect(body['modalities'], ['text', 'audio']);
      expect(body['audio'], {'voice': 'alloy', 'format': 'pcm16'});
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
