import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_INPUT_WIRE';
Matcher _safe(String field) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(field))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));

void main() {
  group('Successful typed payload replacement copies', () {
    test('required function arguments string changes exact wire', () {
      final model = LiveInputFunctionToolCall.fromJson(const {
        'type': 'function_call',
        'call_id': 'call',
        'name': 'function',
        'arguments': 'original',
      });
      final copy = model.copyWith(arguments: 'replacement');
      expect(copy.arguments, 'replacement');
      expect(copy.toJson(), {...model.toJson(), 'arguments': 'replacement'});
      expect(model.arguments, 'original');
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
    });
    test('message phase enum wrapper changes commentary to final answer', () {
      final model = LiveInputMessagePhase.fromJson('commentary');
      final copy = model.copyWith(value: 'final_answer');
      expect(copy.value, 'final_answer');
      expect(copy.toJson(), 'final_answer');
      expect(model.toJson(), 'commentary');
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
    });
    test(
      'easy message content changes from string to typed input-text list',
      () {
        final model = LiveEasyInputMessage.fromJson(const {
          'role': 'user',
          'content': 'original',
        });
        final text = LiveInputTextContent.fromJson(const {
          'type': 'input_text',
          'text': 'replacement',
        });
        final copy = model.copyWith(content: [text]);
        expect(copy.content, isA<LiveEasyInputMessageContentValueBranch1>());
        expect(copy.toJson(), {
          'role': 'user',
          'content': [text.toJson()],
        });
        expect(model.toJson()['content'], 'original');
        expect(copy, isNot(model));
        expect(copy.hashCode, isNot(model.hashCode));
      },
    );
    test('vector-store attribute finite map replacement is detached', () {
      final model = LiveInputVectorStoreFileAttributes.fromJson(const {
        'label': 'original',
      });
      final source = <String, dynamic>{
        'label': 'replacement',
        'rank': 2,
        'active': false,
      };
      final copy = model.copyWith(value: source);
      source['label'] = 'mutated';
      expect(copy.toJson(), {
        'label': 'replacement',
        'rank': 2,
        'active': false,
      });
      expect(model.toJson(), {'label': 'original'});
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
    });
    test('computer-call output nested screenshot replacement is exact', () {
      final model = LiveInputComputerCallOutputItemParam.fromJson(const {
        'type': 'computer_call_output',
        'call_id': 'call',
        'output': {'type': 'computer_screenshot', 'file_id': 'original'},
      });
      final output = LiveInputComputerScreenshotImage.fromJson(const {
        'type': 'computer_screenshot',
        'image_url': 'replacement',
      });
      final copy = model.copyWith(output: output);
      expect(copy.output, output);
      expect(copy.toJson()['output'], output.toJson());
      expect(model.output.fileId, 'original');
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
    });
    test('inline string branch copy replaces typed scalar value', () {
      final model = LiveEasyInputMessageContentValueBranch0.fromJson(
        'original',
      );
      final copy = model.copyWith(value: 'replacement');
      expect(copy.value, 'replacement');
      expect(copy.toJson(), 'replacement');
      expect(model.toJson(), 'original');
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
    });
    test(
      'inline list branch copy accepts typed elements and changes exact wire',
      () {
        final model = LiveEasyInputMessageContentValueBranch1.fromJson(const [
          {'type': 'input_text', 'text': 'original'},
        ]);
        final text = LiveInputTextContent.fromJson(const {
          'type': 'input_text',
          'text': 'replacement',
        });
        final copy = model.copyWith(value: [text]);
        expect(copy.value.value.single.toJson(), text.toJson());
        expect(copy.toJson(), [text.toJson()]);
        expect(model.toJson(), [
          {'type': 'input_text', 'text': 'original'},
        ]);
        expect(copy, isNot(model));
        expect(copy.hashCode, isNot(model.hashCode));
      },
    );
  });
  group('Canonical overlapping InputItem branch admission', () {
    for (final shape in <Map<String, dynamic>>[
      {
        'role': 'assistant',
        'content': _private,
        'id': 'future-id',
        'status': false,
      },
      {
        'role': 'assistant',
        'content': [
          {'type': 'input_text', 'text': _private},
        ],
        'id': 1,
        'status': null,
      },
      {
        'role': 'user',
        'content': _private,
        'id': {'future': true},
        'status': 'future-status',
      },
      {
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': _private},
        ],
        'status': 'future-status',
      },
    ]) {
      test(
        'open EasyInputMessage metadata ${shape['role']}/${shape['content'].runtimeType}',
        () {
          final model = LiveInputItem.fromJson(shape);
          expect(model, isA<LiveEasyInputMessage>());
          expect(model.toJson(), shape);
          expect(model.toString(), isNot(contains(_private)));
          expect(LiveEasyInputMessage.fromJson(shape).toJson(), shape);
        },
      );
    }
    test(
      'nullable reference type wins when the open message candidate fails',
      () {
        final wire = {
          'type': null,
          'id': 'ref',
          'role': 'assistant',
          'content': _private,
        };
        final model = LiveInputItem.fromJson(wire);
        expect(model, isA<LiveInputItemReferenceParam>());
        expect(model.toJson(), wire);
        final reference = model as LiveInputItemReferenceParam;
        expect(reference.hasType, isTrue);
        expect(reference.type, isNull);
        expect(reference.copyWith(clearType: true).toJson(), {
          'id': 'ref',
          'role': 'assistant',
          'content': _private,
        });
      },
    );
    test(
      'typeless reference may carry arbitrary finite future message metadata',
      () {
        final wire = {
          'id': 'ref',
          'role': false,
          'content': {'future': true},
        };
        expect(
          LiveInputItem.fromJson(wire),
          isA<LiveInputItemReferenceParam>(),
        );
        expect(LiveInputItem.fromJson(wire).toJson(), wire);
      },
    );
    test('structured user input prefers its valid InputMessage branch', () {
      final wire = {
        'type': 'message',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': _private},
        ],
      };
      final model = LiveInputItem.fromJson(wire);
      expect(model, isA<LiveInputMessage>());
      expect(model.toJson(), wire);
      // This exact declared-branch shape overlaps EasyInputMessage at the
      // exclusive root oneOf. Compatibility is reported separately.
      expect(LiveEasyInputMessage.fromJson(wire).toJson(), wire);
    });
    test('assistant output preserves its specific required output fields', () {
      final wire = {
        'type': 'message',
        'role': 'assistant',
        'id': 'out',
        'status': 'completed',
        'content': [
          {
            'type': 'output_text',
            'text': _private,
            'annotations': <Object?>[],
            'logprobs': <Object?>[],
          },
        ],
      };
      expect(LiveInputItem.fromJson(wire), isA<LiveInputOutputMessage>());
      expect(LiveInputItem.fromJson(wire).toJson(), wire);
    });
    for (final wire in <Map<String, dynamic>>[
      {'type': 'message', 'role': 'invalid', 'content': _private},
      {
        'type': 'message',
        'role': 'assistant',
        'id': 'out',
        'status': 'future',
        'content': [
          {
            'type': 'output_text',
            'text': _private,
            'annotations': <Object?>[],
            'logprobs': <Object?>[],
          },
        ],
      },
      {
        'type': 'message',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': 5},
        ],
      },
      {'type': _private, 'id': 'ref'},
    ]) {
      test(
        'no known malformed branch falls back ${wire['role']}/${wire['type']}',
        () {
          expect(() => LiveInputItem.fromJson(wire), throwsA(_safe('Live')));
        },
      );
    }
  });

  group('Canonical required keys without property declarations', () {
    for (final value in <Object?>[
      null,
      5,
      _private,
      {
        'future': [false, null],
      },
    ]) {
      test(
        'MCP request_id retains finite ${value.runtimeType} without scalar invention',
        () {
          final wire = {
            'type': 'mcp_approval_response',
            'request_id': value,
            'approval_request_id': 'approval',
            'approve': false,
          };
          final model = LiveInputMCPApprovalResponse.fromJson(wire);
          expect(model.requestId, value);
          expect(model.toJson(), wire);
          expect(model.copyWith(requestId: value), model);
          expect(
            () => LiveInputMCPApprovalResponse.fromJson(
              {...wire}..remove('request_id'),
            ),
            throwsA(_safe('request_id')),
          );
        },
      );
      test(
        'local shell call_id retains finite ${value.runtimeType} without scalar invention',
        () {
          final wire = {
            'type': 'local_shell_call_output',
            'id': 'out',
            'call_id': value,
            'output': _private,
          };
          final model = LiveInputLocalShellToolCallOutput.fromJson(wire);
          expect(model.callId, value);
          expect(model.toJson(), wire);
          expect(model.copyWith(callId: value), model);
          expect(
            () => LiveInputLocalShellToolCallOutput.fromJson(
              {...wire}..remove('call_id'),
            ),
            throwsA(_safe('call_id')),
          );
        },
      );
    }
  });

  group('Copy normalization keeps safe cycle and finite admission', () {
    test('cyclic output list cannot overflow the stack', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      final model = LiveInputFunctionCallOutputItemParam.fromJson(const {
        'type': 'function_call_output',
        'call_id': _private,
        'output': _private,
      });
      expect(() => model.copyWith(output: cycle), throwsA(_safe('output')));
      expect(model.output.toJson(), _private);
    });
    test('cyclic output map cannot overflow the stack or leak its key', () {
      final cycle = <String, dynamic>{};
      cycle[_private] = cycle;
      final model = LiveInputFunctionCallOutputItemParam.fromJson(const {
        'type': 'function_call_output',
        'output': _private,
      });
      expect(() => model.copyWith(output: cycle), throwsA(_safe('output')));
      expect(model.toJson()['output'], _private);
    });
    test('cyclic alias value fails before candidate traversal', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      expect(
        () => LiveInputComputerActionList.fromJson(cycle),
        throwsA(_safe('LiveInputComputerActionList')),
      );
      final model = LiveInputComputerActionList.fromJson(const []);
      expect(() => model.copyWith(value: cycle), throwsA(_safe('value')));
    });
    test('nested known discriminator failure retains its array index', () {
      expect(
        () => LiveInputCompoundFilter.fromJson(const {
          'type': 'and',
          'filters': [
            {'type': 'eq', 'key': 'valid', 'value': 1},
            {'type': 'eq', 'key': 5, 'value': 1},
          ],
        }),
        throwsA(_safe('filters[1]')),
      );
    });
    for (final literal in ['Infinity', '-Infinity', 'NaN']) {
      test('runtime $literal integer and numeric fields stay finite', () {
        final dynamic value = num.parse(literal);
        expect(
          () => LiveInputClickParam.fromJson({
            'type': 'click',
            'button': 'left',
            'x': value,
            'y': 0,
          }),
          throwsA(_safe('x')),
        );
        expect(
          () => LiveInputClickParam.fromJson(const {
            'type': 'click',
            'button': 'left',
            'x': 0,
            'y': 0,
          }).copyWith(x: value),
          throwsA(_safe('x')),
        );
        expect(
          () => LiveInputFunctionShellCallOutputItemParam.fromJson({
            'type': 'shell_call_output',
            'call_id': 'call',
            'output': const <Object?>[],
            'max_output_length': value,
          }),
          throwsA(_safe('max_output_length')),
        );
        expect(
          () => LiveInputFunctionShellCallOutputItemParam.fromJson(const {
            'type': 'shell_call_output',
            'call_id': 'call',
            'output': <Object?>[],
          }).copyWith(maxOutputLength: value),
          throwsA(_safe('max_output_length')),
        );
      });
    }
  });
}
