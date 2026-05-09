import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'realtime_translation_session.dart';

// =============================================================================
// RealtimeTranslationClientEvent (sealed)
// =============================================================================

/// A client → server event for a Realtime translation session.
///
/// Discriminated by `type`:
///
/// - [RealtimeTranslationSessionUpdateEvent] — `session.update`
/// - [RealtimeTranslationInputAudioBufferAppendEvent] — `session.input_audio_buffer.append`
/// - [RealtimeTranslationSessionCloseEvent] — `session.close`
///
/// Unknown discriminators are surfaced as
/// [UnknownRealtimeTranslationClientEvent], preserving the raw payload.
sealed class RealtimeTranslationClientEvent {
  const RealtimeTranslationClientEvent();

  /// Creates from JSON.
  factory RealtimeTranslationClientEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      'session.update' => RealtimeTranslationSessionUpdateEvent.fromJson(json),
      'session.input_audio_buffer.append' =>
        RealtimeTranslationInputAudioBufferAppendEvent.fromJson(json),
      'session.close' => RealtimeTranslationSessionCloseEvent.fromJson(json),
      _ => UnknownRealtimeTranslationClientEvent(
        Map<String, dynamic>.from(json),
      ),
    };
  }

  /// The discriminator value.
  String get type;

  /// Optional client-generated event id.
  String? get eventId;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Send to update the translation session configuration.
@immutable
class RealtimeTranslationSessionUpdateEvent
    extends RealtimeTranslationClientEvent {
  /// Creates a [RealtimeTranslationSessionUpdateEvent].
  const RealtimeTranslationSessionUpdateEvent({
    required this.session,
    this.eventId,
  });

  /// Creates from JSON.
  factory RealtimeTranslationSessionUpdateEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.update') {
      throw FormatException(
        'RealtimeTranslationSessionUpdateEvent.fromJson expected type '
        '"session.update", got ${json['type']}',
      );
    }
    if (json['session'] == null) {
      throw const FormatException(
        'RealtimeTranslationSessionUpdateEvent.fromJson missing required '
        '"session" field',
      );
    }
    return RealtimeTranslationSessionUpdateEvent(
      session: RealtimeTranslationSessionUpdateRequest.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      eventId: json['event_id'] as String?,
    );
  }

  /// Translation session fields to update. The session `type` and `model` are
  /// set at creation and cannot be changed via `session.update`.
  final RealtimeTranslationSessionUpdateRequest session;

  @override
  final String? eventId;

  @override
  String get type => 'session.update';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'session': session.toJson(),
    if (eventId != null) 'event_id': eventId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionUpdateEvent &&
          runtimeType == other.runtimeType &&
          session == other.session &&
          eventId == other.eventId;

  @override
  int get hashCode => Object.hash(session, eventId);

  @override
  String toString() =>
      'RealtimeTranslationSessionUpdateEvent(eventId: $eventId, session: $session)';
}

/// Append base64-encoded audio bytes to the translation input buffer.
///
/// WebSocket translation sessions accept base64-encoded 24 kHz PCM16 mono
/// little-endian raw audio bytes. Note: this base64 is the **raw audio bytes
/// from the client**, *not* a request-factory data URL — the OpenAI-specific
/// `data:<mediaType>;base64,<data>` rule does not apply.
@immutable
class RealtimeTranslationInputAudioBufferAppendEvent
    extends RealtimeTranslationClientEvent {
  /// Creates a [RealtimeTranslationInputAudioBufferAppendEvent].
  const RealtimeTranslationInputAudioBufferAppendEvent({
    required this.audio,
    this.eventId,
  });

  /// Creates from JSON.
  factory RealtimeTranslationInputAudioBufferAppendEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.input_audio_buffer.append') {
      throw FormatException(
        'RealtimeTranslationInputAudioBufferAppendEvent.fromJson expected type '
        '"session.input_audio_buffer.append", got ${json['type']}',
      );
    }
    if (json['audio'] == null) {
      throw const FormatException(
        'RealtimeTranslationInputAudioBufferAppendEvent.fromJson missing '
        'required "audio" field',
      );
    }
    return RealtimeTranslationInputAudioBufferAppendEvent(
      audio: json['audio'] as String,
      eventId: json['event_id'] as String?,
    );
  }

  /// Base64-encoded 24 kHz PCM16 mono raw audio bytes.
  final String audio;

  @override
  final String? eventId;

  @override
  String get type => 'session.input_audio_buffer.append';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'audio': audio,
    if (eventId != null) 'event_id': eventId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationInputAudioBufferAppendEvent &&
          runtimeType == other.runtimeType &&
          audio == other.audio &&
          eventId == other.eventId;

  @override
  int get hashCode => Object.hash(audio, eventId);

  @override
  String toString() =>
      'RealtimeTranslationInputAudioBufferAppendEvent(eventId: $eventId, '
      'audio: <${audio.length} chars>)';
}

