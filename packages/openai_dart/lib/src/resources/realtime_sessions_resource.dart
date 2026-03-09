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
/// // Create a realtime session with ephemeral key
/// final session = await client.realtimeSessions.create(
///   RealtimeSessionCreateRequest(
///     model: 'gpt-realtime-1.5',
///     voice: RealtimeVoice.alloy,
///   ),
/// );
///
/// // Use the client secret for WebSocket connection
/// final ws = await WebSocket.connect(
///   'wss://api.openai.com/v1/realtime',
///   headers: {'Authorization': 'Bearer ${session.clientSecret.value}'},
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

  static const _sessionsEndpoint = '/realtime/sessions';
  static const _transcriptionEndpoint = '/realtime/transcription_sessions';
  static const _clientSecretsEndpoint = '/realtime/client_secrets';

  RealtimeCallsResource? _calls;

  /// Access to WebRTC call operations.
  RealtimeCallsResource get calls => _calls ??= RealtimeCallsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Creates a realtime session with an ephemeral API key.
  ///
  /// This endpoint creates a session configuration and returns an ephemeral
  /// client secret that can be used to authenticate WebSocket connections
  /// without exposing your main API key.
  ///
  /// ## Parameters
  ///
  /// - [request] - The session creation request parameters.
  ///
  /// ## Returns
  ///
  /// A [RealtimeSessionCreateResponse] containing the session configuration
  /// and client secret.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.realtimeSessions.create(
  ///   RealtimeSessionCreateRequest(
  ///     model: 'gpt-realtime-1.5',
  ///     voice: RealtimeVoice.alloy,
  ///     instructions: 'You are a helpful assistant.',
  ///     turnDetection: TurnDetection(
  ///       type: TurnDetectionType.serverVad,
  ///       threshold: 0.5,
  ///     ),
  ///   ),
  /// );
  ///
  /// print('Session ID: ${session.id}');
  /// print('Client secret: ${session.clientSecret.value}');
  /// ```
  Future<RealtimeSessionCreateResponse> create(
    RealtimeSessionCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_sessionsEndpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return RealtimeSessionCreateResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a realtime transcription session.
  ///
  /// Transcription sessions are optimized for audio-to-text scenarios
  /// without generating audio responses.
  ///
  /// ## Parameters
  ///
  /// - [request] - The transcription session creation request.
  ///
  /// ## Returns
  ///
  /// A [RealtimeTranscriptionSessionCreateResponse] containing the session
  /// configuration and client secret.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.realtimeSessions.createTranscription(
  ///   RealtimeTranscriptionSessionCreateRequest(
  ///     inputAudioFormat: RealtimeAudioFormat.pcm16,
  ///     inputAudioTranscription: InputAudioTranscription(
  ///       model: 'whisper-1',
  ///     ),
  ///     turnDetection: TurnDetection(
  ///       type: TurnDetectionType.serverVad,
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<RealtimeTranscriptionSessionCreateResponse> createTranscription(
    RealtimeTranscriptionSessionCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_transcriptionEndpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return RealtimeTranscriptionSessionCreateResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

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
  ///       model: 'gpt-realtime-1.5',
  ///       voice: RealtimeVoice.shimmer,
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
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_clientSecretsEndpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
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
  ///       model: 'gpt-realtime-1.5',
  ///       voice: RealtimeVoice.alloy,
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

  /// Accepts an incoming SIP call.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to accept.
  Future<void> accept(String callId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_callsEndpoint/$callId/accept');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
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
