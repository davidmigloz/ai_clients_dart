import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';

/// Sends one buffered attempt, with a deadline covering headers and body.
///
/// Cancellation signals the transport and independently releases the response
/// subscription. An injected transport may ignore the signal, so its late
/// response is discarded without closing the client.
Future<http.Response> sendBufferedHttpAttempt({
  required Future<http.StreamedResponse> Function(Future<void>) send,
  required Duration? timeout,
  required Future<void>? abortTrigger,
  required String correlationId,
  http.Abortable? nativeRequest,
}) => _BufferedAttempt(
  timeout,
  abortTrigger,
  correlationId,
).run(send, nativeRequest);

class _BufferedAttempt {
  _BufferedAttempt(this.timeout, this.abortTrigger, this.correlationId);

  final Duration? timeout;
  final Future<void>? abortTrigger;
  final String correlationId;
  final _result = Completer<http.Response>();
  final _transportAbort = Completer<void>();
  final _watch = Stopwatch();
  StreamSubscription<List<int>>? _body;
  bool _receivedHeaders = false;

  Future<http.Response> run(
    Future<http.StreamedResponse> Function(Future<void>) send,
    http.Abortable? nativeRequest,
  ) async {
    final userAbort = abortTrigger?.asStream().listen(
      (_) => _cancel(_userAbortError()),
      onError: (Object _, StackTrace _) {},
    );
    final nativeAbort = nativeRequest?.abortTrigger?.asStream().listen(
      (_) => _cancel(http.RequestAbortedException(nativeRequest.url)),
      onError: (Object _, StackTrace _) {},
    );
    _watch.start();
    final timer = switch (timeout) {
      final duration? => Timer(
        duration,
        () => _cancel(
          TimeoutException(
            message: 'The HTTP attempt exceeded its configured timeout',
            timeout: duration,
            elapsed: _watch.elapsed,
          ),
        ),
      ),
      null => null,
    };
    unawaited(_send(send));
    try {
      return await _result.future;
    } finally {
      timer?.cancel();
      _watch.stop();
      _body = null;
      unawaited(userAbort?.cancel());
      unawaited(nativeAbort?.cancel());
    }
  }

  Future<void> _send(
    Future<http.StreamedResponse> Function(Future<void>) send,
  ) async {
    try {
      final response = await send(_transportAbort.future);
      if (_result.isCompleted) {
        unawaited(_discard(response.stream));
        return;
      }
      _receivedHeaders = true;
      final bytes = BytesBuilder(copy: false);
      final subscription = response.stream.listen(
        bytes.add,
        onError: _fail,
        onDone: () {
          if (_result.isCompleted) return;
          _result.complete(
            http.Response.bytes(
              bytes.takeBytes(),
              response.statusCode,
              request: response.request,
              headers: response.headers,
              isRedirect: response.isRedirect,
              persistentConnection: response.persistentConnection,
              reasonPhrase: response.reasonPhrase,
            ),
          );
        },
        cancelOnError: true,
      );
      // An injected synchronous stream can trigger cancellation in onListen.
      if (_result.isCompleted) {
        await subscription.cancel();
      } else {
        _body = subscription;
      }
    } catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_result.isCompleted) return;
    final failure = switch (error) {
      http.RequestAbortedException() when abortTrigger != null =>
        _userAbortError(reason: error),
      _ => error,
    };
    _result.completeError(failure, stackTrace);
  }

  void _cancel(Object error) {
    if (_result.isCompleted) return;
    _result.completeError(error);
    _transportAbort.complete();
    _cancelBody();
  }

  AbortedException _userAbortError({http.RequestAbortedException? reason}) =>
      AbortedException(
        message: 'Request aborted by user',
        correlationId: correlationId,
        timestamp: DateTime.now(),
        stage: _receivedHeaders
            ? AbortionStage.duringResponse
            : AbortionStage.beforeRequest,
        reason: reason,
      );

  void _cancelBody() {
    final subscription = _body;
    _body = null;
    if (subscription != null) unawaited(_cancelSubscription(subscription));
  }
}

Future<void> _discard(Stream<List<int>> stream) async {
  try {
    await stream.listen(null, onError: (Object _, StackTrace _) {}).cancel();
  } on Object {
    // An already terminated transport must not replace the timeout or abort.
  }
}

Future<void> _cancelSubscription(StreamSubscription<List<int>> body) async {
  try {
    await body.cancel();
  } on Object {
    // Cleanup must not replace the timeout or abort.
  }
}