/// Gracefully close a translation session.
@immutable
class RealtimeTranslationSessionCloseEvent
    extends RealtimeTranslationClientEvent {
  /// Creates a [RealtimeTranslationSessionCloseEvent].
  const RealtimeTranslationSessionCloseEvent({this.eventId});

  /// Creates from JSON.
  factory RealtimeTranslationSessionCloseEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.close') {
      throw FormatException(
        'RealtimeTranslationSessionCloseEvent.fromJson expected type '
        '"session.close", got ${json['type']}',
      );
    }
    return RealtimeTranslationSessionCloseEvent(
      eventId: json['event_id'] as String?,
    );
  }

  @override
  final String? eventId;

  @override
  String get type => 'session.close';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (eventId != null) 'event_id': eventId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionCloseEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'RealtimeTranslationSessionCloseEvent(eventId: $eventId)';
}

/// Forward-compatible fallback for unknown translation client events.
@immutable
class UnknownRealtimeTranslationClientEvent
    extends RealtimeTranslationClientEvent {
  /// Creates from raw JSON.
  const UnknownRealtimeTranslationClientEvent(this.json);

  /// The raw JSON map preserved verbatim.
  final Map<String, dynamic> json;

  @override
  String get type => json['type'] as String? ?? '';

  @override
  String? get eventId => json['event_id'] as String?;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRealtimeTranslationClientEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(json, other.json);

  @override
  int get hashCode => mapDeepHashCode(json);

  @override
  String toString() => 'UnknownRealtimeTranslationClientEvent(type: $type)';
}

// =============================================================================
// RealtimeTranslationServerEvent (sealed)
// =============================================================================

/// A server → client event for a Realtime translation session.
///
/// Discriminated by `type`:
///
/// - [RealtimeTranslationErrorEvent] — `error` (shared with the regular
///   Realtime API)
/// - [RealtimeTranslationSessionCreatedEvent] — `session.created`
/// - [RealtimeTranslationSessionUpdatedEvent] — `session.updated`
/// - [RealtimeTranslationSessionClosedEvent] — `session.closed`
/// - [RealtimeTranslationInputTranscriptDeltaEvent] —
///   `session.input_transcript.delta`
/// - [RealtimeTranslationOutputTranscriptDeltaEvent] —
///   `session.output_transcript.delta`
/// - [RealtimeTranslationOutputAudioDeltaEvent] —
///   `session.output_audio.delta`
///
/// Unknown discriminators are surfaced as
/// [UnknownRealtimeTranslationServerEvent], preserving the raw payload.
sealed class RealtimeTranslationServerEvent {
  const RealtimeTranslationServerEvent();

  /// Creates from JSON.
  factory RealtimeTranslationServerEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      'error' => RealtimeTranslationErrorEvent.fromJson(json),
      'session.created' => RealtimeTranslationSessionCreatedEvent.fromJson(
        json,
      ),
      'session.updated' => RealtimeTranslationSessionUpdatedEvent.fromJson(
        json,
      ),
      'session.closed' => RealtimeTranslationSessionClosedEvent.fromJson(json),
      'session.input_transcript.delta' =>
        RealtimeTranslationInputTranscriptDeltaEvent.fromJson(json),
      'session.output_transcript.delta' =>
        RealtimeTranslationOutputTranscriptDeltaEvent.fromJson(json),
      'session.output_audio.delta' =>
        RealtimeTranslationOutputAudioDeltaEvent.fromJson(json),
      _ => UnknownRealtimeTranslationServerEvent(
        Map<String, dynamic>.from(json),
      ),
    };
  }

  /// The discriminator value.
  String get type;

  /// The server-generated event id.
  String get eventId;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

