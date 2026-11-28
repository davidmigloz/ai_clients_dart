import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../auth/auth_provider.dart';
import '../client/config.dart';
import '../errors/exceptions.dart';
import '../genie/genie_auth_token.dart';
import '../genie/genie_session.dart';
import '../live/websocket_connector.dart' as ws;
import '../models/interactions/interaction.dart';
import 'base_resource.dart';

/// Gemini Developer API `v1beta` operations for Genie 4.
class GenieResource extends ResourceBase {
  static const _isWeb = bool.fromEnvironment('dart.library.js_interop');
  static const _apiRevision = '2026-05-20';
  static const _credentialFields = {
    'key',
    'api_key',
    'api-key',
    'apikey',
    'x-goog-api-key',
    'authorization',
    'access_token',
    'auth_token',
    'authtoken',
    'token',
  };

  /// Creates the Genie subresource of Interactions.
  GenieResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a Genie 4 interaction to connect to with [connect].
  /// This sends no world input. Seed the world after opening the socket.
  Future<Interaction> create({Future<void>? abortTrigger}) async {
    _ensureSupported();
    final response = await _post('', const {
      'model': 'genie-4',
    }, abortTrigger: abortTrigger);
    return Interaction.fromJson(response);
  }

  /// Mints a short-lived credential scoped to [interactionId].
  /// Call this on your server and pass the scoped token to the browser client.
  Future<GenieAuthToken> createAuthToken(
    String interactionId, {
    DateTime? expireTime,
    Future<void>? abortTrigger,
  }) async {
    _ensureSupported();
    _validateId(interactionId);
    final response = await _post(
      '/${Uri.encodeComponent(interactionId)}/auth_tokens',
      {
        if (expireTime != null)
          'expire_time': expireTime.toUtc().toIso8601String(),
      },
      abortTrigger: abortTrigger,
    );
    return GenieAuthToken.fromJson(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload, {
    Future<void>? abortTrigger,
  }) async {
    final url = requestBuilder.buildUrl(
      '/{version}/interactions$path',
      apiVersion: ApiVersion.v1beta,
    );
    final request = http.Request('POST', url)
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      )
      ..body = jsonEncode(payload);
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic>) return body;
    } on FormatException {
      // A malformed token response must not expose its raw body.
    }
    throw const FormatException('Invalid Genie API response.');
  }

  /// Opens a dedicated WebSocket session and sends the initial connect frame.
  ///
  /// Browsers require a scoped [authToken] or an `auth_tokens/...` value in the
  /// API-key provider. Native transports can also use a server-side API key.
  /// The [timeout] bounds authentication and upgrade and is the default wait
  /// for a completion acknowledgement.
  Future<GenieSession> connect(
    String interactionId, {
    String? authToken,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _ensureSupported();
    _validateId(interactionId);
    if (timeout <= Duration.zero) {
      throw ArgumentError('Timeout must be positive.');
    }
    if (authToken != null && !_isScopedToken(authToken)) {
      throw ArgumentError(
        'authToken must be a scoped auth_tokens/... credential.',
      );
    }

    var timedOut = false;
    Future<GenieSession> open() async {
      final credential = authToken ?? await _resolveCredential();
      if (credential == null || credential.trim().isEmpty) {
        throw const GenieConnectionException(
          message: 'Genie requires an API key or a scoped token.',
        );
      }
      if (_isWeb && !_isScopedToken(credential)) {
        throw const GenieConnectionException(
          message:
              'Browser Genie WebSockets require a scoped token created on your server.',
        );
      }
      if (timedOut) throw _connectionTimedOut;
      final uri = buildWebSocketUri(config, credential);
      final socket = await ws.connectWebSocket(
        uri,
        headers: _isWeb
            ? null
            : {
                for (final entry in config.defaultHeaders.entries)
                  if (!_credentialFields.contains(entry.key.toLowerCase()) &&
                      entry.key.toLowerCase() != 'api-revision')
                    entry.key: entry.value,
                'x-goog-api-key': credential,
                'api-revision': _apiRevision,
              },
      );
      if (timedOut) {
        await socket.close();
        throw _connectionTimedOut;
      }
      return GenieSession.attach(socket, interactionId, credential, timeout);
    }

    try {
      return await open().timeout(
        timeout,
        onTimeout: () {
          timedOut = true;
          throw _connectionTimedOut;
        },
      );
    } on GenieConnectionException {
      rethrow;
    } catch (_, stackTrace) {
      // Upgrade and authentication errors can include the raw credential URI.
      throw GenieConnectionException(
        message: 'Unable to open the Genie WebSocket.',
        stackTrace: stackTrace,
      );
    }
  }

  static const _connectionTimedOut = GenieConnectionException(
    message: 'Timed out opening the Genie WebSocket.',
  );

  Future<String?> _resolveCredential() async {
    final credentials = await config.authProvider?.getCredentials();
    return switch (credentials) {
      ApiKeyCredentials(:final apiKey) => apiKey,
      EphemeralTokenCredentials(:final token) => token,
      _ => null,
    };
  }

  /// Builds the dedicated transport URL using auth for the current platform.
  @visibleForTesting
  static Uri buildWebSocketUri(GoogleAIConfig config, String credential) {
    final base = Uri.parse(config.baseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final query = <String, dynamic>{
      ...base.queryParametersAll,
      ...config.defaultQueryParams,
    }..removeWhere((key, _) => _credentialFields.contains(key.toLowerCase()));
    if (_isWeb) query['auth_token'] = credential;
    final secure = base.scheme != 'http' && base.scheme != 'ws';
    return Uri(
      scheme: secure ? 'wss' : 'ws',
      host: base.host,
      port: base.hasPort ? base.port : (secure ? 443 : 80),
      path: '$basePath/v1beta/interactions/live',
      queryParameters: query.isEmpty ? null : query,
    );
  }

  void _ensureSupported() {
    ensureNotClosed?.call();
    if (config.apiMode != ApiMode.googleAI) {
      throw UnsupportedError(
        'Genie 4 is available on the Gemini Developer API only.',
      );
    }
  }

  static void _validateId(String interactionId) {
    if (interactionId.trim().isEmpty) {
      throw ArgumentError('A Genie interaction ID is required.');
    }
  }

  static bool _isScopedToken(String token) =>
      token.startsWith('auth_tokens/') && token.length > 'auth_tokens/'.length;
}
