import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/realtime/realtime.dart';
import 'base_resource.dart';

/// Resource for Realtime HTTP API operations.
///
/// The Realtime HTTP API provides endpoints for creating sessions,
/// managing client secrets, and handling WebRTC calls.
///
/// Access this resource through [OpenAIClient.realtimeSessions].
///
/// ## Example
///
/// ```dart
/// // Create a realtime session and a separate ephemeral client secret
/// final secret = await client.realtimeSessions.createClientSecret(
///   RealtimeClientSecretCreateRequest(
///     session: RealtimeSessionCreateRequest(
///       model: 'gpt-realtime-2',
///       audio: RealtimeAudioConfig(
///         output: RealtimeAudioConfigOutput(voice: 'alloy'),
///       ),
///     ),
///   ),
/// );
///
/// // Use the client secret for WebSocket connection
/// final ws = await WebSocket.connect(
///   'wss://api.openai.com/v1/realtime',
///   headers: {'Authorization': 'Bearer ${secret.value}'},
/// );
/// ```
class RealtimeSessionsResource extends ResourceBase {
  /// Creates a [RealtimeSessionsResource].
  RealtimeSessionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _clientSecretsEndpoint = '/realtime/client_secrets';

  RealtimeCallsResource? _calls;
  RealtimeTranslationsResource? _translations;

  /// Access to WebRTC call operations.
  RealtimeCallsResource get calls => _calls ??= RealtimeCallsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Access to Realtime translation operations.
  ///
  /// Mirrors the Python SDK split (`client.realtime.client_secrets` /
  /// `client.realtime.calls`) — final user-facing path:
  /// `client.realtimeSessions.translations.createClientSecret(...)`.
  RealtimeTranslationsResource get translations =>
      _translations ??= RealtimeTranslationsResource(
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
      );

  /// Creates a client secret with custom configuration.
  ///
  /// This endpoint creates an ephemeral client secret with custom
  /// expiration settings and session configuration.
  ///
  /// ## Parameters
  ///
  /// - [request] - The client secret creation request.
  ///
  /// ## Returns
  ///
  /// A [RealtimeClientSecretCreateResponse] containing the client secret
  /// and associated session.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.realtimeSessions.createClientSecret(
  ///   RealtimeClientSecretCreateRequest(
  ///     expiresAfter: ExpiresAfter(anchor: 'created_at', seconds: 3600),
  ///     session: RealtimeSessionCreateRequest(
  ///       model: 'gpt-realtime-2',
  ///       audio: RealtimeAudioConfig(
  ///         output: RealtimeAudioConfigOutput(voice: 'shimmer'),
  ///       ),
  ///     ),
  ///   ),
  /// );
  ///
  /// print('Secret: ${response.value}');
  /// print('Expires at: ${response.expiresAt}');
  /// ```
  Future<RealtimeClientSecretCreateResponse> createClientSecret(
    RealtimeClientSecretCreateRequest request, {
    Future<void>? abortTrigger,
  }) => _postClientSecret(request.toJson(), abortTrigger: abortTrigger);

  /// Creates an ephemeral client secret for a **transcription** session.
  ///
  /// Transcription sessions use a different shape than realtime sessions —
  /// they don't carry a `model` on the inner session payload. This helper
  /// posts to the same `/realtime/client_secrets` endpoint with the
  /// transcription discriminator (`type: 'transcription'`).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response =
  ///     await client.realtimeSessions.createTranscriptionClientSecret(
  ///   RealtimeTranscriptionClientSecretCreateRequest(
  ///     session: RealtimeTranscriptionSessionCreateRequest(
  ///       audio: RealtimeTranscriptionSessionAudio(
  ///         input: RealtimeAudioConfigInput(
  ///           transcription: InputAudioTranscription(
  ///             model: 'gpt-realtime-whisper',
  ///           ),
  ///         ),
  ///       ),
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<RealtimeClientSecretCreateResponse> createTranscriptionClientSecret(
    RealtimeTranscriptionClientSecretCreateRequest request, {
    Future<void>? abortTrigger,
  }) => _postClientSecret(request.toJson(), abortTrigger: abortTrigger);

