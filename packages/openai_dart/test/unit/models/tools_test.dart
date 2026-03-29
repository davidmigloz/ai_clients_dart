import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Tool', () {
    test('function factory creates function tool', () {
      final tool = Tool.function(
        name: 'get_weather',
        description: 'Get the current weather',
        parameters: const {
          'type': 'object',
          'properties': {
            'location': {'type': 'string'},
          },
        },
      );

      expect(tool.type, 'function');
      expect(tool.function.name, 'get_weather');
      expect(tool.function.description, 'Get the current weather');
      expect(tool.function.parameters, isNotNull);
    });

    test('toJson serializes correctly', () {
      final tool = Tool.function(
        name: 'calculate',
        description: 'Calculate a math expression',
      );

      final json = tool.toJson();
      final functionJson = json['function'] as Map<String, dynamic>;

      expect(json['type'], 'function');
      expect(functionJson, isA<Map<String, dynamic>>());
      expect(functionJson['name'], 'calculate');
    });

    test('fromJson parses correctly', () {
      final json = {
        'type': 'function',
        'function': {
          'name': 'search',
          'description': 'Search the web',
          'parameters': {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'},
            },
          },
        },
      };

      final tool = Tool.fromJson(json);

      expect(tool.type, 'function');
      expect(tool.function.name, 'search');
      expect(tool.function.description, 'Search the web');
    });

    test('strict mode can be enabled', () {
      final tool = Tool.function(name: 'strict_function', strict: true);

      expect(tool.function.strict, true);
      final json = tool.toJson();
      final functionJson = json['function'] as Map<String, dynamic>;
      expect(functionJson['strict'], true);
    });
  });

  group('FunctionDefinition', () {
    test('creates with minimal parameters', () {
      const definition = FunctionDefinition(name: 'my_function');

      expect(definition.name, 'my_function');
      expect(definition.description, isNull);
      expect(definition.parameters, isNull);
      expect(definition.strict, false);
    });

    test('creates with all parameters', () {
      const definition = FunctionDefinition(
        name: 'complex_function',
        description: 'A complex function',
        parameters: {'type': 'object'},
        strict: true,
      );

      expect(definition.name, 'complex_function');
      expect(definition.description, 'A complex function');
      expect(definition.parameters, {'type': 'object'});
      expect(definition.strict, true);
    });

    test('toJson excludes null values', () {
      const definition = FunctionDefinition(name: 'simple');

      final json = definition.toJson();

      expect(json['name'], 'simple');
      expect(json.containsKey('description'), false);
      expect(json.containsKey('parameters'), false);
      expect(
        json.containsKey('strict'),
        false,
      ); // false is default, not included
    });

    test('fromJson parses correctly', () {
      final json = {
        'name': 'parsed_function',
        'description': 'A parsed function',
        'strict': true,
      };

      final definition = FunctionDefinition.fromJson(json);

      expect(definition.name, 'parsed_function');
      expect(definition.description, 'A parsed function');
      expect(definition.strict, true);
    });
  });

  group('ToolChoice', () {
    test('none creates correct choice', () {
      final choice = ToolChoice.none();
      final json = choice.toJson();
      expect(json, 'none');
    });

    test('auto creates correct choice', () {
      final choice = ToolChoice.auto();
      final json = choice.toJson();
      expect(json, 'auto');
    });

    test('required creates correct choice', () {
      final choice = ToolChoice.required();
      final json = choice.toJson();
      expect(json, 'required');
    });

    test('function creates correct choice', () {
      final choice = ToolChoice.function('get_weather');
      final json = choice.toJson();

      expect(json, isA<Map<String, dynamic>>());
      final jsonMap = json as Map<String, dynamic>;
      final functionJson = jsonMap['function'] as Map<String, dynamic>;
      expect(jsonMap['type'], 'function');
      expect(functionJson['name'], 'get_weather');
    });

    test('fromJson parses string values', () {
      expect(ToolChoice.fromJson('none'), isA<ToolChoiceNone>());
      expect(ToolChoice.fromJson('auto'), isA<ToolChoiceAuto>());
      expect(ToolChoice.fromJson('required'), isA<ToolChoiceRequired>());
    });

    test('fromJson parses function choice', () {
      final json = {
        'type': 'function',
        'function': {'name': 'my_func'},
      };

      final choice = ToolChoice.fromJson(json);
      expect(choice, isA<ToolChoiceFunction>());
      expect((choice as ToolChoiceFunction).name, 'my_func');
    });

    test('fromJson parses function choice without type field', () {
      // Legacy format: maps without 'type' fall back to ToolChoiceFunction
      final json = {
        'function': {'name': 'legacy_func'},
      };

      final choice = ToolChoice.fromJson(json);
      expect(choice, isA<ToolChoiceFunction>());
      expect((choice as ToolChoiceFunction).name, 'legacy_func');
    });

    test('allowedTools factory creates correct choice', () {
      final choice = ToolChoice.allowedTools(
        mode: 'auto',
        tools: [
          {
            'type': 'function',
            'function': {'name': 'get_weather'},
          },
        ],
      );

      expect(choice, isA<ToolChoiceAllowedTools>());
      final allowed = choice as ToolChoiceAllowedTools;
      expect(allowed.mode, 'auto');
      expect(allowed.tools, hasLength(1));
    });

    test('allowedTools toJson serializes correctly', () {
      final tools = [
        {
          'type': 'function',
          'function': {'name': 'get_weather'},
        },
      ];
      final choice = ToolChoice.allowedTools(mode: 'required', tools: tools);
      final json = choice.toJson() as Map<String, dynamic>;

      expect(json['type'], 'allowed_tools');
      final allowedTools = json['allowed_tools'] as Map<String, dynamic>;
      expect(allowedTools['mode'], 'required');
      expect(allowedTools['tools'], tools);
    });

    test('fromJson parses allowed_tools choice', () {
      final json = {
        'type': 'allowed_tools',
        'allowed_tools': {
          'mode': 'auto',
          'tools': [
            {
              'type': 'function',
              'function': {'name': 'my_func'},
            },
          ],
        },
      };

      final choice = ToolChoice.fromJson(json);
      expect(choice, isA<ToolChoiceAllowedTools>());
      final allowed = choice as ToolChoiceAllowedTools;
      expect(allowed.mode, 'auto');
      expect(allowed.tools, hasLength(1));
      expect(allowed.tools[0]['type'], 'function');
    });

    test('allowedTools equality', () {
      final tools = [
        {
          'type': 'function',
          'function': {'name': 'get_weather'},
        },
      ];
      final a = ToolChoice.allowedTools(mode: 'auto', tools: tools);
      final b = ToolChoice.allowedTools(mode: 'auto', tools: tools);
      final c = ToolChoice.allowedTools(mode: 'required', tools: tools);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('allowedTools copyWith', () {
      const choice = ToolChoiceAllowedTools(
        mode: 'auto',
        tools: [
          {
            'type': 'function',
            'function': {'name': 'a'},
          },
        ],
      );
      final copied = choice.copyWith(mode: 'required');

      expect(copied.mode, 'required');
      expect(copied.tools, choice.tools);
    });

    test('custom factory creates correct choice', () {
      final choice = ToolChoice.custom('my_tool');

      expect(choice, isA<ToolChoiceCustom>());
      expect((choice as ToolChoiceCustom).name, 'my_tool');
    });

    test('custom toJson serializes correctly', () {
      final choice = ToolChoice.custom('my_tool');
      final json = choice.toJson() as Map<String, dynamic>;

      expect(json['type'], 'custom');
      final custom = json['custom'] as Map<String, dynamic>;
      expect(custom['name'], 'my_tool');
    });

    test('fromJson parses custom choice', () {
      final json = {
        'type': 'custom',
        'custom': {'name': 'my_tool'},
      };

      final choice = ToolChoice.fromJson(json);
      expect(choice, isA<ToolChoiceCustom>());
      expect((choice as ToolChoiceCustom).name, 'my_tool');
    });

    test('custom equality', () {
      final a = ToolChoice.custom('my_tool');
      final b = ToolChoice.custom('my_tool');
      final c = ToolChoice.custom('other_tool');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('custom copyWith', () {
      const choice = ToolChoiceCustom(name: 'original');
      final copied = choice.copyWith(name: 'renamed');

      expect(copied.name, 'renamed');
    });

    test('fromJson/toJson roundtrip for all variants', () {
      final choices = [
        ToolChoice.auto(),
        ToolChoice.none(),
        ToolChoice.required(),
        ToolChoice.function('get_weather'),
        ToolChoice.allowedTools(
          mode: 'auto',
          tools: [
            {
              'type': 'function',
              'function': {'name': 'get_weather'},
            },
          ],
        ),
        ToolChoice.custom('my_tool'),
      ];

      for (final choice in choices) {
        final roundtripped = ToolChoice.fromJson(choice.toJson());
        expect(roundtripped, equals(choice));
      }
    });
  });
}
