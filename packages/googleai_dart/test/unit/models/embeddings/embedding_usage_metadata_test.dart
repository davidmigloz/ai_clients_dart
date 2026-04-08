import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbeddingUsageMetadata', () {
    group('constructor', () {
      test('creates with all fields', () {
        const metadata = EmbeddingUsageMetadata(
          promptTokenCount: 10,
          promptTokenDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 10),
          ],
        );
        expect(metadata.promptTokenCount, 10);
        expect(metadata.promptTokenDetails, hasLength(1));
      });

      test('creates with no fields', () {
        const metadata = EmbeddingUsageMetadata();
        expect(metadata.promptTokenCount, isNull);
        expect(metadata.promptTokenDetails, isNull);
      });
    });

    group('fromJson', () {
      test('deserializes with all fields', () {
        final json = {
          'promptTokenCount': 15,
          'promptTokenDetails': [
            {'modality': 'TEXT', 'tokenCount': 10},
            {'modality': 'IMAGE', 'tokenCount': 5},
          ],
        };
        final metadata = EmbeddingUsageMetadata.fromJson(json);
        expect(metadata.promptTokenCount, 15);
        expect(metadata.promptTokenDetails, hasLength(2));
        expect(metadata.promptTokenDetails![0].modality, 'TEXT');
        expect(metadata.promptTokenDetails![0].tokenCount, 10);
        expect(metadata.promptTokenDetails![1].modality, 'IMAGE');
        expect(metadata.promptTokenDetails![1].tokenCount, 5);
      });

      test('deserializes with null fields', () {
        final json = <String, dynamic>{};
        final metadata = EmbeddingUsageMetadata.fromJson(json);
        expect(metadata.promptTokenCount, isNull);
        expect(metadata.promptTokenDetails, isNull);
      });

      test('deserializes with partial fields', () {
        final json = {'promptTokenCount': 7};
        final metadata = EmbeddingUsageMetadata.fromJson(json);
        expect(metadata.promptTokenCount, 7);
        expect(metadata.promptTokenDetails, isNull);
      });
    });

    group('toJson', () {
      test('serializes with all fields', () {
        const metadata = EmbeddingUsageMetadata(
          promptTokenCount: 10,
          promptTokenDetails: [
            ModalityTokenCount(modality: 'TEXT', tokenCount: 10),
          ],
        );
        final json = metadata.toJson();
        expect(json['promptTokenCount'], 10);
        expect(json['promptTokenDetails'], hasLength(1));
      });

      test('omits null fields', () {
        const metadata = EmbeddingUsageMetadata();
        final json = metadata.toJson();
        expect(json.containsKey('promptTokenCount'), isFalse);
        expect(json.containsKey('promptTokenDetails'), isFalse);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson round-trip with all fields', () {
        final original = {
          'promptTokenCount': 20,
          'promptTokenDetails': [
            {'modality': 'TEXT', 'tokenCount': 20},
          ],
        };
        final result = EmbeddingUsageMetadata.fromJson(original).toJson();
        expect(result['promptTokenCount'], original['promptTokenCount']);
        expect(
          (result['promptTokenDetails'] as List).length,
          (original['promptTokenDetails']! as List).length,
        );
      });

      test('fromJson/toJson round-trip with empty', () {
        final original = <String, dynamic>{};
        final result = EmbeddingUsageMetadata.fromJson(original).toJson();
        expect(result, isEmpty);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const metadata = EmbeddingUsageMetadata(promptTokenCount: 5);
        final copy = metadata.copyWith();
        expect(copy.promptTokenCount, 5);
        expect(copy.promptTokenDetails, isNull);
      });

      test('copies with updated fields', () {
        const metadata = EmbeddingUsageMetadata(promptTokenCount: 5);
        final copy = metadata.copyWith(promptTokenCount: 10);
        expect(copy.promptTokenCount, 10);
      });

      test('copies with null to clear fields', () {
        const metadata = EmbeddingUsageMetadata(promptTokenCount: 5);
        final copy = metadata.copyWith(promptTokenCount: null);
        expect(copy.promptTokenCount, isNull);
      });
    });
  });

  group('EmbedContentResponse', () {
    group('fromJson', () {
      test('deserializes with usageMetadata', () {
        final json = {
          'embedding': {
            'values': [0.1, 0.2, 0.3],
          },
          'usageMetadata': {'promptTokenCount': 5},
        };
        final response = EmbedContentResponse.fromJson(json);
        expect(response.embedding.values, [0.1, 0.2, 0.3]);
        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 5);
      });

      test('deserializes without usageMetadata', () {
        final json = {
          'embedding': {
            'values': [0.1, 0.2],
          },
        };
        final response = EmbedContentResponse.fromJson(json);
        expect(response.embedding.values, [0.1, 0.2]);
        expect(response.usageMetadata, isNull);
      });
    });

    group('toJson', () {
      test('serializes with usageMetadata', () {
        const response = EmbedContentResponse(
          embedding: ContentEmbedding(values: [0.5]),
          usageMetadata: EmbeddingUsageMetadata(promptTokenCount: 3),
        );
        final json = response.toJson();
        expect(json['embedding'], isNotNull);
        expect(json['usageMetadata'], isNotNull);
        expect((json['usageMetadata'] as Map)['promptTokenCount'], 3);
      });

      test('omits null usageMetadata', () {
        const response = EmbedContentResponse(
          embedding: ContentEmbedding(values: [0.5]),
        );
        final json = response.toJson();
        expect(json.containsKey('usageMetadata'), isFalse);
      });
    });

    group('copyWith', () {
      test('copies with updated usageMetadata', () {
        const response = EmbedContentResponse(
          embedding: ContentEmbedding(values: [0.5]),
        );
        final copy = response.copyWith(
          usageMetadata: const EmbeddingUsageMetadata(promptTokenCount: 7),
        );
        expect(copy.usageMetadata, isNotNull);
        expect(copy.usageMetadata!.promptTokenCount, 7);
        expect(copy.embedding.values, [0.5]);
      });

      test('copies with null to clear usageMetadata', () {
        const response = EmbedContentResponse(
          embedding: ContentEmbedding(values: [0.5]),
          usageMetadata: EmbeddingUsageMetadata(promptTokenCount: 7),
        );
        final copy = response.copyWith(usageMetadata: null);
        expect(copy.usageMetadata, isNull);
      });
    });
  });

  group('BatchEmbedContentsResponse', () {
    group('fromJson', () {
      test('deserializes with usageMetadata', () {
        final json = {
          'embeddings': [
            {
              'values': [0.1, 0.2],
            },
            {
              'values': [0.3, 0.4],
            },
          ],
          'usageMetadata': {
            'promptTokenCount': 12,
            'promptTokenDetails': [
              {'modality': 'TEXT', 'tokenCount': 12},
            ],
          },
        };
        final response = BatchEmbedContentsResponse.fromJson(json);
        expect(response.embeddings, hasLength(2));
        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 12);
        expect(response.usageMetadata!.promptTokenDetails, hasLength(1));
      });

      test('deserializes without usageMetadata', () {
        final json = {
          'embeddings': [
            {
              'values': [0.1],
            },
          ],
        };
        final response = BatchEmbedContentsResponse.fromJson(json);
        expect(response.embeddings, hasLength(1));
        expect(response.usageMetadata, isNull);
      });
    });

    group('toJson', () {
      test('serializes with usageMetadata', () {
        const response = BatchEmbedContentsResponse(
          embeddings: [
            ContentEmbedding(values: [0.5]),
          ],
          usageMetadata: EmbeddingUsageMetadata(promptTokenCount: 8),
        );
        final json = response.toJson();
        expect(json['embeddings'], hasLength(1));
        expect(json['usageMetadata'], isNotNull);
      });

      test('omits null usageMetadata', () {
        const response = BatchEmbedContentsResponse(
          embeddings: [
            ContentEmbedding(values: [0.5]),
          ],
        );
        final json = response.toJson();
        expect(json.containsKey('usageMetadata'), isFalse);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const response = BatchEmbedContentsResponse(
          embeddings: [
            ContentEmbedding(values: [0.5]),
          ],
          usageMetadata: EmbeddingUsageMetadata(promptTokenCount: 3),
        );
        final copy = response.copyWith();
        expect(copy.embeddings, hasLength(1));
        expect(copy.usageMetadata!.promptTokenCount, 3);
      });

      test('copies with updated usageMetadata', () {
        const response = BatchEmbedContentsResponse(
          embeddings: [
            ContentEmbedding(values: [0.5]),
          ],
        );
        final copy = response.copyWith(
          usageMetadata: const EmbeddingUsageMetadata(promptTokenCount: 9),
        );
        expect(copy.usageMetadata!.promptTokenCount, 9);
      });
    });
  });
}
