import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/request_builder.dart';
import '../errors/exceptions.dart';
import '../models/audio/speech_stream_event.dart';
import '../platform/http_utils.dart';
import '../utils/streaming_parser.dart';

/// Checks a completed cancellation signal before authentication or dispatch.
///
/// Errors from the caller's signal also mean cancellation. No signal error is
/// retained in diagnostics because it may contain application data.
Future<void> checkSpeechAbort(Future<void>? abortTrigger) async {
  if (abortTrigger == null) return;
  var aborted = false;
  unawaited(
    abortTrigger.then<void>(
      (_) {
        aborted = true;
      },
      onError: (Object _, StackTrace _) {
        aborted = true;
      },
    ),
  );
  await Future<void>.value();
  if (aborted) {
    throw const AbortedException(
      message: 'Speech request aborted before dispatch',
      stage: AbortionStage.beforeRequest,
    );
  }
}

/// Opens one speech response without retries or shared-client ownership changes.
///
/// A supplied factory creates an owned client. Without a factory the supplied
/// HTTP client is borrowed. Cancellation also signals native abort support so a
/// borrowed client can cancel this request without being closed.
Stream<Uint8List> openSpeechByteStream({
  required http.Client httpClient,
  required http.Client Function()? streamClientFactory,
  required RequestBuilder requestBuilder,
  required Map<String, dynamic> body,
  required String accept,
  required Duration timeout,
  required ApiException Function(http.Response response) parseError,
  void Function()? ensureNotClosed,
  Future<void>? abortTrigger,
}) => _PrivateByteOperation(
  httpClient: httpClient,
  streamClientFactory: streamClientFactory,
  requestBuilder: requestBuilder,
  method: 'POST',
  endpoint: '/audio/speech',
  context: 'Speech',
  body: body,
  accept: accept,
  timeout: timeout,
  parseError: parseError,
  ensureNotClosed: ensureNotClosed,
  abortTrigger: abortTrigger,
  timeoutResponseBody: false,
  redactTransportErrors: false,
).stream;

/// Opens a private binary HTTP response with cancellation and bounded waits.
///
/// A factory client is owned by this operation; an injected client is borrowed.
/// No request is replayed. [validateResponse] checks successful response headers
/// before any bytes are delivered. Non-success bodies use [parseError] instead.
Stream<Uint8List> openPrivateByteStream({
  required http.Client httpClient,
  required http.Client Function()? streamClientFactory,
  required RequestBuilder requestBuilder,
  required String method,
  required String endpoint,
  Map<String, dynamic>? body,
  Map<String, String>? additionalHeaders,
  String? betaFeature,
  required String accept,
  required Duration timeout,
  required String context,
  required ApiException Function(http.Response response) parseError,
  void Function(http.StreamedResponse response)? validateResponse,
  void Function()? ensureNotClosed,
  Future<void>? abortTrigger,
  bool timeoutResponseBody = true,
  bool sanitizeConnectorErrors = false,
}) => _PrivateByteOperation(
  httpClient: httpClient,
  streamClientFactory: streamClientFactory,
  requestBuilder: requestBuilder,
  method: method,
  endpoint: endpoint,
  context: context,
  body: body,
  additionalHeaders: additionalHeaders,
  betaFeature: betaFeature,
  accept: accept,
  timeout: timeout,
  parseError: parseError,
  validateResponse: validateResponse,
  ensureNotClosed: ensureNotClosed,
  abortTrigger: abortTrigger,
  timeoutResponseBody: timeoutResponseBody,
  redactTransportErrors: true,
  sanitizeConnectorErrors: sanitizeConnectorErrors,
).stream;

/// Decodes speech SSE while forwarding cancellation before the first byte.
///
/// An async generator cannot interrupt its pending first input read reliably.
/// Keeping the raw subscription explicit lets a canceled SSE subscription
/// release its owned transport even while response headers are still pending.
Stream<SpeechStreamEvent> decodeSpeechEvents(Stream<Uint8List> bytes) =>
    _SpeechEventOperation(bytes).stream;

