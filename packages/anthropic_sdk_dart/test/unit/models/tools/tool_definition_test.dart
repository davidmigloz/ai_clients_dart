import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolDefinition', () {
    group('factory constructors', () {
      test('custom creates CustomToolDefinition', () {
        const tool = Tool(name: 'test_tool', inputSchema: InputSchema());
        final definition = ToolDefinition.custom(tool);

        expect(definition, isA<CustomToolDefinition>());
        expect((definition as CustomToolDefinition).tool, equals(tool));
      });

      test('builtIn creates BuiltInToolDefinition', () {
        const builtIn = BashTool();
        final definition = ToolDefinition.builtIn(builtIn);

        expect(definition, isA<BuiltInToolDefinition>());
        expect((definition as BuiltInToolDefinition).tool, equals(builtIn));
      });
    });

    group('fromJson', () {
      test('parses custom tool (no type field)', () {
        final json = {
          'name': 'get_weather',
          'description': 'Get the weather',
          'input_schema': {
            'type': 'object',
            'properties': {
              'location': {'type': 'string'},
            },
          },
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<CustomToolDefinition>());
        final custom = definition as CustomToolDefinition;
        expect(custom.tool.name, 'get_weather');
        expect(custom.tool.description, 'Get the weather');
      });

      test('parses custom tool (type: custom)', () {
        final json = {
          'type': 'custom',
          'name': 'calculator',
          'input_schema': {
            'type': 'object',
            'properties': {
              'expression': {'type': 'string'},
            },
          },
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<CustomToolDefinition>());
        expect((definition as CustomToolDefinition).tool.name, 'calculator');
      });

      test('parses bash built-in tool', () {
        final json = {'type': 'bash_20250124', 'name': 'bash'};

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<BashTool>());
      });

      test('parses text_editor built-in tool (2025-01-24)', () {
        final json = {
          'type': 'text_editor_20250124',
          'name': 'str_replace_editor',
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<TextEditorTool20250124>());
      });

      test('parses text_editor built-in tool (2025-04-29)', () {
        final json = {
          'type': 'text_editor_20250429',
          'name': 'str_replace_based_edit_tool',
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<TextEditorTool20250429>());
      });

      test('parses text_editor built-in tool (latest 2025-07-28)', () {
        final json = {
          'type': 'text_editor_20250728',
          'name': 'str_replace_based_edit_tool',
          'max_characters': 10000,
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<TextEditorTool>());
        expect((builtIn as TextEditorTool).maxCharacters, 10000);
      });

      test('parses web_search built-in tool', () {
        final json = {
          'type': 'web_search_20250305',
          'name': 'web_search',
          'max_uses': 5,
          'allowed_domains': ['example.com'],
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<WebSearchTool>());
        final webSearch = builtIn as WebSearchTool;
        expect(webSearch.maxUses, 5);
        expect(webSearch.allowedDomains, ['example.com']);
      });

      test('parses web_fetch built-in tool', () {
        final json = {
          'type': 'web_fetch_20260209',
          'name': 'web_fetch',
          'max_uses': 2,
          'max_content_tokens': 2048,
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<WebFetchTool>());
        final webFetch = builtIn as WebFetchTool;
        expect(webFetch.maxUses, 2);
        expect(webFetch.maxContentTokens, 2048);
      });

      test('parses memory built-in tool', () {
        final json = {'type': 'memory_20250818', 'name': 'memory'};

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<MemoryTool>());
      });

      test('parses tool search built-in tool', () {
        final json = {
          'type': 'tool_search_tool_bm25_20251119',
          'name': 'tool_search_tool_bm25',
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<ToolSearchToolBm25>());
      });

      test('parses code execution built-in tool', () {
        final json = {
          'type': 'code_execution_20260120',
          'name': 'code_execution',
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<CodeExecutionBuiltInTool>());
      });

      test('parses computer_use built-in tool', () {
        final json = {
          'type': 'computer_20250124',
          'name': 'computer',
          'display_width_px': 1920,
          'display_height_px': 1080,
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<ComputerUseTool>());
        final computer = builtIn as ComputerUseTool;
        expect(computer.displayWidthPx, 1920);
        expect(computer.displayHeightPx, 1080);
      });

      test('parses mcp built-in tool', () {
        final json = {
          'type': 'mcp_20250326',
          'server_definition': {'url': 'https://example.com/mcp'},
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<BuiltInToolDefinition>());
        final builtIn = (definition as BuiltInToolDefinition).tool;
        expect(builtIn, isA<McpToolset>());
      });

      test('throws for unknown built-in tool version', () {
        // A type that matches built-in pattern but has unknown version
        final json = {'type': 'bash_99999999', 'name': 'bash'};

        // Unknown built-in tool versions throw FormatException from BuiltInTool.fromJson
        expect(() => ToolDefinition.fromJson(json), throwsFormatException);
      });

      test('parses unknown type as custom tool', () {
        // Types that don't match any built-in pattern are treated as custom tools
        final json = <String, dynamic>{
          'type': 'some_custom_type',
          'name': 'my_tool',
          'input_schema': <String, dynamic>{
            'type': 'object',
            'properties': <String, dynamic>{},
          },
        };

        final definition = ToolDefinition.fromJson(json);

        expect(definition, isA<CustomToolDefinition>());
        expect((definition as CustomToolDefinition).tool.name, 'my_tool');
      });
    });

    group('toJson', () {
      test('serializes CustomToolDefinition', () {
        const tool = Tool(
          name: 'test_tool',
          description: 'Test description',
          inputSchema: InputSchema(
            properties: {
              'input': {'type': 'string'},
            },
          ),
        );
        final definition = ToolDefinition.custom(tool);

        final json = definition.toJson();

        expect(json['name'], 'test_tool');
        expect(json['description'], 'Test description');
        expect(json['input_schema'], isNotNull);
      });

      test('serializes BuiltInToolDefinition (BashTool)', () {
        const builtIn = BashTool();
        final definition = ToolDefinition.builtIn(builtIn);

        final json = definition.toJson();

        expect(json['type'], 'bash_20250124');
        expect(json['name'], 'bash');
      });

      test('serializes BuiltInToolDefinition (WebSearchTool)', () {
        const builtIn = WebSearchTool(maxUses: 10);
        final definition = ToolDefinition.builtIn(builtIn);

        final json = definition.toJson();

        expect(json['type'], 'web_search_20250305');
        expect(json['name'], 'web_search');
        expect(json['max_uses'], 10);
      });

      test('serializes BuiltInToolDefinition (WebFetchTool)', () {
        const builtIn = WebFetchTool(maxUses: 1, maxContentTokens: 4096);
        final definition = ToolDefinition.builtIn(builtIn);

        final json = definition.toJson();

        expect(json['type'], 'web_fetch_20260209');
        expect(json['name'], 'web_fetch');
        expect(json['max_uses'], 1);
        expect(json['max_content_tokens'], 4096);
      });
    });

    group('round-trip serialization', () {
      test('CustomToolDefinition round-trip', () {
        const tool = Tool(
          name: 'round_trip_tool',
          description: 'A tool for testing',
          inputSchema: InputSchema(
            properties: {
              'param': {'type': 'string', 'description': 'A parameter'},
            },
            required: ['param'],
          ),
        );
        final original = ToolDefinition.custom(tool);

        final json = original.toJson();
        final restored = ToolDefinition.fromJson(json);

        expect(restored, isA<CustomToolDefinition>());
        final restoredCustom = restored as CustomToolDefinition;
        expect(restoredCustom.tool.name, tool.name);
        expect(restoredCustom.tool.description, tool.description);
      });

      test('BuiltInToolDefinition (BashTool) round-trip', () {
        const builtIn = BashTool();
        final original = ToolDefinition.builtIn(builtIn);

        final json = original.toJson();
        final restored = ToolDefinition.fromJson(json);

        expect(restored, isA<BuiltInToolDefinition>());
        final restoredBuiltIn = (restored as BuiltInToolDefinition).tool;
        expect(restoredBuiltIn, isA<BashTool>());
      });

      test('BuiltInToolDefinition (WebSearchTool) round-trip', () {
        const builtIn = WebSearchTool(
          maxUses: 5,
          allowedDomains: ['example.com', 'test.org'],
        );
        final original = ToolDefinition.builtIn(builtIn);

        final json = original.toJson();
        final restored = ToolDefinition.fromJson(json);

        expect(restored, isA<BuiltInToolDefinition>());
        final restoredBuiltIn = (restored as BuiltInToolDefinition).tool;
        expect(restoredBuiltIn, isA<WebSearchTool>());
        final webSearch = restoredBuiltIn as WebSearchTool;
        expect(webSearch.maxUses, 5);
        expect(webSearch.allowedDomains, ['example.com', 'test.org']);
      });
    });
  });

  group('CustomToolDefinition', () {
    test('equality works correctly', () {
      const tool = Tool(name: 'tool', inputSchema: InputSchema());
      const def1 = CustomToolDefinition(tool);
      const def2 = CustomToolDefinition(tool);
      const differentTool = Tool(name: 'other', inputSchema: InputSchema());
      const def3 = CustomToolDefinition(differentTool);

      expect(def1, equals(def2));
      expect(def1, isNot(equals(def3)));
    });

    test('hashCode is consistent with equality', () {
      const tool = Tool(name: 'tool', inputSchema: InputSchema());
      const def1 = CustomToolDefinition(tool);
      const def2 = CustomToolDefinition(tool);

      expect(def1.hashCode, equals(def2.hashCode));
    });

    test('toString returns readable representation', () {
      const tool = Tool(name: 'my_tool', inputSchema: InputSchema());
      const definition = CustomToolDefinition(tool);

      expect(definition.toString(), contains('CustomToolDefinition'));
      expect(definition.toString(), contains('my_tool'));
    });
  });

  group('BuiltInToolDefinition', () {
    test('equality works correctly', () {
      const bash1 = BashTool();
      const bash2 = BashTool();
      const webSearch = WebSearchTool();
      const def1 = BuiltInToolDefinition(bash1);
      const def2 = BuiltInToolDefinition(bash2);
      const def3 = BuiltInToolDefinition(webSearch);

      expect(def1, equals(def2));
      expect(def1, isNot(equals(def3)));
    });

    test('hashCode is consistent with equality', () {
      const bash = BashTool();
      const def1 = BuiltInToolDefinition(bash);
      const def2 = BuiltInToolDefinition(bash);

      expect(def1.hashCode, equals(def2.hashCode));
    });

    test('toString returns readable representation', () {
      const bash = BashTool();
      const definition = BuiltInToolDefinition(bash);

      expect(definition.toString(), contains('BuiltInToolDefinition'));
    });
  });
}
