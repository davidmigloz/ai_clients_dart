import 'package:meta/meta.dart';

import 'realtime_session_create.dart';

// =============================================================================
// ExpiresAfter
// =============================================================================

/// Configuration for when a client secret expires.
@immutable
class ExpiresAfter {
  /// Creates an [ExpiresAfter].
  const ExpiresAfter({this.anchor, required this.seconds});

  /// Creates an [ExpiresAfter] from JSON.
  factory ExpiresAfter.fromJson(Map<String, dynamic> json) {
    return ExpiresAfter(
      anchor: json['anchor'] as String?,
      seconds: json['seconds'] as int,
    );
  }

  /// The anchor point for expiration (e.g., "created_at").
  final String? anchor;

  /// Seconds until expiration (10-7200).
  final int seconds;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (anchor != null) 'anchor': anchor,
    'seconds': seconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpiresAfter &&
          runtimeType == other.runtimeType &&
          seconds == other.seconds;

  @override
  int get hashCode => seconds.hashCode;

  @override
  String toString() => 'ExpiresAfter(seconds: $seconds)';
}

// =============================================================================
// RealtimeClientSecretCreateRequest
// =============================================================================

/// Request for creating a client secret with session configuration.
///
/// This allows creating a client secret with custom expiration and
/// session configuration in a single API call.
///
/// ## Example
///
/// ```dart
/// final response = await client.realtimeSessions.createClientSecret(
///   RealtimeClientSecretCreateRequest(
///     expiresAfter: ExpiresAfter(anchor: 'created_at', seconds: 3600),
///     session: RealtimeSessionCreateRequest(
///       model: 'gpt-4o-realtime-preview',
///       voice: RealtimeVoice.alloy,
///     ),
///   ),
/// );
///
/// print('Secret expires at: ${response.expiresAt}');
/// ```
@immutable
class RealtimeClientSecretCreateRequest {
  /// Creates a [RealtimeClientSecretCreateRequest].
  const RealtimeClientSecretCreateRequest({
    this.expiresAfter,
    required this.session,
  });

  /// Creates a [RealtimeClientSecretCreateRequest] from JSON.
  factory RealtimeClientSecretCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeClientSecretCreateRequest(
      expiresAfter: json['expires_after'] != null
          ? ExpiresAfter.fromJson(json['expires_after'] as Map<String, dynamic>)
          : null,
      session: RealtimeSessionCreateRequest.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  /// Expiration configuration.
  final ExpiresAfter? expiresAfter;

  /// The session configuration.
  final RealtimeSessionCreateRequest session;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
    'session': session.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeClientSecretCreateRequest &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => session.hashCode;

  @override
  String toString() => 'RealtimeClientSecretCreateRequest(...)';
}

// =============================================================================
// RealtimeClientSecretCreateResponse
// =============================================================================

/// Response from creating a client secret.
@immutable
class RealtimeClientSecretCreateResponse {
  /// Creates a [RealtimeClientSecretCreateResponse].
  const RealtimeClientSecretCreateResponse({
    required this.value,
    required this.expiresAt,
    required this.session,
  });

  /// Creates a [RealtimeClientSecretCreateResponse] from JSON.
  factory RealtimeClientSecretCreateResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeClientSecretCreateResponse(
      value: json['value'] as String,
      expiresAt: json['expires_at'] as int,
      session: RealtimeSessionCreateResponse.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  /// The client secret value (starts with "ek_").
  final String value;

  /// Unix timestamp when the secret expires.
  final int expiresAt;

  /// The created session.
  final RealtimeSessionCreateResponse session;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'value': value,
    'expires_at': expiresAt,
    'session': session.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeClientSecretCreateResponse &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'RealtimeClientSecretCreateResponse(expiresAt: $expiresAt)';
}
