import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbedRequest', () {
    test('fromJson creates request correctly', () {
      final json = {'model': 'nomic-embed-text', 'input': 'Hello, world!'};

      final request = EmbedRequest.fromJson(json);

      expect(request.model, 'nomic-embed-text');
      expect(request.input, 'Hello, world!');
    });

    test('toJson converts request correctly', () {
      const request = EmbedRequest(
        model: 'nomic-embed-text',
        input: 'Hello, world!',
      );

      final json = request.toJson();

      expect(json['model'], 'nomic-embed-text');
      expect(json['input'], 'Hello, world!');
    });

    test('handles list of inputs', () {
      final json = {
        'model': 'nomic-embed-text',
        'input': ['Hello', 'World'],
      };

      final request = EmbedRequest.fromJson(json);
      expect(request.input, ['Hello', 'World']);

      final outputJson = request.toJson();
      expect(outputJson['input'], ['Hello', 'World']);
    });

    test('handles optional parameters', () {
      const request = EmbedRequest(
        model: 'nomic-embed-text',
        input: 'Hello',
        truncate: true,
        dimensions: 512,
        keepAlive: '5m',
      );

      final json = request.toJson();

      expect(json['truncate'], true);
      expect(json['dimensions'], 512);
      expect(json['keep_alive'], '5m');
    });

    test('equality works correctly for string input', () {
      const request1 = EmbedRequest(model: 'nomic-embed-text', input: 'Hello');
      const request2 = EmbedRequest(model: 'nomic-embed-text', input: 'Hello');

      expect(request1, equals(request2));
      expect(request1.hashCode, equals(request2.hashCode));
    });

    test('equality works correctly for list input', () {
      const request1 = EmbedRequest(
        model: 'nomic-embed-text',
        input: ['Hello', 'World'],
      );
      const request2 = EmbedRequest(
        model: 'nomic-embed-text',
        input: ['Hello', 'World'],
      );
      const request3 = EmbedRequest(
        model: 'nomic-embed-text',
        input: ['Hello', 'Different'],
      );

      expect(request1, equals(request2));
      expect(request1.hashCode, equals(request2.hashCode));
      expect(request1, isNot(equals(request3)));
    });

    test('equality includes all fields', () {
      const request1 = EmbedRequest(
        model: 'nomic-embed-text',
        input: 'Hello',
        truncate: true,
        dimensions: 512,
        keepAlive: '5m',
      );
      const request2 = EmbedRequest(
        model: 'nomic-embed-text',
        input: 'Hello',
        truncate: false,
        dimensions: 512,
        keepAlive: '5m',
      );

      expect(request1, isNot(equals(request2)));
    });
  });

  group('EmbedResponse', () {
    test('fromJson creates response correctly', () {
      final json = {
        'model': 'nomic-embed-text',
        'embeddings': [
          [0.1, 0.2, 0.3],
          [0.4, 0.5, 0.6],
        ],
      };

      final response = EmbedResponse.fromJson(json);

      expect(response.model, 'nomic-embed-text');
      expect(response.embeddings?.length, 2);
      expect(response.embeddings?[0], [0.1, 0.2, 0.3]);
    });

    test('toJson converts response correctly', () {
      const response = EmbedResponse(
        model: 'nomic-embed-text',
        embeddings: [
          [0.1, 0.2, 0.3],
        ],
      );

      final json = response.toJson();

      expect(json['model'], 'nomic-embed-text');
      expect((json['embeddings'] as List).length, 1);
    });

    test('handles duration fields', () {
      final json = {
        'model': 'nomic-embed-text',
        'embeddings': [
          [0.1, 0.2],
        ],
        'total_duration': 1000000,
        'load_duration': 500000,
        'prompt_eval_count': 5,
      };

      final response = EmbedResponse.fromJson(json);

      expect(response.totalDuration, 1000000);
      expect(response.loadDuration, 500000);
      expect(response.promptEvalCount, 5);
    });

    test('copyWith works correctly', () {
      const original = EmbedResponse(
        model: 'nomic-embed-text',
        embeddings: [
          [0.1, 0.2],
        ],
      );

      final copied = original.copyWith(model: 'other-model');

      expect(copied.model, 'other-model');
      expect(copied.embeddings, original.embeddings);
    });

    test('embedding getter returns first embedding when present', () {
      const response = EmbedResponse(
        model: 'nomic-embed-text',
        embeddings: [
          [0.1, 0.2, 0.3],
          [0.4, 0.5, 0.6],
        ],
      );

      expect(response.embedding, [0.1, 0.2, 0.3]);
    });

    test('embedding getter returns null when embeddings is empty', () {
      const response = EmbedResponse(model: 'nomic-embed-text', embeddings: []);

      expect(response.embedding, isNull);
    });

    test('embedding getter returns null when embeddings is null', () {
      const response = EmbedResponse(model: 'nomic-embed-text');

      expect(response.embedding, isNull);
    });

    test('equality compares nested embeddings by content', () {
      const response1 = EmbedResponse(
        model: 'nomic-embed-text',
        embeddings: [
          [0.1, 0.2, 0.3],
          [0.4, 0.5, 0.6],
        ],
        totalDuration: 1000000,
        loadDuration: 500000,
        promptEvalCount: 5,
      );
      const response2 = EmbedResponse(
        model: 'nomic-embed-text',
        embeddings: [
          [0.1, 0.2, 0.3],
          [0.4, 0.5, 0.6],
        ],
        totalDuration: 1000000,
        loadDuration: 500000,
        promptEvalCount: 5,
      );

      expect(response1, equals(response2));
      expect(response1.hashCode, equals(response2.hashCode));
    });

    test('equality detects single element change in embeddings', () {
      const response1 = EmbedResponse(
        model: 'nomic-embed-text',
        embeddings: [
          [0.1, 0.2, 0.3],
        ],
      );
      const response2 = EmbedResponse(
        model: 'nomic-embed-text',
        embeddings: [
          [0.1, 0.2, 0.999],
        ],
      );

      expect(response1, isNot(equals(response2)));
    });

    test('equality includes duration and token fields', () {
      const response1 = EmbedResponse(
        model: 'nomic-embed-text',
        totalDuration: 1000000,
      );
      const response2 = EmbedResponse(
        model: 'nomic-embed-text',
        totalDuration: 2000000,
      );

      expect(response1, isNot(equals(response2)));
    });
  });
}
