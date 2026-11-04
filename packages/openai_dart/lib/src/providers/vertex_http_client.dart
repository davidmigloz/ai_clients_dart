import 'dart:async';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../errors/exceptions.dart';
import 'vertex_provider.dart';

const _conflictingHeaders = {
  'authorization',
  'api-key',
  'x-api-key',
  'openai-api-key',
  'openai-organization',
  'openai-project',
};

/// Validates provider-owned settings before a configuration is installed.
void validateVertexConfig(OpenAIConfig config) {
  final provider = config.vertexProvider;
  if (provider == null) return;
  if (config.baseUrl != provider.baseUrl) {
    throw ArgumentError('Vertex owns baseUrl; use its configured API root.');
  }
  if (config.authProvider != null ||
      config.organization != null ||
      config.project != null ||
      config.defaultHeaders.keys.any(
        (key) => _conflictingHeaders.contains(key.toLowerCase()),
      )) {
    throw ArgumentError(
      'Vertex owns authentication; remove OpenAI credentials, organization, '
      'project and custom Authorization or api-key headers.',
    );
  }
  if (config.timeout <= Duration.zero) {
    throw ArgumentError('Vertex request timeout must be positive.');
  }
}

/// Generation-local auth adapter around a borrowed or dedicated transport.
///
/// Auth happens at send, below retries and on the SSE path. Credentials never
/// mutate the resource request or a client-wide bearer field. Each attempt owns
/// its timeout/abort gate, so abandoned token futures cannot dispatch later.
final class VertexHttpClient extends http.BaseClient {
  /// Creates one generation or request-scoped transport adapter.
  VertexHttpClient({
    required this.inner,
    required this.provider,
    required this.timeout,
    required this.ensureNotClosed,
    this.ownsInner = false,
    this.onClose,
  });

  /// Underlying caller pool or dedicated per-stream transport.
  final http.Client inner;

  /// Captured immutable provider definition.
  final VertexProvider provider;

  /// Budget for authentication and response headers.
  final Duration timeout;

  /// Lifetime-only guard shared with the owning OpenAI client.
  final void Function() ensureNotClosed;

  /// Whether closing this adapter closes its dedicated transport.
  final bool ownsInner;

  /// Removes a closed request-scoped adapter from its owner registry.
  final void Function()? onClose;
  final Set<void Function()> _pendingAborts = {};
  bool _closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    ensureNotClosed();
    if (_closed) throw StateError('Vertex transport has been closed.');
    _validateRequest(request);

    final nativeAbort = Completer<void>();
    final outcome = Completer<http.StreamedResponse>();
    final elapsed = Stopwatch()..start();
    var abandoned = false;
    var dispatched = false;
    var handedOff = false;
    Timer? timer;
    _VertexRequest? outgoing;

    void cancelNative() {
      if (!nativeAbort.isCompleted) nativeAbort.complete();
    }

    void fail(Object error) {
      abandoned = true;
      cancelNative();
      if (!outcome.isCompleted) {
        outcome.completeError(error, StackTrace.current);
      }
    }

    void abort() =>
        fail(const AbortedException(stage: AbortionStage.duringRequest));
    _pendingAborts.add(abort);
    if (request is http.Abortable) {
      unawaited(
        request.abortTrigger?.then((_) => abort(), onError: (_) => abort()),
      );
    }
    timer = Timer(
      timeout,
      () => fail(
        RequestTimeoutException(
          message: 'Vertex authentication/request headers timed out.',
          timeout: timeout,
        ),
      ),
    );

