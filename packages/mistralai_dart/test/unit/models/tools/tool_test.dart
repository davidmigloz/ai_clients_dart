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

      test('serializes to JSON', () {
        const tool = WebSearchTool();
        final json = tool.toJson();

        expect(json, {'type': 'web_search'});
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'web_search'});
        expect(tool, isA<WebSearchTool>());
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

      test('serializes to JSON', () {
        const tool = WebSearchPremiumTool();
        final json = tool.toJson();

        expect(json, {'type': 'web_search_premium'});
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'web_search_premium'});
        expect(tool, isA<WebSearchPremiumTool>());
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

      test('serializes to JSON', () {
        const tool = CodeInterpreterTool();
        final json = tool.toJson();

        expect(json, {'type': 'code_interpreter'});
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'code_interpreter'});
        expect(tool, isA<CodeInterpreterTool>());
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

      test('serializes to JSON', () {
        const tool = ImageGenerationTool();
        final json = tool.toJson();

        expect(json, {'type': 'image_generation'});
      });

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {'type': 'image_generation'});
        expect(tool, isA<ImageGenerationTool>());
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

      test('deserializes from JSON', () {
        final tool = Tool.fromJson(const {
          'type': 'document_library',
          'library_ids': ['lib1'],
        });
        expect(tool, isA<DocumentLibraryTool>());
        expect((tool as DocumentLibraryTool).libraryIds, ['lib1']);
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
