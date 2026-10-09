import 'dart:async';

import 'package:web_socket/web_socket.dart';

import '../../client/config.dart';
import '../../client/request_builder.dart';
import '../../errors/exceptions.dart';
import '../../utils/private_audio_http.dart';
import 'live_connection.dart';

/// Opens one Live connection without retries, startup or replay.
Future<LiveConnection> openLiveConnection({
  required OpenAIConfig config,
  required RequestBuilder requestBuilder,
  required bool sideband,
  bool fork = false,
  required String endpoint,
  bool? gracefulClose,
  LiveWebSocketConnector? connector,
  Map<String, String>? additionalHeaders,
  Duration? connectionTimeout,
  int maxBufferedEvents = 1024,
  Future<void>? abortTrigger,
  void Function()? ensureNotClosed,
}) async {
  ensureNotClosed?.call();
  if (sideband && fork) throw ArgumentError('A fork is not a sideband.');
  final timeout = connectionTimeout ?? config.connectTimeout;
  if (!timeout.inMicroseconds.isFinite || timeout <= Duration.zero) {
    throw ArgumentError('connectionTimeout must be positive.');
  }
  if (!maxBufferedEvents.isFinite || maxBufferedEvents < 1) {
    throw ArgumentError('maxBufferedEvents must be positive.');
  }
  final overrides = additionalHeaders == null
      ? null
      : Map<String, String>.unmodifiable(additionalHeaders);
  final Uri url;
  try {
    final uri = requestBuilder.buildUrl(
      endpoint,
      queryParams: {
        if (gracefulClose != null) 'graceful_close': gracefulClose.toString(),
      },
    );
    final scheme = switch (uri.scheme) {
      'https' || 'wss' => 'wss',
      'http' || 'ws' => 'ws',
      _ => throw const FormatException(),
    };
    if (uri.host.isEmpty || uri.hasFragment) throw const FormatException();
    url = uri.replace(scheme: scheme);
  } on FormatException {
    throw ArgumentError(
      'Live baseUrl must be an absolute http, https, ws or wss URL with a host and no fragment.',
    );
  }
  await checkPrivateAudioAbort(abortTrigger, 'Live connection');
  ensureNotClosed?.call();
  // The browser default cannot carry provider authentication or any other
  // handshake headers. Reject configured headers before asking for credentials.
  if (connector == null && isLiveBrowserWebSocket) {
    final names = <String>{
      ...config.defaultHeaders.keys,
      if (config.authProvider != null) 'auth-provider',
      if (config.organization != null) 'openai-organization',
      if (config.project != null) 'openai-project',
      if (config.apiVersion != null) 'openai-version',
      ...?overrides?.keys,
    };
    if (names.isNotEmpty) throw LiveBrowserHeadersException(names);
  }
  final headers = <String, String>{};
  void merge(Map<String, String> values) {
    for (final entry in values.entries) {
      headers[entry.key.toLowerCase()] = entry.value;
    }
  }

  merge(config.defaultHeaders);
  if (config.authProvider case final provider?) merge(provider.getHeaders());
  merge({
    'OpenAI-Organization': ?config.organization,
    'OpenAI-Project': ?config.project,
    'OpenAI-Version': ?config.apiVersion,
  });
  if (overrides != null) merge(overrides);
  final trace = headers['x-request-id'] ?? headers['x-client-request-id'];
  await checkPrivateAudioAbort(abortTrigger, 'Live connection');
  ensureNotClosed?.call();
  var abandoned = false;
  final cancelled = Completer<WebSocket>();
  if (abortTrigger != null) {
    void abort() {
      if (cancelled.isCompleted) return;
      cancelled.completeError(
        AbortedException(
          message: 'Live connection aborted.',
          stage: AbortionStage.duringRequest,
          correlationId: trace,
          timestamp: DateTime.now(),
          redactDiagnostics: true,
        ),
      );
    }

    unawaited(
      abortTrigger.then<void>(
        (_) => abort(),
        onError: (Object _, StackTrace _) => abort(),
      ),
    );
  }
  final WebSocket socket;
  try {
    final opening = (connector ?? connectLiveWebSocket)(
      url,
      headers: Map<String, String>.unmodifiable(headers),
    );
    unawaited(
      opening.then<void>((socket) {
        if (abandoned) unawaited(_dispose(socket));
      }, onError: (Object _, StackTrace _) {}),
    );
    socket = await Future.any<WebSocket>([opening, cancelled.future]).timeout(
      timeout,
      onTimeout: () =>
          throw TimeoutException('Live WebSocket handshake timed out.'),
    );
  } on AbortedException {
    abandoned = true;
    rethrow;
  } on LiveBrowserHeadersException {
    abandoned = true;
    rethrow;
  } catch (error) {
    abandoned = true;
    throw ConnectionException(
      message: error is TimeoutException
          ? 'Live WebSocket handshake timed out.'
          : 'Live WebSocket handshake failed.',
      url: url.toString(),
      cause: error,
      redactDiagnostics: true,
    );
  }
  try {
    await checkPrivateAudioAbort(abortTrigger, 'Live connection');
    ensureNotClosed?.call();
  } catch (_) {
    await _dispose(socket);
    rethrow;
  }
  try {
    if (fork) {
      return LiveForkConnection(
        socket,
        maxBufferedEvents: maxBufferedEvents,
        abortTrigger: abortTrigger,
        correlationId: trace,
      );
    }
    return sideband
        ? LiveSidebandConnection(
            socket,
            maxBufferedEvents: maxBufferedEvents,
            abortTrigger: abortTrigger,
            correlationId: trace,
          )
        : LivePrimaryConnection(
            socket,
            maxBufferedEvents: maxBufferedEvents,
            abortTrigger: abortTrigger,
            correlationId: trace,
          );
  } catch (_) {
    await _dispose(socket);
    rethrow;
  }
}

Future<void> _dispose(WebSocket socket) async {
  try {
    await socket.close(1000).timeout(const Duration(seconds: 5));
  } catch (_) {
    // Late or abandoned sockets never create an unhandled cleanup failure.
  }
}
