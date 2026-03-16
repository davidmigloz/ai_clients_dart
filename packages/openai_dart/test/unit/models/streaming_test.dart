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
      expect(accumulator.serviceTier, isNull);
      expect(accumulator.provider, isNull);
    });

    test('toChatCompletion() builds ChatCompletion from accumulated text', () {
      final accumulator = ChatStreamAccumulator()
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1677652288,
            "model": "gpt-4o",
            "system_fingerprint": "fp_abc",
            "service_tier": "default",
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
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-123",
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
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-123",
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {},
                "finish_reason": "stop"
              }
            ],
            "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15}
          }
        '''),
          ),
        );

      final completion = accumulator.toChatCompletion();

      expect(completion.id, equals('chatcmpl-123'));
      expect(completion.object, equals('chat.completion'));
      expect(completion.created, equals(1677652288));
      expect(completion.model, equals('gpt-4o'));
      expect(completion.systemFingerprint, equals('fp_abc'));
      expect(completion.serviceTier, equals('default'));
      expect(completion.usage?.totalTokens, equals(15));
      expect(completion.choices, hasLength(1));
      expect(completion.choices.first.index, equals(0));
      expect(completion.choices.first.finishReason, equals(FinishReason.stop));
      expect(completion.choices.first.message.content, equals('Hello World'));
      expect(completion.choices.first.message.toolCalls, isNull);
      expect(completion.text, equals('Hello World'));
    });

    test('toChatCompletion() builds ChatCompletion with tool calls', () {
      final accumulator = ChatStreamAccumulator()
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_(r'''
          {
            "id": "chatcmpl-456",
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
                      "function": {"name": "get_weather", "arguments": "{\"location"}
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
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_(r'''
          {
            "id": "chatcmpl-456",
            "model": "gpt-4o",
            "choices": [
              {
                "index": 0,
                "delta": {
                  "tool_calls": [
                    {
                      "index": 0,
                      "function": {"arguments": "\":\"Boston\"}"}
                    }
                  ]
                },
                "finish_reason": "tool_calls"
              }
            ]
          }
        '''),
          ),
        );

      final completion = accumulator.toChatCompletion();

      expect(completion.choices.first.message.content, isNull);
      expect(completion.choices.first.message.toolCalls, hasLength(1));
      expect(
        completion.choices.first.message.toolCalls!.first.function.name,
        equals('get_weather'),
      );
      expect(
        completion.choices.first.message.toolCalls!.first.function.arguments,
        equals('{"location":"Boston"}'),
      );
      expect(
        completion.choices.first.finishReason,
        equals(FinishReason.toolCalls),
      );
    });

    test('toChatCompletion() returns empty model when model is missing', () {
      final accumulator = ChatStreamAccumulator();
      final completion = accumulator.toChatCompletion();

      expect(completion.model, '');
      expect(completion.choices.length, 1);
    });

    test('toChatCompletion() captures serviceTier and provider', () {
      final accumulator = ChatStreamAccumulator()
        ..add(
          ChatStreamEvent.fromJson(
            jsonDecode_('''
          {
            "id": "chatcmpl-789",
            "model": "gpt-4o",
            "service_tier": "scale",
            "provider": "openai",
            "choices": [
              {
                "index": 0,
                "delta": {"role": "assistant", "content": "Hi"},
                "finish_reason": "stop"
              }
            ]
          }
        '''),
          ),
        );

      expect(accumulator.serviceTier, equals('scale'));
      expect(accumulator.provider, equals('openai'));

      final completion = accumulator.toChatCompletion();
      expect(completion.serviceTier, equals('scale'));
      expect(completion.provider, equals('openai'));
    });

    group('multi-choice accumulation', () {
      test('interleaved multi-choice accumulation', () {
        final accumulator = ChatStreamAccumulator()
          // Choice 0 content
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
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
          // Choice 1 content
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"role": "assistant", "content": "Bonjour"},
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          )
          // More choice 0 content
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
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
          // More choice 1 content
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"content": " le monde"},
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          );

        final choices = accumulator.choices;
        expect(choices, hasLength(2));
        expect(choices[0].content, equals('Hello World'));
        expect(choices[1].content, equals('Bonjour le monde'));
      });

      test('backward-compat getters return choice 0 data', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"role": "assistant", "content": "Choice zero"},
                    "finish_reason": "stop"
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
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"role": "assistant", "content": "Choice one"},
                    "finish_reason": "length"
                  }
                ]
              }
            '''),
            ),
          );

        // Flat getters should return choice 0's data
        expect(accumulator.content, equals('Choice zero'));
        expect(accumulator.finishReason, equals(FinishReason.stop));
        expect(accumulator.role, equals('assistant'));
      });

      test('toChatCompletion() builds all choices', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"role": "assistant", "content": "Alpha"},
                    "finish_reason": "stop"
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
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"role": "assistant", "content": "Beta"},
                    "finish_reason": "length"
                  }
                ]
              }
            '''),
            ),
          );

        final completion = accumulator.toChatCompletion();
        expect(completion.choices, hasLength(2));
        expect(completion.choices[0].index, equals(0));
        expect(completion.choices[0].message.content, equals('Alpha'));
        expect(completion.choices[0].finishReason, equals(FinishReason.stop));
        expect(completion.choices[1].index, equals(1));
        expect(completion.choices[1].message.content, equals('Beta'));
        expect(completion.choices[1].finishReason, equals(FinishReason.length));
      });

      test('per-choice tool calls are independent', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_(r'''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {
                      "role": "assistant",
                      "tool_calls": [
                        {
                          "index": 0,
                          "id": "call_A",
                          "type": "function",
                          "function": {"name": "func_a", "arguments": "{\"x\":1}"}
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
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_(r'''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {
                      "role": "assistant",
                      "tool_calls": [
                        {
                          "index": 0,
                          "id": "call_B",
                          "type": "function",
                          "function": {"name": "func_b", "arguments": "{\"y\":2}"}
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

        final choices = accumulator.choices;
        expect(choices[0].toolCalls, hasLength(1));
        expect(choices[0].toolCalls.first.id, equals('call_A'));
        expect(choices[0].toolCalls.first.function.name, equals('func_a'));
        expect(choices[1].toolCalls, hasLength(1));
        expect(choices[1].toolCalls.first.id, equals('call_B'));
        expect(choices[1].toolCalls.first.function.name, equals('func_b'));

        // Flat getter returns choice 0
        expect(accumulator.toolCalls.first.id, equals('call_A'));
      });

      test('per-choice finish reasons', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"content": "A"},
                    "finish_reason": "stop"
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
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"content": "B"},
                    "finish_reason": "length"
                  }
                ]
              }
            '''),
            ),
          );

        final choices = accumulator.choices;
        expect(choices[0].finishReason, equals(FinishReason.stop));
        expect(choices[1].finishReason, equals(FinishReason.length));
      });

      test('per-choice refusal', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"refusal": "I cannot help with that"},
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
                "id": "chatcmpl-mc",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"refusal": "Policy violation"},
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          );

        final choices = accumulator.choices;
        expect(choices[0].refusal, equals('I cannot help with that'));
        expect(choices[1].refusal, equals('Policy violation'));
      });
    });

    group('logprobs and reasoningDetails accumulation', () {
      test('logprobs accumulated per-choice', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-lp",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"content": "Hello"},
                    "logprobs": {
                      "content": [
                        {"token": "Hello", "logprob": -0.5, "bytes": [72, 101, 108, 108, 111]}
                      ]
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
                "id": "chatcmpl-lp",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"content": " World"},
                    "logprobs": {
                      "content": [
                        {"token": " World", "logprob": -1.2, "bytes": [32, 87, 111, 114, 108, 100]}
                      ]
                    },
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          );

        final choices = accumulator.choices;
        expect(choices[0].logprobs, isNotNull);
        expect(choices[0].logprobs!.content, hasLength(2));
        expect(choices[0].logprobs!.content![0].token, equals('Hello'));
        expect(choices[0].logprobs!.content![1].token, equals(' World'));
      });

      test('reasoningDetails accumulated', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-rd",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {
                      "reasoning_details": [
                        {"type": "reasoning.summary", "text": "Step 1"}
                      ]
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
                "id": "chatcmpl-rd",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {
                      "reasoning_details": [
                        {"type": "reasoning.text", "text": "Step 2 details"}
                      ]
                    },
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          );

        final choices = accumulator.choices;
        expect(choices[0].reasoningDetails, hasLength(2));
        expect(
          choices[0].reasoningDetails[0].type,
          equals('reasoning.summary'),
        );
        expect(choices[0].reasoningDetails[0].text, equals('Step 1'));
        expect(choices[0].reasoningDetails[1].type, equals('reasoning.text'));
        expect(choices[0].reasoningDetails[1].text, equals('Step 2 details'));
      });

      test('logprobs and reasoningDetails in toChatCompletion()', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-both",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {
                      "content": "Hi",
                      "reasoning_details": [
                        {"type": "reasoning.summary", "text": "Thinking"}
                      ]
                    },
                    "logprobs": {
                      "content": [
                        {"token": "Hi", "logprob": -0.3}
                      ]
                    },
                    "finish_reason": "stop"
                  }
                ]
              }
            '''),
            ),
          );

        final completion = accumulator.toChatCompletion();
        expect(completion.choices.first.logprobs, isNotNull);
        expect(completion.choices.first.logprobs!.content, hasLength(1));
        expect(
          completion.choices.first.logprobs!.content!.first.token,
          equals('Hi'),
        );
        expect(completion.choices.first.message.reasoningDetails, hasLength(1));
        expect(
          completion.choices.first.message.reasoningDetails!.first.text,
          equals('Thinking'),
        );
      });
    });

    group('behavioral fixes', () {
      test('usage overwrite semantics', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-u",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"content": "Hi"},
                    "finish_reason": null
                  }
                ],
                "usage": {"prompt_tokens": 5, "completion_tokens": 1, "total_tokens": 6}
              }
            '''),
            ),
          )
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-u",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {},
                    "finish_reason": "stop"
                  }
                ],
                "usage": {"prompt_tokens": 5, "completion_tokens": 10, "total_tokens": 15}
              }
            '''),
            ),
          );

        // The last usage should win (overwrite semantics)
        expect(accumulator.usage!.completionTokens, equals(10));
        expect(accumulator.usage!.totalTokens, equals(15));
      });

      test('null choice index defaults to 0', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-ni",
                "model": "gpt-4o",
                "choices": [
                  {
                    "delta": {"content": "No index"},
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          );

        expect(accumulator.content, equals('No index'));
        expect(accumulator.choices, hasLength(1));
        expect(accumulator.choices[0].index, equals(0));
      });
    });

    group('edge cases', () {
      test('empty choices list does not crash', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-ec",
                "model": "gpt-4o",
                "choices": []
              }
            '''),
            ),
          );

        expect(accumulator.choices, isEmpty);
        expect(accumulator.content, equals(''));
        expect(accumulator.hasToolCalls, isFalse);
        expect(accumulator.hasReasoningContent, isFalse);
      });

      test('reset clears per-choice state', () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-r",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"content": "A"},
                    "finish_reason": "stop"
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
                "id": "chatcmpl-r",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"content": "B"},
                    "finish_reason": "length"
                  }
                ]
              }
            '''),
            ),
          )
          ..reset()
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-r2",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 0,
                    "delta": {"content": "Fresh"},
                    "finish_reason": "stop"
                  }
                ]
              }
            '''),
            ),
          );

        expect(accumulator.choices, hasLength(1));
        expect(accumulator.content, equals('Fresh'));
        expect(accumulator.id, equals('chatcmpl-r2'));
      });

      test('out-of-order choice indices', () {
        final accumulator = ChatStreamAccumulator()
          // Send index 2 first
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-oo",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 2,
                    "delta": {"content": "Third"},
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          )
          // Then send index 1
          ..add(
            ChatStreamEvent.fromJson(
              jsonDecode_('''
              {
                "id": "chatcmpl-oo",
                "model": "gpt-4o",
                "choices": [
                  {
                    "index": 1,
                    "delta": {"content": "Second"},
                    "finish_reason": null
                  }
                ]
              }
            '''),
            ),
          );

        // Should have 3 choices: 0 (empty), 1, 2
        expect(accumulator.choices, hasLength(3));
        expect(accumulator.choices[0].content, equals(''));
        expect(accumulator.choices[1].content, equals('Second'));
        expect(accumulator.choices[2].content, equals('Third'));
      });
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

    test('fromJson defaults index to 0 when field is missing', () {
      final json = jsonDecode_(r'''
        {
          "id": "call_456",
          "type": "function",
          "function": {
            "name": "my_func",
            "arguments": "{\"key\":\"value\"}"
          }
        }
      ''');

      final delta = ToolCallDelta.fromJson(json);

      expect(delta.index, 0);
      expect(delta.id, 'call_456');
      expect(delta.function!.name, 'my_func');
    });

    test('fromJson defaults index to 0 when field is explicit null', () {
      final json = jsonDecode_(r'''
        {
          "index": null,
          "id": "call_789",
          "type": "function",
          "function": {
            "name": "my_func",
            "arguments": "{}"
          }
        }
      ''');

      final delta = ToolCallDelta.fromJson(json);

      expect(delta.index, 0);
      expect(delta.id, 'call_789');
    });

    test('fromJson uses fallbackIndex when index is missing', () {
      final json = jsonDecode_(r'''
        {
          "id": "call_101",
          "type": "function",
          "function": {
            "name": "second_func",
            "arguments": "{}"
          }
        }
      ''');

      final delta = ToolCallDelta.fromJson(json, fallbackIndex: 1);

      expect(delta.index, 1);
      expect(delta.id, 'call_101');
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

  group('Third-party provider compatibility', () {
    test('handles missing delta in choice — defaults to empty ChatDelta', () {
      final json = jsonDecode_('''
        {
          "id": "chatcmpl-123",
          "object": "chat.completion.chunk",
          "created": 1677652288,
          "model": "gpt-4o",
          "choices": [
            {
              "index": 0,
              "delta": null,
              "finish_reason": "stop"
            }
          ]
        }
      ''');

      final event = ChatStreamEvent.fromJson(json);
      final choice = event.choices!.first;
      expect(choice.delta.content, isNull);
      expect(choice.delta.role, isNull);
      expect(choice.finishReason, FinishReason.stop);
    });

    test('handles absent delta key in choice', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion.chunk',
        'created': 1677652288,
        'model': 'gpt-4o',
        'choices': <dynamic>[
          {'index': 0, 'finish_reason': 'stop'},
        ],
      };

      final event = ChatStreamEvent.fromJson(json);
      final choice = event.choices!.first;
      expect(choice.delta.content, isNull);
    });

    test('FunctionCallDelta handles arguments as Map', () {
      final json = {
        'name': 'get_weather',
        'arguments': {'location': 'Boston'},
      };

      final delta = FunctionCallDelta.fromJson(json);
      expect(delta.arguments, '{"location":"Boston"}');
    });

    test('FunctionCallDelta handles arguments as String', () {
      final json = {'name': 'get_weather', 'arguments': '{"location":'};

      final delta = FunctionCallDelta.fromJson(json);
      expect(delta.arguments, '{"location":');
    });

    test('FunctionCallDelta handles null arguments', () {
      final json = {'name': 'get_weather'};

      final delta = FunctionCallDelta.fromJson(json);
      expect(delta.arguments, isNull);
    });

    test('unknown finish_reason in stream chunk', () {
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
              "finish_reason": "error"
            }
          ]
        }
      ''');

      final event = ChatStreamEvent.fromJson(json);
      expect(event.choices!.first.finishReason, FinishReason.unknown);
    });
  });
}
