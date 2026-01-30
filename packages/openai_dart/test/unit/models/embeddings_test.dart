import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbeddingResponse', () {
    test('fromJson parses response correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'object': 'embedding',
            'index': 0,
            'embedding': [0.1, 0.2, 0.3, 0.4, 0.5],
          },
        ],
        'model': 'text-embedding-3-small',
        'usage': {'prompt_tokens': 5, 'total_tokens': 5},
      };

      final response = EmbeddingResponse.fromJson(json);

      expect(response.object, 'list');
      expect(response.data.length, 1);
      expect(response.data.first.embedding.length, 5);
      expect(response.data.first.embedding[0], 0.1);
      expect(response.model, 'text-embedding-3-small');
      expect(response.usage!.promptTokens, 5);
    });

    test('handles multiple embeddings', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'object': 'embedding',
            'index': 0,
            'embedding': [0.1, 0.2, 0.3],
          },
          {
            'object': 'embedding',
            'index': 1,
            'embedding': [0.4, 0.5, 0.6],
          },
        ],
        'model': 'text-embedding-3-small',
        'usage': {'prompt_tokens': 10, 'total_tokens': 10},
      };

      final response = EmbeddingResponse.fromJson(json);

      expect(response.data.length, 2);
      expect(response.data[0].index, 0);
      expect(response.data[1].index, 1);
    });

    test('firstEmbedding getter returns first embedding vector', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'object': 'embedding',
            'index': 0,
            'embedding': [0.1, 0.2, 0.3],
          },
        ],
        'model': 'text-embedding-3-small',
        'usage': {'prompt_tokens': 5, 'total_tokens': 5},
      };

      final response = EmbeddingResponse.fromJson(json);
      expect(response.firstEmbedding, [0.1, 0.2, 0.3]);
    });
  });

  group('EmbeddingRequest', () {
    test('creates with text input', () {
      final request = EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.text('Hello, world!'),
      );

      final json = request.toJson();

      expect(json['model'], 'text-embedding-3-small');
      expect(json['input'], 'Hello, world!');
    });

    test('creates with textList input', () {
      final request = EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.textList(['Hello', 'World']),
      );

      final json = request.toJson();

      expect(json['model'], 'text-embedding-3-small');
      expect(json['input'], ['Hello', 'World']);
    });

    test('includes dimensions when specified', () {
      final request = EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.text('Hello'),
        dimensions: 256,
      );

      final json = request.toJson();

      expect(json['dimensions'], 256);
    });

    test('includes encoding format when specified', () {
      final request = EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.text('Hello'),
        encodingFormat: EmbeddingEncodingFormat.float,
      );

      final json = request.toJson();

      expect(json['encoding_format'], 'float');
    });
  });

  group('EmbeddingInput', () {
    test('text input serializes correctly', () {
      final input = EmbeddingInput.text('test');
      expect(input.toJson(), 'test');
    });

    test('textList input serializes correctly', () {
      final input = EmbeddingInput.textList(['a', 'b', 'c']);
      expect(input.toJson(), ['a', 'b', 'c']);
    });

    test('tokens input serializes correctly', () {
      final input = EmbeddingInput.tokens([1, 2, 3]);
      expect(input.toJson(), [1, 2, 3]);
    });

    test('tokensList input serializes correctly', () {
      final input = EmbeddingInput.tokensList([
        [1, 2],
        [3, 4],
      ]);
      expect(input.toJson(), [
        [1, 2],
        [3, 4],
      ]);
    });

    test('fromJson parses string input', () {
      final input = EmbeddingInput.fromJson('hello');
      expect(input, isA<EmbeddingInputText>());
      expect((input as EmbeddingInputText).text, 'hello');
    });

    test('fromJson parses string list input', () {
      final input = EmbeddingInput.fromJson(['a', 'b']);
      expect(input, isA<EmbeddingInputTextList>());
      expect((input as EmbeddingInputTextList).texts, ['a', 'b']);
    });

    test('fromJson parses token list input', () {
      final input = EmbeddingInput.fromJson([1, 2, 3]);
      expect(input, isA<EmbeddingInputTokens>());
      expect((input as EmbeddingInputTokens).tokens, [1, 2, 3]);
    });
  });

  group('Embedding', () {
    test('dimensions getter returns correct value', () {
      const embedding = Embedding(
        object: 'embedding',
        embedding: [0.1, 0.2, 0.3, 0.4, 0.5],
        index: 0,
      );

      expect(embedding.dimensions, 5);
    });
  });

  group('EmbeddingEncodingFormat', () {
    test('parses float correctly', () {
      expect(
        EmbeddingEncodingFormat.fromJson('float'),
        EmbeddingEncodingFormat.float,
      );
    });

    test('parses base64 correctly', () {
      expect(
        EmbeddingEncodingFormat.fromJson('base64'),
        EmbeddingEncodingFormat.base64,
      );
    });

    test('toJson returns correct values', () {
      expect(EmbeddingEncodingFormat.float.toJson(), 'float');
      expect(EmbeddingEncodingFormat.base64.toJson(), 'base64');
    });
  });

  // OpenAI-Compatible APIs Tests
  group('OpenAI-Compatible APIs', () {
    test('handles missing usage (Together AI)', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'object': 'embedding',
            'index': 0,
            'embedding': [0.1, 0.2, 0.3],
          },
        ],
        'model': 'text-embedding-3-small',
        // No 'usage' field
      };

      final response = EmbeddingResponse.fromJson(json);

      expect(response.usage, isNull);
      expect(response.data.length, 1);
      expect(response.firstEmbedding, [0.1, 0.2, 0.3]);
    });

    test('toJson excludes null usage', () {
      const response = EmbeddingResponse(
        object: 'list',
        data: [
          Embedding(object: 'embedding', embedding: [0.1, 0.2], index: 0),
        ],
        model: 'text-embedding-3-small',
        // No usage
      );

      final json = response.toJson();

      expect(json.containsKey('usage'), false);
    });
  });
}
