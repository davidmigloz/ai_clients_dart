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
        expect(request.frequencyPenalty, isNull);
        expect(request.presencePenalty, isNull);
        expect(request.n, isNull);
        expect(request.parallelToolCalls, isNull);
        expect(request.metadata, isNull);
        expect(request.prediction, isNull);
        expect(request.promptMode, isNull);
        expect(request.reasoningEffort, isNull);
      });

      test('creates with all parameters', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-456',
          messages: [ChatMessage.system('Be helpful'), ChatMessage.user('Hi')],
          maxTokens: 1000,
          stream: true,
          stop: const StopSequence.multiple(['END', 'STOP']),
          temperature: 0.7,
          topP: 0.9,
          tools: const [Tool.webSearch()],
          toolChoice: const ToolChoiceAuto(),
          responseFormat: const ResponseFormatJsonObject(),
          randomSeed: 42,
          frequencyPenalty: 0.5,
          presencePenalty: 0.3,
          n: 2,
          parallelToolCalls: true,
          metadata: const {'key': 'value'},
          prediction: const Prediction.content('expected'),
          promptMode: MistralPromptMode.reasoning,
          reasoningEffort: ReasoningEffort.high,
        );
        expect(request.agentId, 'agent-456');
        expect(request.messages, hasLength(2));
        expect(request.maxTokens, 1000);
        expect(request.stream, true);
        expect(request.stop, isNotNull);
        expect(request.temperature, 0.7);
        expect(request.topP, 0.9);
        expect(request.tools, hasLength(1));
        expect(request.toolChoice, isNotNull);
        expect(request.responseFormat, isNotNull);
        expect(request.randomSeed, 42);
        expect(request.frequencyPenalty, 0.5);
        expect(request.presencePenalty, 0.3);
        expect(request.n, 2);
        expect(request.parallelToolCalls, true);
        expect(request.metadata, {'key': 'value'});
        expect(request.prediction, isNotNull);
        expect(request.promptMode, MistralPromptMode.reasoning);
        expect(request.reasoningEffort, ReasoningEffort.high);
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
        expect(json.containsKey('frequency_penalty'), isFalse);
        expect(json.containsKey('presence_penalty'), isFalse);
        expect(json.containsKey('n'), isFalse);
        expect(json.containsKey('parallel_tool_calls'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
        expect(json.containsKey('prediction'), isFalse);
        expect(json.containsKey('prompt_mode'), isFalse);
        expect(json.containsKey('reasoning_effort'), isFalse);
      });

      test('serializes all fields', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-456',
          messages: [ChatMessage.user('Hi')],
          maxTokens: 500,
          stream: false,
          stop: const StopSequence.multiple(['STOP', 'END']),
          temperature: 0.5,
          topP: 0.95,
          tools: const [Tool.codeInterpreter()],
          toolChoice: const ToolChoiceNone(),
          responseFormat: const ResponseFormatText(),
          randomSeed: 123,
          frequencyPenalty: 0.2,
          presencePenalty: 0.1,
          n: 3,
          parallelToolCalls: false,
          metadata: const {'env': 'test'},
          prediction: const Prediction.content('expected'),
          promptMode: MistralPromptMode.reasoning,
          reasoningEffort: ReasoningEffort.none,
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
        expect(json['frequency_penalty'], 0.2);
        expect(json['presence_penalty'], 0.1);
        expect(json['n'], 3);
        expect(json['parallel_tool_calls'], false);
        expect(json['metadata'], {'env': 'test'});
        expect(json['prediction'], isMap);
        expect(json['prompt_mode'], 'reasoning');
        expect(json['reasoning_effort'], 'none');
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
          'frequency_penalty': 0.4,
          'presence_penalty': 0.6,
          'n': 2,
          'parallel_tool_calls': true,
          'metadata': {'key': 'value'},
          'prediction': {'type': 'content', 'content': 'expected'},
          'prompt_mode': 'reasoning',
          'reasoning_effort': 'high',
        };
        final request = AgentCompletionRequest.fromJson(json);
        expect(request.agentId, 'agent-full');
        expect(request.messages, hasLength(1));
        expect(request.maxTokens, 750);
        expect(request.stream, true);
        expect(request.stop, isNotNull);
        expect(request.temperature, 0.8);
        expect(request.topP, 0.85);
        expect(request.tools, hasLength(1));
        expect(request.toolChoice, isNotNull);
        expect(request.responseFormat, isNotNull);
        expect(request.randomSeed, 999);
        expect(request.frequencyPenalty, 0.4);
        expect(request.presencePenalty, 0.6);
        expect(request.n, 2);
        expect(request.parallelToolCalls, true);
        expect(request.metadata, {'key': 'value'});
        expect(request.prediction, isNotNull);
        expect(request.promptMode, MistralPromptMode.reasoning);
        expect(request.reasoningEffort, ReasoningEffort.high);
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
        expect(request.frequencyPenalty, isNull);
        expect(request.presencePenalty, isNull);
        expect(request.n, isNull);
        expect(request.parallelToolCalls, isNull);
        expect(request.metadata, isNull);
        expect(request.prediction, isNull);
        expect(request.promptMode, isNull);
        expect(request.reasoningEffort, isNull);
      });

      test('deserializes stop as single string', () {
        final json = <String, dynamic>{
          'agent_id': 'agent-1',
          'messages': <dynamic>[],
          'stop': 'END',
        };
        final request = AgentCompletionRequest.fromJson(json);
        expect(request.stop, isNotNull);
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

      test('copies with new values', () {
        final original = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
          maxTokens: 100,
          stream: false,
          temperature: 0.5,
          frequencyPenalty: 0.1,
          reasoningEffort: ReasoningEffort.high,
        );
        final copy = original.copyWith(
          agentId: 'agent-456',
          messages: [ChatMessage.user('Bye')],
          maxTokens: 200,
          stream: true,
          temperature: 0.9,
          frequencyPenalty: 0.5,
          reasoningEffort: ReasoningEffort.none,
        );
        expect(copy.agentId, 'agent-456');
        expect(copy.maxTokens, 200);
        expect(copy.stream, true);
        expect(copy.temperature, 0.9);
        expect(copy.frequencyPenalty, 0.5);
        expect(copy.reasoningEffort, ReasoningEffort.none);
      });

      test('sets nullable fields to null', () {
        final original = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello')],
          temperature: 0.5,
          reasoningEffort: ReasoningEffort.high,
          metadata: const {'key': 'value'},
        );
        final copy = original.copyWith(
          temperature: null,
          reasoningEffort: null,
          metadata: null,
        );
        expect(copy.agentId, 'agent-123');
        expect(copy.temperature, isNull);
        expect(copy.reasoningEffort, isNull);
        expect(copy.metadata, isNull);
      });
    });

    group('equality', () {
      test('equals with same fields', () {
        const request1 = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [],
          temperature: 0.5,
        );
        const request2 = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [],
          temperature: 0.5,
        );
        expect(request1, equals(request2));
        expect(request1.hashCode, request2.hashCode);
      });

      test('not equals with different fields', () {
        const request1 = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [],
          temperature: 0.5,
        );
        const request2 = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [],
          temperature: 0.9,
        );
        expect(request1, isNot(equals(request2)));
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
      test('includes all fields', () {
        final request = AgentCompletionRequest(
          agentId: 'agent-123',
          messages: [ChatMessage.user('Hello'), ChatMessage.assistant('Hi')],
        );
        final str = request.toString();
        expect(str, contains('AgentCompletionRequest('));
        expect(str, contains('agentId: agent-123'));
        expect(str, contains('messages: 2'));
        expect(str, contains('maxTokens: null'));
        expect(str, contains('frequencyPenalty: null'));
        expect(str, contains('reasoningEffort: null'));
      });
    });
  });
}
