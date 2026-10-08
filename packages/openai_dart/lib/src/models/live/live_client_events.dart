import 'package:meta/meta.dart';

import 'live_config.dart';
import 'live_input_item.dart';
import 'live_json_helpers.dart';

/// Writable Live commands with strict known discriminators.
///
/// Primary commands are [LiveSessionStartEvent], [LiveSessionUpdateParam],
/// [LiveInputAudioAppendEvent], [LiveInputAudioMuteParam],
/// [LiveInputAudioUnmuteParam], [LiveInstructionsAppendParam],
/// [LiveThinkingAppendParam], [LiveCommentaryAppendParam],
/// [LiveResponseItemCreateParam], [LiveResponseCreateParam], and
/// [LiveSessionCloseParam]. [LiveForkSessionStartEvent] is the distinct stored
/// fork startup codec and is accepted only by [LiveClientEvent.fromForkJson].
/// These models never send commands or replay audio themselves.
@immutable
sealed class LiveClientEvent extends LiveJsonModel {
  /// Creates a command correlation value.
  const LiveClientEvent({this.eventId, bool hasEventId = false})
    : hasEventId = hasEventId || eventId != null;

  /// Optional caller correlation ID, limited to 512 Unicode code points.
  /// Explicit null differs from omission on the wire.
  final String? eventId;

  /// Whether the optional nullable `event_id` member is present.
  final bool hasEventId;

  /// The fixed canonical command discriminator.
  String get type;

  /// Parses the eleven commands accepted by a primary Live WebSocket.
  factory LiveClientEvent.fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(json['type'], 'LiveClientEvent.type');
    return switch (type) {
      'session.start' => LiveSessionStartEvent.fromJson(json),
      'session.update' => LiveSessionUpdateParam.fromJson(json),
      'session.input_audio.append' => LiveInputAudioAppendEvent.fromJson(json),
      'session.input_audio.mute' => LiveInputAudioMuteParam.fromJson(json),
      'session.input_audio.unmute' => LiveInputAudioUnmuteParam.fromJson(json),
      'session.instructions.append' => LiveInstructionsAppendParam.fromJson(
        json,
      ),
      'session.thinking.append' => LiveThinkingAppendParam.fromJson(json),
      'session.commentary.append' => LiveCommentaryAppendParam.fromJson(json),
      'response.item.create' => LiveResponseItemCreateParam.fromJson(json),
      'response.create' => LiveResponseCreateParam.fromJson(json),
      'session.close' => LiveSessionCloseParam.fromJson(json),
      _ => throw const FormatException(
        'LiveClientEvent.type: unsupported command',
      ),
    };
  }

  /// Parses the fork union, reusing every ordinary command except startup.
  /// This codec does not connect to or start a stored fork.
  factory LiveClientEvent.fromForkJson(Map<String, dynamic> json) {
    if (json['type'] == 'session.start') {
      return LiveForkSessionStartEvent.fromJson(json);
    }
    return LiveClientEvent.fromJson(json);
  }

  @override
  void validate() {
    if (eventId != null) {
      validateLiveLength(eventId!, 'LiveClientEvent.event_id', max: 512);
    }
  }

  @override
  Map<String, dynamic> toJson();
}

/// The nine commands supported by an already-started sideband session.
///
/// Includes [LiveSessionUpdateParam], [LiveInputAudioMuteParam],
/// [LiveInputAudioUnmuteParam], [LiveInstructionsAppendParam],
/// [LiveThinkingAppendParam], [LiveCommentaryAppendParam],
/// [LiveResponseItemCreateParam], [LiveResponseCreateParam], and
/// [LiveSessionCloseParam]. Primary/fork startup and audio append are excluded.
@immutable
sealed class LiveSidebandClientEvent extends LiveClientEvent {
  /// Creates an optional command correlation value.
  const LiveSidebandClientEvent({super.eventId, super.hasEventId});

