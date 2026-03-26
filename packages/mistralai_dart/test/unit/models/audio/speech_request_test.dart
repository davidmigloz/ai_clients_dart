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
  });
}
