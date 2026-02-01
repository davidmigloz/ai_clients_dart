import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseFormat', () {
    test('ResponseFormat.fromJson parses json string', () {
      expect(ResponseFormat.fromJson('json'), isA<JsonFormat>());
    });

    test('ResponseFormat.fromJson parses schema map', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      };
      final result = ResponseFormat.fromJson(schema);
      expect(result, isA<SchemaFormat>());
      expect((result! as SchemaFormat).schema, schema);
    });

    test('ResponseFormat.fromJson returns null for unknown values', () {
      expect(ResponseFormat.fromJson(null), isNull);
      expect(ResponseFormat.fromJson('unknown'), isNull);
      expect(ResponseFormat.fromJson(123), isNull);
    });

    test('JsonFormat.toJson returns json string', () {
      expect(const JsonFormat().toJson(), 'json');
    });

    test('SchemaFormat.toJson returns schema map', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      };
      expect(SchemaFormat(schema).toJson(), schema);
    });

    test('JsonFormat equality works correctly', () {
      expect(const JsonFormat(), equals(const JsonFormat()));
    });

    test('SchemaFormat equality works correctly', () {
      final schema = {'type': 'object'};
      expect(SchemaFormat(schema), equals(SchemaFormat(schema)));
      expect(
        SchemaFormat(schema),
        isNot(equals(SchemaFormat(const {'type': 'array'}))),
      );
    });

    test('ResponseFormat toString returns readable string', () {
      expect(const JsonFormat().toString(), 'JsonFormat()');
      expect(
        SchemaFormat(const {'type': 'object'}).toString(),
        'SchemaFormat({type: object})',
      );
    });

    test('SchemaFormat equality works with nested maps', () {
      final schema1 = {
        'type': 'object',
        'properties': {
          'address': {
            'type': 'object',
            'properties': {
              'street': {'type': 'string'},
              'city': {'type': 'string'},
            },
          },
        },
      };
      final schema2 = {
        'type': 'object',
        'properties': {
          'address': {
            'type': 'object',
            'properties': {
              'street': {'type': 'string'},
              'city': {'type': 'string'},
            },
          },
        },
      };

      expect(SchemaFormat(schema1), equals(SchemaFormat(schema2)));
    });

    test('SchemaFormat equality works with nested lists', () {
      final schema1 = {
        'type': 'object',
        'required': ['name', 'age'],
        'properties': {
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
      };
      final schema2 = {
        'type': 'object',
        'required': ['name', 'age'],
        'properties': {
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
      };

      expect(SchemaFormat(schema1), equals(SchemaFormat(schema2)));
    });

    test('SchemaFormat inequality works with different nested values', () {
      final schema1 = {
        'properties': {
          'address': {'type': 'object'},
        },
      };
      final schema2 = {
        'properties': {
          'address': {'type': 'string'},
        },
      };

      expect(SchemaFormat(schema1), isNot(equals(SchemaFormat(schema2))));
    });

    test('SchemaFormat stores unmodifiable copy of schema', () {
      final originalSchema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      };
      final format = SchemaFormat(originalSchema);

      // Modifying original should not affect stored schema
      originalSchema['type'] = 'array';
      expect(format.schema['type'], 'object');
    });

    test('SchemaFormat schema is deeply unmodifiable', () {
      final format = SchemaFormat(const {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      });

      // Attempting to modify should throw
      expect(() => format.schema['type'] = 'array', throwsUnsupportedError);
      expect(
        () => (format.schema['properties'] as Map)['age'] = {'type': 'int'},
        throwsUnsupportedError,
      );
    });

    test('SchemaFormat hashCode is consistent for equal schemas', () {
      final schema1 = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      };
      final schema2 = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      };

      expect(
        SchemaFormat(schema1).hashCode,
        equals(SchemaFormat(schema2).hashCode),
      );
    });
  });

  group('ResponseFormat in requests', () {
    test('ChatRequest serializes JsonFormat correctly', () {
      const request = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
        format: JsonFormat(),
      );

      final json = request.toJson();
      expect(json['format'], 'json');
    });

    test('ChatRequest serializes SchemaFormat correctly', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      };
      final request = ChatRequest(
        model: 'llama3.2',
        messages: const [ChatMessage.user('Hello')],
        format: SchemaFormat(schema),
      );

      final json = request.toJson();
      expect(json['format'], schema);
    });

    test('ChatRequest deserializes JsonFormat correctly', () {
      final json = {
        'model': 'llama3.2',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'format': 'json',
      };

      final request = ChatRequest.fromJson(json);
      expect(request.format, isA<JsonFormat>());
    });

    test('ChatRequest deserializes SchemaFormat correctly', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
      };
      final json = {
        'model': 'llama3.2',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'format': schema,
      };

      final request = ChatRequest.fromJson(json);
      expect(request.format, isA<SchemaFormat>());
      expect((request.format! as SchemaFormat).schema, schema);
    });

    test('GenerateRequest serializes JsonFormat correctly', () {
      const request = GenerateRequest(
        model: 'llama3.2',
        prompt: 'Hello',
        format: JsonFormat(),
      );

      final json = request.toJson();
      expect(json['format'], 'json');
    });

    test('GenerateRequest deserializes JsonFormat correctly', () {
      final json = {'model': 'llama3.2', 'prompt': 'Hello', 'format': 'json'};

      final request = GenerateRequest.fromJson(json);
      expect(request.format, isA<JsonFormat>());
    });
  });
}