class _SpeechEventOperation {
  _SpeechEventOperation(this.bytes) {
    _controller = StreamController<SpeechStreamEvent>(
      onListen: _start,
      onPause: () {
        _byteSubscription?.pause();
        _parserSubscription?.pause();
      },
      onResume: () {
        _parserSubscription?.resume();
        _byteSubscription?.resume();
      },
      onCancel: () {
        _cancelled = true;
        return _cleanup();
      },
    );
  }

  final Stream<Uint8List> bytes;
  late final StreamController<SpeechStreamEvent> _controller;
  final _parserBytes = StreamController<List<int>>();
  StreamSubscription<Uint8List>? _byteSubscription;
  StreamSubscription<SseEvent>? _parserSubscription;
  Future<void>? _cleanupFuture;
  bool _cancelled = false;
  bool _settled = false;
  bool _completed = false;
  bool _parserBytesClosing = false;
  bool _controllerClosing = false;

  Stream<SpeechStreamEvent> get stream => _controller.stream;

  void _start() {
    _parserSubscription = const SseParser()
        .parseRaw(_parserBytes.stream)
        .listen(
          _parseEvent,
          onError: (Object error, StackTrace stackTrace) {
            if (error is FormatException) {
              _fail(
                const ParseException(
                  message: 'Invalid speech SSE encoding',
                  cause: FormatException('Expected valid UTF-8 speech SSE'),
                ),
                stackTrace,
              );
            } else {
              _fail(error, stackTrace);
            }
          },
          onDone: _finish,
        );
    _byteSubscription = bytes.listen(
      (chunk) {
        if (!_settled && !_cancelled) _parserBytes.add(chunk);
      },
      onError: _fail,
      onDone: _closeParserBytes,
    );
  }

  void _parseEvent(SseEvent raw) {
    if (_settled || _cancelled) return;
    try {
      if (raw.isDone) {
        _finish();
        return;
      }
      if (raw.event == 'error') {
        throw StreamException(
          message: 'Speech stream reported an inline error',
          partialData: raw.data,
        );
      }

      final Map<String, dynamic> json;
      try {
        final value = jsonDecode(raw.data);
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Expected an SSE JSON object');
        }
        json = value;
      } on FormatException {
        throw ParseException(
          message: 'Invalid speech SSE JSON object',
          responseBody: raw.data,
          cause: const FormatException('Invalid speech SSE JSON object'),
        );
      }

      if (json['type'] == 'error' ||
          (!json.containsKey('type') && json['error'] != null)) {
        throw StreamException(
          message: 'Speech stream reported an inline error',
          partialData: raw.data,
        );
      }

      final SpeechStreamEvent event;
      try {
        event = SpeechStreamEvent.fromJson(json);
      } on FormatException {
        throw ParseException(
          message: 'Invalid speech SSE event payload',
          responseBody: raw.data,
          cause: const FormatException('Invalid speech SSE event payload'),
        );
      }
      if (event is SpeechAudioDoneEvent) _completed = true;
      _controller.add(event);
      // Synthesis is complete at the validated done event. Do not retain an
      // owned transport waiting for HTTP EOF or consume post-terminal bytes.
      if (_completed) _finish();
    } catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  void _closeParserBytes() {
    if (!_parserBytesClosing) {
      _parserBytesClosing = true;
      unawaited(_parserBytes.close());
    }
  }

  void _closeController() {
    if (!_controllerClosing) {
      _controllerClosing = true;
      unawaited(_controller.close());
    }
  }

  Future<void> _cleanup() => _cleanupFuture ??= _cleanupSubscriptions();

  Future<void> _cleanupSubscriptions() async {
    // Release the request first; parser cancellation may be awaiting input.
    await _cancelSpeechSubscription(_byteSubscription);
    _closeParserBytes();
    await _cancelSpeechSubscription(_parserSubscription);
    _closeController();
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_settled || _cancelled) return;
    _settled = true;
    _controller.addError(error, stackTrace);
    _closeController();
    unawaited(_cleanup());
  }

  void _finish() {
    if (_settled || _cancelled) return;
    if (!_completed) {
      _fail(
        const StreamException(
          message: 'Speech stream ended before speech.audio.done',
        ),
        StackTrace.current,
      );
      return;
    }
    _settled = true;
    _closeController();
    unawaited(_cleanup());
  }
}

