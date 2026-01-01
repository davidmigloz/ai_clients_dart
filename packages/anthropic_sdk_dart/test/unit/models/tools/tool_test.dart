import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Tool', () {
    test('can be created with required fields', () {
      const tool = Tool(
        name: 'get_weather',
        inputSchema: InputSchema(
          properties: {
            'location': {'type': 'string', 'description': 'City name'},
          },
        ),
      );

      expect(tool.name, 'get_weather');
      expect(tool.type, isNull);
      expect(tool.description, isNull);
    });

    test('can be created with all fields', () {
      const tool = Tool(
        type: 'custom',
        name: 'get_weather',
        description: 'Get the weather for a location',
        inputSchema: InputSchema(
          properties: {
            'location': {'type': 'string', 'description': 'City name'},
          },
        ),
        cacheControl: CacheControlEphemeral(),
      );

      expect(tool.type, 'custom');
      expect(tool.name, 'get_weather');
      expect(tool.description, 'Get the weather for a location');
      expect(tool.cacheControl, isNotNull);
    });

    group('fromJson', () {
      test('parses basic tool', () {
        final json = {
          'name': 'calculator',
          'input_schema': {
            'type': 'object',
            'properties': {
              'expression': {'type': 'string'},
            },
          },
        };

        final tool = Tool.fromJson(json);

        expect(tool.name, 'calculator');
        expect(tool.type, isNull);
      });

      test('parses tool with all fields', () {
        final json = {
          'type': 'custom',
          'name': 'search',
          'description': 'Search the web',
          'input_schema': {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'},
            },
          },
          'cache_control': {'type': 'ephemeral'},
        };

        final tool = Tool.fromJson(json);

        expect(tool.type, 'custom');
        expect(tool.name, 'search');
        expect(tool.description, 'Search the web');
        expect(tool.cacheControl, isNotNull);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const tool = Tool(name: 'test_tool', inputSchema: InputSchema());

        final json = tool.toJson();

        expect(json['name'], 'test_tool');
        expect(json['input_schema'], isNotNull);
        expect(json.containsKey('type'), isFalse);
        expect(json.containsKey('description'), isFalse);
      });

      test('serializes all fields', () {
        const tool = Tool(
          type: 'custom',
          name: 'test_tool',
          description: 'A test tool',
          inputSchema: InputSchema(),
          cacheControl: CacheControlEphemeral(),
        );

        final json = tool.toJson();

        expect(json['type'], 'custom');
        expect(json['name'], 'test_tool');
        expect(json['description'], 'A test tool');
        expect(json['cache_control'], {'type': 'ephemeral'});
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        const original = Tool(name: 'old_name', inputSchema: InputSchema());

        final copy = original.copyWith(name: 'new_name');

        expect(copy.name, 'new_name');
      });

      test('can set nullable fields to null', () {
        const original = Tool(
          type: 'custom',
          name: 'tool',
          description: 'Has description',
          inputSchema: InputSchema(),
        );

        final copy = original.copyWith(type: null, description: null);

        expect(copy.type, isNull);
        expect(copy.description, isNull);
      });

      test('preserves unchanged fields', () {
        const original = Tool(
          type: 'custom',
          name: 'tool',
          description: 'Description',
          inputSchema: InputSchema(),
        );

        final copy = original.copyWith(name: 'new_name');

        expect(copy.type, 'custom');
        expect(copy.description, 'Description');
      });
    });

    group('equality', () {
      test('equal tools are equal', () {
        const schema = InputSchema();
        const t1 = Tool(name: 'tool', inputSchema: schema);
        const t2 = Tool(name: 'tool', inputSchema: schema);

        expect(t1, equals(t2));
      });

      test('different names means not equal', () {
        const schema = InputSchema();
        const t1 = Tool(name: 'tool_a', inputSchema: schema);
        const t2 = Tool(name: 'tool_b', inputSchema: schema);

        expect(t1, isNot(equals(t2)));
      });
    });
  });
}
