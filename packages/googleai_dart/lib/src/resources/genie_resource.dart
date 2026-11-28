import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../auth/auth_provider.dart';
import '../client/config.dart';
import '../errors/exceptions.dart';
import '../genie/genie_auth_token.dart';
import '../genie/genie_session.dart';
import '../genie/genie_transport.dart';
import '../genie/genie_webrtc_peer.dart';
import '../genie/genie_webrtc_stub.dart'
    if (dart.library.js_interop) '../genie/genie_webrtc_browser.dart'
    as platform;
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
      return GenieSession.attach(
        GenieSocketTransport(socket),
        interactionId,
        credential,
        timeout,
        sendConnectFrame: true,
      );
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

  /// Negotiates a WebRTC session for a Genie 4 interaction over Developer v1beta.
  ///
  /// Pass a scoped [authToken] minted on a trusted server for browser use.
  /// The browser has a default peer. Supply [peer] to attach a media element
  /// or to integrate a host RTC binding on native Dart. The peer belongs to
  /// this session from the start of negotiation and is closed on failure.
  /// `receive()` provides control events. Audio and video arrive on RTP tracks.
  Future<GenieSession> connectWebRtc(
    String interactionId, {
    String? authToken,
    GenieWebRtcPeer? peer,
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

    final rtcPeer = peer ?? platform.createWebRtcPeer();
    final abort = Completer<void>();
    void ensureActive() {
      if (abort.isCompleted) throw _webRtcTimedOut;
    }

    Future<GenieSession> negotiate() async {
      final credential = authToken ?? await _resolveCredential();
      ensureActive();
      if (credential == null || credential.trim().isEmpty) {
        throw const GenieConnectionException(
          message: 'Genie requires an API key or a scoped token.',
        );
      }
      if (_isWeb && !_isScopedToken(credential)) {
        throw const GenieConnectionException(
          message:
              'Browser Genie WebRTC requires a scoped token created on your server.',
        );
      }

      final channel =
          (rtcPeer
                ..addReceiveOnlyTransceiver(GenieWebRtcMediaKind.audio)
                ..addReceiveOnlyTransceiver(GenieWebRtcMediaKind.video))
              .createDataChannel('events');
      final opened = channel.opened..ignore();
      final offer = await rtcPeer.createOffer();
      ensureActive();
      if (offer.trim().isEmpty) {
        throw const GenieConnectionException(
          message: 'The Genie WebRTC peer produced an empty SDP offer.',
        );
      }
      final answer = await _signalWebRtc(
        interactionId,
        credential,
        offer,
        abort.future,
      );
      ensureActive();
      await rtcPeer.setAnswer(answer);
      await opened;
      ensureActive();
      return GenieSession.attach(
        GenieRtcTransport(rtcPeer, channel),
        interactionId,
        credential,
        timeout,
        sendConnectFrame: false,
      );
    }

    try {
      return await negotiate().timeout(
        timeout,
        onTimeout: () {
          abort.complete();
          throw _webRtcTimedOut;
        },
      );
    } catch (error, stackTrace) {
      Future<void>.sync(rtcPeer.close).ignore();
      if (error is GenieConnectionException) rethrow;
      // A third-party peer or HTTP transport may attach raw credentials or SDP.
      throw GenieConnectionException(
        message: 'Unable to negotiate the Genie WebRTC session.',
        stackTrace: stackTrace,
      );
    }
  }

  static const _webRtcTimedOut = GenieConnectionException(
    message: 'Timed out negotiating the Genie WebRTC session.',
  );

  Future<String> _signalWebRtc(
    String id,
    String credential,
    String offer,
    Future<void> abortTrigger,
  ) async {
    final url = requestBuilder.buildUrl(
      '/{version}/interactions/${Uri.encodeComponent(id)}:webrtc',
      apiVersion: ApiVersion.v1beta,
    );
    final query = Map.of(url.queryParametersAll)
      ..removeWhere((key, _) => _credentialFields.contains(key.toLowerCase()));
    final uri = Uri(
      scheme: url.scheme,
      host: url.host,
      port: url.hasPort ? url.port : null,
      path: url.path,
      queryParameters: query.isEmpty ? null : query,
    );
    // Scoped signaling auth takes precedence over every inherited credential.
    // The browser CORS allowlist does not include the WebSocket API revision.
    final request =
        http.AbortableRequest('POST', uri, abortTrigger: abortTrigger)
          ..followRedirects = false
          ..headers.addAll({
            for (final entry in config.defaultHeaders.entries)
              if (!_credentialFields.contains(entry.key.toLowerCase()) &&
                  !const {
                    'api-revision',
                    'accept',
                    'content-type',
                  }.contains(entry.key.toLowerCase()))
                entry.key: entry.value,
            'content-type': 'application/json',
            'accept': 'application/json',
            'x-goog-api-key': credential,
          })
          ..body = jsonEncode({'offer_sdp': offer});

    // Send directly to avoid another credential injection or SDP diagnostics.
    final response = await httpClient.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await response.stream.listen(null).cancel();
      throw GenieConnectionException(
        message:
            'Genie WebRTC signaling failed with HTTP status ${response.statusCode}.',
        httpStatus: response.statusCode,
      );
    }
    try {
      final body = await response.stream.bytesToString();
      if (jsonDecode(body) case {
        'answer_sdp': final String answer,
      } when answer.trim().isNotEmpty) {
        return answer;
      }
    } on FormatException {
      // The response may contain credential or connection information.
    }
    throw const GenieConnectionException(
      message:
          'The Genie WebRTC signaling response is missing a valid SDP answer.',
    );
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
