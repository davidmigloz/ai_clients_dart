import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

/// Helper to convert nested maps to proper `Map<String, dynamic>`.
Map<String, dynamic> jsonDecode_(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('ChatStreamEvent', () {
    test('fromJson parses event correctly', () {
      final json = jsonDecode_('''
        {
          "id": "chatcmpl-123",
          "object": "chat.completion.chunk",
          "created": 1677652288,
          "model": "gpt-4o",
          "choices": [
            {
              "index": 0,
              "delta": {
                "role": "assistant",
                "content": "Hello"
              },
              "finish_reason": null
            }
          ]
        }
      ''');

      final event = ChatStreamEvent.fromJson(json);

      expect(event.id, 'chatcmpl-123');
      expect(event.object, 'chat.completion.chunk');
      expect(event.model, 'gpt-4o');
      expect(event.choices!.length, 1);
    });

    test('textDelta returns first choice content', () {
      final json = jsonDecode_('''
        {
          "id": "chatcmpl-123",
          "object": "chat.completion.chunk",
          "created": 1677652288,
          "model": "gpt-4o",
          "choices": [
            {
              "index": 0,
              "delta": {
                "content": "World"
              },
              "finish_reason": null
            }
          ]
        }
      ''');

      final event = ChatStreamEvent.fromJson(json);
      expect(event.textDelta, 'World');
    });

    test('handles finish reason', () {
      final json = jsonDecode_('''
        {
          "id": "chatcmpl-123",
          "object": "chat.completion.chunk",
          "created": 1677652288,
          "model": "gpt-4o",
          "choices": [
            {
              "index": 0,
              "delta": {},
              "finish_reason": "stop"
            }
          ]
        }
      ''');

      final event = ChatStreamEvent.fromJson(json);
      expect(event.choices!.first.finishReason, FinishReason.stop);
      expect(event.choices!.first.isFinal, true);
    });

    test('handles usage in final event', () {
      final json = jsonDecode_('''
        {
          "id": "chatcmpl-123",
          "object": "chat.completion.chunk",
          "created": 1677652288,
          "model": "gpt-4o",
          "choices": [],
          "usage": {
            "prompt_tokens": 10,
            "completion_tokens": 20,
            "total_tokens": 30
          }
        }
      ''');

      final event = ChatStreamEvent.fromJson(json);
      expect(event.usage, isNotNull);
      expect(event.usage!.promptTokens, 10);
      expect(event.usage!.completionTokens, 20);
    });
  });

  group('ChatDelta', () {
    test('parses content delta', () {
      final json = <String, dynamic>{'content': 'Hello'};

      final delta = ChatDelta.fromJson(json);

      expect(delta.content, 'Hello');
      expect(delta.hasContent, true);
    });

    test('parses role delta', () {
      final json = <String, dynamic>{'role': 'assistant'};

      final delta = ChatDelta.fromJson(json);

      expect(delta.role, 'assistant');
    });

    test('parses tool call delta', () {
      final json = jsonDecode_(r'''
        {
          "tool_calls": [
            {
              "index": 0,
              "id": "call_abc123",
              "type": "function",
              "function": {
                "name": "get_weather",
                "arguments": "{\"loc"
              }
            }
          ]
        }
      ''');

      final delta = ChatDelta.fromJson(json);

      expect(delta.hasToolCalls, true);
      expect(delta.toolCalls!.first.id, 'call_abc123');
      expect(delta.toolCalls!.first.function!.name, 'get_weather');
    });
  });

  group('ChatStreamAccumulator', () {
    test('accumulates text content', () {
      final accumulator = ChatStreamAccumulator()
        // First chunk
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {"role": "assistant", "content": "Hello"},
                "finish_reason": null
              }
            ]
          }
        '''),
          ),
        )
        // Second chunk
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {"content": " World"},
                "finish_reason": null
              }
            ]
          }
        '''),
          ),
        )
        // Final chunk
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {},
                "finish_reason": "stop"
              }
            ]
          }
        '''),
          ),
        );

      expect(accumulator.content, 'Hello World');
      expect(accumulator.role, 'assistant');
      expect(accumulator.finishReason, FinishReason.stop);
      expect(accumulator.id, 'chatcmpl-123');
      expect(accumulator.model, 'gpt-4o');
    });

    test('accumulates tool calls', () {
      final accumulator = ChatStreamAccumulator()
        // First chunk with tool call start
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_(r'''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {
                  "role": "assistant",
                  "tool_calls": [
                    {
                      "index": 0,
                      "id": "call_abc",
                      "type": "function",
                      "function": {"name": "get_weather", "arguments": "{\""}
                    }
                  ]
                },
                "finish_reason": null
              }
            ]
          }
        '''),
          ),
        )
        // Second chunk with more arguments
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_(r'''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {
                  "tool_calls": [
                    {
                      "index": 0,
                      "function": {"arguments": "location\":\"Boston\"}"}
                    }
                  ]
                },
                "finish_reason": null
              }
            ]
          }
        '''),
          ),
        );

      expect(accumulator.hasToolCalls, true);
      expect(accumulator.toolCalls.length, 1);
      expect(accumulator.toolCalls.first.id, 'call_abc');
      expect(accumulator.toolCalls.first.function.name, 'get_weather');
      expect(
        accumulator.toolCalls.first.function.arguments,
        '{"location":"Boston"}',
      );
    });

    test('reset clears accumulated data', () {
      final accumulator = ChatStreamAccumulator()
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {"content": "Hello"},
                "finish_reason": null
              }
            ]
          }
        '''),
          ),
        )
        ..reset();

      expect(accumulator.content, '');
      expect(accumulator.id, isNull);
      expect(accumulator.model, isNull);
    });
  });

  group('ToolCallDelta', () {
    test('fromJson parses correctly', () {
      final json = jsonDecode_('''
        {
          "index": 0,
          "id": "call_123",
          "type": "function",
          "function": {
            "name": "my_func",
            "arguments": "{}"
          }
        }
      ''');

      final delta = ToolCallDelta.fromJson(json);

      expect(delta.index, 0);
      expect(delta.id, 'call_123');
      expect(delta.type, 'function');
      expect(delta.function!.name, 'my_func');
      expect(delta.function!.arguments, '{}');
    });
  });

  // OpenAI-Compatible APIs Tests
  group('OpenAI-Compatible APIs', () {
    group('ChatStreamEvent nullable fields', () {
      test('handles missing id (OpenRouter)', () {
        final json = jsonDecode_('''
          {
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {"content": "Hello"},
                "finish_reason": null
              }
            ]
          }
        ''');

        final event = ChatStreamEvent.fromJson(json);

        expect(event.id, isNull);
        expect(event.model, 'gpt-4o');
      });

      test('handles missing object (FastChat)', () {
        final json = jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "created": 1677652288,
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {"content": "Hello"},
                "finish_reason": null
              }
            ]
          }
        ''');

        final event = ChatStreamEvent.fromJson(json);

        expect(event.object, isNull);
      });

      test('handles missing created (FastChat)', () {
        final json = jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {"content": "Hello"},
                "finish_reason": null
              }
            ]
          }
        ''');

        final event = ChatStreamEvent.fromJson(json);

        expect(event.created, isNull);
      });

      test('handles missing model (TogetherAI)', () {
        final json = jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "choices": [
              {
                "index": 0,
                "delta": {"content": "Hello"},
                "finish_reason": null
              }
            ]
          }
        ''');

        final event = ChatStreamEvent.fromJson(json);

        expect(event.model, isNull);
      });

      test('handles missing choices (Groq)', () {
        final json = jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "mixtral-8x7b"
          }
        ''');

        final event = ChatStreamEvent.fromJson(json);

        expect(event.choices, isNull);
        expect(event.textDelta, isNull);
        expect(event.firstChoice, isNull);
      });

      test('handles provider field (OpenRouter)', () {
        final json = jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "provider": "OpenAI",
            "choices": [
              {
                "index": 0,
                "delta": {"content": "Hello"},
                "finish_reason": null
              }
            ]
          }
        ''');

        final event = ChatStreamEvent.fromJson(json);

        expect(event.provider, 'OpenAI');
      });
    });

    group('ChatStreamChoice nullable index', () {
      test('handles missing index (OpenRouter)', () {
        final json = jsonDecode_('''
          {
            "delta": {"content": "Hello"},
            "finish_reason": null
          }
        ''');

        final choice = ChatStreamChoice.fromJson(json);

        expect(choice.index, isNull);
        expect(choice.delta.content, 'Hello');
      });
    });

    group('ChatDelta reasoning fields', () {
      test('parses reasoning_content (DeepSeek R1)', () {
        final json = <String, dynamic>{
          'content': 'The answer is 42.',
          'reasoning_content': 'Let me think...',
        };

        final delta = ChatDelta.fromJson(json);

        expect(delta.content, 'The answer is 42.');
        expect(delta.reasoningContent, 'Let me think...');
        expect(delta.hasReasoningContent, true);
      });

      test('parses reasoning (OpenRouter)', () {
        final json = <String, dynamic>{
          'content': 'The answer is 42.',
          'reasoning': 'Quick thinking...',
        };

        final delta = ChatDelta.fromJson(json);

        expect(delta.reasoning, 'Quick thinking...');
        expect(delta.hasReasoningContent, true);
      });

      test('parses reasoning_details (OpenRouter)', () {
        final json = jsonDecode_('''
          {
            "content": "Hello",
            "reasoning_details": [
              {
                "type": "reasoning.summary",
                "text": "Summary of reasoning"
              }
            ]
          }
        ''');

        final delta = ChatDelta.fromJson(json);

        expect(delta.reasoningDetails, isNotNull);
        expect(delta.reasoningDetails!.length, 1);
        expect(delta.reasoningDetails!.first.type, 'reasoning.summary');
      });
    });

    group('ChatStreamAccumulator reasoning', () {
      test('accumulates reasoning content', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-123",
                "object": "chat.completion.chunk",
                "created": 1677652288,
                "model": "deepseek-r1",
                "choices": [
                  {
                    "index": 0,
                    "delta": {
                      "role": "assistant",
                      "reasoning_content": "Let me "
                    },
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          )
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-123",
                "object": "chat.completion.chunk",
                "created": 1677652288,
                "model": "deepseek-r1",
                "choices": [
                  {
                    "index": 0,
                    "delta": {
                      "reasoning_content": "think..."
                    },
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          );

        expect(accumulator.reasoningContent, 'Let me think...');
        expect(accumulator.hasReasoningContent, true);
      });

      test('reset clears reasoning buffers', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-123",
                "object": "chat.completion.chunk",
                "created": 1677652288,
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {
                      "reasoning_content": "Some reasoning"
                    },
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          )
          ..reset();

        expect(accumulator.reasoningContent, '');
        expect(accumulator.reasoning, '');
        expect(accumulator.hasReasoningContent, false);
      });
    });
  });
}
