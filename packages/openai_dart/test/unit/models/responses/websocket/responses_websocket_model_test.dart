import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../../../fixtures/responses_websocket_events.dart';

const _request = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('private prompt'),
);

const _error = ResponsesErrorPayload(
  type: 'private type',
  message: 'private message',
  code: 'private code',
  param: 'private parameter',
);

Map<String, dynamic> _fresh(Map<String, dynamic> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

Map<String, dynamic> _errorJson() => {
  'type': 'error',
  'status': 400,
  'sequence_number': 3,
  'stream_id': 'private lane',
  'agent': {'agent_name': 'private owner', 'future_agent': 'retained'},
  'error': {
    'type': 'invalid_request_error',
    'message': 'private error text',
    'code': 'future_error_code',
    'param': null,
    'headers': {'authorization': 'private token', 'x-request-id': 'private id'},
    'misalignment': {
      'detailed_explanation': 'private explanation',
      'error_type': 'future classification',
      'review_target': 'private-review:target',
      'steer': {
        'message': 'private continuation',
        'future_steer': <dynamic>[1],
      },
      'future_detail': {
        'nested': <dynamic>[true, null],
      },
    },
    'future_error': {
      'nested': <dynamic>[1, false],
    },
  },
  'future_envelope': {
    'nested': <dynamic>[2, null],
  },
};

void main() {
  group('WebSocket model effective wire value', () {
    final fixtures =
        <(Object, Map<String, dynamic>, Object Function(Map<String, dynamic>))>[
          (
            const ResponsesCreateEvent(
              request: _request,
              streamId: 'lane',
              generate: false,
            ),
            const ResponsesCreateEvent(
              request: _request,
              streamId: 'lane',
              generate: false,
            ).toJson(),
            ResponsesCreateEvent.fromJson,
          ),
          (
            const ResponsesStreamEvent(
              event: ResponseAudioDoneEvent(sequenceNumber: 1),
              streamId: 'lane',
            ),
            const ResponsesStreamEvent(
              event: ResponseAudioDoneEvent(sequenceNumber: 1),
              streamId: 'lane',
            ).toJson(),
            ResponsesStreamEvent.fromJson,
          ),
          (
            const UnknownResponsesServerEvent(
              type: 'future',
              streamId: 'lane',
              rawJson: {
                'future': <dynamic>[1],
              },
            ),
            const UnknownResponsesServerEvent(
              type: 'future',
              streamId: 'lane',
              rawJson: {
                'future': <dynamic>[1],
              },
            ).toJson(),
            UnknownResponsesServerEvent.fromJson,
          ),
          (
            const ResponsesErrorEvent(
              error: _error,
              status: 400,
              streamId: 'lane',
            ),
            const ResponsesErrorEvent(
              error: _error,
              status: 400,
              streamId: 'lane',
            ).toJson(),
            ResponsesErrorEvent.fromJson,
          ),
          (_error, _error.toJson(), ResponsesErrorPayload.fromJson),
          (
            const ResponsesMisalignmentDetails(
              detailedExplanation: 'text',
              errorType: 'future',
              reviewTarget: 'target',
            ),
            const ResponsesMisalignmentDetails(
              detailedExplanation: 'text',
              errorType: 'future',
              reviewTarget: 'target',
            ).toJson(),
            ResponsesMisalignmentDetails.fromJson,
          ),
          (
            const ResponsesMisalignmentSteer(message: 'text'),
            const ResponsesMisalignmentSteer(message: 'text').toJson(),
            ResponsesMisalignmentSteer.fromJson,
          ),
        ];
    for (final (constructed, json, parse) in fixtures) {
      test(
        '${constructed.runtimeType} constructor roundtrip equality and hash',
        () {
          final parsed = parse(_fresh(json));
          expect(parsed, constructed);
          expect(constructed, parsed);
          expect(parsed.hashCode, constructed.hashCode);
        },
      );
    }

    test('ordinary/unknown child factories reject the wrong variant', () {
      expect(
        () => ResponsesStreamEvent.fromJson(const {'type': 'future'}),
        throwsFormatException,
      );
      expect(
        () => UnknownResponsesServerEvent.fromJson(const {
          'type': 'response.audio.done',
        }),
        throwsFormatException,
      );
    });

    test(
      'ordinary direct construction rejects narrow SSE error and unknown frames',
      () {
        for (final event in <ResponseStreamEvent>[
          const ErrorEvent(code: 'private code', message: 'private message'),
          const UnknownEvent(type: 'future', rawJson: {'type': 'future'}),
          const UnknownEvent(
            type: 'response.audio.done',
            rawJson: {'type': 'response.audio.done'},
          ),
        ]) {
          final envelope = ResponsesStreamEvent(event: event);
          expect(envelope.toJson, throwsFormatException);
          expect(
            () => envelope.copyWith(streamId: 'lane').toJson(),
            throwsFormatException,
          );
          expect(envelope.toString(), isNot(contains('private message')));
          expect(envelope, envelope.copyWith());
          expect(envelope.hashCode, envelope.copyWith().hashCode);
        }
      },
    );

    test(
      'typed edits override stale known raw values and reparse as equals',
      () {
        final original = ResponsesErrorEvent.fromJson(_errorJson());
        final changed = original.copyWith(
          status: null,
          streamId: 'new lane',
          agent: null,
          error: original.error.copyWith(
            message: 'new message',
            code: null,
            headers: null,
            misalignment: original.error.misalignment!.copyWith(
              detailedExplanation: null,
              errorType: 'new classification',
              reviewTarget: null,
              steer: original.error.misalignment!.steer!.copyWith(
                message: 'new instruction',
              ),
            ),
          ),
        );
        final reparsed = ResponsesErrorEvent.fromJson(changed.toJson());
        expect(changed, reparsed);
        expect(changed.hashCode, reparsed.hashCode);
        expect(changed.error, reparsed.error);
        expect(changed.error.hashCode, reparsed.error.hashCode);
        expect(changed.error.misalignment, reparsed.error.misalignment);
        expect(
          changed.error.misalignment!.hashCode,
          reparsed.error.misalignment!.hashCode,
        );
        expect(
          changed.error.misalignment!.steer,
          reparsed.error.misalignment!.steer,
        );
        expect(
          changed.error.misalignment!.steer!.hashCode,
          reparsed.error.misalignment!.steer!.hashCode,
        );
        expect(changed.toJson().containsKey('status'), isFalse);
        expect(changed.error.toJson().containsKey('headers'), isFalse);
        expect(
          changed.error.misalignment!.toJson().containsKey(
            'detailed_explanation',
          ),
          isFalse,
        );
      },
    );

    test(
      'raw known collisions are ignored while future raw differences affect value',
      () {
        const a = ResponsesMisalignmentSteer(
          message: 'typed',
          rawJson: {
            'message': 'old',
            'future': <dynamic>[1],
          },
        );
        const b = ResponsesMisalignmentSteer(
          message: 'typed',
          rawJson: {
            'message': 'other old',
            'future': <dynamic>[1],
          },
        );
        const c = ResponsesMisalignmentSteer(
          message: 'typed',
          rawJson: {
            'message': 'old',
            'future': <dynamic>[2],
          },
        );
        expect(a, b);
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(c));
      },
    );

    test(
      'invalid const review target can be inspected and compared safely',
      () {
        const a = ResponsesMisalignmentDetails(reviewTarget: 'invalid target');
        const b = ResponsesMisalignmentDetails(reviewTarget: 'invalid target');
        expect(a, b);
        expect(a.hashCode, b.hashCode);
        expect(() => a.toJson(), throwsFormatException);
      },
    );
  });

  group('ResponsesCreateEvent', () {
    test('default create composes the HTTP request', () {
      const event = ResponsesCreateEvent(request: _request);
      expect(event.type, 'response.create');
      expect(event.toJson(), {
        'model': 'gpt-6-sol',
        'input': 'private prompt',
        'type': 'response.create',
      });
      expect(_request.toJson().containsKey('stream_id'), isFalse);
      expect(_request.toJson().containsKey('generate'), isFalse);
    });

    for (final stream in <bool?>[null, false, true]) {
      for (final background in <bool?>[null, false]) {
        for (final generate in <bool?>[null, false, true]) {
          test('stream=$stream background=$background generate=$generate', () {
            final request = _request.copyWith(
              stream: stream,
              background: background,
              streamOptions: const StreamOptions(includeUsage: true),
              previousResponseId: 'resp_parent',
              store: false,
              tools: const [ToolSearchTool()],
              accessPrograms: const AccessProgramsParam(
                cyber: CyberAccessProgram.daybreakBlue,
              ),
            );
            final event = ResponsesCreateEvent(
              request: request,
              streamId: 'lane_1.2-3',
              generate: generate,
            );
            final json = event.toJson();
            final expected = request.toJson()
              ..remove('stream')
              ..remove('background');
            expect(json, {
              ...expected,
              'type': 'response.create',
              'stream_id': 'lane_1.2-3',
              'generate': ?generate,
            });
            expect(json['stream_options'], {'include_usage': true});
            expect(ResponsesCreateEvent.fromJson(json).toJson(), json);
            expect(request.stream, stream);
            expect(request.background, background);
          });
        }
      }
    }

    for (final lane in ['a', 'A0_.-', 'a' * 256]) {
      test('accepts valid create lane length=${lane.length}', () {
        final json = ResponsesCreateEvent(
          request: _request,
          streamId: lane,
        ).toJson();
        expect(json['stream_id'], lane);
        expect(ResponsesCreateEvent.fromJson(json).streamId, lane);
      });
    }

    for (final lane in [
      '',
      'a' * 257,
      'a b',
      '/',
      'é',
      'a\n',
      'a\r',
      'a\u0000',
    ]) {
      test('rejects invalid create lane ${jsonEncode(lane)}', () {
        expect(
          () =>
              ResponsesCreateEvent(request: _request, streamId: lane).toJson(),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('stream_id'),
            ),
          ),
        );
        expect(
          () => ResponsesCreateEvent.fromJson({
            ..._request.toJson(),
            'type': 'response.create',
            'stream_id': lane,
          }),
          throwsFormatException,
        );
      });
    }

    test('rejects background true without leaking input', () {
      expect(
        () => ResponsesCreateEvent(
          request: _request.copyWith(background: true),
        ).toJson(),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'safe context',
            allOf(contains('background'), isNot(contains('private prompt'))),
          ),
        ),
      );
      expect(
        () => ResponsesCreateEvent.fromJson({
          ..._request.toJson(),
          'type': 'response.create',
          'background': true,
        }),
        throwsFormatException,
      );
    });

    for (final field in [
      'type',
      'model',
      'input',
      'stream_id',
      'generate',
      'stream',
      'background',
    ]) {
      for (final bad in <Object?>[null, 1, <String, dynamic>{}, <dynamic>[]]) {
        if (field == 'input' && bad is List) continue;
        if ((field == 'stream' || field == 'background') && bad == null) {
          continue;
        }
        test('malformed create $field ${bad.runtimeType}', () {
          final json = <String, dynamic>{
            ..._request.toJson(),
            'type': 'response.create',
            field: bad,
          };
          expect(
            () => ResponsesCreateEvent.fromJson(json),
            throwsFormatException,
          );
        });
      }
    }

    for (final unused in <Map<String, dynamic>>[
      {'stream': null, 'background': null},
      {'stream': null, 'background': false},
      {'stream': true, 'background': null},
    ]) {
      test(
        'inherited nullable unused fields normalize ${jsonEncode(unused)}',
        () {
          final parsed = ResponsesCreateEvent.fromJson({
            ..._request.toJson(),
            'type': 'response.create',
            ...unused,
          });
          expect(parsed.toJson(), {
            ..._request.toJson(),
            'type': 'response.create',
          });
          expect(parsed.request.stream, isNull);
          expect(parsed.request.background, isNull);
        },
      );
    }

    test('copy retains omitted values and clears nullable metadata', () {
      const original = ResponsesCreateEvent(
        request: _request,
        streamId: 'lane',
        generate: false,
      );
      expect(original.copyWith(), original);
      expect(original.copyWith().hashCode, original.hashCode);
      final cleared = original.copyWith(streamId: null, generate: null);
      expect(cleared.streamId, isNull);
      expect(cleared.generate, isNull);
      expect(cleared.toJson().containsKey('stream_id'), isFalse);
      expect(cleared.toJson().containsKey('generate'), isFalse);
      expect(
        original.copyWith(request: _request.copyWith(model: 'other')),
        isNot(original),
      );
      expect(original.copyWith(streamId: 'other'), isNot(original));
      expect(original.copyWith(generate: true), isNot(original));
    });

    test(
      'parsed snapshots are detached and have immutable outer collections',
      () {
        final source = <String, dynamic>{
          'type': 'response.create',
          'model': 'gpt-6-sol',
          'input': 'input',
          'tools': <Map<String, dynamic>>[
            {'type': 'tool_search'},
          ],
          'include': <String>['web_search_call.results'],
          'metadata': <String, dynamic>{'key': 'value'},
        };
        final parsed = ResponsesCreateEvent.fromJson(source);
        (source['metadata'] as Map<String, dynamic>)['key'] = 'changed';
        (source['tools'] as List<Map<String, dynamic>>).clear();
        expect(parsed.request.metadata, {'key': 'value'});
        expect(parsed.request.tools, hasLength(1));
        expect(() => parsed.request.tools!.clear(), throwsUnsupportedError);
        expect(() => parsed.request.include!.clear(), throwsUnsupportedError);
        expect(() => parsed.request.metadata!.clear(), throwsUnsupportedError);
      },
    );

    test('caller-owned const request semantics and safe diagnostics', () {
      final metadata = <String, dynamic>{'private key': 'private value'};
      final request = _request.copyWith(metadata: metadata);
      final event = ResponsesCreateEvent(
        request: request,
        streamId: 'private lane',
      );
      expect(identical(event.request, request), isTrue);
      metadata['later'] = 'value';
      expect(event.request.metadata!['later'], 'value');
      expect(event.toString(), contains('request: present'));
      expect(event.toString(), isNot(contains('private')));
    });
  });

  group('ResponsesServerEvent shared codec', () {
    test('covers all 58 currently canonical ordinary discriminators', () {
      expect(responsesWebSocketEventFixtures(), hasLength(58));
      expect(
        responsesWebSocketEventFixtures().map((e) => e['type']).toSet(),
        hasLength(58),
      );
    });

    for (final fixture in responsesWebSocketEventFixtures()) {
      for (final lane in <String?>[null, 'lane.1', 'returned lane / é']) {
        test('${fixture['type']} lane=$lane', () {
          final json = _fresh({
            ...fixture,
            'stream_id': ?lane,
            'future_metadata': {
              'nested': <dynamic>[1, true, null],
            },
          });
          final parsed = ResponsesServerEvent.fromJson(json);
          expect(parsed, isA<ResponsesStreamEvent>());
          final typed = parsed as ResponsesStreamEvent;
          expect(typed.type, fixture['type']);
          expect(typed.event, isNot(isA<UnknownEvent>()));
          expect(typed.streamId, lane);
          expect(typed.rawJson, json);
          expect(typed.toJson(), json);
          expect(ResponsesServerEvent.fromJson(_fresh(json)), typed);
          expect(
            ResponsesServerEvent.fromJson(_fresh(json)).hashCode,
            typed.hashCode,
          );
          expect(typed.copyWith(), typed);
          expect(
            typed.copyWith(streamId: null).toJson().containsKey('stream_id'),
            isFalse,
          );
          expect(typed.copyWith(streamId: 'different'), isNot(typed));
          expect(typed.rawJson.clear, throwsUnsupportedError);
          expect(
            () => (typed.rawJson['future_metadata'] as Map<String, dynamic>)
                .clear(),
            throwsUnsupportedError,
          );
        });
      }
    }

    test('nested future metadata is retained in shared typed DTOs', () {
      final source = _fresh(
        responsesWebSocketEventFixtures().firstWhere(
          (event) => event['type'] == 'response.created',
        ),
      );
      (source['response'] as Map<String, dynamic>)['future_response'] = {
        'nested': <dynamic>[
          {'opaque': 'private content'},
        ],
      };
      final parsed = ResponsesServerEvent.fromJson(source);
      expect(parsed.toJson(), source);
      expect(parsed.toString(), isNot(contains('private content')));
    });

    test(
      'same-type edits retain nested future fields and clear known fields',
      () {
        final source = _fresh(
          responsesWebSocketEventFixtures().firstWhere(
            (event) => event['type'] == 'response.created',
          ),
        );
        final response = source['response'] as Map<String, dynamic>;
        response['instructions'] = 'old instructions';
        response['future_response'] = {'kept': true};
        response['output'] = <Map<String, dynamic>>[
          {
            'type': 'message',
            'id': 'message_1',
            'role': 'assistant',
            'status': 'completed',
            'future_item': {'kept': true},
            'content': <Map<String, dynamic>>[
              {
                'type': 'output_text',
                'text': 'old text',
                'annotations': <dynamic>[],
                'future_content': {'kept': true},
              },
            ],
          },
        ];
        final parsed = ResponsesStreamEvent.fromJson(source);
        final created = parsed.event as ResponseCreatedEvent;
        final sequenceEdit = parsed.copyWith(
          event: created.copyWith(sequenceNumber: 2),
        );
        final sequenceJson = sequenceEdit.toJson();
        expect(sequenceJson['response'], source['response']);
        expect(sequenceJson['sequence_number'], 2);
        expect(sequenceEdit.rawJson.clear, throwsUnsupportedError);
        expect(
          () => (sequenceEdit.rawJson['response'] as Map<String, dynamic>)
              .clear(),
          throwsUnsupportedError,
        );
        expect(sequenceEdit, ResponsesStreamEvent.fromJson(sequenceJson));
        expect(
          sequenceEdit.hashCode,
          ResponsesStreamEvent.fromJson(sequenceJson).hashCode,
        );

        final item = created.response.output.single as MessageOutputItem;
        final text = item.content.single as OutputTextContent;
        final updatedItem = MessageOutputItem(
          id: item.id,
          role: item.role,
          status: item.status,
          content: [text.copyWith(text: 'new text', annotations: null)],
        );
        final nestedEdit = parsed.copyWith(
          event: created.copyWith(
            response: created.response.copyWith(
              instructions: null,
              output: [updatedItem],
            ),
          ),
        );
        final updatedResponse =
            nestedEdit.toJson()['response'] as Map<String, dynamic>;
        expect(updatedResponse.containsKey('instructions'), isFalse);
        expect(updatedResponse['future_response'], {'kept': true});
        final updatedRawItem =
            (updatedResponse['output'] as List<dynamic>).single
                as Map<String, dynamic>;
        expect(updatedRawItem['future_item'], {'kept': true});
        final updatedContent =
            (updatedRawItem['content'] as List<dynamic>).single
                as Map<String, dynamic>;
        expect(updatedContent['text'], 'new text');
        expect(updatedContent['future_content'], {'kept': true});
        expect(updatedContent.containsKey('annotations'), isFalse);

        final clearedList = parsed.copyWith(
          event: created.copyWith(
            response: created.response.copyWith(output: <OutputItem>[]),
          ),
        );
        expect(
          (clearedList.toJson()['response'] as Map<String, dynamic>)['output'],
          isEmpty,
        );
        final changedIdentity = parsed.copyWith(
          event: created.copyWith(
            response: created.response.copyWith(
              output: [
                MessageOutputItem(
                  id: 'different_message',
                  role: item.role,
                  content: item.content,
                ),
              ],
            ),
          ),
        );
        final replacementRawItem =
            ((changedIdentity.toJson()['response']
                            as Map<String, dynamic>)['output']
                        as List<dynamic>)
                    .single
                as Map<String, dynamic>;
        expect(replacementRawItem.containsKey('future_item'), isFalse);
      },
    );

    test('replacing a typed event does not resurrect its cleared fields', () {
      final parsed =
          ResponsesServerEvent.fromJson(const {
                'type': 'response.output_text.delta',
                'sequence_number': 1,
                'item_id': 'item',
                'output_index': 0,
                'content_index': 0,
                'delta': 'private delta',
                'logprobs': <dynamic>[],
                'future': 'retained',
                'stream_id': 'lane',
              })
              as ResponsesStreamEvent;
      final replacement = parsed.copyWith(
        event: const ResponseAudioDoneEvent(sequenceNumber: 2),
      );
      expect(replacement.toJson()['type'], 'response.audio.done');
      expect(replacement.toJson().containsKey('delta'), isFalse);
      expect(replacement.toJson()['future'], 'retained');
      expect(replacement.toJson()['stream_id'], 'lane');
      expect(replacement, isNot(parsed));
      expect(parsed.toString(), isNot(contains('private delta')));
    });

    for (final json in <Map<String, dynamic>>[
      <String, dynamic>{},
      {'type': null},
      {'type': 1},
      {'type': 'response.output_text.delta'},
      {'type': 'response.output_text.delta', 'delta': 1},
      {'type': 'response.created', 'response': 'private invalid payload'},
      {'type': 'response.created', 'response': <String, dynamic>{}},
      {'type': 'response.compaction.compacting', 'sequence_number': null},
    ]) {
      test('known malformed frame ${jsonEncode(json)} fails contextually', () {
        expect(
          () => ResponsesServerEvent.fromJson(json),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              allOf(
                contains('ResponsesServerEvent'),
                isNot(contains('private')),
              ),
            ),
          ),
        );
      });
    }

    for (final bad in <Object?>[
      null,
      1,
      true,
      <dynamic>[],
      <String, dynamic>{},
    ]) {
      test('server stream_id wrong type ${bad.runtimeType}', () {
        expect(
          () => ResponsesServerEvent.fromJson({
            'type': 'future',
            'stream_id': bad,
          }),
          throwsFormatException,
        );
      });
    }

    for (final type in ['future.private']) {
      test('future/raw message $type preserves arbitrary nested fields', () {
        final source = <String, dynamic>{
          'type': type,
          'stream_id': '',
          'sequence_number': 'future untyped metadata',
          'payload': {
            'content': <dynamic>[
              null,
              1,
              1.25,
              -2,
              false,
              {'private': 'payload'},
            ],
          },
        };
        final parsed =
            ResponsesServerEvent.fromJson(source)
                as UnknownResponsesServerEvent;
        expect(parsed.type, type);
        expect(parsed.streamId, '');
        expect(parsed.toJson(), source);
        expect(ResponsesServerEvent.fromJson(_fresh(source)), parsed);
        expect(
          ResponsesServerEvent.fromJson(_fresh(source)).hashCode,
          parsed.hashCode,
        );
        expect(parsed.copyWith(), parsed);
        expect(parsed.copyWith(type: 'other').toJson()['type'], 'other');
        expect(
          parsed.copyWith(streamId: null).toJson().containsKey('stream_id'),
          isFalse,
        );
        expect(parsed.copyWith(rawJson: const {'future': 1}).toJson(), {
          'future': 1,
          'type': type,
          'stream_id': '',
        });
        expect(parsed.toString(), isNot(contains('payload')));
        (source['payload'] as Map<String, dynamic>).clear();
        expect(parsed.rawJson['payload'], isNot(isEmpty));
        expect(
          () => (parsed.rawJson['payload'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
      });
    }

    for (final bad in <Object?>[
      double.nan,
      double.infinity,
      Object(),
      DateTime(2026),
    ]) {
      test('non-JSON future payload ${bad.runtimeType}', () {
        expect(
          () =>
              ResponsesServerEvent.fromJson({'type': 'future', 'payload': bad}),
          throwsFormatException,
        );
      });
    }
    test('non-string nested object keys fail safely', () {
      expect(
        () => ResponsesServerEvent.fromJson(const {
          'type': 'future',
          'payload': <Object?, Object?>{1: null},
        }),
        throwsFormatException,
      );
    });
  });

  group('ResponsesErrorEvent and complete payload', () {
    test('full nested metadata survives exact round trip', () {
      final source = _errorJson();
      final parsed =
          ResponsesServerEvent.fromJson(source) as ResponsesErrorEvent;
      expect(parsed.error.type, 'invalid_request_error');
      expect(parsed.error.code, 'future_error_code');
      expect(parsed.error.hasCode, isTrue);
      expect(parsed.error.hasParam, isTrue);
      expect(parsed.agent!.agentName, 'private owner');
      expect(parsed.error.misalignment!.errorType, 'future classification');
      expect(parsed.toJson(), source);
      expect(ResponsesServerEvent.fromJson(_fresh(source)), parsed);
      expect(
        ResponsesServerEvent.fromJson(_fresh(source)).hashCode,
        parsed.hashCode,
      );
      expect(parsed.copyWith(), parsed);
      expect(parsed.error.copyWith(), parsed.error);
      expect(parsed.error.misalignment!.copyWith(), parsed.error.misalignment);
      expect(
        parsed.error.misalignment!.steer!.copyWith(),
        parsed.error.misalignment!.steer,
      );
    });

    test('exact guide connection-limit error accepts omitted param', () {
      final json = <String, dynamic>{
        'type': 'error',
        'status': 400,
        'error': {
          'type': 'invalid_request_error',
          'code': 'websocket_connection_limit_reached',
          'message':
              'Responses websocket connection limit reached (60 minutes). Create a new websocket connection to continue.',
        },
      };
      final parsed = ResponsesServerEvent.fromJson(json) as ResponsesErrorEvent;
      expect(parsed.error.hasCode, isTrue);
      expect(parsed.error.hasParam, isFalse);
      expect(parsed.toJson(), json);
    });

    for (final codeState in ['absent', 'null', 'value']) {
      for (final paramState in ['absent', 'null', 'value']) {
        test('presence code=$codeState param=$paramState', () {
          final json = <String, dynamic>{
            'type': 'future_error_type',
            'message': 'error',
            if (codeState != 'absent')
              'code': codeState == 'null' ? null : 'future_code',
            if (paramState != 'absent')
              'param': paramState == 'null' ? null : 'future_param',
          };
          final parsed = ResponsesErrorPayload.fromJson(json);
          expect(parsed.hasCode, codeState != 'absent');
          expect(parsed.hasParam, paramState != 'absent');
          expect(parsed.toJson(), json);
          expect(parsed.copyWith().toJson(), json);
          expect(ResponsesErrorPayload.fromJson(_fresh(json)), parsed);
          expect(
            ResponsesErrorPayload.fromJson(_fresh(json)).hashCode,
            parsed.hashCode,
          );
          expect(parsed.copyWith(code: null).toJson()['code'], isNull);
          expect(
            parsed.copyWith(code: null).toJson().containsKey('code'),
            isTrue,
          );
          expect(
            parsed.copyWith(param: null).toJson().containsKey('param'),
            isTrue,
          );
          expect(
            parsed
                .copyWith(code: null, hasCode: false)
                .toJson()
                .containsKey('code'),
            isFalse,
          );
          expect(
            parsed
                .copyWith(param: null, hasParam: false)
                .toJson()
                .containsKey('param'),
            isFalse,
          );
        });
      }
    }

    test('new canonical construction emits nullable code and param keys', () {
      const payload = ResponsesErrorPayload(type: 'type', message: 'message');
      expect(payload.toJson(), {
        'type': 'type',
        'message': 'message',
        'code': null,
        'param': null,
      });
      expect(payload, isNot(payload.copyWith(hasCode: false)));
      expect(payload, isNot(payload.copyWith(hasParam: false)));
    });

    test('all envelope copy fields affect value and clear output', () {
      final parsed = ResponsesErrorEvent.fromJson(_errorJson());
      for (final changed in [
        parsed.copyWith(error: _error),
        parsed.copyWith(status: 401),
        parsed.copyWith(sequenceNumber: 4),
        parsed.copyWith(streamId: 'other'),
        parsed.copyWith(agent: const AgentTag(agentName: 'other')),
        parsed.copyWith(agent: null, hasAgent: false),
        parsed.copyWith(
          rawJson: const {
            'future': <dynamic>[1],
          },
        ),
      ]) {
        expect(changed, isNot(parsed));
      }
      final cleared = parsed.copyWith(
        status: null,
        sequenceNumber: null,
        streamId: null,
        agent: null,
      );
      expect(cleared.toJson().containsKey('status'), isFalse);
      expect(cleared.toJson().containsKey('sequence_number'), isFalse);
      expect(cleared.toJson().containsKey('stream_id'), isFalse);
      expect(cleared.toJson()['agent'], isNull);
      expect(cleared.toJson().containsKey('agent'), isTrue);
      expect(
        cleared.copyWith(hasAgent: false).toJson().containsKey('agent'),
        isFalse,
      );
      expect(
        parsed
            .copyWith(agent: const AgentTag(agentName: 'other'))
            .toJson()['agent'],
        {'agent_name': 'other'},
      );
    });

    test('all error payload copy fields affect value and clear typed keys', () {
      final original = ResponsesErrorPayload.fromJson(
        _errorJson()['error'] as Map<String, dynamic>,
      );
      for (final changed in [
        original.copyWith(type: 'other'),
        original.copyWith(message: 'other'),
        original.copyWith(code: 'other'),
        original.copyWith(param: 'other'),
        original.copyWith(code: null, hasCode: false),
        original.copyWith(param: null, hasParam: false),
        original.copyWith(headers: const {'other': 'header'}),
        original.copyWith(misalignment: const ResponsesMisalignmentDetails()),
        original.copyWith(
          rawJson: const {
            'future': <dynamic>[1],
          },
        ),
      ]) {
        expect(changed, isNot(original));
      }
      final cleared = original.copyWith(headers: null, misalignment: null);
      expect(cleared.toJson().containsKey('headers'), isFalse);
      expect(cleared.toJson().containsKey('misalignment'), isFalse);
      expect(
        cleared.toJson()['future_error'],
        original.toJson()['future_error'],
      );
    });

    for (final agentState in ['absent', 'null', 'value']) {
      test('nullable beta agent presence $agentState', () {
        final json = <String, dynamic>{
          'type': 'error',
          'error': {'type': 'type', 'message': 'message'},
          if (agentState != 'absent')
            'agent': agentState == 'null' ? null : {'agent_name': 'owner'},
        };
        final parsed = ResponsesErrorEvent.fromJson(json);
        expect(parsed.hasAgent, agentState != 'absent');
        expect(parsed.toJson(), json);
      });
    }

    test('safe diagnostics include fields without opaque values', () {
      final parsed = ResponsesErrorEvent.fromJson(_errorJson());
      for (final model in <Object>[
        parsed,
        parsed.error,
        parsed.error.misalignment!,
        parsed.error.misalignment!.steer!,
      ]) {
        final output = model.toString();
        expect(output, isNot(contains('private')));
        expect(output, isNot(contains('future_error_code')));
        expect(output, contains('rawJson:'));
      }
    });

    test('parsed maps and nested future JSON are immutable snapshots', () {
      final source = _errorJson();
      final parsed = ResponsesErrorEvent.fromJson(source);
      (source['error'] as Map<String, dynamic>)['message'] = 'changed';
      expect(parsed.error.message, 'private error text');
      expect(parsed.rawJson.clear, throwsUnsupportedError);
      expect(() => parsed.error.headers!.clear(), throwsUnsupportedError);
      expect(parsed.error.rawJson.clear, throwsUnsupportedError);
      expect(
        () => parsed.error.misalignment!.rawJson.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => parsed.error.misalignment!.steer!.rawJson.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => (parsed.error.rawJson['future_error'] as Map<String, dynamic>)
            .clear(),
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((parsed.error.rawJson['future_error']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .clear(),
        throwsUnsupportedError,
      );
    });

    for (final field in ['status', 'sequence_number', 'stream_id', 'error']) {
      for (final bad in <Object?>[null, false, <dynamic>[]]) {
        test('malformed envelope $field ${bad.runtimeType}', () {
          final json = _errorJson()..[field] = bad;
          expect(
            () => ResponsesServerEvent.fromJson(json),
            throwsFormatException,
          );
        });
      }
    }
    for (final bad in <Object?>[
      true,
      'owner',
      <dynamic>[],
      <String, dynamic>{},
      {'agent_name': null},
      {'agent_name': 1},
    ]) {
      test('malformed beta agent ${jsonEncode(bad)}', () {
        expect(
          () => ResponsesErrorEvent.fromJson(_errorJson()..['agent'] = bad),
          throwsFormatException,
        );
      });
    }
    test('direct error factory validates its discriminator', () {
      expect(
        () => ResponsesErrorEvent.fromJson(_errorJson()..['type'] = 'other'),
        throwsFormatException,
      );
    });

    for (final field in [
      'type',
      'message',
      'code',
      'param',
      'headers',
      'misalignment',
    ]) {
      for (final bad in <Object?>[true, 1, <dynamic>[]]) {
        test('malformed error payload $field ${bad.runtimeType}', () {
          final json = _errorJson()['error'] as Map<String, dynamic>;
          json[field] = bad;
          expect(
            () => ResponsesErrorPayload.fromJson(json),
            throwsFormatException,
          );
        });
      }
    }
    for (final field in ['type', 'message', 'headers', 'misalignment']) {
      test('nonnull payload $field rejects null', () {
        final json = _errorJson()['error'] as Map<String, dynamic>;
        json[field] = null;
        expect(
          () => ResponsesErrorPayload.fromJson(json),
          throwsFormatException,
        );
      });
    }
    for (final field in ['type', 'message']) {
      test('required payload $field rejects omission', () {
        final json = (_errorJson()['error'] as Map<String, dynamic>)
          ..remove(field);
        expect(
          () => ResponsesErrorPayload.fromJson(json),
          throwsFormatException,
        );
      });
    }
    test('header values are strings, and malformed values remain redacted', () {
      expect(
        () => ResponsesErrorPayload.fromJson(const {
          'type': 'type',
          'message': 'message',
          'headers': {'private header': 1},
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'safe context',
            allOf(contains('headers'), isNot(contains('private'))),
          ),
        ),
      );
    });
  });

  group('ResponsesMisalignmentDetails and steer', () {
    test('empty details are valid and optional fields remain absent', () {
      expect(ResponsesMisalignmentDetails.fromJson(const {}).toJson(), isEmpty);
    });
    for (final targetState in ['absent', 'null', 'value']) {
      test('nullable review target $targetState', () {
        final json = <String, dynamic>{
          'error_type': 'future',
          if (targetState != 'absent')
            'review_target': targetState == 'null' ? null : 'valid_Review:~.-1',
        };
        final parsed = ResponsesMisalignmentDetails.fromJson(json);
        expect(parsed.hasReviewTarget, targetState != 'absent');
        expect(parsed.toJson(), json);
        expect(
          parsed
              .copyWith(reviewTarget: null)
              .toJson()
              .containsKey('review_target'),
          isTrue,
        );
        expect(
          parsed
              .copyWith(reviewTarget: null, hasReviewTarget: false)
              .toJson()
              .containsKey('review_target'),
          isFalse,
        );
      });
    }
    test('copy updates every field and clears optional known metadata', () {
      final original = ResponsesMisalignmentDetails.fromJson(
        (_errorJson()['error'] as Map<String, dynamic>)['misalignment']
            as Map<String, dynamic>,
      );
      for (final changed in [
        original.copyWith(detailedExplanation: 'other'),
        original.copyWith(errorType: 'other'),
        original.copyWith(reviewTarget: 'other'),
        original.copyWith(reviewTarget: null, hasReviewTarget: false),
        original.copyWith(
          steer: const ResponsesMisalignmentSteer(message: 'other'),
        ),
        original.copyWith(
          rawJson: const {
            'future': <dynamic>[1],
          },
        ),
      ]) {
        expect(changed, isNot(original));
      }
      final cleared = original.copyWith(
        detailedExplanation: null,
        errorType: null,
        reviewTarget: null,
        hasReviewTarget: false,
        steer: null,
      );
      expect(cleared.toJson(), {
        'future_detail': {
          'nested': <dynamic>[true, null],
        },
      });
      final steer = original.steer!;
      expect(steer.copyWith(message: 'other').toJson(), {
        'message': 'other',
        'future_steer': <dynamic>[1],
      });
      expect(steer.copyWith(message: 'other'), isNot(steer));
      expect(
        steer.copyWith(
          rawJson: const {
            'future': <dynamic>[2],
          },
        ),
        isNot(steer),
      );
    });
    for (final target in [
      '',
      'x' * 97,
      'bad space',
      'é',
      'target\n',
      'target/',
      'target\u0000',
    ]) {
      test('opaque target malformed ${jsonEncode(target)}', () {
        expect(
          () =>
              ResponsesMisalignmentDetails.fromJson({'review_target': target}),
          throwsFormatException,
        );
        expect(
          () => ResponsesMisalignmentDetails(reviewTarget: target).toJson(),
          throwsFormatException,
        );
      });
    }
    test('opaque target accepts exact 96-character boundary', () {
      final target = 'x' * 96;
      expect(
        ResponsesMisalignmentDetails.fromJson({
          'review_target': target,
        }).reviewTarget,
        target,
      );
    });
    for (final field in [
      'detailed_explanation',
      'error_type',
      'review_target',
      'steer',
    ]) {
      for (final bad in <Object?>[1, false, <dynamic>[]]) {
        test('malformed review metadata $field ${bad.runtimeType}', () {
          expect(
            () => ResponsesMisalignmentDetails.fromJson({field: bad}),
            throwsFormatException,
          );
        });
      }
    }
    for (final field in ['detailed_explanation', 'error_type', 'steer']) {
      test('nonnull review metadata $field rejects null', () {
        expect(
          () => ResponsesMisalignmentDetails.fromJson({field: null}),
          throwsFormatException,
        );
      });
    }
    for (final json in <Map<String, dynamic>>[
      <String, dynamic>{},
      {'message': null},
      {'message': 1},
      {'message': false},
    ]) {
      test('malformed continuation ${jsonEncode(json)}', () {
        expect(
          () => ResponsesMisalignmentSteer.fromJson(json),
          throwsFormatException,
        );
        expect(
          () => ResponsesMisalignmentDetails.fromJson({'steer': json}),
          throwsFormatException,
        );
      });
    }
    test('deep value equality and insertion-order-independent hashes', () {
      final a = ResponsesMisalignmentDetails.fromJson(const {
        'future': {
          'a': <dynamic>[1, null],
          'b': true,
        },
      });
      final b = ResponsesMisalignmentDetails.fromJson(const {
        'future': {
          'b': true,
          'a': <dynamic>[1, null],
        },
      });
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      final headerA = ResponsesErrorPayload.fromJson(const {
        'type': 'type',
        'message': 'message',
        'headers': {'a': '1', 'b': '2'},
      });
      final headerB = ResponsesErrorPayload.fromJson(const {
        'headers': {'b': '2', 'a': '1'},
        'message': 'message',
        'type': 'type',
      });
      expect(headerA, headerB);
      expect(headerA.hashCode, headerB.hashCode);
    });
    test('new const models retain caller-owned collection construction', () {
      final raw = <String, dynamic>{
        'future': <dynamic>[1],
      };
      final headers = <String, String>{'key': 'value'};
      final payload = ResponsesErrorPayload(
        type: 'type',
        message: 'message',
        headers: headers,
        rawJson: raw,
      );
      expect(identical(payload.rawJson, raw), isTrue);
      expect(identical(payload.headers, headers), isTrue);
      raw['later'] = true;
      headers['later'] = 'value';
      expect(payload.toJson()['later'], isTrue);
      expect(payload.headers!['later'], 'value');
    });
  });
}
