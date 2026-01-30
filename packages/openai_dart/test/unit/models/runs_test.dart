// ignore_for_file: deprecated_member_use_from_same_package
import 'package:openai_dart/openai_dart.dart'
    show
        JsonObjectResponseFormat,
        JsonSchemaResponseFormat,
        TextResponseFormat,
        ToolChoiceAuto,
        ToolChoiceFunction,
        ToolChoiceNone,
        ToolChoiceRequired;
import 'package:openai_dart/openai_dart_assistants.dart';
import 'package:test/test.dart';

void main() {
  group('Run', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'run_abc123',
        'object': 'thread.run',
        'created_at': 1699472000,
        'thread_id': 'thread_xyz',
        'assistant_id': 'asst_abc',
        'status': 'completed',
        'model': 'gpt-4o',
        'instructions': 'Be helpful',
        'tools': [
          {'type': 'code_interpreter'},
        ],
        'metadata': {'key': 'value'},
        'temperature': 0.7,
        'top_p': 0.9,
        'tool_choice': 'auto',
        'response_format': {'type': 'text'},
      };

      final run = Run.fromJson(json);

      expect(run.id, 'run_abc123');
      expect(run.threadId, 'thread_xyz');
      expect(run.assistantId, 'asst_abc');
      expect(run.status, RunStatus.completed);
      expect(run.model, 'gpt-4o');
      expect(run.isComplete, isTrue);
      expect(run.toolChoice, isA<ToolChoiceAuto>());
      expect(run.responseFormat, isA<TextResponseFormat>());
    });

    test('fromJson parses function tool choice', () {
      final json = {
        'id': 'run_abc123',
        'object': 'thread.run',
        'created_at': 1699472000,
        'thread_id': 'thread_xyz',
        'assistant_id': 'asst_abc',
        'status': 'in_progress',
        'model': 'gpt-4o',
        'tools': <dynamic>[],
        'metadata': <String, dynamic>{},
        'tool_choice': {
          'type': 'function',
          'function': {'name': 'get_weather'},
        },
        'response_format': {
          'type': 'json_schema',
          'json_schema': {
            'name': 'weather',
            'schema': {'type': 'object'},
          },
        },
      };

      final run = Run.fromJson(json);

      expect(run.toolChoice, isA<ToolChoiceFunction>());
      expect((run.toolChoice! as ToolChoiceFunction).name, 'get_weather');
      expect(run.responseFormat, isA<JsonSchemaResponseFormat>());
    });

    test('toJson serializes correctly', () {
      const run = Run(
        id: 'run_abc123',
        object: 'thread.run',
        createdAt: 1699472000,
        threadId: 'thread_xyz',
        assistantId: 'asst_abc',
        status: RunStatus.completed,
        model: 'gpt-4o',
        tools: [],
        metadata: {},
        toolChoice: ToolChoiceRequired(),
        responseFormat: JsonObjectResponseFormat(),
      );

      final json = run.toJson();

      expect(json['id'], 'run_abc123');
      expect(json['tool_choice'], 'required');
      expect((json['response_format'] as Map)['type'], 'json_object');
    });

    test('status helpers work correctly', () {
      expect(
        const Run(
          id: 'run1',
          object: 'thread.run',
          createdAt: 0,
          threadId: 't1',
          assistantId: 'a1',
          status: RunStatus.queued,
          model: 'gpt-4o',
          tools: [],
          metadata: {},
        ).isProcessing,
        isTrue,
      );

      expect(
        const Run(
          id: 'run1',
          object: 'thread.run',
          createdAt: 0,
          threadId: 't1',
          assistantId: 'a1',
          status: RunStatus.requiresAction,
          model: 'gpt-4o',
          tools: [],
          metadata: {},
        ).requiresAction,
        isTrue,
      );

      expect(
        const Run(
          id: 'run1',
          object: 'thread.run',
          createdAt: 0,
          threadId: 't1',
          assistantId: 'a1',
          status: RunStatus.failed,
          model: 'gpt-4o',
          tools: [],
          metadata: {},
        ).isFailed,
        isTrue,
      );
    });
  });

  group('CreateRunRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'assistant_id': 'asst_abc',
        'model': 'gpt-4o',
        'instructions': 'Be helpful',
        'temperature': 0.8,
        'tool_choice': 'none',
        'response_format': {'type': 'json_object'},
      };

      final request = CreateRunRequest.fromJson(json);

      expect(request.assistantId, 'asst_abc');
      expect(request.model, 'gpt-4o');
      expect(request.toolChoice, isA<ToolChoiceNone>());
      expect(request.responseFormat, isA<JsonObjectResponseFormat>());
    });

    test('toJson serializes correctly', () {
      const request = CreateRunRequest(
        assistantId: 'asst_abc',
        model: 'gpt-4o',
        toolChoice: ToolChoiceAuto(),
        responseFormat: TextResponseFormat(),
      );

      final json = request.toJson();

      expect(json['assistant_id'], 'asst_abc');
      expect(json['tool_choice'], 'auto');
      expect((json['response_format'] as Map)['type'], 'text');
    });
  });

  group('RunStatus', () {
    test('fromJson parses all values', () {
      expect(RunStatus.fromJson('queued'), RunStatus.queued);
      expect(RunStatus.fromJson('in_progress'), RunStatus.inProgress);
      expect(RunStatus.fromJson('requires_action'), RunStatus.requiresAction);
      expect(RunStatus.fromJson('cancelling'), RunStatus.cancelling);
      expect(RunStatus.fromJson('cancelled'), RunStatus.cancelled);
      expect(RunStatus.fromJson('failed'), RunStatus.failed);
      expect(RunStatus.fromJson('completed'), RunStatus.completed);
      expect(RunStatus.fromJson('incomplete'), RunStatus.incomplete);
      expect(RunStatus.fromJson('expired'), RunStatus.expired);
    });

    test('toJson returns correct string', () {
      expect(RunStatus.inProgress.toJson(), 'in_progress');
      expect(RunStatus.requiresAction.toJson(), 'requires_action');
    });
  });

  group('RequiredAction', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'submit_tool_outputs',
        'submit_tool_outputs': {
          'tool_calls': [
            {
              'id': 'call_abc',
              'type': 'function',
              'function': {
                'name': 'get_weather',
                'arguments': '{"location": "NYC"}',
              },
            },
          ],
        },
      };

      final action = RequiredAction.fromJson(json);

      expect(action.type, 'submit_tool_outputs');
      expect(action.submitToolOutputs.toolCalls.length, 1);
      expect(action.submitToolOutputs.toolCalls[0].id, 'call_abc');
      expect(
        action.submitToolOutputs.toolCalls[0].function.name,
        'get_weather',
      );
    });
  });

  group('TruncationStrategy', () {
    test('fromJson parses correctly', () {
      final json = {'type': 'last_messages', 'last_messages': 10};

      final strategy = TruncationStrategy.fromJson(json);

      expect(strategy.type, 'last_messages');
      expect(strategy.lastMessages, 10);
    });

    test('toJson serializes correctly', () {
      const strategy = TruncationStrategy(type: 'auto');

      final json = strategy.toJson();

      expect(json['type'], 'auto');
      expect(json.containsKey('last_messages'), isFalse);
    });
  });

  group('ToolOutput', () {
    test('fromJson parses correctly', () {
      final json = {
        'tool_call_id': 'call_abc',
        'output': '{"temperature": 72}',
      };

      final output = ToolOutput.fromJson(json);

      expect(output.toolCallId, 'call_abc');
      expect(output.output, '{"temperature": 72}');
    });

    test('toJson serializes correctly', () {
      const output = ToolOutput(toolCallId: 'call_abc', output: 'result');

      final json = output.toJson();

      expect(json['tool_call_id'], 'call_abc');
      expect(json['output'], 'result');
    });
  });
}
