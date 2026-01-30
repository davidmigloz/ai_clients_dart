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
  });
}