class _PrivateByteOperation {
  _PrivateByteOperation({
    required this.httpClient,
    required this.streamClientFactory,
    required this.requestBuilder,
    required this.method,
    required this.endpoint,
    required this.context,
    required this.body,
    required this.accept,
    required this.timeout,
    required this.parseError,
    required this.ensureNotClosed,
    required this.abortTrigger,
    required this.timeoutResponseBody,
    required this.redactTransportErrors,
    this.validateResponse,
    this.sanitizeConnectorErrors = false,
    Map<String, String>? additionalHeaders,
    this.betaFeature,
  }) : additionalHeaders = additionalHeaders == null
           ? null
           : Map<String, String>.unmodifiable(additionalHeaders) {
    _controller = StreamController<Uint8List>(
      onListen: () => unawaited(_start()),
      onPause: () {
        _paused = true;
        if (!_failedResponse) _bodyTimer?.cancel();
        _subscription?.pause();
      },
      onResume: () {
        _paused = false;
        _subscription?.resume();
        _armBodyTimeout();
      },
      onCancel: _cancel,
    );
  }

  final http.Client httpClient;
  final http.Client Function()? streamClientFactory;
  final RequestBuilder requestBuilder;
  final String method;
  final String endpoint;
  final String context;
  final Map<String, dynamic>? body;
  final Map<String, String>? additionalHeaders;
  final String? betaFeature;
  final String accept;
  final Duration timeout;
  final ApiException Function(http.Response response) parseError;
  final void Function()? ensureNotClosed;
  final Future<void>? abortTrigger;
  final bool timeoutResponseBody;
  final bool redactTransportErrors;
  final bool sanitizeConnectorErrors;
  final void Function(http.StreamedResponse response)? validateResponse;

  late final StreamController<Uint8List> _controller;
  final _cancelSignal = Completer<void>();
  StreamSubscription<List<int>>? _subscription;
  Timer? _bodyTimer;
  http.Client? _client;
  http.BaseRequest? _request;
  bool _ownsClient = false;
  bool _clientClosed = false;
  bool _paused = false;
  bool _cancelled = false;
  bool _settled = false;
  bool _sent = false;
  bool _controllerClosing = false;
  bool _failedResponse = false;

  Stream<Uint8List> get stream => _controller.stream;

