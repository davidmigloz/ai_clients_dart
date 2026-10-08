// ignore_for_file: avoid_print
/// Runs buffered, byte-streamed and SSE speech with synthetic offline responses.
///
/// Run: dart run example/speech_streaming_example.dart
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var calls = 0;
  final audio = <int>[0, 1, 255, 128, 0, 2, 254, 127];
  final transport = MockClient.streaming((request, body) async {
    calls++;
    if (request.method != 'POST' || request.url.path != '/v1/audio/speech') {
      throw StateError('Unexpected speech request');
    }
    final wire =
        jsonDecode(utf8.decode(await body.toBytes())) as Map<String, dynamic>;
    if (wire['stream_format'] == 'sse') {
      if (request.headers['Accept'] != 'text/event-stream') {
        throw StateError('SSE requires the event-stream media type');
      }
      final events = [
        {'type': 'speech.audio.delta', 'audio': base64Encode(audio)},
        {
          'type': 'speech.audio.future',
          'metadata': {'source': 'synthetic', 'unicode': '☀️'},
        },
        {
          'type': 'speech.audio.done',
          'usage': {'input_tokens': 1, 'output_tokens': 2, 'total_tokens': 3},
        },
      ];
      final bytes = utf8.encode(
        events.map((event) => 'data: ${jsonEncode(event)}\n\n').join(),
      );
      return http.StreamedResponse(
        Stream.fromIterable([
          for (var i = 0; i < bytes.length; i += 7)
            bytes.sublist(i, (i + 7).clamp(0, bytes.length)),
        ]),
        200,
        headers: {'content-type': 'text/event-stream'},
        request: request,
      );
    }
    if (request.headers['Accept'] != 'application/octet-stream') {
      throw StateError('Audio requires the binary media type');
    }
    return http.StreamedResponse(
      Stream.fromIterable([audio.sublist(0, 3), audio.sublist(3)]),
      200,
      headers: {'content-type': 'audio/pcm'},
      request: request,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
    httpClient: transport,
  );
  try {
    final buffered = await client.audio.speech.create(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'Hello.',
        voice: SpeechVoice.marin,
        instructions: 'Speak clearly.',
        responseFormat: SpeechResponseFormat.pcm,
      ),
    );
    print('Buffered: ${buffered.length} synthetic bytes');

    var byteCount = 0;
    await for (final chunk in client.audio.speech.createByteStream(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'Hello.',
        voice: AudioVoice.named('future-provider-voice'),
        responseFormat: SpeechResponseFormat.pcm,
      ),
    )) {
      byteCount += chunk.length;
      // An application can write or play each chunk in its received order.
    }
    print('Byte stream: $byteCount synthetic bytes');

    final decoded = BytesBuilder(copy: false);
    var futureEvents = 0;
    SpeechUsage? usage;
    await for (final event in client.audio.speech.createStream(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'Hello.',
        voice: AudioVoice.custom('voice_mock_existing'),
        instructions: 'Speak clearly.',
        responseFormat: SpeechResponseFormat.pcm,
      ),
    )) {
      switch (event) {
        case SpeechAudioDeltaEvent():
          decoded.add(event.decodeAudio());
        case SpeechAudioDoneEvent():
          usage = event.usage;
        case SpeechUnknownEvent():
          futureEvents++;
        // event.rawJson retains future metadata for explicit caller inspection.
      }
    }
    if (calls != 3 ||
        buffered.length != audio.length ||
        byteCount != audio.length ||
        decoded.length != audio.length ||
        usage?.totalTokens != 3 ||
        futureEvents != 1) {
      throw StateError('Offline speech workflow did not retain its output');
    }
    print(
      'SSE: ${decoded.length} bytes, ${usage!.totalTokens} synthetic tokens',
    );
    print(
      'Retained $futureEvents future event; $calls mock requests; API cost \$0',
    );
  } finally {
    client.close();
    transport.close(); // The client/streams borrow this injected transport.
  }
}
