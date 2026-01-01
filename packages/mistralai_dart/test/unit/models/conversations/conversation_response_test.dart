import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ConversationResponse', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const response = ConversationResponse(
          conversationId: 'conv-123',
          outputs: [],
        );
        expect(response.conversationId, 'conv-123');
        expect(response.outputs, isEmpty);
        expect(response.usage, isNull);
      });

      test('creates with all parameters', () {
        const response = ConversationResponse(
          conversationId: 'conv-456',
          outputs: [MessageOutputEntry(content: 'Hello!')],
          usage: UsageInfo(
            promptTokens: 10,
            completionTokens: 5,
            totalTokens: 15,
          ),
        );
        expect(response.outputs, hasLength(1));
        expect(response.usage?.totalTokens, 15);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const response = ConversationResponse(
          conversationId: 'conv-123',
          outputs: [MessageOutputEntry(content: 'Response')],
          usage: UsageInfo(
            promptTokens: 20,
            completionTokens: 10,
            totalTokens: 30,
          ),
        );
        final json = response.toJson();
        expect(json['conversation_id'], 'conv-123');
        expect(json['outputs'], hasLength(1));
        expect(json['usage'], isNotNull);
      });

      test('omits null usage', () {
        const response = ConversationResponse(
          conversationId: 'conv-123',
          outputs: [],
        );
        final json = response.toJson();
        expect(json.containsKey('usage'), isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'conversation_id': 'conv-789',
          'outputs': [
            {'type': 'message.output', 'content': 'Hello', 'role': 'assistant'},
          ],
          'usage': {
            'prompt_tokens': 15,
            'completion_tokens': 25,
            'total_tokens': 40,
          },
        };
        final response = ConversationResponse.fromJson(json);
        expect(response.conversationId, 'conv-789');
        expect(response.outputs, hasLength(1));
        expect(response.outputs.first, isA<MessageOutputEntry>());
        expect(response.usage?.totalTokens, 40);
      });

      test('handles missing fields', () {
        final json = <String, dynamic>{};
        final response = ConversationResponse.fromJson(json);
        expect(response.conversationId, '');
        expect(response.outputs, isEmpty);
        expect(response.usage, isNull);
      });

      test('handles multiple output types', () {
        final json = <String, dynamic>{
          'conversation_id': 'conv-multi',
          'outputs': [
            {
              'type': 'message.output',
              'content': 'Searching...',
              'role': 'assistant',
            },
            {'type': 'function.call', 'name': 'search', 'arguments': '{}'},
            {'type': 'function.result', 'call_id': 'c1', 'result': 'done'},
            {
              'type': 'message.output',
              'content': 'Here are the results',
              'role': 'assistant',
            },
          ],
        };
        final response = ConversationResponse.fromJson(json);
        expect(response.outputs, hasLength(4));
        expect(response.outputs[0], isA<MessageOutputEntry>());
        expect(response.outputs[1], isA<FunctionCallEntry>());
        expect(response.outputs[2], isA<FunctionResultEntry>());
        expect(response.outputs[3], isA<MessageOutputEntry>());
      });
    });

    group('convenience getters', () {
      test('outputCount returns number of outputs', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [
            MessageOutputEntry(content: 'A'),
            MessageOutputEntry(content: 'B'),
          ],
        );
        expect(response.outputCount, 2);
      });

      test('hasOutputs returns true when outputs exist', () {
        const response1 = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [MessageOutputEntry(content: 'A')],
        );
        expect(response1.hasOutputs, isTrue);

        const response2 = ConversationResponse(
          conversationId: 'conv-2',
          outputs: [],
        );
        expect(response2.hasOutputs, isFalse);
      });

      test('firstOutput returns first entry', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [
            MessageOutputEntry(content: 'First'),
            MessageOutputEntry(content: 'Second'),
          ],
        );
        final first = response.firstOutput! as MessageOutputEntry;
        expect(first.content, 'First');
      });

      test('firstOutput returns null for empty outputs', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [],
        );
        expect(response.firstOutput, isNull);
      });

      test('lastOutput returns last entry', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [
            MessageOutputEntry(content: 'First'),
            MessageOutputEntry(content: 'Last'),
          ],
        );
        final last = response.lastOutput! as MessageOutputEntry;
        expect(last.content, 'Last');
      });

      test('text returns content from first message output', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [
            FunctionCallEntry(name: 'test', arguments: '{}'),
            MessageOutputEntry(content: 'The answer is 42'),
          ],
        );
        expect(response.text, 'The answer is 42');
      });

      test('text returns null when no message outputs', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [FunctionCallEntry(name: 'test', arguments: '{}')],
        );
        expect(response.text, isNull);
      });

      test('messageOutputs returns only MessageOutputEntry items', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [
            MessageOutputEntry(content: 'A'),
            FunctionCallEntry(name: 'test', arguments: '{}'),
            MessageOutputEntry(content: 'B'),
          ],
        );
        final messages = response.messageOutputs;
        expect(messages, hasLength(2));
        expect(messages[0].content, 'A');
        expect(messages[1].content, 'B');
      });

      test('functionCalls returns only FunctionCallEntry items', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [
            MessageOutputEntry(content: 'A'),
            FunctionCallEntry(name: 'fn1', arguments: '{}'),
            FunctionCallEntry(name: 'fn2', arguments: '{}'),
          ],
        );
        final calls = response.functionCalls;
        expect(calls, hasLength(2));
        expect(calls[0].name, 'fn1');
        expect(calls[1].name, 'fn2');
      });

      test('toolExecutions returns only ToolExecutionEntry items', () {
        const response = ConversationResponse(
          conversationId: 'conv-1',
          outputs: [
            MessageOutputEntry(content: 'A'),
            ToolExecutionEntry(toolType: 'web_search'),
            ToolExecutionEntry(toolType: 'code_interpreter'),
          ],
        );
        final executions = response.toolExecutions;
        expect(executions, hasLength(2));
        expect(executions[0].toolType, 'web_search');
        expect(executions[1].toolType, 'code_interpreter');
      });
    });

    group('equality', () {
      test('equals with same conversationId', () {
        const resp1 = ConversationResponse(
          conversationId: 'conv-123',
          outputs: [],
        );
        const resp2 = ConversationResponse(
          conversationId: 'conv-123',
          outputs: [MessageOutputEntry(content: 'X')],
        );
        expect(resp1, equals(resp2));
        expect(resp1.hashCode, resp2.hashCode);
      });

      test('not equals with different conversationId', () {
        const resp1 = ConversationResponse(
          conversationId: 'conv-123',
          outputs: [],
        );
        const resp2 = ConversationResponse(
          conversationId: 'conv-456',
          outputs: [],
        );
        expect(resp1, isNot(equals(resp2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const response = ConversationResponse(
          conversationId: 'conv-xyz',
          outputs: [
            MessageOutputEntry(content: 'A'),
            MessageOutputEntry(content: 'B'),
          ],
        );
        expect(
          response.toString(),
          'ConversationResponse(conversationId: conv-xyz, outputs: 2)',
        );
      });
    });
  });

  group('ConversationEntriesResponse', () {
    group('constructor', () {
      test('creates with required data', () {
        const response = ConversationEntriesResponse(data: []);
        expect(response.data, isEmpty);
        expect(response.object, 'list');
      });

      test('creates with entries', () {
        const response = ConversationEntriesResponse(
          data: [
            MessageInputEntry(content: 'Hello'),
            MessageOutputEntry(content: 'Hi'),
          ],
        );
        expect(response.data, hasLength(2));
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const response = ConversationEntriesResponse(
          data: [MessageInputEntry(content: 'Test')],
        );
        final json = response.toJson();
        expect(json['object'], 'list');
        expect(json['data'], hasLength(1));
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'object': 'list',
          'data': [
            {'type': 'message.input', 'content': 'Hi', 'role': 'user'},
            {'type': 'message.output', 'content': 'Hello', 'role': 'assistant'},
          ],
        };
        final response = ConversationEntriesResponse.fromJson(json);
        expect(response.data, hasLength(2));
        expect(response.data[0], isA<MessageInputEntry>());
        expect(response.data[1], isA<MessageOutputEntry>());
      });

      test('handles missing data', () {
        final json = <String, dynamic>{'object': 'list'};
        final response = ConversationEntriesResponse.fromJson(json);
        expect(response.data, isEmpty);
      });
    });

    group('convenience getters', () {
      test('isEmpty and isNotEmpty work correctly', () {
        const empty = ConversationEntriesResponse(data: []);
        expect(empty.isEmpty, isTrue);
        expect(empty.isNotEmpty, isFalse);

        const nonEmpty = ConversationEntriesResponse(
          data: [MessageInputEntry(content: 'X')],
        );
        expect(nonEmpty.isEmpty, isFalse);
        expect(nonEmpty.isNotEmpty, isTrue);
      });

      test('length returns count', () {
        const response = ConversationEntriesResponse(
          data: [
            MessageInputEntry(content: 'A'),
            MessageOutputEntry(content: 'B'),
            MessageInputEntry(content: 'C'),
          ],
        );
        expect(response.length, 3);
      });

      test('userMessages returns only MessageInputEntry items', () {
        const response = ConversationEntriesResponse(
          data: [
            MessageInputEntry(content: 'User 1'),
            MessageOutputEntry(content: 'Assistant 1'),
            MessageInputEntry(content: 'User 2'),
          ],
        );
        final userMessages = response.userMessages;
        expect(userMessages, hasLength(2));
        expect(userMessages[0].content, 'User 1');
        expect(userMessages[1].content, 'User 2');
      });

      test('assistantMessages returns only MessageOutputEntry items', () {
        const response = ConversationEntriesResponse(
          data: [
            MessageInputEntry(content: 'User 1'),
            MessageOutputEntry(content: 'Assistant 1'),
            MessageOutputEntry(content: 'Assistant 2'),
          ],
        );
        final assistantMessages = response.assistantMessages;
        expect(assistantMessages, hasLength(2));
        expect(assistantMessages[0].content, 'Assistant 1');
        expect(assistantMessages[1].content, 'Assistant 2');
      });
    });

    group('equality', () {
      test('equals with same data', () {
        const resp1 = ConversationEntriesResponse(
          data: [MessageInputEntry(content: 'A')],
        );
        const resp2 = ConversationEntriesResponse(
          data: [MessageInputEntry(content: 'A')], // Same content
        );
        expect(resp1, equals(resp2));
      });

      test('not equals with different data', () {
        const resp1 = ConversationEntriesResponse(
          data: [MessageInputEntry(content: 'A')],
        );
        const resp2 = ConversationEntriesResponse(
          data: [MessageInputEntry(content: 'B')], // Different content
        );
        expect(resp1, isNot(equals(resp2)));
      });

      test('not equals with different length', () {
        const resp1 = ConversationEntriesResponse(
          data: [MessageInputEntry(content: 'A')],
        );
        const resp2 = ConversationEntriesResponse(data: []);
        expect(resp1, isNot(equals(resp2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const response = ConversationEntriesResponse(
          data: [
            MessageInputEntry(content: 'A'),
            MessageOutputEntry(content: 'B'),
          ],
        );
        expect(response.toString(), 'ConversationEntriesResponse(entries: 2)');
      });
    });
  });
}
