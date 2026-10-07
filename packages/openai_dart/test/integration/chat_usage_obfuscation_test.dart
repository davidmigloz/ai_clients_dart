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
    'streams usage and obfuscation with one bounded unstored request',
    () async {
      final transport = _OneChatRequestClient(http.Client());
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
      final events = await client.chat.completions
          .createStream(
            ChatCompletionCreateRequest(
              model: 'gpt-6-luna',
              messages: [ChatMessage.user('Reply with only OK.')],
              reasoningEffort: ReasoningEffort.none,
              serviceTier: 'default',
              maxCompletionTokens: 16,
              store: false,
              streamOptions: const StreamOptions(
                includeUsage: true,
                includeObfuscation: true,
              ),
            ),
          )
          .toList();
      expect(events, isNotEmpty);
      expect(transport.creationCount, 1);
      final usageEvents = events.where((event) => event.usage != null).toList();
      expect(usageEvents, isNotEmpty);
      final finalUsage = usageEvents.last;
      expect(finalUsage.choices, isEmpty);
      final usage = finalUsage.usage!;
      expect(usage.promptTokens, greaterThan(0));
      expect(usage.completionTokens, isNotNull);
      expect(usage.completionTokens, inInclusiveRange(0, 16));
      // No particular modality/cache detail is required for a short text request.
      expect(Usage.fromJson(usage.toJson()), usage);
      final accumulator = ChatStreamAccumulator();
      final text = StringBuffer();
      for (final event in events) {
        accumulator.add(event);
        text.write(event.textDelta ?? '');
        if (event.obfuscation != null) {
          expect(
            ChatStreamEvent.fromJson(event.toJson()).obfuscation,
            event.obfuscation,
          );
        }
      }
      expect(accumulator.content, text.toString());
      expect(accumulator.usage, usage);
      expect(accumulator.toChatCompletion().text ?? '', text.toString());
      final estimate =
          usage.promptTokens * 0.125 / 1000000 +
          usage.completionTokens! * 0.50 / 1000000;
      // Log counts only: no key, request, text, or padding contents.
      // ignore: avoid_print
      print(
        'Chat smoke usage: input=${usage.promptTokens}, '
        'output=${usage.completionTokens}, '
        'padding_events=${events.where((event) => event.obfuscation != null).length}, '
        'conservative_USD=$estimate',
      );
    },
    skip: apiKey == null || apiKey.trim().isEmpty
        ? 'OPENAI_API_KEY is not set.'
        : false,
    timeout: const Timeout(Duration(seconds: 90)),
  );
}

class _OneChatRequestClient extends http.BaseClient {
  final http.Client _inner;
  int creationCount = 0;
  _OneChatRequestClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.method == 'POST') {
      if (++creationCount > 1) {
        throw StateError('Only one paid request is permitted.');
      }
      expect(request.url.path, '/v1/chat/completions');
      final body =
          jsonDecode((request as http.Request).body) as Map<String, dynamic>;
      expect(body['store'], isFalse);
      expect(body['stream'], isTrue);
      expect(body['max_completion_tokens'], 16);
      expect(body['stream_options'], {
        'include_usage': true,
        'include_obfuscation': true,
      });
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
