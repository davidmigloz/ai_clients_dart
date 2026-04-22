import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbedContentConfig', () {
    group('constructor', () {
      test('creates with all fields', () {
        const config = EmbedContentConfig(
          taskType: TaskType.retrievalDocument,
          title: 'A doc',
          outputDimensionality: 256,
          autoTruncate: true,
          documentOcr: true,
          audioTrackExtraction: false,
        );
        expect(config.taskType, TaskType.retrievalDocument);
        expect(config.title, 'A doc');
        expect(config.outputDimensionality, 256);
        expect(config.autoTruncate, isTrue);
        expect(config.documentOcr, isTrue);
        expect(config.audioTrackExtraction, isFalse);
      });

      test('creates with no fields', () {
        const config = EmbedContentConfig();
        expect(config.taskType, isNull);
        expect(config.title, isNull);
        expect(config.outputDimensionality, isNull);
        expect(config.autoTruncate, isNull);
        expect(config.documentOcr, isNull);
        expect(config.audioTrackExtraction, isNull);
      });
    });

    group('fromJson', () {
      test('deserializes with all fields', () {
        final json = {
          'taskType': 'RETRIEVAL_QUERY',
          'title': 'Title',
          'outputDimensionality': 128,
          'autoTruncate': true,
          'documentOcr': false,
          'audioTrackExtraction': true,
        };
        final config = EmbedContentConfig.fromJson(json);
        expect(config.taskType, TaskType.retrievalQuery);
        expect(config.title, 'Title');
        expect(config.outputDimensionality, 128);
        expect(config.autoTruncate, isTrue);
        expect(config.documentOcr, isFalse);
        expect(config.audioTrackExtraction, isTrue);
      });

      test('deserializes with empty JSON', () {
        final config = EmbedContentConfig.fromJson(<String, dynamic>{});
        expect(config.taskType, isNull);
        expect(config.title, isNull);
        expect(config.outputDimensionality, isNull);
        expect(config.autoTruncate, isNull);
        expect(config.documentOcr, isNull);
        expect(config.audioTrackExtraction, isNull);
      });
    });

    group('toJson', () {
      test('serializes all set fields', () {
        const config = EmbedContentConfig(
          taskType: TaskType.semanticSimilarity,
          title: 'T',
          outputDimensionality: 64,
          autoTruncate: true,
          documentOcr: true,
          audioTrackExtraction: true,
        );
        final json = config.toJson();
        expect(json['taskType'], 'SEMANTIC_SIMILARITY');
        expect(json['title'], 'T');
        expect(json['outputDimensionality'], 64);
        expect(json['autoTruncate'], isTrue);
        expect(json['documentOcr'], isTrue);
        expect(json['audioTrackExtraction'], isTrue);
      });

      test('omits null fields', () {
        const config = EmbedContentConfig();
        expect(config.toJson(), isEmpty);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves all fields', () {
        final original = {
          'taskType': 'CLASSIFICATION',
          'title': 'Round',
          'outputDimensionality': 32,
          'autoTruncate': false,
          'documentOcr': true,
          'audioTrackExtraction': false,
        };
        final result = EmbedContentConfig.fromJson(original).toJson();
        expect(result, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const config = EmbedContentConfig(
          taskType: TaskType.clustering,
          title: 'X',
        );
        final copy = config.copyWith();
        expect(copy.taskType, TaskType.clustering);
        expect(copy.title, 'X');
      });

      test('copies with updated fields', () {
        const config = EmbedContentConfig(outputDimensionality: 100);
        final copy = config.copyWith(outputDimensionality: 200, title: 'new');
        expect(copy.outputDimensionality, 200);
        expect(copy.title, 'new');
      });

      test('copies with null to clear fields', () {
        const config = EmbedContentConfig(
          taskType: TaskType.factVerification,
          documentOcr: true,
        );
        final copy = config.copyWith(taskType: null, documentOcr: null);
        expect(copy.taskType, isNull);
        expect(copy.documentOcr, isNull);
      });
    });
  });
}
