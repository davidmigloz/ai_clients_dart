import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Tool', () {
    group('FunctionTool', () {
      test('creates function tool with factory constructor', () {
        final tool = Tool.function(
          name: 'get_weather',
          description: 'Get weather data',
          parameters: const {
            'type': 'object',
            'properties': {
              'location': {'type': 'string'},
            },
          },
        );

        expect(tool, isA<FunctionTool>());
        final functionTool = tool as FunctionTool;
        expect(functionTool.function.name, 'get_weather');
        expect(functionTool.function.description, 'Get weather data');
        expect(functionTool.function.parameters, isNotNull);
      });

      test('serializes to JSON', () {
        final tool = Tool.function(
          name: 'test_func',
          description: 'A test function',
        );
        final json = tool.toJson();

        expect(json['type'], 'function');
        expect(json['function'], isA<Map<String, dynamic>>());
        expect((json['function'] as Map)['name'], 'test_func');
        expect((json['function'] as Map)['description'], 'A test function');
      });

      test('deserializes from JSON', () {
        final json = {
          'type': 'function',
          'function': {
            'name': 'my_func',
            'description': 'Does something',
            'parameters': {
              'type': 'object',
              'properties': {
                'x': {'type': 'number'},
              },
            },
          },
        };
        final tool = Tool.fromJson(json);

        expect(tool, isA<FunctionTool>());
        final functionTool = tool as FunctionTool;
        expect(functionTool.function.name, 'my_func');
        expect(functionTool.function.description, 'Does something');
      });

      test('equality works correctly', () {
        const tool1 = FunctionTool(
          function: FunctionDefinition(name: 'test', description: 'desc'),
        );
        const tool2 = FunctionTool(
          function: FunctionDefinition(name: 'test', description: 'desc'),
        );
        const tool3 = FunctionTool(
          function: FunctionDefinition(name: 'other', description: 'desc'),
        );

        expect(tool1, equals(tool2));
        expect(tool1.hashCode, equals(tool2.hashCode));
        expect(tool1, isNot(equals(tool3)));
      });

      test('copyWith creates a copy with new function', () {
        const original = FunctionTool(
          function: FunctionDefinition(name: 'old_func', description: 'old'),
        );
        const newDef = FunctionDefinition(name: 'new_func', description: 'new');
        final copied = original.copyWith(function: newDef);

        expect(copied.function.name, 'new_func');
        expect(copied.function.description, 'new');
      });

      test('copyWith preserves function when not specified', () {
        const original = FunctionTool(
          function: FunctionDefinition(name: 'my_func', description: 'desc'),
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
        expect(copied.function.name, 'my_func');
      });
    });

    group('WebSearchTool', () {
      test('creates with const factory', () {
        const tool = WebSearchTool();
        expect(tool, isA<Tool>());
      });

      test('creates with named constructor', () {
        const tool = Tool.webSearch();
        expect(tool, isA<WebSearchTool>());
      });

      test('creates with toolConfiguration', () {
        const tool = WebSearchTool(
          toolConfiguration: ToolConfiguration(
            include: ['func1'],
            requiresConfirmation: ['func2'],
          ),
        );
        expect(tool.toolConfiguration, isNotNull);
        expect(tool.toolConfiguration!.include, ['func1']);
        expect(tool.toolConfiguration!.requiresConfirmation, ['func2']);
      });

      test('serializes to JSON', () {
        const tool = WebSearchTool();
        final json = tool.toJson();

        expect(json, {'type': 'web_search'});
      });

      test('serializes to JSON with toolConfiguration', () {
        const tool = WebSearchTool(
          toolConfiguration: ToolConfiguration(
            include: ['func1'],
            requiresConfirmation: ['func2'],
          ),
        );
        final json = tool.toJson();

        expect(json['type'], 'web_search');
        expect(json['tool_configuration'], isA<Map<String, dynamic>>());
        expect((json['tool_configuration'] as Map)['include'], ['func1']);
        expect((json['tool_configuration'] as Map)['requires_confirmation'], [
          'func2',
        ]);
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'web_search'});
        expect(tool, isA<WebSearchTool>());
      });

      test('deserializes from JSON with toolConfiguration', () {
        final tool = Tool.fromJson(const {
          'type': 'web_search',
          'tool_configuration': {
            'include': ['func1'],
            'requires_confirmation': ['func2'],
          },
        });
        expect(tool, isA<WebSearchTool>());
        final webSearchTool = tool as WebSearchTool;
        expect(webSearchTool.toolConfiguration, isNotNull);
        expect(webSearchTool.toolConfiguration!.include, ['func1']);
        expect(webSearchTool.toolConfiguration!.requiresConfirmation, [
          'func2',
        ]);
      });

      test('equality works correctly', () {
        const tool1 = WebSearchTool();
        const tool2 = WebSearchTool();

        expect(tool1, equals(tool2));
        expect(tool1.hashCode, equals(tool2.hashCode));
      });
    });

    group('WebSearchPremiumTool', () {
      test('creates with const factory', () {
        const tool = WebSearchPremiumTool();
        expect(tool, isA<Tool>());
      });

      test('creates with named constructor', () {
        const tool = Tool.webSearchPremium();
        expect(tool, isA<WebSearchPremiumTool>());
      });

      test('creates with toolConfiguration', () {
        const tool = WebSearchPremiumTool(
          toolConfiguration: ToolConfiguration(include: ['search']),
        );
        expect(tool.toolConfiguration, isNotNull);
        expect(tool.toolConfiguration!.include, ['search']);
      });

      test('serializes to JSON', () {
        const tool = WebSearchPremiumTool();
        final json = tool.toJson();

        expect(json, {'type': 'web_search_premium'});
      });

      test('serializes to JSON with toolConfiguration', () {
        const tool = WebSearchPremiumTool(
          toolConfiguration: ToolConfiguration(exclude: ['private_search']),
        );
        final json = tool.toJson();

        expect(json['type'], 'web_search_premium');
        expect(json['tool_configuration'], isA<Map<String, dynamic>>());
        expect((json['tool_configuration'] as Map)['exclude'], [
          'private_search',
        ]);
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'web_search_premium'});
        expect(tool, isA<WebSearchPremiumTool>());
      });

      test('deserializes from JSON with toolConfiguration', () {
        final tool = Tool.fromJson(const {
          'type': 'web_search_premium',
          'tool_configuration': {
            'exclude': ['private_search'],
          },
        });
        expect(tool, isA<WebSearchPremiumTool>());
        final premiumTool = tool as WebSearchPremiumTool;
        expect(premiumTool.toolConfiguration, isNotNull);
        expect(premiumTool.toolConfiguration!.exclude, ['private_search']);
      });
    });

    group('CodeInterpreterTool', () {
      test('creates with const factory', () {
        const tool = CodeInterpreterTool();
        expect(tool, isA<Tool>());
      });

      test('creates with named constructor', () {
        const tool = Tool.codeInterpreter();
        expect(tool, isA<CodeInterpreterTool>());
      });

      test('creates with toolConfiguration', () {
        const tool = CodeInterpreterTool(
          toolConfiguration: ToolConfiguration(
            requiresConfirmation: ['execute'],
          ),
        );
        expect(tool.toolConfiguration, isNotNull);
        expect(tool.toolConfiguration!.requiresConfirmation, ['execute']);
      });

      test('serializes to JSON', () {
        const tool = CodeInterpreterTool();
        final json = tool.toJson();

        expect(json, {'type': 'code_interpreter'});
      });

      test('serializes to JSON with toolConfiguration', () {
        const tool = CodeInterpreterTool(
          toolConfiguration: ToolConfiguration(
            requiresConfirmation: ['execute'],
          ),
        );
        final json = tool.toJson();

        expect(json['type'], 'code_interpreter');
        expect(json['tool_configuration'], isA<Map<String, dynamic>>());
        expect((json['tool_configuration'] as Map)['requires_confirmation'], [
          'execute',
        ]);
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'code_interpreter'});
        expect(tool, isA<CodeInterpreterTool>());
      });

      test('deserializes from JSON with toolConfiguration', () {
        final tool = Tool.fromJson(const {
          'type': 'code_interpreter',
          'tool_configuration': {
            'requires_confirmation': ['execute'],
          },
        });
        expect(tool, isA<CodeInterpreterTool>());
        final codeInterpreter = tool as CodeInterpreterTool;
        expect(codeInterpreter.toolConfiguration, isNotNull);
        expect(codeInterpreter.toolConfiguration!.requiresConfirmation, [
          'execute',
        ]);
      });
    });

    group('ImageGenerationTool', () {
      test('creates with const factory', () {
        const tool = ImageGenerationTool();
        expect(tool, isA<Tool>());
      });

      test('creates with named constructor', () {
        const tool = Tool.imageGeneration();
        expect(tool, isA<ImageGenerationTool>());
      });

      test('creates with toolConfiguration', () {
        const tool = ImageGenerationTool(
          toolConfiguration: ToolConfiguration(include: ['generate']),
        );
        expect(tool.toolConfiguration, isNotNull);
        expect(tool.toolConfiguration!.include, ['generate']);
      });

      test('serializes to JSON', () {
        const tool = ImageGenerationTool();
        final json = tool.toJson();

        expect(json, {'type': 'image_generation'});
      });

      test('serializes to JSON with toolConfiguration', () {
        const tool = ImageGenerationTool(
          toolConfiguration: ToolConfiguration(include: ['generate']),
        );
        final json = tool.toJson();

        expect(json['type'], 'image_generation');
        expect(json['tool_configuration'], isA<Map<String, dynamic>>());
        expect((json['tool_configuration'] as Map)['include'], ['generate']);
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'image_generation'});
        expect(tool, isA<ImageGenerationTool>());
      });

      test('deserializes from JSON with toolConfiguration', () {
        final tool = Tool.fromJson(const {
          'type': 'image_generation',
          'tool_configuration': {
            'include': ['generate'],
          },
        });
        expect(tool, isA<ImageGenerationTool>());
        final imageGenTool = tool as ImageGenerationTool;
        expect(imageGenTool.toolConfiguration, isNotNull);
        expect(imageGenTool.toolConfiguration!.include, ['generate']);
      });
    });

    group('DocumentLibraryTool', () {
      test('creates without library IDs', () {
        const tool = DocumentLibraryTool();
        expect(tool.libraryIds, isNull);
      });

      test('creates with library IDs', () {
        const tool = DocumentLibraryTool(libraryIds: ['lib1', 'lib2']);
        expect(tool.libraryIds, ['lib1', 'lib2']);
      });

      test('creates with named constructor', () {
        const tool = Tool.documentLibrary(libraryIds: ['lib1']);
        expect(tool, isA<DocumentLibraryTool>());
        expect((tool as DocumentLibraryTool).libraryIds, ['lib1']);
      });

      test('serializes to JSON without library IDs', () {
        const tool = DocumentLibraryTool();
        final json = tool.toJson();

        expect(json, {'type': 'document_library'});
      });

      test('serializes to JSON with library IDs', () {
        const tool = DocumentLibraryTool(libraryIds: ['lib1', 'lib2']);
        final json = tool.toJson();

        expect(json, {
          'type': 'document_library',
          'library_ids': ['lib1', 'lib2'],
        });
      });

      test('creates with toolConfiguration', () {
        const tool = DocumentLibraryTool(
          libraryIds: ['lib1'],
          toolConfiguration: ToolConfiguration(
            include: ['search'],
            requiresConfirmation: ['delete'],
          ),
        );
        expect(tool.toolConfiguration, isNotNull);
        expect(tool.toolConfiguration!.include, ['search']);
        expect(tool.toolConfiguration!.requiresConfirmation, ['delete']);
      });

      test('serializes to JSON with toolConfiguration', () {
        const tool = DocumentLibraryTool(
          libraryIds: ['lib1'],
          toolConfiguration: ToolConfiguration(include: ['search']),
        );
        final json = tool.toJson();

        expect(json['type'], 'document_library');
        expect(json['library_ids'], ['lib1']);
        expect(json['tool_configuration'], isA<Map<String, dynamic>>());
        expect((json['tool_configuration'] as Map)['include'], ['search']);
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {
          'type': 'document_library',
          'library_ids': ['lib1'],
        });
        expect(tool, isA<DocumentLibraryTool>());
        expect((tool as DocumentLibraryTool).libraryIds, ['lib1']);
      });

      test('deserializes from JSON with toolConfiguration', () {
        final tool = Tool.fromJson(const {
          'type': 'document_library',
          'library_ids': ['lib1'],
          'tool_configuration': {
            'include': ['search'],
            'requires_confirmation': ['delete'],
          },
        });
        expect(tool, isA<DocumentLibraryTool>());
        final docLibTool = tool as DocumentLibraryTool;
        expect(docLibTool.libraryIds, ['lib1']);
        expect(docLibTool.toolConfiguration, isNotNull);
        expect(docLibTool.toolConfiguration!.include, ['search']);
        expect(docLibTool.toolConfiguration!.requiresConfirmation, ['delete']);
      });

      test('equality works correctly', () {
        const tool1 = DocumentLibraryTool(libraryIds: ['a', 'b']);
        const tool2 = DocumentLibraryTool(libraryIds: ['a', 'b']);
        const tool3 = DocumentLibraryTool(libraryIds: ['a']);

        expect(tool1, equals(tool2));
        expect(tool1.hashCode, equals(tool2.hashCode));
        expect(tool1, isNot(equals(tool3)));
      });
    });

    group('CustomConnectorTool', () {
      test('creates with required fields', () {
        const tool = CustomConnectorTool(connectorId: 'my-connector');
        expect(tool.connectorId, 'my-connector');
        expect(tool.authorization, isNull);
        expect(tool.toolConfiguration, isNull);
      });

      test('creates with named constructor', () {
        const tool = Tool.connector(connectorId: 'my-connector');
        expect(tool, isA<CustomConnectorTool>());
        expect((tool as CustomConnectorTool).connectorId, 'my-connector');
      });

      test('creates with all fields', () {
        const tool = CustomConnectorTool(
          connectorId: 'my-connector',
          authorization: ApiKeyAuth(value: 'secret'),
          toolConfiguration: ToolConfiguration(include: ['func1']),
        );
        expect(tool.connectorId, 'my-connector');
        expect(tool.authorization, isA<ApiKeyAuth>());
        expect(tool.toolConfiguration?.include, ['func1']);
      });

      test('serializes to JSON', () {
        const tool = CustomConnectorTool(connectorId: 'my-connector');
        final json = tool.toJson();

        expect(json['type'], 'connector');
        expect(json['connector_id'], 'my-connector');
        expect(json.containsKey('authorization'), isFalse);
        expect(json.containsKey('tool_configuration'), isFalse);
      });

      test('serializes to JSON with all fields', () {
        const tool = CustomConnectorTool(
          connectorId: 'my-connector',
          authorization: ApiKeyAuth(value: 'key'),
          toolConfiguration: ToolConfiguration(include: ['func1']),
        );
        final json = tool.toJson();

        expect(json['type'], 'connector');
        expect(json['connector_id'], 'my-connector');
        expect(json['authorization'], isA<Map<String, dynamic>>());
        expect((json['authorization'] as Map)['type'], 'api-key');
        expect((json['authorization'] as Map)['value'], 'key');
        expect(json['tool_configuration'], isA<Map<String, dynamic>>());
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {
          'type': 'connector',
          'connector_id': 'my-connector',
        });
        expect(tool, isA<CustomConnectorTool>());
        expect((tool as CustomConnectorTool).connectorId, 'my-connector');
      });

      test('deserializes from JSON with all fields', () {
        final tool = Tool.fromJson(const {
          'type': 'connector',
          'connector_id': 'my-connector',
          'authorization': {'type': 'oauth2-token', 'value': 'token'},
          'tool_configuration': {
            'include': ['func1'],
          },
        });
        expect(tool, isA<CustomConnectorTool>());
        final connectorTool = tool as CustomConnectorTool;
        expect(connectorTool.connectorId, 'my-connector');
        expect(connectorTool.authorization, isA<OAuth2TokenAuth>());
        expect(
          (connectorTool.authorization! as OAuth2TokenAuth).value,
          'token',
        );
        expect(connectorTool.toolConfiguration?.include, ['func1']);
      });

      test('equality works correctly', () {
        const tool1 = CustomConnectorTool(connectorId: 'a');
        const tool2 = CustomConnectorTool(connectorId: 'a');
        const tool3 = CustomConnectorTool(connectorId: 'b');

        expect(tool1, equals(tool2));
        expect(tool1.hashCode, equals(tool2.hashCode));
        expect(tool1, isNot(equals(tool3)));
      });

      test('round-trip serialization', () {
        const original = CustomConnectorTool(
          connectorId: 'my-connector',
          authorization: ApiKeyAuth(value: 'key'),
          toolConfiguration: ToolConfiguration(include: ['func1']),
        );
        final json = original.toJson();
        final restored = Tool.fromJson(json) as CustomConnectorTool;
        expect(restored, equals(original));
      });
    });

    group('fromJson defaults', () {
      test('defaults to function type for unknown or missing type', () {
        final tool = Tool.fromJson(const {
          'function': {'name': 'test'},
        });
        expect(tool, isA<FunctionTool>());
      });
    });
  });
}
