import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ConversationEntry', () {
    group('MessageInputEntry', () {
      group('constructor', () {
        test('creates with required content', () {
          const entry = MessageInputEntry(content: 'Hello');
          expect(entry.content, 'Hello');
          expect(entry.role, 'user');
          expect(entry.id, isNull);
          expect(entry.type, 'message.input');
        });

        test('creates with all parameters', () {
          const entry = MessageInputEntry(
            id: 'entry-123',
            content: 'Hello world',
            role: 'user',
          );
          expect(entry.id, 'entry-123');
          expect(entry.content, 'Hello world');
          expect(entry.role, 'user');
        });
      });

      group('toJson', () {
        test('serializes correctly', () {
          const entry = MessageInputEntry(
            id: 'entry-123',
            content: 'Hello',
            role: 'user',
          );
          final json = entry.toJson();
          expect(json['type'], 'message.input');
          expect(json['role'], 'user');
          expect(json['content'], 'Hello');
          expect(json['id'], 'entry-123');
        });

        test('omits null id', () {
          const entry = MessageInputEntry(content: 'Hello');
          final json = entry.toJson();
          expect(json.containsKey('id'), isFalse);
        });
      });

      group('fromJson', () {
        test('deserializes correctly', () {
          final json = <String, dynamic>{
            'type': 'message.input',
            'id': 'entry-456',
            'content': 'Hi there',
            'role': 'user',
          };
          final entry = MessageInputEntry.fromJson(json);
          expect(entry.id, 'entry-456');
          expect(entry.content, 'Hi there');
          expect(entry.role, 'user');
        });

        test('handles missing fields', () {
          final json = <String, dynamic>{};
          final entry = MessageInputEntry.fromJson(json);
          expect(entry.content, '');
          expect(entry.role, 'user');
          expect(entry.id, isNull);
        });
      });

      test('copyWith works correctly', () {
        const original = MessageInputEntry(
          id: 'entry-1',
          content: 'Original',
          role: 'user',
        );
        final copy = original.copyWith(content: 'Updated');
        expect(copy.id, 'entry-1');
        expect(copy.content, 'Updated');
        expect(copy.role, 'user');
      });

      test('equality based on id and content', () {
        const entry1 = MessageInputEntry(id: 'e1', content: 'Hello');
        const entry2 = MessageInputEntry(id: 'e1', content: 'Hello');
        const entry3 = MessageInputEntry(id: 'e2', content: 'Hello');
        expect(entry1, equals(entry2));
        expect(entry1, isNot(equals(entry3)));
      });

      test('toString returns descriptive string', () {
        const entry = MessageInputEntry(content: 'Hello world');
        expect(
          entry.toString(),
          'MessageInputEntry(role: user, content: 11 chars)',
        );
      });
    });

    group('MessageOutputEntry', () {
      group('constructor', () {
        test('creates with required content', () {
          const entry = MessageOutputEntry(content: 'Response');
          expect(entry.content, 'Response');
          expect(entry.role, 'assistant');
          expect(entry.id, isNull);
          expect(entry.toolCalls, isNull);
          expect(entry.type, 'message.output');
        });

        test('creates with tool calls', () {
          const entry = MessageOutputEntry(
            content: '',
            toolCalls: [
              ToolCall(
                id: 'call-1',
                function: FunctionCall(name: 'search', arguments: '{}'),
              ),
            ],
          );
          expect(entry.toolCalls, hasLength(1));
        });
      });

      group('toJson', () {
        test('serializes with tool calls', () {
          const entry = MessageOutputEntry(
            id: 'out-1',
            content: 'Here are the results',
            toolCalls: [
              ToolCall(
                id: 'call-1',
                function: FunctionCall(
                  name: 'search',
                  arguments: '{"q":"test"}',
                ),
              ),
            ],
          );
          final json = entry.toJson();
          expect(json['type'], 'message.output');
          expect(json['role'], 'assistant');
          expect(json['content'], 'Here are the results');
          expect(json['tool_calls'], isList);
          expect(json['tool_calls'] as List<dynamic>, hasLength(1));
        });
      });

      group('fromJson', () {
        test('deserializes with tool calls', () {
          final json = <String, dynamic>{
            'type': 'message.output',
            'id': 'out-1',
            'content': 'Response',
            'role': 'assistant',
            'tool_calls': [
              {
                'id': 'call-1',
                'function': {'name': 'test', 'arguments': '{}'},
              },
            ],
          };
          final entry = MessageOutputEntry.fromJson(json);
          expect(entry.id, 'out-1');
          expect(entry.content, 'Response');
          expect(entry.toolCalls, hasLength(1));
        });
      });
    });

    group('FunctionCallEntry', () {
      group('constructor', () {
        test('creates with required parameters', () {
          const entry = FunctionCallEntry(
            name: 'search',
            arguments: '{"query": "test"}',
          );
          expect(entry.name, 'search');
          expect(entry.arguments, '{"query": "test"}');
          expect(entry.type, 'function.call');
        });

        test('creates with all parameters', () {
          const entry = FunctionCallEntry(
            id: 'fc-1',
            name: 'calculate',
            arguments: '{"x": 1, "y": 2}',
            callId: 'call-123',
          );
          expect(entry.id, 'fc-1');
          expect(entry.callId, 'call-123');
        });
      });

      group('toJson', () {
        test('serializes correctly', () {
          const entry = FunctionCallEntry(
            id: 'fc-1',
            name: 'search',
            arguments: '{}',
            callId: 'call-1',
          );
          final json = entry.toJson();
          expect(json['type'], 'function.call');
          expect(json['name'], 'search');
          expect(json['arguments'], '{}');
          expect(json['id'], 'fc-1');
          expect(json['call_id'], 'call-1');
        });
      });

      group('fromJson', () {
        test('deserializes correctly', () {
          final json = <String, dynamic>{
            'type': 'function.call',
            'id': 'fc-2',
            'name': 'get_weather',
            'arguments': '{"city": "Paris"}',
            'call_id': 'call-2',
          };
          final entry = FunctionCallEntry.fromJson(json);
          expect(entry.name, 'get_weather');
          expect(entry.arguments, '{"city": "Paris"}');
          expect(entry.callId, 'call-2');
        });
      });

      test('toString returns function name', () {
        const entry = FunctionCallEntry(name: 'search', arguments: '{}');
        expect(entry.toString(), 'FunctionCallEntry(name: search)');
      });
    });

    group('FunctionResultEntry', () {
      group('constructor', () {
        test('creates with required parameters', () {
          const entry = FunctionResultEntry(
            callId: 'call-1',
            result: '{"data": "value"}',
          );
          expect(entry.callId, 'call-1');
          expect(entry.result, '{"data": "value"}');
          expect(entry.isError, isNull);
          expect(entry.type, 'function.result');
        });

        test('creates with error flag', () {
          const entry = FunctionResultEntry(
            callId: 'call-1',
            result: 'Error: Not found',
            isError: true,
          );
          expect(entry.isError, true);
        });
      });

      group('toJson', () {
        test('serializes correctly', () {
          const entry = FunctionResultEntry(
            id: 'fr-1',
            callId: 'call-1',
            result: 'Success',
            isError: false,
          );
          final json = entry.toJson();
          expect(json['type'], 'function.result');
          expect(json['call_id'], 'call-1');
          expect(json['result'], 'Success');
          expect(json['is_error'], false);
        });
      });

      group('fromJson', () {
        test('deserializes correctly', () {
          final json = <String, dynamic>{
            'type': 'function.result',
            'id': 'fr-2',
            'call_id': 'call-2',
            'result': 'Done',
            'is_error': false,
          };
          final entry = FunctionResultEntry.fromJson(json);
          expect(entry.callId, 'call-2');
          expect(entry.result, 'Done');
          expect(entry.isError, false);
        });
      });
    });

    group('ToolExecutionEntry', () {
      group('constructor', () {
        test('creates with required toolType', () {
          const entry = ToolExecutionEntry(toolType: 'web_search');
          expect(entry.toolType, 'web_search');
          expect(entry.type, 'tool.execution');
        });

        test('creates with input and output', () {
          const entry = ToolExecutionEntry(
            toolType: 'code_interpreter',
            input: {'code': 'print(1+1)'},
            output: {'result': '2'},
            status: 'completed',
          );
          expect(entry.input, {'code': 'print(1+1)'});
          expect(entry.output, {'result': '2'});
          expect(entry.status, 'completed');
        });
      });

      group('toJson', () {
        test('serializes correctly', () {
          const entry = ToolExecutionEntry(
            id: 'te-1',
            toolType: 'web_search',
            input: {'query': 'test'},
            output: {'results': <dynamic>[]},
            status: 'success',
          );
          final json = entry.toJson();
          expect(json['type'], 'tool.execution');
          expect(json['tool_type'], 'web_search');
          expect(json['input'], {'query': 'test'});
          expect(json['output'], {'results': <dynamic>[]});
          expect(json['status'], 'success');
        });
      });

      group('fromJson', () {
        test('deserializes correctly', () {
          final json = <String, dynamic>{
            'type': 'tool.execution',
            'tool_type': 'image_generation',
            'input': {'prompt': 'a cat'},
            'output': {'url': 'https://...'},
            'status': 'done',
          };
          final entry = ToolExecutionEntry.fromJson(json);
          expect(entry.toolType, 'image_generation');
          expect(entry.status, 'done');
        });
      });
    });

    group('AgentHandoffEntry', () {
      group('constructor', () {
        test('creates with required targetAgentId', () {
          const entry = AgentHandoffEntry(targetAgentId: 'agent-2');
          expect(entry.targetAgentId, 'agent-2');
          expect(entry.type, 'agent.handoff');
        });

        test('creates with reason and context', () {
          const entry = AgentHandoffEntry(
            targetAgentId: 'specialist-agent',
            reason: 'Requires specialized knowledge',
            context: {'topic': 'legal'},
          );
          expect(entry.reason, 'Requires specialized knowledge');
          expect(entry.context, {'topic': 'legal'});
        });
      });

      group('toJson', () {
        test('serializes correctly', () {
          const entry = AgentHandoffEntry(
            id: 'ah-1',
            targetAgentId: 'agent-3',
            reason: 'Escalation',
            context: {'priority': 'high'},
          );
          final json = entry.toJson();
          expect(json['type'], 'agent.handoff');
          expect(json['target_agent_id'], 'agent-3');
          expect(json['reason'], 'Escalation');
          expect(json['context'], {'priority': 'high'});
        });
      });

      group('fromJson', () {
        test('deserializes correctly', () {
          final json = <String, dynamic>{
            'type': 'agent.handoff',
            'id': 'ah-2',
            'target_agent_id': 'agent-4',
            'reason': 'Transfer',
            'context': {'user_id': '123'},
          };
          final entry = AgentHandoffEntry.fromJson(json);
          expect(entry.targetAgentId, 'agent-4');
          expect(entry.reason, 'Transfer');
        });
      });
    });

    group('ConversationEntry.fromJson factory', () {
      test('creates MessageInputEntry for message.input type', () {
        final json = <String, dynamic>{
          'type': 'message.input',
          'content': 'Hello',
          'role': 'user',
        };
        final entry = ConversationEntry.fromJson(json);
        expect(entry, isA<MessageInputEntry>());
      });

      test('creates MessageOutputEntry for message.output type', () {
        final json = <String, dynamic>{
          'type': 'message.output',
          'content': 'Response',
          'role': 'assistant',
        };
        final entry = ConversationEntry.fromJson(json);
        expect(entry, isA<MessageOutputEntry>());
      });

      test('creates FunctionCallEntry for function.call type', () {
        final json = <String, dynamic>{
          'type': 'function.call',
          'name': 'test',
          'arguments': '{}',
        };
        final entry = ConversationEntry.fromJson(json);
        expect(entry, isA<FunctionCallEntry>());
      });

      test('creates FunctionResultEntry for function.result type', () {
        final json = <String, dynamic>{
          'type': 'function.result',
          'call_id': 'call-1',
          'result': 'done',
        };
        final entry = ConversationEntry.fromJson(json);
        expect(entry, isA<FunctionResultEntry>());
      });

      test('creates ToolExecutionEntry for tool.execution type', () {
        final json = <String, dynamic>{
          'type': 'tool.execution',
          'tool_type': 'web_search',
        };
        final entry = ConversationEntry.fromJson(json);
        expect(entry, isA<ToolExecutionEntry>());
      });

      test('creates AgentHandoffEntry for agent.handoff type', () {
        final json = <String, dynamic>{
          'type': 'agent.handoff',
          'target_agent_id': 'agent-1',
        };
        final entry = ConversationEntry.fromJson(json);
        expect(entry, isA<AgentHandoffEntry>());
      });

      test('defaults to MessageInputEntry for unknown type', () {
        final json = <String, dynamic>{
          'type': 'unknown.type',
          'content': 'test',
        };
        final entry = ConversationEntry.fromJson(json);
        expect(entry, isA<MessageInputEntry>());
      });
    });

    group('factory constructors', () {
      test('ConversationEntry.userMessage creates MessageInputEntry', () {
        final entry = ConversationEntry.userMessage('Hello', id: 'msg-1');
        expect(entry, isA<MessageInputEntry>());
        expect((entry as MessageInputEntry).content, 'Hello');
        expect(entry.id, 'msg-1');
      });

      test('ConversationEntry.assistantMessage creates MessageOutputEntry', () {
        final entry = ConversationEntry.assistantMessage(
          'Response',
          id: 'msg-2',
        );
        expect(entry, isA<MessageOutputEntry>());
        expect((entry as MessageOutputEntry).content, 'Response');
        expect(entry.id, 'msg-2');
      });
    });
  });
}
