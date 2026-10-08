import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/models/responses/multi_agent/agent_tag.dart'
    as direct_agent;
import 'package:openai_dart/src/models/responses/streaming/response_stream_event.dart'
    as direct;
import 'package:test/test.dart';

Map<String, dynamic> _canonical() => {
  'type': 'error',
  'code': null,
  'message': 'private explanation',
  'param': null,
  'sequence_number': 12,
};

Matcher _context(String field) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(field))
    .having((error) => error.source, 'source', isNull);

void main() {
  final parsers = <String, ErrorEvent Function(Map<String, dynamic>)>{
    'direct': ErrorEvent.fromJson,
    'sealed': (json) => ResponseStreamEvent.fromJson(json) as ErrorEvent,
  };

  group('public streaming factory discriminator', () {
    test(
      'missing discriminator fails contextually without a payload source',
      () {
        expect(
          () => ResponseStreamEvent.fromJson(const {
            'private key': 'private data',
          }),
          throwsA(_context('ResponseStreamEvent.type')),
        );
      },
    );
    for (final invalid in <Object?>[null, false, 2, [], {}]) {
      test(
        'wrong discriminator type ${invalid.runtimeType} fails contextually',
        () {
          expect(
            () => ResponseStreamEvent.fromJson({'type': invalid}),
            throwsA(_context('ResponseStreamEvent.type')),
          );
        },
      );
    }
    for (final unknownType in ['', 'future.error']) {
      test('unknown string discriminator $unknownType retains fallback', () {
        final source = {'type': unknownType, 'future': false};
        final event = ResponseStreamEvent.fromJson(source);
        expect(event, isA<UnknownEvent>());
        expect(event.type, unknownType);
        expect(event.toJson(), source);
      });
    }
  });

  group('canonical flat SSE error', () {
    for (final parser in parsers.entries) {
      for (final code in <String?>[null, 'future classification']) {
        for (final param in <String?>[null, 'private input identifier']) {
          test('${parser.key} nullable fields $code/$param round trip', () {
            final json = _canonical()
              ..['code'] = code
              ..['param'] = param;
            final value = parser.value(json);
            expect(value.type, 'error');
            expect(value.code, code);
            expect(value.param, param);
            expect(value.message, 'private explanation');
            expect(value.sequenceNumber, 12);
            expect(value.hasSequenceNumber, isTrue);
            expect(value.hasCode, isTrue);
            expect(value.hasParam, isTrue);
            expect(value.hasAgent, isFalse);
            expect(value.isFinal, isFalse);
            expect(value.toJson(), json);
            expect(value.toJson().containsKey('error'), isFalse);
            final reparsed = parser.value(
              jsonDecode(jsonEncode(value.toJson())) as Map<String, dynamic>,
            );
            expect(reparsed, value);
            expect(reparsed.hashCode, value.hashCode);
          });
        }
      }
      for (final agent in <Object?>[
        null,
        {
          'agent_name': 'private agent',
          'future': [true, null, 7],
        },
      ]) {
        test('${parser.key} beta nullable agent $agent', () {
          final json = _canonical()..['agent'] = agent;
          final value = parser.value(json);
          expect(value.hasAgent, isTrue);
          expect(
            value.agent?.agentName,
            agent == null ? null : 'private agent',
          );
          expect(value.toJson(), json);
          expect(value.copyWith(), value);
          expect(value.copyWith().hashCode, value.hashCode);
          expect(parser.value(value.toJson()), value);
        });
      }
      test('${parser.key} future open metadata survives opaquely', () {
        final json = _canonical()
          ..['misalignment'] = {
            'error_type': 'opaque future classification',
            'review_target': 'private.review',
          }
          ..['headers'] = {'private-header': 'private value'}
          ..['future'] = [
            false,
            null,
            {'private-key': 'private payload'},
          ]
          ..['error'] = {'message': 'opaque overflow', 'code': 'opaque code'};
        final value = parser.value(json);
        expect(value.code, isNull);
        expect(value.message, 'private explanation');
        expect(value.toJson(), json);
        expect(value.rawJson, json);
        expect(parser.value(value.toJson()), value);
        expect(value.copyWith().hashCode, value.hashCode);
        final diagnostic = value.toString();
        for (final secret in [
          'private explanation',
          'private.review',
          'private-header',
          'private value',
          'private-key',
          'private payload',
          'opaque overflow',
          'opaque code',
        ]) {
          expect(diagnostic, isNot(contains(secret)));
        }
      });
      test('${parser.key} accepts absent sequence without inventing zero', () {
        final json = _canonical()..remove('sequence_number');
        final value = parser.value(json);
        expect(value.sequenceNumber, isNull);
        expect(value.hasSequenceNumber, isFalse);
        expect(value.toJson(), json);
        expect(parser.value(value.toJson()), value);
      });
      test(
        '${parser.key} zero sequence and empty strings retain exact values',
        () {
          final json = _canonical()
            ..['sequence_number'] = 0
            ..['message'] = ''
            ..['code'] = ''
            ..['param'] = ''
            ..['agent'] = {'agent_name': ''};
          expect(parser.value(json).toJson(), json);
        },
      );
      for (final key in ['message']) {
        test('${parser.key} requires flat $key', () {
          expect(
            () => parser.value(_canonical()..remove(key)),
            throwsA(_context('ErrorEvent.$key')),
          );
        });
      }
      final malformed = <String, List<Object?>>{
        'code': [false, 2, [], {}],
        'param': [false, 2, [], {}],
        'message': [null, false, 2, [], {}],
        'sequence_number': [null, false, 1.25, '1', [], {}],
        'agent': [
          false,
          2,
          '',
          [],
          {'agent_name': null},
          {'agent_name': 2},
          {},
        ],
      };
      for (final field in malformed.entries) {
        for (var index = 0; index < field.value.length; index++) {
          test('${parser.key} rejects ${field.key} case $index', () {
            expect(
              () =>
                  parser.value(_canonical()..[field.key] = field.value[index]),
              throwsA(_context('ErrorEvent.${field.key}')),
            );
          });
        }
      }
    }
    for (final type in <Object?>[null, false, 'response.failed']) {
      test('direct subtype rejects discriminator $type safely', () {
        expect(
          () => ErrorEvent.fromJson(_canonical()..['type'] = type),
          throwsA(_context('ErrorEvent.type')),
        );
      });
    }
    test('direct subtype requires discriminator', () {
      expect(
        () => ErrorEvent.fromJson(_canonical()..remove('type')),
        throwsA(_context('ErrorEvent.type')),
      );
    });
  });

  group('documented legacy nested input', () {
    for (final parser in parsers.entries) {
      test('${parser.key} normalizes legacy envelope to flat', () {
        final source = {
          'type': 'error',
          'error': {
            'code': 'legacy code',
            'message': 'legacy message',
            'param': null,
            'legacy_future': {
              'private': [true],
            },
          },
          'sequence_number': 8,
          'agent': null,
          'future': false,
        };
        final value = parser.value(source);
        expect(value.toJson(), {
          'type': 'error',
          'code': 'legacy code',
          'message': 'legacy message',
          'param': null,
          'sequence_number': 8,
          'agent': null,
          'future': false,
        });
        expect(value.rawJson, source);
        expect(value.copyWith().toJson(), value.toJson());
        expect(parser.value(value.toJson()), value);
        expect(parser.value(value.toJson()).hashCode, value.hashCode);
      });
      test(
        '${parser.key} missing legacy code/param/sequence retain omission',
        () {
          final value = parser.value({
            'type': 'error',
            'error': {'message': 'private message'},
          });
          expect(value.code, isNull);
          expect(value.param, isNull);
          expect(value.sequenceNumber, isNull);
          expect(value.hasCode, isFalse);
          expect(value.hasParam, isFalse);
          expect(value.hasSequenceNumber, isFalse);
          expect(value.toJson(), {
            'type': 'error',
            'message': 'private message',
          });
          expect(value.copyWith(), value);
          expect(parser.value(value.toJson()), value);
          expect(parser.value(value.toJson()).hashCode, value.hashCode);
          final canonical = value.copyWith(code: null, param: null);
          expect(canonical.hasCode, isTrue);
          expect(canonical.hasParam, isTrue);
          expect(parser.value(canonical.toJson()), canonical);
        },
      );
      for (final key in ['code', 'param']) {
        test('${parser.key} legacy explicit nullable $key retained', () {
          final value = parser.value({
            'type': 'error',
            'error': {'message': 'private message', key: null},
          });
          expect(value.toJson().containsKey(key), isTrue);
          expect(value.toJson()[key], isNull);
        });
      }
      for (final absentKey in ['code', 'param']) {
        test('${parser.key} legacy flat omission $absentKey round trips', () {
          final source = _canonical()..remove(absentKey);
          final value = parser.value(source);
          expect(value.toJson(), source);
          expect(value.hasCode, absentKey != 'code');
          expect(value.hasParam, absentKey != 'param');
          expect(parser.value(value.toJson()), value);
          expect(parser.value(value.toJson()).hashCode, value.hashCode);
        });
      }
      test('${parser.key} legacy missing message does not invent text', () {
        expect(
          () => parser.value({'type': 'error', 'error': <String, dynamic>{}}),
          throwsA(_context('ErrorEvent.message')),
        );
      });
      for (final error in <Object?>[false, 2, '', []]) {
        test('${parser.key} malformed legacy object $error', () {
          expect(
            () => parser.value({'type': 'error', 'error': error}),
            throwsA(_context('ErrorEvent.error')),
          );
        });
      }
    }
  });

  group('failed lifecycle monitoring diagnostics', () {
    for (final withDetails in [false, true]) {
      test('redacts monitored response and agent withDetails=$withDetails', () {
        final response = Response(
          id: 'private response id',
          object: 'response',
          createdAt: 1,
          status: ResponseStatus.failed,
          output: const [],
          error: ResponseError(
            code: withDetails
                ? 'unknown code'
                : 'misalignment_policy_violation',
            message: 'private explanation',
            misalignment: withDetails
                ? const ResponsesMisalignmentDetails(errorType: 'unknown type')
                : null,
          ),
        );
        final event = ResponseFailedEvent(
          response: response,
          sequenceNumber: 9,
          agent: const AgentTag(agentName: 'private agent'),
        );
        for (final secret in [
          'private response id',
          'private agent',
          'private explanation',
        ]) {
          expect(event.toString(), isNot(contains(secret)));
        }
        expect(event.toString(), contains('sequenceNumber: 9'));
        expect(event.response.id, 'private response id');
        expect(event.agent?.agentName, 'private agent');
        expect(event.response.error?.message, 'private explanation');
        expect(
          (ResponseStreamEvent.fromJson(event.toJson()) as ResponseFailedEvent)
              .response
              .error
              ?.misalignment,
          response.error?.misalignment,
        );
      });
    }
    test('unrelated lifecycle diagnostics preserve existing format', () {
      const event = ResponseFailedEvent(
        response: Response(
          id: 'resp_local',
          object: 'response',
          createdAt: 1,
          status: ResponseStatus.failed,
          output: [],
        ),
        agent: AgentTag(agentName: 'local agent'),
      );
      expect(
        event.toString(),
        'ResponseFailedEvent(response: resp_local, agent: AgentTag(agentName: local agent))',
      );
    });
  });

  group('complete value semantics and immutable ownership', () {
    test('old const constructor and direct import remain usable', () {
      const old = direct.ErrorEvent(code: 'old code', message: 'old message');
      const nullable = direct.ErrorEvent(code: null, message: 'message');
      const beta = direct.ErrorEvent(
        code: null,
        message: 'message',
        agent: direct_agent.AgentTag(agentName: 'private agent'),
      );
      expect(old.toJson(), {
        'type': 'error',
        'code': 'old code',
        'message': 'old message',
        'param': null,
      });
      expect(nullable.code, isNull);
      expect(nullable.hasCode, isTrue);
      expect(beta.agent?.agentName, 'private agent');
      expect(ErrorEvent.fromJson(old.toJson()), old);
    });
    test('copy replaces and clears all typed fields', () {
      final value = ErrorEvent.fromJson(
        _canonical()
          ..['code'] = 'code'
          ..['param'] = 'parameter'
          ..['agent'] = {'agent_name': 'private name'},
      );
      final changed = value.copyWith(
        code: 'new code',
        message: 'new message',
        param: 'new parameter',
        sequenceNumber: 24,
        agent: const AgentTag(agentName: 'new name'),
      );
      expect(changed.toJson(), {
        'type': 'error',
        'code': 'new code',
        'message': 'new message',
        'param': 'new parameter',
        'sequence_number': 24,
        'agent': {'agent_name': 'new name'},
      });
      final cleared = changed.copyWith(
        code: null,
        param: null,
        sequenceNumber: null,
        agent: null,
      );
      expect(cleared.toJson(), {
        'type': 'error',
        'code': null,
        'message': 'new message',
        'param': null,
        'agent': null,
      });
      expect(
        cleared
            .copyWith(hasCode: false, hasParam: false, hasAgent: false)
            .toJson(),
        {'type': 'error', 'message': 'new message'},
      );
      expect(changed, isNot(value));
      expect(ErrorEvent.fromJson(changed.toJson()).hashCode, changed.hashCode);
    });
    test('future agent fields persist until fresh replacement', () {
      final value = ErrorEvent.fromJson(
        _canonical()
          ..['agent'] = {
            'agent_name': 'private name',
            'future': {'token': 'private token'},
          },
      );
      expect(value.copyWith(message: 'changed').toJson()['agent'], {
        'agent_name': 'private name',
        'future': {'token': 'private token'},
      });
      expect(
        value
            .copyWith(agent: const AgentTag(agentName: 'private name'))
            .toJson()['agent'],
        {'agent_name': 'private name'},
      );
      expect(value.copyWith(agent: null).toJson()['agent'], isNull);
      expect(
        value
            .copyWith(agent: null, hasAgent: false)
            .toJson()
            .containsKey('agent'),
        isFalse,
      );
      final override = value.copyWith(
        agent: const AgentTag(agentName: 'replacement'),
        rawJson: {
          'agent': {'agent_name': 'stale', 'new_future': true},
        },
      );
      expect(override.toJson()['agent'], {
        'agent_name': 'replacement',
        'new_future': true,
      });
      expect(value.copyWith(), value);
      expect(value.copyWith().hashCode, value.hashCode);
    });
    test(
      'explicit parent raw override takes precedence over legacy archive',
      () {
        final legacy = ErrorEvent.fromJson(const {
          'type': 'error',
          'error': {'message': 'legacy message'},
        });
        final copy = legacy.copyWith(
          rawJson: const {
            'error': {'private_future': true},
          },
        );
        expect(copy.toJson(), {
          'type': 'error',
          'message': 'legacy message',
          'error': {'private_future': true},
        });
        expect(ErrorEvent.fromJson(copy.toJson()), copy);
      },
    );
    test(
      'caller-owned invalid constructor metadata fails safely on output',
      () {
        final value = ErrorEvent(
          code: null,
          message: 'private message',
          rawJson: {'private future': DateTime(2026)},
        );
        expect(value.toJson, throwsA(_context('ErrorEvent.rawJson')));
      },
    );
    test('schema-known stale raw values never override typed values', () {
      const value = ErrorEvent(
        code: 'typed code',
        message: 'typed message',
        rawJson: {
          'type': 'wrong',
          'code': 'stale',
          'param': 'stale',
          'message': 'stale',
          'sequence_number': 99,
          'agent': {'agent_name': 'stale'},
          'future': false,
        },
      );
      expect(value.toJson(), {
        'type': 'error',
        'code': 'typed code',
        'param': null,
        'message': 'typed message',
        'future': false,
      });
    });
    test('deep future metadata defines equality independent of key order', () {
      final first = ErrorEvent.fromJson(
        _canonical()
          ..['future'] = {
            'items': [
              true,
              {'a': 1, 'b': null},
            ],
            'false': false,
          },
      );
      final second = ErrorEvent.fromJson(
        _canonical()
          ..['future'] = {
            'false': false,
            'items': [
              true,
              {'b': null, 'a': 1},
            ],
          },
      );
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect({first, second}, hasLength(1));
      expect(first.copyWith(rawJson: {'future': true}), isNot(first));
      expect(first.copyWith(sequenceNumber: null), isNot(first));
      expect(first.copyWith(code: 'different'), isNot(first));
      expect(first.copyWith(param: 'different'), isNot(first));
      expect(first.copyWith(message: 'different'), isNot(first));
      expect(first.copyWith(agent: null), isNot(first));
    });
    test('parsed raw metadata is a deep snapshot', () {
      final nested = <String, dynamic>{
        'values': <Object?>[true, null],
      };
      final source = _canonical()
        ..['agent'] = {'agent_name': 'private name', 'future': nested}
        ..['future'] = nested;
      final value = ErrorEvent.fromJson(source);
      final original = jsonDecode(jsonEncode(source));
      (nested['values'] as List<Object?>).add('mutation');
      source['message'] = 'mutated';
      expect(value.toJson(), original);
      expect(
        () => value.rawJson['message'] = 'mutation',
        throwsUnsupportedError,
      );
      final future = value.rawJson['future'] as Map<String, dynamic>;
      expect(() => future['new'] = true, throwsUnsupportedError);
      expect(
        () => (future['values'] as List<dynamic>).add(true),
        throwsUnsupportedError,
      );
      final replacement = <String, dynamic>{
        'future': <Object?>[false],
      };
      final copy = value.copyWith(rawJson: replacement);
      (replacement['future'] as List<Object?>).add(true);
      expect(copy.toJson()['future'], [false]);
    });
    test('diagnostics redact every sensitive typed and raw value', () {
      final value = ErrorEvent.fromJson(
        _canonical()
          ..['code'] = 'private code'
          ..['param'] = 'private parameter'
          ..['agent'] = {'agent_name': 'private name'}
          ..['secret_future_key'] = 'private raw',
      );
      final diagnostic = value.toString();
      for (final secret in [
        'private code',
        'private parameter',
        'private name',
        'private explanation',
        'private raw',
        'secret_future_key',
      ]) {
        expect(diagnostic, isNot(contains(secret)));
      }
      for (final field in [
        'code',
        'message',
        'param',
        'sequenceNumber',
        'agent',
        'hasCode',
        'hasParam',
        'hasSequenceNumber',
        'hasAgent',
        'rawJson',
      ]) {
        expect(diagnostic, contains(field));
      }
      expect(value.code, 'private code');
      expect(value.message, 'private explanation');
    });
    for (final malformed in <Object?>[
      double.infinity,
      double.nan,
      DateTime(2026),
      <int, String>{1: 'private'},
    ]) {
      test(
        'invalid future metadata is rejected safely: ${malformed.runtimeType}',
        () {
          expect(
            () =>
                ErrorEvent.fromJson(_canonical()..['private key'] = malformed),
            throwsA(_context('ErrorEvent')),
          );
        },
      );
    }
    test(
      'cyclic future metadata fails without recursion or payload disclosure',
      () {
        final cycle = <String, dynamic>{};
        cycle['private key'] = cycle;
        expect(
          () => ErrorEvent.fromJson(_canonical()..['future'] = cycle),
          throwsA(_context('ErrorEvent')),
        );
      },
    );
  });
}