  Future<void> _start() async {
    if (abortTrigger case final trigger?) {
      unawaited(
        trigger.then<void>(
          (_) => _abort(),
          onError: (Object _, StackTrace _) => _abort(),
        ),
      );
    }

    // Let an already-completed abort signal win before headers/auth/factory.
    await Future<void>.value();
    if (_settled || _cancelled) return;

    try {
      ensureNotClosed?.call();
      final request = _external(
        () =>
            http.AbortableRequest(
                method,
                requestBuilder.buildUrl(endpoint),
                abortTrigger: _cancelSignal.future,
              )
              ..headers.addAll(
                requestBuilder.buildHeaders(
                  additionalHeaders: {
                    ...?additionalHeaders,
                    'Accept': accept,
                    'Content-Type': 'application/json',
                  },
                ),
              )
              ..headers['Accept'] = accept
              ..headers['Content-Type'] = 'application/json',
      );
      if (betaFeature != null) request.headers['openai-beta'] = betaFeature!;
      if (body != null) {
        request
          ..headers['content-type'] = 'application/json; charset=utf-8'
          ..encoding = utf8
          ..bodyBytes = utf8.encode(jsonEncode(body));
      }
      if (body == null) request.headers.remove('content-type');
      _request = request;

      _client = _external(() => streamClientFactory?.call() ?? httpClient);
      _ownsClient =
          streamClientFactory != null && !identical(_client, httpClient);
      _sent = true;
      final pendingResponse = _sendRequest(request);
      var discardedResponse = false;

      Future<void> discardResponse(http.StreamedResponse response) async {
        if (discardedResponse) return;
        discardedResponse = true;
        try {
          await response.stream.listen((_) {}, onError: (Object _) {}).cancel();
        } catch (_) {
          // A late connector cleanup failure cannot replace this request's
          // existing outcome or create an unhandled asynchronous exception.
        }
      }

      // A custom client may ignore both close() and native abortion. Stop the
      // header deadline immediately on cancellation, and release any response
      // body that such a client eventually returns after this operation ended.
      unawaited(
        pendingResponse.then<void>((response) {
          if (_settled || _cancelled) {
            return discardResponse(response);
          }
        }, onError: (Object _, StackTrace _) {}),
      );
      final response =
          await Future.any([
            pendingResponse,
            _cancelSignal.future.then<http.StreamedResponse>(
              (_) => throw AbortedException(
                message: '$context streaming request was canceled',
                stage: AbortionStage.duringStream,
                redactDiagnostics: redactTransportErrors,
              ),
            ),
          ]).timeout(
            timeout,
            onTimeout: () => throw RequestTimeoutException(
              message: '$context streaming request timed out',
              timeout: timeout,
            ),
          );

      if (_settled || _cancelled) {
        await discardResponse(response);
        return;
      }

      final failed = response.statusCode < 200 || response.statusCode >= 300;
      _failedResponse = failed;
      if (!failed) {
        if (validateResponse != null) {
          try {
            validateResponse!(response);
          } catch (_) {
            await discardResponse(response);
            rethrow;
          }
        }
        final contentType = response.headers['content-type']
            ?.split(';')
            .first
            .trim()
            .toLowerCase();
        if (contentType != null &&
            ((accept == 'text/event-stream' &&
                    contentType != 'text/event-stream') ||
                (accept != 'text/event-stream' &&
                    contentType == 'text/event-stream'))) {
          await discardResponse(response);
          throw ParseException(
            message:
                '$context response media type does not match the selected mode',
          );
        }
      }

      final errorBytes = BytesBuilder();
      _subscription = _external(
        () => response.stream.listen(
          (bytes) {
            if (_settled || _cancelled) return;
            _armBodyTimeout();
            if (failed) {
              errorBytes.add(bytes);
            } else {
              _controller.add(Uint8List.fromList(bytes));
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (error is http.RequestAbortedException) {
              _abort(cause: error);
            } else {
              _fail(_connectorError(error), stackTrace);
            }
          },
          onDone: () {
            if (_settled || _cancelled) return;
            if (failed) {
              final errorResponse = http.Response.bytes(
                errorBytes.takeBytes(),
                response.statusCode,
                headers: response.headers,
                request: sanitizeConnectorErrors
                    ? request
                    : response.request ?? request,
                isRedirect: response.isRedirect,
                persistentConnection: response.persistentConnection,
                reasonPhrase: response.reasonPhrase,
              );
              try {
                _fail(parseError(errorResponse), StackTrace.current);
              } catch (error, stackTrace) {
                _fail(error, stackTrace);
              }
            } else {
              _finish();
            }
          },
        ),
      );
      if (_paused) _subscription?.pause();
      _armBodyTimeout();
    } catch (error, stackTrace) {
      if (error is http.RequestAbortedException) {
        _abort(cause: error);
      } else {
        _fail(error, stackTrace);
      }
    }
  }

  // Caller-supplied provider/factory/connector exceptions may themselves be SDK
  // exceptions with unredacted private messages. Sanitize at their origin so
  // local HTTP, parse, timeout and abort errors keep their established classes.
  Object _connectorError(Object error) =>
      !sanitizeConnectorErrors || error is http.RequestAbortedException
      ? error
      : ConnectionException(
          message: '$context transport failed',
          cause: error,
          redactDiagnostics: true,
        );

  T _external<T>(T Function() callback) {
    try {
      return callback();
    } catch (error) {
      if (sanitizeConnectorErrors && error is! http.RequestAbortedException) {
        throw ConnectionException(
          message: '$context transport failed',
          cause: error,
          redactDiagnostics: true,
        );
      }
      rethrow;
    }
  }

  Future<http.StreamedResponse> _sendRequest(http.BaseRequest request) async {
    try {
      return await _client!.send(request);
    } catch (error) {
      if (sanitizeConnectorErrors && error is! http.RequestAbortedException) {
        throw ConnectionException(
          message: '$context transport failed',
          cause: error,
          redactDiagnostics: true,
        );
      }
      rethrow;
    }
  }

  void _signalCancellation() {
    if (!_cancelSignal.isCompleted) _cancelSignal.complete();
  }

  void _armBodyTimeout() {
    if (_settled || _cancelled) return;
    // Persistent successful observation may remain idle indefinitely. Failed
    // responses have a total read deadline, even if paused or trickling bytes.
    if (_failedResponse) {
      _bodyTimer ??= Timer(timeout, () {
        _fail(
          RequestTimeoutException(
            message: '$context error response timed out',
            timeout: timeout,
          ),
          StackTrace.current,
        );
      });
      return;
    }
    _bodyTimer?.cancel();
    if (!timeoutResponseBody ||
        _subscription == null ||
        _paused ||
        _settled ||
        _cancelled) {
      return;
    }
    _bodyTimer = Timer(timeout, () {
      _fail(
        RequestTimeoutException(
          message: '$context streaming response timed out',
          timeout: timeout,
        ),
        StackTrace.current,
      );
    });
  }

  void _closeClient() {
    if (_ownsClient && !_clientClosed) {
      _clientClosed = true;
      try {
        _client?.close();
      } catch (_) {
        // Disposal is best effort: preserve successful output or the original
        // HTTP/parser/abort error without exposing connector diagnostics.
      }
    }
  }

  void _closeController() {
    if (!_controllerClosing) {
      _controllerClosing = true;
      unawaited(_controller.close());
    }
  }

  void _abort({Object? cause}) {
    if (_settled || _cancelled) return;
    _fail(
      AbortedException(
        message: '$context request aborted by user',
        stage: _sent ? AbortionStage.duringStream : AbortionStage.beforeRequest,
        correlationId: redactTransportErrors
            ? _request?.headers['x-request-id']
            : null,
        cause: redactTransportErrors ? cause : null,
        redactDiagnostics: redactTransportErrors,
      ),
      StackTrace.current,
    );
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_settled || _cancelled) return;
    _settled = true;
    _bodyTimer?.cancel();
    _signalCancellation();
    _closeClient();
    final Object diagnosticError;
    if (redactTransportErrors && error is http.ClientException) {
      diagnosticError = ConnectionException(
        message: error.message,
        url: error.uri?.toString() ?? _request?.url.toString(),
        cause: error,
        redactDiagnostics: true,
      );
    } else if (redactTransportErrors && isSocketException(error)) {
      diagnosticError = ConnectionException(
        message: '$context connection failed',
        url: _request?.url.toString(),
        cause: error,
        redactDiagnostics: true,
      );
    } else {
      diagnosticError = error;
    }
    _controller.addError(diagnosticError, stackTrace);
    if (_subscription case final subscription?) {
      unawaited(_cancelSpeechSubscription(subscription));
    }
    _closeController();
  }

  void _finish() {
    if (_settled || _cancelled) return;
    _settled = true;
    _bodyTimer?.cancel();
    _closeClient();
    _closeController();
  }

  Future<void> _cancel() async {
    _cancelled = true;
    _bodyTimer?.cancel();
    _signalCancellation();
    _closeClient();
    await _cancelSpeechSubscription(_subscription);
    _closeController();
  }
}

Future<void> _cancelSpeechSubscription<T>(
  StreamSubscription<T>? subscription,
) async {
  try {
    await subscription?.cancel();
  } catch (_) {
    // Teardown-only failures never mask the already selected request outcome.
  }
}
