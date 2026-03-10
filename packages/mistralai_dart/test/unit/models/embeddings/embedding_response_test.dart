import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbeddingResponse', () {
    test('creates with required fields', () {
      const response = EmbeddingResponse(
        id: 'emb-123',
        object: 'list',
        data: [
          EmbeddingData(
            object: 'embedding',
            embedding: [0.1, 0.2, 0.3],
            index: 0,
          ),
        ],
        model: 'mistral-embed',
      );

      expect(response.id, 'emb-123');
      expect(response.object, 'list');
      expect(response.data, hasLength(1));
      expect(response.model, 'mistral-embed');
      expect(response.usage, isNull);
    });

    test('creates with usage', () {
      const response = EmbeddingResponse(
        id: 'emb-456',
        object: 'list',
        data: [],
        model: 'mistral-embed',
        usage: UsageInfo(
          promptTokens: 10,
          completionTokens: 0,
          totalTokens: 10,
        ),
      );

      expect(response.usage, isNotNull);
      expect(response.usage!.promptTokens, 10);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'emb-789',
        'object': 'list',
        'data': [
          {
            'object': 'embedding',
            'embedding': [0.5, 0.6],
            'index': 0,
          },
        ],
        'model': 'mistral-embed',
        'usage': {'prompt_tokens': 5, 'total_tokens': 5},
      };
      final response = EmbeddingResponse.fromJson(json);

      expect(response.id, 'emb-789');
      expect(response.data, hasLength(1));
      expect(response.data.first.embedding, [0.5, 0.6]);
      expect(response.usage, isNotNull);
    });

    test('serializes to JSON', () {
      const response = EmbeddingResponse(
        id: 'emb-abc',
        object: 'list',
        data: [
          EmbeddingData(object: 'embedding', embedding: [0.1], index: 0),
        ],
        model: 'mistral-embed',
      );
      final json = response.toJson();

      expect(json['id'], 'emb-abc');
      expect(json['object'], 'list');
      expect(json['data'], isList);
      expect(json['model'], 'mistral-embed');
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const original = EmbeddingResponse(
          id: 'emb-100',
          object: 'list',
          model: 'mistral-embed',
          data: [
            EmbeddingData(object: 'embedding', embedding: [0.1], index: 0),
          ],
          usage: UsageInfo(
            promptTokens: 5,
            completionTokens: 0,
            totalTokens: 5,
          ),
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
        expect(copied.id, original.id);
        expect(copied.object, original.object);
        expect(copied.model, original.model);
        expect(copied.data, original.data);
        expect(copied.usage, original.usage);
      });

      test('copies with all changes', () {
        const original = EmbeddingResponse(
          id: 'emb-100',
          object: 'list',
          model: 'mistral-embed',
          data: [],
        );
        final copied = original.copyWith(
          id: 'emb-200',
          object: 'updated-list',
          model: 'new-embed',
          data: const [
            EmbeddingData(object: 'embedding', embedding: [0.9], index: 0),
          ],
          usage: const UsageInfo(
            promptTokens: 10,
            completionTokens: 0,
            totalTokens: 10,
          ),
        );

        expect(copied.id, 'emb-200');
        expect(copied.object, 'updated-list');
        expect(copied.model, 'new-embed');
        expect(copied.data, hasLength(1));
        expect(copied.usage!.promptTokens, 10);
      });

      test('copies with partial changes', () {
        const original = EmbeddingResponse(
          id: 'emb-100',
          object: 'list',
          model: 'mistral-embed',
          data: [],
          usage: UsageInfo(
            promptTokens: 5,
            completionTokens: 0,
            totalTokens: 5,
          ),
        );
        final copied = original.copyWith(model: 'new-embed');

        expect(copied.id, 'emb-100');
        expect(copied.model, 'new-embed');
        expect(copied.usage, original.usage);
      });

      test('can set usage to null', () {
        const original = EmbeddingResponse(
          id: 'emb-100',
          object: 'list',
          model: 'mistral-embed',
          data: [],
          usage: UsageInfo(
            promptTokens: 5,
            completionTokens: 0,
            totalTokens: 5,
          ),
        );
        final copied = original.copyWith(usage: null);

        expect(copied.usage, isNull);
      });
    });

    group('toString', () {
      test('includes all fields', () {
        const response = EmbeddingResponse(
          id: 'emb-test',
          object: 'list',
          model: 'mistral-embed',
          data: [
            EmbeddingData(object: 'embedding', embedding: [0.1], index: 0),
          ],
        );
        final str = response.toString();

        expect(
          str,
          'EmbeddingResponse(id: emb-test, object: list, '
          'model: mistral-embed, data: 1, usage: null)',
        );
      });
    });
  });

  group('EmbeddingData', () {
    test('creates with required fields', () {
      const data = EmbeddingData(
        object: 'embedding',
        embedding: [0.1, 0.2, 0.3, 0.4, 0.5],
        index: 0,
      );

      expect(data.object, 'embedding');
      expect(data.embedding, hasLength(5));
      expect(data.index, 0);
    });

    test('deserializes from JSON', () {
      final json = {
        'object': 'embedding',
        'embedding': [0.1, 0.2],
        'index': 1,
      };
      final data = EmbeddingData.fromJson(json);

      expect(data.object, 'embedding');
      expect(data.embedding, [0.1, 0.2]);
      expect(data.index, 1);
    });

    test('serializes to JSON', () {
      const data = EmbeddingData(
        object: 'embedding',
        embedding: [0.5, 0.6, 0.7],
        index: 2,
      );
      final json = data.toJson();

      expect(json['object'], 'embedding');
      expect(json['embedding'], [0.5, 0.6, 0.7]);
      expect(json['index'], 2);
    });
  });
}
