// ignore_for_file: deprecated_member_use_from_same_package

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbedContentRequest', () {
    group('fromJson', () {
      test('deserializes with embedContentConfig', () {
        final json = {
          'content': {
            'parts': [
              {'text': 'hello'},
            ],
          },
          'embedContentConfig': {
            'taskType': 'RETRIEVAL_DOCUMENT',
            'title': 'Doc',
            'outputDimensionality': 64,
          },
        };
        final request = EmbedContentRequest.fromJson(json);
        expect(request.embedContentConfig, isNotNull);
        expect(
          request.embedContentConfig!.taskType,
          TaskType.retrievalDocument,
        );
        expect(request.embedContentConfig!.title, 'Doc');
        expect(request.embedContentConfig!.outputDimensionality, 64);
        expect(request.taskType, isNull);
        expect(request.title, isNull);
        expect(request.outputDimensionality, isNull);
      });

      test('deserializes with deprecated top-level fields', () {
        final json = {
          'content': {
            'parts': [
              {'text': 'hi'},
            ],
          },
          'taskType': 'RETRIEVAL_QUERY',
          'title': 'Legacy',
          'outputDimensionality': 128,
        };
        final request = EmbedContentRequest.fromJson(json);
        expect(request.embedContentConfig, isNull);
        expect(request.taskType, TaskType.retrievalQuery);
        expect(request.title, 'Legacy');
        expect(request.outputDimensionality, 128);
      });
    });

    group('toJson', () {
      test('serializes with embedContentConfig', () {
        const request = EmbedContentRequest(
          content: Content(parts: [TextPart('hi')]),
          embedContentConfig: EmbedContentConfig(
            taskType: TaskType.retrievalQuery,
            outputDimensionality: 64,
          ),
        );
        final json = request.toJson();
        expect(json['embedContentConfig'], isA<Map<String, dynamic>>());
        final cfg = json['embedContentConfig'] as Map<String, dynamic>;
        expect(cfg['taskType'], 'RETRIEVAL_QUERY');
        expect(cfg['outputDimensionality'], 64);
        expect(json.containsKey('taskType'), isFalse);
        expect(json.containsKey('outputDimensionality'), isFalse);
      });

      test('serializes deprecated top-level fields alongside config', () {
        const request = EmbedContentRequest(
          content: Content(parts: [TextPart('x')]),
          embedContentConfig: EmbedContentConfig(title: 'New'),
          title: 'Legacy',
        );
        final json = request.toJson();
        expect(json['title'], 'Legacy');
        expect(
          (json['embedContentConfig']! as Map<String, dynamic>)['title'],
          'New',
        );
      });

      test('omits embedContentConfig when null', () {
        const request = EmbedContentRequest(
          content: Content(parts: [TextPart('x')]),
        );
        final json = request.toJson();
        expect(json.containsKey('embedContentConfig'), isFalse);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves embedContentConfig', () {
        final original = {
          'content': {
            'parts': [
              {'text': 'round'},
            ],
          },
          'embedContentConfig': {
            'taskType': 'CLASSIFICATION',
            'autoTruncate': true,
          },
        };
        final result = EmbedContentRequest.fromJson(original).toJson();
        expect(result['embedContentConfig'], original['embedContentConfig']);
      });
    });

    group('copyWith', () {
      test('updates embedContentConfig', () {
        const request = EmbedContentRequest(
          content: Content(parts: [TextPart('hi')]),
        );
        final copy = request.copyWith(
          embedContentConfig: const EmbedContentConfig(
            taskType: TaskType.clustering,
          ),
        );
        expect(copy.embedContentConfig!.taskType, TaskType.clustering);
      });

      test('clears embedContentConfig with null', () {
        const request = EmbedContentRequest(
          content: Content(parts: [TextPart('hi')]),
          embedContentConfig: EmbedContentConfig(title: 't'),
        );
        final copy = request.copyWith(embedContentConfig: null);
        expect(copy.embedContentConfig, isNull);
      });
    });
  });
}