  Future<RealtimeClientSecretCreateResponse> _postClientSecret(
    Map<String, dynamic> body, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_clientSecretsEndpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return RealtimeClientSecretCreateResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

/// Resource for Realtime WebRTC call operations.
///
/// Provides access to WebRTC call management including creating,
/// accepting, hanging up, and transferring calls.
class RealtimeCallsResource extends ResourceBase {
  /// Creates a [RealtimeCallsResource].
  RealtimeCallsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _callsEndpoint = '/realtime/calls';

  /// Creates a WebRTC call with an SDP offer.
  ///
  /// This endpoint initiates a WebRTC call by sending an SDP offer
  /// and receiving an SDP answer that can be used to complete the
  /// WebRTC handshake.
  ///
  /// **Note:** This endpoint uses multipart/form-data and returns
  /// an SDP answer string (application/sdp).
  ///
  /// ## Parameters
  ///
  /// - [request] - The call creation request with SDP offer.
  ///
  /// ## Returns
  ///
  /// The SDP answer string. The call ID can be retrieved from the
  /// 'Location' header if needed for subsequent operations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final sdpAnswer = await client.realtimeSessions.calls.create(
  ///   RealtimeCallCreateRequest(
  ///     sdp: myPeerConnection.localDescription.sdp,
  ///     session: RealtimeSessionCreateRequest(
  ///       model: 'gpt-realtime-2',
  ///       audio: RealtimeAudioConfig(
  ///         output: RealtimeAudioConfigOutput(voice: 'alloy'),
  ///       ),
  ///     ),
  ///   ),
  /// );
  ///
  /// await myPeerConnection.setRemoteDescription(
  ///   RTCSessionDescription(sdpAnswer, 'answer'),
  /// );
  /// ```
  Future<String> create(
    RealtimeCallCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_callsEndpoint);
    final httpRequest = http.MultipartRequest('POST', url);

    // Add SDP as a field
    httpRequest.fields['sdp'] = request.sdp;

    // Add session as a field if provided
    if (request.session != null) {
      httpRequest.fields['session'] = jsonEncode(request.session!.toJson());
    }

    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return response.body;
  }

  /// Accepts an incoming SIP call, optionally overriding the realtime
  /// session configuration.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to accept.
  /// - [request] - Optional session configuration to apply on accept
  ///   (model, audio, instructions, tools, reasoning, tracing, …). When
  ///   omitted, the call is accepted with the server's default session.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await client.realtimeSessions.calls.accept(
  ///   callId,
  ///   request: const RealtimeSessionCreateRequest(
  ///     model: 'gpt-realtime-2',
  ///     audio: RealtimeAudioConfig(
  ///       output: RealtimeAudioConfigOutput(voice: 'alloy'),
  ///     ),
  ///     instructions: 'Greet the caller in English.',
  ///   ),
  /// );
  /// ```
  Future<void> accept(
    String callId, {
    RealtimeSessionCreateRequest? request,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_callsEndpoint/$callId/accept');
    final headers = requestBuilder.buildHeaders();
    // The /realtime/calls/{id}/accept endpoint requires the `type`
    // discriminator on the embedded session payload (whereas the bare
    // /realtime/sessions endpoint rejects it). Inject `'realtime'` when
    // the caller didn't set it explicitly — same trick as
    // `RealtimeClientSecretCreateRequest.toJson`.
    final Map<String, dynamic> body;
    if (request != null) {
      body = request.toJson();
      body['type'] ??= 'realtime';
    } else {
      body = <String, dynamic>{};
    }
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);
    await interceptorChain.execute(httpRequest, abortTrigger: abortTrigger);
  }

  /// Hangs up an active call.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to hang up.
  Future<void> hangup(String callId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_callsEndpoint/$callId/hangup');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
    await interceptorChain.execute(httpRequest, abortTrigger: abortTrigger);
  }

  /// Transfers a call to another destination.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to transfer.
  /// - [request] - The transfer request with target URI.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await client.realtimeSessions.calls.refer(
  ///   callId,
  ///   RealtimeCallReferRequest(targetUri: 'tel:+14155550123'),
  /// );
  /// ```
  Future<void> refer(
    String callId,
    RealtimeCallReferRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_callsEndpoint/$callId/refer');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    await interceptorChain.execute(httpRequest, abortTrigger: abortTrigger);
  }

  /// Rejects an incoming SIP call.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to reject.
  /// - [request] - Optional rejection request with status code.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await client.realtimeSessions.calls.reject(
  ///   callId,
  ///   request: RealtimeCallRejectRequest(statusCode: 486), // Busy Here
  /// );
  /// ```
  Future<void> reject(
    String callId, {
    RealtimeCallRejectRequest? request,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_callsEndpoint/$callId/reject');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request?.toJson() ?? <String, dynamic>{});
    await interceptorChain.execute(httpRequest, abortTrigger: abortTrigger);
  }
}

/// Resource for Realtime translation operations.
///
/// Translation sessions continuously translate input audio into the configured
/// output language using `gpt-realtime-translate`.
class RealtimeTranslationsResource extends ResourceBase {
  /// Creates a [RealtimeTranslationsResource].
  RealtimeTranslationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _translationClientSecretsEndpoint =
      '/realtime/translations/client_secrets';

  /// Creates a translation client secret with session configuration.
  ///
  /// `POST /realtime/translations/client_secrets`. Returns an ephemeral
  /// client secret that authenticates a translation WebSocket session.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response =
  ///     await client.realtimeSessions.translations.createClientSecret(
  ///   RealtimeTranslationClientSecretCreateRequest(
  ///     session: RealtimeTranslationSessionCreateRequest(
  ///       model: 'gpt-realtime-translate',
  ///       audio: RealtimeTranslationSessionAudio(
  ///         input: RealtimeTranslationSessionAudioInput(
  ///           transcription: RealtimeTranslationInputTranscription(
  ///             model: 'gpt-realtime-whisper',
  ///           ),
  ///         ),
  ///         output: RealtimeTranslationSessionAudioOutput(language: 'es'),
  ///       ),
  ///     ),
  ///   ),
  /// );
  ///
  /// print('Secret: ${response.value}');
  /// ```
  Future<RealtimeTranslationClientSecretCreateResponse> createClientSecret(
    RealtimeTranslationClientSecretCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_translationClientSecretsEndpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return RealtimeTranslationClientSecretCreateResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
