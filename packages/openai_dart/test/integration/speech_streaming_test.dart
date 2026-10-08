// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'short speech byte and SSE streams preserve generated audio and usage',
    timeout: const Timeout(Duration(minutes: 2)),
    () async {
      final key = Platform.environment['OPENAI_API_KEY'];
      if (key == null || key.isEmpty) {
        markTestSkipped('OPENAI_API_KEY is not set');
        return;
      }
      // Exactly two short requests. No uploads, storage, tool calls or retries.
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider(key),
          timeout: const Duration(seconds: 45),
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
      );
      try {
        const request = SpeechRequest(
          model: 'gpt-4o-mini-tts',
          input: 'Hi.',
          voice: SpeechVoice.marin,
          instructions: 'Speak briefly.',
          responseFormat: SpeechResponseFormat.pcm,
        );
        final firstAbort = Completer<void>();
        final firstTimer = Timer(
          const Duration(seconds: 45),
          firstAbort.complete,
        );
        var byteCount = 0;
        try {
          await for (final chunk in client.audio.speech.createByteStream(
            request,
            abortTrigger: firstAbort.future,
          )) {
            byteCount += chunk.length;
          }
        } finally {
          firstTimer.cancel();
        }
        expect(byteCount, greaterThan(0));
        expect(byteCount.isEven, isTrue); // Raw mono 16-bit PCM samples.

        final secondAbort = Completer<void>();
        final secondTimer = Timer(
          const Duration(seconds: 45),
          secondAbort.complete,
        );
        var sseByteCount = 0;
        var doneCount = 0;
        SpeechUsage? usage;
        try {
          await for (final event in client.audio.speech.createStream(
            request,
            abortTrigger: secondAbort.future,
          )) {
            if (event is SpeechAudioDeltaEvent) {
              sseByteCount += event.decodeAudio().length;
            } else if (event is SpeechAudioDoneEvent) {
              doneCount++;
              usage = event.usage;
            }
          }
        } finally {
          secondTimer.cancel();
        }
        expect(sseByteCount, greaterThan(0));
        expect(sseByteCount.isEven, isTrue);
        expect(doneCount, 1);
        expect(usage, isNotNull);
        expect(usage!.inputTokens, greaterThanOrEqualTo(0));
        expect(usage.outputTokens, greaterThan(0));
        expect(usage.totalTokens, usage.inputTokens + usage.outputTokens);
        print(
          'SPEECH_SMOKE byte_pcm_bytes=$byteCount sse_pcm_bytes=$sseByteCount '
          'input_tokens=${usage.inputTokens} output_tokens=${usage.outputTokens} '
          'total_tokens=${usage.totalTokens}',
        );
      } finally {
        client.close();
      }
    },
  );
}
