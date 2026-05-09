import 'package:meta/meta.dart';

import 'realtime_session_create.dart';
import 'realtime_transcription_session.dart';

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
///       model: 'gpt-realtime-2',
///       audio: RealtimeAudioConfig(
///         output: RealtimeAudioConfigOutput(voice: 'alloy'),
///       ),
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
  ///
  /// The `/realtime/client_secrets` endpoint requires a `type` discriminator
  /// on the embedded session (`'realtime'` vs `'transcription'`). If the
  /// caller didn't set it explicitly, default it to `'realtime'` here so the
  /// bare `/realtime/sessions` payload (which rejects `type`) stays
  /// untouched.
  Map<String, dynamic> toJson() {
    final sessionJson = session.toJson();
    sessionJson['type'] ??= 'realtime';
    return {
      if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
      'session': sessionJson,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeClientSecretCreateRequest &&
          runtimeType == other.runtimeType &&
          expiresAfter == other.expiresAfter &&
          session == other.session;

  @override
  int get hashCode => Object.hash(expiresAfter, session);

  @override
  String toString() =>
      'RealtimeClientSecretCreateRequest(expiresAfter: $expiresAfter, '
      'session: $session)';
}

// =============================================================================
// RealtimeTranscriptionClientSecretCreateRequest
// =============================================================================

/// Request for creating a client secret for a **transcription** session.
///
/// Posts to `POST /realtime/client_secrets`. The session payload uses the
/// transcription-specific shape (no `model` field, audio limited to inputs).
/// Realtime sessions use [RealtimeClientSecretCreateRequest] instead.
@immutable
class RealtimeTranscriptionClientSecretCreateRequest {
  /// Creates a [RealtimeTranscriptionClientSecretCreateRequest].
  const RealtimeTranscriptionClientSecretCreateRequest({
    required this.session,
    this.expiresAfter,
  });

  /// Creates from JSON.
  factory RealtimeTranscriptionClientSecretCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['session'] == null) {
      throw const FormatException(
        'RealtimeTranscriptionClientSecretCreateRequest.fromJson missing '
        'required "session" field',
      );
    }
    return RealtimeTranscriptionClientSecretCreateRequest(
      session: RealtimeTranscriptionSessionCreateRequest.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      expiresAfter: json['expires_after'] != null
          ? ExpiresAfter.fromJson(json['expires_after'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Transcription session configuration.
  final RealtimeTranscriptionSessionCreateRequest session;

  /// Optional client-secret expiration.
  final ExpiresAfter? expiresAfter;

  /// Converts to JSON, injecting `'type': 'transcription'` on the embedded
  /// session if the caller didn't set it explicitly.
  Map<String, dynamic> toJson() {
    final sessionJson = session.toJson();
    sessionJson['type'] ??= 'transcription';
    return {
      if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
      'session': sessionJson,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranscriptionClientSecretCreateRequest &&
          runtimeType == other.runtimeType &&
          session == other.session &&
          expiresAfter == other.expiresAfter;

  @override
  int get hashCode => Object.hash(session, expiresAfter);

  @override
  String toString() =>
      'RealtimeTranscriptionClientSecretCreateRequest(session: $session, '
      'expiresAfter: $expiresAfter)';
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
          value == other.value &&
          expiresAt == other.expiresAt &&
          session == other.session;

  @override
  int get hashCode => Object.hash(value, expiresAt, session);

  @override
  String toString() =>
      'RealtimeClientSecretCreateResponse(expiresAt: $expiresAt, '
      'session: $session)';
}
