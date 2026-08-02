// ignore_for_file: deprecated_member_use_from_same_package

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TranscriptionConfig', () {
    group('constructor', () {
      test('creates with all fields', () {
        const config = TranscriptionConfig(
          adaptationPhrases: ['legacy phrase'],
          customVocabulary: ['gRPC', 'protobuf'],
          diarizationMode: 'speaker',
          languageCodes: ['en-US', 'es-ES'],
          timestampGranularities: ['word'],
        );
        expect(config.adaptationPhrases, ['legacy phrase']);
        expect(config.customVocabulary, ['gRPC', 'protobuf']);
        expect(config.diarizationMode, 'speaker');
        expect(config.languageCodes, ['en-US', 'es-ES']);
        expect(config.timestampGranularities, ['word']);
      });

      test('creates with no fields', () {
        const config = TranscriptionConfig();
        expect(config.adaptationPhrases, isNull);
        expect(config.customVocabulary, isNull);
        expect(config.diarizationMode, isNull);
        expect(config.languageCodes, isNull);
        expect(config.timestampGranularities, isNull);
      });
    });

    group('toJson', () {
      test('serializes all set fields with snake_case keys', () {
        const config = TranscriptionConfig(
          customVocabulary: ['gRPC'],
          diarizationMode: 'speaker',
          languageCodes: ['en-US'],
          timestampGranularities: ['word'],
        );
        final json = config.toJson();
        expect(json['custom_vocabulary'], ['gRPC']);
        expect(json['diarization_mode'], 'speaker');
        expect(json['language_codes'], ['en-US']);
        expect(json['timestamp_granularities'], ['word']);
      });

      test('omits null fields', () {
        const config = TranscriptionConfig();
        expect(config.toJson(), <String, dynamic>{});
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'adaptation_phrases': ['legacy phrase'],
          'custom_vocabulary': ['gRPC', 'protobuf'],
          'diarization_mode': 'speaker',
          'language_codes': ['en-US', 'es-ES'],
          'timestamp_granularities': ['word'],
        };
        final config = TranscriptionConfig.fromJson(json);
        expect(config.adaptationPhrases, ['legacy phrase']);
        expect(config.customVocabulary, ['gRPC', 'protobuf']);
        expect(config.diarizationMode, 'speaker');
        expect(config.languageCodes, ['en-US', 'es-ES']);
        expect(config.timestampGranularities, ['word']);
      });

      test('handles missing fields', () {
        final config = TranscriptionConfig.fromJson(const {});
        expect(config.customVocabulary, isNull);
        expect(config.timestampGranularities, isNull);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves all fields', () {
        final original = {
          'custom_vocabulary': ['gRPC'],
          'diarization_mode': 'speaker',
          'language_codes': ['en-US'],
          'timestamp_granularities': ['word'],
        };
        final result = TranscriptionConfig.fromJson(original).toJson();
        expect(result, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const config = TranscriptionConfig(
          diarizationMode: 'speaker',
          languageCodes: ['en-US'],
        );
        final copy = config.copyWith();
        expect(copy.diarizationMode, 'speaker');
        expect(copy.languageCodes, ['en-US']);
      });

      test('replaces fields with new values', () {
        const config = TranscriptionConfig(diarizationMode: 'speaker');
        final copy = config.copyWith(
          diarizationMode: 'off',
          customVocabulary: ['new-term'],
        );
        expect(copy.diarizationMode, 'off');
        expect(copy.customVocabulary, ['new-term']);
      });

      test('copies with null to clear fields', () {
        const config = TranscriptionConfig(
          diarizationMode: 'speaker',
          languageCodes: ['en-US'],
        );
        final copy = config.copyWith(
          diarizationMode: null,
          languageCodes: null,
        );
        expect(copy.diarizationMode, isNull);
        expect(copy.languageCodes, isNull);
      });

      test('preserves unspecified fields', () {
        const config = TranscriptionConfig(
          diarizationMode: 'speaker',
          languageCodes: ['en-US'],
        );
        final copy = config.copyWith(diarizationMode: 'off');
        expect(copy.diarizationMode, 'off');
        expect(copy.languageCodes, ['en-US']);
      });
    });
  });
}
