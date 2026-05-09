import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'realtime_audio_config.dart';
import 'realtime_client_secret.dart' show ExpiresAfter;
import 'realtime_enums.dart';

// =============================================================================
// RealtimeTranslationInputTranscription
// =============================================================================

/// Optional source-language transcription for a translation session.
///
/// When configured, the server emits `session.input_transcript.delta` events.
/// Translation itself still runs from the input audio stream regardless.
@immutable
class RealtimeTranslationInputTranscription {
  /// Creates a [RealtimeTranslationInputTranscription].
  const RealtimeTranslationInputTranscription({required this.model});

  /// Creates from JSON.
  factory RealtimeTranslationInputTranscription.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['model'] == null) {
      throw const FormatException(
        'RealtimeTranslationInputTranscription.fromJson missing required "model" field',
      );
    }
    return RealtimeTranslationInputTranscription(
      model: json['model'] as String,
    );
  }

  /// Transcription model id (e.g. `'gpt-realtime-whisper'`).
  final String model;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'model': model};

  /// Returns a copy with the given fields replaced.
  RealtimeTranslationInputTranscription copyWith({String? model}) =>
      RealtimeTranslationInputTranscription(model: model ?? this.model);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationInputTranscription &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'RealtimeTranslationInputTranscription(model: $model)';
}

// =============================================================================
// RealtimeTranslationNoiseReduction
// =============================================================================

/// Noise reduction configuration for a translation session.
///
/// Distinct from [AudioInputNoiseReduction]: the spec requires `type` and the
/// field can be set to `null` on the wrapper to disable filtering.
@immutable
class RealtimeTranslationNoiseReduction {
  /// Creates a [RealtimeTranslationNoiseReduction].
  const RealtimeTranslationNoiseReduction({required this.type});

  /// Creates from JSON.
  factory RealtimeTranslationNoiseReduction.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] == null) {
      throw const FormatException(
        'RealtimeTranslationNoiseReduction.fromJson missing required "type" field',
      );
    }
    return RealtimeTranslationNoiseReduction(
      type: NoiseReductionType.fromJson(json['type'] as String),
    );
  }

  /// The noise-reduction profile.
  final NoiseReductionType type;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type.toJson()};

  /// Returns a copy with the given fields replaced.
  RealtimeTranslationNoiseReduction copyWith({NoiseReductionType? type}) =>
      RealtimeTranslationNoiseReduction(type: type ?? this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationNoiseReduction &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'RealtimeTranslationNoiseReduction(type: $type)';
}

// =============================================================================
// RealtimeTranslationSessionAudioInput
// =============================================================================

/// Input audio configuration for a translation session.
///
/// **Tri-state serialization for `transcription` and `noise_reduction`** —
/// translation `session.update` events use the same convention as
/// realtime sessions:
///
/// - **Field omitted** → server keeps the current value (don't change).
/// - **Field with value** → server sets/replaces the configuration.
/// - **Field with explicit JSON `null`** → server *disables* the feature.
///
/// To send the third form, pass [clearTranscription] / [clearNoiseReduction]
/// as `true`. The flags are ignored when the corresponding typed field is
/// non-null. Roundtrip preserves the distinction.
@immutable
class RealtimeTranslationSessionAudioInput {
  /// Creates a [RealtimeTranslationSessionAudioInput].
  const RealtimeTranslationSessionAudioInput({
    this.transcription,
    this.noiseReduction,
    this.clearTranscription = false,
    this.clearNoiseReduction = false,
  });

