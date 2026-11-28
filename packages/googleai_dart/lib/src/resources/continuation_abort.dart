import 'dart:async'
    show Completer, StreamController, StreamSubscription, Timer, unawaited;

import '../errors/exceptions.dart';
import '../utils/request_id.dart';

/// A deadline and cancellation signal shared by a sequence of HTTP requests.
class ContinuationAbort {
  final String _operation;
  final Duration _timeout;
  final Stopwatch _elapsed = Stopwatch()..start();
  final Completer<void> _abort = Completer<void>();
  late final Timer _timer;
  bool _closed = false;
  Exception? _failure;
  bool _subscriptionCancelled = false;

  /// Whether the caller canceled their stream subscription.
  bool get subscriptionCancelled => _subscriptionCancelled;

  /// Starts a deadline and optionally watches an explicit abort trigger.
  ContinuationAbort(this._operation, this._timeout, Future<void>? trigger) {
    _timer = Timer(_timeout, _timeOut);
    if (trigger != null) {
      unawaited(
        trigger.then(
          (_) => _abortByUser(AbortionStage.beforeRequest),
          onError: (Object _, StackTrace _) {},
        ),
      );
    }
  }

  void _abortByUser(AbortionStage stage) => _stop(
    AbortedException(
      message: '$_operation aborted by user',
      correlationId: generateRequestId(),
      timestamp: DateTime.now(),
      stage: stage,
    ),
  );

  /// Cancels the current HTTP request when the listener no longer needs it.
  void cancelSubscription() {
    _subscriptionCancelled = true;
    _abortByUser(AbortionStage.duringStream);
  }

  /// Completes when active HTTP work should abort.
  Future<void> get future => _abort.future;

  /// Waits for a response or for the full operation to stop.
  Future<T> race<T>(Future<T> response) async {
    // Future.any handles a late response error even if cancellation wins.
    final value = await Future.any<T>([
      response,
      future.then<T>((_) => throw _failure!),
    ]);
    check();
    return value;
  }

  /// Throws if the operation has stopped.
  void check() {
    if (_elapsed.elapsed >= _timeout) _timeOut();
    final current = _failure;
    if (current != null) throw current;
  }

  void _timeOut() => _stop(
    TimeoutException(
      message: 'The ${_operation.toLowerCase()} deadline elapsed',
      timeout: _timeout,
      elapsed: _elapsed.elapsed,
    ),
  );

  /// Prefers the full operation deadline or abort to a transport failure.
  Exception resolveFailure(Exception error) => switch (_failure) {
    final TimeoutException timeout => timeout,
    _ when error is AbortedException => error,
    final failure => failure ?? error,
  };

  void _stop(Exception error) {
    if (_closed || _failure != null) return;
    _failure = error;
    _abort.complete();
  }

  /// Releases the shared deadline timer.
  void close() {
    _closed = true;
    _timer.cancel();
  }
}

/// Runs a sequence of streaming hops with one deadline and subscription.
Stream<T> continuationStream<T>({
  required String operation,
  required Duration timeout,
  required Stream<T> Function(ContinuationAbort) run,
  Future<void>? abortTrigger,
}) {
  late final StreamController<T> controller;
  StreamSubscription<T>? subscription;
  ContinuationAbort? active;
  controller = StreamController<T>(
    // A listener may abort as soon as a continuation boundary arrives.
    sync: true,
    onListen: () {
      final abort = ContinuationAbort(operation, timeout, abortTrigger);
      active = abort;
      subscription = run(abort).listen(
        controller.add,
        onError: controller.addError,
        onDone: () => unawaited(controller.close()),
      );
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () {
      // Release the current HTTP read before waiting for the async generator.
      active?.cancelSubscription();
      return subscription?.cancel();
    },
  );
  return controller.stream;
}
