import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AgentCompletionRequest', () {
    group('constructor', () {
      test('creates with required parameters', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
        );
        expect(request.agentId, 'agent-123');
        expect(request.messages, hasLength(1));
        expect(request.maxTokens, isNull);
        expect(request.stream, isNull);
        expect(request.stop, isNull);
        expect(request.temperature, isNull);
        expect(request.topP, isNull);
        expect(request.tools, isNull);
        expect(request.toolChoice, isNull);
        expect(request.responseFormat, isNull);
        expect(request.randomSeed, isNull);
      });

      test('creates with all parameters', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-456',
          messages: [ChatMessage.system('Be helpful'), ChatMessage.user('Hi')],
          maxTokens: 1000,
          stream: true,
          stop: const ['END'],
          temperature: 0.7,
          topP: 0.9,
          tools: const [Tool.webSearch()],
          toolChoice: const ToolChoiceAuto(),
          responseFormat: const ResponseFormatJsonObject(),
          randomSeed: 42,
        );
        expect(request.agentId, 'agent-456');
        expect(request.messages, hasLength(2));
        expect(request.maxTokens, 1000);
        expect(request.stream, true);
        expect(request.stop, ['END']);
        expect(request.temperature, 0.7);
        expect(request.topP, 0.9);
        expect(request.tools, hasLength(1));
        expect(request.toolChoice, isNotNull);
        expect(request.responseFormat, isNotNull);
        expect(request.randomSeed, 42);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
        );
        final json = request.toJson();
        expect(json['agent_id'], 'agent-123');
        expect(json['messages'], isList);
        expect(json.containsKey('max_tokens'), isFalse);
        expect(json.containsKey('stream'), isFalse);
        expect(json.containsKey('stop'), isFalse);
        expect(json.containsKey('temperature'), isFalse);
        expect(json.containsKey('top_p'), isFalse);
        expect(json.containsKey('tools'), isFalse);
        expect(json.containsKey('tool_choice'), isFalse);
        expect(json.containsKey('response_format'), isFalse);
        expect(json.containsKey('random_seed'), isFalse);
      });

      test('serializes all fields', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-456',
          messages: [ChatMessage.user('Hi')],
          maxTokens: 500,
          stream: false,
          stop: const ['STOP', 'END'],
          temperature: 0.5,
          topP: 0.95,
          tools: const [Tool.codeInterpreter()],
          toolChoice: const ToolChoiceNone(),
          responseFormat: const ResponseFormatText(),
          randomSeed: 123,
        );
        final json = request.toJson();
        expect(json['agent_id'], 'agent-456');
        expect(json['messages'], hasLength(1));
        expect(json['max_tokens'], 500);
        expect(json['stream'], false);
        expect(json['stop'], ['STOP', 'END']);
        expect(json['temperature'], 0.5);
        expect(json['top_p'], 0.95);
        expect(json['tools'], isList);
        expect(json['tool_choice'], isNotNull);
        expect(json['response_format'], isNotNull);
        expect(json['random_seed'], 123);
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{
          'agent_id': 'agent-789',
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
        };
        final request = AgentCompletionRequest.fromJson(json);
        expect(request.agentId, 'agent-789');
        expect(request.messages, hasLength(1));
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'agent_id': 'agent-full',
          'messages': [
            {'role': 'user', 'content': 'Hi'},
          ],
          'max_tokens': 750,
          'stream': true,
          'stop': ['DONE'],
          'temperature': 0.8,
          'top_p': 0.85,
          'tools': [
            {'type': 'web_search'},
          ],
          'tool_choice': 'auto',
          'response_format': {'type': 'json_object'},
          'random_seed': 999,
        };
        final request = AgentCompletionRequest.fromJson(json);
        expect(request.agentId, 'agent-full');
        expect(request.messages, hasLength(1));
        expect(request.maxTokens, 750);
        expect(request.stream, true);
        expect(request.stop, ['DONE']);
        expect(request.temperature, 0.8);
        expect(request.topP, 0.85);
        expect(request.tools, hasLength(1));
        expect(request.toolChoice, isNotNull);
        expect(request.responseFormat, isNotNull);
        expect(request.randomSeed, 999);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'agent_id': 'minimal',
          'messages': <dynamic>[],
        };
        final request = AgentCompletionRequest.fromJson(json);
        expect(request.maxTokens, isNull);
        expect(request.stream, isNull);
        expect(request.stop, isNull);
        expect(request.temperature, isNull);
        expect(request.topP, isNull);
        expect(request.tools, isNull);
        expect(request.toolChoice, isNull);
        expect(request.responseFormat, isNull);
        expect(request.randomSeed, isNull);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        final original = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
          temperature: 0.7,
        );
        final copy = original.copyWith();
        expect(copy.agentId, 'agent-123');
        expect(copy.messages, hasLength(1));
        expect(copy.temperature, 0.7);
      });

      test('copies with all changes', () {
        final original = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
          maxTokens: 100,
          stream: false,
          temperature: 0.5,
        );
        final copy = original.copyWith(
          agentId: 'agent-456',
          messages: [ChatMessage.user('Bye')],
          maxTokens: 200,
          stream: true,
          temperature: 0.9,
        );
        expect(copy.agentId, 'agent-456');
        expect(copy.maxTokens, 200);
        expect(copy.stream, true);
        expect(copy.temperature, 0.9);
      });

      test('copies with partial changes', () {
        final original = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
          temperature: 0.5,
          maxTokens: 100,
        );
        final copy = original.copyWith(temperature: 0.8);
        expect(copy.agentId, 'agent-123');
        expect(copy.temperature, 0.8);
        expect(copy.maxTokens, 100);
      });
    });

    group('equality', () {
      test('equals with same agentId', () {
        final request1 = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
        );
        final request2 = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Bye')],
        );
        expect(request1, equals(request2));
        expect(request1.hashCode, request2.hashCode);
      });

      test('not equals with different agentId', () {
        const request1 = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [],
        );
        const request2 = AgentCompletionRequest(
          agentId: 'agent-456',
          messages: [],
        );
        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello'), ChatMessage.assistant('Hi')],
        );
        expect(
          request.toString(),
          'AgentCompletionRequest(agentId: agent-123, messages: 2)',
        );
      });
    });
  });
}