// -----------------------------------------------------------------------------
// RealtimeTranslationError
// -----------------------------------------------------------------------------

/// The `error` payload nested inside [RealtimeTranslationErrorEvent].
@immutable
class RealtimeTranslationError {
  /// Creates a [RealtimeTranslationError].
  const RealtimeTranslationError({
    required this.type,
    required this.message,
    this.code,
    this.eventId,
    this.param,
  });

  /// Creates from JSON.
  factory RealtimeTranslationError.fromJson(Map<String, dynamic> json) {
    return RealtimeTranslationError(
      type: json['type'] as String,
      message: json['message'] as String,
      code: json['code'] as String?,
      eventId: json['event_id'] as String?,
      param: json['param'] as String?,
    );
  }

  /// Error category (e.g. `'invalid_request_error'`, `'server_error'`).
  final String type;

  /// Human-readable error message.
  final String message;

  /// Optional machine-readable error code.
  final String? code;

  /// Optional event id of the originating client event.
  final String? eventId;

  /// Optional related parameter name.
  final String? param;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    if (code != null) 'code': code,
    if (eventId != null) 'event_id': eventId,
    if (param != null) 'param': param,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          code == other.code &&
          eventId == other.eventId &&
          param == other.param;

  @override
  int get hashCode => Object.hash(type, message, code, eventId, param);

  @override
  String toString() =>
      'RealtimeTranslationError(type: $type, message: $message)';
}

/// Returned when an error occurs in a translation session.
@immutable
class RealtimeTranslationErrorEvent extends RealtimeTranslationServerEvent {
  /// Creates a [RealtimeTranslationErrorEvent].
  const RealtimeTranslationErrorEvent({
    required this.eventId,
    required this.error,
  });

  /// Creates from JSON.
  factory RealtimeTranslationErrorEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'error') {
      throw FormatException(
        'RealtimeTranslationErrorEvent.fromJson expected type "error", got '
        '${json['type']}',
      );
    }
    return RealtimeTranslationErrorEvent(
      eventId: json['event_id'] as String,
      error: RealtimeTranslationError.fromJson(
        json['error'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  final String eventId;

  /// Error payload.
  final RealtimeTranslationError error;

  @override
  String get type => 'error';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'error': error.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationErrorEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          error == other.error;

  @override
  int get hashCode => Object.hash(eventId, error);

  @override
  String toString() =>
      'RealtimeTranslationErrorEvent(eventId: $eventId, error: $error)';
}

// -----------------------------------------------------------------------------
// session.created / session.updated / session.closed
// -----------------------------------------------------------------------------

/// Returned when a translation session is created.
@immutable
class RealtimeTranslationSessionCreatedEvent
    extends RealtimeTranslationServerEvent {
  /// Creates a [RealtimeTranslationSessionCreatedEvent].
  const RealtimeTranslationSessionCreatedEvent({
    required this.eventId,
    required this.session,
  });

  /// Creates from JSON.
  factory RealtimeTranslationSessionCreatedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.created') {
      throw FormatException(
        'RealtimeTranslationSessionCreatedEvent.fromJson expected type '
        '"session.created", got ${json['type']}',
      );
    }
    return RealtimeTranslationSessionCreatedEvent(
      eventId: json['event_id'] as String,
      session: RealtimeTranslationSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  final String eventId;

  /// The created translation session.
  final RealtimeTranslationSession session;

  @override
  String get type => 'session.created';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'session': session.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionCreatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          session == other.session;

  @override
  int get hashCode => Object.hash(eventId, session);

  @override
  String toString() =>
      'RealtimeTranslationSessionCreatedEvent(eventId: $eventId, session: $session)';
}

/// Returned when a translation session is updated.
@immutable
class RealtimeTranslationSessionUpdatedEvent
    extends RealtimeTranslationServerEvent {
  /// Creates a [RealtimeTranslationSessionUpdatedEvent].
  const RealtimeTranslationSessionUpdatedEvent({
    required this.eventId,
    required this.session,
  });

  /// Creates from JSON.
  factory RealtimeTranslationSessionUpdatedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.updated') {
      throw FormatException(
        'RealtimeTranslationSessionUpdatedEvent.fromJson expected type '
        '"session.updated", got ${json['type']}',
      );
    }
    return RealtimeTranslationSessionUpdatedEvent(
      eventId: json['event_id'] as String,
      session: RealtimeTranslationSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  final String eventId;

  /// The updated translation session.
  final RealtimeTranslationSession session;

  @override
  String get type => 'session.updated';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'session': session.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionUpdatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          session == other.session;

  @override
  int get hashCode => Object.hash(eventId, session);

  @override
  String toString() =>
      'RealtimeTranslationSessionUpdatedEvent(eventId: $eventId, session: $session)';
}

/// Returned when a translation session is closed.
@immutable
class RealtimeTranslationSessionClosedEvent
    extends RealtimeTranslationServerEvent {
  /// Creates a [RealtimeTranslationSessionClosedEvent].
  const RealtimeTranslationSessionClosedEvent({required this.eventId});

  /// Creates from JSON.
  factory RealtimeTranslationSessionClosedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.closed') {
      throw FormatException(
        'RealtimeTranslationSessionClosedEvent.fromJson expected type '
        '"session.closed", got ${json['type']}',
      );
    }
    return RealtimeTranslationSessionClosedEvent(
      eventId: json['event_id'] as String,
    );
  }

  @override
  final String eventId;

  @override
  String get type => 'session.closed';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'event_id': eventId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationSessionClosedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'RealtimeTranslationSessionClosedEvent(eventId: $eventId)';
}

