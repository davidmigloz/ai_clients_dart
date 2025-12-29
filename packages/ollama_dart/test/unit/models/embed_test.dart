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

    test('equality works correctly', () {
      const request1 = EmbedRequest(model: 'nomic-embed-text', input: 'Hello');
      const request2 = EmbedRequest(model: 'nomic-embed-text', input: 'Hello');

      expect(request1, equals(request2));
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
  });
}
