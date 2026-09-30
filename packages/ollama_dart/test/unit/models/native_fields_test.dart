import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  const controlFields = <String, dynamic>{'truncate': false, 'shift': true};
  const associationFields = <String, dynamic>{
    'tool_name': 'weather',
    'tool_call_id': 'call_1',
  };
  const toolJson = <String, dynamic>{
    'id': 'call_1',
    'function': {
      'index': 1,
      'name': 'weather',
      'arguments': {
        'location': {'city': 'Paris'},
      },
    },
  };
  const cachedFields = <String, dynamic>{'prompt_eval_cached_count': 0};
  const generatedFields = <String, dynamic>{
    ...cachedFields,
    'tool_calls': [toolJson],
  };
  const streamFields = <String, dynamic>{
    ...generatedFields,
    'context': [1, 2, 3],
    'logprobs': [
      {
        'token': 'Paris',
        'logprob': -0.2,
        'bytes': [80],
        'top_logprobs': [
          {'token': 'Rome', 'logprob': -1.0},
        ],
      },
    ],
  };

  optionalContracts<ChatRequest>(
    'ChatRequest context controls',
    fromJson: ChatRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(truncate: null, shift: null),
    base: const {'model': 'm', 'messages': <dynamic>[]},
    fields: controlFields,
  );
  optionalContracts<GenerateRequest>(
    'GenerateRequest context controls',
    fromJson: GenerateRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(truncate: null, shift: null),
    base: const {'model': 'm'},
    fields: controlFields,
  );
  optionalContracts<ChatMessage>(
    'ChatMessage tool association',
    fromJson: ChatMessage.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(toolName: null, toolCallId: null),
    base: const {'role': 'tool', 'content': 'Sunny'},
    fields: associationFields,
  );
  optionalContracts<ChatResponseMessage>(
    'ChatResponseMessage tool association',
    fromJson: ChatResponseMessage.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(toolName: null, toolCallId: null),
    fields: associationFields,
  );
  optionalContracts<ToolCall>(
    'ToolCall identifier',
    fromJson: ToolCall.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(id: null),
    base: const {
      'function': {'name': 'weather'},
    },
    fields: const {'id': 'call_1'},
  );
  optionalContracts<ToolCallFunction>(
    'ToolCallFunction index',
    fromJson: ToolCallFunction.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(index: null),
    base: const {'name': 'weather'},
    fields: const {'index': 0},
  );
  optionalContracts<ChatResponse>(
    'ChatResponse cached prompt count',
    fromJson: ChatResponse.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(promptEvalCachedCount: null),
    fields: cachedFields,
  );
  optionalContracts<ChatStreamEvent>(
    'ChatStreamEvent cached prompt count',
    fromJson: ChatStreamEvent.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(promptEvalCachedCount: null),
    fields: cachedFields,
  );
  optionalContracts<GenerateResponse>(
    'GenerateResponse tool calls and cached prompt count',
    fromJson: GenerateResponse.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) =>
        value.copyWith(promptEvalCachedCount: null, toolCalls: null),
    fields: generatedFields,
  );
  optionalContracts<GenerateStreamEvent>(
    'GenerateStreamEvent final context, logprobs, tool calls, cached count',
    fromJson: GenerateStreamEvent.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(
      promptEvalCachedCount: null,
      toolCalls: null,
      context: null,
      logprobs: null,
    ),
    fields: streamFields,
  );
  optionalContracts<ModelDetails>(
    'ModelDetails dimensions',
    fromJson: ModelDetails.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) =>
        value.copyWith(contextLength: null, embeddingLength: null),
    fields: const {'context_length': 32768, 'embedding_length': 4096},
  );
  optionalContracts<ModelSummary>(
    'ModelSummary capabilities',
    fromJson: ModelSummary.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(capabilities: null),
    fields: const {
      'capabilities': ['completion', 'future-capability'],
    },
  );
  optionalContracts<ShowRequest>(
    'ShowRequest overrides',
    fromJson: ShowRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(system: null, options: null),
    base: const {'model': 'm', 'verbose': true},
    fields: const {
      'system': 'Be concise',
      'options': {'temperature': 0.5},
    },
  );
  optionalContracts<ShowResponse>(
    'ShowResponse full model metadata',
    fromJson: ShowResponse.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(
      modelfile: null,
      system: null,
      renderer: null,
      parser: null,
      remoteModel: null,
      remoteHost: null,
      requires: null,
      messages: null,
      projectorInfo: null,
      tensors: null,
      thinking: null,
    ),
    base: const {
      'details': {'context_length': 32768},
    },
    fields: const {
      'modelfile': 'FROM m',
      'system': 'Be concise',
      'renderer': 'qwen3.8',
      'parser': 'qwen3.8',
      'remote_model': 'm:cloud',
      'remote_host': 'https://ollama.com',
      'requires': '0.35.0',
      'messages': [
        {'role': 'system', 'content': 'Be concise'},
      ],
      'projector_info': {
        'nested': {
          'dimensions': <int>[1, 2],
        },
      },
      'tensors': [
        {
          'name': 'weight',
          'type': 'F32',
          'shape': <int>[2, 3],
        },
      ],
      'thinking': {
        'values': <Object>[false, 'low', 'xhigh'],
        'default': 'xhigh',
      },
    },
  );

  test('show verbose participates in equality', () {
    expect(
      const ShowRequest(model: 'm', verbose: true),
      isNot(const ShowRequest(model: 'm', verbose: false)),
    );
  });

  test('context control copyWith replaces false and true explicitly', () {
    const chat = ChatRequest(model: 'm', messages: [], truncate: true);
    expect(chat.copyWith(truncate: false, shift: true).truncate, isFalse);
    expect(chat.copyWith(truncate: false, shift: true).shift, isTrue);
    const generate = GenerateRequest(model: 'm', shift: true);
    expect(generate.copyWith(truncate: true, shift: false).truncate, isTrue);
    expect(generate.copyWith(truncate: true, shift: false).shift, isFalse);
  });

  test(
    'tool replay retains reasoning, text, identities and nested arguments',
    () {
      final responseMessage = ChatResponseMessage.fromJson(const {
        'role': 'assistant',
        'content': 'Checking the weather',
        'thinking': 'A tool is needed',
        'tool_calls': [toolJson],
      });
      final replay = ChatMessage.assistant(
        responseMessage.content ?? '',
        thinking: responseMessage.thinking,
        toolCalls: responseMessage.toolCalls,
      );
      const result = ChatMessage.tool(
        'Sunny',
        toolName: 'weather',
        toolCallId: 'call_1',
      );
      final request = ChatRequest(model: 'm', messages: [replay, result]);
      final roundTrip = ChatRequest.fromJson(request.toJson());
      expect(roundTrip, request);
      expect(roundTrip.hashCode, request.hashCode);
      expect(roundTrip.messages.first.thinking, 'A tool is needed');
      expect(roundTrip.messages.first.content, 'Checking the weather');
      expect(roundTrip.messages.first.toolCalls?.single.id, 'call_1');
      expect(roundTrip.messages.first.toolCalls?.single.function?.index, 1);
      expect(roundTrip.messages.last.toolName, 'weather');
      expect(roundTrip.messages.last.toolCallId, 'call_1');
      expect(responseMessage.copyWith(content: null).content, isNull);
      expect(const ChatResponseMessage().content, isNull);
    },
  );

  test('stream copyWith exposes existing fields as well as additions', () {
    const chat = ChatStreamEvent(model: 'm', done: true);
    expect(chat.copyWith(model: null, done: false).model, isNull);
    expect(chat.copyWith(model: null, done: false).done, isFalse);
    const generated = GenerateStreamEvent(model: 'm', image: 'encoded');
    expect(generated.copyWith(model: null, image: null).toJson(), isEmpty);
    expect(generated.copyWith(done: true).done, isTrue);
  });

  group('new collection snapshots on const-compatible models', () {
    test('ModelSummary capabilities freeze decoded and copied values', () {
      final source = ['completion'];
      final decoded = ModelSummary.fromJson({'capabilities': source});
      final direct = ModelSummary(capabilities: source);
      final unchanged = direct.copyWith();
      final replaced = const ModelSummary().copyWith(capabilities: source);
      source.clear();
      expect(direct.capabilities, isEmpty);
      for (final value in [decoded, unchanged, replaced]) {
        expect(value.capabilities, ['completion']);
        expect(value.capabilities!.clear, throwsUnsupportedError);
      }
    });

    test('GenerateResponse tool calls freeze decoded and copied lists', () {
      final jsonCalls = <Map<String, dynamic>>[
        {'id': 'call_1'},
      ];
      final source = <ToolCall>[const ToolCall(id: 'call_1')];
      final decoded = GenerateResponse.fromJson({'tool_calls': jsonCalls});
      final direct = GenerateResponse(toolCalls: source);
      final unchanged = direct.copyWith();
      final replaced = const GenerateResponse().copyWith(toolCalls: source);
      jsonCalls.clear();
      source.clear();
      expect(direct.toolCalls, isEmpty);
      for (final value in [decoded, unchanged, replaced]) {
        expect(value.toolCalls!.single.id, 'call_1');
        expect(value.toolCalls!.clear, throwsUnsupportedError);
      }
    });

    test('GenerateStreamEvent freezes all new decoded and copied lists', () {
      final jsonCalls = <Map<String, dynamic>>[
        {'id': 'call_1'},
      ];
      final jsonLogprobs = <Map<String, dynamic>>[
        {'token': 'token'},
      ];
      final calls = <ToolCall>[const ToolCall(id: 'call_1')];
      final context = [1, 2];
      final logprobs = <Logprob>[const Logprob(token: 'token')];
      final decoded = GenerateStreamEvent.fromJson({
        'tool_calls': jsonCalls,
        'context': context,
        'logprobs': jsonLogprobs,
      });
      final direct = GenerateStreamEvent(
        toolCalls: calls,
        context: context,
        logprobs: logprobs,
      );
      final unchanged = direct.copyWith();
      final replaced = const GenerateStreamEvent().copyWith(
        toolCalls: calls,
        context: context,
        logprobs: logprobs,
      );
      jsonCalls.clear();
      jsonLogprobs.clear();
      calls.clear();
      context.clear();
      logprobs.clear();
      expect(direct.toolCalls, isEmpty);
      expect(direct.context, isEmpty);
      expect(direct.logprobs, isEmpty);
      for (final value in [decoded, unchanged, replaced]) {
        expect(value.toolCalls!.single.id, 'call_1');
        expect(value.context, [1, 2]);
        expect(value.logprobs!.single.token, 'token');
        expect(value.toolCalls!.clear, throwsUnsupportedError);
        expect(value.context!.clear, throwsUnsupportedError);
        expect(value.logprobs!.clear, throwsUnsupportedError);
      }
    });

    test('ShowResponse freezes new lists and nested projector JSON', () {
      final jsonMessages = <Map<String, dynamic>>[
        {'role': 'system', 'content': 'Be concise'},
      ];
      final jsonTensors = <Map<String, dynamic>>[
        {
          'name': 'weight',
          'type': 'F32',
          'shape': [2, 3],
        },
      ];
      final messages = <ChatMessage>[const ChatMessage.system('Be concise')];
      final tensors = <ModelTensor>[
        ModelTensor(name: 'weight', type: 'F32', shape: const [2, 3]),
      ];
      final dimensions = [2, 3];
      final nested = <String, dynamic>{'dimensions': dimensions};
      final projectorInfo = <String, dynamic>{'nested': nested};
      final decoded = ShowResponse.fromJson({
        'messages': jsonMessages,
        'tensors': jsonTensors,
        'projector_info': projectorInfo,
      });
      final direct = ShowResponse(
        messages: messages,
        tensors: tensors,
        projectorInfo: projectorInfo,
      );
      final unchanged = direct.copyWith();
      final replaced = const ShowResponse().copyWith(
        messages: messages,
        tensors: tensors,
        projectorInfo: projectorInfo,
      );
      jsonMessages.clear();
      jsonTensors.clear();
      messages.clear();
      tensors.clear();
      dimensions.clear();
      nested.clear();
      projectorInfo.clear();
      expect(direct.messages, isEmpty);
      expect(direct.tensors, isEmpty);
      expect(direct.projectorInfo, isEmpty);
      for (final value in [decoded, unchanged, replaced]) {
        expect(value.messages!.single.content, 'Be concise');
        expect(value.tensors!.single.shape, [2, 3]);
        expect(value.projectorInfo, {
          'nested': {
            'dimensions': [2, 3],
          },
        });
        expect(value.messages!.clear, throwsUnsupportedError);
        expect(value.tensors!.clear, throwsUnsupportedError);
        expect(value.projectorInfo!.clear, throwsUnsupportedError);
        final copiedNested =
            value.projectorInfo!['nested'] as Map<String, dynamic>;
        expect(copiedNested.clear, throwsUnsupportedError);
        final copiedDimensions = copiedNested['dimensions'] as List;
        expect(copiedDimensions.clear, throwsUnsupportedError);
      }
    });
  });

  group('ModelThinking', () {
    for (final name in ['high', 'xhigh']) {
      test('$name string control preserves discovery round-trip equality', () {
        final thinking = ModelThinking(
          values: [ThinkValue.string(name)],
          defaultValue: ThinkValue.string(name),
        );
        final decoded = ModelThinking.fromJson(thinking.toJson());
        expect(decoded == thinking, isTrue);
        expect(thinking == decoded, isTrue);
        expect(decoded.hashCode, thinking.hashCode);
        expect(decoded.toJson(), thinking.toJson());
      });
    }

    test('preserves boolean and model-defined string controls', () {
      const json = <String, dynamic>{
        'values': <Object>[false, 'medium', 'xhigh', 'future-level'],
        'default': 'xhigh',
      };
      final thinking = ModelThinking.fromJson(json);
      expect(thinking.values[0], const ThinkEnabled(false));
      expect(thinking.values[1], const ThinkWithLevel(ThinkLevel.medium));
      expect(thinking.values[2], const ThinkWithString('xhigh'));
      expect(thinking.defaultValue, const ThinkWithString('xhigh'));
      expect(thinking.toJson(), json);
      expect(ModelThinking.fromJson(thinking.toJson()), thinking);
      expect(ModelThinking.fromJson(json).hashCode, thinking.hashCode);
      expect(thinking.copyWith(), thinking);
      expect(
        thinking.copyWith(defaultValue: const ThinkEnabled(false)),
        isNot(thinking),
      );
      expect(
        thinking.copyWith(values: const [ThinkEnabled(false)]),
        isNot(thinking),
      );
      expect(thinking.toString(), contains('values:'));
      expect(thinking.toString(), contains('defaultValue:'));
    });

    test('freezes constructor and copyWith collections', () {
      final source = <ThinkValue>[const ThinkEnabled(true)];
      final value = ModelThinking(
        values: source,
        defaultValue: const ThinkEnabled(true),
      );
      source.clear();
      expect(value.values, hasLength(1));
      expect(value.values.clear, throwsUnsupportedError);
      final replacement = <ThinkValue>[const ThinkEnabled(false)];
      final copy = value.copyWith(values: replacement);
      replacement.clear();
      expect(copy.values, hasLength(1));
      expect(copy.values.clear, throwsUnsupportedError);
    });

    for (final json in <Map<String, dynamic>>[
      {},
      {'values': <Object>[]},
      {'values': 'not an array', 'default': true},
      {
        'values': <Object>[1],
        'default': true,
      },
      {
        'values': <Object?>[null],
        'default': true,
      },
      {
        'values': <Object>[true],
        'default': 1,
      },
      {
        'values': <Object>[true],
        'default': null,
      },
    ]) {
      test('rejects malformed discovery descriptor $json', () {
        expect(() => ModelThinking.fromJson(json), throwsFormatException);
      });
    }
  });

  group('ModelTensor', () {
    test('round-trip, copies and all-field equality', () {
      const json = <String, dynamic>{
        'name': 'weight',
        'type': 'F32',
        'shape': <int>[2, 3],
      };
      final tensor = ModelTensor.fromJson(json);
      expect(tensor.toJson(), json);
      expect(ModelTensor.fromJson(json), tensor);
      expect(ModelTensor.fromJson(json).hashCode, tensor.hashCode);
      expect(tensor.copyWith(), tensor);
      expect(tensor.copyWith(name: 'other'), isNot(tensor));
      expect(tensor.copyWith(type: 'Q4_0'), isNot(tensor));
      expect(tensor.copyWith(shape: [3, 2]), isNot(tensor));
      expect(tensor.toString(), contains('shape: [2, 3]'));
    });

    test('freezes constructor and copyWith dimensions', () {
      final dimensions = [2, 3];
      final tensor = ModelTensor(
        name: 'weight',
        type: 'F32',
        shape: dimensions,
      );
      dimensions.clear();
      expect(tensor.shape, [2, 3]);
      expect(tensor.shape.clear, throwsUnsupportedError);
      final replacement = [4];
      final copy = tensor.copyWith(shape: replacement);
      replacement.clear();
      expect(copy.shape, [4]);
      expect(copy.shape.clear, throwsUnsupportedError);
    });

    for (final json in <Map<String, dynamic>>[
      {},
      {'name': 'weight', 'type': 'F32'},
      {'name': 1, 'type': 'F32', 'shape': <int>[]},
      {
        'name': 'weight',
        'type': 'F32',
        'shape': <double>[1.5],
      },
    ]) {
      test('rejects malformed tensor $json', () {
        expect(() => ModelTensor.fromJson(json), throwsFormatException);
      });
    }
  });
}

void optionalContracts<T>(
  String name, {
  required T Function(Map<String, dynamic>) fromJson,
  required Map<String, dynamic> Function(T) toJson,
  required T Function(T) copy,
  required T Function(T) clear,
  Map<String, dynamic> base = const {},
  required Map<String, dynamic> fields,
}) {
  group(name, () {
    test('round-trips all added fields with content equality', () {
      final json = <String, dynamic>{...base, ...fields};
      final value = fromJson(json);
      expect(toJson(value), json);
      expect(fromJson(toJson(value)), value);
      expect(fromJson(json).hashCode, value.hashCode);
      expect(copy(value), value);
      for (final key in fields.keys) {
        final withoutField = Map<String, dynamic>.of(json)..remove(key);
        expect(value, isNot(fromJson(withoutField)), reason: key);
        final fieldName = key.replaceAllMapped(
          RegExp('_([a-z])'),
          (match) => match[1]!.toUpperCase(),
        );
        expect(value.toString(), contains('$fieldName:'), reason: key);
      }
    });
    test('omits absent optional fields and copyWith clears them', () {
      expect(toJson(fromJson(base)), base);
      final value = fromJson(<String, dynamic>{...base, ...fields});
      expect(toJson(clear(value)), base);
    });
  });
}
