import 'dart:async' show Completer, StreamController, StreamSubscription, Timer;
import 'dart:convert';

import 'package:web_socket/web_socket.dart';

import '../auth/auth_provider.dart';
import '../client/config.dart';
import '../errors/exceptions.dart';
import '../models/live/music/live_music_generation_config.dart';
import '../models/live/music/live_music_server_message.dart';
import 'websocket_connector.dart' as ws;

part 'live_music_session.dart';

/// Client for experimental Lyria RealTime music generation.
///
/// Uses the Gemini Developer API `v1beta` Live Music WebSocket. Use an API key
/// for direct connections, or set a [GoogleAIConfig.baseUrl] for a gateway.
/// Close the client to release its sessions and cancel pending connections.
class LiveMusicClient {
  /// Creates a Live Music client.
  LiveMusicClient({required this._config});

  static const _defaultHost = 'generativelanguage.googleapis.com';
  static const _endpoint =
      '/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic';

  final GoogleAIConfig _config;
  final Set<LiveMusicSession> _sessions = {};
  final Set<void Function()> _pending = {};
  Future<void>? _closing;

  /// Connects to [model] and waits for the server to acknowledge setup.
  ///
  /// The public model is `lyria-realtime-exp`. Use [abortTrigger] to cancel
  /// a pending connect. To stop a connected session, close it or cancel its
  /// message subscription.
  Future<LiveMusicSession> connect({
    required String model,
    Future<void>? abortTrigger,
  }) async {
    if (_closing != null) {
      throw StateError('The Live Music client is closed.');
    }
    if (_config.apiMode != ApiMode.googleAI ||
        _config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError(
        'Live Music requires the Gemini Developer API with ApiVersion.v1beta.',
      );
    }
    final modelName = model.startsWith('models/') ? model : 'models/$model';
    if (modelName == 'models/' || modelName.substring(7).contains('/')) {
      throw ArgumentError.value(
        model,
        'model',
        'Expected a Live Music model ID.',
      );
    }

    final result = Completer<LiveMusicSession>();
    LiveMusicSession? current;
    void fail(Object error, [StackTrace? trace]) {
      if (result.isCompleted) return;
      result.completeError(error, trace);
      current?.close().ignore();
    }

    void cancel() => fail(
      const LiveConnectionException(message: 'Live Music connection canceled.'),
    );
    _pending.add(cancel);
    final timer = Timer(_config.timeout, () {
      fail(
        current == null
            ? const LiveConnectionException(
                message: 'Live Music connection timed out.',
              )
            : const LiveSessionSetupException(
                message: 'Live Music setup timed out.',
              ),
      );
    });
    void Function()? handleAbort = cancel;
    abortTrigger
        ?.then<void>(
          (_) => handleAbort?.call(),
          onError: (Object _) => handleAbort?.call(),
        )
        .ignore();

    Future<void> open() async {
      final Uri uri;
      try {
        final credentials = await _getCredentials();
        if (result.isCompleted) return;
        uri = _buildUri(credentials);
      } catch (error, trace) {
        fail(error, trace);
        return;
      }

      final WebSocket socket;
      try {
        socket = await ws.connectWebSocket(uri);
      } on UnsupportedError catch (error, trace) {
        fail(error, trace);
        return;
      } catch (error, trace) {
        fail(
          LiveConnectionException(
            message:
                'Unable to open the Live Music WebSocket (${error.runtimeType}).',
            uri: uri.replace(query: ''),
          ),
          trace,
        );
        return;
      }
      if (result.isCompleted) {
        // A connection can arrive after the timeout or abort signal.
        try {
          await socket.close();
        } on WebSocketConnectionClosed {
          // Already closed by the remote end.
        }
        return;
      }
      final session = LiveMusicSession._(
        socket,
        onClosed: _sessions.remove,
        redact: (message) => _redact(message, uri),
      );
      current = session;
      _sessions.add(session);
      try {
        await session._setup(modelName);
        if (!result.isCompleted) result.complete(session);
      } catch (error, trace) {
        fail(
          error is LiveSessionSetupException
              ? error
              : LiveSessionSetupException(
                  message: 'Unable to initialize the Live Music session.',
                  stackTrace: trace,
                ),
          trace,
        );
      }
    }

    open().ignore();
    try {
      return await result.future;
    } finally {
      timer.cancel();
      _pending.remove(cancel);
      handleAbort = null;
    }
  }

  Future<AuthCredentials?> _getCredentials() async {
    try {
      return await _config.authProvider?.getCredentials();
    } catch (_, trace) {
      throw LiveConnectionException(
        message: 'Unable to obtain Live Music credentials.',
        stackTrace: trace,
      );
    }
  }

  Uri _buildUri(AuthCredentials? credentials) {
    if (credentials is BearerTokenCredentials ||
        credentials is EphemeralTokenCredentials) {
      throw UnsupportedError(
        'Live Music supports Gemini API key authentication.',
      );
    }
    final configured = _config.baseUrl;
    final base = Uri.tryParse(
      configured.isEmpty
          ? 'https://$_defaultHost'
          : configured.contains('://')
          ? configured
          : 'https://$configured',
    );
    if (base == null ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        !const {'https', 'http', 'wss', 'ws'}.contains(base.scheme)) {
      throw const LiveConnectionException(
        message: 'Invalid Live Music base URL.',
      );
    }
    final params = <String, dynamic>{
      ...base.queryParametersAll,
      ..._config.defaultQueryParams,
    };
    if (params.keys.any((name) => name.toLowerCase() == 'access_token')) {
      throw UnsupportedError(
        'Live Music supports Gemini API key authentication.',
      );
    }
    if (credentials is ApiKeyCredentials) {
      params['key'] = credentials.apiKey;
    }
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final uri = Uri(
      scheme: base.scheme == 'http' || base.scheme == 'ws' ? 'ws' : 'wss',
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '$basePath$_endpoint',
      queryParameters: params.isEmpty ? null : params,
    );
    if (uri.host == _defaultHost &&
        uri.queryParametersAll['key']?.any((key) => key.isNotEmpty) != true) {
      throw const LiveConnectionException(
        message: 'A Gemini API key is required for Live Music.',
      );
    }
    return uri;
  }

  static String _redact(String message, Uri uri) {
    var safe = message.replaceAll(uri.toString(), '[redacted WebSocket URL]');
    for (final value in uri.queryParametersAll.values.expand(
      (values) => values,
    )) {
      if (value.isEmpty) continue;
      for (final form in {
        value,
        Uri.encodeComponent(value),
        Uri.encodeQueryComponent(value),
      }) {
        safe = safe.replaceAll(form, '[redacted]');
      }
    }
    return safe;
  }

  /// Closes all active sessions and cancels pending connections.
  ///
  /// After close, create a new client to open more sessions.
  Future<void> close() {
    final existing = _closing;
    if (existing != null) return existing;
    final active = _sessions.toList(growable: false);
    for (final cancel in _pending.toList(growable: false)) {
      cancel();
    }
    return _closing = Future.wait<void>(
      active.map((session) => session.close()),
    ).then<void>((_) {});
  }
}