  /// Creates from JSON.
  factory RealtimeTranslationSessionAudioInput.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeTranslationSessionAudioInput(
      transcription: json['transcription'] != null
          ? RealtimeTranslationInputTranscription.fromJson(
              json['transcription'] as Map<String, dynamic>,
            )
          : null,
      noiseReduction: json['noise_reduction'] != null
          ? RealtimeTranslationNoiseReduction.fromJson(
              json['noise_reduction'] as Map<String, dynamic>,
            )
          : null,
      clearTranscription:
          json.containsKey('transcription') && json['transcription'] == null,
      clearNoiseReduction:
          json.containsKey('noise_reduction') &&
          json['noise_reduction'] == null,
    );
  }

  /// Source-language transcription configuration.
  final RealtimeTranslationInputTranscription? transcription;

  /// Noise reduction configuration.
  final RealtimeTranslationNoiseReduction? noiseReduction;

  /// When `true`, emit `"transcription": null` on the wire to ask the
  /// server to disable transcription. Has no effect when [transcription]
  /// is non-null.
  final bool clearTranscription;

  /// When `true`, emit `"noise_reduction": null` on the wire to ask the
  /// server to disable noise reduction. Has no effect when
  /// [noiseReduction] is non-null.
  final bool clearNoiseReduction;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (transcription != null)
      'transcription': transcription!.toJson()
    else if (clearTranscription)
      'transcription': null,
    if (noiseReduction != null)
      'noise_reduction': noiseReduction!.toJson()
    else if (clearNoiseReduction)
      'noise_reduction': null,
  };

  /// Returns a copy of this with the given fields replaced.
  ///
  /// Pass `null` for any nullable field to clear the in-memory value
  /// (use the `clear*` flags to send explicit JSON null over the wire).
  RealtimeTranslationSessionAudioInput copyWith({
    Object? transcription = unsetCopyWithValue,
    Object? noiseReduction = unsetCopyWithValue,
    bool? clearTranscription,
    bool? clearNoiseReduction,
  }) => RealtimeTranslationSessionAudioInput(
    transcription: identical(transcription, unsetCopyWithValue)
        ? this.transcription
        : transcription as RealtimeTranslationInputTranscription?,
    noiseReduction: identical(noiseReduction, unsetCopyWithValue)
        ? this.noiseReduction
        : noiseReduction as RealtimeTranslationNoiseReduction?,
    clearTranscription: clearTranscription ?? this.clearTranscription,
    clearNoiseReduction: clearNoiseReduction ?? this.clearNoiseReduction,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionAudioInput &&
          runtimeType == other.runtimeType &&
          transcription == other.transcription &&
          noiseReduction == other.noiseReduction &&
          clearTranscription == other.clearTranscription &&
          clearNoiseReduction == other.clearNoiseReduction;

  @override
  int get hashCode => Object.hash(
    transcription,
    noiseReduction,
    clearTranscription,
    clearNoiseReduction,
  );

  @override
  String toString() =>
      'RealtimeTranslationSessionAudioInput(transcription: $transcription, '
      'noiseReduction: $noiseReduction, '
      'clearTranscription: $clearTranscription, '
      'clearNoiseReduction: $clearNoiseReduction)';
}

// =============================================================================
// RealtimeTranslationSessionAudioOutput
// =============================================================================

/// Output audio configuration for a translation session.
@immutable
class RealtimeTranslationSessionAudioOutput {
  /// Creates a [RealtimeTranslationSessionAudioOutput].
  const RealtimeTranslationSessionAudioOutput({this.language});

  /// Creates from JSON.
  factory RealtimeTranslationSessionAudioOutput.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeTranslationSessionAudioOutput(
      language: json['language'] as String?,
    );
  }

  /// Target language for translated output audio and transcript deltas.
  final String? language;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (language != null) 'language': language};

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for [language] to clear the existing value.
  RealtimeTranslationSessionAudioOutput copyWith({
    Object? language = unsetCopyWithValue,
  }) => RealtimeTranslationSessionAudioOutput(
    language: identical(language, unsetCopyWithValue)
        ? this.language
        : language as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionAudioOutput &&
          runtimeType == other.runtimeType &&
          language == other.language;

  @override
  int get hashCode => language.hashCode;

  @override
  String toString() =>
      'RealtimeTranslationSessionAudioOutput(language: $language)';
}

