import 'live_config.dart';
import 'live_json_helpers.dart';

/// Complete Live events received on primary and trusted sideband connections.
///
/// Known variants are [LiveSessionStarted], [LiveSessionUpdated], [LiveInputAudioMuted], [LiveInputAudioUnmuted], [LiveInstructionsAppended], [LiveThinkingAppended], [LiveCommentaryAppended], [LiveInputAudioAppend], [LiveOutputAudioDelta], [LiveInputTranscriptDelta], [LiveOutputTranscriptDelta], [LiveDelegationCreated], [LiveResponseEvent], [LiveSessionUsageUpdated], [LiveSessionClosed], [LiveErrorEvent], [LiveInfoEvent], [LiveTransportDTMFReceived], [LiveTransportDTMFSend], [LiveTransportRinging], [LiveTransportAnswered], [LiveTransportFailed].
/// Future event types use [UnknownLiveServerEvent]; known malformed events fail.
sealed class LiveServerEvent extends LiveJsonModel {
  /// Creates a received Live event.
  const LiveServerEvent();

  /// Parses all 22 canonical variants, independently of narrower sideband aliases.
  static LiveServerEvent fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(json['type'], 'LiveServerEvent.type');
    return switch (type) {
      'session.started' => LiveSessionStarted.fromJson(json),
      'session.updated' => LiveSessionUpdated.fromJson(json),
      'session.input_audio.muted' => LiveInputAudioMuted.fromJson(json),
      'session.input_audio.unmuted' => LiveInputAudioUnmuted.fromJson(json),
      'session.instructions.appended' => LiveInstructionsAppended.fromJson(
        json,
      ),
      'session.thinking.appended' => LiveThinkingAppended.fromJson(json),
      'session.commentary.appended' => LiveCommentaryAppended.fromJson(json),
      'session.input_audio.append' => LiveInputAudioAppend.fromJson(json),
      'session.output_audio.delta' => LiveOutputAudioDelta.fromJson(json),
      'session.input_transcript.delta' => LiveInputTranscriptDelta.fromJson(
        json,
      ),
      'session.output_transcript.delta' => LiveOutputTranscriptDelta.fromJson(
        json,
      ),
      'session.delegation.created' => LiveDelegationCreated.fromJson(json),
      'response.event' => LiveResponseEvent.fromJson(json),
      'session.usage.updated' => LiveSessionUsageUpdated.fromJson(json),
      'session.closed' => LiveSessionClosed.fromJson(json),
      'error' => LiveErrorEvent.fromJson(json),
      'info' => LiveInfoEvent.fromJson(json),
      'transport.dtmf.received' => LiveTransportDTMFReceived.fromJson(json),
      'transport.dtmf.send' => LiveTransportDTMFSend.fromJson(json),
      'transport.ringing' => LiveTransportRinging.fromJson(json),
      'transport.answered' => LiveTransportAnswered.fromJson(json),
      'transport.failed' => LiveTransportFailed.fromJson(json),
      _ => UnknownLiveServerEvent.fromJson(json),
    };
  }

  /// The exact received event discriminator.
  String get type;

  /// Immutable original wire data, including finite future metadata.
  Map<String, dynamic> get rawJson;

  /// Optional server correlation; the two audio event contracts omit this field.
  String? get eventId {
    final value = toJson()['event_id'];
    return value is String ? value : null;
  }

  @override
  Map<String, dynamic> toJson();

  /// Checks channel-specific reflected audio contracts without altering wire data.
  ///
  /// Both channels accept every known event. Reflected sideband audio is raw
  /// mono PCM16LE at 24 kHz. Primary output uses its negotiated format and omits
  /// reflected timestamps; sideband output requires both timestamps. Audio bytes
  /// and timeline gaps remain caller-owned; codecs do not decode or reorder them.
  void validateForChannel(String channel) {
    validate();
    if (channel != 'primary' && channel != 'sideband') {
      throw const FormatException(
        'LiveServerEvent.channel: unsupported channel',
      );
    }
  }
}

const _knownServerEventTypes = <String>{
  'session.started',
  'session.updated',
  'session.input_audio.muted',
  'session.input_audio.unmuted',
  'session.instructions.appended',
  'session.thinking.appended',
  'session.commentary.appended',
  'session.input_audio.append',
  'session.output_audio.delta',
  'session.input_transcript.delta',
  'session.output_transcript.delta',
  'session.delegation.created',
  'response.event',
  'session.usage.updated',
  'session.closed',
  'error',
  'info',
  'transport.dtmf.received',
  'transport.dtmf.send',
  'transport.ringing',
  'transport.answered',
  'transport.failed',
};

