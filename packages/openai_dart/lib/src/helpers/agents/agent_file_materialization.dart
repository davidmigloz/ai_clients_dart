import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../errors/exceptions.dart';
import 'agent_file_abort.dart';
import 'agent_file_inputs.dart';

/// Internal bounded per-file materializer with removable abort ownership.
@internal
Future<Uint8List> materializeAgentFile(
  AgentFileInput input,
  int budget,
  AgentFileAbortGate gate,
) async {
  gate.check();
  if (input is AgentFileInputBytes) return input.bytes;
  final selected = input as AgentFileInputStream;
  final outcome = Completer<Uint8List>();
  final bytes = BytesBuilder();
  StreamSubscription<List<int>>? subscription;
  var ended = false;
  var received = 0;
  void cancel() {
    try {
      subscription?.cancel().ignore();
    } catch (_) {
      /* Best-effort private source cleanup. */
    }
  }

  void fail(Object error) {
    if (ended) return;
    ended = true;
    outcome.completeError(error, StackTrace.current);
    cancel();
  }

  final removeAbort = gate.listen(
    () => fail(
      const AbortedException(
        message: 'Agent file source aborted',
        redactDiagnostics: true,
        stage: AbortionStage.beforeRequest,
      ),
    ),
  );
  try {
    final source = selected.open();
    subscription = source.listen(
      (chunk) {
        if (ended) return;
        if (chunk.any((byte) => !byte.isFinite || byte < 0 || byte > 255) ||
            received + chunk.length > budget ||
            received + chunk.length > selected.length) {
          fail(
            const FormatException(
              'Agent file source exceeded its declared length/budget or contained invalid bytes.',
            ),
          );
          return;
        }
        received += chunk.length;
        bytes.add(chunk);
      },
      onError: (Object error) => fail(
        ConnectionException(
          message: 'Agent file source failed',
          cause: error,
          redactDiagnostics: true,
        ),
      ),
      onDone: () {
        if (ended) return;
        if (received != selected.length) {
          fail(const FormatException('Agent file source length changed.'));
        } else {
          ended = true;
          outcome.complete(bytes.takeBytes().asUnmodifiableView());
        }
      },
    );
    if (ended) cancel();
  } catch (error) {
    fail(
      ConnectionException(
        message: 'Agent file source could not open',
        cause: error,
        redactDiagnostics: true,
      ),
    );
  }
  try {
    return await outcome.future;
  } finally {
    removeAbort();
  }
}
