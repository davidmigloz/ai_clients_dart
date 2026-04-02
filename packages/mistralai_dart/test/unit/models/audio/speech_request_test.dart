import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SpeechRequest', () {
    test('constructor with required input only', () {
      const request = SpeechRequest(input: 'Hello world');
      expect(request.input, 'Hello world');
      expect(request.model, isNull);
      expect(request.voiceId, isNull);
      expect(request.refAudio, isNull);
      expect(request.responseFormat, isNull);
      expect(request.stream, isNull);
    });

    test('constructor with all fields', () {
      const request = SpeechRequest(
        input: 'Hello world',
        model: 'mistral-tts-latest',
        voiceId: 'voice-1',
        refAudio: 'base64audio',
        responseFormat: SpeechOutputFormat.mp3,
        stream: true,
      );
      expect(request.input, 'Hello world');
      expect(request.model, 'mistral-tts-latest');
      expect(request.voiceId, 'voice-1');
      expect(request.refAudio, 'base64audio');
      expect(request.responseFormat, SpeechOutputFormat.mp3);
      expect(request.stream, isTrue);
    });

    test('fromJson with all fields', () {
      final request = SpeechRequest.fromJson(const {
        'input': 'Hello world',
        'model': 'mistral-tts-latest',
        'voice_id': 'voice-1',
        'ref_audio': 'base64audio',
        'response_format': 'mp3',
        'stream': true,
      });
      expect(request.input, 'Hello world');
      expect(request.model, 'mistral-tts-latest');
      expect(request.voiceId, 'voice-1');
      expect(request.refAudio, 'base64audio');
      expect(request.responseFormat, SpeechOutputFormat.mp3);
      expect(request.stream, isTrue);
    });

    test('fromJson with required fields only', () {
      final request = SpeechRequest.fromJson(const {'input': 'Hello world'});
      expect(request.input, 'Hello world');
      expect(request.model, isNull);
      expect(request.voiceId, isNull);
      expect(request.refAudio, isNull);
      expect(request.responseFormat, isNull);
      expect(request.stream, isNull);
    });

    test('toJson omits null fields', () {
      const request = SpeechRequest(input: 'Hello world');
      final json = request.toJson();
      expect(json, {'input': 'Hello world'});
      expect(json.containsKey('model'), isFalse);
      expect(json.containsKey('voice_id'), isFalse);
      expect(json.containsKey('ref_audio'), isFalse);
      expect(json.containsKey('response_format'), isFalse);
      expect(json.containsKey('stream'), isFalse);
    });

    test('toJson serializes responseFormat as string value', () {
      const request = SpeechRequest(
        input: 'Hello world',
        responseFormat: SpeechOutputFormat.flac,
      );
      final json = request.toJson();
      expect(json['response_format'], 'flac');
    });

    test('copyWith preserves values when no arguments given', () {
      const original = SpeechRequest(
        input: 'Hello world',
        model: 'mistral-tts-latest',
        voiceId: 'voice-1',
        refAudio: 'base64audio',
        responseFormat: SpeechOutputFormat.wav,
        stream: false,
      );
      final copy = original.copyWith();
      expect(copy, original);
    });

    test('copyWith replaces values', () {
      const original = SpeechRequest(
        input: 'Hello world',
        model: 'mistral-tts-latest',
        voiceId: 'voice-1',
      );
      final copy = original.copyWith(
        input: 'Goodbye',
        model: 'other-model',
        voiceId: 'voice-2',
        responseFormat: SpeechOutputFormat.opus,
        stream: true,
      );
      expect(copy.input, 'Goodbye');
      expect(copy.model, 'other-model');
      expect(copy.voiceId, 'voice-2');
      expect(copy.responseFormat, SpeechOutputFormat.opus);
      expect(copy.stream, isTrue);
    });

    test('copyWith can set nullable fields to null', () {
      const original = SpeechRequest(
        input: 'Hello world',
        model: 'mistral-tts-latest',
        voiceId: 'voice-1',
        refAudio: 'base64audio',
        responseFormat: SpeechOutputFormat.mp3,
        stream: true,
      );
      final copy = original.copyWith(
        model: null,
        voiceId: null,
        refAudio: null,
        responseFormat: null,
        stream: null,
      );
      expect(copy.input, 'Hello world');
      expect(copy.model, isNull);
      expect(copy.voiceId, isNull);
      expect(copy.refAudio, isNull);
      expect(copy.responseFormat, isNull);
      expect(copy.stream, isNull);
    });

    test('equality and hashCode', () {
      const a = SpeechRequest(
        input: 'Hello',
        model: 'model-1',
        responseFormat: SpeechOutputFormat.mp3,
      );
      const b = SpeechRequest(
        input: 'Hello',
        model: 'model-1',
        responseFormat: SpeechOutputFormat.mp3,
      );
      const c = SpeechRequest(
        input: 'Different',
        model: 'model-1',
        responseFormat: SpeechOutputFormat.mp3,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString', () {
      const request = SpeechRequest(input: 'Hello', model: 'model-1');
      final str = request.toString();
      expect(str, contains('SpeechRequest'));
      expect(str, contains('Hello'));
      expect(str, contains('model-1'));
    });

    group('extra field', () {
      test('fromJson collects unknown keys into extra', () {
        final request = SpeechRequest.fromJson(const {
          'input': 'Hello',
          'model': 'mistral-tts-latest',
          'custom_param': 'value',
          'speed': 1.5,
        });
        expect(request.input, 'Hello');
        expect(request.model, 'mistral-tts-latest');
        expect(request.extra, {'custom_param': 'value', 'speed': 1.5});
      });

      test('fromJson returns null extra when only known keys', () {
        final request = SpeechRequest.fromJson(const {
          'input': 'Hello',
          'model': 'mistral-tts-latest',
        });
        expect(request.extra, isNull);
      });

      test('toJson includes extra as top-level keys', () {
        const request = SpeechRequest(
          input: 'Hello',
          extra: {'custom_param': 'value', 'speed': 1.5},
        );
        final json = request.toJson();
        expect(json['input'], 'Hello');
        expect(json['custom_param'], 'value');
        expect(json['speed'], 1.5);
        expect(json.containsKey('extra'), isFalse);
      });

      test('toJson without extra produces no extra keys', () {
        const request = SpeechRequest(input: 'Hello');
        final json = request.toJson();
        expect(json.keys, ['input']);
      });

      test('round-trip preserves extra keys', () {
        final original = {
          'input': 'Hello',
          'model': 'mistral-tts-latest',
          'custom_param': 'value',
        };
        final request = SpeechRequest.fromJson(original);
        final json = request.toJson();
        expect(json, original);
      });

      test('copyWith sets extra', () {
        const request = SpeechRequest(input: 'Hello');
        final copy = request.copyWith(extra: {'speed': 1.5});
        expect(copy.extra, {'speed': 1.5});
      });

      test('copyWith clears extra to null', () {
        const request = SpeechRequest(input: 'Hello', extra: {'speed': 1.5});
        final copy = request.copyWith(extra: null);
        expect(copy.extra, isNull);
      });

      test('copyWith preserves extra when not specified', () {
        const request = SpeechRequest(input: 'Hello', extra: {'speed': 1.5});
        final copy = request.copyWith(input: 'Goodbye');
        expect(copy.extra, {'speed': 1.5});
      });

      test('equality includes extra', () {
        const a = SpeechRequest(input: 'Hello', extra: {'speed': 1.5});
        const b = SpeechRequest(input: 'Hello', extra: {'speed': 1.5});
        const c = SpeechRequest(input: 'Hello', extra: {'speed': 2.0});
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(c)));
      });

      test('toString shows extra entry count', () {
        const request = SpeechRequest(
          input: 'Hello',
          extra: {'speed': 1.5, 'custom': true},
        );
        expect(request.toString(), contains('extra: 2 entries'));
      });

      test('toString shows null for missing extra', () {
        const request = SpeechRequest(input: 'Hello');
        expect(request.toString(), contains('extra: null'));
      });
    });
  });
}
