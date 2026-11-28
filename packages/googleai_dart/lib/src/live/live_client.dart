import 'dart:async' show Completer;

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:web_socket/web_socket.dart';

import '../auth/auth_provider.dart';
import '../client/config.dart';
import '../errors/exceptions.dart';
import '../models/live/config/live_config.dart';
import '../models/live/config/session_resumption_config.dart';
import '../models/live/messages/client/client_message.dart';
import '../models/live/messages/server/server_message.dart';
import 'live_session.dart';
import 'websocket_connector.dart' as ws;

/// Client for the Gemini Live API.
///
/// Provides WebSocket-based real-time bidirectional streaming for
/// audio, video, and text conversations.
///
/// ## Example
///
/// ```dart
/// final client = GoogleAIClient(config: config);
/// final liveClient = client.createLiveClient();
///
/// final session = await liveClient.connect(
///   model: 'gemini-3.8-live',
///   liveConfig: LiveConfig(
///     generationConfig: LiveGenerationConfig(
///       responseModalities: [ResponseModality.audio],
///     ),
///   ),
/// );
///
/// // Use session for streaming...
///
/// await session.close();
/// await liveClient.close();
/// ```
class LiveClient {
  static final _log = Logger('LiveClient');
  static const _credentialQueryKeys = {
    'key',
    'api_key',
    'api-key',
    'x-goog-api-key',
    'access_token',
  };

  final GoogleAIConfig _config;
  final Set<LiveSession> _sessions = {};

  /// Creates a [LiveClient].
  LiveClient({required this._config});

  /// Connects to the Live API and starts a new session.
  ///
  /// [model] is the model to use (e.g., 'gemini-3.8-live').
  /// [liveConfig] contains session configuration (generation, VAD, tools, etc.).
  /// [accessToken] is an optional ephemeral token for client-side authentication.
  /// When provided, this token takes precedence over configured credentials
  /// and uses the Gemini Developer API's constrained `v1beta` endpoint.
  /// Alternatively, configure an `EphemeralTokenProvider`. Browsers require
  /// query-parameter placement. Project-scoped Vertex AI Live uses native
  /// OAuth headers. Custom gateways can instead supply their own credentials.
  ///
  /// Returns a [LiveSession] for bidirectional streaming.
  ///
  /// Throws [LiveConnectionException] if the connection fails.
  /// Throws [LiveSessionSetupException] if session setup fails.
  ///
  /// ## Using Ephemeral Tokens
  ///
  /// Ephemeral tokens allow secure client-side authentication without exposing
  /// the main API key. Create tokens server-side using `client.authTokens.create`
  /// with Gemini Developer API `v1beta`:
  ///
  /// ```dart
  /// // Server-side
  /// final token = await client.authTokens.create(
  ///   authToken: AuthToken(
  ///     expireTime: DateTime.now().add(Duration(minutes: 30)),
  ///     uses: 1,
  ///   ),
  /// );
  ///
  /// // Client-side
  /// final session = await liveClient.connect(
  ///   model: 'gemini-3.8-live',
  ///   accessToken: tokenFromServer,
  /// );
  /// ```
  Future<LiveSession> connect({
    required String model,
    LiveConfig? liveConfig,
    String? accessToken,
  }) async {
    final credentials = await _getCredentials(accessToken);
    final isVertex = _config.apiMode == ApiMode.vertexAI;
    if (isVertex && credentials is EphemeralTokenCredentials) {
      throw const LiveConnectionException(
        message: 'Ephemeral Live tokens require the Gemini Developer API.',
      );
    }

    if (isVertex && credentials is ApiKeyCredentials) {
      throw const LiveConnectionException(
        message: 'Project-scoped Vertex AI Live requires OAuth credentials.',
      );
    }

    final useEphemeralHeader =
        credentials is EphemeralTokenCredentials &&
        credentials.placement == EphemeralTokenPlacement.header;
    final authQueryParams = <String, String>{};
    Map<String, String>? headers;
    switch (credentials) {
      case ApiKeyCredentials(:final apiKey):
        authQueryParams['key'] = apiKey;
      case EphemeralTokenCredentials(:final token):
        if (useEphemeralHeader) {
          headers = {'Authorization': 'Token $token'};
        } else {
          authQueryParams['access_token'] = token;
        }
      case BearerTokenCredentials(:final token) when isVertex:
        headers = {'Authorization': 'Bearer $token'};
      default:
        break;
    }
    final Uri uri;
    try {
      uri = buildWebSocketUri(
        _config,
        authQueryParams,
        useEphemeralHeader: useEphemeralHeader,
      );
    } on FormatException {
      throw const LiveConnectionException(
        message: 'Invalid Live API base URL.',
      );
    }
    _log.fine('Connecting to Live API');

    final LiveSession session;
    try {
      final socket = await ws.connectWebSocket(uri, headers: headers);
      session = LiveSession.attach(
        socket,
        onClosed: _sessions.remove,
        redactDiagnostic: (message) =>
            _safeSocketMessage(message, uri, credentials),
      );
      _sessions.add(session);
    } on LiveConnectionException catch (error, stackTrace) {
      // Platform connectors supply static, credential-free guidance here.
      throw LiveConnectionException(
        message: error.message,
        uri: _diagnosticUri(uri),
        stackTrace: stackTrace,
      );
    } on UnsupportedError {
      rethrow;
    } catch (error, stackTrace) {
      final cause = error is WebSocketException
          ? WebSocketException(
              _safeSocketMessage(error.message, uri, credentials),
            )
          : null;
      throw LiveConnectionException(
        message:
            'Failed to connect to Live API: ${cause?.message ?? error.runtimeType}',
        uri: _diagnosticUri(uri),
        stackTrace: stackTrace,
        cause: cause,
      );
    }

    // Phase 2: Setup session (separate try block to surface setup errors)
    try {
      await _setupSession(session, model, liveConfig);
      _log.fine('Live session established');
      return session;
    } catch (error, stackTrace) {
      try {
        await session.close();
      } catch (_) {
        // The original setup failure carries the actionable error.
      }
      if (error is LiveSessionSetupException) rethrow;
      throw LiveSessionSetupException(
        message: 'Live session setup failed (${error.runtimeType}).',
        stackTrace: stackTrace,
        cause: error is GoogleAIException ? error : null,
      );
    }
  }

