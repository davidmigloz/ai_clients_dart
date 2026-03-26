import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SpeechStreamEvent', () {
    group('SpeechStreamAudioDelta', () {
      test('fromJson with valid JSON', () {
        final event = SpeechStreamAudioDelta.fromJson(const {
          'type': 'speech.audio.delta',
          'audio_data': 'chunk1',
        });
        expect(event.type, 'speech.audio.delta');
        expect(event.audioData, 'chunk1');
      });

      test('fromJson throws FormatException for wrong type', () {
        expect(
          () => SpeechStreamAudioDelta.fromJson(const {
            'type': 'speech.audio.done',
            'audio_data': 'chunk1',
          }),
          throwsA(isA<FormatException>()),
        );
      });

      test('toJson round-trip', () {
        final json = {'type': 'speech.audio.delta', 'audio_data': 'chunk1'};
        final event = SpeechStreamAudioDelta.fromJson(json);
        expect(event.toJson(), json);
      });

      test('equality', () {
        const a = SpeechStreamAudioDelta(audioData: 'chunk1');
        const b = SpeechStreamAudioDelta(audioData: 'chunk1');
        const c = SpeechStreamAudioDelta(audioData: 'chunk2');
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(c)));
      });
    });

    group('SpeechStreamDone', () {
      test('fromJson with valid JSON', () {
        final event = SpeechStreamDone.fromJson(const {
          'type': 'speech.audio.done',
          'usage': {
            'prompt_tokens': 10,
            'completion_tokens': 20,
            'total_tokens': 30,
          },
        });
        expect(event.type, 'speech.audio.done');
        expect(event.usage.promptTokens, 10);
        expect(event.usage.completionTokens, 20);
        expect(event.usage.totalTokens, 30);
      });

      test('fromJson throws FormatException for wrong type', () {
        expect(
          () => SpeechStreamDone.fromJson(const {
            'type': 'speech.audio.delta',
            'usage': {
              'prompt_tokens': 10,
              'completion_tokens': 20,
              'total_tokens': 30,
            },
          }),
          throwsA(isA<FormatException>()),
        );
      });

      test('toJson round-trip', () {
        final json = {
          'type': 'speech.audio.done',
          'usage': {
            'prompt_tokens': 10,
            'completion_tokens': 20,
            'total_tokens': 30,
          },
        };
        final event = SpeechStreamDone.fromJson(json);
        final output = event.toJson();
        expect(output['type'], 'speech.audio.done');
        final usage = output['usage'] as Map<String, dynamic>;
        expect(usage['prompt_tokens'], 10);
        expect(usage['completion_tokens'], 20);
        expect(usage['total_tokens'], 30);
      });

      test('equality', () {
        const usage = UsageInfo(
          promptTokens: 10,
          completionTokens: 20,
          totalTokens: 30,
        );
        const a = SpeechStreamDone(usage: usage);
        const b = SpeechStreamDone(usage: usage);
        const otherUsage = UsageInfo(
          promptTokens: 5,
          completionTokens: 10,
          totalTokens: 15,
        );
        const c = SpeechStreamDone(usage: otherUsage);
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(c)));
      });
    });

    group('SpeechStreamEvent.fromJson dispatch', () {
      test('dispatches to SpeechStreamAudioDelta for delta type', () {
        final event = SpeechStreamEvent.fromJson({
          'type': 'speech.audio.delta',
          'audio_data': 'chunk1',
        });
        expect(event, isA<SpeechStreamAudioDelta>());
        final delta = event as SpeechStreamAudioDelta;
        expect(delta.audioData, 'chunk1');
      });

      test('dispatches to SpeechStreamDone for done type', () {
        final event = SpeechStreamEvent.fromJson({
          'type': 'speech.audio.done',
          'usage': {
            'prompt_tokens': 10,
            'completion_tokens': 20,
            'total_tokens': 30,
          },
        });
        expect(event, isA<SpeechStreamDone>());
        final done = event as SpeechStreamDone;
        expect(done.usage.totalTokens, 30);
      });

      test('returns UnknownSpeechStreamEvent for unknown type', () {
        final event = SpeechStreamEvent.fromJson({
          'type': 'speech.audio.unknown',
          'data': 'something',
        });
        expect(event, isA<UnknownSpeechStreamEvent>());
        final unknown = event as UnknownSpeechStreamEvent;
        expect(unknown.raw['type'], 'speech.audio.unknown');
        expect(unknown.raw['data'], 'something');
      });

      test('UnknownSpeechStreamEvent equality uses deep map comparison', () {
        final a = UnknownSpeechStreamEvent(const {'type': 'x', 'data': 'a'});
        final b = UnknownSpeechStreamEvent(const {'type': 'x', 'data': 'a'});
        final c = UnknownSpeechStreamEvent(const {'type': 'x', 'data': 'b'});
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(c)));
      });

      test('UnknownSpeechStreamEvent raw is unmodifiable', () {
        final event = UnknownSpeechStreamEvent(const {
          'type': 'x',
          'data': 'a',
        });
        expect(
          () => event.raw['new_key'] = 'value',
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}
