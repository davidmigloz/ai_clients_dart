import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

ResponsesReconnectDecision _continue(ResponsesReconnectContext context) =>
    const ResponsesReconnectDecision.continueWith();
ResponsesReconnectDecision _abort(ResponsesReconnectContext context) =>
    const ResponsesReconnectDecision.abort();

const _options = ResponsesReconnectOptions(onReconnecting: _continue);
const _context = ResponsesReconnectContext(
  attempt: 1,
  maxAttempts: 5,
  delay: Duration(milliseconds: 375),
  closeCode: 1006,
  closeReason: 'private reason with token',
);

void _equal(Object original, Object copy) {
  expect(original, copy);
  expect(copy, original);
  expect(copy.hashCode, original.hashCode);
}

void main() {
  group('reconnect configuration', () {
    test(
      'const defaults require an explicit callback and match SDK timing',
      () async {
        _options.validate();
        expect(_options.maxAttempts, 5);
        expect(_options.initialDelay, const Duration(milliseconds: 500));
        expect(_options.maxDelay, const Duration(seconds: 8));
        expect(_options.maxQueueBytes, 1048576);
        expect((await _options.onReconnecting(_context)).isAborted, isFalse);
        _equal(_options, _options.copyWith());
      },
    );

    final changed = [
      _options.copyWith(onReconnecting: _abort),
      _options.copyWith(maxAttempts: 2),
      _options.copyWith(initialDelay: const Duration(milliseconds: 250)),
      _options.copyWith(maxDelay: const Duration(seconds: 2)),
      _options.copyWith(maxQueueBytes: 12),
    ];
    for (var index = 0; index < changed.length; index++) {
      test('each option participates in copy/equality/hash $index', () {
        expect(changed[index], isNot(_options));
        _equal(changed[index], changed[index].copyWith());
        changed[index].validate();
      });
    }

    test('zero limits and a cap below the initial delay remain valid', () {
      const zero = ResponsesReconnectOptions(
        onReconnecting: _continue,
        maxAttempts: 0,
        initialDelay: Duration.zero,
        maxDelay: Duration.zero,
        maxQueueBytes: 0,
      );
      expect(zero.validate, returnsNormally);
      _options.copyWith(maxDelay: const Duration(milliseconds: 1)).validate();
    });

    final invalid = [
      _options.copyWith(maxAttempts: -1),
      _options.copyWith(initialDelay: const Duration(microseconds: -1)),
      _options.copyWith(maxDelay: const Duration(microseconds: -1)),
      _options.copyWith(maxQueueBytes: -1),
    ];
    for (var index = 0; index < invalid.length; index++) {
      test('release-safe rejection of negative config $index', () {
        expect(invalid[index].validate, throwsArgumentError);
        expect(invalid[index].toString(), isNot(contains('private')));
      });
    }
    for (final value in <num>[double.infinity, double.nan]) {
      for (final attempts in [false, true]) {
        test(
          'nonfinite JS int cannot enter config $value attempts=$attempts',
          () {
            expect(() {
              (attempts
                      ? _options.copyWith(maxAttempts: value as int)
                      : _options.copyWith(maxQueueBytes: value as int))
                  .validate();
            }, throwsA(anyOf(isA<TypeError>(), isA<ArgumentError>())));
          },
        );
      }
    }
    test(
      'callback supports asynchronous preparation without implicit continue',
      () async {
        final options = ResponsesReconnectOptions(
          onReconnecting: (context) {
            expect(context, _context);
            return Future<ResponsesReconnectDecision>.value(
              const ResponsesReconnectDecision.abort(),
            );
          },
        );
        final decision = await options.onReconnecting(_context);
        expect(decision.isAborted, isTrue);
        expect(options.toString(), isNot(contains('_abort')));
      },
    );
  });

  group('attempt metadata and callback decisions', () {
    test(
      'context is const, includes every field, and clears nullable reason',
      () {
        _equal(_context, _context.copyWith());
        final changed = [
          _context.copyWith(attempt: 2),
          _context.copyWith(maxAttempts: 6),
          _context.copyWith(delay: Duration.zero),
          _context.copyWith(closeCode: 1012),
          _context.copyWith(closeReason: null),
        ];
        for (final value in changed) {
          expect(value, isNot(_context));
          _equal(value, value.copyWith());
        }
        expect(_context.copyWith(closeReason: null).closeReason, isNull);
        expect(_context.toString(), isNot(contains('private')));
        expect(_context.toString(), contains('closeReason: [REDACTED]'));
        expect(
          _context.copyWith(closeReason: null).toString(),
          contains('closeReason: null'),
        );
      },
    );

    test(
      'null reuses overrides and an empty map explicitly replaces with none',
      () {
        const reuse = ResponsesReconnectDecision.continueWith();
        const clear = ResponsesReconnectDecision.continueWith(
          queryParameters: {},
          headers: {},
        );
        const abort = ResponsesReconnectDecision.abort();
        expect(reuse.isAborted, isFalse);
        expect(reuse.queryParameters, isNull);
        expect(reuse.headers, isNull);
        expect(clear.queryParameters, isEmpty);
        expect(clear.headers, isEmpty);
        expect(clear, isNot(reuse));
        expect(abort.isAborted, isTrue);
        expect(abort.queryParameters, isNull);
        expect(abort.headers, isNull);
        _equal(reuse, reuse.copyWith());
        _equal(clear, clear.snapshot());
        _equal(abort, abort.copyWith());
      },
    );

    test('snapshot freezes replacement maps before caller mutation', () {
      final query = {'private-key': 'private-value'};
      final headers = {'Authorization': 'Bearer private-token'};
      final decision = ResponsesReconnectDecision.continueWith(
        queryParameters: query,
        headers: headers,
      );
      expect(identical(decision.queryParameters, query), isTrue);
      expect(identical(decision.headers, headers), isTrue);
      final snapshot = decision.snapshot();
      _equal(decision, snapshot);
      query.clear();
      headers['Authorization'] = 'changed';
      expect(snapshot.queryParameters, {'private-key': 'private-value'});
      expect(snapshot.headers, {'Authorization': 'Bearer private-token'});
      expect(() => snapshot.queryParameters!.clear(), throwsUnsupportedError);
      expect(() => snapshot.headers!.clear(), throwsUnsupportedError);
      expect(snapshot.toString(), isNot(contains('private')));
      expect(snapshot.toString(), isNot(contains('Authorization')));
    });

    test(
      'full decision copies compare maps by values independent of insertion order',
      () {
        const original = ResponsesReconnectDecision.continueWith(
          queryParameters: {'a': '1', 'b': '2'},
          headers: {'a': '3', 'b': '4'},
        );
        const reordered = ResponsesReconnectDecision.continueWith(
          headers: {'b': '4', 'a': '3'},
          queryParameters: {'b': '2', 'a': '1'},
        );
        _equal(original, reordered);
        expect(original.copyWith(isAborted: true), isNot(original));
        expect(
          original.copyWith(queryParameters: const {'a': 'new'}),
          isNot(original),
        );
        expect(original.copyWith(headers: const {'a': 'new'}), isNot(original));
        final cleared = original.copyWith(queryParameters: null, headers: null);
        expect(cleared.queryParameters, isNull);
        expect(cleared.headers, isNull);
        _equal(cleared, const ResponsesReconnectDecision.continueWith());
        expect(
          const ResponsesReconnectDecision.abort().copyWith(isAborted: false),
          cleared,
        );
      },
    );
  });

  group('never-attempted immutable wire snapshots', () {
    for (final (text, byteLength) in [
      ('', 0),
      ('ascii', 5),
      ('aé😀', 7),
      ('😀😀', 8),
    ]) {
      test('exact UTF-8 accounting for $text', () {
        final message = ResponsesUnsentMessage.fromText(text);
        expect(message.text, text);
        expect(message.byteLength, byteLength);
        _equal(message, message.copyWith());
        final changed = message.copyWith(text: 'private');
        expect(changed.byteLength, 7);
        expect(changed, isNot(message));
        expect(changed.toString(), isNot(contains('private')));
      });
    }
    test(
      'decoded nested JSON is recursively frozen without reserializing wire text',
      () {
        final caller = <String, dynamic>{
          'type': 'response.create',
          'input': {
            'private': [null, true, 1.25],
          },
        };
        final wire = jsonEncode(caller);
        final message = ResponsesUnsentMessage.fromText(wire);
        caller.clear();
        expect(message.text, wire);
        final decoded = message.message;
        expect(decoded['type'], 'response.create');
        expect(decoded.clear, throwsUnsupportedError);
        expect(
          () => (decoded['input'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(
          () =>
              ((decoded['input'] as Map<String, dynamic>)['private']
                      as List<dynamic>)
                  .clear(),
          throwsUnsupportedError,
        );
        expect(message.toString(), isNot(contains('private')));
      },
    );
    for (final text in [
      'private invalid JSON',
      'null',
      '[]',
      '"private string"',
      'true',
      '12',
      '{"private":1e999}',
    ]) {
      test(
        'raw text remains available while invalid JSON convenience rejects $text',
        () {
          final message = ResponsesUnsentMessage.fromText(text);
          expect(message.text, text);
          expect(
            () => message.message,
            throwsA(
              isA<FormatException>().having(
                (error) => error.toString(),
                'safe diagnostics',
                isNot(contains('private')),
              ),
            ),
          );
        },
      );
    }
  });

  group('SDK lifecycle and identifiable failures', () {
    test('all named lifecycle factories expose their typed records', () {
      expect(
        const ResponsesRecoveryEvent.reconnecting(_context),
        const ResponsesRecoveryReconnecting(_context),
      );
      expect(
        const ResponsesRecoveryEvent.reconnected(2),
        const ResponsesRecoveryReconnected(2),
      );
      expect(
        const ResponsesRecoveryEvent.queueOverflow(
          frameBytes: 3,
          maxQueueBytes: 2,
          queuedBytes: 1,
        ),
        const ResponsesRecoveryQueueOverflow(
          frameBytes: 3,
          maxQueueBytes: 2,
          queuedBytes: 1,
        ),
      );
      expect(
        const ResponsesRecoveryEvent.deliveryUnknown(
          frameBytes: 3,
          operation: 'send',
        ),
        const ResponsesRecoveryDeliveryUnknown(
          frameBytes: 3,
          operation: 'send',
        ),
      );
      expect(
        const ResponsesRecoveryEvent.transportError(operation: 'receive'),
        const ResponsesRecoveryTransportError(operation: 'receive'),
      );
      expect(
        ResponsesRecoveryEvent.closed(cause: 'explicit_close'),
        ResponsesRecoveryClosed(cause: 'explicit_close'),
      );
    });

    test(
      'terminal report snapshots FIFO list, full fields and nullable clears',
      () {
        final first = ResponsesUnsentMessage.fromText('private first');
        final second = ResponsesUnsentMessage.fromText('private second');
        final caller = [first, second];
        final closed = ResponsesRecoveryClosed(
          code: 1008,
          reason: 'private reason',
          cause: 'private cause',
          unsentMessages: caller,
        );
        caller.clear();
        expect(closed.unsentMessages, [first, second]);
        expect(closed.unsentMessages.clear, throwsUnsupportedError);
        _equal(closed, closed.copyWith());
        final changed = [
          closed.copyWith(code: null),
          closed.copyWith(reason: null),
          closed.copyWith(cause: 'other'),
          closed.copyWith(unsentMessages: [second, first]),
          closed.copyWith(unsentMessages: [first]),
        ];
        for (final value in changed) {
          expect(value, isNot(closed));
          _equal(value, value.copyWith());
        }
        final cleared = closed.copyWith(code: null, reason: null);
        expect(cleared.code, isNull);
        expect(cleared.reason, isNull);
        expect(closed.toString(), isNot(contains('private')));
        final replacement = [second];
        final copied = closed.copyWith(unsentMessages: replacement);
        replacement.clear();
        expect(copied.unsentMessages, [second]);
      },
    );

    test('scalar lifecycle records copy and compare every field', () {
      const reconnecting = ResponsesRecoveryReconnecting(_context);
      const reconnected = ResponsesRecoveryReconnected(1);
      const overflow = ResponsesRecoveryQueueOverflow(
        frameBytes: 9,
        maxQueueBytes: 8,
        queuedBytes: 1,
      );
      const unknown = ResponsesRecoveryDeliveryUnknown(
        frameBytes: 9,
        operation: 'private operation',
      );
      const error = ResponsesRecoveryTransportError(
        operation: 'private receive',
      );
      _equal(reconnecting, reconnecting.copyWith());
      _equal(reconnected, reconnected.copyWith());
      _equal(overflow, overflow.copyWith());
      _equal(unknown, unknown.copyWith());
      _equal(error, error.copyWith());
      expect(
        reconnecting.copyWith(context: _context.copyWith(attempt: 2)),
        isNot(reconnecting),
      );
      expect(reconnected.copyWith(attempt: 2), isNot(reconnected));
      expect(overflow.copyWith(frameBytes: 10), isNot(overflow));
      expect(overflow.copyWith(maxQueueBytes: 10), isNot(overflow));
      expect(overflow.copyWith(queuedBytes: 2), isNot(overflow));
      expect(unknown.copyWith(frameBytes: 10), isNot(unknown));
      expect(unknown.copyWith(operation: 'flush'), isNot(unknown));
      expect(error.copyWith(operation: 'close'), isNot(error));
      for (final value in <ResponsesRecoveryEvent>[
        reconnecting,
        unknown,
        error,
      ]) {
        expect(value.toString(), isNot(contains('private')));
      }
    });

    test(
      'queue rejection and attempted-write errors have complete safe values',
      () {
        const overflow = ResponsesSendQueueOverflowException(
          frameBytes: 9,
          maxQueueBytes: 8,
          queuedBytes: 1,
        );
        const unknown = ResponsesDeliveryUnknownException(
          frameBytes: 9,
          operation: 'private operation',
        );
        expect(overflow, isA<Exception>());
        expect(unknown, isA<Exception>());
        _equal(overflow, overflow.copyWith());
        _equal(unknown, unknown.copyWith());
        expect(overflow.copyWith(frameBytes: 10), isNot(overflow));
        expect(overflow.copyWith(maxQueueBytes: 10), isNot(overflow));
        expect(overflow.copyWith(queuedBytes: 2), isNot(overflow));
        expect(unknown.copyWith(frameBytes: 10), isNot(unknown));
        expect(unknown.copyWith(operation: 'flush'), isNot(unknown));
        expect(unknown.toString(), isNot(contains('private')));
        expect(
          overflow,
          isNot(
            const ResponsesRecoveryQueueOverflow(
              frameBytes: 9,
              maxQueueBytes: 8,
              queuedBytes: 1,
            ),
          ),
        );
      },
    );
  });
}
