import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _id = ResponsesSteerIdentity(
  id: 'steer_private',
  previousResponseId: 'resp_private',
);
const _error = ResponsesSteerError(
  code: 'future_private_code',
  message: 'private message',
);
const _stubs = <Map<String, dynamic>>[
  {
    'type': 'function_call_output',
    'call_id': 'call_private',
    'name': 'lookup.private',
  },
  {'type': 'custom_tool_call_output', 'call_id': 'call_private'},
  {'type': 'computer_call_output', 'call_id': 'call_private'},
  {'type': 'shell_call_output', 'call_id': 'call_private'},
  {'type': 'apply_patch_call_output', 'call_id': 'call_private'},
  {
    'type': 'tool_search_output',
    'call_id': 'call_private',
    'execution': 'client',
  },
  {'type': 'mcp_approval_response', 'approval_request_id': 'approval_private'},
];

Map<String, dynamic> _fresh(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

Map<String, dynamic> _server(String kind) => {
  'type': 'response.steer.$kind',
  'sequence_number': 3,
  'stream_id': 'returned private lane / é',
  'steer': <String, dynamic>{
    'id': 'steer_private',
    'previous_response_id': 'resp_private',
    if (kind == 'failed')
      'input': {
        'private': <dynamic>[null, false, 1.25],
      },
    'future_steer': {
      'nested': <dynamic>[1, null],
    },
  },
  if (kind == 'pending') 'reason': 'future_private_reason',
  if (kind == 'pending') 'required_input': _stubs,
  if (kind == 'failed')
    'error': <String, dynamic>{
      'type': 'invalid_request_error',
      'code': 'future_private_code',
      'message': 'private message',
      'future_error': {
        'nested': <dynamic>[true, null],
      },
    },
  'future_envelope': {
    'nested': <dynamic>[false, null],
  },
};

void _wireEqual(Object value, Object parsed) {
  expect(parsed, value);
  expect(value, parsed);
  expect(parsed.hashCode, value.hashCode);
}

ResponsesSteerPendingEvent _pendingWithFutureStubs() =>
    ResponsesSteerPendingEvent.fromJson(
      _server('pending')
        ..['required_input'] = [
          {
            'type': 'future_tool_output',
            'call_id': 'call_first',
            'future': {'owner': 'first'},
          },
          {
            'type': 'future_tool_output',
            'call_id': 'call_second',
            'future': {'owner': 'second'},
          },
        ],
    );

void main() {
  group('outbound steering', () {
    for (final input in <ResponsesSteerInput>[
      const ResponsesSteerInput.text(''),
      const ResponsesSteerInput.text('private instruction'),
      const ResponsesSteerInput.messages([
        ResponsesSteerMessage.text('private instruction'),
      ]),
      const ResponsesSteerInput.messages([ResponsesSteerMessage.parts([])]),
      const ResponsesSteerInput.messages([
        ResponsesSteerMessage.parts([
          ResponsesSteerContentPart.text('private text'),
          ResponsesSteerContentPart.image(
            imageUrl: 'https://private.example/image',
            detail: ImageDetail.original,
          ),
          ResponsesSteerContentPart.file(
            fileId: 'file_private',
            filename: 'private.pdf',
            detail: FileInputDetail.high,
          ),
        ]),
        ResponsesSteerMessage.text('next'),
      ]),
    ]) {
      test(
        'exact frame and roundtrip ${input.runtimeType} ${input.hashCode}',
        () {
          final event = ResponsesSteerEvent(
            previousResponseId: 'resp_private',
            input: input,
          );
          final json = event.toJson();
          expect(json.keys.toSet(), {'type', 'previous_response_id', 'input'});
          expect(json['type'], 'response.steer');
          expect(json['previous_response_id'], 'resp_private');
          expect(json['input'], input.toJson());
          _wireEqual(event, ResponsesSteerEvent.fromJson(_fresh(json)));
          _wireEqual(input, ResponsesSteerInput.fromJson(json['input']));
          expect(event.toString(), isNot(contains('private')));
          expect(event.copyWith(), event);
          expect(event.copyWith(previousResponseId: 'other'), isNot(event));
          expect(
            event.copyWith(input: const ResponsesSteerInput.text('other')),
            isNot(event),
          );
        },
      );
    }

    test('public const content constructor and user message projection', () {
      const message = ResponsesSteerMessage(
        content: ResponsesSteerTextContent('private text'),
      );
      expect(message.toJson(), {
        'type': 'message',
        'role': 'user',
        'content': 'private text',
      });
      final projected = ResponsesSteerMessage.fromMessageItem(
        const MessageItem(
          id: 'private id',
          agent: AgentTag(agentName: 'private agent'),
          status: ItemStatus.completed,
          phase: MessagePhase.finalAnswer,
          role: MessageRole.user,
          content: [InputContent.text('private text')],
        ),
      );
      expect(projected.toJson(), {
        'type': 'message',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': 'private text'},
        ],
      });
      expect(projected.toString(), isNot(contains('private')));
      expect(projected.copyWith(), projected);
      expect(
        projected.copyWith(content: const ResponsesSteerTextContent('other')),
        isNot(projected),
      );
    });

    for (final role in [
      MessageRole.assistant,
      MessageRole.system,
      MessageRole.developer,
      MessageRole.unknown,
    ]) {
      test('projection rejects non-user role $role', () {
        expect(
          () => ResponsesSteerMessage.fromMessageItem(
            MessageItem(role: role, content: const [InputContent.text('text')]),
          ),
          throwsFormatException,
        );
      });
    }

    test('guide omitted message type normalizes to fixed type', () {
      final parsed = ResponsesSteerMessage.fromJson(const {
        'role': 'user',
        'content': '',
      });
      expect(parsed.type, 'message');
      expect(parsed.role, 'user');
      expect(parsed.toJson(), {
        'type': 'message',
        'role': 'user',
        'content': '',
      });
    });

    for (final field in [
      'stream_id',
      'model',
      'tools',
      'background',
      'generate',
      'id',
      'status',
      'agent',
      'metadata',
      'unknown',
    ]) {
      test('rejects extra event field $field', () {
        expect(
          () => ResponsesSteerEvent.fromJson({
            'type': 'response.steer',
            'previous_response_id': 'parent',
            'input': 'text',
            field: 'private value',
          }),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'safe error',
              isNot(contains('private')),
            ),
          ),
        );
      });
    }

    for (final field in [
      'id',
      'status',
      'agent',
      'phase',
      'name',
      'output',
      'call_id',
      'unknown',
    ]) {
      test('rejects extra user message field $field', () {
        expect(
          () => ResponsesSteerMessage.fromJson({
            'type': 'message',
            'role': 'user',
            'content': 'text',
            field: 'private value',
          }),
          throwsFormatException,
        );
      });
    }

    for (final bad in <Object?>[
      null,
      true,
      1,
      <String, dynamic>{},
      <dynamic>[],
      <dynamic>['bad'],
      [
        {'type': 'function_call_output', 'call_id': 'id', 'output': 'out'},
      ],
      [
        {'role': 'assistant', 'content': 'text'},
      ],
      [
        {'role': 'system', 'content': 'text'},
      ],
      [
        {'role': 'user', 'content': null},
      ],
      [
        {
          'role': 'user',
          'content': [
            {'type': 'output_text', 'text': 'text'},
          ],
        },
      ],
    ]) {
      test('malformed/unsupported outbound input ${jsonEncode(bad)}', () {
        expect(
          () => ResponsesSteerInput.fromJson(bad),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('ResponsesSteer'),
            ),
          ),
        );
      });
    }

    test(
      'empty constructed input list fails serialization but remains inspectable',
      () {
        const input = ResponsesSteerInput.messages([]);
        expect(input.toJson, throwsFormatException);
        expect(input, const ResponsesSteerInput.messages([]));
        expect(input.hashCode, const ResponsesSteerInput.messages([]).hashCode);
        expect(input.toString(), contains('0 items'));
      },
    );

    for (final field in ['type', 'previous_response_id', 'input']) {
      test('missing required event $field', () {
        final json = <String, dynamic>{
          'type': 'response.steer',
          'previous_response_id': 'parent',
          'input': 'text',
        }..remove(field);
        expect(() => ResponsesSteerEvent.fromJson(json), throwsFormatException);
      });
      for (final bad in <Object?>[null, true, <String, dynamic>{}]) {
        test('bad required event $field ${bad.runtimeType}', () {
          expect(
            () => ResponsesSteerEvent.fromJson({
              'type': 'response.steer',
              'previous_response_id': 'parent',
              'input': 'text',
              field: bad,
            }),
            throwsFormatException,
          );
        });
      }
    }

    for (final type in <Object?>[null, false, 'function_call_output']) {
      test('message supplied type rejects $type', () {
        expect(
          () => ResponsesSteerMessage.fromJson({
            'type': type,
            'role': 'user',
            'content': 'text',
          }),
          throwsFormatException,
        );
      });
    }

    test(
      'parsed message and content lists are detached immutable snapshots',
      () {
        final source = <Map<String, dynamic>>[
          {
            'role': 'user',
            'content': <Map<String, dynamic>>[
              {
                'type': 'input_text',
                'text': 'text',
                'future': <dynamic>[1],
              },
            ],
          },
        ];
        final parsed =
            ResponsesSteerInput.fromJson(source) as ResponsesSteerMessagesInput;
        final content =
            parsed.messages.single.content as ResponsesSteerPartsContent;
        source.clear();
        expect(parsed.messages, hasLength(1));
        expect(parsed.messages.clear, throwsUnsupportedError);
        expect(content.parts.clear, throwsUnsupportedError);
        expect(
          () => content.parts.single.rawJson.clear(),
          throwsUnsupportedError,
        );
        expect(
          () =>
              (content.parts.single.rawJson['future'] as List<dynamic>).clear(),
          throwsUnsupportedError,
        );
      },
    );

    test('caller-owned collections, full content copies and diagnostics', () {
      final messages = <ResponsesSteerMessage>[
        const ResponsesSteerMessage.text('text'),
      ];
      final input = ResponsesSteerMessagesInput(messages);
      expect(identical(input.messages, messages), isTrue);
      messages.add(const ResponsesSteerMessage.parts([]));
      expect(input.toJson(), hasLength(2));
      expect(input.copyWith(), input);
      expect(
        input.copyWith(messages: const [ResponsesSteerMessage.text('other')]),
        isNot(input),
      );
      const textInput = ResponsesSteerTextInput('private');
      expect(textInput.copyWith(), textInput);
      expect(textInput.copyWith(text: 'other'), isNot(textInput));
      const textContent = ResponsesSteerTextContent('private');
      expect(textContent.copyWith(), textContent);
      expect(textContent.copyWith(text: 'other'), isNot(textContent));
      const parts = ResponsesSteerPartsContent([
        ResponsesSteerContentPart.text('private'),
      ]);
      expect(parts.copyWith(), parts);
      expect(parts.copyWith(parts: const []), isNot(parts));
      expect(parts.toString(), isNot(contains('private')));
    });
  });

  group('steering request content', () {
    final parts = <ResponsesSteerContentPart>[
      const ResponsesSteerContentPart.text(
        'private text',
        promptCacheBreakpoint: PromptCacheBreakpointConfig(),
      ),
      const ResponsesSteerContentPart.image(),
      const ResponsesSteerContentPart.image(
        imageUrl: 'private URL',
        fileId: 'private id',
        detail: ImageDetail.original,
        promptCacheBreakpoint: PromptCacheBreakpointConfig(),
      ),
      const ResponsesSteerContentPart.file(),
      const ResponsesSteerContentPart.file(
        fileData: 'private data',
        fileId: 'private id',
        fileUrl: 'private URL',
        filename: 'private name',
        detail: FileInputDetail.high,
        promptCacheBreakpoint: PromptCacheBreakpointConfig(),
      ),
    ];
    for (var index = 0; index < parts.length; index++) {
      test('complete content constructor roundtrip #$index', () {
        final part = parts[index];
        final parsed = ResponsesSteerContentPart.fromJson(
          _fresh(part.toJson()),
        );
        _wireEqual(part, parsed);
        expect(parsed.toJson(), part.toJson());
        expect(part.toString(), isNot(contains('private')));
      });
    }

    for (final type in ['input_text', 'input_image', 'input_file']) {
      test('future nested part metadata and nullable cache for $type', () {
        final json = <String, dynamic>{
          'type': type,
          if (type == 'input_text') 'text': '',
          'prompt_cache_breakpoint': {
            'mode': 'explicit',
            'future': <dynamic>[
              {'opaque': 'private value'},
            ],
          },
          'future': {
            'nested': <dynamic>[1.25, null],
          },
        };
        final part = ResponsesSteerContentPart.fromJson(json);
        expect(part.toJson(), json);
        expect(
          () => (part.rawJson['future'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(part.toString(), isNot(contains('private value')));
        final nullable = ResponsesSteerContentPart.fromJson({
          ...json,
          'prompt_cache_breakpoint': null,
        });
        expect(
          nullable.toJson().containsKey('prompt_cache_breakpoint'),
          isFalse,
        );
      });
      for (final bad in <Object?>[
        true,
        'private value',
        <dynamic>[],
        <String, dynamic>{},
        {'mode': null},
        {'mode': 'future'},
      ]) {
        test('malformed cache $type ${jsonEncode(bad)}', () {
          expect(
            () => ResponsesSteerContentPart.fromJson({
              'type': type,
              if (type == 'input_text') 'text': 'text',
              'prompt_cache_breakpoint': bad,
            }),
            throwsFormatException,
          );
        });
      }
    }

    for (final type in ['input_image', 'input_file']) {
      for (final key
          in type == 'input_image'
              ? ['image_url', 'file_id']
              : ['file_data', 'file_id', 'file_url', 'filename']) {
        test('request optionalnullable $type $key accepts omitted/null', () {
          expect(
            ResponsesSteerContentPart.fromJson({
              'type': type,
              key: null,
            }).toJson(),
            {'type': type},
          );
        });
        for (final bad in <Object?>[
          true,
          1,
          <dynamic>[],
          <String, dynamic>{},
        ]) {
          test('wrong request $type $key ${bad.runtimeType}', () {
            expect(
              () =>
                  ResponsesSteerContentPart.fromJson({'type': type, key: bad}),
              throwsA(
                isA<FormatException>().having(
                  (error) => error.message,
                  'context',
                  contains(key),
                ),
              ),
            );
          });
        }
      }
    }

    for (final type in ['input_image', 'input_file']) {
      for (final detail in [
        'auto',
        'low',
        'high',
        if (type == 'input_image') 'original',
      ]) {
        test('canonical detail $type $detail', () {
          expect(
            ResponsesSteerContentPart.fromJson({
              'type': type,
              'detail': detail,
            }).toJson(),
            {'type': type, 'detail': detail},
          );
        });
      }
      for (final bad in <Object?>[true, 1, 'future', <dynamic>[]]) {
        test('wrong detail $type ${bad.runtimeType} $bad', () {
          expect(
            () => ResponsesSteerContentPart.fromJson({
              'type': type,
              'detail': bad,
            }),
            throwsFormatException,
          );
        });
      }
    }
    test('image detail nullable, file detail nonnull-if-present', () {
      expect(
        ResponsesSteerContentPart.fromJson(const {
          'type': 'input_image',
          'detail': null,
        }).toJson(),
        {'type': 'input_image'},
      );
      expect(
        () => ResponsesSteerContentPart.fromJson(const {
          'type': 'input_file',
          'detail': null,
        }),
        throwsFormatException,
      );
      expect(
        () => ResponsesSteerContentPart.fromJson(const {
          'type': 'input_file',
          'detail': 'original',
        }),
        throwsFormatException,
      );
    });

    for (final bad in <Object?>[
      null,
      true,
      1,
      <dynamic>[],
      <String, dynamic>{},
    ]) {
      test('required text wrong ${bad.runtimeType}', () {
        expect(
          () => ResponsesSteerContentPart.fromJson({
            'type': 'input_text',
            'text': bad,
          }),
          throwsFormatException,
        );
      });
    }
    test('required text missing and malformed fixed part types fail', () {
      expect(
        () => ResponsesSteerContentPart.fromJson(const {'type': 'input_text'}),
        throwsFormatException,
      );
      expect(
        () => ResponsesSteerTextPart.fromJson(const {
          'type': 'input_image',
          'text': 'text',
        }),
        throwsFormatException,
      );
      expect(
        () => ResponsesSteerImagePart.fromJson(const {'type': 'input_file'}),
        throwsFormatException,
      );
      expect(
        () => ResponsesSteerFilePart.fromJson(const {'type': 'input_image'}),
        throwsFormatException,
      );
      expect(
        () => ResponsesSteerContentPart.fromJson(const {'type': 'input_video'}),
        throwsFormatException,
      );
    });

    test('all text/image/file fields copy, clear and affect wire values', () {
      final text = parts[0] as ResponsesSteerTextPart;
      final image = parts[2] as ResponsesSteerImagePart;
      final file = parts[4] as ResponsesSteerFilePart;
      expect(text.copyWith(), text);
      expect(image.copyWith(), image);
      expect(file.copyWith(), file);
      for (final changed in <ResponsesSteerContentPart>[
        text.copyWith(text: 'other'),
        text.copyWith(promptCacheBreakpoint: null),
        text.copyWith(
          rawJson: {
            'future': <dynamic>[1],
          },
        ),
        image.copyWith(imageUrl: 'other'),
        image.copyWith(fileId: 'other'),
        image.copyWith(detail: ImageDetail.low),
        image.copyWith(promptCacheBreakpoint: null),
        image.copyWith(
          rawJson: {
            'future': <dynamic>[1],
          },
        ),
        file.copyWith(fileData: 'other'),
        file.copyWith(fileId: 'other'),
        file.copyWith(fileUrl: 'other'),
        file.copyWith(filename: 'other'),
        file.copyWith(detail: FileInputDetail.low),
        file.copyWith(promptCacheBreakpoint: null),
        file.copyWith(
          rawJson: {
            'future': <dynamic>[1],
          },
        ),
      ]) {
        _wireEqual(
          changed,
          ResponsesSteerContentPart.fromJson(changed.toJson()),
        );
      }
      expect(
        image
            .copyWith(
              imageUrl: null,
              fileId: null,
              detail: null,
              promptCacheBreakpoint: null,
            )
            .toJson(),
        {'type': 'input_image'},
      );
      expect(
        file
            .copyWith(
              fileData: null,
              fileId: null,
              fileUrl: null,
              filename: null,
              detail: null,
              promptCacheBreakpoint: null,
            )
            .toJson(),
        {'type': 'input_file'},
      );
      expect(text.copyWith(promptCacheBreakpoint: null).toJson(), {
        'type': 'input_text',
        'text': 'private text',
      });
    });

    for (final shared in <InputContent>[
      const InputContent.text('text'),
      const InputContent.imageUrl('url'),
      const InputContent.fileId('file'),
    ]) {
      test('shared content projection ${shared.runtimeType}', () {
        expect(
          ResponsesSteerContentPart.fromInputContent(shared).toJson(),
          shared.toJson(),
        );
      });
    }
    for (final shared in <InputContent>[
      const InputContent.assistantText('text'),
      const InputContent.video('url'),
    ]) {
      test('shared unsupported projection ${shared.runtimeType}', () {
        expect(
          () => ResponsesSteerContentPart.fromInputContent(shared),
          throwsFormatException,
        );
      });
    }
  });

  group('required input stubs', () {
    test('all seven kinds are distinct typed identifying shapes', () {
      expect(_stubs, hasLength(7));
      final values = _stubs.map(ResponsesSteerRequiredInput.fromJson).toList();
      expect(values.map((stub) => stub.runtimeType).toSet(), hasLength(7));
      expect(values[0], isA<ResponsesSteerFunctionCallOutput>());
      expect(values[1], isA<ResponsesSteerCustomCallOutput>());
      expect(values[2], isA<ResponsesSteerComputerCallOutput>());
      expect(values[3], isA<ResponsesSteerShellCallOutput>());
      expect(values[4], isA<ResponsesSteerApplyPatchCallOutput>());
      expect(values[5], isA<ResponsesSteerToolSearchOutput>());
      expect(values[6], isA<ResponsesSteerMcpApprovalResponse>());
    });
    for (final stub in _stubs) {
      test('exact stub ${stub['type']}', () {
        final parsed = ResponsesSteerRequiredInput.fromJson(_fresh(stub));
        expect(parsed.toJson(), stub);
        _wireEqual(parsed, ResponsesSteerRequiredInput.fromJson(_fresh(stub)));
        expect(parsed.toString(), isNot(contains('private')));
      });
      for (final key in stub.keys) {
        test('missing stub ${stub['type']} $key', () {
          expect(
            () =>
                ResponsesSteerRequiredInput.fromJson(_fresh(stub)..remove(key)),
            throwsFormatException,
          );
        });
        for (final bad in <Object?>[
          null,
          true,
          1,
          <dynamic>[],
          <String, dynamic>{},
        ]) {
          test('wrong stub ${stub['type']} $key ${bad.runtimeType}', () {
            expect(
              () => ResponsesSteerRequiredInput.fromJson({...stub, key: bad}),
              throwsFormatException,
            );
          });
        }
      }
      for (final key in [
        'output',
        'approve',
        'acknowledged_safety_checks',
        'status',
        'agent',
        'namespace',
      ]) {
        test('stub ${stub['type']} rejects completed-result field $key', () {
          expect(
            () => ResponsesSteerRequiredInput.fromJson({
              ...stub,
              key: 'private value',
            }),
            throwsFormatException,
          );
        });
      }
    }

    test('tool search execution is fixed client with no constructor field', () {
      const stub = ResponsesSteerToolSearchOutput(callId: 'call');
      expect(stub.execution, 'client');
      expect(stub.toJson(), {
        'type': 'tool_search_output',
        'call_id': 'call',
        'execution': 'client',
      });
      for (final execution in ['server', 'future']) {
        expect(
          () => ResponsesSteerRequiredInput.fromJson({
            'type': 'tool_search_output',
            'call_id': 'call',
            'execution': execution,
          }),
          throwsFormatException,
        );
      }
    });

    test('all stub copy fields participate in equality/hash', () {
      const function = ResponsesSteerFunctionCallOutput(
        callId: 'call',
        name: 'name',
      );
      expect(function.copyWith(), function);
      expect(function.copyWith().hashCode, function.hashCode);
      expect(function.copyWith(callId: 'other'), isNot(function));
      expect(function.copyWith(name: 'other'), isNot(function));
      const custom = ResponsesSteerCustomCallOutput(callId: 'call');
      const computer = ResponsesSteerComputerCallOutput(callId: 'call');
      const shell = ResponsesSteerShellCallOutput(callId: 'call');
      const patch = ResponsesSteerApplyPatchCallOutput(callId: 'call');
      const search = ResponsesSteerToolSearchOutput(callId: 'call');
      const approval = ResponsesSteerMcpApprovalResponse(
        approvalRequestId: 'approval',
      );
      final originals = <ResponsesSteerRequiredInput>[
        custom,
        computer,
        shell,
        patch,
        search,
        approval,
      ];
      final equalCopies = <ResponsesSteerRequiredInput>[
        custom.copyWith(),
        computer.copyWith(),
        shell.copyWith(),
        patch.copyWith(),
        search.copyWith(),
        approval.copyWith(),
      ];
      final changed = <ResponsesSteerRequiredInput>[
        custom.copyWith(callId: 'other'),
        computer.copyWith(callId: 'other'),
        shell.copyWith(callId: 'other'),
        patch.copyWith(callId: 'other'),
        search.copyWith(callId: 'other'),
        approval.copyWith(approvalRequestId: 'other'),
      ];
      for (var index = 0; index < originals.length; index++) {
        _wireEqual(originals[index], equalCopies[index]);
        expect(changed[index], isNot(originals[index]));
      }
    });

    for (final stub in _stubs) {
      test(
        'future wrapper rejects known kind ${stub['type']} on serialization',
        () {
          final invalid = UnknownResponsesSteerRequiredInput(
            type: stub['type'] as String,
            rawJson: const {'credential': 'private-secret'},
          );
          final copied = invalid.copyWith();
          _wireEqual(invalid, copied);
          expect(invalid.toString(), isNot(contains('private-secret')));
          expect(invalid.toJson, throwsFormatException);
          expect(copied.toJson, throwsFormatException);
          expect(
            () => const UnknownResponsesSteerRequiredInput(
              type: 'future',
              rawJson: {},
            ).copyWith(type: stub['type'] as String).toJson(),
            throwsFormatException,
          );
        },
      );
    }

    test('future stub raw fallback is deep immutable and value stable', () {
      final json = <String, dynamic>{
        'type': 'future_private',
        'future': {
          'nested': <dynamic>[1.25, null, false],
        },
      };
      final parsed =
          ResponsesSteerRequiredInput.fromJson(json)
              as UnknownResponsesSteerRequiredInput;
      expect(parsed.toJson(), json);
      _wireEqual(
        parsed,
        UnknownResponsesSteerRequiredInput.fromJson(_fresh(json)),
      );
      expect(parsed.copyWith(), parsed);
      expect(parsed.copyWith(type: 'changed').toJson()['type'], 'changed');
      expect(
        parsed.copyWith(
          rawJson: const {
            'future': <dynamic>[2],
          },
        ),
        isNot(parsed),
      );
      expect(parsed.toString(), isNot(contains('private')));
      expect(
        () => (parsed.rawJson['future'] as Map<String, dynamic>).clear(),
        throwsUnsupportedError,
      );
      json.clear();
      expect(parsed.rawJson, hasLength(2));
      expect(
        () => UnknownResponsesSteerRequiredInput.fromJson(_stubs.first),
        throwsFormatException,
      );
    });
  });

  group('steering server acknowledgements', () {
    for (final kind in ['accepted', 'pending', 'failed']) {
      test('typed dispatcher and complete nested raw roundtrip $kind', () {
        final json = _server(kind);
        final parsed = ResponsesServerEvent.fromJson(json);
        expect(parsed, isNot(isA<UnknownResponsesServerEvent>()));
        expect(parsed.type, json['type']);
        expect(parsed.streamId, json['stream_id']);
        expect(parsed.rawJson, json);
        expect(parsed.toJson(), json);
        _wireEqual(parsed, ResponsesServerEvent.fromJson(_fresh(json)));
        expect(parsed.toString(), isNot(contains('private')));
        expect(() => parsed.rawJson.clear(), throwsUnsupportedError);
        expect(
          () => (parsed.rawJson['future_envelope'] as Map<String, dynamic>)
              .clear(),
          throwsUnsupportedError,
        );
      });
      for (final field in [
        'type',
        'sequence_number',
        'steer',
        if (kind == 'pending') 'reason',
        if (kind == 'pending') 'required_input',
        if (kind == 'failed') 'error',
      ]) {
        test('required $kind $field missing', () {
          expect(
            () => ResponsesServerEvent.fromJson(_server(kind)..remove(field)),
            throwsFormatException,
          );
        });
        for (final bad in <Object?>[
          null,
          true,
          1.5,
          <dynamic>[],
          <String, dynamic>{},
        ]) {
          test('required $kind $field wrong ${bad.runtimeType}', () {
            final json = _server(kind)..[field] = bad;
            // An empty raw map is valid failed input but not an error/identity.
            expect(
              () => ResponsesServerEvent.fromJson(json),
              throwsFormatException,
            );
          });
        }
      }
      for (final bad in <Object?>[
        null,
        true,
        1,
        <dynamic>[],
        <String, dynamic>{},
      ]) {
        test('optional $kind lane supplied wrong ${bad.runtimeType}', () {
          expect(
            () => ResponsesServerEvent.fromJson(
              _server(kind)..['stream_id'] = bad,
            ),
            throwsFormatException,
          );
        });
      }
      test('default $kind lane omission', () {
        final json = _server(kind)..remove('stream_id');
        expect(ResponsesServerEvent.fromJson(json).toJson(), json);
      });
    }

    test('pending required inputs nonempty, all seven typed and frozen', () {
      final parsed = ResponsesSteerPendingEvent.fromJson(_server('pending'));
      expect(parsed.requiredInput, hasLength(7));
      expect(parsed.reason, 'future_private_reason');
      expect(parsed.requiredInput.clear, throwsUnsupportedError);
      expect(
        () => ResponsesSteerPendingEvent.fromJson(
          _server('pending')..['required_input'] = <dynamic>[],
        ),
        throwsFormatException,
      );
      expect(
        () => const ResponsesSteerPendingEvent(
          sequenceNumber: 1,
          steer: _id,
          reason: 'waiting_for_required_input',
          requiredInput: [],
        ).toJson(),
        throwsFormatException,
      );
      expect(
        () => ResponsesSteerPendingEvent.fromJson(
          _server('pending')..['required_input'] = <dynamic>[null],
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'indexed context',
            contains('required_input[0]'),
          ),
        ),
      );
    });

    for (final kind in ['accepted', 'pending']) {
      for (final field in ['id', 'previous_response_id']) {
        test('identity $kind missing $field', () {
          final json = _server(kind);
          (json['steer'] as Map<String, dynamic>).remove(field);
          expect(
            () => ResponsesServerEvent.fromJson(json),
            throwsFormatException,
          );
        });
        for (final bad in <Object?>[null, true, 1, <dynamic>[]]) {
          test('identity $kind wrong $field ${bad.runtimeType}', () {
            final json = _server(kind);
            (json['steer'] as Map<String, dynamic>)[field] = bad;
            expect(
              () => ResponsesServerEvent.fromJson(json),
              throwsFormatException,
            );
          });
        }
      }
    }

    for (final input in <Object?>[
      null,
      false,
      1,
      1.25,
      'private input',
      <dynamic>[],
      <String, dynamic>{},
      {'role': 'assistant', 'id': 'private invalid'},
    ]) {
      test(
        'failed preserves original rejected JSON ${input.runtimeType} $input',
        () {
          final json = _server('failed');
          (json['steer'] as Map<String, dynamic>)['input'] = input;
          final parsed = ResponsesSteerFailedEvent.fromJson(json);
          expect(parsed.steer.input, input);
          expect(parsed.toJson(), json);
          expect(parsed.toString(), isNot(contains('private')));
          expect(parsed.steer.toString(), isNot(contains('private')));
          _wireEqual(
            parsed.steer,
            ResponsesFailedSteer.fromJson(parsed.steer.toJson()),
          );
        },
      );
    }

    test('failed optional id omitted versus nonnullable supplied id', () {
      final json = _server('failed');
      final steer = (json['steer'] as Map<String, dynamic>)..remove('id');
      final parsed = ResponsesSteerFailedEvent.fromJson(json);
      expect(parsed.steer.id, isNull);
      expect(parsed.toJson(), json);
      expect(
        () => ResponsesFailedSteer.fromJson({...steer, 'id': null}),
        throwsFormatException,
      );
      expect(
        () => ResponsesFailedSteer.fromJson({...steer, 'id': true}),
        throwsFormatException,
      );
      expect(
        () => ResponsesFailedSteer.fromJson({...steer}..remove('input')),
        throwsFormatException,
      );
    });

    for (final code in [
      'response_not_found',
      'invalid_input',
      'steering_not_supported',
      'too_many_pending_steers',
      'response_already_completed',
      'response_not_active',
      'successor_creation_failed',
      'future_code',
    ]) {
      test('open steering failure code $code', () {
        final json = _server('failed');
        (json['error'] as Map<String, dynamic>)['code'] = code;
        expect(ResponsesSteerFailedEvent.fromJson(json).error.code, code);
        expect(ResponsesSteerFailedEvent.fromJson(json).toJson(), json);
      });
    }

    for (final field in ['type', 'code', 'message']) {
      test('required steering error $field missing', () {
        final json = (_server('failed')['error'] as Map<String, dynamic>)
          ..remove(field);
        expect(() => ResponsesSteerError.fromJson(json), throwsFormatException);
      });
      for (final bad in <Object?>[null, true, 1, <dynamic>[]]) {
        test('required steering error $field wrong ${bad.runtimeType}', () {
          final json = _server('failed')['error'] as Map<String, dynamic>;
          json[field] = bad;
          expect(
            () => ResponsesSteerError.fromJson(json),
            throwsFormatException,
          );
        });
      }
    }
    test(
      'fixed error type is not writable or normalized from arbitrary values',
      () {
        expect(_error.type, 'invalid_request_error');
        expect(
          () => ResponsesSteerError.fromJson(const {
            'type': 'server_error',
            'code': 'future',
            'message': 'private',
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'server constructors, all copy fields and stale-raw override roundtrip',
      () {
        const accepted = ResponsesSteerAcceptedEvent(
          sequenceNumber: 1,
          steer: _id,
        );
        const pending = ResponsesSteerPendingEvent(
          sequenceNumber: 1,
          steer: _id,
          reason: 'waiting_for_required_input',
          requiredInput: [
            ResponsesSteerFunctionCallOutput(callId: 'call', name: 'lookup'),
          ],
        );
        const failed = ResponsesSteerFailedEvent(
          sequenceNumber: 1,
          steer: ResponsesFailedSteer(
            previousResponseId: 'parent',
            input: null,
          ),
          error: _error,
        );
        for (final value in <ResponsesServerEvent>[accepted, pending, failed]) {
          _wireEqual(value, ResponsesServerEvent.fromJson(value.toJson()));
        }
        final parsedAccepted = ResponsesSteerAcceptedEvent.fromJson(
          _server('accepted'),
        );
        final parsedPending = ResponsesSteerPendingEvent.fromJson(
          _server('pending'),
        );
        final parsedFailed = ResponsesSteerFailedEvent.fromJson(
          _server('failed'),
        );
        final changed = <ResponsesServerEvent>[
          parsedAccepted.copyWith(sequenceNumber: 2),
          parsedAccepted.copyWith(steer: _id.copyWith(id: 'other')),
          parsedAccepted.copyWith(streamId: null),
          parsedAccepted.copyWith(
            rawJson: {
              'future': <dynamic>[1],
            },
          ),
          parsedPending.copyWith(sequenceNumber: 2),
          parsedPending.copyWith(
            steer: _id.copyWith(previousResponseId: 'other'),
          ),
          parsedPending.copyWith(reason: 'other'),
          parsedPending.copyWith(
            requiredInput: const [
              ResponsesSteerToolSearchOutput(callId: 'other'),
            ],
          ),
          parsedPending.copyWith(streamId: null),
          parsedPending.copyWith(
            rawJson: {
              'future': <dynamic>[1],
            },
          ),
          parsedFailed.copyWith(sequenceNumber: 2),
          parsedFailed.copyWith(
            steer: parsedFailed.steer.copyWith(input: null, id: null),
          ),
          parsedFailed.copyWith(
            error: parsedFailed.error.copyWith(message: 'other'),
          ),
          parsedFailed.copyWith(streamId: null),
          parsedFailed.copyWith(
            rawJson: {
              'future': <dynamic>[1],
            },
          ),
        ];
        for (final value in changed) {
          _wireEqual(value, ResponsesServerEvent.fromJson(value.toJson()));
        }
        expect(parsedAccepted.copyWith(), parsedAccepted);
        expect(parsedPending.copyWith(), parsedPending);
        expect(parsedFailed.copyWith(), parsedFailed);
        expect(
          parsedAccepted
              .copyWith(streamId: null)
              .toJson()
              .containsKey('stream_id'),
          isFalse,
        );
        expect(
          parsedPending
              .copyWith(streamId: null)
              .toJson()
              .containsKey('stream_id'),
          isFalse,
        );
        expect(
          parsedFailed
              .copyWith(streamId: null)
              .toJson()
              .containsKey('stream_id'),
          isFalse,
        );
      },
    );

    test(
      'nested scalar copies retain their own future metadata and clear known fields',
      () {
        final accepted = ResponsesSteerAcceptedEvent.fromJson(
          _server('accepted'),
        );
        final edited = accepted.copyWith(steer: accepted.steer.copyWith());
        expect(
          (edited.toJson()['steer'] as Map<String, dynamic>)['future_steer'],
          accepted.steer.rawJson['future_steer'],
        );
        _wireEqual(edited, ResponsesServerEvent.fromJson(edited.toJson()));
        final replaced = accepted.copyWith(steer: _id.copyWith(id: 'other'));
        expect(
          (replaced.toJson()['steer'] as Map<String, dynamic>).containsKey(
            'future_steer',
          ),
          isFalse,
        );
        final failed = ResponsesSteerFailedEvent.fromJson(_server('failed'));
        final cleared = failed.copyWith(
          steer: failed.steer.copyWith(input: null, id: null),
          error: failed.error.copyWith(
            code: 'changed',
            message: 'private-secret',
          ),
        );
        final nested = cleared.toJson()['steer'] as Map<String, dynamic>;
        expect(nested['input'], isNull);
        expect(nested.containsKey('id'), isFalse);
        expect(nested['future_steer'], failed.steer.rawJson['future_steer']);
        expect(
          (cleared.toJson()['error'] as Map<String, dynamic>)['future_error'],
          failed.error.rawJson['future_error'],
        );
        expect(cleared.error.toString(), isNot(contains('private-secret')));
        _wireEqual(cleared, ResponsesServerEvent.fromJson(cleared.toJson()));
      },
    );

    for (final pending in [false, true]) {
      final kind = pending ? 'pending' : 'accepted';
      test('explicit $kind identity metadata clear stays cleared', () {
        final parsed = ResponsesServerEvent.fromJson(_server(kind));
        final changed = parsed is ResponsesSteerPendingEvent
            ? parsed.copyWith(steer: parsed.steer.copyWith(rawJson: {}))
            : (parsed as ResponsesSteerAcceptedEvent).copyWith(
                steer: parsed.steer.copyWith(rawJson: {}),
              );
        expect(changed.toJson()['steer'], _id.toJson());
        expect(
          changed.toJson()['future_envelope'],
          parsed.toJson()['future_envelope'],
        );
        expect(changed.rawJson.clear, throwsUnsupportedError);
        expect(
          () => (changed.rawJson['steer'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      });
      test('fresh $kind identity replacement drops old owned metadata', () {
        final parsed = ResponsesServerEvent.fromJson(_server(kind));
        final changed = parsed is ResponsesSteerPendingEvent
            ? parsed.copyWith(steer: _id)
            : (parsed as ResponsesSteerAcceptedEvent).copyWith(steer: _id);
        expect(changed.toJson()['steer'], _id.toJson());
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      });
      test('ordinary $kind scalar copy retains child metadata', () {
        final parsed = ResponsesServerEvent.fromJson(_server(kind));
        final changed = parsed is ResponsesSteerPendingEvent
            ? parsed.copyWith(
                steer: parsed.steer.copyWith(previousResponseId: 'changed'),
              )
            : (parsed as ResponsesSteerAcceptedEvent).copyWith(
                steer: parsed.steer.copyWith(previousResponseId: 'changed'),
              );
        expect(
          (changed.toJson()['steer'] as Map<String, dynamic>)['future_steer'],
          (parsed.toJson()['steer'] as Map<String, dynamic>)['future_steer'],
        );
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      });
      test(
        'explicit $kind parent override takes priority over reconciliation',
        () {
          final parsed = ResponsesServerEvent.fromJson(_server(kind));
          final raw = <String, dynamic>{
            'steer': {'parent_override': true},
            'replacement_parent': true,
          };
          final changed = parsed is ResponsesSteerPendingEvent
              ? parsed.copyWith(
                  steer: parsed.steer.copyWith(rawJson: {}),
                  rawJson: raw,
                )
              : (parsed as ResponsesSteerAcceptedEvent).copyWith(
                  steer: parsed.steer.copyWith(rawJson: {}),
                  rawJson: raw,
                );
          expect(identical(changed.rawJson, raw), isTrue);
          expect(changed.toJson()['steer'], {
            'parent_override': true,
            ..._id.toJson(),
          });
          expect(changed.toJson().containsKey('future_envelope'), isFalse);
          _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
        },
      );
    }
    for (final fresh in [false, true]) {
      test(
        'failed error ${fresh ? 'fresh replacement' : 'explicit raw clear'} stays replaced',
        () {
          final parsed = ResponsesSteerFailedEvent.fromJson(_server('failed'));
          final error = fresh ? _error : parsed.error.copyWith(rawJson: {});
          final changed = parsed.copyWith(error: error);
          expect(changed.toJson()['error'], error.toJson());
          expect(changed.toJson()['steer'], parsed.toJson()['steer']);
          _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
        },
      );
    }
    test(
      'failed steer clear removes metadata and optional ID without stale input',
      () {
        final parsed = ResponsesSteerFailedEvent.fromJson(_server('failed'));
        final changed = parsed.copyWith(
          steer: parsed.steer.copyWith(rawJson: {}, input: null, id: null),
        );
        expect(changed.toJson()['steer'], {
          'previous_response_id': 'resp_private',
          'input': null,
        });
        expect(changed.toJson()['error'], parsed.toJson()['error']);
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );
    test(
      'simultaneous failed child clears preserve only parent future metadata',
      () {
        final parsed = ResponsesSteerFailedEvent.fromJson(_server('failed'));
        final changed = parsed.copyWith(
          steer: parsed.steer.copyWith(rawJson: {}, input: null, id: null),
          error: parsed.error.copyWith(rawJson: {}, code: 'changed'),
        );
        expect(changed.toJson()['steer'], changed.steer.toJson());
        expect(changed.toJson()['error'], changed.error.toJson());
        expect(
          changed.toJson()['future_envelope'],
          parsed.toJson()['future_envelope'],
        );
        expect(changed.rawJson.clear, throwsUnsupportedError);
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );
    test(
      'failed explicit parent override wins with both child replacements',
      () {
        final parsed = ResponsesSteerFailedEvent.fromJson(_server('failed'));
        final raw = <String, dynamic>{
          'steer': {'parent_steer': true},
          'error': {'parent_error': true},
          'replacement_parent': true,
        };
        final changed = parsed.copyWith(
          steer: parsed.steer.copyWith(rawJson: {}),
          error: parsed.error.copyWith(rawJson: {}),
          rawJson: raw,
        );
        expect(identical(changed.rawJson, raw), isTrue);
        expect(changed.toJson()['steer'], {
          'parent_steer': true,
          ...changed.steer.toJson(),
        });
        expect(changed.toJson()['error'], {
          'parent_error': true,
          ...changed.error.toJson(),
        });
        expect(changed.toJson().containsKey('future_envelope'), isFalse);
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );
    test('failed nested metadata replacement removes old nested children', () {
      final parsed = ResponsesSteerFailedEvent.fromJson(_server('failed'));
      final changed = parsed.copyWith(
        steer: parsed.steer.copyWith(
          rawJson: {
            'future_steer': {'replacement': true},
          },
        ),
        error: parsed.error.copyWith(
          rawJson: {
            'future_error': {'replacement': false},
          },
        ),
      );
      expect(
        (changed.toJson()['steer'] as Map<String, dynamic>)['future_steer'],
        {'replacement': true},
      );
      expect(
        (changed.toJson()['error'] as Map<String, dynamic>)['future_error'],
        {'replacement': false},
      );
      _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
    });

    test(
      'required-input scalar copies retain owned metadata while fresh replacements replace',
      () {
        final json = _server('pending')
          ..['required_input'] = [
            {
              'type': 'future_tool_output',
              'call_id': 'call_same',
              'future': {'kept': true},
            },
            {
              'type': 'future_tool_output',
              'call_id': 'call_remove',
              'future': {'removed': true},
            },
          ];
        final parsed = ResponsesSteerPendingEvent.fromJson(json);
        final same = parsed.copyWith(
          requiredInput: [
            (parsed.requiredInput.first as UnknownResponsesSteerRequiredInput)
                .copyWith(),
          ],
        );
        expect(same.toJson()['required_input'], [
          {
            'type': 'future_tool_output',
            'call_id': 'call_same',
            'future': {'kept': true},
          },
        ]);
        _wireEqual(same, ResponsesServerEvent.fromJson(same.toJson()));
        final changed = parsed.copyWith(
          requiredInput: const [
            UnknownResponsesSteerRequiredInput(
              type: 'future_tool_output',
              rawJson: {'call_id': 'new_call'},
            ),
          ],
        );
        expect(changed.toJson()['required_input'], [
          {'type': 'future_tool_output', 'call_id': 'new_call'},
        ]);
        final known = parsed.copyWith(
          requiredInput: const [
            ResponsesSteerShellCallOutput(callId: 'new_call'),
          ],
        );
        expect(known.toJson()['required_input'], [
          {'type': 'shell_call_output', 'call_id': 'new_call'},
        ]);
        final reset = parsed.copyWith(
          requiredInput: const [
            UnknownResponsesSteerRequiredInput(
              type: 'future_tool_output',
              rawJson: {'call_id': 'call_same'},
            ),
          ],
          rawJson: const {},
        );
        expect(reset.toJson()['required_input'], [
          {'type': 'future_tool_output', 'call_id': 'call_same'},
        ]);
      },
    );

    test('required-input child raw clear removes old owned stub metadata', () {
      final parsed = _pendingWithFutureStubs();
      final first =
          parsed.requiredInput.first as UnknownResponsesSteerRequiredInput;
      final changed = parsed.copyWith(
        requiredInput: [
          first.copyWith(rawJson: const {'call_id': 'call_first'}),
        ],
      );
      expect(changed.toJson()['required_input'], [
        {'type': 'future_tool_output', 'call_id': 'call_first'},
      ]);
      expect(changed.rawJson.clear, throwsUnsupportedError);
      expect(
        () => (changed.rawJson['required_input'] as List<dynamic>).clear(),
        throwsUnsupportedError,
      );
      _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
    });
    test(
      'fresh same-identity required-input replacement carries only its own fields',
      () {
        final parsed = _pendingWithFutureStubs();
        final changed = parsed.copyWith(
          requiredInput: const [
            UnknownResponsesSteerRequiredInput(
              type: 'future_tool_output',
              rawJson: {'call_id': 'call_first', 'replacement': true},
            ),
          ],
        );
        expect(changed.toJson()['required_input'], [
          {
            'type': 'future_tool_output',
            'call_id': 'call_first',
            'replacement': true,
          },
        ]);
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );
    test(
      'required-input reorder keeps each child metadata without index carry',
      () {
        final parsed = _pendingWithFutureStubs();
        final changed = parsed.copyWith(
          requiredInput: [
            (parsed.requiredInput[1] as UnknownResponsesSteerRequiredInput)
                .copyWith(),
            (parsed.requiredInput[0] as UnknownResponsesSteerRequiredInput)
                .copyWith(),
          ],
        );
        expect(changed.toJson()['required_input'], [
          parsed.requiredInput[1].toJson(),
          parsed.requiredInput[0].toJson(),
        ]);
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );
    test('direct stub overlay is retained until explicit list replacement', () {
      const constructed = ResponsesSteerPendingEvent(
        sequenceNumber: 3,
        steer: _id,
        reason: 'future reason',
        requiredInput: [
          UnknownResponsesSteerRequiredInput(
            type: 'future_tool_output',
            rawJson: {'call_id': 'call_first'},
          ),
        ],
        rawJson: {
          'required_input': [
            {
              'type': 'future_tool_output',
              'call_id': 'call_first',
              'parent_only': true,
            },
          ],
        },
      );
      expect(constructed.toJson()['required_input'], [
        {
          'type': 'future_tool_output',
          'call_id': 'call_first',
          'parent_only': true,
        },
      ]);
      final changed = constructed.copyWith(
        requiredInput: constructed.requiredInput,
      );
      expect(changed.toJson()['required_input'], [
        {'type': 'future_tool_output', 'call_id': 'call_first'},
      ]);
      _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
    });
    test(
      'required-input scalar child copy preserves explicitly retained metadata',
      () {
        final parsed = _pendingWithFutureStubs();
        final first =
            parsed.requiredInput.first as UnknownResponsesSteerRequiredInput;
        final changed = parsed.copyWith(
          requiredInput: [
            first.copyWith(
              rawJson: {...first.rawJson, 'call_id': 'call_changed'},
            ),
          ],
        );
        expect(changed.toJson()['required_input'], [
          {
            'type': 'future_tool_output',
            'call_id': 'call_changed',
            'future': {'owner': 'first'},
          },
        ]);
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );
    test(
      'explicit parent override retains direct required-input overlay policy',
      () {
        final parsed = _pendingWithFutureStubs();
        final raw = <String, dynamic>{
          'required_input': [
            {
              'type': 'future_tool_output',
              'call_id': 'call_first',
              'parent_override': true,
            },
          ],
          'replacement_parent': true,
        };
        final changed = parsed.copyWith(
          requiredInput: const [
            UnknownResponsesSteerRequiredInput(
              type: 'future_tool_output',
              rawJson: {'call_id': 'call_first'},
            ),
          ],
          rawJson: raw,
        );
        expect(identical(changed.rawJson, raw), isTrue);
        expect(changed.toJson()['required_input'], [
          {
            'type': 'future_tool_output',
            'call_id': 'call_first',
            'parent_override': true,
          },
        ]);
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );
    test(
      'simultaneous pending identity and stub metadata clears remain independent',
      () {
        final parsed = _pendingWithFutureStubs();
        final changed = parsed.copyWith(
          steer: parsed.steer.copyWith(rawJson: {}),
          requiredInput: const [
            UnknownResponsesSteerRequiredInput(
              type: 'future_tool_output',
              rawJson: {'call_id': 'call_first'},
            ),
          ],
        );
        expect(changed.toJson()['steer'], _id.toJson());
        expect(changed.toJson()['required_input'], [
          {'type': 'future_tool_output', 'call_id': 'call_first'},
        ]);
        expect(
          changed.toJson()['future_envelope'],
          parsed.toJson()['future_envelope'],
        );
        _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
      },
    );

    test(
      'all nested identity, rejected input, error copies and value fields',
      () {
        _wireEqual(_id, ResponsesSteerIdentity.fromJson(_id.toJson()));
        expect(_id.copyWith(), _id);
        expect(_id.copyWith(id: 'other'), isNot(_id));
        expect(_id.copyWith(previousResponseId: 'other'), isNot(_id));
        expect(
          _id.copyWith(
            rawJson: {
              'future': <dynamic>[1],
            },
          ),
          isNot(_id),
        );
        _wireEqual(_error, ResponsesSteerError.fromJson(_error.toJson()));
        expect(_error.copyWith(), _error);
        expect(_error.copyWith(code: 'other'), isNot(_error));
        expect(_error.copyWith(message: 'other'), isNot(_error));
        expect(
          _error.copyWith(
            rawJson: {
              'future': <dynamic>[1],
            },
          ),
          isNot(_error),
        );
        final failed = ResponsesFailedSteer.fromJson(
          _server('failed')['steer'] as Map<String, dynamic>,
        );
        expect(failed.copyWith(), failed);
        expect(failed.copyWith(previousResponseId: 'other'), isNot(failed));
        expect(failed.copyWith(input: null), isNot(failed));
        expect(failed.copyWith(id: null), isNot(failed));
        expect(
          failed.copyWith(
            rawJson: {
              'future': <dynamic>[1],
            },
          ),
          isNot(failed),
        );
        expect(
          failed.copyWith(input: null, id: null).toJson()['input'],
          isNull,
        );
        expect(
          failed.copyWith(input: null, id: null).toJson().containsKey('id'),
          isFalse,
        );
        expect(
          () => (failed.input! as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(
          () =>
              (failed.rawJson['future_steer'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
      },
    );

    for (final bad in <Object?>[double.infinity, double.nan, Object()]) {
      test('non-JSON rejected input ${bad.runtimeType}', () {
        expect(
          () => ResponsesFailedSteer.fromJson({
            'previous_response_id': 'parent',
            'input': bad,
          }),
          throwsFormatException,
        );
        expect(
          () => ResponsesFailedSteer(
            previousResponseId: 'parent',
            input: bad,
          ).toJson(),
          throwsFormatException,
        );
      });
    }
    for (final pending in [false, true]) {
      test(
        'direct ${pending ? 'pending' : 'accepted'} parent-only identity metadata clears on replacement',
        () {
          final ResponsesServerEvent constructed = pending
              ? const ResponsesSteerPendingEvent(
                  sequenceNumber: 3,
                  steer: _id,
                  reason: 'future reason',
                  requiredInput: [
                    ResponsesSteerShellCallOutput(callId: 'call'),
                  ],
                  rawJson: {
                    'steer': {'parent_only': true},
                  },
                )
              : const ResponsesSteerAcceptedEvent(
                  sequenceNumber: 3,
                  steer: _id,
                  rawJson: {
                    'steer': {'parent_only': true},
                  },
                );
          expect(
            (constructed.toJson()['steer']
                as Map<String, dynamic>)['parent_only'],
            isTrue,
          );
          final changed = constructed is ResponsesSteerPendingEvent
              ? constructed.copyWith(steer: _id)
              : (constructed as ResponsesSteerAcceptedEvent).copyWith(
                  steer: _id,
                );
          expect(changed.toJson()['steer'], _id.toJson());
          _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
        },
      );
    }
    for (final error in [false, true]) {
      test(
        'direct failed parent-only ${error ? 'error' : 'steer'} metadata clears independently',
        () {
          const constructed = ResponsesSteerFailedEvent(
            sequenceNumber: 3,
            steer: ResponsesFailedSteer(
              id: 'steer_private',
              previousResponseId: 'resp_private',
              input: 'original',
            ),
            error: _error,
            rawJson: {
              'steer': {'parent_only': true},
              'error': {'parent_only': true},
            },
          );
          for (final child in ['steer', 'error']) {
            expect(
              (constructed.toJson()[child]
                  as Map<String, dynamic>)['parent_only'],
              isTrue,
            );
          }
          _wireEqual(constructed, constructed.copyWith());
          final changed = error
              ? constructed.copyWith(
                  error: constructed.error.copyWith(rawJson: {}),
                )
              : constructed.copyWith(
                  steer: constructed.steer.copyWith(rawJson: {}),
                );
          final replaced = error ? 'error' : 'steer';
          final untouched = error ? 'steer' : 'error';
          expect(
            (changed.toJson()[replaced] as Map<String, dynamic>).containsKey(
              'parent_only',
            ),
            isFalse,
          );
          expect(changed.toJson()[untouched], constructed.toJson()[untouched]);
          _wireEqual(changed, ResponsesServerEvent.fromJson(changed.toJson()));
        },
      );
    }
    test(
      'known steering discriminators never fall back on malformed objects',
      () {
        for (final type in [
          'response.steer.accepted',
          'response.steer.pending',
          'response.steer.failed',
        ]) {
          expect(
            () => ResponsesServerEvent.fromJson({'type': type}),
            throwsFormatException,
          );
          expect(
            () => UnknownResponsesServerEvent.fromJson({'type': type}),
            throwsFormatException,
          );
        }
        expect(
          () => ResponsesSteerAcceptedEvent.fromJson(_server('pending')),
          throwsFormatException,
        );
        expect(
          () => ResponsesSteerPendingEvent.fromJson(_server('accepted')),
          throwsFormatException,
        );
        expect(
          () => ResponsesSteerFailedEvent.fromJson(_server('accepted')),
          throwsFormatException,
        );
      },
    );

    test(
      'future raw values change deep equality/hash and constructor ownership stays',
      () {
        final raw = <String, dynamic>{
          'future': <dynamic>[1],
        };
        final identity = ResponsesSteerIdentity(
          id: 'id',
          previousResponseId: 'parent',
          rawJson: raw,
        );
        expect(identical(identity.rawJson, raw), isTrue);
        raw['later'] = true;
        expect(identity.toJson()['later'], isTrue);
        final a = ResponsesSteerError.fromJson(const {
          'type': 'invalid_request_error',
          'code': 'code',
          'message': 'msg',
          'future': {
            'a': <dynamic>[1],
            'b': true,
          },
        });
        final b = ResponsesSteerError.fromJson(const {
          'future': {
            'b': true,
            'a': <dynamic>[1],
          },
          'message': 'msg',
          'code': 'code',
          'type': 'invalid_request_error',
        });
        _wireEqual(a, b);
        expect(
          a.copyWith(
            rawJson: {
              'future': <dynamic>[2],
            },
          ),
          isNot(a),
        );
      },
    );
  });
}
