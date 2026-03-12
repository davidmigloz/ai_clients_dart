import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Condition', () {
    test('fromJson with string value', () {
      final json = {'operation': 'EQUAL', 'stringValue': 'drama'};
      final condition = Condition.fromJson(json);
      expect(condition.operation, 'EQUAL');
      expect(condition.stringValue, 'drama');
      expect(condition.numericValue, isNull);
    });

    test('fromJson with numeric value', () {
      final json = {'operation': 'GREATER', 'numericValue': 0.5};
      final condition = Condition.fromJson(json);
      expect(condition.operation, 'GREATER');
      expect(condition.numericValue, 0.5);
      expect(condition.stringValue, isNull);
    });

    test('toJson omits null fields', () {
      const condition = Condition(operation: 'EQUAL', stringValue: 'test');
      final json = condition.toJson();
      expect(json['operation'], 'EQUAL');
      expect(json['stringValue'], 'test');
      expect(json.containsKey('numericValue'), isFalse);
    });

    test('round-trip', () {
      const condition = Condition(operation: 'LESS_EQUAL', numericValue: 3.14);
      final restored = Condition.fromJson(condition.toJson());
      expect(restored.operation, condition.operation);
      expect(restored.numericValue, condition.numericValue);
      expect(restored.stringValue, condition.stringValue);
    });
  });

  group('MetadataFilter', () {
    test('fromJson', () {
      final json = {
        'key': 'document.custom_metadata.genre',
        'conditions': [
          {'operation': 'EQUAL', 'stringValue': 'drama'},
          {'operation': 'EQUAL', 'stringValue': 'action'},
        ],
      };
      final filter = MetadataFilter.fromJson(json);
      expect(filter.key, 'document.custom_metadata.genre');
      expect(filter.conditions, hasLength(2));
      expect(filter.conditions[0].stringValue, 'drama');
      expect(filter.conditions[1].stringValue, 'action');
    });

    test('toJson round-trip', () {
      const filter = MetadataFilter(
        key: 'genre',
        conditions: [Condition(operation: 'EQUAL', stringValue: 'drama')],
      );
      final restored = MetadataFilter.fromJson(filter.toJson());
      expect(restored.key, filter.key);
      expect(restored.conditions, hasLength(1));
      expect(restored.conditions[0].operation, 'EQUAL');
    });
  });

  group('SemanticRetrieverConfig', () {
    test('fromJson with all fields', () {
      final json = {
        'source': 'corpora/123',
        'query': {
          'parts': [
            {'text': 'test query'},
          ],
        },
        'maxChunksCount': 5,
        'minimumRelevanceScore': 0.7,
        'metadataFilters': [
          {
            'key': 'genre',
            'conditions': [
              {'operation': 'EQUAL', 'stringValue': 'drama'},
            ],
          },
        ],
      };
      final config = SemanticRetrieverConfig.fromJson(json);
      expect(config.source, 'corpora/123');
      expect(config.query.parts, hasLength(1));
      expect(config.maxChunksCount, 5);
      expect(config.minimumRelevanceScore, 0.7);
      expect(config.metadataFilters, hasLength(1));
      expect(config.metadataFilters![0].key, 'genre');
    });

    test('fromJson with required fields only', () {
      final json = {
        'source': 'corpora/123/documents/abc',
        'query': {
          'parts': [
            {'text': 'search query'},
          ],
        },
      };
      final config = SemanticRetrieverConfig.fromJson(json);
      expect(config.source, 'corpora/123/documents/abc');
      expect(config.maxChunksCount, isNull);
      expect(config.minimumRelevanceScore, isNull);
      expect(config.metadataFilters, isNull);
    });

    test('toJson omits null fields', () {
      final config = SemanticRetrieverConfig(
        source: 'corpora/123',
        query: Content.text('query'),
      );
      final json = config.toJson();
      expect(json['source'], 'corpora/123');
      expect(json.containsKey('query'), isTrue);
      expect(json.containsKey('maxChunksCount'), isFalse);
      expect(json.containsKey('minimumRelevanceScore'), isFalse);
      expect(json.containsKey('metadataFilters'), isFalse);
    });

    test('round-trip with all fields', () {
      final config = SemanticRetrieverConfig(
        source: 'corpora/123',
        query: Content.text('test'),
        maxChunksCount: 10,
        minimumRelevanceScore: 0.5,
        metadataFilters: const [
          MetadataFilter(
            key: 'genre',
            conditions: [Condition(operation: 'EQUAL', stringValue: 'drama')],
          ),
        ],
      );
      final restored = SemanticRetrieverConfig.fromJson(config.toJson());
      expect(restored.source, config.source);
      expect(restored.maxChunksCount, config.maxChunksCount);
      expect(restored.minimumRelevanceScore, config.minimumRelevanceScore);
      expect(restored.metadataFilters, hasLength(1));
    });
  });

  group('SemanticRetrieverChunk', () {
    test('fromJson', () {
      final json = {
        'source': 'corpora/123',
        'chunk': 'corpora/123/documents/abc/chunks/xyz',
      };
      final chunk = SemanticRetrieverChunk.fromJson(json);
      expect(chunk.source, 'corpora/123');
      expect(chunk.chunk, 'corpora/123/documents/abc/chunks/xyz');
    });

    test('toJson omits null fields', () {
      const chunk = SemanticRetrieverChunk();
      final json = chunk.toJson();
      expect(json.containsKey('source'), isFalse);
      expect(json.containsKey('chunk'), isFalse);
    });

    test('round-trip', () {
      const chunk = SemanticRetrieverChunk(
        source: 'corpora/123',
        chunk: 'corpora/123/documents/abc/chunks/xyz',
      );
      final restored = SemanticRetrieverChunk.fromJson(chunk.toJson());
      expect(restored.source, chunk.source);
      expect(restored.chunk, chunk.chunk);
    });
  });

  group('GenerateAnswerRequest with semanticRetriever', () {
    test('fromJson includes semanticRetriever', () {
      final json = {
        'contents': [
          {
            'parts': [
              {'text': 'What is Dart?'},
            ],
          },
        ],
        'answerStyle': 'VERBOSE',
        'semanticRetriever': {
          'source': 'corpora/my-corpus',
          'query': {
            'parts': [
              {'text': 'Dart features'},
            ],
          },
          'maxChunksCount': 5,
        },
      };
      final request = GenerateAnswerRequest.fromJson(json);
      expect(request.semanticRetriever, isNotNull);
      expect(request.semanticRetriever!.source, 'corpora/my-corpus');
      expect(request.semanticRetriever!.maxChunksCount, 5);
    });

    test('toJson includes semanticRetriever when set', () {
      final request = GenerateAnswerRequest(
        contents: [Content.text('question')],
        answerStyle: AnswerStyle.verbose,
        semanticRetriever: SemanticRetrieverConfig(
          source: 'corpora/my-corpus',
          query: Content.text('query'),
          maxChunksCount: 5,
          minimumRelevanceScore: 0.5,
        ),
      );
      final json = request.toJson();
      expect(json.containsKey('semanticRetriever'), isTrue);
      final sr = json['semanticRetriever'] as Map<String, dynamic>;
      expect(sr['source'], 'corpora/my-corpus');
      expect(sr['maxChunksCount'], 5);
    });

    test('toJson omits semanticRetriever when null', () {
      final request = GenerateAnswerRequest(
        contents: [Content.text('question')],
        answerStyle: AnswerStyle.abstractive,
      );
      final json = request.toJson();
      expect(json.containsKey('semanticRetriever'), isFalse);
    });
  });
}
