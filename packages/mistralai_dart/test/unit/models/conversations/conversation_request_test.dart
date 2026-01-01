import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StartConversationRequest', () {
    group('constructor', () {
      test('creates with required inputs', () {
        const request = StartConversationRequest(
          inputs: [MessageInputEntry(content: 'Hello')],
        );
        expect(request.inputs, hasLength(1));
        expect(request.model, isNull);
        expect(request.agentId, isNull);
        expect(request.store, isNull);
        expect(request.maxTokens, isNull);
      });

      test('creates with model', () {
        const request = StartConversationRequest(
          model: 'mistral-large-latest',
          inputs: [MessageInputEntry(content: 'Hi')],
          temperature: 0.7,
          maxTokens: 1000,
        );
        expect(request.model, 'mistral-large-latest');
        expect(request.temperature, 0.7);
        expect(request.maxTokens, 1000);
      });

      test('creates with agentId', () {
        const request = StartConversationRequest(
          agentId: 'agent-123',
          inputs: [MessageInputEntry(content: 'Hi')],
        );
        expect(request.agentId, 'agent-123');
      });

      test('creates with all parameters', () {
        const request = StartConversationRequest(
          model: 'mistral-large-latest',
          agentId: 'agent-1',
          inputs: [MessageInputEntry(content: 'Test')],
          store: true,
          maxTokens: 500,
          stop: ['END'],
          temperature: 0.5,
          topP: 0.9,
          tools: [Tool.webSearch()],
          toolChoice: ToolChoiceAuto(),
          responseFormat: ResponseFormatJsonObject(),
          randomSeed: 42,
          metadata: {'key': 'value'},
        );
        expect(request.store, true);
        expect(request.stop, ['END']);
        expect(request.topP, 0.9);
        expect(request.tools, hasLength(1));
        expect(request.toolChoice, isA<ToolChoiceAuto>());
        expect(request.responseFormat, isA<ResponseFormatJsonObject>());
        expect(request.randomSeed, 42);
        expect(request.metadata?['key'], 'value');
      });
    });

    group('factory withMessage', () {
      test('creates request with simple message', () {
        final request = StartConversationRequest.withMessage(
          model: 'mistral-small-latest',
          message: 'Hello world',
          maxTokens: 100,
        );
        expect(request.model, 'mistral-small-latest');
        expect(request.inputs, hasLength(1));
        expect(
          (request.inputs.first as MessageInputEntry).content,
          'Hello world',
        );
        expect(request.maxTokens, 100);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const request = StartConversationRequest(
          model: 'mistral-small-latest',
          inputs: [MessageInputEntry(content: 'Test')],
        );
        final json = request.toJson();
        expect(json['model'], 'mistral-small-latest');
        expect(json['inputs'], hasLength(1));
        expect(json.containsKey('agent_id'), isFalse);
        expect(json.containsKey('store'), isFalse);
      });

      test('serializes all fields', () {
        const request = StartConversationRequest(
          model: 'model-1',
          agentId: 'agent-1',
          inputs: [MessageInputEntry(content: 'X')],
          store: false,
          maxTokens: 200,
          stop: ['STOP'],
          temperature: 0.3,
          topP: 0.8,
          tools: [Tool.codeInterpreter()],
          toolChoice: ToolChoiceNone(),
          responseFormat: ResponseFormatText(),
          randomSeed: 123,
          metadata: {'env': 'test'},
        );
        final json = request.toJson();
        expect(json['model'], 'model-1');
        expect(json['agent_id'], 'agent-1');
        expect(json['store'], false);
        expect(json['max_tokens'], 200);
        expect(json['stop'], ['STOP']);
        expect(json['temperature'], 0.3);
        expect(json['top_p'], 0.8);
        expect(json['tools'], isList);
        expect(json['tool_choice'], isNotNull);
        expect(json['response_format'], isNotNull);
        expect(json['random_seed'], 123);
        expect(json['metadata'], {'env': 'test'});
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'model': 'mistral-large-latest',
          'inputs': [
            {'type': 'message.input', 'content': 'Hi', 'role': 'user'},
          ],
          'store': true,
          'max_tokens': 300,
          'temperature': 0.6,
        };
        final request = StartConversationRequest.fromJson(json);
        expect(request.model, 'mistral-large-latest');
        expect(request.inputs, hasLength(1));
        expect(request.store, true);
        expect(request.maxTokens, 300);
        expect(request.temperature, 0.6);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{'inputs': <dynamic>[]};
        final request = StartConversationRequest.fromJson(json);
        expect(request.model, isNull);
        expect(request.agentId, isNull);
        expect(request.inputs, isEmpty);
      });
    });

    group('copyWith', () {
      test('copies with changes', () {
        const original = StartConversationRequest(
          model: 'model-1',
          inputs: [MessageInputEntry(content: 'A')],
          temperature: 0.5,
        );
        final copy = original.copyWith(model: 'model-2', temperature: 0.8);
        expect(copy.model, 'model-2');
        expect(copy.temperature, 0.8);
        expect(copy.inputs, hasLength(1));
      });
    });

    group('equality', () {
      test('equals with same model and agentId', () {
        const req1 = StartConversationRequest(
          model: 'model-1',
          agentId: 'agent-1',
          inputs: [MessageInputEntry(content: 'A')],
        );
        const req2 = StartConversationRequest(
          model: 'model-1',
          agentId: 'agent-1',
          inputs: [MessageInputEntry(content: 'B')],
        );
        expect(req1, equals(req2));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const request = StartConversationRequest(
          model: 'mistral-large-latest',
          inputs: [
            MessageInputEntry(content: 'A'),
            MessageInputEntry(content: 'B'),
          ],
        );
        expect(
          request.toString(),
          'StartConversationRequest(model: mistral-large-latest, agentId: null, inputs: 2)',
        );
      });
    });
  });

  group('AppendConversationRequest', () {
    group('constructor', () {
      test('creates with required inputs', () {
        const request = AppendConversationRequest(
          inputs: [MessageInputEntry(content: 'Follow up')],
        );
        expect(request.inputs, hasLength(1));
        expect(request.store, isNull);
        expect(request.maxTokens, isNull);
      });

      test('creates with all parameters', () {
        const request = AppendConversationRequest(
          inputs: [MessageInputEntry(content: 'X')],
          store: true,
          maxTokens: 500,
          stop: ['END'],
          temperature: 0.7,
          topP: 0.95,
          tools: [Tool.webSearch()],
          toolChoice: ToolChoiceAuto(),
          responseFormat: ResponseFormatText(),
          randomSeed: 99,
        );
        expect(request.store, true);
        expect(request.maxTokens, 500);
        expect(request.stop, ['END']);
        expect(request.temperature, 0.7);
        expect(request.topP, 0.95);
      });
    });

    group('factory withMessage', () {
      test('creates with simple message', () {
        final request = AppendConversationRequest.withMessage(
          message: 'Continue please',
          maxTokens: 200,
        );
        expect(request.inputs, hasLength(1));
        expect(
          (request.inputs.first as MessageInputEntry).content,
          'Continue please',
        );
        expect(request.maxTokens, 200);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const request = AppendConversationRequest(
          inputs: [MessageInputEntry(content: 'Test')],
          store: true,
          maxTokens: 150,
        );
        final json = request.toJson();
        expect(json['inputs'], hasLength(1));
        expect(json['store'], true);
        expect(json['max_tokens'], 150);
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'inputs': [
            {'type': 'message.input', 'content': 'Hi', 'role': 'user'},
          ],
          'store': false,
          'temperature': 0.5,
        };
        final request = AppendConversationRequest.fromJson(json);
        expect(request.inputs, hasLength(1));
        expect(request.store, false);
        expect(request.temperature, 0.5);
      });
    });

    group('copyWith', () {
      test('copies with changes', () {
        const original = AppendConversationRequest(
          inputs: [MessageInputEntry(content: 'A')],
          temperature: 0.5,
        );
        final copy = original.copyWith(temperature: 0.9);
        expect(copy.temperature, 0.9);
        expect(copy.inputs, hasLength(1));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const request = AppendConversationRequest(
          inputs: [MessageInputEntry(content: 'X')],
        );
        expect(request.toString(), 'AppendConversationRequest(inputs: 1)');
      });
    });
  });

  group('RestartConversationRequest', () {
    group('constructor', () {
      test('creates with required entryId', () {
        const request = RestartConversationRequest(entryId: 'entry-123');
        expect(request.entryId, 'entry-123');
        expect(request.store, isNull);
        expect(request.maxTokens, isNull);
      });

      test('creates with all parameters', () {
        const request = RestartConversationRequest(
          entryId: 'entry-456',
          store: true,
          maxTokens: 400,
          stop: ['DONE'],
          temperature: 0.6,
          topP: 0.85,
          tools: [Tool.codeInterpreter()],
          randomSeed: 77,
        );
        expect(request.entryId, 'entry-456');
        expect(request.store, true);
        expect(request.maxTokens, 400);
        expect(request.stop, ['DONE']);
        expect(request.temperature, 0.6);
        expect(request.randomSeed, 77);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const request = RestartConversationRequest(
          entryId: 'entry-789',
          store: false,
          temperature: 0.4,
        );
        final json = request.toJson();
        expect(json['entry_id'], 'entry-789');
        expect(json['store'], false);
        expect(json['temperature'], 0.4);
      });
    });

    group('fromJson', () {
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'entry_id': 'entry-abc',
          'store': true,
          'max_tokens': 250,
        };
        final request = RestartConversationRequest.fromJson(json);
        expect(request.entryId, 'entry-abc');
        expect(request.store, true);
        expect(request.maxTokens, 250);
      });

      test('handles missing entry_id', () {
        final json = <String, dynamic>{};
        final request = RestartConversationRequest.fromJson(json);
        expect(request.entryId, '');
      });
    });

    group('copyWith', () {
      test('copies with changes', () {
        const original = RestartConversationRequest(
          entryId: 'entry-1',
          temperature: 0.5,
        );
        final copy = original.copyWith(entryId: 'entry-2', maxTokens: 100);
        expect(copy.entryId, 'entry-2');
        expect(copy.maxTokens, 100);
        expect(copy.temperature, 0.5);
      });
    });

    group('equality', () {
      test('equals with same entryId', () {
        const req1 = RestartConversationRequest(entryId: 'entry-1');
        const req2 = RestartConversationRequest(
          entryId: 'entry-1',
          temperature: 0.9,
        );
        expect(req1, equals(req2));
      });

      test('not equals with different entryId', () {
        const req1 = RestartConversationRequest(entryId: 'entry-1');
        const req2 = RestartConversationRequest(entryId: 'entry-2');
        expect(req1, isNot(equals(req2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const request = RestartConversationRequest(entryId: 'entry-xyz');
        expect(
          request.toString(),
          'RestartConversationRequest(entryId: entry-xyz)',
        );
      });
    });
  });
}
