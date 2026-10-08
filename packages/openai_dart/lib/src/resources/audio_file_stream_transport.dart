import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/request_builder.dart';
import '../errors/exceptions.dart';
import '../models/audio/transcription.dart';
import '../utils/streaming_parser.dart';

/// Lets an already completed signal win before file-audio authentication.
Future<void> checkAudioFileAbort(Future<void>? abortTrigger) async {
  if (abortTrigger == null) return;
  var aborted = false;
  unawaited(
    abortTrigger.then<void>(
      (_) => aborted = true,
      onError: (Object _, StackTrace _) => aborted = true,
    ),
  );
  await Future<void>.value();
  if (aborted) {
    throw const AbortedException(
      message: 'Audio file request aborted by user',
      stage: AbortionStage.beforeRequest,
    );
  }
}

/// Streams one prepared multipart request without retrying consumed output.
Stream<TranscriptionStreamEvent> openTranscriptionStream({
  required http.MultipartRequest preparedRequest,
  required http.Client httpClient,
  required http.Client Function()? streamClientFactory,
  required RequestBuilder requestBuilder,
  required Duration timeout,
  required ApiException Function(http.Response) parseError,
  required void Function()? ensureNotClosed,
  Future<void>? abortTrigger,
}) => _TranscriptionOperation(
  preparedRequest: preparedRequest,
  httpClient: httpClient,
  streamClientFactory: streamClientFactory,
  requestBuilder: requestBuilder,
  timeout: timeout,
  parseError: parseError,
  ensureNotClosed: ensureNotClosed,
  abortTrigger: abortTrigger,
).stream;

class _TranscriptionOperation {
  _TranscriptionOperation({
    required this.preparedRequest,
    required this.httpClient,
    required this.streamClientFactory,
    required this.requestBuilder,
    required this.timeout,
    required this.parseError,
    required this.ensureNotClosed,
    required this.abortTrigger,
  }) {
    _controller = StreamController<TranscriptionStreamEvent>(
      onListen: () => unawaited(_start()),
      onPause: () {
        _paused = true;
        _bodySubscription?.pause();
        _parserSubscription?.pause();
      },
      onResume: () {
        _paused = false;
        _parserSubscription?.resume();
        _bodySubscription?.resume();
      },
      onCancel: _cancel,
    );
  }

  final http.MultipartRequest preparedRequest;
  final http.Client httpClient;
  final http.Client Function()? streamClientFactory;
  final RequestBuilder requestBuilder;
  final Duration timeout;
  final ApiException Function(http.Response) parseError;
  final void Function()? ensureNotClosed;
  final Future<void>? abortTrigger;

  late final StreamController<TranscriptionStreamEvent> _controller;
  final _parserBytes = StreamController<List<int>>();
  final _receivedBytes = BytesBuilder();
  final _cancelSignal = Completer<void>();
  StreamSubscription<List<int>>? _bodySubscription;
  StreamSubscription<SseEvent>? _parserSubscription;
  Future<void>? _cleanupFuture;
  void Function()? _detachAbortListener;
  http.Client? _client;
  bool _ownsClient = false;
  bool _clientClosed = false;
  bool _cancelled = false;
  bool _settled = false;
  bool _sent = false;
  bool _paused = false;
  bool _completed = false;
  bool _parserClosing = false;
  bool _controllerClosing = false;

  Stream<TranscriptionStreamEvent> get stream => _controller.stream;

