import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TranscriptionRequest', () {
    group('constructor', () {
      test('creates with required file parameter', () {
        const request = TranscriptionRequest(file: 'file-123');
        expect(request.file, 'file-123');
        expect(request.model, 'mistral-audio-latest');
        expect(request.language, isNull);
        expect(request.responseFormat, isNull);
        expect(request.prompt, isNull);
        expect(request.temperature, isNull);
        expect(request.timestampGranularities, isNull);
      });

      test('creates with all parameters', () {
        const request = TranscriptionRequest(
          file: 'file-123',
          model: 'custom-model',
          language: 'en',
          responseFormat: 'verbose_json',
          prompt: 'Transcribe this meeting about AI',
          temperature: 0.5,
          timestampGranularities: true,
        );
        expect(request.file, 'file-123');
        expect(request.model, 'custom-model');
        expect(request.language, 'en');
        expect(request.responseFormat, 'verbose_json');
        expect(request.prompt, 'Transcribe this meeting about AI');
        expect(request.temperature, 0.5);
        expect(request.timestampGranularities, true);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const request = TranscriptionRequest(file: 'file-123');
        final json = request.toJson();
        expect(json['file'], 'file-123');
        expect(json['model'], 'mistral-audio-latest');
        expect(json.containsKey('language'), isFalse);
        expect(json.containsKey('response_format'), isFalse);
        expect(json.containsKey('prompt'), isFalse);
        expect(json.containsKey('temperature'), isFalse);
        expect(json.containsKey('timestamp_granularities'), isFalse);
      });

      test('serializes all fields', () {
        const request = TranscriptionRequest(
          file: 'file-123',
          model: 'custom-model',
          language: 'en',
          responseFormat: 'verbose_json',
          prompt: 'Technical meeting',
          temperature: 0.3,
          timestampGranularities: true,
        );
        final json = request.toJson();
        expect(json['file'], 'file-123');
        expect(json['model'], 'custom-model');
        expect(json['language'], 'en');
        expect(json['response_format'], 'verbose_json');
        expect(json['prompt'], 'Technical meeting');
        expect(json['temperature'], 0.3);
        expect(json['timestamp_granularities'], true);
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{'file': 'file-456'};
        final request = TranscriptionRequest.fromJson(json);
        expect(request.file, 'file-456');
        expect(request.model, 'mistral-audio-latest');
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'file': 'file-456',
          'model': 'custom-model',
          'language': 'fr',
          'response_format': 'srt',
          'prompt': 'French conversation',
          'temperature': 0.7,
          'timestamp_granularities': false,
        };
        final request = TranscriptionRequest.fromJson(json);
        expect(request.file, 'file-456');
        expect(request.model, 'custom-model');
        expect(request.language, 'fr');
        expect(request.responseFormat, 'srt');
        expect(request.prompt, 'French conversation');
        expect(request.temperature, 0.7);
        expect(request.timestampGranularities, false);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'file': 'file-789',
          'model': 'model-abc',
        };
        final request = TranscriptionRequest.fromJson(json);
        expect(request.language, isNull);
        expect(request.responseFormat, isNull);
        expect(request.prompt, isNull);
        expect(request.temperature, isNull);
        expect(request.timestampGranularities, isNull);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const original = TranscriptionRequest(file: 'file-123', language: 'en');
        final copy = original.copyWith();
        expect(copy.file, 'file-123');
        expect(copy.language, 'en');
      });

      test('copies with all changes', () {
        const original = TranscriptionRequest(
          file: 'file-123',
          model: 'model-1',
          language: 'en',
          responseFormat: 'json',
          prompt: 'Original prompt',
          temperature: 0.5,
          timestampGranularities: true,
        );
        final copy = original.copyWith(
          file: 'file-456',
          model: 'model-2',
          language: 'fr',
          responseFormat: 'vtt',
          prompt: 'New prompt',
          temperature: 0.8,
          timestampGranularities: false,
        );
        expect(copy.file, 'file-456');
        expect(copy.model, 'model-2');
        expect(copy.language, 'fr');
        expect(copy.responseFormat, 'vtt');
        expect(copy.prompt, 'New prompt');
        expect(copy.temperature, 0.8);
        expect(copy.timestampGranularities, false);
      });

      test('copies with partial changes', () {
        const original = TranscriptionRequest(
          file: 'file-123',
          language: 'en',
          temperature: 0.5,
        );
        final copy = original.copyWith(language: 'de');
        expect(copy.file, 'file-123');
        expect(copy.language, 'de');
        expect(copy.temperature, 0.5);
      });
    });

    group('equality', () {
      test('equals with same file and model', () {
        const request1 = TranscriptionRequest(file: 'file-123');
        const request2 = TranscriptionRequest(file: 'file-123');
        expect(request1, equals(request2));
        expect(request1.hashCode, request2.hashCode);
      });

      test('not equals with different file', () {
        const request1 = TranscriptionRequest(file: 'file-123');
        const request2 = TranscriptionRequest(file: 'file-456');
        expect(request1, isNot(equals(request2)));
      });

      test('not equals with different model', () {
        const request1 = TranscriptionRequest(file: 'file-123');
        const request2 = TranscriptionRequest(
          file: 'file-123',
          model: 'different-model',
        );
        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const request = TranscriptionRequest(
          file: 'file-123',
          model: 'mistral-audio-latest',
        );
        expect(
          request.toString(),
          'TranscriptionRequest(file: file-123, model: mistral-audio-latest)',
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = TranscriptionRequest(
          file: 'file-roundtrip',
          model: 'custom-model',
          language: 'es',
          responseFormat: 'text',
          prompt: 'Spanish podcast',
          temperature: 0.4,
          timestampGranularities: true,
        );
        final json = original.toJson();
        final restored = TranscriptionRequest.fromJson(json);
        expect(restored.file, original.file);
        expect(restored.model, original.model);
        expect(restored.language, original.language);
        expect(restored.responseFormat, original.responseFormat);
        expect(restored.prompt, original.prompt);
        expect(restored.temperature, original.temperature);
        expect(
          restored.timestampGranularities,
          original.timestampGranularities,
        );
      });
    });
  });
}