// -----------------------------------------------------------------------------
// transcript / audio deltas
// -----------------------------------------------------------------------------

/// Source-language transcript delta.
@immutable
class RealtimeTranslationInputTranscriptDeltaEvent
    extends RealtimeTranslationServerEvent {
  /// Creates a [RealtimeTranslationInputTranscriptDeltaEvent].
  const RealtimeTranslationInputTranscriptDeltaEvent({
    required this.eventId,
    required this.delta,
    this.elapsedMs,
  });

  /// Creates from JSON.
  factory RealtimeTranslationInputTranscriptDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.input_transcript.delta') {
      throw FormatException(
        'RealtimeTranslationInputTranscriptDeltaEvent.fromJson expected type '
        '"session.input_transcript.delta", got ${json['type']}',
      );
    }
    return RealtimeTranslationInputTranscriptDeltaEvent(
      eventId: json['event_id'] as String,
      delta: json['delta'] as String,
      elapsedMs: json['elapsed_ms'] as int?,
    );
  }

  @override
  final String eventId;

  /// Append-only source-language transcript fragment.
  final String delta;

  /// Optional alignment-frame timing in 200 ms increments.
  final int? elapsedMs;

  @override
  String get type => 'session.input_transcript.delta';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'delta': delta,
    if (elapsedMs != null) 'elapsed_ms': elapsedMs,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationInputTranscriptDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          delta == other.delta &&
          elapsedMs == other.elapsedMs;

  @override
  int get hashCode => Object.hash(eventId, delta, elapsedMs);

  @override
  String toString() =>
      'RealtimeTranslationInputTranscriptDeltaEvent(eventId: $eventId, '
      'delta: $delta, elapsedMs: $elapsedMs)';
}

