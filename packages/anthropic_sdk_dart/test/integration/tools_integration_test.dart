// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  AnthropicClient? client;

  setUpAll(() {
    apiKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Tools API - Integration', () {
    test(
      'invokes a tool and handles tool result',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Define a simple calculator tool
        const calculatorTool = Tool(
          name: 'calculator',
          description: 'A simple calculator that adds two numbers',
          inputSchema: InputSchema(
            properties: {
              'a': {'type': 'number', 'description': 'First number'},
              'b': {'type': 'number', 'description': 'Second number'},
            },
            required: ['a', 'b'],
          ),
        );

        // Send a message that should trigger tool use
        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            tools: [calculatorTool.toJson()],
            messages: [
              InputMessage.user('What is 15 + 27? Use the calculator tool.'),
            ],
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.stopReason, StopReason.toolUse);

        // Should have a tool use block
        final toolUseBlocks = response.toolUseBlocks;
        expect(toolUseBlocks, isNotEmpty);

        final toolUse = toolUseBlocks.first;
        expect(toolUse.name, 'calculator');
        expect(toolUse.input, isNotNull);

        // Verify input has the expected numbers
        final input = toolUse.input;
        expect(input.containsKey('a'), isTrue);
        expect(input.containsKey('b'), isTrue);
      },
    );

    test(
      'multi-turn tool conversation',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        const weatherTool = Tool(
          name: 'get_weather',
          description: 'Get the current weather for a location',
          inputSchema: InputSchema(
            properties: {
              'location': {'type': 'string', 'description': 'City name'},
            },
            required: ['location'],
          ),
        );

        // First turn - ask about weather
        final response1 = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            tools: [weatherTool.toJson()],
            messages: [InputMessage.user('What is the weather in Paris?')],
          ),
        );

        expect(response1.stopReason, StopReason.toolUse);
        final toolUse = response1.toolUseBlocks.first;
        expect(toolUse.name, 'get_weather');

        // Convert ContentBlocks to InputContentBlocks via JSON roundtrip
        final assistantBlocks = response1.content
            .map((block) => InputContentBlock.fromJson(block.toJson()))
            .toList();

        // Second turn - provide tool result
        final response2 = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            tools: [weatherTool.toJson()],
            messages: [
              InputMessage.user('What is the weather in Paris?'),
              InputMessage.assistantBlocks(assistantBlocks),
              InputMessage.userBlocks([
                InputContentBlock.toolResult(
                  toolUseId: toolUse.id,
                  content: [ToolResultContent.text('Sunny, 22°C')],
                ),
              ]),
            ],
          ),
        );

        expect(response2.stopReason, StopReason.endTurn);
        expect(response2.text.toLowerCase(), contains('paris'));
        // Should mention the weather we provided
        expect(
          response2.text.toLowerCase(),
          anyOf(contains('sunny'), contains('22')),
        );
      },
    );

    test(
      'tool choice auto',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        const tool = Tool(
          name: 'get_time',
          description: 'Get the current time',
          inputSchema: InputSchema(),
        );

        // With auto, model decides whether to use tools
        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            tools: [tool.toJson()],
            toolChoice: const ToolChoiceAuto().toJson(),
            messages: [InputMessage.user('Hello, how are you?')],
          ),
        );

        // Model should respond without using the tool for a greeting
        expect(response.stopReason, StopReason.endTurn);
        expect(response.text, isNotEmpty);
      },
    );

    test(
      'tool choice forces specific tool',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        const tool = Tool(
          name: 'random_number',
          description: 'Generate a random number',
          inputSchema: InputSchema(
            properties: {
              'min': {'type': 'integer'},
              'max': {'type': 'integer'},
            },
          ),
        );

        // Force use of specific tool
        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            tools: [tool.toJson()],
            toolChoice: const ToolChoiceTool('random_number').toJson(),
            messages: [
              InputMessage.user('Give me a number between 1 and 100.'),
            ],
          ),
        );

        expect(response.stopReason, StopReason.toolUse);
        expect(response.toolUseBlocks, isNotEmpty);
        expect(response.toolUseBlocks.first.name, 'random_number');
      },
    );

    test(
      'streaming with tool use',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        const tool = Tool(
          name: 'search',
          description: 'Search for information',
          inputSchema: InputSchema(
            properties: {
              'query': {'type': 'string'},
            },
            required: ['query'],
          ),
        );

        final stream = client!.messages.createStream(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            tools: [tool.toJson()],
            messages: [
              InputMessage.user('Search for information about Dart language.'),
            ],
          ),
        );

        var hasToolUseStart = false;
        var hasInputJsonDelta = false;
        var toolName = '';

        await for (final event in stream) {
          switch (event) {
            case ContentBlockStartEvent(:final contentBlock):
              if (contentBlock is ToolUseBlock) {
                hasToolUseStart = true;
                toolName = contentBlock.name;
              }
            case ContentBlockDeltaEvent(:final delta):
              if (delta is InputJsonDelta) {
                hasInputJsonDelta = true;
              }
            default:
              break;
          }
        }

        expect(hasToolUseStart, isTrue);
        expect(toolName, 'search');
        expect(hasInputJsonDelta, isTrue);
      },
    );
  });
}
