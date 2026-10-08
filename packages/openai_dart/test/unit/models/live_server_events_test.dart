import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _secret = 'PRIVATE-LIVE-SERVER-CONTENT';

void main() {
  for (final fixture in _fixtures) {
    group(fixture.schema, () {
      test('minimal/complete fields and direct constructor round trip', () {
        for (final json in [fixture.minimal, fixture.complete]) {
          final value = fixture.parse(json);
          expect(value.toJson(), json);
          expect(fixture.copy(value), value);
          expect(fixture.copy(value).hashCode, value.hashCode);
          expect(fixture.parse(_json(value)), value);
          value.validate();
          expect(value.toString(), isNot(contains(_secret)));
        }
        expect(fixture.create(fixture.complete).toJson(), fixture.complete);
      });
      for (final key in fixture.required) {
        test('required $key absence stays malformed', () {
          final json = {...fixture.minimal}..remove(key);
          _safeFailure(() => fixture.parse(json), key);
        });
        test('required $key null policy is exact', () {
          if (fixture.schema == 'LiveLiveError' && key == 'code') {
            expect(fixture.parse({...fixture.minimal, key: null}).toJson(), {
              ...fixture.minimal,
              key: null,
            });
          } else {
            _safeFailure(
              () => fixture.parse({...fixture.minimal, key: null}),
              key,
            );
          }
        });
        test('required $key wrong type fails safely', () {
          _safeFailure(
            () => fixture.parse({...fixture.minimal, key: true}),
            key,
          );
        });
        if (fixture.fields.contains(key)) {
          test('required $key copy preserves its null policy', () {
            final value = fixture.parse(fixture.complete);
            if (fixture.schema == 'LiveLiveError' && key == 'code') {
              expect(_json(fixture.replace(value, key, null))[key], isNull);
            } else {
              _safeFailure(() => fixture.replace(value, key, null), key);
            }
          });
        }
      }
      for (final key in fixture.fixed) {
        test('fixed $key does not normalize an invalid tag', () {
          _safeFailure(
            () => fixture.parse({...fixture.complete, key: _secret}),
            key,
          );
        });
      }
      for (final key in fixture.fields) {
        test('copy $key uses the typed field and rejects malformed data', () {
          final value = fixture.parse(fixture.complete);
          _safeFailure(() => fixture.replace(value, key, true), key);
          final replacement = fixture.integers.contains(key)
              ? -9
              : fixture.numbers.contains(key)
              ? 1.625
              : fixture.closed.contains(key)
              ? key == 'reason'
                    ? 'content'
                    : key == 'target'
                    ? 'responses'
                    : '#'
              : fixture.objects.contains(key)
              ? <String, dynamic>{
                  ...(fixture.complete[key] as Map<String, dynamic>),
                  'copy': 'copy-private-value',
                }
              : 'copy-private-value';
          final changed = fixture.replace(value, key, replacement);
          expect(_json(changed)[key], replacement);
          final expected = {...fixture.complete, key: replacement};
          expect(changed, fixture.parse(expected));
          expect(changed.hashCode, fixture.parse(expected).hashCode);
          if (replacement != fixture.complete[key]) {
            expect(changed, isNot(value));
          }
        });
      }
      for (final key in fixture.optional) {
        test('optional $key absent/null/value and clear copy are exact', () {
          final value = fixture.parse(fixture.complete);
          final cleared = fixture.clear(value, key);
          expect(_json(cleared).containsKey(key), isFalse);
          expect(cleared, fixture.parse({...fixture.complete}..remove(key)));
          final explicitNull = {...fixture.complete, key: null};
          if (fixture.nullable.contains(key)) {
            expect(fixture.parse(explicitNull).toJson(), explicitNull);
            expect(fixture.replace(value, key, null).toJson(), explicitNull);
          } else {
            _safeFailure(() => fixture.parse(explicitNull), key);
            _safeFailure(() => fixture.replace(value, key, null), key);
            _safeFailure(() => fixture.create(explicitNull), key);
          }
        });
      }
      test('future extras own immutable snapshots and affect value/hash', () {
        final list = <dynamic>[
          _secret,
          <String, dynamic>{_secret: null},
        ];
        final input = {
          ...fixture.complete,
          'future': {'nested': list},
        };
        final value = fixture.parse(input);
        list.clear();
        input['future'] = 'changed';
        final expected = {
          ...fixture.complete,
          'future': {
            'nested': [
              _secret,
              {_secret: null},
            ],
          },
        };
        expect(value.toJson(), expected);
        final raw = fixture.raw(value);
        expect(raw.clear, throwsUnsupportedError);
        expect(
          () => (raw['future'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(
          () => ((raw['future'] as Map<String, dynamic>)['nested'] as List)
              .clear(),
          throwsUnsupportedError,
        );
        expect(value, fixture.parse(expected));
        expect(value.hashCode, fixture.parse(expected).hashCode);
        expect(value, isNot(fixture.parse(fixture.complete)));
        expect(value.toString(), isNot(contains(_secret)));
      });
      test('finite future admission rejects malformed caller data', () {
        final cycle = <dynamic>[];
        cycle.add(cycle);
        for (final invalid in [
          double.nan,
          double.infinity,
          ByteData(1),
          {_secret: Object()},
          {1: _secret},
          cycle,
        ]) {
          _safeFailure(
            () => fixture.parse({...fixture.complete, _secret: invalid}),
          );
          _safeFailure(
            () => fixture.create({...fixture.complete, _secret: invalid}),
          );
          _safeFailure(
            () => fixture.copyRaw(fixture.parse(fixture.complete), {
              _secret: invalid,
            }),
          );
        }
      });
      for (final key in [...fixture.integers, ...fixture.numbers]) {
        for (final literal in ['Infinity', '-Infinity', 'NaN']) {
          test(
            'runtime $literal rejected at numeric $key constructor/copy/factory',
            () {
              final dynamic value = num.parse(literal);
              _safeFailure(
                () => fixture.parse({...fixture.complete, key: value}),
                key,
              );
              _safeFailure(
                () => fixture.replace(
                  fixture.parse(fixture.complete),
                  key,
                  value,
                ),
                key,
              );
              if (fixture.integers.contains(key) &&
                  fixture.required.contains(key) &&
                  value is! int) {
                expect(
                  () => fixture.create({...fixture.complete, key: value}),
                  throwsA(isA<TypeError>()),
                );
              } else {
                _safeFailure(
                  () => fixture.create({...fixture.complete, key: value}),
                  key,
                );
              }
            },
          );
        }
      }
    });
  }
  group('complete receive union and role-specific audio', () {
    for (final fixture in _fixtures.where((value) => value.isEvent)) {
      test(
        '${fixture.schema} malformed known payload never becomes Unknown',
        () {
          final key = fixture.required.firstWhere((key) => key != 'type');
          _safeFailure(
            () => LiveServerEvent.fromJson({...fixture.minimal, key: true}),
            key,
          );
        },
      );
      test(
        '${fixture.schema} dispatches and remains accepted on both channels',
        () {
          final event = LiveServerEvent.fromJson(fixture.complete);
          expect(event, fixture.parse(fixture.complete));
          expect(event.rawJson, fixture.complete);
          if (event is LiveOutputAudioDelta) {
            event.validateForChannel('sideband');
            event
                .copyWith(clearStartMs: true, clearEndMs: true)
                .validateForChannel('primary');
          } else {
            event
              ..validateForChannel('primary')
              ..validateForChannel('sideband');
          }
          _safeFailure(() => event.validateForChannel(_secret));
        },
      );
    }
    test('audio has no required or synthesized correlation id', () {
      for (final wire in [
        {'type': 'session.input_audio.append', 'audio': _secret},
        {'type': 'session.output_audio.delta', 'delta': _secret},
      ]) {
        final event = LiveServerEvent.fromJson(wire);
        expect(event.eventId, isNull);
        expect(event.toJson().containsKey('event_id'), isFalse);
        expect(event.toJson(), wire);
      }
    });
    test(
      'received correlation strings have no invented command length limit',
      () {
        final id = '🚀' * 1500;
        final event = LiveInputAudioMuted(eventId: id, clientEventId: id);
        expect(LiveServerEvent.fromJson(event.toJson()), event);
        expect(event.eventId, id);
        expect(event.clientEventId, id);
      },
    );
    test('primary output omits timestamps; sideband output requires both', () {
      final primary = LiveOutputAudioDelta(delta: _secret)
        ..validateForChannel('primary');
      _safeFailure(() => primary.validateForChannel('sideband'), 'start_ms');
      for (final partial in [
        primary.copyWith(startMs: 1),
        primary.copyWith(endMs: 2),
      ]) {
        _safeFailure(() => partial.validateForChannel('sideband'));
        _safeFailure(() => partial.validateForChannel('primary'));
      }
      final sideband = LiveOutputAudioDelta(
        delta: _secret,
        startMs: 1,
        endMs: 2,
      )..validateForChannel('sideband');
      _safeFailure(() => sideband.validateForChannel('primary'));
      expect(sideband.startMs, 1);
      expect(sideband.endMs, 2);
    });
    test(
      'raw Base64 audio bytes/timing gaps and delivery order stay intact',
      () {
        final bytes = Uint8List.fromList([0, 1, 255, 128, 7]);
        final encoded = base64Encode(bytes);
        final input =
            LiveServerEvent.fromJson({
                  'type': 'session.input_audio.append',
                  'audio': encoded,
                })
                as LiveInputAudioAppend;
        expect(base64Decode(input.audio), bytes);
        final events = [
          LiveOutputAudioDelta(delta: encoded, startMs: 17, endMs: 20),
          LiveOutputAudioDelta(delta: encoded, startMs: 99, endMs: 101),
          LiveOutputAudioDelta(delta: encoded, startMs: 8, endMs: 9),
        ];
        expect(events.map((value) => value.startMs), [17, 99, 8]);
        for (final event in events) {
          event.validateForChannel('sideband');
          expect(base64Decode(event.delta), bytes);
          expect(LiveServerEvent.fromJson(event.toJson()), event);
        }
      },
    );
  });
  group('future events remain receive-only immutable data', () {
    test(
      'unknown event preserves arbitrary ids and metadata without guessing',
      () {
        final input = {
          'type': 'future.event',
          'event_id': 12,
          'client_event_id': null,
          'future': [null, _secret],
        };
        final event = LiveServerEvent.fromJson(input) as UnknownLiveServerEvent;
        expect(event.eventId, isNull);
        expect(event.toJson(), input);
        expect(event.copyWith(type: 'future.other').toJson(), {
          ...input,
          'type': 'future.other',
        });
        event
          ..validateForChannel('primary')
          ..validateForChannel('sideband');
        expect(event.toString(), isNot(contains(_secret)));
        expect(event.rawJson.clear, throwsUnsupportedError);
        expect(event, UnknownLiveServerEvent.fromJson(input));
        expect(event.hashCode, UnknownLiveServerEvent.fromJson(input).hashCode);
      },
    );
    for (final fixture in _fixtures.where((value) => value.isEvent)) {
      test(
        '${fixture.schema} cannot bypass known validation through Unknown',
        () {
          _safeFailure(
            () =>
                UnknownLiveServerEvent(type: fixture.minimal['type'] as String),
          );
          _safeFailure(() => UnknownLiveServerEvent.fromJson(fixture.minimal));
          _safeFailure(
            () => UnknownLiveServerEvent(
              type: 'future',
            ).copyWith(type: fixture.minimal['type']),
          );
        },
      );
    }
    test(
      'missing/null/nonstring outer type and invalid unknown extras fail',
      () {
        for (final json in <Map<String, dynamic>>[
          {},
          {'type': null},
          {'type': true},
          {'type': _secret, _secret: double.nan},
        ]) {
          _safeFailure(() => LiveServerEvent.fromJson(json));
        }
      },
    );
  });
  group('open nested Responses and exact receive compatibility', () {
    test('finite typed arrays snapshot their original view as JSON arrays', () {
      final buffer = Uint8List.fromList([9, 1, 2, 3, 8]);
      final view = Uint8List.sublistView(buffer, 1, 4);
      final value = LiveSessionUsage(seconds: 0.375, rawJson: {'future': view});
      buffer[2] = 99;
      expect(value.toJson()['future'], [1, 2, 3]);
      expect(
        () => (value.rawJson['future'] as List<dynamic>).clear(),
        throwsUnsupportedError,
      );
    });
    for (final nested in <Map<String, dynamic>>[
      {},
      {'compact': true},
      {
        'type': 'response.completed',
        'response': {
          'id': _secret,
          'status': 'completed',
          'instructions': null,
          'tools': <Object?>[],
          'output': <Object?>[],
        },
      },
      {
        'type': 'response.failed',
        'response': {
          'error': {'message': _secret},
          'input': null,
        },
      },
      {
        'type': 'future.nested',
        _secret: [1, null],
      },
    ]) {
      test(
        'nested object ${nested['type'] ?? 'typeless'} stays complete and immutable',
        () {
          final envelope = LiveResponseEvent(eventId: _secret, event: nested);
          expect(envelope.event, nested);
          expect(
            (LiveServerEvent.fromJson(envelope.toJson()) as LiveResponseEvent)
                .event,
            nested,
          );
          expect(envelope.event.clear, throwsUnsupportedError);
          expect(envelope.toString(), isNot(contains(_secret)));
        },
      );
    }
    test(
      'nested response errors preserve known parent context without raw source',
      () {
        _safeFailure(
          () => LiveResponseEvent(
            eventId: _secret,
            event: const {_secret: double.nan},
          ),
          'event',
        );
        _safeFailure(
          () => LiveResponseEvent.fromJson(const {
            'type': 'response.event',
            'event_id': _secret,
            'event': <Object?>[],
          }),
          'event',
        );
      },
    );
    test('delegation omission/null/value stay distinct and never inferred', () {
      final absent = LiveResponseEvent(
        eventId: _secret,
        event: const {'delegation_id': _secret},
      );
      final explicitNull = absent.copyWith(delegationId: null);
      final value = absent.copyWith(delegationId: _secret);
      expect(absent.hasDelegationId, isFalse);
      expect(explicitNull.hasDelegationId, isTrue);
      expect(absent.toJson().containsKey('delegation_id'), isFalse);
      expect(explicitNull.toJson()['delegation_id'], isNull);
      expect(value.toJson()['delegation_id'], _secret);
      expect(explicitNull.copyWith(clearDelegationId: true), absent);
      expect(absent, isNot(explicitNull));
    });
    test(
      'guide code null requires presence and stays separate from canonical string',
      () {
        final compatible = LiveLiveError(
          type: 'invalid_request_error',
          code: null,
          message: _secret,
        );
        expect(compatible.toJson().containsKey('code'), isTrue);
        expect(compatible.toJson()['code'], isNull);
        expect(LiveLiveError.fromJson(compatible.toJson()), compatible);
        final envelope = LiveErrorEvent(eventId: _secret, error: compatible);
        expect(
          (LiveServerEvent.fromJson(envelope.toJson()) as LiveErrorEvent)
              .error
              .code,
          isNull,
        );
        _safeFailure(
          () => LiveLiveError.fromJson(const {
            'type': 'invalid_request_error',
            'message': _secret,
          }),
          'code',
        );
        for (final code in [true, 1, <Object?>[], <String, dynamic>{}]) {
          _safeFailure(
            () => LiveLiveError(
              type: 'invalid_request_error',
              code: code,
              message: _secret,
            ),
            'code',
          );
        }
        expect(compatible.copyWith(code: 'canonical').code, 'canonical');
      },
    );
    test(
      'nested Live error context remains caller-readable while diagnostics are safe',
      () {
        final error = LiveLiveError(
          type: _secret,
          code: _secret,
          message: _secret,
          param: _secret,
          clientEventId: _secret,
          rawJson: const {
            'future': {_secret: _secret},
          },
        );
        final envelope = LiveErrorEvent(
          eventId: _secret,
          clientEventId: _secret,
          error: error,
        );
        expect(envelope.error.message, _secret);
        expect(envelope.error.param, _secret);
        expect(envelope.error.clientEventId, _secret);
        expect(envelope.rawJson, isEmpty);
        expect(envelope.toString(), isNot(contains(_secret)));
        _safeFailure(
          () => LiveErrorEvent.fromJson({
            ...envelope.toJson(),
            'error': const {'type': _secret, 'code': _secret, 'message': 42},
          }),
          'error',
        );
      },
    );
    test(
      'cumulative fractional usage and context ratio are independent numbers',
      () {
        for (final seconds in [-0.5, 0, 0.375, 9.625]) {
          final value = LiveSessionUsage(seconds: seconds);
          expect(value.seconds, seconds);
          expect(value.copyWith(seconds: seconds), value);
        }
        expect(LiveContextWindowUsage(usageRatio: 1.625).usageRatio, 1.625);
        final latest = [
          LiveSessionUsage(seconds: 2.5),
          LiveSessionUsage(seconds: 3.75),
        ];
        expect(latest.last.seconds, 3.75);
      },
    );
    for (final reason in [
      'close_requested',
      'expired',
      'content',
      'remote_hangup',
      'connection_lost',
    ]) {
      test(
        'session.closed $reason retains final active snapshot and usage',
        () {
          final session = LiveSessionResourceParam(
            expiresAt: 1,
            id: _secret,
            model: 'future',
          );
          final event = LiveSessionClosed(
            eventId: _secret,
            reason: reason,
            session: session,
            usage: LiveSessionUsage(seconds: 1.625),
          );
          expect(event.session.status, 'active');
          expect(event.reason, reason);
          expect(event.usage.seconds, 1.625);
          expect(LiveServerEvent.fromJson(event.toJson()), event);
        },
      );
    }
    for (final target in ['client', 'responses']) {
      test('delegation target $target is metadata, not invented task text', () {
        final delegation = LiveDelegationItem(
          id: _secret,
          target: target,
          responseId: _secret,
        );
        expect(delegation.target, target);
        expect(delegation.toJson().containsKey('task'), isFalse);
        expect(delegation.copyWith(clearResponseId: true).responseId, isNull);
      });
    }
    test('unknown close reason/delegation target fail closed', () {
      _safeFailure(
        () => LiveDelegationItem(id: _secret, target: _secret),
        'target',
      );
      _safeFailure(
        () => LiveSessionClosed(
          eventId: _secret,
          reason: _secret,
          session: LiveSessionResourceParam(
            expiresAt: 1,
            id: _secret,
            model: 'future',
          ),
          usage: LiveSessionUsage(seconds: 0),
        ),
        'reason',
      );
    });
    for (final digit in '0123456789ABCD*#'.split('')) {
      test(
        'DTMF $digit received/send reflection exactly one canonical character',
        () {
          expect(
            LiveTransportDTMFReceived(eventId: _secret, event: digit).event,
            digit,
          );
          expect(
            LiveTransportDTMFSend(eventId: _secret, event: digit).event,
            digit,
          );
        },
      );
    }
    for (final invalid in ['', 'a', 'AB', '🚀', '\n', '0\n']) {
      test('malformed DTMF ${invalid.length} is rejected safely', () {
        _safeFailure(
          () => LiveTransportDTMFReceived(eventId: _secret, event: invalid),
          'event',
        );
        _safeFailure(
          () => LiveTransportDTMFSend(eventId: _secret, event: invalid),
          'event',
        );
      });
    }
  });
}

Map<String, dynamic> _json(LiveJsonModel value) =>
    value.toJson() as Map<String, dynamic>;

void _safeFailure(void Function() operation, [String? context]) {
  expect(
    operation,
    throwsA(
      isA<FormatException>()
          .having(
            (error) => error.message,
            'context',
            context == null ? isNotEmpty : contains(context),
          )
          .having((error) => error.source, 'source', isNull)
          .having((error) => error.offset, 'offset', isNull)
          .having(
            (error) => error.toString(),
            'privacy',
            isNot(contains(_secret)),
          ),
    ),
  );
}

class _Fixture {
  const _Fixture({
    required this.schema,
    required this.minimal,
    required this.complete,
    required this.required,
    required this.fields,
    required this.optional,
    required this.nullable,
    required this.fixed,
    required this.integers,
    required this.numbers,
    required this.objects,
    required this.closed,
    required this.parse,
    required this.create,
    required this.copy,
    required this.replace,
    required this.clear,
    required this.copyRaw,
    required this.raw,
    required this.isEvent,
  });
  final String schema;
  final Map<String, dynamic> minimal;
  final Map<String, dynamic> complete;
  final Set<String> required;
  final Set<String> fields;
  final Set<String> optional;
  final Set<String> nullable;
  final Set<String> fixed;
  final Set<String> integers;
  final Set<String> numbers;
  final Set<String> objects;
  final Set<String> closed;
  final LiveJsonModel Function(Map<String, dynamic>) parse;
  final LiveJsonModel Function(Map<String, dynamic>) create;
  final LiveJsonModel Function(dynamic) copy;
  final LiveJsonModel Function(dynamic, String, Object?) replace;
  final LiveJsonModel Function(dynamic, String) clear;
  final LiveJsonModel Function(dynamic, Map<String, dynamic>) copyRaw;
  final Map<String, dynamic> Function(dynamic) raw;
  final bool isEvent;
}

final _fixtures = <_Fixture>[
  _Fixture(
    schema: 'LiveSessionStarted',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session': {
        'expires_at': 17,
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'model': 'PRIVATE-LIVE-SERVER-CONTENT',
        'status': 'active',
      },
      'type': 'session.started',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session': {
        'expires_at': 17,
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'model': 'PRIVATE-LIVE-SERVER-CONTENT',
        'status': 'active',
      },
      'type': 'session.started',
    },
    required: <String>{'type', 'event_id', 'session'},
    fields: <String>{'client_event_id', 'event_id', 'session'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{'session'},
    closed: <String>{},
    parse: LiveSessionStarted.fromJson,
    create: (json) => LiveSessionStarted(
      clientEventId: json['client_event_id'],
      eventId: json['event_id'],
      session: json['session'] is Map<String, dynamic>
          ? LiveSessionResourceParam.fromJson(
              json['session'] as Map<String, dynamic>,
            )
          : json['session'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveSessionStarted).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveSessionStarted).copyWith(
        clientEventId: replacement,
      ),
      'event_id' => (value as LiveSessionStarted).copyWith(
        eventId: replacement,
      ),
      'session' => (value as LiveSessionStarted).copyWith(
        session: replacement is Map<String, dynamic>
            ? LiveSessionResourceParam.fromJson(replacement)
            : replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveSessionStarted).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveSessionStarted).copyWith(rawJson: raw),
    raw: (value) => (value as LiveSessionStarted).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveSessionUpdated',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session': {
        'expires_at': 17,
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'model': 'PRIVATE-LIVE-SERVER-CONTENT',
        'status': 'active',
      },
      'type': 'session.updated',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session': {
        'expires_at': 17,
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'model': 'PRIVATE-LIVE-SERVER-CONTENT',
        'status': 'active',
      },
      'type': 'session.updated',
    },
    required: <String>{'type', 'event_id', 'session'},
    fields: <String>{'client_event_id', 'event_id', 'session'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{'session'},
    closed: <String>{},
    parse: LiveSessionUpdated.fromJson,
    create: (json) => LiveSessionUpdated(
      clientEventId: json['client_event_id'],
      eventId: json['event_id'],
      session: json['session'] is Map<String, dynamic>
          ? LiveSessionResourceParam.fromJson(
              json['session'] as Map<String, dynamic>,
            )
          : json['session'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveSessionUpdated).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveSessionUpdated).copyWith(
        clientEventId: replacement,
      ),
      'event_id' => (value as LiveSessionUpdated).copyWith(
        eventId: replacement,
      ),
      'session' => (value as LiveSessionUpdated).copyWith(
        session: replacement is Map<String, dynamic>
            ? LiveSessionResourceParam.fromJson(replacement)
            : replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveSessionUpdated).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveSessionUpdated).copyWith(rawJson: raw),
    raw: (value) => (value as LiveSessionUpdated).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveInputAudioMuted',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.input_audio.muted',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.input_audio.muted',
    },
    required: <String>{'event_id', 'type'},
    fields: <String>{'client_event_id', 'event_id'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveInputAudioMuted.fromJson,
    create: (json) => LiveInputAudioMuted(
      clientEventId: json['client_event_id'],
      eventId: json['event_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveInputAudioMuted).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveInputAudioMuted).copyWith(
        clientEventId: replacement,
      ),
      'event_id' => (value as LiveInputAudioMuted).copyWith(
        eventId: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveInputAudioMuted).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveInputAudioMuted).copyWith(rawJson: raw),
    raw: (value) => (value as LiveInputAudioMuted).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveInputAudioUnmuted',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.input_audio.unmuted',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.input_audio.unmuted',
    },
    required: <String>{'event_id', 'type'},
    fields: <String>{'client_event_id', 'event_id'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveInputAudioUnmuted.fromJson,
    create: (json) => LiveInputAudioUnmuted(
      clientEventId: json['client_event_id'],
      eventId: json['event_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveInputAudioUnmuted).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveInputAudioUnmuted).copyWith(
        clientEventId: replacement,
      ),
      'event_id' => (value as LiveInputAudioUnmuted).copyWith(
        eventId: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveInputAudioUnmuted).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveInputAudioUnmuted).copyWith(rawJson: raw),
    raw: (value) => (value as LiveInputAudioUnmuted).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveInstructionsAppended',
    minimal: {
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.instructions.appended',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.instructions.appended',
    },
    required: <String>{'event_id', 'start_ms', 'end_ms', 'type'},
    fields: <String>{'client_event_id', 'end_ms', 'event_id', 'start_ms'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{'end_ms', 'start_ms'},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveInstructionsAppended.fromJson,
    create: (json) => LiveInstructionsAppended(
      clientEventId: json['client_event_id'],
      endMs: json['end_ms'],
      eventId: json['event_id'],
      startMs: json['start_ms'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveInstructionsAppended).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveInstructionsAppended).copyWith(
        clientEventId: replacement,
      ),
      'end_ms' => (value as LiveInstructionsAppended).copyWith(
        endMs: replacement,
      ),
      'event_id' => (value as LiveInstructionsAppended).copyWith(
        eventId: replacement,
      ),
      'start_ms' => (value as LiveInstructionsAppended).copyWith(
        startMs: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveInstructionsAppended).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveInstructionsAppended).copyWith(rawJson: raw),
    raw: (value) => (value as LiveInstructionsAppended).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveThinkingAppended',
    minimal: {
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.thinking.appended',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.thinking.appended',
    },
    required: <String>{'event_id', 'start_ms', 'end_ms', 'type'},
    fields: <String>{'client_event_id', 'end_ms', 'event_id', 'start_ms'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{'end_ms', 'start_ms'},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveThinkingAppended.fromJson,
    create: (json) => LiveThinkingAppended(
      clientEventId: json['client_event_id'],
      endMs: json['end_ms'],
      eventId: json['event_id'],
      startMs: json['start_ms'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveThinkingAppended).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveThinkingAppended).copyWith(
        clientEventId: replacement,
      ),
      'end_ms' => (value as LiveThinkingAppended).copyWith(endMs: replacement),
      'event_id' => (value as LiveThinkingAppended).copyWith(
        eventId: replacement,
      ),
      'start_ms' => (value as LiveThinkingAppended).copyWith(
        startMs: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveThinkingAppended).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveThinkingAppended).copyWith(rawJson: raw),
    raw: (value) => (value as LiveThinkingAppended).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveCommentaryAppended',
    minimal: {
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.commentary.appended',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.commentary.appended',
    },
    required: <String>{'event_id', 'start_ms', 'end_ms', 'type'},
    fields: <String>{'client_event_id', 'end_ms', 'event_id', 'start_ms'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{'end_ms', 'start_ms'},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveCommentaryAppended.fromJson,
    create: (json) => LiveCommentaryAppended(
      clientEventId: json['client_event_id'],
      endMs: json['end_ms'],
      eventId: json['event_id'],
      startMs: json['start_ms'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveCommentaryAppended).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveCommentaryAppended).copyWith(
        clientEventId: replacement,
      ),
      'end_ms' => (value as LiveCommentaryAppended).copyWith(
        endMs: replacement,
      ),
      'event_id' => (value as LiveCommentaryAppended).copyWith(
        eventId: replacement,
      ),
      'start_ms' => (value as LiveCommentaryAppended).copyWith(
        startMs: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveCommentaryAppended).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveCommentaryAppended).copyWith(rawJson: raw),
    raw: (value) => (value as LiveCommentaryAppended).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveInputAudioAppend',
    minimal: {
      'audio': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.input_audio.append',
    },
    complete: {
      'audio': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.input_audio.append',
    },
    required: <String>{'type', 'audio'},
    fields: <String>{'audio'},
    optional: <String>{},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveInputAudioAppend.fromJson,
    create: (json) => LiveInputAudioAppend(audio: json['audio'], rawJson: json),
    copy: (value) => (value as LiveInputAudioAppend).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'audio' => (value as LiveInputAudioAppend).copyWith(audio: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveInputAudioAppend).copyWith(rawJson: raw),
    raw: (value) => (value as LiveInputAudioAppend).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveOutputAudioDelta',
    minimal: {
      'delta': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.output_audio.delta',
    },
    complete: {
      'delta': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'start_ms': 17,
      'type': 'session.output_audio.delta',
    },
    required: <String>{'type', 'delta'},
    fields: <String>{'delta', 'end_ms', 'start_ms'},
    optional: <String>{'end_ms', 'start_ms'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{'end_ms', 'start_ms'},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveOutputAudioDelta.fromJson,
    create: (json) => LiveOutputAudioDelta(
      delta: json['delta'],
      endMs: json['end_ms'],
      startMs: json['start_ms'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveOutputAudioDelta).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'delta' => (value as LiveOutputAudioDelta).copyWith(delta: replacement),
      'end_ms' => (value as LiveOutputAudioDelta).copyWith(endMs: replacement),
      'start_ms' => (value as LiveOutputAudioDelta).copyWith(
        startMs: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'end_ms' => (value as LiveOutputAudioDelta).copyWith(clearEndMs: true),
      'start_ms' => (value as LiveOutputAudioDelta).copyWith(
        clearStartMs: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveOutputAudioDelta).copyWith(rawJson: raw),
    raw: (value) => (value as LiveOutputAudioDelta).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveInputTranscriptDelta',
    minimal: {
      'delta': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.input_transcript.delta',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'delta': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.input_transcript.delta',
    },
    required: <String>{'event_id', 'start_ms', 'end_ms', 'delta', 'type'},
    fields: <String>{
      'client_event_id',
      'delta',
      'end_ms',
      'event_id',
      'start_ms',
    },
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{'end_ms', 'start_ms'},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveInputTranscriptDelta.fromJson,
    create: (json) => LiveInputTranscriptDelta(
      clientEventId: json['client_event_id'],
      delta: json['delta'],
      endMs: json['end_ms'],
      eventId: json['event_id'],
      startMs: json['start_ms'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveInputTranscriptDelta).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveInputTranscriptDelta).copyWith(
        clientEventId: replacement,
      ),
      'delta' => (value as LiveInputTranscriptDelta).copyWith(
        delta: replacement,
      ),
      'end_ms' => (value as LiveInputTranscriptDelta).copyWith(
        endMs: replacement,
      ),
      'event_id' => (value as LiveInputTranscriptDelta).copyWith(
        eventId: replacement,
      ),
      'start_ms' => (value as LiveInputTranscriptDelta).copyWith(
        startMs: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveInputTranscriptDelta).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveInputTranscriptDelta).copyWith(rawJson: raw),
    raw: (value) => (value as LiveInputTranscriptDelta).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveOutputTranscriptDelta',
    minimal: {
      'delta': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.output_transcript.delta',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'delta': 'PRIVATE-LIVE-SERVER-CONTENT',
      'end_ms': 17,
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'start_ms': 17,
      'type': 'session.output_transcript.delta',
    },
    required: <String>{'event_id', 'start_ms', 'end_ms', 'delta', 'type'},
    fields: <String>{
      'client_event_id',
      'delta',
      'end_ms',
      'event_id',
      'start_ms',
    },
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{'end_ms', 'start_ms'},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveOutputTranscriptDelta.fromJson,
    create: (json) => LiveOutputTranscriptDelta(
      clientEventId: json['client_event_id'],
      delta: json['delta'],
      endMs: json['end_ms'],
      eventId: json['event_id'],
      startMs: json['start_ms'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveOutputTranscriptDelta).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveOutputTranscriptDelta).copyWith(
        clientEventId: replacement,
      ),
      'delta' => (value as LiveOutputTranscriptDelta).copyWith(
        delta: replacement,
      ),
      'end_ms' => (value as LiveOutputTranscriptDelta).copyWith(
        endMs: replacement,
      ),
      'event_id' => (value as LiveOutputTranscriptDelta).copyWith(
        eventId: replacement,
      ),
      'start_ms' => (value as LiveOutputTranscriptDelta).copyWith(
        startMs: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveOutputTranscriptDelta).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveOutputTranscriptDelta).copyWith(rawJson: raw),
    raw: (value) => (value as LiveOutputTranscriptDelta).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveDelegationCreated',
    minimal: {
      'delegation': {
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'target': 'client',
        'type': 'delegation',
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'offset_ms': 17,
      'type': 'session.delegation.created',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'delegation': {
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'target': 'client',
        'type': 'delegation',
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'offset_ms': 17,
      'type': 'session.delegation.created',
    },
    required: <String>{'event_id', 'type', 'offset_ms', 'delegation'},
    fields: <String>{'client_event_id', 'delegation', 'event_id', 'offset_ms'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{'offset_ms'},
    numbers: <String>{},
    objects: <String>{'delegation'},
    closed: <String>{},
    parse: LiveDelegationCreated.fromJson,
    create: (json) => LiveDelegationCreated(
      clientEventId: json['client_event_id'],
      delegation: json['delegation'] is Map<String, dynamic>
          ? LiveDelegationItem.fromJson(
              json['delegation'] as Map<String, dynamic>,
            )
          : json['delegation'],
      eventId: json['event_id'],
      offsetMs: json['offset_ms'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveDelegationCreated).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveDelegationCreated).copyWith(
        clientEventId: replacement,
      ),
      'delegation' => (value as LiveDelegationCreated).copyWith(
        delegation: replacement is Map<String, dynamic>
            ? LiveDelegationItem.fromJson(replacement)
            : replacement,
      ),
      'event_id' => (value as LiveDelegationCreated).copyWith(
        eventId: replacement,
      ),
      'offset_ms' => (value as LiveDelegationCreated).copyWith(
        offsetMs: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveDelegationCreated).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveDelegationCreated).copyWith(rawJson: raw),
    raw: (value) => (value as LiveDelegationCreated).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveResponseEvent',
    minimal: {
      'event': {
        'future': {
          'opaque': ['PRIVATE-LIVE-SERVER-CONTENT', null, 0.5],
        },
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'response.event',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'delegation_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event': {
        'future': {
          'opaque': ['PRIVATE-LIVE-SERVER-CONTENT', null, 0.5],
        },
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'response.event',
    },
    required: <String>{'event_id', 'type', 'event'},
    fields: <String>{'client_event_id', 'delegation_id', 'event', 'event_id'},
    optional: <String>{'client_event_id', 'delegation_id'},
    nullable: <String>{'delegation_id'},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{'event'},
    closed: <String>{},
    parse: LiveResponseEvent.fromJson,
    create: (json) => LiveResponseEvent(
      clientEventId: json['client_event_id'],
      delegationId: json['delegation_id'],
      event: json['event'] as Map<String, dynamic>,
      eventId: json['event_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveResponseEvent).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveResponseEvent).copyWith(
        clientEventId: replacement,
      ),
      'delegation_id' => (value as LiveResponseEvent).copyWith(
        delegationId: replacement,
      ),
      'event' => (value as LiveResponseEvent).copyWith(event: replacement),
      'event_id' => (value as LiveResponseEvent).copyWith(eventId: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveResponseEvent).copyWith(
        clearClientEventId: true,
      ),
      'delegation_id' => (value as LiveResponseEvent).copyWith(
        clearDelegationId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveResponseEvent).copyWith(rawJson: raw),
    raw: (value) => (value as LiveResponseEvent).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveSessionUsageUpdated',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.usage.updated',
      'usage': {'seconds': 0.375},
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'context_window': {'usage_ratio': 0.375},
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'session.usage.updated',
      'usage': {'seconds': 0.375},
    },
    required: <String>{'event_id', 'type', 'usage'},
    fields: <String>{'client_event_id', 'context_window', 'event_id', 'usage'},
    optional: <String>{'client_event_id', 'context_window'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{'context_window', 'usage'},
    closed: <String>{},
    parse: LiveSessionUsageUpdated.fromJson,
    create: (json) => LiveSessionUsageUpdated(
      clientEventId: json['client_event_id'],
      contextWindow: json['context_window'] is Map<String, dynamic>
          ? LiveContextWindowUsage.fromJson(
              json['context_window'] as Map<String, dynamic>,
            )
          : json['context_window'],
      eventId: json['event_id'],
      usage: json['usage'] is Map<String, dynamic>
          ? LiveSessionUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : json['usage'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveSessionUsageUpdated).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveSessionUsageUpdated).copyWith(
        clientEventId: replacement,
      ),
      'context_window' => (value as LiveSessionUsageUpdated).copyWith(
        contextWindow: replacement is Map<String, dynamic>
            ? LiveContextWindowUsage.fromJson(replacement)
            : replacement,
      ),
      'event_id' => (value as LiveSessionUsageUpdated).copyWith(
        eventId: replacement,
      ),
      'usage' => (value as LiveSessionUsageUpdated).copyWith(
        usage: replacement is Map<String, dynamic>
            ? LiveSessionUsage.fromJson(replacement)
            : replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveSessionUsageUpdated).copyWith(
        clearClientEventId: true,
      ),
      'context_window' => (value as LiveSessionUsageUpdated).copyWith(
        clearContextWindow: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveSessionUsageUpdated).copyWith(rawJson: raw),
    raw: (value) => (value as LiveSessionUsageUpdated).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveSessionClosed',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'reason': 'close_requested',
      'session': {
        'expires_at': 17,
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'model': 'PRIVATE-LIVE-SERVER-CONTENT',
        'status': 'active',
      },
      'type': 'session.closed',
      'usage': {'seconds': 0.375},
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'reason': 'close_requested',
      'session': {
        'expires_at': 17,
        'id': 'PRIVATE-LIVE-SERVER-CONTENT',
        'model': 'PRIVATE-LIVE-SERVER-CONTENT',
        'status': 'active',
      },
      'type': 'session.closed',
      'usage': {'seconds': 0.375},
    },
    required: <String>{'event_id', 'type', 'reason', 'session', 'usage'},
    fields: <String>{
      'client_event_id',
      'event_id',
      'reason',
      'session',
      'usage',
    },
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{'session', 'usage'},
    closed: <String>{'reason'},
    parse: LiveSessionClosed.fromJson,
    create: (json) => LiveSessionClosed(
      clientEventId: json['client_event_id'],
      eventId: json['event_id'],
      reason: json['reason'],
      session: json['session'] is Map<String, dynamic>
          ? LiveSessionResourceParam.fromJson(
              json['session'] as Map<String, dynamic>,
            )
          : json['session'],
      usage: json['usage'] is Map<String, dynamic>
          ? LiveSessionUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : json['usage'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveSessionClosed).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveSessionClosed).copyWith(
        clientEventId: replacement,
      ),
      'event_id' => (value as LiveSessionClosed).copyWith(eventId: replacement),
      'reason' => (value as LiveSessionClosed).copyWith(reason: replacement),
      'session' => (value as LiveSessionClosed).copyWith(
        session: replacement is Map<String, dynamic>
            ? LiveSessionResourceParam.fromJson(replacement)
            : replacement,
      ),
      'usage' => (value as LiveSessionClosed).copyWith(
        usage: replacement is Map<String, dynamic>
            ? LiveSessionUsage.fromJson(replacement)
            : replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveSessionClosed).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveSessionClosed).copyWith(rawJson: raw),
    raw: (value) => (value as LiveSessionClosed).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveErrorEvent',
    minimal: {
      'error': {
        'code': 'PRIVATE-LIVE-SERVER-CONTENT',
        'message': 'PRIVATE-LIVE-SERVER-CONTENT',
        'type': 'PRIVATE-LIVE-SERVER-CONTENT',
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'error',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'error': {
        'code': 'PRIVATE-LIVE-SERVER-CONTENT',
        'message': 'PRIVATE-LIVE-SERVER-CONTENT',
        'type': 'PRIVATE-LIVE-SERVER-CONTENT',
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'error',
    },
    required: <String>{'event_id', 'type', 'error'},
    fields: <String>{'client_event_id', 'error', 'event_id'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{'error'},
    closed: <String>{},
    parse: LiveErrorEvent.fromJson,
    create: (json) => LiveErrorEvent(
      clientEventId: json['client_event_id'],
      error: json['error'] is Map<String, dynamic>
          ? LiveLiveError.fromJson(json['error'] as Map<String, dynamic>)
          : json['error'],
      eventId: json['event_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveErrorEvent).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveErrorEvent).copyWith(
        clientEventId: replacement,
      ),
      'error' => (value as LiveErrorEvent).copyWith(
        error: replacement is Map<String, dynamic>
            ? LiveLiveError.fromJson(replacement)
            : replacement,
      ),
      'event_id' => (value as LiveErrorEvent).copyWith(eventId: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveErrorEvent).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) => (value as LiveErrorEvent).copyWith(rawJson: raw),
    raw: (value) => (value as LiveErrorEvent).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveInfoEvent',
    minimal: {
      'code': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'message': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'info',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'code': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'message': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'info',
    },
    required: <String>{'event_id', 'type', 'code', 'message'},
    fields: <String>{'client_event_id', 'code', 'event_id', 'message'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveInfoEvent.fromJson,
    create: (json) => LiveInfoEvent(
      clientEventId: json['client_event_id'],
      code: json['code'],
      eventId: json['event_id'],
      message: json['message'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveInfoEvent).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveInfoEvent).copyWith(
        clientEventId: replacement,
      ),
      'code' => (value as LiveInfoEvent).copyWith(code: replacement),
      'event_id' => (value as LiveInfoEvent).copyWith(eventId: replacement),
      'message' => (value as LiveInfoEvent).copyWith(message: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveInfoEvent).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) => (value as LiveInfoEvent).copyWith(rawJson: raw),
    raw: (value) => (value as LiveInfoEvent).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveTransportDTMFReceived',
    minimal: {
      'event': 'A',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.dtmf.received',
    },
    complete: {
      'event': 'A',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.dtmf.received',
    },
    required: <String>{'type', 'event_id', 'event'},
    fields: <String>{'event', 'event_id'},
    optional: <String>{},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{'event'},
    parse: LiveTransportDTMFReceived.fromJson,
    create: (json) => LiveTransportDTMFReceived(
      event: json['event'],
      eventId: json['event_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveTransportDTMFReceived).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'event' => (value as LiveTransportDTMFReceived).copyWith(
        event: replacement,
      ),
      'event_id' => (value as LiveTransportDTMFReceived).copyWith(
        eventId: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveTransportDTMFReceived).copyWith(rawJson: raw),
    raw: (value) => (value as LiveTransportDTMFReceived).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveTransportDTMFSend',
    minimal: {
      'event': 'A',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.dtmf.send',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'event': 'A',
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.dtmf.send',
    },
    required: <String>{'type', 'event_id', 'event'},
    fields: <String>{'client_event_id', 'event', 'event_id'},
    optional: <String>{'client_event_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{'event'},
    parse: LiveTransportDTMFSend.fromJson,
    create: (json) => LiveTransportDTMFSend(
      clientEventId: json['client_event_id'],
      event: json['event'],
      eventId: json['event_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveTransportDTMFSend).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveTransportDTMFSend).copyWith(
        clientEventId: replacement,
      ),
      'event' => (value as LiveTransportDTMFSend).copyWith(event: replacement),
      'event_id' => (value as LiveTransportDTMFSend).copyWith(
        eventId: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveTransportDTMFSend).copyWith(
        clearClientEventId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveTransportDTMFSend).copyWith(rawJson: raw),
    raw: (value) => (value as LiveTransportDTMFSend).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveTransportRinging',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.ringing',
    },
    complete: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.ringing',
    },
    required: <String>{'event_id', 'session_id', 'type'},
    fields: <String>{'event_id', 'session_id'},
    optional: <String>{},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveTransportRinging.fromJson,
    create: (json) => LiveTransportRinging(
      eventId: json['event_id'],
      sessionId: json['session_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveTransportRinging).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'event_id' => (value as LiveTransportRinging).copyWith(
        eventId: replacement,
      ),
      'session_id' => (value as LiveTransportRinging).copyWith(
        sessionId: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveTransportRinging).copyWith(rawJson: raw),
    raw: (value) => (value as LiveTransportRinging).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveTransportAnswered',
    minimal: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.answered',
    },
    complete: {
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.answered',
    },
    required: <String>{'event_id', 'session_id', 'type'},
    fields: <String>{'event_id', 'session_id'},
    optional: <String>{},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveTransportAnswered.fromJson,
    create: (json) => LiveTransportAnswered(
      eventId: json['event_id'],
      sessionId: json['session_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveTransportAnswered).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'event_id' => (value as LiveTransportAnswered).copyWith(
        eventId: replacement,
      ),
      'session_id' => (value as LiveTransportAnswered).copyWith(
        sessionId: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveTransportAnswered).copyWith(rawJson: raw),
    raw: (value) => (value as LiveTransportAnswered).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveTransportFailed',
    minimal: {
      'error': {
        'code': 'PRIVATE-LIVE-SERVER-CONTENT',
        'message': 'PRIVATE-LIVE-SERVER-CONTENT',
        'type': 'call_error',
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.failed',
    },
    complete: {
      'error': {
        'code': 'PRIVATE-LIVE-SERVER-CONTENT',
        'message': 'PRIVATE-LIVE-SERVER-CONTENT',
        'type': 'call_error',
      },
      'event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'session_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'transport.failed',
    },
    required: <String>{'event_id', 'session_id', 'type', 'error'},
    fields: <String>{'error', 'event_id', 'session_id'},
    optional: <String>{},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{'error'},
    closed: <String>{},
    parse: LiveTransportFailed.fromJson,
    create: (json) => LiveTransportFailed(
      error: json['error'] is Map<String, dynamic>
          ? LiveTransportCallError.fromJson(
              json['error'] as Map<String, dynamic>,
            )
          : json['error'],
      eventId: json['event_id'],
      sessionId: json['session_id'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveTransportFailed).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'error' => (value as LiveTransportFailed).copyWith(
        error: replacement is Map<String, dynamic>
            ? LiveTransportCallError.fromJson(replacement)
            : replacement,
      ),
      'event_id' => (value as LiveTransportFailed).copyWith(
        eventId: replacement,
      ),
      'session_id' => (value as LiveTransportFailed).copyWith(
        sessionId: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveTransportFailed).copyWith(rawJson: raw),
    raw: (value) => (value as LiveTransportFailed).rawJson,
    isEvent: true,
  ),
  _Fixture(
    schema: 'LiveLiveError',
    minimal: {
      'code': 'PRIVATE-LIVE-SERVER-CONTENT',
      'message': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'PRIVATE-LIVE-SERVER-CONTENT',
    },
    complete: {
      'client_event_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'code': 'PRIVATE-LIVE-SERVER-CONTENT',
      'message': 'PRIVATE-LIVE-SERVER-CONTENT',
      'param': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'PRIVATE-LIVE-SERVER-CONTENT',
    },
    required: <String>{'type', 'code', 'message'},
    fields: <String>{'client_event_id', 'code', 'message', 'param', 'type'},
    optional: <String>{'client_event_id', 'param'},
    nullable: <String>{},
    fixed: <String>{},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveLiveError.fromJson,
    create: (json) => LiveLiveError(
      clientEventId: json['client_event_id'],
      code: json['code'],
      message: json['message'],
      param: json['param'],
      type: json['type'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveLiveError).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'client_event_id' => (value as LiveLiveError).copyWith(
        clientEventId: replacement,
      ),
      'code' => (value as LiveLiveError).copyWith(code: replacement),
      'message' => (value as LiveLiveError).copyWith(message: replacement),
      'param' => (value as LiveLiveError).copyWith(param: replacement),
      'type' => (value as LiveLiveError).copyWith(type: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'client_event_id' => (value as LiveLiveError).copyWith(
        clearClientEventId: true,
      ),
      'param' => (value as LiveLiveError).copyWith(clearParam: true),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) => (value as LiveLiveError).copyWith(rawJson: raw),
    raw: (value) => (value as LiveLiveError).rawJson,
    isEvent: false,
  ),
  _Fixture(
    schema: 'LiveSessionUsage',
    minimal: {'seconds': 0.375},
    complete: {'seconds': 0.375},
    required: <String>{'seconds'},
    fields: <String>{'seconds'},
    optional: <String>{},
    nullable: <String>{},
    fixed: <String>{},
    integers: <String>{},
    numbers: <String>{'seconds'},
    objects: <String>{},
    closed: <String>{},
    parse: LiveSessionUsage.fromJson,
    create: (json) => LiveSessionUsage(seconds: json['seconds'], rawJson: json),
    copy: (value) => (value as LiveSessionUsage).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'seconds' => (value as LiveSessionUsage).copyWith(seconds: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) => (value as LiveSessionUsage).copyWith(rawJson: raw),
    raw: (value) => (value as LiveSessionUsage).rawJson,
    isEvent: false,
  ),
  _Fixture(
    schema: 'LiveContextWindowUsage',
    minimal: {'usage_ratio': 0.375},
    complete: {'usage_ratio': 0.375},
    required: <String>{'usage_ratio'},
    fields: <String>{'usage_ratio'},
    optional: <String>{},
    nullable: <String>{},
    fixed: <String>{},
    integers: <String>{},
    numbers: <String>{'usage_ratio'},
    objects: <String>{},
    closed: <String>{},
    parse: LiveContextWindowUsage.fromJson,
    create: (json) =>
        LiveContextWindowUsage(usageRatio: json['usage_ratio'], rawJson: json),
    copy: (value) => (value as LiveContextWindowUsage).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'usage_ratio' => (value as LiveContextWindowUsage).copyWith(
        usageRatio: replacement,
      ),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveContextWindowUsage).copyWith(rawJson: raw),
    raw: (value) => (value as LiveContextWindowUsage).rawJson,
    isEvent: false,
  ),
  _Fixture(
    schema: 'LiveDelegationItem',
    minimal: {
      'id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'target': 'client',
      'type': 'delegation',
    },
    complete: {
      'id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'response_id': 'PRIVATE-LIVE-SERVER-CONTENT',
      'target': 'client',
      'type': 'delegation',
    },
    required: <String>{'id', 'type', 'target'},
    fields: <String>{'id', 'response_id', 'target'},
    optional: <String>{'response_id'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{'target'},
    parse: LiveDelegationItem.fromJson,
    create: (json) => LiveDelegationItem(
      id: json['id'],
      responseId: json['response_id'],
      target: json['target'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveDelegationItem).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'id' => (value as LiveDelegationItem).copyWith(id: replacement),
      'response_id' => (value as LiveDelegationItem).copyWith(
        responseId: replacement,
      ),
      'target' => (value as LiveDelegationItem).copyWith(target: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'response_id' => (value as LiveDelegationItem).copyWith(
        clearResponseId: true,
      ),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveDelegationItem).copyWith(rawJson: raw),
    raw: (value) => (value as LiveDelegationItem).rawJson,
    isEvent: false,
  ),
  _Fixture(
    schema: 'LiveTransportCallError',
    minimal: {
      'code': 'PRIVATE-LIVE-SERVER-CONTENT',
      'message': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'call_error',
    },
    complete: {
      'code': 'PRIVATE-LIVE-SERVER-CONTENT',
      'message': 'PRIVATE-LIVE-SERVER-CONTENT',
      'param': 'PRIVATE-LIVE-SERVER-CONTENT',
      'type': 'call_error',
    },
    required: <String>{'type', 'code', 'message'},
    fields: <String>{'code', 'message', 'param'},
    optional: <String>{'param'},
    nullable: <String>{},
    fixed: <String>{'type'},
    integers: <String>{},
    numbers: <String>{},
    objects: <String>{},
    closed: <String>{},
    parse: LiveTransportCallError.fromJson,
    create: (json) => LiveTransportCallError(
      code: json['code'],
      message: json['message'],
      param: json['param'],
      rawJson: json,
    ),
    copy: (value) => (value as LiveTransportCallError).copyWith(),
    replace: (value, key, replacement) => switch (key) {
      'code' => (value as LiveTransportCallError).copyWith(code: replacement),
      'message' => (value as LiveTransportCallError).copyWith(
        message: replacement,
      ),
      'param' => (value as LiveTransportCallError).copyWith(param: replacement),
      _ => throw StateError('Unexpected fixture field'),
    },
    clear: (value, key) => switch (key) {
      'param' => (value as LiveTransportCallError).copyWith(clearParam: true),
      _ => throw StateError('Unexpected optional fixture field'),
    },
    copyRaw: (value, raw) =>
        (value as LiveTransportCallError).copyWith(rawJson: raw),
    raw: (value) => (value as LiveTransportCallError).rawJson,
    isEvent: false,
  ),
];
