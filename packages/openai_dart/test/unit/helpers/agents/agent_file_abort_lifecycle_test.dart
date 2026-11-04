import 'dart:async';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/helpers/agents/agent_file_abort.dart';
import 'package:openai_dart/src/helpers/agents/agent_file_materialization.dart';
import 'package:test/test.dart';

void main() {
  test(
    'completed materializations remove every per-file abort registration',
    () async {
      final neverAbort = Completer<void>();
      final gate = AgentFileAbortGate(neverAbort.future);
      for (var index = 0; index < 20; index++) {
        final value = AgentFileInput.stream(
          open: () => Stream.value([index, 255]),
          length: 2,
          filename: 'selected',
          destination: '/workspace/selected',
        );
        expect(await materializeAgentFile(value, 2, gate), [index, 255]);
        expect(gate.listenerCount, 0);
      }
      expect(gate.aborted, isFalse);
      gate.dispose();
      expect(gate.listenerCount, 0);
      neverAbort.complete();
      await Future<void>.delayed(Duration.zero);
      expect(gate.aborted, isFalse);
    },
  );
  test(
    'failure and cancellation remove active source callbacks without waiting for source cancel',
    () async {
      final gate = AgentFileAbortGate(null);
      await expectLater(
        materializeAgentFile(
          AgentFileInput.stream(
            open: () => Stream.value([1]),
            length: 2,
            filename: 'selected',
            destination: '/workspace/a',
          ),
          2,
          gate,
        ),
        throwsFormatException,
      );
      expect(gate.listenerCount, 0);
      final ready = Completer<void>();
      var cancels = 0;
      final source = StreamController<List<int>>(
        onListen: ready.complete,
        onCancel: () {
          cancels++;
          return Completer<void>().future;
        },
      );
      final materialized = materializeAgentFile(
        AgentFileInput.stream(
          open: () => source.stream,
          length: 2,
          filename: 'selected',
          destination: '/workspace/a',
        ),
        2,
        gate,
      );
      final assertion = expectLater(
        materialized,
        throwsA(isA<AbortedException>()),
      );
      await ready.future;
      expect(gate.listenerCount, 1);
      gate.abort();
      await assertion;
      expect(gate.listenerCount, 0);
      expect(cancels, 1);
      source.close().ignore();
      gate.dispose();
    },
  );
  test(
    'native signals are per-upload and settled/disconnected after success or abort',
    () async {
      final gate = AgentFileAbortGate(Completer<void>().future);
      final first = gate.bind();
      expect(gate.listenerCount, 1);
      var settled = false;
      unawaited(first.future.then((_) => settled = true));
      first.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(settled, isTrue);
      expect(gate.listenerCount, 0);
      expect(gate.aborted, isFalse);
      final second = gate.bind();
      expect(gate.listenerCount, 1);
      gate.abort();
      await second.future;
      second.dispose();
      expect(gate.listenerCount, 0);
      gate.dispose();
    },
  );
}
