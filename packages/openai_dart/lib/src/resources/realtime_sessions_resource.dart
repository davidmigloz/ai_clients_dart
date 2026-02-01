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
///     model: 'gpt-4o-realtime-preview',
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
class RealtimeSessionsResource extends BaseResource {
  /// Creates a [RealtimeSessionsResource] with the given client.
  RealtimeSessionsResource(super.client);

  static const _sessionsEndpoint = '/realtime/sessions';
  static const _transcriptionEndpoint = '/realtime/transcription_sessions';
  static const _clientSecretsEndpoint = '/realtime/client_secrets';

  RealtimeCallsResource? _calls;

  /// Access to WebRTC call operations.
  RealtimeCallsResource get calls => _calls ??= RealtimeCallsResource(client);

  /// Creates a realtime session with an ephemeral API key.
  ///
  /// This endpoint creates a session configuration and returns an ephemeral
  /// client secret that can be used to authenticate WebSocket connections
  /// without exposing your main API key.
  ///
  /// ## Parameters
  ///
  /// - [request] - The session creation request parameters.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
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
  ///     model: 'gpt-4o-realtime-preview',
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
    final json = await postJson(
      _sessionsEndpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return RealtimeSessionCreateResponse.fromJson(json);
  }

  /// Creates a realtime transcription session.
  ///
  /// Transcription sessions are optimized for audio-to-text scenarios
  /// without generating audio responses.
  ///
  /// ## Parameters
  ///
  /// - [request] - The transcription session creation request.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
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
    final json = await postJson(
      _transcriptionEndpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return RealtimeTranscriptionSessionCreateResponse.fromJson(json);
  }

  /// Creates a client secret with custom configuration.
  ///
  /// This endpoint creates an ephemeral client secret with custom
  /// expiration settings and session configuration.
  ///
  /// ## Parameters
  ///
  /// - [request] - The client secret creation request.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
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
  ///       model: 'gpt-4o-realtime-preview',
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
    final json = await postJson(
      _clientSecretsEndpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return RealtimeClientSecretCreateResponse.fromJson(json);
  }
}

/// Resource for Realtime WebRTC call operations.
///
/// Provides access to WebRTC call management including creating,
/// accepting, hanging up, and transferring calls.
class RealtimeCallsResource extends BaseResource {
  /// Creates a [RealtimeCallsResource] with the given client.
  RealtimeCallsResource(super.client);

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
  /// - [abortTrigger] - Optional future that cancels the request when completed.
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
  ///       model: 'gpt-4o-realtime-preview',
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
    // Create multipart request with properly normalized URL
    final url = client.buildUrl(_callsEndpoint);
    final multipartRequest = http.MultipartRequest('POST', url);

    // Add SDP as a field
    multipartRequest.fields['sdp'] = request.sdp;

    // Add session as a field if provided
    if (request.session != null) {
      // Convert session to JSON string for multipart field
      multipartRequest.fields['session'] = _encodeSession(request.session!);
    }

    final response = await client.postMultipart(
      request: multipartRequest,
      abortTrigger: abortTrigger,
    );

    return response.body;
  }

  /// Accepts an incoming SIP call.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to accept.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  Future<void> accept(String callId, {Future<void>? abortTrigger}) async {
    await postJson(
      '$_callsEndpoint/$callId/accept',
      body: <String, dynamic>{},
      abortTrigger: abortTrigger,
    );
  }

  /// Hangs up an active call.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to hang up.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  Future<void> hangup(String callId, {Future<void>? abortTrigger}) async {
    await postJson(
      '$_callsEndpoint/$callId/hangup',
      body: <String, dynamic>{},
      abortTrigger: abortTrigger,
    );
  }

  /// Transfers a call to another destination.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to transfer.
  /// - [request] - The transfer request with target URI.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
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
    await postJson(
      '$_callsEndpoint/$callId/refer',
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
  }

  /// Rejects an incoming SIP call.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The ID of the call to reject.
  /// - [request] - Optional rejection request with status code.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await client.realtimeSessions.calls.reject(
  ///   callId,
  ///   RealtimeCallRejectRequest(statusCode: 486), // Busy Here
  /// );
  /// ```
  Future<void> reject(
    String callId, {
    RealtimeCallRejectRequest? request,
    Future<void>? abortTrigger,
  }) async {
    await postJson(
      '$_callsEndpoint/$callId/reject',
      body: request?.toJson() ?? <String, dynamic>{},
      abortTrigger: abortTrigger,
    );
  }

  String _encodeSession(RealtimeSessionCreateRequest session) {
    return jsonEncode(session.toJson());
  }
}