/// Returned when a Live session has started. Contains the resolved session configuration, including server defaults.
final class LiveSessionStarted extends LiveServerEvent {
  /// Creates LiveSessionStarted with canonical received fields.
  LiveSessionStarted({
    Object? clientEventId = liveUnset,
    required this.eventId,
    required this.session,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveSessionStarted.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionStarted',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'event_id',
    'session',
    'type',
  };

  @override
  String get type => 'session.started';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// Canonical received field.
  final LiveSessionResourceParam session;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionStarted; wrong or missing known fields fail safely.
  factory LiveSessionStarted.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.started', 'LiveSessionStarted', key: 'type');
    return LiveSessionStarted(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveSessionStarted.client_event_id',
            )
          : liveUnset,
      eventId: requireLiveString(
        json['event_id'],
        'LiveSessionStarted.event_id',
      ),
      session: _serverModel(
        json['session'],
        'LiveSessionStarted.session',
        LiveSessionResourceParam.fromJson,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'event_id': eventId,
    'session': session.toJson(),
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveSessionStarted copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? eventId = liveUnset,
    Object? session = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveSessionStarted(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveSessionStarted.event_id'),
    session: identical(session, liveUnset)
        ? this.session
        : _serverRequired<LiveSessionResourceParam>(
            session,
            'LiveSessionStarted.session',
          ),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveSessionStarted.rawJson'),
  );
}

/// Returned when a Live session update is accepted. Contains the resolved session configuration after the update.
final class LiveSessionUpdated extends LiveServerEvent {
  /// Creates LiveSessionUpdated with canonical received fields.
  LiveSessionUpdated({
    Object? clientEventId = liveUnset,
    required this.eventId,
    required this.session,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveSessionUpdated.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionUpdated',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'event_id',
    'session',
    'type',
  };

  @override
  String get type => 'session.updated';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// Canonical received field.
  final LiveSessionResourceParam session;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionUpdated; wrong or missing known fields fail safely.
  factory LiveSessionUpdated.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.updated', 'LiveSessionUpdated', key: 'type');
    return LiveSessionUpdated(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveSessionUpdated.client_event_id',
            )
          : liveUnset,
      eventId: requireLiveString(
        json['event_id'],
        'LiveSessionUpdated.event_id',
      ),
      session: _serverModel(
        json['session'],
        'LiveSessionUpdated.session',
        LiveSessionResourceParam.fromJson,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'event_id': eventId,
    'session': session.toJson(),
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveSessionUpdated copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? eventId = liveUnset,
    Object? session = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveSessionUpdated(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveSessionUpdated.event_id'),
    session: identical(session, liveUnset)
        ? this.session
        : _serverRequired<LiveSessionResourceParam>(
            session,
            'LiveSessionUpdated.session',
          ),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveSessionUpdated.rawJson'),
  );
}

/// Returned when a session.input_audio.mute command is accepted. Input audio is no longer sent to the model; sideband audio reflection continues.
final class LiveInputAudioMuted extends LiveServerEvent {
  /// Creates LiveInputAudioMuted with canonical received fields.
  LiveInputAudioMuted({
    Object? clientEventId = liveUnset,
    required this.eventId,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveInputAudioMuted.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInputAudioMuted',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'client_event_id', 'event_id', 'type'};

  @override
  String get type => 'session.input_audio.muted';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveInputAudioMuted; wrong or missing known fields fail safely.
  factory LiveInputAudioMuted.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.input_audio.muted',
      'LiveInputAudioMuted',
      key: 'type',
    );
    return LiveInputAudioMuted(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveInputAudioMuted.client_event_id',
            )
          : liveUnset,
      eventId: requireLiveString(
        json['event_id'],
        'LiveInputAudioMuted.event_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'event_id': eventId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveInputAudioMuted copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? eventId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveInputAudioMuted(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveInputAudioMuted.event_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveInputAudioMuted.rawJson'),
  );
}

/// Returned when a session.input_audio.unmute command is accepted. Input audio is sent to the model again.
final class LiveInputAudioUnmuted extends LiveServerEvent {
  /// Creates LiveInputAudioUnmuted with canonical received fields.
  LiveInputAudioUnmuted({
    Object? clientEventId = liveUnset,
    required this.eventId,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveInputAudioUnmuted.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInputAudioUnmuted',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'client_event_id', 'event_id', 'type'};

  @override
  String get type => 'session.input_audio.unmuted';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveInputAudioUnmuted; wrong or missing known fields fail safely.
  factory LiveInputAudioUnmuted.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.input_audio.unmuted',
      'LiveInputAudioUnmuted',
      key: 'type',
    );
    return LiveInputAudioUnmuted(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveInputAudioUnmuted.client_event_id',
            )
          : liveUnset,
      eventId: requireLiveString(
        json['event_id'],
        'LiveInputAudioUnmuted.event_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'event_id': eventId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveInputAudioUnmuted copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? eventId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveInputAudioUnmuted(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveInputAudioUnmuted.event_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveInputAudioUnmuted.rawJson'),
  );
}

/// Returned when a session.instructions.append command is accepted into the Live session timeline. Acknowledges the appended instructions without guaranteeing that the model has acted on them.
final class LiveInstructionsAppended extends LiveServerEvent {
  /// Creates LiveInstructionsAppended with canonical received fields.
  LiveInstructionsAppended({
    Object? clientEventId = liveUnset,
    required this.endMs,
    required this.eventId,
    required this.startMs,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveInstructionsAppended.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInstructionsAppended',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'end_ms',
    'event_id',
    'start_ms',
    'type',
  };

  @override
  String get type => 'session.instructions.appended';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The end of this event on the Live session timeline, in milliseconds from the beginning of the session. For appended context, this can equal start_ms.
  final int endMs;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// The start of this event on the Live session timeline, in milliseconds from the beginning of the session.
  final int startMs;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveInstructionsAppended; wrong or missing known fields fail safely.
  factory LiveInstructionsAppended.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.instructions.appended',
      'LiveInstructionsAppended',
      key: 'type',
    );
    return LiveInstructionsAppended(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveInstructionsAppended.client_event_id',
            )
          : liveUnset,
      endMs: requireLiveInt(json['end_ms'], 'LiveInstructionsAppended.end_ms'),
      eventId: requireLiveString(
        json['event_id'],
        'LiveInstructionsAppended.event_id',
      ),
      startMs: requireLiveInt(
        json['start_ms'],
        'LiveInstructionsAppended.start_ms',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireLiveInt(endMs, 'LiveInstructionsAppended.end_ms');
    requireLiveInt(startMs, 'LiveInstructionsAppended.start_ms');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'end_ms': endMs,
    'event_id': eventId,
    'start_ms': startMs,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveInstructionsAppended copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? endMs = liveUnset,
    Object? eventId = liveUnset,
    Object? startMs = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveInstructionsAppended(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    endMs: identical(endMs, liveUnset)
        ? this.endMs
        : requireLiveInt(endMs, 'LiveInstructionsAppended.end_ms'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveInstructionsAppended.event_id'),
    startMs: identical(startMs, liveUnset)
        ? this.startMs
        : requireLiveInt(startMs, 'LiveInstructionsAppended.start_ms'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveInstructionsAppended.rawJson'),
  );
}

/// Returned when a session.thinking.append command is accepted into the Live session timeline. Acknowledges the added reasoning context without guaranteeing any spoken output.
final class LiveThinkingAppended extends LiveServerEvent {
  /// Creates LiveThinkingAppended with canonical received fields.
  LiveThinkingAppended({
    Object? clientEventId = liveUnset,
    required this.endMs,
    required this.eventId,
    required this.startMs,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveThinkingAppended.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveThinkingAppended',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'end_ms',
    'event_id',
    'start_ms',
    'type',
  };

  @override
  String get type => 'session.thinking.appended';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The end of this event on the Live session timeline, in milliseconds from the beginning of the session. For appended context, this can equal start_ms.
  final int endMs;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// The start of this event on the Live session timeline, in milliseconds from the beginning of the session.
  final int startMs;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveThinkingAppended; wrong or missing known fields fail safely.
  factory LiveThinkingAppended.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.thinking.appended',
      'LiveThinkingAppended',
      key: 'type',
    );
    return LiveThinkingAppended(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveThinkingAppended.client_event_id',
            )
          : liveUnset,
      endMs: requireLiveInt(json['end_ms'], 'LiveThinkingAppended.end_ms'),
      eventId: requireLiveString(
        json['event_id'],
        'LiveThinkingAppended.event_id',
      ),
      startMs: requireLiveInt(
        json['start_ms'],
        'LiveThinkingAppended.start_ms',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireLiveInt(endMs, 'LiveThinkingAppended.end_ms');
    requireLiveInt(startMs, 'LiveThinkingAppended.start_ms');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'end_ms': endMs,
    'event_id': eventId,
    'start_ms': startMs,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveThinkingAppended copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? endMs = liveUnset,
    Object? eventId = liveUnset,
    Object? startMs = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveThinkingAppended(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    endMs: identical(endMs, liveUnset)
        ? this.endMs
        : requireLiveInt(endMs, 'LiveThinkingAppended.end_ms'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveThinkingAppended.event_id'),
    startMs: identical(startMs, liveUnset)
        ? this.startMs
        : requireLiveInt(startMs, 'LiveThinkingAppended.start_ms'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveThinkingAppended.rawJson'),
  );
}

/// Returned when a session.commentary.append command is accepted into the Live session timeline. Acknowledges the added commentary without guaranteeing exact wording or completed audio playback.
final class LiveCommentaryAppended extends LiveServerEvent {
  /// Creates LiveCommentaryAppended with canonical received fields.
  LiveCommentaryAppended({
    Object? clientEventId = liveUnset,
    required this.endMs,
    required this.eventId,
    required this.startMs,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveCommentaryAppended.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveCommentaryAppended',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'end_ms',
    'event_id',
    'start_ms',
    'type',
  };

  @override
  String get type => 'session.commentary.appended';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The end of this event on the Live session timeline, in milliseconds from the beginning of the session. For appended context, this can equal start_ms.
  final int endMs;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// The start of this event on the Live session timeline, in milliseconds from the beginning of the session.
  final int startMs;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveCommentaryAppended; wrong or missing known fields fail safely.
  factory LiveCommentaryAppended.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.commentary.appended',
      'LiveCommentaryAppended',
      key: 'type',
    );
    return LiveCommentaryAppended(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveCommentaryAppended.client_event_id',
            )
          : liveUnset,
      endMs: requireLiveInt(json['end_ms'], 'LiveCommentaryAppended.end_ms'),
      eventId: requireLiveString(
        json['event_id'],
        'LiveCommentaryAppended.event_id',
      ),
      startMs: requireLiveInt(
        json['start_ms'],
        'LiveCommentaryAppended.start_ms',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireLiveInt(endMs, 'LiveCommentaryAppended.end_ms');
    requireLiveInt(startMs, 'LiveCommentaryAppended.start_ms');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'end_ms': endMs,
    'event_id': eventId,
    'start_ms': startMs,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveCommentaryAppended copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? endMs = liveUnset,
    Object? eventId = liveUnset,
    Object? startMs = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveCommentaryAppended(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    endMs: identical(endMs, liveUnset)
        ? this.endMs
        : requireLiveInt(endMs, 'LiveCommentaryAppended.end_ms'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveCommentaryAppended.event_id'),
    startMs: identical(startMs, liveUnset)
        ? this.startMs
        : requireLiveInt(startMs, 'LiveCommentaryAppended.start_ms'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveCommentaryAppended.rawJson'),
  );
}

/// Input audio received from the primary transport and reflected to a Live sideband connection before model-input muting.
final class LiveInputAudioAppend extends LiveServerEvent {
  /// Creates LiveInputAudioAppend with canonical received fields.
  LiveInputAudioAppend({
    required this.audio,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInputAudioAppend',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'audio', 'type'};

  @override
  String get type => 'session.input_audio.append';

  /// Base64-encoded raw mono PCM16LE at 24 kHz received from the primary transport, reflected to the sideband before model-input muting. This server event uses the same audio key as the client command, but is not an acknowledgment of it.
  final String audio;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveInputAudioAppend; wrong or missing known fields fail safely.
  factory LiveInputAudioAppend.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.input_audio.append',
      'LiveInputAudioAppend',
      key: 'type',
    );
    return LiveInputAudioAppend(
      audio: requireLiveString(json['audio'], 'LiveInputAudioAppend.audio'),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type, 'audio': audio});

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveInputAudioAppend copyWith({
    Object? audio = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveInputAudioAppend(
    audio: identical(audio, liveUnset)
        ? this.audio
        : requireLiveString(audio, 'LiveInputAudioAppend.audio'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveInputAudioAppend.rawJson'),
  );
}

/// An audio chunk generated by the Live model. Decode and play primary WebSocket chunks in delivery order using the configured session audio format. Sideband connections receive reflected output audio with timestamps.
final class LiveOutputAudioDelta extends LiveServerEvent {
  /// Creates LiveOutputAudioDelta with canonical received fields.
  LiveOutputAudioDelta({
    required this.delta,
    Object? endMs = liveUnset,
    Object? startMs = liveUnset,
    Map<String, dynamic> rawJson = const {},
  }) : endMs = _serverOptional<int>(
         endMs,
         'LiveOutputAudioDelta.end_ms',
         nullable: false,
       ),
       startMs = _serverOptional<int>(
         startMs,
         'LiveOutputAudioDelta.start_ms',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveOutputAudioDelta',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'delta', 'end_ms', 'start_ms', 'type'};

  @override
  String get type => 'session.output_audio.delta';

  /// Base64-encoded raw audio. Primary WebSocket events use the session's configured format; reflected sideband events use mono PCM16LE at 24 kHz.
  final String delta;

  /// Exclusive session-relative end in milliseconds. Required on reflected sideband events; omitted on the primary WebSocket. Dropped output frames leave gaps between reflected ranges.
  final int? endMs;

  /// Inclusive session-relative start in milliseconds. Required on reflected sideband events; omitted on the primary WebSocket.
  final int? startMs;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveOutputAudioDelta; wrong or missing known fields fail safely.
  factory LiveOutputAudioDelta.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.output_audio.delta',
      'LiveOutputAudioDelta',
      key: 'type',
    );
    return LiveOutputAudioDelta(
      delta: requireLiveString(json['delta'], 'LiveOutputAudioDelta.delta'),
      endMs: json.containsKey('end_ms')
          ? requireLiveInt(json['end_ms'], 'LiveOutputAudioDelta.end_ms')
          : liveUnset,
      startMs: json.containsKey('start_ms')
          ? requireLiveInt(json['start_ms'], 'LiveOutputAudioDelta.start_ms')
          : liveUnset,
      rawJson: json,
    );
  }

  @override
  void validate() {
    if (endMs != null) {
      requireLiveInt(endMs, 'LiveOutputAudioDelta.end_ms');
    }
    if (startMs != null) {
      requireLiveInt(startMs, 'LiveOutputAudioDelta.start_ms');
    }
  }

  @override
  void validateForChannel(String channel) {
    super.validateForChannel(channel);
    if (channel == 'sideband' && (startMs == null || endMs == null)) {
      throw const FormatException(
        'LiveOutputAudioDelta: sideband requires start_ms and end_ms',
      );
    }
    if (channel == 'primary' && (startMs != null || endMs != null)) {
      throw const FormatException(
        'LiveOutputAudioDelta: primary omits start_ms and end_ms',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'delta': delta,
    if (endMs != null) 'end_ms': endMs,
    if (startMs != null) 'start_ms': startMs,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveOutputAudioDelta copyWith({
    Object? delta = liveUnset,
    Object? endMs = liveUnset,
    bool clearEndMs = false,
    Object? startMs = liveUnset,
    bool clearStartMs = false,
    Object? rawJson = liveUnset,
  }) => LiveOutputAudioDelta(
    delta: identical(delta, liveUnset)
        ? this.delta
        : requireLiveString(delta, 'LiveOutputAudioDelta.delta'),
    endMs: clearEndMs
        ? liveUnset
        : (identical(endMs, liveUnset) ? (this.endMs ?? liveUnset) : endMs),
    startMs: clearStartMs
        ? liveUnset
        : (identical(startMs, liveUnset)
              ? (this.startMs ?? liveUnset)
              : startMs),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveOutputAudioDelta.rawJson'),
  );
}

/// A transcript fragment for user input audio in the Live session. Accumulate fragments in delivery order; these events do not define complete turns or include a transcript-done event.
final class LiveInputTranscriptDelta extends LiveServerEvent {
  /// Creates LiveInputTranscriptDelta with canonical received fields.
  LiveInputTranscriptDelta({
    Object? clientEventId = liveUnset,
    required this.delta,
    required this.endMs,
    required this.eventId,
    required this.startMs,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveInputTranscriptDelta.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInputTranscriptDelta',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'delta',
    'end_ms',
    'event_id',
    'start_ms',
    'type',
  };

  @override
  String get type => 'session.input_transcript.delta';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The transcript text fragment for the audio in this time range. Append fragments in delivery order to build the transcript.
  final String delta;

  /// The end of this event on the Live session timeline, in milliseconds from the beginning of the session. For appended context, this can equal start_ms.
  final int endMs;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// The start of this event on the Live session timeline, in milliseconds from the beginning of the session.
  final int startMs;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveInputTranscriptDelta; wrong or missing known fields fail safely.
  factory LiveInputTranscriptDelta.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.input_transcript.delta',
      'LiveInputTranscriptDelta',
      key: 'type',
    );
    return LiveInputTranscriptDelta(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveInputTranscriptDelta.client_event_id',
            )
          : liveUnset,
      delta: requireLiveString(json['delta'], 'LiveInputTranscriptDelta.delta'),
      endMs: requireLiveInt(json['end_ms'], 'LiveInputTranscriptDelta.end_ms'),
      eventId: requireLiveString(
        json['event_id'],
        'LiveInputTranscriptDelta.event_id',
      ),
      startMs: requireLiveInt(
        json['start_ms'],
        'LiveInputTranscriptDelta.start_ms',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireLiveInt(endMs, 'LiveInputTranscriptDelta.end_ms');
    requireLiveInt(startMs, 'LiveInputTranscriptDelta.start_ms');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'delta': delta,
    'end_ms': endMs,
    'event_id': eventId,
    'start_ms': startMs,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveInputTranscriptDelta copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? delta = liveUnset,
    Object? endMs = liveUnset,
    Object? eventId = liveUnset,
    Object? startMs = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveInputTranscriptDelta(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    delta: identical(delta, liveUnset)
        ? this.delta
        : requireLiveString(delta, 'LiveInputTranscriptDelta.delta'),
    endMs: identical(endMs, liveUnset)
        ? this.endMs
        : requireLiveInt(endMs, 'LiveInputTranscriptDelta.end_ms'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveInputTranscriptDelta.event_id'),
    startMs: identical(startMs, liveUnset)
        ? this.startMs
        : requireLiveInt(startMs, 'LiveInputTranscriptDelta.start_ms'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveInputTranscriptDelta.rawJson'),
  );
}

/// A transcript fragment for assistant output audio in the Live session. Accumulate fragments in delivery order; these events do not define complete turns or include a transcript-done event.
final class LiveOutputTranscriptDelta extends LiveServerEvent {
  /// Creates LiveOutputTranscriptDelta with canonical received fields.
  LiveOutputTranscriptDelta({
    Object? clientEventId = liveUnset,
    required this.delta,
    required this.endMs,
    required this.eventId,
    required this.startMs,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveOutputTranscriptDelta.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveOutputTranscriptDelta',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'delta',
    'end_ms',
    'event_id',
    'start_ms',
    'type',
  };

  @override
  String get type => 'session.output_transcript.delta';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The transcript text fragment for the audio in this time range. Append fragments in delivery order to build the transcript.
  final String delta;

  /// The end of this event on the Live session timeline, in milliseconds from the beginning of the session. For appended context, this can equal start_ms.
  final int endMs;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// The start of this event on the Live session timeline, in milliseconds from the beginning of the session.
  final int startMs;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveOutputTranscriptDelta; wrong or missing known fields fail safely.
  factory LiveOutputTranscriptDelta.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.output_transcript.delta',
      'LiveOutputTranscriptDelta',
      key: 'type',
    );
    return LiveOutputTranscriptDelta(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveOutputTranscriptDelta.client_event_id',
            )
          : liveUnset,
      delta: requireLiveString(
        json['delta'],
        'LiveOutputTranscriptDelta.delta',
      ),
      endMs: requireLiveInt(json['end_ms'], 'LiveOutputTranscriptDelta.end_ms'),
      eventId: requireLiveString(
        json['event_id'],
        'LiveOutputTranscriptDelta.event_id',
      ),
      startMs: requireLiveInt(
        json['start_ms'],
        'LiveOutputTranscriptDelta.start_ms',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireLiveInt(endMs, 'LiveOutputTranscriptDelta.end_ms');
    requireLiveInt(startMs, 'LiveOutputTranscriptDelta.start_ms');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'delta': delta,
    'end_ms': endMs,
    'event_id': eventId,
    'start_ms': startMs,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveOutputTranscriptDelta copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? delta = liveUnset,
    Object? endMs = liveUnset,
    Object? eventId = liveUnset,
    Object? startMs = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveOutputTranscriptDelta(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    delta: identical(delta, liveUnset)
        ? this.delta
        : requireLiveString(delta, 'LiveOutputTranscriptDelta.delta'),
    endMs: identical(endMs, liveUnset)
        ? this.endMs
        : requireLiveInt(endMs, 'LiveOutputTranscriptDelta.end_ms'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveOutputTranscriptDelta.event_id'),
    startMs: identical(startMs, liveUnset)
        ? this.startMs
        : requireLiveInt(startMs, 'LiveOutputTranscriptDelta.start_ms'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveOutputTranscriptDelta.rawJson'),
  );
}

/// Returned when the Live model delegates work to your application or a Responses backend. Contains delegation metadata and the position on the session timeline where the work was delegated.
final class LiveDelegationCreated extends LiveServerEvent {
  /// Creates LiveDelegationCreated with canonical received fields.
  LiveDelegationCreated({
    Object? clientEventId = liveUnset,
    required this.delegation,
    required this.eventId,
    required this.offsetMs,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveDelegationCreated.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDelegationCreated',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'delegation',
    'event_id',
    'offset_ms',
    'type',
  };

  @override
  String get type => 'session.delegation.created';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The delegated work identifier and destination. This object contains metadata, not the task text.
  final LiveDelegationItem delegation;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// The position on the Live session timeline where the delegation was created, in milliseconds from the beginning of the session.
  final int offsetMs;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveDelegationCreated; wrong or missing known fields fail safely.
  factory LiveDelegationCreated.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.delegation.created',
      'LiveDelegationCreated',
      key: 'type',
    );
    return LiveDelegationCreated(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveDelegationCreated.client_event_id',
            )
          : liveUnset,
      delegation: _serverModel(
        json['delegation'],
        'LiveDelegationCreated.delegation',
        LiveDelegationItem.fromJson,
      ),
      eventId: requireLiveString(
        json['event_id'],
        'LiveDelegationCreated.event_id',
      ),
      offsetMs: requireLiveInt(
        json['offset_ms'],
        'LiveDelegationCreated.offset_ms',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    delegation.validate();
    requireLiveInt(offsetMs, 'LiveDelegationCreated.offset_ms');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'delegation': delegation.toJson(),
    'event_id': eventId,
    'offset_ms': offsetMs,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveDelegationCreated copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? delegation = liveUnset,
    Object? eventId = liveUnset,
    Object? offsetMs = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveDelegationCreated(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    delegation: identical(delegation, liveUnset)
        ? this.delegation
        : _serverRequired<LiveDelegationItem>(
            delegation,
            'LiveDelegationCreated.delegation',
          ),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveDelegationCreated.event_id'),
    offsetMs: identical(offsetMs, liveUnset)
        ? this.offsetMs
        : requireLiveInt(offsetMs, 'LiveDelegationCreated.offset_ms'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveDelegationCreated.rawJson'),
  );
}

/// A streaming Responses API event from a backend delegated to by the Live session. Use the outer delegation_id to associate the nested stream with its Live delegation.
final class LiveResponseEvent extends LiveServerEvent {
  /// Creates LiveResponseEvent with canonical received fields.
  LiveResponseEvent({
    Object? clientEventId = liveUnset,
    Object? delegationId = liveUnset,
    required Map<String, dynamic> event,
    required this.eventId,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveResponseEvent.client_event_id',
         nullable: false,
       ),
       delegationId = _serverOptional<String>(
         delegationId,
         'LiveResponseEvent.delegation_id',
         nullable: true,
       ),
       hasDelegationId = !identical(delegationId, liveUnset),
       event = snapshotLiveJson(
         requireLiveObject(event, 'LiveResponseEvent.event'),
         'LiveResponseEvent.event',
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponseEvent',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'delegation_id',
    'event',
    'event_id',
    'type',
  };

  @override
  String get type => 'response.event';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// Canonical received field.
  final String? delegationId;

  /// Whether delegation_id was supplied, including explicit null.
  final bool hasDelegationId;

  /// The nested Responses streaming event. Dispatch on its type field. Response lifecycle snapshots omit input and clear instructions, tools, and output to keep messages small; consume granular output events for the generated content.
  final Map<String, dynamic> event;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveResponseEvent; wrong or missing known fields fail safely.
  factory LiveResponseEvent.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'response.event', 'LiveResponseEvent', key: 'type');
    return LiveResponseEvent(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveResponseEvent.client_event_id',
            )
          : liveUnset,
      delegationId: json.containsKey('delegation_id')
          ? (json['delegation_id'] == null
                ? null
                : requireLiveString(
                    json['delegation_id'],
                    'LiveResponseEvent.delegation_id',
                  ))
          : liveUnset,
      event: snapshotLiveJson(
        requireLiveObject(json['event'], 'LiveResponseEvent.event'),
        'LiveResponseEvent.event',
      ),
      eventId: requireLiveString(
        json['event_id'],
        'LiveResponseEvent.event_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    if (hasDelegationId) 'delegation_id': delegationId,
    'event': event,
    'event_id': eventId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveResponseEvent copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? delegationId = liveUnset,
    bool clearDelegationId = false,
    Object? event = liveUnset,
    Object? eventId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveResponseEvent(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    delegationId: clearDelegationId
        ? liveUnset
        : (identical(delegationId, liveUnset)
              ? (hasDelegationId ? this.delegationId : liveUnset)
              : delegationId),
    event: identical(event, liveUnset)
        ? this.event
        : snapshotLiveJson(
            requireLiveObject(event, 'LiveResponseEvent.event'),
            'LiveResponseEvent.event',
          ),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveResponseEvent.event_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveResponseEvent.rawJson'),
  );
}

/// Reports cumulative Live audio usage and, when available, the most recent context-window usage. Delegated Responses token usage is reported separately in response.event events.
final class LiveSessionUsageUpdated extends LiveServerEvent {
  /// Creates LiveSessionUsageUpdated with canonical received fields.
  LiveSessionUsageUpdated({
    Object? clientEventId = liveUnset,
    Object? contextWindow = liveUnset,
    required this.eventId,
    required this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveSessionUsageUpdated.client_event_id',
         nullable: false,
       ),
       contextWindow = _serverOptional<LiveContextWindowUsage>(
         contextWindow,
         'LiveSessionUsageUpdated.context_window',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionUsageUpdated',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'context_window',
    'event_id',
    'type',
    'usage',
  };

  @override
  String get type => 'session.usage.updated';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The latest measured Live context-window usage. Omitted when the context limit is unknown.
  final LiveContextWindowUsage? contextWindow;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// The cumulative Live audio usage so far.
  final LiveSessionUsage usage;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionUsageUpdated; wrong or missing known fields fail safely.
  factory LiveSessionUsageUpdated.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.usage.updated',
      'LiveSessionUsageUpdated',
      key: 'type',
    );
    return LiveSessionUsageUpdated(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveSessionUsageUpdated.client_event_id',
            )
          : liveUnset,
      contextWindow: json.containsKey('context_window')
          ? _serverModel(
              json['context_window'],
              'LiveSessionUsageUpdated.context_window',
              LiveContextWindowUsage.fromJson,
            )
          : liveUnset,
      eventId: requireLiveString(
        json['event_id'],
        'LiveSessionUsageUpdated.event_id',
      ),
      usage: _serverModel(
        json['usage'],
        'LiveSessionUsageUpdated.usage',
        LiveSessionUsage.fromJson,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    if (contextWindow != null) {
      contextWindow!.validate();
    }
    usage.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    if (contextWindow != null) 'context_window': contextWindow!.toJson(),
    'event_id': eventId,
    'usage': usage.toJson(),
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveSessionUsageUpdated copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? contextWindow = liveUnset,
    bool clearContextWindow = false,
    Object? eventId = liveUnset,
    Object? usage = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveSessionUsageUpdated(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    contextWindow: clearContextWindow
        ? liveUnset
        : (identical(contextWindow, liveUnset)
              ? (this.contextWindow ?? liveUnset)
              : contextWindow),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveSessionUsageUpdated.event_id'),
    usage: identical(usage, liveUnset)
        ? this.usage
        : _serverRequired<LiveSessionUsage>(
            usage,
            'LiveSessionUsageUpdated.usage',
          ),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveSessionUsageUpdated.rawJson'),
  );
}

/// Returned after the Live session finishes finalizing, with the close reason, final session snapshot, and cumulative audio usage. A connection closing without this event does not confirm successful finalization.
final class LiveSessionClosed extends LiveServerEvent {
  /// Creates LiveSessionClosed with canonical received fields.
  LiveSessionClosed({
    Object? clientEventId = liveUnset,
    required this.eventId,
    required this.reason,
    required this.session,
    required this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveSessionClosed.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionClosed',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'event_id',
    'reason',
    'session',
    'type',
    'usage',
  };

  @override
  String get type => 'session.closed';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// Why the Live session ended: `close_requested` for an application close or hangup request, `expired` for the session duration limit, `content` for a safety filter, `remote_hangup` for a graceful remote disconnect, or `connection_lost` for an unexpected primary or upstream disconnection.
  final String reason;

  /// Canonical received field.
  final LiveSessionResourceParam session;

  /// The final cumulative Live audio usage after session finalization.
  final LiveSessionUsage usage;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionClosed; wrong or missing known fields fail safely.
  factory LiveSessionClosed.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.closed', 'LiveSessionClosed', key: 'type');
    return LiveSessionClosed(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveSessionClosed.client_event_id',
            )
          : liveUnset,
      eventId: requireLiveString(
        json['event_id'],
        'LiveSessionClosed.event_id',
      ),
      reason: requireLiveString(json['reason'], 'LiveSessionClosed.reason'),
      session: _serverModel(
        json['session'],
        'LiveSessionClosed.session',
        LiveSessionResourceParam.fromJson,
      ),
      usage: _serverModel(
        json['usage'],
        'LiveSessionClosed.usage',
        LiveSessionUsage.fromJson,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    if (!const <String>{
      'close_requested',
      'expired',
      'content',
      'remote_hangup',
      'connection_lost',
    }.contains(reason)) {
      throw const FormatException(
        'LiveSessionClosed.reason: unsupported canonical value',
      );
    }
    session.validate();
    usage.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'event_id': eventId,
    'reason': reason,
    'session': session.toJson(),
    'usage': usage.toJson(),
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveSessionClosed copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? eventId = liveUnset,
    Object? reason = liveUnset,
    Object? session = liveUnset,
    Object? usage = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveSessionClosed(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveSessionClosed.event_id'),
    reason: identical(reason, liveUnset)
        ? this.reason
        : requireLiveString(reason, 'LiveSessionClosed.reason'),
    session: identical(session, liveUnset)
        ? this.session
        : _serverRequired<LiveSessionResourceParam>(
            session,
            'LiveSessionClosed.session',
          ),
    usage: identical(usage, liveUnset)
        ? this.usage
        : _serverRequired<LiveSessionUsage>(usage, 'LiveSessionClosed.usage'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveSessionClosed.rawJson'),
  );
}

/// Reports an error in the Live session, such as an invalid client command. Use error.client_event_id, when present, to identify the command that caused the error.
final class LiveErrorEvent extends LiveServerEvent {
  /// Creates LiveErrorEvent with canonical received fields.
  LiveErrorEvent({
    Object? clientEventId = liveUnset,
    required this.error,
    required this.eventId,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveErrorEvent.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveErrorEvent',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'error',
    'event_id',
    'type',
  };

  @override
  String get type => 'error';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// Details of the Live error and the client command that caused it, when known.
  final LiveLiveError error;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveErrorEvent; wrong or missing known fields fail safely.
  factory LiveErrorEvent.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'error', 'LiveErrorEvent', key: 'type');
    return LiveErrorEvent(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveErrorEvent.client_event_id',
            )
          : liveUnset,
      error: _serverModel(
        json['error'],
        'LiveErrorEvent.error',
        LiveLiveError.fromJson,
      ),
      eventId: requireLiveString(json['event_id'], 'LiveErrorEvent.event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    error.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'error': error.toJson(),
    'event_id': eventId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveErrorEvent copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? error = liveUnset,
    Object? eventId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveErrorEvent(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    error: identical(error, liveUnset)
        ? this.error
        : _serverRequired<LiveLiveError>(error, 'LiveErrorEvent.error'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveErrorEvent.event_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveErrorEvent.rawJson'),
  );
}

/// An informational notice about the Live session, such as the event permissions applied to a frontend data channel.
final class LiveInfoEvent extends LiveServerEvent {
  /// Creates LiveInfoEvent with canonical received fields.
  LiveInfoEvent({
    Object? clientEventId = liveUnset,
    required this.code,
    required this.eventId,
    required this.message,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveInfoEvent.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInfoEvent',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'code',
    'event_id',
    'message',
    'type',
  };

  @override
  String get type => 'info';

  /// The event_id of the client command associated with this server event, when supplied.
  final String? clientEventId;

  /// A machine-readable code for the notice, such as `data_channel_permissions`.
  final String code;

  /// The unique ID of the Live server event.
  @override
  final String eventId;

  /// A human-readable explanation of the Live session notice.
  final String message;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveInfoEvent; wrong or missing known fields fail safely.
  factory LiveInfoEvent.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'info', 'LiveInfoEvent', key: 'type');
    return LiveInfoEvent(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveInfoEvent.client_event_id',
            )
          : liveUnset,
      code: requireLiveString(json['code'], 'LiveInfoEvent.code'),
      eventId: requireLiveString(json['event_id'], 'LiveInfoEvent.event_id'),
      message: requireLiveString(json['message'], 'LiveInfoEvent.message'),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'code': code,
    'event_id': eventId,
    'message': message,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveInfoEvent copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? code = liveUnset,
    Object? eventId = liveUnset,
    Object? message = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveInfoEvent(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    code: identical(code, liveUnset)
        ? this.code
        : requireLiveString(code, 'LiveInfoEvent.code'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveInfoEvent.event_id'),
    message: identical(message, liveUnset)
        ? this.message
        : requireLiveString(message, 'LiveInfoEvent.message'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveInfoEvent.rawJson'),
  );
}

/// A SIP DTMF keypress received from the caller. Delivered only to sideband observers.
final class LiveTransportDTMFReceived extends LiveServerEvent {
  /// Creates LiveTransportDTMFReceived with canonical received fields.
  LiveTransportDTMFReceived({
    required this.event,
    required this.eventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveTransportDTMFReceived',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'event', 'event_id', 'type'};

  @override
  String get type => 'transport.dtmf.received';

  /// Canonical received field.
  final String event;

  /// Canonical received field.
  @override
  final String eventId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveTransportDTMFReceived; wrong or missing known fields fail safely.
  factory LiveTransportDTMFReceived.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'transport.dtmf.received',
      'LiveTransportDTMFReceived',
      key: 'type',
    );
    return LiveTransportDTMFReceived(
      event: requireLiveString(
        json['event'],
        'LiveTransportDTMFReceived.event',
      ),
      eventId: requireLiveString(
        json['event_id'],
        'LiveTransportDTMFReceived.event_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    validateLiveLength(
      event,
      'LiveTransportDTMFReceived.event',
      min: 1,
      max: 1,
    );
    if (!RegExp(r'^[0-9A-D*#]$').hasMatch(event)) {
      throw const FormatException(
        'LiveTransportDTMFReceived.event: expected one canonical DTMF character',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'event': event,
    'event_id': eventId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveTransportDTMFReceived copyWith({
    Object? event = liveUnset,
    Object? eventId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveTransportDTMFReceived(
    event: identical(event, liveUnset)
        ? this.event
        : requireLiveString(event, 'LiveTransportDTMFReceived.event'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveTransportDTMFReceived.event_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveTransportDTMFReceived.rawJson'),
  );
}

/// A SIP DTMF keypress successfully sent to the SIP trunk. Delivered only to sideband observers; this is not a client command.
final class LiveTransportDTMFSend extends LiveServerEvent {
  /// Creates LiveTransportDTMFSend with canonical received fields.
  LiveTransportDTMFSend({
    Object? clientEventId = liveUnset,
    required this.event,
    required this.eventId,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveTransportDTMFSend.client_event_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveTransportDTMFSend',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'event',
    'event_id',
    'type',
  };

  @override
  String get type => 'transport.dtmf.send';

  /// The event_id of the client command, when supplied.
  final String? clientEventId;

  /// Canonical received field.
  final String event;

  /// Canonical received field.
  @override
  final String eventId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveTransportDTMFSend; wrong or missing known fields fail safely.
  factory LiveTransportDTMFSend.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'transport.dtmf.send',
      'LiveTransportDTMFSend',
      key: 'type',
    );
    return LiveTransportDTMFSend(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveTransportDTMFSend.client_event_id',
            )
          : liveUnset,
      event: requireLiveString(json['event'], 'LiveTransportDTMFSend.event'),
      eventId: requireLiveString(
        json['event_id'],
        'LiveTransportDTMFSend.event_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    validateLiveLength(event, 'LiveTransportDTMFSend.event', min: 1, max: 1);
    if (!RegExp(r'^[0-9A-D*#]$').hasMatch(event)) {
      throw const FormatException(
        'LiveTransportDTMFSend.event: expected one canonical DTMF character',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (clientEventId != null) 'client_event_id': clientEventId,
    'event': event,
    'event_id': eventId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveTransportDTMFSend copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? event = liveUnset,
    Object? eventId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveTransportDTMFSend(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    event: identical(event, liveUnset)
        ? this.event
        : requireLiveString(event, 'LiveTransportDTMFSend.event'),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveTransportDTMFSend.event_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveTransportDTMFSend.rawJson'),
  );
}

/// The outbound SIP provider leg is ringing or providing early media. Delivered only to sideband observers.
final class LiveTransportRinging extends LiveServerEvent {
  /// Creates LiveTransportRinging with canonical received fields.
  LiveTransportRinging({
    required this.eventId,
    required this.sessionId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveTransportRinging',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'event_id', 'session_id', 'type'};

  @override
  String get type => 'transport.ringing';

  /// Canonical received field.
  @override
  final String eventId;

  /// The canonical Live session ID.
  final String sessionId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveTransportRinging; wrong or missing known fields fail safely.
  factory LiveTransportRinging.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'transport.ringing',
      'LiveTransportRinging',
      key: 'type',
    );
    return LiveTransportRinging(
      eventId: requireLiveString(
        json['event_id'],
        'LiveTransportRinging.event_id',
      ),
      sessionId: requireLiveString(
        json['session_id'],
        'LiveTransportRinging.session_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'event_id': eventId,
    'session_id': sessionId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveTransportRinging copyWith({
    Object? eventId = liveUnset,
    Object? sessionId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveTransportRinging(
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveTransportRinging.event_id'),
    sessionId: identical(sessionId, liveUnset)
        ? this.sessionId
        : requireLiveString(sessionId, 'LiveTransportRinging.session_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveTransportRinging.rawJson'),
  );
}

/// The outbound SIP provider leg answered and media is established. Delivered only to sideband observers.
final class LiveTransportAnswered extends LiveServerEvent {
  /// Creates LiveTransportAnswered with canonical received fields.
  LiveTransportAnswered({
    required this.eventId,
    required this.sessionId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveTransportAnswered',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'event_id', 'session_id', 'type'};

  @override
  String get type => 'transport.answered';

  /// Canonical received field.
  @override
  final String eventId;

  /// The canonical Live session ID.
  final String sessionId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveTransportAnswered; wrong or missing known fields fail safely.
  factory LiveTransportAnswered.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'transport.answered',
      'LiveTransportAnswered',
      key: 'type',
    );
    return LiveTransportAnswered(
      eventId: requireLiveString(
        json['event_id'],
        'LiveTransportAnswered.event_id',
      ),
      sessionId: requireLiveString(
        json['session_id'],
        'LiveTransportAnswered.session_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'event_id': eventId,
    'session_id': sessionId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveTransportAnswered copyWith({
    Object? eventId = liveUnset,
    Object? sessionId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveTransportAnswered(
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveTransportAnswered.event_id'),
    sessionId: identical(sessionId, liveUnset)
        ? this.sessionId
        : requireLiveString(sessionId, 'LiveTransportAnswered.session_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveTransportAnswered.rawJson'),
  );
}

/// An asynchronous outbound SIP setup failure. Delivered only to sideband observers.
final class LiveTransportFailed extends LiveServerEvent {
  /// Creates LiveTransportFailed with canonical received fields.
  LiveTransportFailed({
    required this.error,
    required this.eventId,
    required this.sessionId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveTransportFailed',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'error', 'event_id', 'session_id', 'type'};

  @override
  String get type => 'transport.failed';

  /// Canonical received field.
  final LiveTransportCallError error;

  /// Canonical received field.
  @override
  final String eventId;

  /// The canonical Live session ID.
  final String sessionId;

  /// Immutable finite original data; typed fields control known wire members.
  @override
  final Map<String, dynamic> rawJson;

  /// Parses LiveTransportFailed; wrong or missing known fields fail safely.
  factory LiveTransportFailed.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'transport.failed',
      'LiveTransportFailed',
      key: 'type',
    );
    return LiveTransportFailed(
      error: _serverModel(
        json['error'],
        'LiveTransportFailed.error',
        LiveTransportCallError.fromJson,
      ),
      eventId: requireLiveString(
        json['event_id'],
        'LiveTransportFailed.event_id',
      ),
      sessionId: requireLiveString(
        json['session_id'],
        'LiveTransportFailed.session_id',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    error.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'error': error.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveTransportFailed copyWith({
    Object? error = liveUnset,
    Object? eventId = liveUnset,
    Object? sessionId = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveTransportFailed(
    error: identical(error, liveUnset)
        ? this.error
        : _serverRequired<LiveTransportCallError>(
            error,
            'LiveTransportFailed.error',
          ),
    eventId: identical(eventId, liveUnset)
        ? this.eventId
        : requireLiveString(eventId, 'LiveTransportFailed.event_id'),
    sessionId: identical(sessionId, liveUnset)
        ? this.sessionId
        : requireLiveString(sessionId, 'LiveTransportFailed.session_id'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveTransportFailed.rawJson'),
  );
}

/// Details of an error encountered by the Live session, including the affected parameter or client command when available.
final class LiveLiveError extends LiveJsonModel {
  /// Creates LiveLiveError with canonical received fields.
  LiveLiveError({
    Object? clientEventId = liveUnset,
    required Object? code,
    required this.message,
    Object? param = liveUnset,
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : clientEventId = _serverOptional<String>(
         clientEventId,
         'LiveLiveError.client_event_id',
         nullable: false,
       ),
       code = code == null
           ? null
           : requireLiveString(code, 'LiveLiveError.code'),
       param = _serverOptional<String>(
         param,
         'LiveLiveError.param',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveLiveError',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{
    'client_event_id',
    'code',
    'message',
    'param',
    'type',
  };

  /// The event_id of the client command that caused the error, when supplied.
  final String? clientEventId;

  /// A machine-readable code identifying the Live error, such as `unknown_parameter`.
  /// Required-present null is accepted only for the documented receive compatibility.
  final String? code;

  /// A human-readable explanation of the Live error.
  final String message;

  /// The parameter that caused the error, when applicable, such as `session.voice`.
  final String? param;

  /// The category of error, such as `invalid_request_error` for an invalid Live client command.
  final String type;

  /// Immutable finite original data; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveLiveError; wrong or missing known fields fail safely.
  factory LiveLiveError.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('code')) {
      throw const FormatException(
        'LiveLiveError.code: required field is missing',
      );
    }
    return LiveLiveError(
      clientEventId: json.containsKey('client_event_id')
          ? requireLiveString(
              json['client_event_id'],
              'LiveLiveError.client_event_id',
            )
          : liveUnset,
      code: json['code'] == null
          ? null
          : requireLiveString(json['code'], 'LiveLiveError.code'),
      message: requireLiveString(json['message'], 'LiveLiveError.message'),
      param: json.containsKey('param')
          ? requireLiveString(json['param'], 'LiveLiveError.param')
          : liveUnset,
      type: requireLiveString(json['type'], 'LiveLiveError.type'),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (clientEventId != null) 'client_event_id': clientEventId,
    'code': code,
    'message': message,
    if (param != null) 'param': param,
    'type': type,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveLiveError copyWith({
    Object? clientEventId = liveUnset,
    bool clearClientEventId = false,
    Object? code = liveUnset,
    Object? message = liveUnset,
    Object? param = liveUnset,
    bool clearParam = false,
    Object? type = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveLiveError(
    clientEventId: clearClientEventId
        ? liveUnset
        : (identical(clientEventId, liveUnset)
              ? (this.clientEventId ?? liveUnset)
              : clientEventId),
    code: identical(code, liveUnset)
        ? this.code
        : code == null
        ? null
        : requireLiveString(code, 'LiveLiveError.code'),
    message: identical(message, liveUnset)
        ? this.message
        : requireLiveString(message, 'LiveLiveError.message'),
    param: clearParam
        ? liveUnset
        : (identical(param, liveUnset) ? (this.param ?? liveUnset) : param),
    type: identical(type, liveUnset)
        ? this.type
        : requireLiveString(type, 'LiveLiveError.type'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveLiveError.rawJson'),
  );
}

/// Cumulative audio duration for a Live session. Values are totals for the session, not increments to sum across usage events.
final class LiveSessionUsage extends LiveJsonModel {
  /// Creates LiveSessionUsage with canonical received fields.
  LiveSessionUsage({
    required num seconds,
    Map<String, dynamic> rawJson = const {},
  }) : seconds = requireLiveNumber(seconds, 'LiveSessionUsage.seconds'),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionUsage',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'seconds'};

  /// The cumulative Live audio duration in seconds. Do not sum this value across usage events.
  final double seconds;

  /// Immutable finite original data; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionUsage; wrong or missing known fields fail safely.
  factory LiveSessionUsage.fromJson(Map<String, dynamic> json) {
    return LiveSessionUsage(
      seconds: requireLiveNumber(json['seconds'], 'LiveSessionUsage.seconds'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireLiveNumber(seconds, 'LiveSessionUsage.seconds');
  }

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'seconds': seconds});

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveSessionUsage copyWith({
    Object? seconds = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveSessionUsage(
    seconds: identical(seconds, liveUnset)
        ? this.seconds
        : requireLiveNumber(seconds, 'LiveSessionUsage.seconds'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveSessionUsage.rawJson'),
  );
}

/// The latest measured context-window usage of the Live model. This is separate from billing usage and delegated Responses token usage.
final class LiveContextWindowUsage extends LiveJsonModel {
  /// Creates LiveContextWindowUsage with canonical received fields.
  LiveContextWindowUsage({
    required num usageRatio,
    Map<String, dynamic> rawJson = const {},
  }) : usageRatio = requireLiveNumber(
         usageRatio,
         'LiveContextWindowUsage.usage_ratio',
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveContextWindowUsage',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'usage_ratio'};

  /// The latest active context token count divided by the Live model context limit. Can decrease after compaction and may lag between measured audio frames.
  final double usageRatio;

  /// Immutable finite original data; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveContextWindowUsage; wrong or missing known fields fail safely.
  factory LiveContextWindowUsage.fromJson(Map<String, dynamic> json) {
    return LiveContextWindowUsage(
      usageRatio: requireLiveNumber(
        json['usage_ratio'],
        'LiveContextWindowUsage.usage_ratio',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireLiveNumber(usageRatio, 'LiveContextWindowUsage.usage_ratio');
  }

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'usage_ratio': usageRatio});

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveContextWindowUsage copyWith({
    Object? usageRatio = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveContextWindowUsage(
    usageRatio: identical(usageRatio, liveUnset)
        ? this.usageRatio
        : requireLiveNumber(usageRatio, 'LiveContextWindowUsage.usage_ratio'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveContextWindowUsage.rawJson'),
  );
}

/// Metadata for work delegated by the Live model. Client delegations are handled by your application; Responses delegations run on the configured backend.
final class LiveDelegationItem extends LiveJsonModel {
  /// Creates LiveDelegationItem with canonical received fields.
  LiveDelegationItem({
    required this.id,
    Object? responseId = liveUnset,
    required this.target,
    Map<String, dynamic> rawJson = const {},
  }) : responseId = _serverOptional<String>(
         responseId,
         'LiveDelegationItem.response_id',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDelegationItem',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'id', 'response_id', 'target', 'type'};

  /// The exact delegation object discriminator.
  String get type => 'delegation';

  /// The unique ID of the delegation. Use this as delegation_id when replying to client-owned work or correlating Responses events.
  final String id;

  /// The ID of the Responses API response associated with a Responses delegation. Omitted for client delegations.
  final String? responseId;

  /// Where the Live model delegated the work: `client` for your application, or `responses` for the configured Responses backend.
  final String target;

  /// Immutable finite original data; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveDelegationItem; wrong or missing known fields fail safely.
  factory LiveDelegationItem.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'delegation', 'LiveDelegationItem', key: 'type');
    return LiveDelegationItem(
      id: requireLiveString(json['id'], 'LiveDelegationItem.id'),
      responseId: json.containsKey('response_id')
          ? requireLiveString(
              json['response_id'],
              'LiveDelegationItem.response_id',
            )
          : liveUnset,
      target: requireLiveString(json['target'], 'LiveDelegationItem.target'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    if (!const <String>{'client', 'responses'}.contains(target)) {
      throw const FormatException(
        'LiveDelegationItem.target: unsupported canonical value',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'id': id,
    if (responseId != null) 'response_id': responseId,
    'target': target,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveDelegationItem copyWith({
    Object? id = liveUnset,
    Object? responseId = liveUnset,
    bool clearResponseId = false,
    Object? target = liveUnset,
    Object? rawJson = liveUnset,
  }) => LiveDelegationItem(
    id: identical(id, liveUnset)
        ? this.id
        : requireLiveString(id, 'LiveDelegationItem.id'),
    responseId: clearResponseId
        ? liveUnset
        : (identical(responseId, liveUnset)
              ? (this.responseId ?? liveUnset)
              : responseId),
    target: identical(target, liveUnset)
        ? this.target
        : requireLiveString(target, 'LiveDelegationItem.target'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveDelegationItem.rawJson'),
  );
}

/// LiveTransportCallError.
final class LiveTransportCallError extends LiveJsonModel {
  /// Creates LiveTransportCallError with canonical received fields.
  LiveTransportCallError({
    required this.code,
    required this.message,
    Object? param = liveUnset,
    Map<String, dynamic> rawJson = const {},
  }) : param = _serverOptional<String>(
         param,
         'LiveTransportCallError.param',
         nullable: false,
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveTransportCallError',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = <String>{'code', 'message', 'param', 'type'};

  /// The exact call error discriminator.
  String get type => 'call_error';

  /// The call setup failure code.
  final String code;

  /// Canonical received field.
  final String message;

  /// The parameter related to the error, if any. Empty when no parameter applies.
  final String? param;

  /// Immutable finite original data; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveTransportCallError; wrong or missing known fields fail safely.
  factory LiveTransportCallError.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'call_error', 'LiveTransportCallError', key: 'type');
    return LiveTransportCallError(
      code: requireLiveString(json['code'], 'LiveTransportCallError.code'),
      message: requireLiveString(
        json['message'],
        'LiveTransportCallError.message',
      ),
      param: json.containsKey('param')
          ? requireLiveString(json['param'], 'LiveTransportCallError.param')
          : liveUnset,
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    'code': code,
    'message': message,
    if (param != null) 'param': param,
  });

  /// Copies all fields. Explicit null is retained only where canonical receive permits it.
  /// Clear flags omit optional nonnull fields or remove nullable-field presence.
  LiveTransportCallError copyWith({
    Object? code = liveUnset,
    Object? message = liveUnset,
    Object? param = liveUnset,
    bool clearParam = false,
    Object? rawJson = liveUnset,
  }) => LiveTransportCallError(
    code: identical(code, liveUnset)
        ? this.code
        : requireLiveString(code, 'LiveTransportCallError.code'),
    message: identical(message, liveUnset)
        ? this.message
        : requireLiveString(message, 'LiveTransportCallError.message'),
    param: clearParam
        ? liveUnset
        : (identical(param, liveUnset) ? (this.param ?? liveUnset) : param),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'LiveTransportCallError.rawJson'),
  );
}

/// Immutable receive-only fallback for an unfamiliar event discriminator.
/// Known event tags cannot bypass their strict codecs through this class.
final class UnknownLiveServerEvent extends LiveServerEvent {
  /// Creates a future event while preserving finite caller-visible data.
  UnknownLiveServerEvent({
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(rawJson, 'UnknownLiveServerEvent') {
    validate();
  }

  @override
  final String type;

  @override
  final Map<String, dynamic> rawJson;

  /// Parses a future type without requiring or inferring correlation metadata.
  factory UnknownLiveServerEvent.fromJson(Map<String, dynamic> json) =>
      UnknownLiveServerEvent(
        type: requireLiveString(json['type'], 'UnknownLiveServerEvent.type'),
        rawJson: json,
      );

  @override
  void validate() {
    if (_knownServerEventTypes.contains(type)) {
      throw const FormatException(
        'UnknownLiveServerEvent.type: use the known event codec',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies a future event; known tags still require their proper codecs.
  UnknownLiveServerEvent copyWith({
    Object? type = liveUnset,
    Object? rawJson = liveUnset,
  }) => UnknownLiveServerEvent(
    type: identical(type, liveUnset)
        ? this.type
        : requireLiveString(type, 'UnknownLiveServerEvent.type'),
    rawJson: identical(rawJson, liveUnset)
        ? this.rawJson
        : requireLiveObject(rawJson, 'UnknownLiveServerEvent.rawJson'),
  );
}

T? _serverOptional<T>(Object? value, String context, {required bool nullable}) {
  if (identical(value, liveUnset)) return null;
  if (value == null) {
    if (nullable) return null;
    throw FormatException('$context: null is not allowed');
  }
  if (value is! T) {
    throw FormatException('$context: expected the declared field type');
  }
  if (value is num && !value.isFinite) {
    throw FormatException('$context: expected a finite number');
  }
  return value as T;
}

T _serverModel<T>(
  Object? value,
  String context,
  T Function(Map<String, dynamic>) parser,
) {
  try {
    return parser(requireLiveObject(value, context));
  } on FormatException catch (error) {
    throw FormatException('$context: ${error.message}');
  }
}

T _serverRequired<T>(Object? value, String context) {
  if (value is! T) {
    throw FormatException('$context: expected the declared field type');
  }
  return value;
}