  /// Resumes a previous session using a resumption token.
  ///
  /// [model] is the model to use (must match the original session).
  /// [resumptionToken] is the token from [LiveSession.resumptionToken].
  /// [liveConfig] contains additional session configuration.
  /// [accessToken] is an optional ephemeral token for client-side authentication.
  ///
  /// Throws [LiveSessionResumptionException] if resumption fails.
  Future<LiveSession> resume({
    required String model,
    required String resumptionToken,
    LiveConfig? liveConfig,
    String? accessToken,
  }) async {
    final config = (liveConfig ?? const LiveConfig()).copyWith(
      sessionResumption: SessionResumptionConfig.resume(
        resumptionToken,
        transparent: liveConfig?.sessionResumption?.transparent,
      ),
    );

    try {
      return await connect(
        model: model,
        liveConfig: config,
        accessToken: accessToken,
      );
    } on LiveConnectionException catch (e) {
      throw LiveSessionResumptionException(
        message: 'Failed to resume session: ${e.message}',
        handle: resumptionToken,
        cause: e.cause,
      );
    }
  }

  Future<AuthCredentials?> _getCredentials(String? accessToken) async {
    if (accessToken != null) return EphemeralTokenCredentials(accessToken);
    try {
      return await _config.authProvider?.getCredentials();
    } catch (_, stackTrace) {
      throw LiveConnectionException(
        message: 'Unable to obtain Live API credentials.',
        stackTrace: stackTrace,
      );
    }
  }

