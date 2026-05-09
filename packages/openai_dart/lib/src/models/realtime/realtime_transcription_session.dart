import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'realtime_audio_config.dart';

// =============================================================================
// RealtimeTranscriptionSessionAudio
// =============================================================================

/// Audio configuration block for a transcription session.
///
/// Mirrors the Python SDK `realtime_transcription_session_audio` shape.
@immutable
class RealtimeTranscriptionSessionAudio {
  /// Creates a [RealtimeTranscriptionSessionAudio].
  const RealtimeTranscriptionSessionAudio({this.input});

  /// Creates from JSON.
  factory RealtimeTranscriptionSessionAudio.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeTranscriptionSessionAudio(
      input: json['input'] != null
          ? RealtimeAudioConfigInput.fromJson(
              json['input'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Input audio configuration. Transcription sessions only have inputs.
  final RealtimeAudioConfigInput? input;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (input != null) 'input': input!.toJson(),
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for [input] to clear the existing value.
  RealtimeTranscriptionSessionAudio copyWith({
    Object? input = unsetCopyWithValue,
  }) => RealtimeTranscriptionSessionAudio(
    input: identical(input, unsetCopyWithValue)
        ? this.input
        : input as RealtimeAudioConfigInput?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranscriptionSessionAudio &&
          runtimeType == other.runtimeType &&
          input == other.input;

  @override
  int get hashCode => input.hashCode;

  @override
  String toString() => 'RealtimeTranscriptionSessionAudio(input: $input)';
}

// =============================================================================
// RealtimeTranscriptionSessionCreateRequest
// =============================================================================

/// Request for creating a Realtime transcription session via HTTP.
///
/// Transcription sessions are optimized for audio-to-text scenarios without
/// generating audio responses.
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
///           transcription: InputAudioTranscription(model: 'whisper-1'),
///         ),
///       ),
///     ),
///   ),
/// );
/// ```
@immutable
class RealtimeTranscriptionSessionCreateRequest {
  /// Creates a [RealtimeTranscriptionSessionCreateRequest].
  ///
  /// [type] is the session-type discriminator (`'transcription'` for
  /// transcription sessions). Set this when the API needs to distinguish
  /// session types, e.g. when creating client secrets.
  const RealtimeTranscriptionSessionCreateRequest({
    this.type,
    this.audio,
    this.include,
  });

  /// Creates a [RealtimeTranscriptionSessionCreateRequest] from JSON.
  factory RealtimeTranscriptionSessionCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeTranscriptionSessionCreateRequest(
      type: json['type'] as String?,
      audio: json['audio'] != null
          ? RealtimeTranscriptionSessionAudio.fromJson(
              json['audio'] as Map<String, dynamic>,
            )
          : null,
      include: (json['include'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// The session type discriminator. Defaults to `'transcription'` on the
  /// wire if omitted.
  final String? type;

  /// Audio configuration.
  final RealtimeTranscriptionSessionAudio? audio;

  /// Additional fields to include in server outputs.
  final List<String>? include;

  /// Converts to JSON.
  ///
  /// `type` is only emitted when explicitly set. The bare
  /// `/realtime/transcription_sessions` endpoint rejects unknown parameters;
  /// the `/realtime/client_secrets` wrapper injects
  /// `'type': 'transcription'` itself when serializing the embedded session.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    if (audio != null) 'audio': audio!.toJson(),
    if (include != null) 'include': include,
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for any nullable field to clear the existing value.
  RealtimeTranscriptionSessionCreateRequest copyWith({
    Object? type = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
  }) => RealtimeTranscriptionSessionCreateRequest(
    type: identical(type, unsetCopyWithValue) ? this.type : type as String?,
    audio: identical(audio, unsetCopyWithValue)
        ? this.audio
        : audio as RealtimeTranscriptionSessionAudio?,
    include: identical(include, unsetCopyWithValue)
        ? this.include
        : include as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranscriptionSessionCreateRequest &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          audio == other.audio &&
          listsEqual(include, other.include);

  @override
  int get hashCode => Object.hash(type, audio, listHash(include));

  @override
  String toString() =>
      'RealtimeTranscriptionSessionCreateRequest(type: $type, audio: $audio, '
      'include: $include)';
}

// =============================================================================
// RealtimeTranscriptionSessionCreateResponse
// =============================================================================

/// Response from creating a Realtime transcription session.
///
/// Note: the response does not include `client_secret` on the inner session
/// object; callers must read the secret from the wrapper response of the
/// `/realtime/client_secrets` endpoint.
@immutable
class RealtimeTranscriptionSessionCreateResponse {
  /// Creates a [RealtimeTranscriptionSessionCreateResponse].
  const RealtimeTranscriptionSessionCreateResponse({
    required this.id,
    required this.object,
    required this.type,
    required this.expiresAt,
    this.audio,
    this.include,
  });

  /// Creates a [RealtimeTranscriptionSessionCreateResponse] from JSON.
  factory RealtimeTranscriptionSessionCreateResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['id'] == null ||
        json['object'] == null ||
        json['type'] == null ||
        json['expires_at'] == null) {
      throw const FormatException(
        'RealtimeTranscriptionSessionCreateResponse.fromJson missing one or more '
        'required fields (id, object, type, expires_at)',
      );
    }
    return RealtimeTranscriptionSessionCreateResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      type: json['type'] as String,
      expiresAt: json['expires_at'] as int,
      audio: json['audio'] != null
          ? RealtimeTranscriptionSessionAudio.fromJson(
              json['audio'] as Map<String, dynamic>,
            )
          : null,
      include: (json['include'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// The session identifier (`sess_…`).
  final String id;

  /// The object type (`'realtime.transcription_session'`).
  final String object;

  /// The session type (always `'transcription'`).
  final String type;

  /// Expiration timestamp (Unix epoch seconds).
  final int expiresAt;

  /// Audio configuration.
  final RealtimeTranscriptionSessionAudio? audio;

  /// Fields included in server outputs.
  final List<String>? include;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'type': type,
    'expires_at': expiresAt,
    if (audio != null) 'audio': audio!.toJson(),
    if (include != null) 'include': include,
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for any nullable field to clear the existing value.
  RealtimeTranscriptionSessionCreateResponse copyWith({
    String? id,
    String? object,
    String? type,
    int? expiresAt,
    Object? audio = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
  }) => RealtimeTranscriptionSessionCreateResponse(
    id: id ?? this.id,
    object: object ?? this.object,
    type: type ?? this.type,
    expiresAt: expiresAt ?? this.expiresAt,
    audio: identical(audio, unsetCopyWithValue)
        ? this.audio
        : audio as RealtimeTranscriptionSessionAudio?,
    include: identical(include, unsetCopyWithValue)
        ? this.include
        : include as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranscriptionSessionCreateResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          type == other.type &&
          expiresAt == other.expiresAt &&
          audio == other.audio &&
          listsEqual(include, other.include);

  @override
  int get hashCode =>
      Object.hash(id, object, type, expiresAt, audio, listHash(include));

  @override
  String toString() =>
      'RealtimeTranscriptionSessionCreateResponse(id: $id, expiresAt: $expiresAt, '
      'audio: $audio)';
}