  Future<void> _start() async {
    if (abortTrigger case final trigger?) {
      // A caller can reuse a long-lived abort future. Do not let its pending
      // callbacks retain a completed operation and the snapshotted upload.
      void Function()? onAbort = _abort;
      _detachAbortListener = () => onAbort = null;
      unawaited(
        trigger.then<void>(
          (_) => onAbort?.call(),
          onError: (Object _, StackTrace _) => onAbort?.call(),
        ),
      );
    }
    await Future<void>.value();
    if (_settled || _cancelled) return;
    try {
      ensureNotClosed?.call();
      final request =
          http.AbortableMultipartRequest(
              preparedRequest.method,
              preparedRequest.url,
              abortTrigger: _cancelSignal.future,
            )
            ..fields.addAll(preparedRequest.fields)
            ..files.addAll(preparedRequest.files)
            ..headers.addAll(requestBuilder.buildMultipartHeaders())
            ..headers['Accept'] = 'text/event-stream';
      // MultipartRequest owns the boundary and always sets its Content-Type.
      _client = streamClientFactory?.call() ?? httpClient;
      _ownsClient =
          streamClientFactory != null && !identical(_client, httpClient);
      _sent = true;
      final pendingResponse = _client!.send(request);
      var discarded = false;
      Future<void> discard(http.StreamedResponse response) async {
        if (discarded) return;
        discarded = true;
        try {
          await _cancelSubscription(
            response.stream.listen((_) {}, onError: (Object _) {}),
          );
        } catch (_) {
          // A connector's late cleanup cannot escape the selected outcome.
        }
      }

      unawaited(
        pendingResponse.then<void>((response) {
          if (_settled || _cancelled) return discard(response);
        }, onError: (Object _, StackTrace _) {}),
      );
      final response =
          await Future.any([
            pendingResponse,
            _cancelSignal.future.then<http.StreamedResponse>(
              (_) => throw const AbortedException(
                message: 'Audio file stream was canceled',
                stage: AbortionStage.duringStream,
              ),
            ),
          ]).timeout(
            timeout,
            onTimeout: () => throw RequestTimeoutException(
              message: 'Audio file streaming request timed out',
              timeout: timeout,
            ),
          );
      if (_settled || _cancelled) {
        await discard(response);
        return;
      }

      final failed = response.statusCode < 200 || response.statusCode >= 300;
      if (!failed) {
        final contentType = response.headers['content-type']
            ?.split(';')
            .first
            .trim()
            .toLowerCase();
        if (contentType != null && contentType != 'text/event-stream') {
          await discard(response);
          throw const ParseException(
            message: 'Transcription streaming response requires SSE media',
          );
        }
        _parserSubscription = const SseParser()
            .parseRaw(_parserBytes.stream)
            .listen(
              _parseEvent,
              onError: (Object error, StackTrace stackTrace) {
                if (error is FormatException) {
                  _fail(
                    ParseException(
                      message: 'Invalid transcription SSE encoding',
                      responseBody: utf8.decode(
                        _receivedBytes.toBytes(),
                        allowMalformed: true,
                      ),
                      cause: const FormatException(
                        'Expected valid UTF-8 transcription SSE',
                      ),
                    ),
                    stackTrace,
                  );
                } else {
                  _fail(error, stackTrace);
                }
              },
              onDone: _finish,
            );
      }

      _bodySubscription = response.stream.listen(
        (bytes) {
          if (_settled || _cancelled) return;
          _receivedBytes.add(bytes);
          if (!failed) _parserBytes.add(List<int>.of(bytes));
        },
        onError: (Object error, StackTrace stackTrace) {
          if (error is http.RequestAbortedException) {
            _abort();
          } else {
            _fail(error, stackTrace);
          }
        },
        onDone: () {
          if (_settled || _cancelled) return;
          if (failed) {
            final errorResponse = http.Response.bytes(
              _receivedBytes.takeBytes(),
              response.statusCode,
              headers: response.headers,
              request: response.request ?? request,
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
            _closeParser();
          }
        },
      );
      if (_paused) {
        _bodySubscription?.pause();
        _parserSubscription?.pause();
      }
    } catch (error, stackTrace) {
      if (error is http.RequestAbortedException) {
        _abort();
      } else {
        _fail(error, stackTrace);
      }
    }
  }

  void _parseEvent(SseEvent raw) {
    if (_settled || _cancelled) return;
    try {
      if (raw.isDone) {
        _finish();
        return;
      }
      final Map<String, dynamic> json;
      try {
        final value = jsonDecode(raw.data);
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Expected an SSE JSON object');
        }
        json = value;
      } on FormatException {
        if (raw.event == 'error') {
          throw StreamException(
            message: 'Transcription stream reported an inline error',
            partialData: raw.data,
            redactDiagnostics: true,
          );
        }
        throw ParseException(
          message: 'Invalid transcription SSE JSON object',
          responseBody: raw.data,
          cause: const FormatException('Invalid transcription SSE JSON object'),
        );
      }
      if (raw.event == 'error' ||
          json['type'] == 'error' ||
          (!json.containsKey('type') && json['error'] != null)) {
        throw StreamException(
          message: _inlineTranscriptionMessage(json),
          partialData: raw.data,
          redactDiagnostics: true,
        );
      }
      final TranscriptionStreamEvent event;
      try {
        event = TranscriptionStreamEvent.fromJson(json);
      } on FormatException {
        throw ParseException(
          message: 'Invalid transcription SSE event payload',
          responseBody: raw.data,
          cause: const FormatException(
            'Invalid transcription SSE event payload',
          ),
        );
      } on TypeError {
        throw ParseException(
          message: 'Invalid transcription SSE event payload',
          responseBody: raw.data,
          cause: const FormatException(
            'Invalid transcription SSE event payload',
          ),
        );
      }
      if (event is TranscriptTextDoneEvent) _completed = true;
      _controller.add(event);
      if (_completed) _finish();
    } catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  void _signalCancellation() {
    if (!_cancelSignal.isCompleted) _cancelSignal.complete();
  }

  void _closeClient() {
    if (!_ownsClient || _clientClosed) return;
    _clientClosed = true;
    try {
      _client?.close();
    } catch (_) {
      // Cleanup cannot replace output or the original failure.
    }
  }

  void _detachAbort() {
    _detachAbortListener?.call();
    _detachAbortListener = null;
  }

  void _closeParser() {
    if (!_parserClosing) {
      _parserClosing = true;
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
    await _cancelSubscription(_bodySubscription);
    _closeParser();
    await _cancelSubscription(_parserSubscription);
    _receivedBytes.clear();
    _closeController();
  }

  void _abort() {
    if (_settled || _cancelled) return;
    _fail(
      AbortedException(
        message: 'Audio file request aborted by user',
        stage: _sent ? AbortionStage.duringStream : AbortionStage.beforeRequest,
      ),
      StackTrace.current,
    );
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_settled || _cancelled) return;
    _settled = true;
    _detachAbort();
    _signalCancellation();
    _closeClient();
    _controller.addError(error, stackTrace);
    _closeController();
    unawaited(_cleanup());
  }

  void _finish() {
    if (_settled || _cancelled) return;
    if (!_completed) {
      _fail(
        const StreamException(
          message: 'Transcription stream ended before transcript.text.done',
        ),
        StackTrace.current,
      );
      return;
    }
    _settled = true;
    _detachAbort();
    _signalCancellation();
    _closeClient();
    _closeController();
    unawaited(_cleanup());
  }

  Future<void> _cancel() async {
    _cancelled = true;
    _detachAbort();
    _signalCancellation();
    _closeClient();
    await _cleanup();
  }
}

String _inlineTranscriptionMessage(Map<String, dynamic> json) {
  final error = json['error'];
  if (error is Map<String, dynamic>) {
    final message = error['message'];
    if (message is String) return message;
    final nestedError = error['error'];
    if (nestedError is String) return nestedError;
  } else if (error is String) {
    return error;
  }
  final message = json['message'];
  if (message is String) return message;
  return 'Transcription stream reported an inline error';
}

Future<void> _cancelSubscription<T>(StreamSubscription<T>? subscription) async {
  try {
    await subscription?.cancel();
  } catch (_) {
    // Teardown-only errors cannot replace the already selected outcome.
  }
}