  /// Builds the WebSocket URI for a Live API connection.
  ///
  /// Query parameters normally merge in order: base URL → auth → config
  /// defaults. For constrained Developer API connections, an explicit or
  /// provider-issued token takes precedence and API keys are removed. Set
  /// [useEphemeralHeader] when the ephemeral token is in an auth header.
  ///
  /// A base URL may use a proxy path and explicit port. An `http` or `ws`
  /// base URL maps to `ws`. Other schemes and scheme-less hosts map to `wss`.
  @visibleForTesting
  static Uri buildWebSocketUri(
    GoogleAIConfig config,
    Map<String, String> authQueryParams, {
    bool useEphemeralHeader = false,
  }) {
    const googleBase = 'https://generativelanguage.googleapis.com';
    final isVertex = config.apiMode == ApiMode.vertexAI;
    if (isVertex && config.projectId == null) {
      throw const LiveSessionSetupException(
        message: 'Project ID is required for Vertex AI',
      );
    }
    final defaultBase = isVertex
        ? GoogleAIConfig.vertexAIBaseUrl(config.location ?? 'us-central1')
        : googleBase;
    final raw =
        config.baseUrl.isEmpty || (isVertex && config.baseUrl == googleBase)
        ? defaultBase
        : config.baseUrl;
    final baseUri = Uri.parse(raw.contains('://') ? raw : 'https://$raw');
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final secure = baseUri.scheme != 'http' && baseUri.scheme != 'ws';
    final queryParams = <String, dynamic>{
      ...baseUri.queryParametersAll,
      ...authQueryParams,
      ...config.defaultQueryParams,
    };

    final String endpoint;
    if (isVertex) {
      final version = config.apiVersion == ApiVersion.v1 ? 'v1' : 'v1beta1';
      endpoint =
          '/ws/google.cloud.aiplatform.$version.LlmBidiService/BidiGenerateContent';
      queryParams.removeWhere(
        (name, _) => _credentialQueryKeys.contains(name.toLowerCase()),
      );
    } else {
      final accessToken =
          authQueryParams['access_token'] ?? queryParams['access_token'];
      final constrained = useEphemeralHeader || accessToken != null;
      final version = constrained ? 'v1beta' : config.apiVersion.value;
      final method = constrained
          ? 'BidiGenerateContentConstrained'
          : 'BidiGenerateContent';
      endpoint =
          '/ws/google.ai.generativelanguage.$version.GenerativeService.$method';
      if (constrained) {
        queryParams.removeWhere(
          (name, _) => _credentialQueryKeys.contains(name.toLowerCase()),
        );
        if (!useEphemeralHeader && accessToken != null) {
          queryParams['access_token'] = accessToken;
        }
      }
    }

    return Uri(
      scheme: secure ? 'wss' : 'ws',
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : (secure ? 443 : 80),
      path: '$basePath$endpoint',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  static Uri _diagnosticUri(Uri uri) =>
      Uri(scheme: uri.scheme, host: uri.host, port: uri.port, path: uri.path);

  static String _safeSocketMessage(
    String message,
    Uri uri,
    AuthCredentials? credentials,
  ) {
    var safe = message.replaceAll(
      uri.toString(),
      _diagnosticUri(uri).toString(),
    );
    final credential = switch (credentials) {
      ApiKeyCredentials(:final apiKey) => apiKey,
      BearerTokenCredentials(:final token) ||
      EphemeralTokenCredentials(:final token) => token,
      _ => null,
    };
    final values =
        {
            ...uri.queryParametersAll.values.expand((values) => values),
            ?credential,
          }.where((value) => value.isNotEmpty).toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    for (final value in values) {
      safe = safe.replaceAll(value, '[redacted]');
      for (final encoded in {
        Uri.encodeComponent(value),
        Uri.encodeQueryComponent(value),
      }) {
        if (encoded == value) continue;
        safe = safe.replaceAll(
          RegExp(RegExp.escape(encoded), caseSensitive: false),
          '[redacted]',
        );
      }
    }
    return safe;
  }

  Future<void> _setupSession(
    LiveSession session,
    String model,
    LiveConfig? liveConfig,
  ) async {
    // Build model path based on API mode
    final String modelPath;
    if (_config.apiMode == ApiMode.vertexAI) {
      // Vertex AI: projects/{project}/locations/{location}/publishers/google/models/{model}
      if (model.startsWith('projects/')) {
        modelPath = model; // Already fully qualified
      } else {
        final projectId = _config.projectId;
        if (projectId == null) {
          throw const LiveSessionSetupException(
            message: 'projectId required for Vertex AI',
          );
        }
        final location = _config.location ?? 'us-central1';
        final publisherModel = model.startsWith('publishers/')
            ? model
            : 'publishers/google/${model.startsWith('models/') ? model : 'models/$model'}';
        modelPath = 'projects/$projectId/locations/$location/$publisherModel';
      }
    } else {
      // Google AI: models/{model}
      modelPath = model.startsWith('models/') ? model : 'models/$model';
    }

    final setup = BidiGenerateContentSetup(
      model: modelPath,
      generationConfig: liveConfig?.generationConfig,
      systemInstruction: liveConfig?.systemInstruction,
      tools: liveConfig?.tools,
      realtimeInputConfig: liveConfig?.realtimeInputConfig,
      sessionResumption: liveConfig?.sessionResumption,
      contextWindowCompression: liveConfig?.contextWindowCompression,
      inputAudioTranscription: liveConfig?.inputAudioTranscription,
      outputAudioTranscription: liveConfig?.outputAudioTranscription,
      proactivity: liveConfig?.proactivity,
      historyConfig: liveConfig?.historyConfig,
    );

    // Subscribe before sending setup so an immediate response cannot be lost.
    final completer = Completer<void>();
    completer.future.ignore();
    final subscription = session.messages.listen(
      (message) {
        if (message is BidiGenerateContentSetupComplete) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            const LiveSessionSetupException(
              message: 'Connection closed before setup completed',
            ),
          );
        }
      },
    );

    try {
      session.send(setup);
      const defaultTimeout = Duration(seconds: 30);
      final timeout = _config.timeout < defaultTimeout
          ? _config.timeout
          : defaultTimeout;
      await completer.future.timeout(
        timeout,
        onTimeout: () {
          throw LiveSessionSetupException(
            message:
                'Live session setup timed out after ${timeout.inMilliseconds} ms.',
          );
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  /// Closes all active sessions and cleans up resources.
  Future<void> close() async {
    final active = _sessions.toList(growable: false);
    await Future.wait(active.map((session) => session.close()));
  }
}
