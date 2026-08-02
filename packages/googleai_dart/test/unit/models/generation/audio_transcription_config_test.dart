import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('GenerationAudioTranscriptionConfig', () {
    test('creates with required fields', () {
      const config = GenerationAudioTranscriptionConfig();
      expect(config.adaptationPhrases, isNull);
      expect(config.customVocabulary, isNull);
      expect(config.diarization, isNull);
      expect(config.languageAuto, isNull);
      expect(config.languageCodes, isNull);
      expect(config.languageHints, isNull);
      expect(config.wordTimestamp, isNull);
    });

    test('creates with all fields', () {
      const config = GenerationAudioTranscriptionConfig(
        adaptationPhrases: ['hello world'],
        customVocabulary: ['acme corp'],
        diarization: true,
        languageAuto: LanguageAuto(),
        languageCodes: ['en-US'],
        languageHints: LanguageHints(languageCodes: ['en-US', 'es-ES']),
        wordTimestamp: true,
      );
      expect(config.adaptationPhrases, ['hello world']);
      expect(config.customVocabulary, ['acme corp']);
      expect(config.diarization, isTrue);
      expect(config.languageAuto, const LanguageAuto());
      expect(config.languageCodes, ['en-US']);
      expect(
        config.languageHints,
        const LanguageHints(languageCodes: ['en-US', 'es-ES']),
      );
      expect(config.wordTimestamp, isTrue);
    });

    test('serializes to JSON', () {
      const config = GenerationAudioTranscriptionConfig(
        adaptationPhrases: ['hello world'],
        customVocabulary: ['acme corp'],
        diarization: true,
        languageAuto: LanguageAuto(),
        languageCodes: ['en-US'],
        languageHints: LanguageHints(languageCodes: ['en-US']),
        wordTimestamp: true,
      );
      final json = config.toJson();
      expect(json['adaptationPhrases'], ['hello world']);
      expect(json['customVocabulary'], ['acme corp']);
      expect(json['diarization'], isTrue);
      expect(json['languageAuto'], <String, dynamic>{});
      expect(json['languageCodes'], ['en-US']);
      expect(json['languageHints'], {
        'languageCodes': ['en-US'],
      });
      expect(json['wordTimestamp'], isTrue);
    });

    test('omits null fields from JSON', () {
      const config = GenerationAudioTranscriptionConfig();
      final json = config.toJson();
      expect(json.containsKey('adaptationPhrases'), isFalse);
      expect(json.containsKey('customVocabulary'), isFalse);
      expect(json.containsKey('diarization'), isFalse);
      expect(json.containsKey('languageAuto'), isFalse);
      expect(json.containsKey('languageCodes'), isFalse);
      expect(json.containsKey('languageHints'), isFalse);
      expect(json.containsKey('wordTimestamp'), isFalse);
    });

    test('deserializes from JSON', () {
      final json = {
        'adaptationPhrases': ['hello world'],
        'customVocabulary': ['acme corp'],
        'diarization': true,
        'languageAuto': <String, dynamic>{},
        'languageCodes': ['en-US'],
        'languageHints': {
          'languageCodes': ['en-US'],
        },
        'wordTimestamp': true,
      };
      final config = GenerationAudioTranscriptionConfig.fromJson(json);
      expect(config.adaptationPhrases, ['hello world']);
      expect(config.customVocabulary, ['acme corp']);
      expect(config.diarization, isTrue);
      expect(config.languageAuto, const LanguageAuto());
      expect(config.languageCodes, ['en-US']);
      expect(config.languageHints?.languageCodes, ['en-US']);
      expect(config.wordTimestamp, isTrue);
    });

    test('roundtrip serialization', () {
      const original = GenerationAudioTranscriptionConfig(
        adaptationPhrases: ['hello world'],
        customVocabulary: ['acme corp'],
        diarization: true,
        languageAuto: LanguageAuto(),
        languageCodes: ['en-US'],
        languageHints: LanguageHints(languageCodes: ['en-US']),
        wordTimestamp: true,
      );
      final json = original.toJson();
      final restored = GenerationAudioTranscriptionConfig.fromJson(json);
      expect(restored.adaptationPhrases, original.adaptationPhrases);
      expect(restored.customVocabulary, original.customVocabulary);
      expect(restored.diarization, original.diarization);
      expect(restored.languageAuto, original.languageAuto);
      expect(restored.languageCodes, original.languageCodes);
      expect(
        restored.languageHints?.languageCodes,
        original.languageHints?.languageCodes,
      );
      expect(restored.wordTimestamp, original.wordTimestamp);
    });

    test('copyWith replaces values', () {
      const original = GenerationAudioTranscriptionConfig(
        diarization: false,
        languageCodes: ['en-US'],
      );
      final copy = original.copyWith(
        diarization: true,
        languageCodes: ['es-ES'],
      );
      expect(copy.diarization, isTrue);
      expect(copy.languageCodes, ['es-ES']);
    });

    test('copyWith preserves values by default', () {
      const original = GenerationAudioTranscriptionConfig(
        diarization: true,
        wordTimestamp: true,
        languageCodes: ['en-US'],
      );
      final copy = original.copyWith();
      expect(copy.diarization, original.diarization);
      expect(copy.wordTimestamp, original.wordTimestamp);
      expect(copy.languageCodes, original.languageCodes);
    });

    test('copyWith supports explicit null clearing via sentinel', () {
      const original = GenerationAudioTranscriptionConfig(
        diarization: true,
        languageCodes: ['en-US'],
        wordTimestamp: true,
      );
      final copy = original.copyWith(diarization: null, languageCodes: null);
      expect(copy.diarization, isNull);
      expect(copy.languageCodes, isNull);
      expect(copy.wordTimestamp, original.wordTimestamp);
    });
  });

  group('LanguageHints', () {
    test('creates with required fields', () {
      const hints = LanguageHints(languageCodes: ['en-US']);
      expect(hints.languageCodes, ['en-US']);
    });

    test('serializes to JSON, always emitting languageCodes', () {
      const hints = LanguageHints(languageCodes: []);
      final json = hints.toJson();
      expect(json.containsKey('languageCodes'), isTrue);
      expect(json['languageCodes'], <String>[]);
    });

    test('deserializes from JSON', () {
      final json = {
        'languageCodes': ['en-US', 'es-ES'],
      };
      final hints = LanguageHints.fromJson(json);
      expect(hints.languageCodes, ['en-US', 'es-ES']);
    });

    test('roundtrip serialization', () {
      const original = LanguageHints(languageCodes: ['en-US', 'es-ES']);
      final json = original.toJson();
      final restored = LanguageHints.fromJson(json);
      expect(restored.languageCodes, original.languageCodes);
    });

    test('copyWith replaces values', () {
      const original = LanguageHints(languageCodes: ['en-US']);
      final copy = original.copyWith(languageCodes: ['fr-FR']);
      expect(copy.languageCodes, ['fr-FR']);
    });

    test('copyWith preserves values by default', () {
      const original = LanguageHints(languageCodes: ['en-US']);
      final copy = original.copyWith();
      expect(copy.languageCodes, original.languageCodes);
    });
  });

  group('LanguageAuto', () {
    test('creates a const instance', () {
      const marker = LanguageAuto();
      expect(marker, isA<LanguageAuto>());
    });

    test('serializes to an empty JSON object', () {
      const marker = LanguageAuto();
      expect(marker.toJson(), <String, dynamic>{});
    });

    test('deserializes from any JSON object', () {
      final marker = LanguageAuto.fromJson(<String, dynamic>{});
      expect(marker, isA<LanguageAuto>());
    });

    test('roundtrip serialization', () {
      const original = LanguageAuto();
      final json = original.toJson();
      final restored = LanguageAuto.fromJson(json);
      expect(restored, isA<LanguageAuto>());
    });
  });
}
