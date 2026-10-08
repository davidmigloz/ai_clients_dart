import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/models/responses/multi_agent/response_inject_event.dart'
    as legacy;
import 'package:test/test.dart';

const _error = ResponseInjectError(
  code: ResponseInjectErrorCode.responseAlreadyCompleted,
  message: 'private message',
);

Map<String, dynamic> _fresh(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
Map<String, dynamic> _ack(String kind) => <String, dynamic>{
  'type': 'response.inject.$kind',
  'response_id': 'resp_private',
  'sequence_number': 3,
  'stream_id': 'private lane / é',
  if (kind == 'failed')
    'input': <Object?>[
      null,
      false,
      1,
      1.25,
      [
        'nested',
        {'private': true},
      ],
      {'type': 'function_call_output', 'output': null},
      {
        'type': 'future_private_item',
        'encrypted_content': 'private payload',
        'future': {
          'nested': [null, true],
        },
      },
    ],
  if (kind == 'failed')
    'error': <String, dynamic>{
      'code': 'future_private_code',
      'message': 'private message',
      'future_error': {
        'nested': [null, false],
      },
    },
  'agent': {'agent_name': '/root/private'},
  'future': {
    'nested': [true, 1.25],
  },
};

void _equal(Object first, Object second) {
  expect(first, second);
  expect(second, first);
  expect(first.hashCode, second.hashCode);
}

void main() {
  group('injection request contract', () {
    for (final input in <List<Item>>[
      [],
      [MessageItem.userText('private input')],
      [const ItemReference(id: 'private reference')],
      [
        FunctionCallOutputItem.string(
          callId: 'private call',
          output: 'private output',
        ),
      ],
      [
        const CustomToolCallOutputInputItem(
          callId: 'private call',
          output: FunctionCallOutputString('private output'),
        ),
      ],
    ]) {
      test(
        'broad existing Item surface ${input.isEmpty ? 'empty' : input.single.runtimeType}',
        () {
          final event = ResponseInjectEvent(
            responseId: 'private response',
            input: input,
          );
          final json = event.toJson();
          expect(json.keys.toSet(), {'type', 'response_id', 'input'});
          expect(json['type'], 'response.inject');
          expect(json['input'], input.map((item) => item.toJson()).toList());
          final parsed = ResponseInjectEvent.fromJson(_fresh(json));
          _equal(event, parsed);
          expect(parsed.input.clear, throwsUnsupportedError);
          expect(event.toString(), isNot(contains('private')));
          _equal(event, event.copyWith());
          expect(event.copyWith(responseId: 'changed'), isNot(event));
        },
      );
    }

    for (final count in [16384, 16385]) {
      test('actual max boundary $count in constructor and parser', () {
        final items = List<Item>.filled(count, const ItemReference(id: 'ref'));
        final event = ResponseInjectEvent(responseId: 'response', input: items);
        final json = <String, dynamic>{
          'type': 'response.inject',
          'response_id': 'response',
          'input': List<Map<String, dynamic>>.filled(count, const {
            'type': 'item_reference',
            'id': 'ref',
          }),
        };
        if (count == 16384) {
          expect(event.toJson()['input'], hasLength(count));
          expect(ResponseInjectEvent.fromJson(json).input, hasLength(count));
        } else {
          expect(event.toJson, throwsFormatException);
          expect(
            () => ResponseInjectEvent.fromJson(json),
            throwsFormatException,
          );
          _equal(event, event.copyWith());
          expect(event.toString(), contains('16385 items'));
        }
      });
    }

    for (final extra in [
      'stream_id',
      'stream',
      'model',
      'tools',
      'background',
      'agent',
      'previous_response_id',
      'future',
    ]) {
      test(
        'finite extra $extra is tolerated but not projected into a write',
        () {
          final parsed = ResponseInjectEvent.fromJson({
            'type': 'response.inject',
            'response_id': 'private',
            'input': const <dynamic>[],
            extra: const {
              'private value': [true, null, 1.25],
            },
          });
          expect(parsed.toJson(), {
            'type': 'response.inject',
            'response_id': 'private',
            'input': const <dynamic>[],
          });
          expect(parsed.toJson().keys.toSet(), {
            'type',
            'response_id',
            'input',
          });
        },
      );
    }
    for (final field in ['type', 'response_id', 'input']) {
      test('required request $field missing', () {
        final json = <String, dynamic>{
          'type': 'response.inject',
          'response_id': 'private',
          'input': <dynamic>[],
        }..remove(field);
        expect(() => ResponseInjectEvent.fromJson(json), throwsFormatException);
      });
    }
    for (final input in <Object?>[
      null,
      true,
      1,
      1.25,
      'private',
      <String, dynamic>{},
    ]) {
      test('nonarray request input ${input.runtimeType}', () {
        expect(
          () => ResponseInjectEvent.fromJson({
            'type': 'response.inject',
            'response_id': 'private',
            'input': input,
          }),
          throwsFormatException,
        );
      });
    }
    for (final responseId in <Object?>[
      null,
      true,
      1,
      <dynamic>[],
      <String, dynamic>{},
    ]) {
      test('nonstrings request response ID ${responseId.runtimeType}', () {
        expect(
          () => ResponseInjectEvent.fromJson({
            'type': 'response.inject',
            'response_id': responseId,
            'input': const <dynamic>[],
          }),
          throwsFormatException,
        );
      });
    }
    for (final input in <Object?>[
      null,
      true,
      1,
      'private',
      <dynamic>[],
      <String, dynamic>{},
      {'type': null},
      {'type': 'future_private_kind'},
      {'type': 'function_call_output', 'call_id': null, 'output': 'private'},
    ]) {
      test(
        'malformed Item is contextual and redacted ${input.runtimeType} $input',
        () {
          expect(
            () => ResponseInjectEvent.fromJson({
              'type': 'response.inject',
              'response_id': 'resp',
              'input': [input],
            }),
            throwsA(
              isA<FormatException>()
                  .having(
                    (error) => error.message,
                    'context',
                    contains('ResponseInjectEvent.input[0]'),
                  )
                  .having(
                    (error) => error.toString(),
                    'redacted',
                    isNot(contains('private')),
                  ),
            ),
          );
        },
      );
    }
    test('wrong discriminator cannot normalize into an injection', () {
      expect(
        () => ResponseInjectEvent.fromJson(const {
          'type': 'response.create',
          'response_id': 'response',
          'input': <dynamic>[],
        }),
        throwsFormatException,
      );
    });
    test('legacy known-item extras and nested ownership remain explicit', () {
      final parsed = ResponseInjectEvent.fromJson(const {
        'type': 'response.inject',
        'response_id': 'response',
        'input': [
          {
            'type': 'item_reference',
            'id': 'ref',
            'future_private': {'kept': true},
          },
        ],
      });
      expect(parsed.toJson()['input'], [
        {'type': 'item_reference', 'id': 'ref'},
      ]);
      final input = <Item>[const ItemReference(id: 'before')];
      final constructed = ResponseInjectEvent(
        responseId: 'response',
        input: input,
      );
      expect(identical(constructed.input, input), isTrue);
      input[0] = const ItemReference(id: 'after');
      expect(constructed.toJson()['input'], [
        {'type': 'item_reference', 'id': 'after'},
      ]);
    });
    test('request wire equality includes changed shared serialized fields', () {
      final first = ResponseInjectEvent(
        responseId: 'response',
        input: [MessageItem.userText('first')],
      );
      final changed = first.copyWith(input: [MessageItem.userText('second')]);
      expect(changed, isNot(first));
      _equal(changed, ResponseInjectEvent.fromJson(changed.toJson()));
    });
  });

  group('typed injection acknowledgements', () {
    test('legacy sublibrary reexports exactly the public declarations', () {
      const created = legacy.ResponseInjectCreatedEvent(
        responseId: 'response',
        sequenceNumber: 1,
      );
      const failed = legacy.ResponseInjectFailedEvent(
        responseId: 'response',
        input: [],
        error: _error,
        sequenceNumber: 1,
      );
      const error = legacy.ResponseInjectError(
        code: legacy.ResponseInjectErrorCode.responseAlreadyCompleted,
        message: 'private message',
      );
      expect(created, isA<ResponseInjectCreatedEvent>());
      expect(failed, isA<ResponseInjectFailedEvent>());
      expect(error, _error);
      expect(created, isA<ResponsesServerEvent>());
      expect(failed, isA<ResponsesServerEvent>());
    });
    for (final kind in ['created', 'failed']) {
      test(
        'dispatcher keeps all raw fields and optional future agent $kind',
        () {
          final source = _ack(kind);
          final parsed = ResponsesServerEvent.fromJson(source);
          expect(
            parsed,
            kind == 'created'
                ? isA<ResponseInjectCreatedEvent>()
                : isA<ResponseInjectFailedEvent>(),
          );
          expect(parsed.streamId, 'private lane / é');
          expect(parsed.toJson(), source);
          _equal(parsed, ResponsesServerEvent.fromJson(_fresh(source)));
          expect(parsed.toString(), isNot(contains('private')));
          source.clear();
          expect(parsed.rawJson, isNot(isEmpty));
          expect(() => parsed.rawJson.clear(), throwsUnsupportedError);
          expect(
            () => (parsed.rawJson['agent'] as Map<String, dynamic>).clear(),
            throwsUnsupportedError,
          );
        },
      );
      final fields = [
        'type',
        'response_id',
        'sequence_number',
        if (kind == 'failed') ...['input', 'error'],
      ];
      for (final field in fields) {
        test('required acknowledgement $kind $field missing', () {
          final json = _ack(kind)..remove(field);
          expect(
            () => ResponsesServerEvent.fromJson(json),
            throwsFormatException,
          );
        });
      }
      for (final bad in <Object?>[
        null,
        true,
        1.25,
        'private',
        <dynamic>[],
        <String, dynamic>{},
      ]) {
        test('malformed sequence $kind ${bad.runtimeType}', () {
          final json = _ack(kind)..['sequence_number'] = bad;
          expect(
            () => ResponsesServerEvent.fromJson(json),
            throwsFormatException,
          );
        });
      }
      for (final bad in <Object?>[
        null,
        true,
        1,
        <dynamic>[],
        <String, dynamic>{},
      ]) {
        test(
          'malformed nonnullable optional lane $kind ${bad.runtimeType}',
          () {
            final json = _ack(kind)..['stream_id'] = bad;
            expect(
              () => ResponsesServerEvent.fromJson(json),
              throwsFormatException,
            );
          },
        );
        test('malformed response ID $kind ${bad.runtimeType}', () {
          final json = _ack(kind)..['response_id'] = bad;
          expect(
            () => ResponsesServerEvent.fromJson(json),
            throwsFormatException,
          );
        });
      }
      test('known malformed $kind never becomes an unknown message', () {
        expect(
          () => UnknownResponsesServerEvent.fromJson({
            'type': 'response.inject.$kind',
          }),
          throwsFormatException,
        );
      });
    }
    for (final input in <Object?>[
      null,
      true,
      1,
      1.25,
      'private',
      <String, dynamic>{},
    ]) {
      test(
        'failed outer input is required nonnullable array ${input.runtimeType}',
        () {
          final json = _ack('failed')..['input'] = input;
          expect(
            () => ResponseInjectFailedEvent.fromJson(json),
            throwsFormatException,
          );
        },
      );
    }
    for (final error in <Object?>[null, true, 1, 'private', <dynamic>[]]) {
      test('failed error is required object ${error.runtimeType}', () {
        final json = _ack('failed')..['error'] = error;
        expect(
          () => ResponseInjectFailedEvent.fromJson(json),
          throwsFormatException,
        );
      });
    }
    test(
      'failed nested raw values remain finite, exact and deeply immutable',
      () {
        final json = _ack('failed');
        final original = _fresh(json);
        final parsed = ResponseInjectFailedEvent.fromJson(json);
        expect(parsed.input, original['input']);
        expect(parsed.toJson(), original);
        expect(parsed.error.code, ResponseInjectErrorCode.unknown);
        expect(parsed.error.rawCode, 'future_private_code');
        expect(parsed.input.clear, throwsUnsupportedError);
        expect(
          () => (parsed.input[4]! as List<dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(
          () => (parsed.input[5]! as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(
          () =>
              ((parsed.input[6]! as Map<String, dynamic>)['future']
                      as Map<String, dynamic>)
                  .clear(),
          throwsUnsupportedError,
        );
        (json['input'] as List<Object?>).clear();
        expect(parsed.toJson(), original);
      },
    );
    test('failed empty and over-client-limit arrays remain raw compatible', () {
      for (final values in <List<Object?>>[
        [],
        List<Object?>.filled(16385, null),
      ]) {
        final parsed = ResponseInjectFailedEvent.fromJson(
          _ack('failed')..['input'] = values,
        );
        expect(parsed.input, hasLength(values.length));
        expect(parsed.toJson()['input'], values);
      }
    });
    test(
      'old Item constructor values normalize without coercing raw values',
      () {
        final item = FunctionCallOutputItem.string(
          callId: 'call',
          output: 'saved',
        );
        final constructed = ResponseInjectFailedEvent(
          responseId: 'response',
          input: [item],
          error: _error,
          sequenceNumber: 1,
        );
        expect(identical(constructed.input.single, item), isTrue);
        expect(constructed.toJson()['input'], [item.toJson()]);
        _equal(
          constructed,
          ResponseInjectFailedEvent.fromJson(constructed.toJson()),
        );
      },
    );
    test('all acknowledgement copies, lane clears and nested future edits', () {
      final created = ResponseInjectCreatedEvent.fromJson(_ack('created'));
      final failed = ResponseInjectFailedEvent.fromJson(_ack('failed'));
      final changed = <ResponsesServerEvent>[
        created.copyWith(responseId: 'new'),
        created.copyWith(sequenceNumber: 4),
        created.copyWith(streamId: null),
        created.copyWith(rawJson: const {'new': true}),
        failed.copyWith(responseId: 'new'),
        failed.copyWith(sequenceNumber: 4),
        failed.copyWith(streamId: null),
        failed.copyWith(input: const []),
        failed.copyWith(rawJson: const {'new': true}),
        failed.copyWith(
          error: const ResponseInjectError(
            code: ResponseInjectErrorCode.responseNotFound,
            message: 'new',
          ),
        ),
      ];
      for (final value in changed) {
        expect(
          value,
          isNot(value is ResponseInjectCreatedEvent ? created : failed),
        );
        _equal(value, ResponsesServerEvent.fromJson(value.toJson()));
      }
      _equal(created, created.copyWith());
      _equal(failed, failed.copyWith());
      expect(
        created.copyWith(streamId: null).toJson().containsKey('stream_id'),
        isFalse,
      );
      expect(
        failed.copyWith(streamId: null).toJson().containsKey('stream_id'),
        isFalse,
      );
      final freshError = failed.copyWith(
        error: failed.error.copyWith(
          code: ResponseInjectErrorCode.responseNotFound,
          message: 'changed',
        ),
      );
      expect(
        (freshError.toJson()['error'] as Map<String, dynamic>)['future_error'],
        failed.error.rawJson['future_error'],
      );
      expect(
        (freshError.toJson()['error'] as Map<String, dynamic>)['code'],
        'response_not_found',
      );
      expect(failed.copyWith(input: const []).toJson()['input'], isEmpty);
    });
    test(
      'explicit child metadata clear does not resurrect parent provenance',
      () {
        final failed = ResponseInjectFailedEvent.fromJson(_ack('failed'));
        final changed = failed.copyWith(
          error: failed.error.copyWith(rawJson: {}),
        );
        expect(changed.toJson()['error'], {
          'code': 'future_private_code',
          'message': 'private message',
        });
        expect(changed.toJson()['future'], failed.toJson()['future']);
        _equal(changed, ResponseInjectFailedEvent.fromJson(changed.toJson()));
        expect(changed.rawJson.clear, throwsUnsupportedError);
        expect(
          () => (changed.rawJson['error'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
      },
    );
    test('fresh child replacement drops its old future metadata', () {
      final failed = ResponseInjectFailedEvent.fromJson(_ack('failed'));
      final changed = failed.copyWith(
        error: const ResponseInjectError(
          code: ResponseInjectErrorCode.responseNotFound,
          message: 'replacement',
        ),
      );
      expect(changed.toJson()['error'], {
        'code': 'response_not_found',
        'message': 'replacement',
      });
      _equal(changed, ResponseInjectFailedEvent.fromJson(changed.toJson()));
    });
    for (final fresh in [false, true]) {
      test(
        'direct parent-only error metadata clears on ${fresh ? 'fresh replacement' : 'child raw clear'}',
        () {
          const constructed = ResponseInjectFailedEvent(
            responseId: 'response',
            input: [],
            error: _error,
            sequenceNumber: 1,
            rawJson: {
              'error': {'parent_only': true},
            },
          );
          expect(
            (constructed.toJson()['error']
                as Map<String, dynamic>)['parent_only'],
            isTrue,
          );
          _equal(constructed, constructed.copyWith());
          final error = fresh
              ? const ResponseInjectError(
                  code: ResponseInjectErrorCode.responseNotFound,
                  message: 'replacement',
                )
              : constructed.error.copyWith(rawJson: {});
          final changed = constructed.copyWith(error: error);
          expect(changed.toJson()['error'], error.toJson());
          _equal(changed, ResponseInjectFailedEvent.fromJson(changed.toJson()));
        },
      );
    }
    test(
      'nested child replacement removes stale keys without positional merge',
      () {
        final failed = ResponseInjectFailedEvent.fromJson(_ack('failed'));
        final changed = failed.copyWith(
          error: failed.error.copyWith(
            rawJson: {
              'future_error': {'replacement': true},
            },
          ),
        );
        expect(
          (changed.toJson()['error'] as Map<String, dynamic>)['future_error'],
          {'replacement': true},
        );
        _equal(changed, ResponseInjectFailedEvent.fromJson(changed.toJson()));
      },
    );
    test(
      'explicit parent provenance override wins over copy reconciliation',
      () {
        final failed = ResponseInjectFailedEvent.fromJson(_ack('failed'));
        final raw = <String, dynamic>{
          'replacement_parent': true,
          'error': {'parent_override': true},
        };
        final changed = failed.copyWith(
          error: failed.error.copyWith(rawJson: {}),
          rawJson: raw,
        );
        expect(identical(changed.rawJson, raw), isTrue);
        expect(changed.toJson()['error'], {
          'parent_override': true,
          'code': 'future_private_code',
          'message': 'private message',
        });
        expect(changed.toJson()['replacement_parent'], isTrue);
        expect(changed.toJson().containsKey('future'), isFalse);
        _equal(changed, ResponseInjectFailedEvent.fromJson(changed.toJson()));
      },
    );
    test(
      'child enum edit clears future wire override and retains its metadata',
      () {
        final failed = ResponseInjectFailedEvent.fromJson(_ack('failed'));
        final changed = failed.copyWith(
          error: failed.error.copyWith(
            code: ResponseInjectErrorCode.responseNotFound,
          ),
        );
        expect(changed.error.rawCode, isNull);
        expect(
          (changed.toJson()['error'] as Map<String, dynamic>)['code'],
          'response_not_found',
        );
        expect(
          (changed.toJson()['error'] as Map<String, dynamic>)['future_error'],
          failed.error.toJson()['future_error'],
        );
        _equal(changed, ResponseInjectFailedEvent.fromJson(changed.toJson()));
      },
    );
    for (final bad in <Object?>[double.infinity, double.nan, Object()]) {
      test('non-JSON failed array or metadata rejected ${bad.runtimeType}', () {
        expect(
          () => ResponseInjectFailedEvent.fromJson(
            _ack('failed')..['input'] = [bad],
          ),
          throwsFormatException,
        );
        expect(
          () => ResponseInjectFailedEvent(
            responseId: 'response',
            input: [bad],
            error: _error,
            sequenceNumber: 1,
          ).toJson(),
          throwsFormatException,
        );
        expect(
          () => ResponseInjectCreatedEvent(
            responseId: 'response',
            sequenceNumber: 1,
            rawJson: {'future': bad},
          ).toJson(),
          throwsFormatException,
        );
      });
    }
    test('concrete acknowledgement factories validate discriminators', () {
      expect(
        () => ResponseInjectCreatedEvent.fromJson(_ack('failed')),
        throwsFormatException,
      );
      expect(
        () => ResponseInjectFailedEvent.fromJson(_ack('created')),
        throwsFormatException,
      );
    });
  });

  group('injection error code fidelity', () {
    for (final value in [
      'response_already_completed',
      'response_not_found',
      'future_private_code',
      'unknown',
      '',
    ]) {
      test('known or forward-compatible wire string $value', () {
        final json = {
          'code': value,
          'message': 'private',
          'future': {
            'nested': [1, true],
          },
        };
        final error = ResponseInjectError.fromJson(json);
        expect(error.toJson(), json);
        expect(error.code, ResponseInjectErrorCode.fromJson(value));
        expect(
          error.rawCode,
          error.code == ResponseInjectErrorCode.unknown ? value : null,
        );
        _equal(error, ResponseInjectError.fromJson(_fresh(json)));
        expect(error.toString(), isNot(contains('private')));
        expect(error.rawJson.clear, throwsUnsupportedError);
      });
    }
    for (final field in ['code', 'message']) {
      test('required error $field missing', () {
        final json = <String, dynamic>{
          'code': 'response_not_found',
          'message': 'private',
        }..remove(field);
        expect(() => ResponseInjectError.fromJson(json), throwsFormatException);
      });
      for (final bad in <Object?>[
        null,
        true,
        1,
        <dynamic>[],
        <String, dynamic>{},
      ]) {
        test('malformed error $field ${bad.runtimeType}', () {
          final json = <String, dynamic>{
            'code': 'response_not_found',
            'message': 'private',
          }..[field] = bad;
          expect(
            () => ResponseInjectError.fromJson(json),
            throwsFormatException,
          );
        });
      }
    }
    test(
      'every error field copies and explicit enum selection clears stale wire code',
      () {
        final error = ResponseInjectError.fromJson(const {
          'code': 'future_private',
          'message': 'private',
          'future': {'keep': true},
        });
        _equal(error, error.copyWith());
        final changed = [
          error.copyWith(message: 'new'),
          error.copyWith(rawCode: 'other_future'),
          error.copyWith(rawCode: null),
          error.copyWith(code: ResponseInjectErrorCode.responseNotFound),
          error.copyWith(rawJson: const {'changed': true}),
        ];
        for (final value in changed) {
          expect(value, isNot(error));
          _equal(value, ResponseInjectError.fromJson(value.toJson()));
        }
        final known = error.copyWith(
          code: ResponseInjectErrorCode.responseAlreadyCompleted,
        );
        expect(known.rawCode, isNull);
        expect(known.toJson()['code'], 'response_already_completed');
        expect(known.toJson()['future'], {'keep': true});
        expect(error.copyWith(rawCode: null).toJson()['code'], 'unknown');
      },
    );
    for (final (code, raw) in [
      (ResponseInjectErrorCode.responseAlreadyCompleted, 'future_private'),
      (ResponseInjectErrorCode.responseAlreadyCompleted, 'response_not_found'),
      (ResponseInjectErrorCode.unknown, 'response_not_found'),
    ]) {
      test('conflicting const error code rejects $code $raw', () {
        final error = ResponseInjectError(
          code: code,
          rawCode: raw,
          message: 'private',
        );
        _equal(error, error.copyWith());
        expect(error.toJson, throwsFormatException);
        expect(error.toString(), isNot(contains('private')));
        expect(
          () => ResponseInjectFailedEvent(
            responseId: 'response',
            input: const [],
            error: error,
            sequenceNumber: 1,
          ).toJson(),
          throwsFormatException,
        );
      });
    }
    test('redundant matching known override has the same effective value', () {
      const normal = ResponseInjectError(
        code: ResponseInjectErrorCode.responseNotFound,
        message: 'message',
      );
      const redundant = ResponseInjectError(
        code: ResponseInjectErrorCode.responseNotFound,
        rawCode: 'response_not_found',
        message: 'message',
      );
      _equal(normal, redundant);
      _equal(redundant, ResponseInjectError.fromJson(redundant.toJson()));
    });
    test(
      'constructor raw metadata remains caller owned and typed values win',
      () {
        final raw = <String, dynamic>{
          'code': 'stale',
          'message': 'stale',
          'future': <dynamic>[1],
        };
        final error = ResponseInjectError(
          code: ResponseInjectErrorCode.responseNotFound,
          message: 'current',
          rawJson: raw,
        );
        expect(identical(error.rawJson, raw), isTrue);
        expect(error.toJson(), {
          'code': 'response_not_found',
          'message': 'current',
          'future': <dynamic>[1],
        });
        raw['future'] = <dynamic>[2];
        expect(error.toJson()['future'], <dynamic>[2]);
      },
    );
  });
}
