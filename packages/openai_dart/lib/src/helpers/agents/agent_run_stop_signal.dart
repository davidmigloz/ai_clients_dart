import 'dart:async';

/// Internal removable stop registrations for one Agent helper invocation.
///
/// This is not exported from the package. Completed operations remove their stop
/// registration, so an uncompleted lifetime signal cannot retain old payloads.
final class AgentRunStopSignal {
  final _listeners = <void Function()>{};
  bool _stopped = false;

  /// Active operation registrations, exposed only to internal deterministic tests.
  int get pendingOperations => _listeners.length;

  /// Races an operation while removing its stop registration on every outcome.
  /// Losing late operation values/errors are consumed without changing the result.
  Future<T> race<T>(Future<T> operation, {required Never Function() onStop}) {
    final result = Completer<T>();
    void stop() {
      if (result.isCompleted) return;
      try {
        onStop();
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    }

    if (_stopped) {
      stop();
    } else {
      _listeners.add(stop);
    }
    operation.then<void>(
      (value) {
        _listeners.remove(stop);
        if (!result.isCompleted) result.complete(value);
      },
      onError: (Object error, StackTrace stack) {
        _listeners.remove(stop);
        if (!result.isCompleted) result.completeError(error, stack);
      },
    );
    return result.future;
  }

  /// Settles every active race once, without keeping completed registrations.
  void stop() {
    if (_stopped) return;
    _stopped = true;
    final pending = _listeners.toList();
    _listeners.clear();
    for (final notify in pending) {
      notify();
    }
  }
}
