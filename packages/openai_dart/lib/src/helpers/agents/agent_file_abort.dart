import 'dart:async';

import 'package:meta/meta.dart';

import '../../errors/exceptions.dart';

/// Internal removable cancellation registrations for one file preparation.
/// The caller's Future retains only this gate, never completed file outcomes.
@internal
final class AgentFileAbortGate {
  /// Registers one external continuation; operation listeners are removable.
  AgentFileAbortGate(Future<void>? trigger) {
    unawaited(trigger?.then((_) => abort(), onError: (Object _) => abort()));
  }

  final _listeners = <void Function()>{};
  bool _aborted = false;
  bool _disposed = false;

  /// Active operation registrations, useful for deterministic lifecycle tests.
  int get listenerCount => _listeners.length;

  /// Whether the external abort has been observed.
  bool get aborted => _aborted;

  /// Registers a callback and returns an idempotent removal function.
  void Function() listen(void Function() callback) {
    if (_disposed) throw StateError('File cancellation scope is disposed.');
    if (_aborted) {
      callback();
      return () {};
    }
    _listeners.add(callback);
    return () => _listeners.remove(callback);
  }

  /// Cancels active work once; one failing cleanup cannot strand other work.
  void abort() {
    if (_aborted || _disposed) return;
    _aborted = true;
    for (final listener in List<void Function()>.of(_listeners)) {
      if (_listeners.contains(listener)) {
        try {
          listener();
        } catch (_) {
          /* Best-effort private cleanup. */
        }
      }
    }
  }

  /// Throws before opening a source or starting the next upload.
  void check() {
    if (_aborted) {
      throw const AbortedException(
        message: 'Agent file preparation aborted',
        redactDiagnostics: true,
        stage: AbortionStage.beforeRequest,
      );
    }
  }

  /// Binds a fresh native abort Future to only one HTTP attempt's lifetime.
  /// Disposal settles that Future so transport listeners do not accumulate on
  /// the caller's never-completing shared cancellation Future.
  AgentFileAbortSignal bind() {
    final completion = Completer<void>();
    final remove = listen(() {
      if (!completion.isCompleted) completion.complete();
    });
    return AgentFileAbortSignal._(completion, remove);
  }

  /// Drops registrations after preparation settles, without retaining payloads.
  void dispose() {
    _disposed = true;
    _listeners.clear();
  }
}

/// Internal request-local signal; always dispose when its operation settles.
@internal
final class AgentFileAbortSignal {
  AgentFileAbortSignal._(this._completion, this._remove);
  final Completer<void> _completion;
  void Function()? _remove;

  /// Native request cancellation/cleanup Future, unique to this operation.
  Future<void> get future => _completion.future;

  /// Removes the gate callback and releases transport cancellation listeners.
  void dispose() {
    _remove?.call();
    _remove = null;
    if (!_completion.isCompleted) _completion.complete();
  }
}