    try {
      // Snapshot/finalize before awaiting credentials. Later mutation of the
      // caller's request cannot change the origin, headers or body being sent.
      final prepared = _VertexRequest(request, nativeAbort.future);
      outgoing = prepared;
      _validateRequest(prepared);
      // An already completed abort trigger wins before invoking user code.
      await Future<void>.value();
      if (!abandoned) {
        unawaited(() async {
          try {
            final token = await provider.tokenProvider();
            // Abortable exposes a Future, rather than a synchronously readable
            // signal. Drain queued cancellation propagation (including the SSE
            // adapter's linked abort futures) before committing a dispatch.
            await Future<void>.delayed(Duration.zero);
            // A synchronous callback may have blocked the event loop, preventing
            // Timer from firing. Enforce the actual elapsed budget as well.
            if (elapsed.elapsed >= timeout) {
              fail(
                RequestTimeoutException(
                  message: 'Vertex authentication/request headers timed out.',
                  timeout: timeout,
                ),
              );
            }
            if (abandoned) return;
            ensureNotClosed();
            if (_closed) throw StateError('Vertex transport has been closed.');
            if (token.isEmpty ||
                token.codeUnits.any((unit) => unit < 33 || unit > 126)) {
              throw const VertexAuthenticationException();
            }
            prepared.headers['Authorization'] = 'Bearer $token';
            prepared.followRedirects = false;
            dispatched = true;
            final response = await inner.send(prepared);
            if (abandoned) {
              await response.stream.listen(null).cancel();
              return;
            }
            timer?.cancel();
            handedOff = true;
            outcome.complete(
              http.StreamedResponse(
                _safeBody(
                  response.stream,
                  nativeAbort.future,
                  () => _pendingAborts.remove(abort),
                ),
                response.statusCode,
                contentLength: response.contentLength,
                request: response.request ?? prepared,
                headers: response.headers,
                isRedirect: response.isRedirect,
                persistentConnection: response.persistentConnection,
                reasonPhrase: response.reasonPhrase,
              ),
            );
          } catch (error) {
            if (abandoned) return;
            if (error is VertexAuthenticationException) {
              fail(error);
            } else if (!dispatched) {
              // Credential callbacks can include secrets in arbitrary errors.
              // Preserve only the package's own lifetime failure after closure.
              try {
                ensureNotClosed();
              } on StateError {
                fail(StateError('Client has been closed'));
                return;
              }
              fail(const VertexAuthenticationException());
            } else if (error is http.RequestAbortedException ||
                error is AbortedException) {
              abort();
            } else {
              // Keep transport failures retryable without retaining credentials
              // that an injected transport could include in its exception.
              fail(http.ClientException('Vertex HTTP transport failed.'));
            }
          }
        }());
      }
      return await outcome.future;
    } finally {
      timer.cancel();
      elapsed.stop();
      if (!handedOff) _pendingAborts.remove(abort);
      if (!handedOff) {
        // The body was finalized locally but will never reach a transport.
        outgoing?.discardBody();
      }
    }
  }

  void _validateRequest(http.BaseRequest request) {
    final url = request.url;
    final root = provider.root;
    if (url.scheme != root.scheme ||
        url.host != root.host ||
        url.port != root.port ||
        url.userInfo.isNotEmpty ||
        url.hasFragment) {
      throw ArgumentError(
        'Vertex refuses requests outside its configured origin.',
      );
    }
    if (request.headers.keys.any(
      (key) => _conflictingHeaders.contains(key.toLowerCase()),
    )) {
      throw ArgumentError(
        'Vertex owns authentication; remove OpenAI and custom auth headers.',
      );
    }
    final prefix = '${root.path}/';
    if (!url.path.startsWith(prefix)) {
      throw UnsupportedError(
        'Vertex supports only its configured Responses API root.',
      );
    }
    final segments = url.pathSegments.skip(root.pathSegments.length).toList();
    final validSegments = segments.every(
      (part) =>
          part.isNotEmpty &&
          part != '.' &&
          part != '..' &&
          !part.contains('/') &&
          !part.contains(r'\'),
    );
    final method = request.method;
    final supported =
        segments.isNotEmpty &&
        validSegments &&
        segments.first == 'responses' &&
        ((segments.length == 1 && method == 'POST') ||
            (segments.length == 2 &&
                segments[1] == 'compact' &&
                method == 'POST') ||
            (segments.length == 2 && (method == 'GET' || method == 'DELETE')) ||
            (segments.length == 3 &&
                ((segments[2] == 'cancel' && method == 'POST') ||
                    (segments[2] == 'input_items' && method == 'GET'))));
    if (!supported) {
      throw UnsupportedError(
        'Vertex supports only the documented Responses HTTP/SSE lifecycle.',
      );
    }
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    for (final abort in List<void Function()>.of(_pendingAborts)) {
      abort();
    }
    try {
      if (ownsInner) inner.close();
    } catch (_) {
      // Dedicated cleanup is best effort. A credential-bearing custom close
      // error must not mask cancellation or prevent other adapters closing.
    } finally {
      onClose?.call();
    }
  }
}

Stream<List<int>> _safeBody(
  Stream<List<int>> body,
  Future<void> abortTrigger,
  void Function() onFinish,
) {
  StreamSubscription<List<int>>? subscription;
  late StreamController<List<int>> controller;
  var ended = false;
  var sourceStarted = false;

  void cancelUpstream() {
    try {
      // Cancellation can arrive before the returned body is first listened to.
      // Subscribe only to release that source, without waiting for another byte.
      if (!sourceStarted) {
        sourceStarted = true;
        subscription = body.listen(null, onError: (Object _) {});
      }
      subscription?.cancel().ignore();
    } catch (_) {
      // A custom subscription may throw synchronously or never finish cancel.
      // Neither may replace the locally completed, sanitized result.
    }
  }

  void finish([Object? error, StackTrace? stackTrace]) {
    if (ended) return;
    ended = true;
    onFinish();
    if (error != null) {
      controller.addError(
        error is http.RequestAbortedException || error is AbortedException
            ? const AbortedException(stage: AbortionStage.duringStream)
            : http.ClientException('Vertex response stream failed.'),
        StackTrace.current,
      );
    }
    cancelUpstream();
    unawaited(controller.close());
  }

  controller = StreamController<List<int>>(
    onListen: () {
      if (ended) return;
      sourceStarted = true;
      try {
        subscription = body.listen(
          controller.add,
          onError: finish,
          onDone: finish,
        );
        if (ended) cancelUpstream();
      } catch (error) {
        finish(error);
      }
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () {
      if (!ended) {
        ended = true;
        onFinish();
      }
      cancelUpstream();
    },
  );
  unawaited(
    abortTrigger.then(
      (_) => finish(const AbortedException(stage: AbortionStage.duringStream)),
      onError: (Object _) =>
          finish(const AbortedException(stage: AbortionStage.duringStream)),
    ),
  );
  return controller.stream;
}

final class _VertexRequest extends http.BaseRequest implements http.Abortable {
  _VertexRequest(http.BaseRequest original, this.abortTrigger)
    : _body = original.finalize(),
      super(original.method, original.url) {
    headers.addAll(original.headers);
    contentLength = original.contentLength;
    followRedirects = false;
    maxRedirects = 0;
    persistentConnection = original.persistentConnection;
  }

  final http.ByteStream _body;
  bool _consumed = false;

  @override
  final Future<void> abortTrigger;

  @override
  http.ByteStream finalize() {
    super.finalize();
    _consumed = true;
    return _body;
  }

  void discardBody() {
    if (_consumed) return;
    _consumed = true;
    _body.listen(null).cancel().ignore();
  }
}