  /// Parses only canonical sideband command branches.
  factory LiveSidebandClientEvent.fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(
      json['type'],
      'LiveSidebandClientEvent.type',
    );
    return switch (type) {
      'session.update' => LiveSessionUpdateParam.fromJson(json),
      'session.input_audio.mute' => LiveInputAudioMuteParam.fromJson(json),
      'session.input_audio.unmute' => LiveInputAudioUnmuteParam.fromJson(json),
      'session.instructions.append' => LiveInstructionsAppendParam.fromJson(
        json,
      ),
      'session.thinking.append' => LiveThinkingAppendParam.fromJson(json),
      'session.commentary.append' => LiveCommentaryAppendParam.fromJson(json),
      'response.item.create' => LiveResponseItemCreateParam.fromJson(json),
      'response.create' => LiveResponseCreateParam.fromJson(json),
      'session.close' => LiveSessionCloseParam.fromJson(json),
      _ => throw const FormatException(
        'LiveSidebandClientEvent.type: unsupported command',
      ),
    };
  }
}

/// Start a Live session on a primary WebSocket. Send this event before other commands and wait for `session.started`.
@immutable
final class LiveSessionStartEvent extends LiveClientEvent {
  /// Creates the canonical `session.start` command.
  LiveSessionStartEvent({
    required this.session,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionStartEvent',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'session', 'type'};

  /// Initial configuration for a primary WebSocket. Send session.start first and wait for session.started before application commands. WebRTC creation already starts the session; do not send this event again on its data channel.
  final LiveSessionCreateParams session;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.start';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveSessionStartEvent.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.start', 'LiveSessionStartEvent');
    return LiveSessionStartEvent(
      session: _requiredClientField(
        json,
        'session',
        'LiveSessionStartEvent',
        (value, context) =>
            LiveSessionCreateParams.fromJson(requireLiveObject(value, context)),
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveSessionStartEvent',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    session.validateForTransport('websocket');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'session': session.toJson(),
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveSessionStartEvent copyWith({
    LiveSessionCreateParams? session,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionStartEvent(
    session: session ?? this.session,
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveSessionStartEvent.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionStartEvent('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'session: ${livePresence(session)}, '
      'rawJson: [REDACTED])';
}

/// Start a Live session after connecting to a stored session’s fork WebSocket. Send an empty `session` object to use the stored configuration.
@immutable
final class LiveForkSessionStartEvent extends LiveClientEvent {
  /// Creates the canonical `session.start` command.
  LiveForkSessionStartEvent({
    required this.session,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveForkSessionStartEvent',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'session', 'type'};

  /// Overrides for a stored session after connecting to the fork WebSocket. An empty object inherits the stored configuration; do not supply a new model. audio.format applies only to the new WebSocket connection. client overrides are only supported for WebRTC forks.
  final LiveForkSessionConfigParam session;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.start';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveForkSessionStartEvent.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.start', 'LiveForkSessionStartEvent');
    return LiveForkSessionStartEvent(
      session: _requiredClientField(
        json,
        'session',
        'LiveForkSessionStartEvent',
        (value, context) => LiveForkSessionConfigParam.fromJson(
          requireLiveObject(value, context),
        ),
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveForkSessionStartEvent',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    session.validateForTransport('websocket');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'session': session.toJson(),
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveForkSessionStartEvent copyWith({
    LiveForkSessionConfigParam? session,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveForkSessionStartEvent(
    session: session ?? this.session,
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveForkSessionStartEvent.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveForkSessionStartEvent('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'session: ${livePresence(session)}, '
      'rawJson: [REDACTED])';
}

/// Update the delegation settings of an active Live session. The server acknowledges accepted changes with `session.updated`.
@immutable
final class LiveSessionUpdateParam extends LiveSidebandClientEvent {
  /// Creates the canonical `session.update` command.
  LiveSessionUpdateParam({
    required this.session,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionUpdateParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'session', 'type'};

  /// Sparse delegation updates. Omitted settings retain their values. The delegation type cannot change, including resetting Responses delegation to null or client. Model, frontend instructions, audio, and startup input are immutable.
  final LiveSessionUpdateParams session;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.update';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveSessionUpdateParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.update', 'LiveSessionUpdateParam');
    return LiveSessionUpdateParam(
      session: _requiredClientField(
        json,
        'session',
        'LiveSessionUpdateParam',
        (value, context) =>
            LiveSessionUpdateParams.fromJson(requireLiveObject(value, context)),
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveSessionUpdateParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'session': session.toJson(),
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveSessionUpdateParam copyWith({
    LiveSessionUpdateParams? session,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionUpdateParam(
    session: session ?? this.session,
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveSessionUpdateParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionUpdateParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'session: ${livePresence(session)}, '
      'rawJson: [REDACTED])';
}

/// Send audio to a Live session over its primary WebSocket. WebRTC and SIP sessions send audio over their media transport.
@immutable
final class LiveInputAudioAppendEvent extends LiveClientEvent {
  /// Creates the canonical `session.input_audio.append` command.
  LiveInputAudioAppendEvent({
    required this.audio,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInputAudioAppendEvent',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'audio', 'event_id', 'type'};

  /// Base64-encoded raw audio in the startup-selected format, without a WAV or other container header. Primary WebSocket only; media transports use their audio track. Audio appends have no acknowledgment. Reflected sideband server events reuse this event type and audio key, with no timestamps or event_id; their audio is always mono PCM16LE at 24 kHz.
  final String audio;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.input_audio.append';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveInputAudioAppendEvent.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.input_audio.append',
      'LiveInputAudioAppendEvent',
    );
    return LiveInputAudioAppendEvent(
      audio: requireLiveString(
        json['audio'],
        'LiveInputAudioAppendEvent.audio',
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveInputAudioAppendEvent',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    validateLiveLength(audio, 'LiveInputAudioAppendEvent.audio', min: 1);
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'audio': audio,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveInputAudioAppendEvent copyWith({
    String? audio,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveInputAudioAppendEvent(
    audio: audio ?? this.audio,
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveInputAudioAppendEvent.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInputAudioAppendEvent('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'audio: ${livePresence(audio)}, '
      'rawJson: [REDACTED])';
}

/// Mute audio input to the Live model without closing the session. The server acknowledges with `session.input_audio.muted`.
@immutable
final class LiveInputAudioMuteParam extends LiveSidebandClientEvent {
  /// Creates the canonical `session.input_audio.mute` command.
  LiveInputAudioMuteParam({
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInputAudioMuteParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'type'};

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.input_audio.mute';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveInputAudioMuteParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.input_audio.mute',
      'LiveInputAudioMuteParam',
    );
    return LiveInputAudioMuteParam(
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveInputAudioMuteParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveInputAudioMuteParam copyWith({
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveInputAudioMuteParam(
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveInputAudioMuteParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInputAudioMuteParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'rawJson: [REDACTED])';
}

/// Resume audio input to a Live model after muting it. The server acknowledges with `session.input_audio.unmuted`.
@immutable
final class LiveInputAudioUnmuteParam extends LiveSidebandClientEvent {
  /// Creates the canonical `session.input_audio.unmute` command.
  LiveInputAudioUnmuteParam({
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInputAudioUnmuteParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'type'};

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.input_audio.unmute';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveInputAudioUnmuteParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.input_audio.unmute',
      'LiveInputAudioUnmuteParam',
    );
    return LiveInputAudioUnmuteParam(
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveInputAudioUnmuteParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveInputAudioUnmuteParam copyWith({
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveInputAudioUnmuteParam(
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveInputAudioUnmuteParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInputAudioUnmuteParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'rawJson: [REDACTED])';
}

/// Append instructions to the Live conversation while it is running, optionally associating them with an existing client delegation.
@immutable
final class LiveInstructionsAppendParam extends LiveSidebandClientEvent {
  /// Creates the canonical `session.instructions.append` command.
  LiveInstructionsAppendParam({
    required this.content,
    required this.delegationId,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInstructionsAppendParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'content', 'delegation_id', 'event_id', 'type'};

  /// Instruction text to append, limited to 500 tokens. This is a plain string, not an array of content parts.
  final String content;

  /// Canonical command payload.
  final String? delegationId;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.instructions.append';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveInstructionsAppendParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.instructions.append',
      'LiveInstructionsAppendParam',
    );
    return LiveInstructionsAppendParam(
      content: requireLiveString(
        json['content'],
        'LiveInstructionsAppendParam.content',
      ),
      delegationId: _requiredNullableClientString(
        json,
        'delegation_id',
        'LiveInstructionsAppendParam',
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveInstructionsAppendParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    if (delegationId != null) {
      validateLiveLength(
        delegationId!,
        'LiveInstructionsAppendParam.delegation_id',
        min: 1,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'content': content,
    'delegation_id': delegationId,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveInstructionsAppendParam copyWith({
    String? content,
    Object? delegationId = liveUnset,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveInstructionsAppendParam(
    content: content ?? this.content,
    delegationId: copyLiveValue<String>(
      delegationId,
      this.delegationId,
      'LiveInstructionsAppendParam.delegation_id',
    ),
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveInstructionsAppendParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInstructionsAppendParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'content: ${livePresence(content)}, '
      'delegationId: ${livePresence(delegationId)}, '
      'rawJson: [REDACTED])';
}

/// Provide silent reasoning or progress context to the Live model, optionally for an existing client delegation.
@immutable
final class LiveThinkingAppendParam extends LiveSidebandClientEvent {
  /// Creates the canonical `session.thinking.append` command.
  LiveThinkingAppendParam({
    required this.content,
    required this.delegationId,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveThinkingAppendParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'content', 'delegation_id', 'event_id', 'type'};

  /// Silent reasoning or progress context, limited to 500 tokens. It does not directly request speech, but can influence later speech and is not a secrecy boundary.
  final String content;

  /// Canonical command payload.
  final String? delegationId;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.thinking.append';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveThinkingAppendParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.thinking.append', 'LiveThinkingAppendParam');
    return LiveThinkingAppendParam(
      content: requireLiveString(
        json['content'],
        'LiveThinkingAppendParam.content',
      ),
      delegationId: _requiredNullableClientString(
        json,
        'delegation_id',
        'LiveThinkingAppendParam',
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveThinkingAppendParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    if (delegationId != null) {
      validateLiveLength(
        delegationId!,
        'LiveThinkingAppendParam.delegation_id',
        min: 1,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'content': content,
    'delegation_id': delegationId,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveThinkingAppendParam copyWith({
    String? content,
    Object? delegationId = liveUnset,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveThinkingAppendParam(
    content: content ?? this.content,
    delegationId: copyLiveValue<String>(
      delegationId,
      this.delegationId,
      'LiveThinkingAppendParam.delegation_id',
    ),
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveThinkingAppendParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveThinkingAppendParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'content: ${livePresence(content)}, '
      'delegationId: ${livePresence(delegationId)}, '
      'rawJson: [REDACTED])';
}

/// Provide context the Live model can communicate to the user, optionally for an existing client delegation.
@immutable
final class LiveCommentaryAppendParam extends LiveSidebandClientEvent {
  /// Creates the canonical `session.commentary.append` command.
  LiveCommentaryAppendParam({
    required this.content,
    required this.delegationId,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveCommentaryAppendParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'content', 'delegation_id', 'event_id', 'type'};

  /// Speakable context for the Live model, limited to 500 tokens. Use this for a result the model should communicate; use session.thinking.append for silent context.
  final String content;

  /// Canonical command payload.
  final String? delegationId;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.commentary.append';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveCommentaryAppendParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'session.commentary.append',
      'LiveCommentaryAppendParam',
    );
    return LiveCommentaryAppendParam(
      content: requireLiveString(
        json['content'],
        'LiveCommentaryAppendParam.content',
      ),
      delegationId: _requiredNullableClientString(
        json,
        'delegation_id',
        'LiveCommentaryAppendParam',
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveCommentaryAppendParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    if (delegationId != null) {
      validateLiveLength(
        delegationId!,
        'LiveCommentaryAppendParam.delegation_id',
        min: 1,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'content': content,
    'delegation_id': delegationId,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveCommentaryAppendParam copyWith({
    String? content,
    Object? delegationId = liveUnset,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveCommentaryAppendParam(
    content: content ?? this.content,
    delegationId: copyLiveValue<String>(
      delegationId,
      this.delegationId,
      'LiveCommentaryAppendParam.delegation_id',
    ),
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveCommentaryAppendParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveCommentaryAppendParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'content: ${livePresence(content)}, '
      'delegationId: ${livePresence(delegationId)}, '
      'rawJson: [REDACTED])';
}

/// Add an input item to the Live session’s Responses backend. Requires Responses delegation; use `response.create` to request a response.
@immutable
final class LiveResponseItemCreateParam extends LiveSidebandClientEvent {
  /// Creates the canonical `response.item.create` command.
  LiveResponseItemCreateParam({
    required this.item,
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponseItemCreateParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'item', 'type'};

  /// An input item to append to the Responses backend conversation, such as a user message or a function tool result.
  final LiveInputItem item;

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'response.item.create';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveResponseItemCreateParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'response.item.create',
      'LiveResponseItemCreateParam',
    );
    return LiveResponseItemCreateParam(
      item: _requiredClientField(
        json,
        'item',
        'LiveResponseItemCreateParam',
        (value, context) =>
            LiveInputItem.fromJson(requireLiveObject(value, context)),
      ),
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveResponseItemCreateParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    item.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
    'item': item.toJson(),
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveResponseItemCreateParam copyWith({
    LiveInputItem? item,
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveResponseItemCreateParam(
    item: item ?? this.item,
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveResponseItemCreateParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveResponseItemCreateParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'item: ${livePresence(item)}, '
      'rawJson: [REDACTED])';
}

/// Request a response from the Live session’s Responses backend, or continue a delegated response waiting for tool results. Requires Responses delegation.
@immutable
final class LiveResponseCreateParam extends LiveSidebandClientEvent {
  /// Creates the canonical `response.create` command.
  LiveResponseCreateParam({
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveResponseCreateParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'type'};

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'response.create';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveResponseCreateParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'response.create', 'LiveResponseCreateParam');
    return LiveResponseCreateParam(
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveResponseCreateParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveResponseCreateParam copyWith({
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveResponseCreateParam(
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveResponseCreateParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveResponseCreateParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'rawJson: [REDACTED])';
}

/// Request that the Live session close. The terminal `session.closed` event contains the close reason and final usage.
@immutable
final class LiveSessionCloseParam extends LiveSidebandClientEvent {
  /// Creates the canonical `session.close` command.
  LiveSessionCloseParam({
    super.eventId,
    super.hasEventId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionCloseParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'event_id', 'type'};

  /// Immutable finite future metadata; typed fields control known wire keys.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'session.close';

  /// Parses every declared field, preserving nullable correlation presence.
  factory LiveSessionCloseParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'session.close', 'LiveSessionCloseParam');
    return LiveSessionCloseParam(
      eventId: optionalLiveValue(
        json,
        'event_id',
        'LiveSessionCloseParam',
        requireLiveString,
        nullable: true,
      ),
      hasEventId: json.containsKey('event_id'),
      rawJson: json,
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'type': type,
    if (hasEventId) 'event_id': eventId,
  });

  /// Copies all fields; null emits null and clearEventId removes correlation.
  LiveSessionCloseParam copyWith({
    Object? eventId = liveUnset,
    bool clearEventId = false,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionCloseParam(
    eventId: clearEventId
        ? null
        : copyLiveValue<String>(
            eventId,
            this.eventId,
            'LiveSessionCloseParam.event_id',
          ),
    hasEventId: !clearEventId && (!identical(eventId, liveUnset) || hasEventId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionCloseParam('
      'type: $type, '
      'eventId: ${livePresence(eventId)}, '
      'hasEventId: $hasEventId, '
      'rawJson: [REDACTED])';
}

T _requiredClientField<T>(
  Map<String, dynamic> json,
  String key,
  String context,
  T Function(Object?, String) parse,
) {
  if (!json.containsKey(key)) {
    throw FormatException('$context.$key: required field');
  }
  try {
    return parse(json[key], '$context.$key');
  } on FormatException catch (error) {
    final field = '$context.$key';
    throw FormatException(
      error.message.startsWith(field)
          ? error.message
          : '$field: ${error.message}',
    );
  }
}

String? _requiredNullableClientString(
  Map<String, dynamic> json,
  String key,
  String context,
) {
  if (!json.containsKey(key)) {
    throw FormatException('$context.$key: required nullable field');
  }
  final value = json[key];
  return value == null ? null : requireLiveString(value, '$context.$key');
}
