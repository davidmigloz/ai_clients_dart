import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbeddingRequest', () {
    test('creates single input request', () {
      final request = EmbeddingRequest.single(
        model: 'mistral-embed',
        input: 'Hello, world!',
      );

      expect(request.model, 'mistral-embed');
      expect(request.input, isA<EmbedInputString>());
      expect((request.input as EmbedInputString).value, 'Hello, world!');
    });

    test('creates batch input request', () {
      final request = EmbeddingRequest.batch(
        model: 'mistral-embed',
        input: const ['Text 1', 'Text 2', 'Text 3'],
      );

      expect(request.model, 'mistral-embed');
      expect(request.input, isA<EmbedInputList>());
      expect((request.input as EmbedInputList).values, [
        'Text 1',
        'Text 2',
        'Text 3',
      ]);
    });

    test('creates with encoding format', () {
      final request = EmbeddingRequest.single(
        model: 'mistral-embed',
        input: 'Test',
        encodingFormat: 'float',
      );

      expect(request.encodingFormat, 'float');
    });

    test('serializes to JSON', () {
      final request = EmbeddingRequest.batch(
        model: 'mistral-embed',
        input: const ['a', 'b'],
        encodingFormat: 'float',
      );
      final json = request.toJson();

      expect(json['model'], 'mistral-embed');
      expect(json['input'], ['a', 'b']);
      expect(json['encoding_format'], 'float');
    });

    test('deserializes from JSON', () {
      final json = {
        'model': 'mistral-embed',
        'input': ['test input'],
        'encoding_format': 'float',
      };
      final request = EmbeddingRequest.fromJson(json);

      expect(request.model, 'mistral-embed');
      expect(request.input, isA<EmbedInputList>());
      expect((request.input as EmbedInputList).values, ['test input']);
      expect(request.encodingFormat, 'float');
    });

    test('handles missing optional fields', () {
      final json = {
        'model': 'mistral-embed',
        'input': ['test'],
      };
      final request = EmbeddingRequest.fromJson(json);

      expect(request.encodingFormat, isNull);
      expect(request.outputDimension, isNull);
      expect(request.outputDtype, isNull);
      expect(request.metadata, isNull);
    });

    test('creates with outputDimension', () {
      const request = EmbeddingRequest(
        model: 'mistral-embed',
        input: EmbedInput.string('Test'),
        outputDimension: 256,
      );

      expect(request.outputDimension, 256);
    });

    test('creates with outputDtype', () {
      const request = EmbeddingRequest(
        model: 'mistral-embed',
        input: EmbedInput.string('Test'),
        outputDtype: EmbeddingDtype.float,
      );

      expect(request.outputDtype, EmbeddingDtype.float);
    });

    test('serializes with all optional fields', () {
      const request = EmbeddingRequest(
        model: 'mistral-embed',
        input: EmbedInput.list(['Hello', 'World']),
        outputDimension: 256,
        outputDtype: EmbeddingDtype.int8,
        encodingFormat: 'float',
        metadata: {'project': 'test'},
      );

      final json = request.toJson();

      expect(json['model'], 'mistral-embed');
      expect(json['input'], ['Hello', 'World']);
      expect(json['output_dimension'], 256);
      expect(json['output_dtype'], 'int8');
      expect(json['encoding_format'], 'float');
      expect(json['metadata'], {'project': 'test'});
    });

    test('omits null metadata from JSON', () {
      const request = EmbeddingRequest(
        model: 'mistral-embed',
        input: EmbedInput.string('Test'),
      );

      final json = request.toJson();

      expect(json.containsKey('metadata'), isFalse);
    });

    test('deserializes with all optional fields', () {
      final json = {
        'model': 'mistral-embed',
        'input': ['Hello'],
        'output_dimension': 512,
        'output_dtype': 'int8',
        'encoding_format': 'base64',
        'metadata': {'project': 'test'},
      };

      final request = EmbeddingRequest.fromJson(json);

      expect(request.outputDimension, 512);
      expect(request.outputDtype, EmbeddingDtype.int8);
      expect(request.encodingFormat, 'base64');
      expect(request.metadata, {'project': 'test'});
    });

    test('copyWith creates a copy with modified fields', () {
      const original = EmbeddingRequest(
        model: 'mistral-embed',
        input: EmbedInput.string('Original'),
        outputDimension: 256,
      );

      final modified = original.copyWith(
        input: const EmbedInput.string('Modified'),
        outputDimension: 512,
        outputDtype: EmbeddingDtype.float,
      );

      expect(modified.model, 'mistral-embed');
      expect((modified.input as EmbedInputString).value, 'Modified');
      expect(modified.outputDimension, 512);
      expect(modified.outputDtype, EmbeddingDtype.float);
    });

    test('copyWith preserves unmodified fields', () {
      const original = EmbeddingRequest(
        model: 'mistral-embed',
        input: EmbedInput.string('Test'),
        outputDimension: 256,
        outputDtype: EmbeddingDtype.int8,
      );

      final modified = original.copyWith(encodingFormat: 'base64');

      expect(modified.model, 'mistral-embed');
      expect((modified.input as EmbedInputString).value, 'Test');
      expect(modified.outputDimension, 256);
      expect(modified.outputDtype, EmbeddingDtype.int8);
      expect(modified.encodingFormat, 'base64');
    });

    test('copyWith updates metadata', () {
      const original = EmbeddingRequest(
        model: 'mistral-embed',
        input: EmbedInput.string('Test'),
        metadata: {'key': 'old'},
      );

      final modified = original.copyWith(metadata: {'key': 'new'});

      expect(modified.metadata, {'key': 'new'});
      expect(modified.model, 'mistral-embed');
      expect((modified.input as EmbedInputString).value, 'Test');
    });

    group('equality', () {
      test('requests with different metadata are not equal', () {
        const request1 = EmbeddingRequest(
          model: 'mistral-embed',
          input: EmbedInput.string('Test'),
          metadata: {'key': 'value1'},
        );
        const request2 = EmbeddingRequest(
          model: 'mistral-embed',
          input: EmbedInput.string('Test'),
          metadata: {'key': 'value2'},
        );

        expect(request1, isNot(equals(request2)));
      });

      test('requests with same metadata are equal', () {
        const request1 = EmbeddingRequest(
          model: 'mistral-embed',
          input: EmbedInput.string('Test'),
          metadata: {'key': 'value'},
        );
        const request2 = EmbeddingRequest(
          model: 'mistral-embed',
          input: EmbedInput.string('Test'),
          metadata: {'key': 'value'},
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });
    });

    group('toString', () {
      test('includes all fields including metadata', () {
        const request = EmbeddingRequest(
          model: 'mistral-embed',
          input: EmbedInput.string('Test'),
          encodingFormat: 'float',
          outputDimension: 256,
          outputDtype: EmbeddingDtype.int8,
          metadata: {'project': 'test'},
        );
        final str = request.toString();

        expect(
          str,
          'EmbeddingRequest(model: mistral-embed, '
          'input: EmbedInputString(Test), '
          'encodingFormat: float, outputDimension: 256, '
          'outputDtype: EmbeddingDtype.int8, metadata: {project: test})',
        );
      });

      test('shows null for missing optional fields', () {
        const request = EmbeddingRequest(
          model: 'mistral-embed',
          input: EmbedInput.string('Test'),
        );
        final str = request.toString();

        expect(str, contains('encodingFormat: null'));
        expect(str, contains('outputDimension: null'));
        expect(str, contains('outputDtype: null'));
        expect(str, contains('metadata: null'));
      });
    });
  });

  group('EmbeddingDtype', () {
    test('has all expected values', () {
      expect(EmbeddingDtype.values, hasLength(5));
      expect(
        EmbeddingDtype.values,
        containsAll([
          EmbeddingDtype.float,
          EmbeddingDtype.int8,
          EmbeddingDtype.uint8,
          EmbeddingDtype.binary,
          EmbeddingDtype.ubinary,
        ]),
      );
    });

    test('fromString parses valid values', () {
      expect(EmbeddingDtype.fromString('float'), EmbeddingDtype.float);
      expect(EmbeddingDtype.fromString('int8'), EmbeddingDtype.int8);
      expect(EmbeddingDtype.fromString('uint8'), EmbeddingDtype.uint8);
      expect(EmbeddingDtype.fromString('binary'), EmbeddingDtype.binary);
      expect(EmbeddingDtype.fromString('ubinary'), EmbeddingDtype.ubinary);
    });

    test('fromString defaults to float for unknown values', () {
      expect(EmbeddingDtype.fromString('unknown'), EmbeddingDtype.float);
      expect(EmbeddingDtype.fromString(null), EmbeddingDtype.float);
    });

    test('value property returns correct string', () {
      expect(EmbeddingDtype.float.value, 'float');
      expect(EmbeddingDtype.int8.value, 'int8');
      expect(EmbeddingDtype.uint8.value, 'uint8');
      expect(EmbeddingDtype.binary.value, 'binary');
      expect(EmbeddingDtype.ubinary.value, 'ubinary');
    });
  });
}