// =============================================================================
// RealtimeTranslationSessionAudio
// =============================================================================

/// Audio configuration block for a translation session.
@immutable
class RealtimeTranslationSessionAudio {
  /// Creates a [RealtimeTranslationSessionAudio].
  const RealtimeTranslationSessionAudio({this.input, this.output});

  /// Creates from JSON.
  factory RealtimeTranslationSessionAudio.fromJson(Map<String, dynamic> json) {
    return RealtimeTranslationSessionAudio(
      input: json['input'] != null
          ? RealtimeTranslationSessionAudioInput.fromJson(
              json['input'] as Map<String, dynamic>,
            )
          : null,
      output: json['output'] != null
          ? RealtimeTranslationSessionAudioOutput.fromJson(
              json['output'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Input audio configuration.
  final RealtimeTranslationSessionAudioInput? input;

  /// Output audio configuration.
  final RealtimeTranslationSessionAudioOutput? output;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (input != null) 'input': input!.toJson(),
    if (output != null) 'output': output!.toJson(),
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for any field to clear the existing value.
  RealtimeTranslationSessionAudio copyWith({
    Object? input = unsetCopyWithValue,
    Object? output = unsetCopyWithValue,
  }) => RealtimeTranslationSessionAudio(
    input: identical(input, unsetCopyWithValue)
        ? this.input
        : input as RealtimeTranslationSessionAudioInput?,
    output: identical(output, unsetCopyWithValue)
        ? this.output
        : output as RealtimeTranslationSessionAudioOutput?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionAudio &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          output == other.output;

  @override
  int get hashCode => Object.hash(input, output);

  @override
  String toString() =>
      'RealtimeTranslationSessionAudio(input: $input, output: $output)';
}

// =============================================================================
// RealtimeTranslationSession
// =============================================================================

/// A Realtime translation session.
///
/// Translation sessions continuously translate input audio into the configured
/// output language.
@immutable
class RealtimeTranslationSession {
  /// Creates a [RealtimeTranslationSession].
  const RealtimeTranslationSession({
    required this.id,
    required this.type,
    required this.expiresAt,
    required this.model,
    required this.audio,
  });

  /// Creates from JSON.
  factory RealtimeTranslationSession.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['type'] == null ||
        json['expires_at'] == null ||
        json['model'] == null ||
        json['audio'] == null) {
      throw const FormatException(
        'RealtimeTranslationSession.fromJson missing one or more required fields '
        '(id, type, expires_at, model, audio)',
      );
    }
    return RealtimeTranslationSession(
      id: json['id'] as String,
      type: json['type'] as String,
      expiresAt: json['expires_at'] as int,
      model: json['model'] as String,
      audio: RealtimeTranslationSessionAudio.fromJson(
        json['audio'] as Map<String, dynamic>,
      ),
    );
  }

  /// Unique session identifier (`sess_…`).
  final String id;

  /// The session type. Always `'translation'`.
  final String type;

  /// Expiration timestamp (Unix epoch seconds).
  final int expiresAt;

  /// The translation model used for this session.
  final String model;

  /// Audio configuration.
  final RealtimeTranslationSessionAudio audio;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'expires_at': expiresAt,
    'model': model,
    'audio': audio.toJson(),
  };

  /// Returns a copy with the given fields replaced.
  RealtimeTranslationSession copyWith({
    String? id,
    String? type,
    int? expiresAt,
    String? model,
    RealtimeTranslationSessionAudio? audio,
  }) => RealtimeTranslationSession(
    id: id ?? this.id,
    type: type ?? this.type,
    expiresAt: expiresAt ?? this.expiresAt,
    model: model ?? this.model,
    audio: audio ?? this.audio,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          expiresAt == other.expiresAt &&
          model == other.model &&
          audio == other.audio;

  @override
  int get hashCode => Object.hash(id, type, expiresAt, model, audio);

  @override
  String toString() =>
      'RealtimeTranslationSession(id: $id, model: $model, expiresAt: $expiresAt)';
}

// =============================================================================
// RealtimeTranslationSessionCreateRequest
// =============================================================================

/// Request payload for creating a translation session.
///
/// Streams source audio in and translated audio plus transcript deltas out
/// continuously.
@immutable
class RealtimeTranslationSessionCreateRequest {
  /// Creates a [RealtimeTranslationSessionCreateRequest].
  const RealtimeTranslationSessionCreateRequest({
    required this.model,
    this.audio,
  });

  /// Creates from JSON.
  factory RealtimeTranslationSessionCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['model'] == null) {
      throw const FormatException(
        'RealtimeTranslationSessionCreateRequest.fromJson missing required "model" field',
      );
    }
    return RealtimeTranslationSessionCreateRequest(
      model: json['model'] as String,
      audio: json['audio'] != null
          ? RealtimeTranslationSessionAudio.fromJson(
              json['audio'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The translation model id (e.g. `'gpt-realtime-translate'`).
  final String model;

  /// Optional audio configuration.
  final RealtimeTranslationSessionAudio? audio;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (audio != null) 'audio': audio!.toJson(),
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for [audio] to clear the existing value.
  RealtimeTranslationSessionCreateRequest copyWith({
    String? model,
    Object? audio = unsetCopyWithValue,
  }) => RealtimeTranslationSessionCreateRequest(
    model: model ?? this.model,
    audio: identical(audio, unsetCopyWithValue)
        ? this.audio
        : audio as RealtimeTranslationSessionAudio?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionCreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          audio == other.audio;

  @override
  int get hashCode => Object.hash(model, audio);

  @override
  String toString() =>
      'RealtimeTranslationSessionCreateRequest(model: $model, audio: $audio)';
}

// =============================================================================
// RealtimeTranslationSessionUpdateRequest
// =============================================================================

/// Update payload for a translation session (`session.update` event).
///
/// Translation sessions support updates to `audio.input.transcription`,
/// `audio.input.noise_reduction`, and `audio.output.language` only.
@immutable
class RealtimeTranslationSessionUpdateRequest {
  /// Creates a [RealtimeTranslationSessionUpdateRequest].
  const RealtimeTranslationSessionUpdateRequest({this.audio});

  /// Creates from JSON.
  factory RealtimeTranslationSessionUpdateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeTranslationSessionUpdateRequest(
      audio: json['audio'] != null
          ? RealtimeTranslationSessionAudio.fromJson(
              json['audio'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Audio configuration delta.
  final RealtimeTranslationSessionAudio? audio;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (audio != null) 'audio': audio!.toJson(),
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for [audio] to clear the existing value.
  RealtimeTranslationSessionUpdateRequest copyWith({
    Object? audio = unsetCopyWithValue,
  }) => RealtimeTranslationSessionUpdateRequest(
    audio: identical(audio, unsetCopyWithValue)
        ? this.audio
        : audio as RealtimeTranslationSessionAudio?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionUpdateRequest &&
          runtimeType == other.runtimeType &&
          audio == other.audio;

  @override
  int get hashCode => audio.hashCode;

  @override
  String toString() => 'RealtimeTranslationSessionUpdateRequest(audio: $audio)';
}

// =============================================================================
// RealtimeTranslationClientSecretCreateRequest
// =============================================================================

/// Request for creating a translation client secret.
///
/// Calls `POST /realtime/translations/client_secrets`.
///
/// ## Example
///
/// ```dart
/// final response = await client.realtimeSessions.translations
///     .createClientSecret(
///   RealtimeTranslationClientSecretCreateRequest(
///     session: RealtimeTranslationSessionCreateRequest(
///       model: 'gpt-realtime-translate',
///       audio: RealtimeTranslationSessionAudio(
///         output: RealtimeTranslationSessionAudioOutput(language: 'es'),
///       ),
///     ),
///   ),
/// );
/// ```
@immutable
class RealtimeTranslationClientSecretCreateRequest {
  /// Creates a [RealtimeTranslationClientSecretCreateRequest].
  const RealtimeTranslationClientSecretCreateRequest({
    required this.session,
    this.expiresAfter,
  });

  /// Creates from JSON.
  factory RealtimeTranslationClientSecretCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['session'] == null) {
      throw const FormatException(
        'RealtimeTranslationClientSecretCreateRequest.fromJson missing required "session" field',
      );
    }
    return RealtimeTranslationClientSecretCreateRequest(
      session: RealtimeTranslationSessionCreateRequest.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      expiresAfter: json['expires_after'] != null
          ? ExpiresAfter.fromJson(json['expires_after'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The translation session configuration.
  final RealtimeTranslationSessionCreateRequest session;

  /// Optional expiration configuration.
  final ExpiresAfter? expiresAfter;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'session': session.toJson(),
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for [expiresAfter] to clear the existing value.
  RealtimeTranslationClientSecretCreateRequest copyWith({
    RealtimeTranslationSessionCreateRequest? session,
    Object? expiresAfter = unsetCopyWithValue,
  }) => RealtimeTranslationClientSecretCreateRequest(
    session: session ?? this.session,
    expiresAfter: identical(expiresAfter, unsetCopyWithValue)
        ? this.expiresAfter
        : expiresAfter as ExpiresAfter?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationClientSecretCreateRequest &&
          runtimeType == other.runtimeType &&
          session == other.session &&
          expiresAfter == other.expiresAfter;

  @override
  int get hashCode => Object.hash(session, expiresAfter);

  @override
  String toString() =>
      'RealtimeTranslationClientSecretCreateRequest(session: $session, '
      'expiresAfter: $expiresAfter)';
}

// =============================================================================
// RealtimeTranslationClientSecretCreateResponse
// =============================================================================

/// Response from creating a translation client secret.
@immutable
class RealtimeTranslationClientSecretCreateResponse {
  /// Creates a [RealtimeTranslationClientSecretCreateResponse].
  const RealtimeTranslationClientSecretCreateResponse({
    required this.value,
    required this.expiresAt,
    required this.session,
  });

  /// Creates from JSON.
  factory RealtimeTranslationClientSecretCreateResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['value'] == null ||
        json['expires_at'] == null ||
        json['session'] == null) {
      throw const FormatException(
        'RealtimeTranslationClientSecretCreateResponse.fromJson missing one or '
        'more required fields (value, expires_at, session)',
      );
    }
    return RealtimeTranslationClientSecretCreateResponse(
      value: json['value'] as String,
      expiresAt: json['expires_at'] as int,
      session: RealtimeTranslationSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  /// The client secret value (starts with `ek_`).
  final String value;

  /// Expiration timestamp (Unix epoch seconds).
  final int expiresAt;

  /// The created translation session.
  final RealtimeTranslationSession session;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'value': value,
    'expires_at': expiresAt,
    'session': session.toJson(),
  };

  /// Returns a copy with the given fields replaced.
  RealtimeTranslationClientSecretCreateResponse copyWith({
    String? value,
    int? expiresAt,
    RealtimeTranslationSession? session,
  }) => RealtimeTranslationClientSecretCreateResponse(
    value: value ?? this.value,
    expiresAt: expiresAt ?? this.expiresAt,
    session: session ?? this.session,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationClientSecretCreateResponse &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          expiresAt == other.expiresAt &&
          session == other.session;

  @override
  int get hashCode => Object.hash(value, expiresAt, session);

  @override
  String toString() =>
      'RealtimeTranslationClientSecretCreateResponse(expiresAt: $expiresAt, '
      'session: $session)';
}