/// Translated transcript delta.
@immutable
class RealtimeTranslationOutputTranscriptDeltaEvent
    extends RealtimeTranslationServerEvent {
  /// Creates a [RealtimeTranslationOutputTranscriptDeltaEvent].
  const RealtimeTranslationOutputTranscriptDeltaEvent({
    required this.eventId,
    required this.delta,
    this.elapsedMs,
  });

  /// Creates from JSON.
  factory RealtimeTranslationOutputTranscriptDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.output_transcript.delta') {
      throw FormatException(
        'RealtimeTranslationOutputTranscriptDeltaEvent.fromJson expected type '
        '"session.output_transcript.delta", got ${json['type']}',
      );
    }
    return RealtimeTranslationOutputTranscriptDeltaEvent(
      eventId: json['event_id'] as String,
      delta: json['delta'] as String,
      elapsedMs: json['elapsed_ms'] as int?,
    );
  }

  @override
  final String eventId;

  /// Append-only translated transcript fragment.
  final String delta;

  /// Optional alignment-frame timing in 200 ms increments.
  final int? elapsedMs;

  @override
  String get type => 'session.output_transcript.delta';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'delta': delta,
    if (elapsedMs != null) 'elapsed_ms': elapsedMs,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationOutputTranscriptDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          delta == other.delta &&
          elapsedMs == other.elapsedMs;

  @override
  int get hashCode => Object.hash(eventId, delta, elapsedMs);

  @override
  String toString() =>
      'RealtimeTranslationOutputTranscriptDeltaEvent(eventId: $eventId, '
      'delta: $delta, elapsedMs: $elapsedMs)';
}

/// Translated output-audio delta (200 ms PCM16 frames).
///
/// `delta` is a base64-encoded **server-emitted** audio fragment. This is not
/// a request-factory base64 input, so the OpenAI-specific data-URL convention
/// does not apply here.
@immutable
class RealtimeTranslationOutputAudioDeltaEvent
    extends RealtimeTranslationServerEvent {
  /// Creates a [RealtimeTranslationOutputAudioDeltaEvent].
  const RealtimeTranslationOutputAudioDeltaEvent({
    required this.eventId,
    required this.delta,
    this.format,
    this.sampleRate,
    this.channels,
    this.elapsedMs,
  });

  /// Creates from JSON.
  factory RealtimeTranslationOutputAudioDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'session.output_audio.delta') {
      throw FormatException(
        'RealtimeTranslationOutputAudioDeltaEvent.fromJson expected type '
        '"session.output_audio.delta", got ${json['type']}',
      );
    }
    return RealtimeTranslationOutputAudioDeltaEvent(
      eventId: json['event_id'] as String,
      delta: json['delta'] as String,
      format: json['format'] as String?,
      sampleRate: json['sample_rate'] as int?,
      channels: json['channels'] as int?,
      elapsedMs: json['elapsed_ms'] as int?,
    );
  }

  @override
  final String eventId;

  /// Base64-encoded translated audio data (server-emitted PCM16).
  final String delta;

  /// Audio encoding for [delta]. Currently always `'pcm16'`.
  final String? format;

  /// Sample rate of the audio delta. Defaults to 24000.
  final int? sampleRate;

  /// Number of audio channels. Defaults to 1.
  final int? channels;

  /// Optional alignment-frame timing.
  final int? elapsedMs;

  @override
  String get type => 'session.output_audio.delta';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'delta': delta,
    if (format != null) 'format': format,
    if (sampleRate != null) 'sample_rate': sampleRate,
    if (channels != null) 'channels': channels,
    if (elapsedMs != null) 'elapsed_ms': elapsedMs,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranslationOutputAudioDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          delta == other.delta &&
          format == other.format &&
          sampleRate == other.sampleRate &&
          channels == other.channels &&
          elapsedMs == other.elapsedMs;

  @override
  int get hashCode =>
      Object.hash(eventId, delta, format, sampleRate, channels, elapsedMs);

  @override
  String toString() =>
      'RealtimeTranslationOutputAudioDeltaEvent(eventId: $eventId, '
      'delta: <${delta.length} chars>, sampleRate: $sampleRate, channels: $channels)';
}

/// Forward-compatible fallback for unknown translation server events.
@immutable
class UnknownRealtimeTranslationServerEvent
    extends RealtimeTranslationServerEvent {
  /// Creates from raw JSON.
  const UnknownRealtimeTranslationServerEvent(this.json);

  /// The raw JSON map preserved verbatim.
  final Map<String, dynamic> json;

  @override
  String get type => json['type'] as String? ?? '';

  @override
  String get eventId => (json['event_id'] as String?) ?? '';

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRealtimeTranslationServerEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(json, other.json);

  @override
  int get hashCode => mapDeepHashCode(json);

  @override
  String toString() => 'UnknownRealtimeTranslationServerEvent(type: $type)';
}
