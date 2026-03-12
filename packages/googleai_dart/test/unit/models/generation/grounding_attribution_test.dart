import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('GroundingPassageId', () {
    test('fromJson', () {
      final json = {'partIndex': 2, 'passageId': 'passage-abc'};
      final id = GroundingPassageId.fromJson(json);
      expect(id.partIndex, 2);
      expect(id.passageId, 'passage-abc');
    });

    test('fromJson with nulls', () {
      final id = GroundingPassageId.fromJson(<String, dynamic>{});
      expect(id.partIndex, isNull);
      expect(id.passageId, isNull);
    });

    test('toJson includes non-null fields', () {
      const id = GroundingPassageId(partIndex: 0, passageId: 'p1');
      final json = id.toJson();
      expect(json['partIndex'], 0);
      expect(json['passageId'], 'p1');
    });

    test('round-trip', () {
      const id = GroundingPassageId(partIndex: 3, passageId: 'passage-xyz');
      final restored = GroundingPassageId.fromJson(id.toJson());
      expect(restored.partIndex, id.partIndex);
      expect(restored.passageId, id.passageId);
    });

    test('copyWith', () {
      const id = GroundingPassageId(partIndex: 1, passageId: 'p1');
      final updated = id.copyWith(partIndex: 5);
      expect(updated.partIndex, 5);
      expect(updated.passageId, 'p1');
    });
  });

  group('AttributionSourceId', () {
    test('fromJson with groundingPassage', () {
      final json = {
        'groundingPassage': {'partIndex': 0, 'passageId': 'p1'},
      };
      final sourceId = AttributionSourceId.fromJson(json);
      expect(sourceId.groundingPassage, isNotNull);
      expect(sourceId.groundingPassage!.passageId, 'p1');
      expect(sourceId.semanticRetrieverChunk, isNull);
    });

    test('fromJson with semanticRetrieverChunk', () {
      final json = {
        'semanticRetrieverChunk': {
          'source': 'corpora/123',
          'chunk': 'corpora/123/documents/abc/chunks/xyz',
        },
      };
      final sourceId = AttributionSourceId.fromJson(json);
      expect(sourceId.groundingPassage, isNull);
      expect(sourceId.semanticRetrieverChunk, isNotNull);
      expect(sourceId.semanticRetrieverChunk!.source, 'corpora/123');
      expect(
        sourceId.semanticRetrieverChunk!.chunk,
        'corpora/123/documents/abc/chunks/xyz',
      );
    });

    test('toJson omits null fields', () {
      const sourceId = AttributionSourceId();
      final json = sourceId.toJson();
      expect(json.containsKey('groundingPassage'), isFalse);
      expect(json.containsKey('semanticRetrieverChunk'), isFalse);
    });

    test('round-trip with groundingPassage', () {
      const sourceId = AttributionSourceId(
        groundingPassage: GroundingPassageId(partIndex: 1, passageId: 'p1'),
      );
      final restored = AttributionSourceId.fromJson(sourceId.toJson());
      expect(restored.groundingPassage!.partIndex, 1);
      expect(restored.groundingPassage!.passageId, 'p1');
    });

    test('round-trip with semanticRetrieverChunk', () {
      const sourceId = AttributionSourceId(
        semanticRetrieverChunk: SemanticRetrieverChunk(
          source: 'corpora/my-corpus',
          chunk: 'corpora/my-corpus/documents/doc1/chunks/c1',
        ),
      );
      final restored = AttributionSourceId.fromJson(sourceId.toJson());
      expect(restored.semanticRetrieverChunk!.source, 'corpora/my-corpus');
      expect(
        restored.semanticRetrieverChunk!.chunk,
        'corpora/my-corpus/documents/doc1/chunks/c1',
      );
    });

    test('copyWith', () {
      const sourceId = AttributionSourceId(
        groundingPassage: GroundingPassageId(partIndex: 0, passageId: 'p0'),
      );
      final updated = sourceId.copyWith(
        semanticRetrieverChunk: const SemanticRetrieverChunk(
          source: 'corpora/new',
        ),
      );
      expect(updated.groundingPassage!.passageId, 'p0');
      expect(updated.semanticRetrieverChunk!.source, 'corpora/new');
    });
  });

  group('GroundingAttribution', () {
    test('fromJson with all fields', () {
      final json = {
        'content': {
          'parts': [
            {'text': 'attributed content'},
          ],
        },
        'sourceId': {
          'groundingPassage': {'partIndex': 0, 'passageId': 'p1'},
        },
      };
      final attr = GroundingAttribution.fromJson(json);
      expect(attr.content, isNotNull);
      expect(attr.content!.parts, hasLength(1));
      expect(attr.sourceId, isNotNull);
      expect(attr.sourceId!.groundingPassage!.passageId, 'p1');
    });

    test('fromJson with nulls', () {
      final attr = GroundingAttribution.fromJson(<String, dynamic>{});
      expect(attr.content, isNull);
      expect(attr.sourceId, isNull);
    });

    test('toJson omits null fields', () {
      const attr = GroundingAttribution();
      final json = attr.toJson();
      expect(json.containsKey('content'), isFalse);
      expect(json.containsKey('sourceId'), isFalse);
    });

    test('round-trip', () {
      final attr = GroundingAttribution(
        content: Content.text('some passage'),
        sourceId: const AttributionSourceId(
          semanticRetrieverChunk: SemanticRetrieverChunk(
            source: 'corpora/123',
            chunk: 'corpora/123/documents/d/chunks/c',
          ),
        ),
      );
      final restored = GroundingAttribution.fromJson(attr.toJson());
      expect(restored.content!.parts, hasLength(1));
      expect(restored.sourceId!.semanticRetrieverChunk!.source, 'corpora/123');
    });

    test('copyWith', () {
      const attr = GroundingAttribution(
        sourceId: AttributionSourceId(
          groundingPassage: GroundingPassageId(partIndex: 0, passageId: 'p0'),
        ),
      );
      final updated = attr.copyWith(content: Content.text('new content'));
      expect(updated.content, isNotNull);
      expect(updated.sourceId!.groundingPassage!.passageId, 'p0');
    });
  });

  group('Candidate.groundingAttributions', () {
    test('fromJson deserializes typed groundingAttributions', () {
      final json = {
        'content': {
          'parts': [
            {'text': 'answer'},
          ],
        },
        'finishReason': 'STOP',
        'groundingAttributions': [
          {
            'content': {
              'parts': [
                {'text': 'source passage'},
              ],
            },
            'sourceId': {
              'groundingPassage': {'partIndex': 0, 'passageId': 'p1'},
            },
          },
          {
            'sourceId': {
              'semanticRetrieverChunk': {
                'source': 'corpora/123',
                'chunk': 'corpora/123/documents/d/chunks/c',
              },
            },
          },
        ],
      };
      final candidate = Candidate.fromJson(json);
      expect(candidate.groundingAttributions, hasLength(2));
      expect(
        candidate
            .groundingAttributions![0]
            .sourceId!
            .groundingPassage!
            .passageId,
        'p1',
      );
      expect(
        candidate
            .groundingAttributions![1]
            .sourceId!
            .semanticRetrieverChunk!
            .source,
        'corpora/123',
      );
    });

    test('toJson serializes typed groundingAttributions', () {
      final candidate = Candidate(
        groundingAttributions: [
          GroundingAttribution(
            content: Content.text('passage'),
            sourceId: const AttributionSourceId(
              groundingPassage: GroundingPassageId(
                partIndex: 0,
                passageId: 'p1',
              ),
            ),
          ),
        ],
      );
      final json = candidate.toJson();
      final attrs = json['groundingAttributions'] as List;
      expect(attrs, hasLength(1));
      final attr = attrs[0] as Map<String, dynamic>;
      expect(attr.containsKey('content'), isTrue);
      expect(attr.containsKey('sourceId'), isTrue);
    });

    test('null groundingAttributions omitted from JSON', () {
      const candidate = Candidate();
      final json = candidate.toJson();
      expect(json.containsKey('groundingAttributions'), isFalse);
    });
  });
}
