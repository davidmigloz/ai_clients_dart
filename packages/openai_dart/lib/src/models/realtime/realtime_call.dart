import 'package:meta/meta.dart';

import 'realtime_session_create.dart';

// =============================================================================
// RealtimeCallCreateRequest
// =============================================================================

/// Request for creating a WebRTC call.
///
/// This endpoint initiates a WebRTC call with the Realtime API
/// using an SDP (Session Description Protocol) offer.
///
/// ## Example
///
/// ```dart
/// final sdpAnswer = await client.realtimeSessions.calls.create(
///   RealtimeCallCreateRequest(
///     sdp: sdpOffer,
///     session: RealtimeSessionCreateRequest(
///       model: 'gpt-realtime-1.5',
///       voice: RealtimeVoice.alloy,
///     ),
///   ),
/// );
///
/// // Use sdpAnswer to complete WebRTC handshake
/// ```
@immutable
class RealtimeCallCreateRequest {
  /// Creates a [RealtimeCallCreateRequest].
  const RealtimeCallCreateRequest({required this.sdp, this.session});

  /// Creates a [RealtimeCallCreateRequest] from JSON.
  factory RealtimeCallCreateRequest.fromJson(Map<String, dynamic> json) {
    return RealtimeCallCreateRequest(
      sdp: json['sdp'] as String,
      session: json['session'] != null
          ? RealtimeSessionCreateRequest.fromJson(
              json['session'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The SDP offer string.
  final String sdp;

  /// Optional session configuration.
  final RealtimeSessionCreateRequest? session;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'sdp': sdp,
    if (session != null) 'session': session!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeCallCreateRequest &&
          runtimeType == other.runtimeType &&
          sdp == other.sdp;

  @override
  int get hashCode => sdp.hashCode;

  @override
  String toString() => 'RealtimeCallCreateRequest(sdp: ${sdp.length} chars)';
}

// =============================================================================
// RealtimeCallReferRequest
// =============================================================================

/// Request for referring (transferring) a call.
///
/// This endpoint transfers an ongoing call to another destination,
/// typically a phone number for telephony integrations.
///
/// ## Example
///
/// ```dart
/// await client.realtimeSessions.calls.refer(
///   callId,
///   RealtimeCallReferRequest(targetUri: 'tel:+14155550123'),
/// );
/// ```
@immutable
class RealtimeCallReferRequest {
  /// Creates a [RealtimeCallReferRequest].
  const RealtimeCallReferRequest({required this.targetUri});

  /// Creates a [RealtimeCallReferRequest] from JSON.
  factory RealtimeCallReferRequest.fromJson(Map<String, dynamic> json) {
    return RealtimeCallReferRequest(targetUri: json['target_uri'] as String);
  }

  /// The target URI to transfer the call to (e.g., "tel:+14155550123").
  final String targetUri;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'target_uri': targetUri};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeCallReferRequest &&
          runtimeType == other.runtimeType &&
          targetUri == other.targetUri;

  @override
  int get hashCode => targetUri.hashCode;

  @override
  String toString() => 'RealtimeCallReferRequest(targetUri: $targetUri)';
}

// =============================================================================
// RealtimeCallRejectRequest
// =============================================================================

/// Request for rejecting an incoming call.
///
/// This endpoint rejects an incoming SIP call with an optional
/// status code indicating the rejection reason.
///
/// ## Example
///
/// ```dart
/// await client.realtimeSessions.calls.reject(
///   callId,
///   RealtimeCallRejectRequest(statusCode: 486), // Busy Here
/// );
/// ```
@immutable
class RealtimeCallRejectRequest {
  /// Creates a [RealtimeCallRejectRequest].
  const RealtimeCallRejectRequest({this.statusCode});

  /// Creates a [RealtimeCallRejectRequest] from JSON.
  factory RealtimeCallRejectRequest.fromJson(Map<String, dynamic> json) {
    return RealtimeCallRejectRequest(statusCode: json['status_code'] as int?);
  }

  /// The SIP status code for rejection (defaults to 603 - Decline).
  ///
  /// Common status codes:
  /// - 486: Busy Here
  /// - 603: Decline
  /// - 404: Not Found
  /// - 480: Temporarily Unavailable
  final int? statusCode;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (statusCode != null) 'status_code': statusCode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeCallRejectRequest &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode;

  @override
  int get hashCode => statusCode.hashCode;

  @override
  String toString() => 'RealtimeCallRejectRequest(statusCode: $statusCode)';
}
