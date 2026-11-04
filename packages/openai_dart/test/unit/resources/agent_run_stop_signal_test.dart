import 'dart:async';

import 'package:openai_dart/src/helpers/agents/agent_run_stop_signal.dart';
import 'package:test/test.dart';

void main() {
  test(
    'completed large operations unregister while lifetime remains open',
    () async {
      final signal = AgentRunStopSignal();
      for (var i = 0; i < 100; i++) {
        final output = List<int>.filled(16384, i);
        expect(
          await signal.race(
            Future.value(output),
            onStop: () => throw StateError('stopped'),
          ),
          same(output),
        );
        expect(signal.pendingOperations, 0);
      }
      final pending = Completer<void>();
      final future = signal.race(
        pending.future,
        onStop: () => throw StateError('stopped'),
      );
      expect(signal.pendingOperations, 1);
      pending.complete();
      await future;
      expect(signal.pendingOperations, 0);
    },
  );

  test(
    'failure unregisters; stop settles active races and consumes losing errors',
    () async {
      final signal = AgentRunStopSignal();
      await expectLater(
        signal.race(
          Future<void>.error(StateError('operation')),
          onStop: () => throw StateError('stop'),
        ),
        throwsStateError,
      );
      expect(signal.pendingOperations, 0);
      final pending = Completer<void>();
      final future = signal.race(
        pending.future,
        onStop: () => throw StateError('stop'),
      );
      final check = expectLater(future, throwsStateError);
      signal.stop();
      await check;
      expect(signal.pendingOperations, 0);
      pending.completeError(StateError('late'));
      await Future<void>.delayed(Duration.zero);
      signal.stop();
      expect(signal.pendingOperations, 0);
    },
  );

  test(
    'already stopped consumes late successful operations without registration',
    () async {
      final signal = AgentRunStopSignal()..stop();
      final operation = Completer<Object>();
      await expectLater(
        signal.race(operation.future, onStop: () => throw StateError('stop')),
        throwsStateError,
      );
      expect(signal.pendingOperations, 0);
      operation.complete(List<int>.filled(16384, 1));
      await Future<void>.delayed(Duration.zero);
      expect(signal.pendingOperations, 0);
    },
  );
}
