import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'audio_agent_config.dart';

/// An event published by the agent in the LiveKit room.
///
/// [VoiceAgentToolCallStartedEvent], [VoiceAgentToolCallEndedEvent], [VoiceAgentErrorEvent], [VoiceAgentTranscriptEvent], [VoiceAgentStateChangedEvent], [VoiceAgentSessionUpdatedEvent], or [UnknownVoiceAgentEvent].
@immutable
sealed class VoiceAgentEvent {
  const VoiceAgentEvent();

  /// Parses an API payload.
  factory VoiceAgentEvent.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'tool_call.started' => VoiceAgentToolCallStartedEvent.fromJson(json),
        'tool_call.ended' => VoiceAgentToolCallEndedEvent.fromJson(json),
        'error' => VoiceAgentErrorEvent.fromJson(json),
        'transcription.segment' => VoiceAgentTranscriptEvent.fromJson(json),
        'agent.state.changed' => VoiceAgentStateChangedEvent.fromJson(json),
        'session.updated' => VoiceAgentSessionUpdatedEvent.fromJson(json),
        _ => UnknownVoiceAgentEvent(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();

  /// The wire type.
  String get type;
}

/// A future VoiceAgentEvent value.
@immutable
final class UnknownVoiceAgentEvent extends VoiceAgentEvent {
  /// Creates a fallback from the original payload.
  UnknownVoiceAgentEvent(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  String get type => switch (raw['type']) {
    final String value => value,
    _ => 'unknown',
  };

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownVoiceAgentEvent && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// Values for VoiceAgentErrorSource.
enum VoiceAgentErrorSource {
  /// Represents stt.
  stt('stt'),

  /// Represents llm.
  llm('llm'),

  /// Represents tts.
  tts('tts'),

  /// Represents realtime_model.
  realtimeModel('realtime_model'),

  /// Represents interruption_detection.
  interruptionDetection('interruption_detection'),

  /// Represents agent.
  agent('agent'),

  /// Represents worker.
  worker('worker'),

  /// Represents transport.
  transport('transport'),

  /// Represents audio_interface.
  audioInterface('audio_interface'),

  /// Represents rest.
  rest('rest'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const VoiceAgentErrorSource(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static VoiceAgentErrorSource fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for VoiceAgentState.
enum VoiceAgentState {
  /// Represents initializing.
  initializing('initializing'),

  /// Represents idle.
  idle('idle'),

  /// Represents listening.
  listening('listening'),

  /// Represents thinking.
  thinking('thinking'),

  /// Represents speaking.
  speaking('speaking'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const VoiceAgentState(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static VoiceAgentState fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for VoiceAgentTranscriptRole.
enum VoiceAgentTranscriptRole {
  /// Represents user.
  user('user'),

  /// Represents assistant.
  assistant('assistant'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const VoiceAgentTranscriptRole(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static VoiceAgentTranscriptRole fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for VoiceAgentToolCallStatus.
enum VoiceAgentToolCallStatus {
  /// Represents done.
  done('done'),

  /// Represents error.
  error('error'),

  /// Represents cancelled.
  cancelled('cancelled'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const VoiceAgentToolCallStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static VoiceAgentToolCallStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The VoiceAgentToolCallStartedEvent wire payload.
@immutable
class VoiceAgentToolCallStartedEvent extends VoiceAgentEvent {
  /// Creates a [VoiceAgentToolCallStartedEvent].
  const VoiceAgentToolCallStartedEvent({
    required this.id,
    required this.name,
    required this.ts,
  });

  /// The fixed phase discriminator.
  String get phase => 'started';

  @override
  String get type => 'tool_call.started';

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The ts field.
  final double ts;

  /// Parses a [VoiceAgentToolCallStartedEvent] from JSON.
  factory VoiceAgentToolCallStartedEvent.fromJson(Map<String, dynamic> json) {
    if (json['phase'] case final value? when value != 'started') {
      throw FormatException(
        'VoiceAgentToolCallStartedEvent: unexpected phase $value',
      );
    }
    if (json['type'] case final value? when value != 'tool_call.started') {
      throw FormatException(
        'VoiceAgentToolCallStartedEvent: unexpected type $value',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('VoiceAgentToolCallStartedEvent: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException(
        'VoiceAgentToolCallStartedEvent: missing name',
      );
    }
    if (json['ts'] == null) {
      throw const FormatException('VoiceAgentToolCallStartedEvent: missing ts');
    }
    return VoiceAgentToolCallStartedEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      ts: (json['ts'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'phase': phase,
    'type': type,
    'id': id,
    'name': name,
    'ts': ts,
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentToolCallStartedEvent copyWith({
    String? id,
    String? name,
    double? ts,
  }) => VoiceAgentToolCallStartedEvent(
    id: id ?? this.id,
    name: name ?? this.name,
    ts: ts ?? this.ts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentToolCallStartedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ts == other.ts;

  @override
  int get hashCode => Object.hashAll([id, name, ts]);

  @override
  String toString() =>
      'VoiceAgentToolCallStartedEvent('
      'id: $id, '
      'name: $name, '
      'ts: $ts)';
}

/// `result` is the exact text the model received: the tool output, the error message when `status` is "error", or null when "cancelled".
@immutable
class VoiceAgentToolCallEndedEvent extends VoiceAgentEvent {
  /// Creates a [VoiceAgentToolCallEndedEvent].
  const VoiceAgentToolCallEndedEvent({
    required this.arguments,
    required this.id,
    required this.name,
    this.result,
    required this.status,
    required this.ts,
  });

  /// The fixed phase discriminator.
  String get phase => 'ended';

  @override
  String get type => 'tool_call.ended';

  /// The arguments field.
  final String arguments;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The result field.
  final String? result;

  /// The status field.
  final VoiceAgentToolCallStatus status;

  /// The ts field.
  final double ts;

  /// Parses a [VoiceAgentToolCallEndedEvent] from JSON.
  factory VoiceAgentToolCallEndedEvent.fromJson(Map<String, dynamic> json) {
    if (json['phase'] case final value? when value != 'ended') {
      throw FormatException(
        'VoiceAgentToolCallEndedEvent: unexpected phase $value',
      );
    }
    if (json['type'] case final value? when value != 'tool_call.ended') {
      throw FormatException(
        'VoiceAgentToolCallEndedEvent: unexpected type $value',
      );
    }
    if (json['arguments'] == null) {
      throw const FormatException(
        'VoiceAgentToolCallEndedEvent: missing arguments',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('VoiceAgentToolCallEndedEvent: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('VoiceAgentToolCallEndedEvent: missing name');
    }
    if (json['status'] == null) {
      throw const FormatException(
        'VoiceAgentToolCallEndedEvent: missing status',
      );
    }
    if (json['ts'] == null) {
      throw const FormatException('VoiceAgentToolCallEndedEvent: missing ts');
    }
    return VoiceAgentToolCallEndedEvent(
      arguments: json['arguments'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      result: json['result'] == null ? null : json['result'] as String,
      status: VoiceAgentToolCallStatus.fromJson(json['status'] as String),
      ts: (json['ts'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'phase': phase,
    'type': type,
    'arguments': arguments,
    'id': id,
    'name': name,
    'result': ?result,
    'status': status.toJson(),
    'ts': ts,
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentToolCallEndedEvent copyWith({
    String? arguments,
    String? id,
    String? name,
    Object? result = unsetCopyWithValue,
    VoiceAgentToolCallStatus? status,
    double? ts,
  }) => VoiceAgentToolCallEndedEvent(
    arguments: arguments ?? this.arguments,
    id: id ?? this.id,
    name: name ?? this.name,
    result: result == unsetCopyWithValue ? this.result : result as String?,
    status: status ?? this.status,
    ts: ts ?? this.ts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentToolCallEndedEvent &&
          runtimeType == other.runtimeType &&
          arguments == other.arguments &&
          id == other.id &&
          name == other.name &&
          result == other.result &&
          status == other.status &&
          ts == other.ts;

  @override
  int get hashCode => Object.hashAll([arguments, id, name, result, status, ts]);

  @override
  String toString() =>
      'VoiceAgentToolCallEndedEvent('
      'arguments: $arguments, '
      'id: $id, '
      'name: $name, '
      'result: $result, '
      'status: $status, '
      'ts: $ts)';
}

/// Shared error envelope for worker and SDK failures.
@immutable
class VoiceAgentErrorEvent extends VoiceAgentEvent {
  /// Creates a [VoiceAgentErrorEvent].
  const VoiceAgentErrorEvent({
    required this.code,
    required this.fatal,
    required this.message,
    this.payload,
    required this.source,
  });

  @override
  String get type => 'error';

  /// The code field.
  final String code;

  /// The fatal field.
  final bool fatal;

  /// The message field.
  final String message;

  /// The payload field.
  final Map<String, dynamic>? payload;

  /// The source field.
  final VoiceAgentErrorSource source;

  /// Parses a [VoiceAgentErrorEvent] from JSON.
  factory VoiceAgentErrorEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'error') {
      throw FormatException('VoiceAgentErrorEvent: unexpected type $value');
    }
    if (json['code'] == null) {
      throw const FormatException('VoiceAgentErrorEvent: missing code');
    }
    if (json['fatal'] == null) {
      throw const FormatException('VoiceAgentErrorEvent: missing fatal');
    }
    if (json['message'] == null) {
      throw const FormatException('VoiceAgentErrorEvent: missing message');
    }
    if (json['source'] == null) {
      throw const FormatException('VoiceAgentErrorEvent: missing source');
    }
    return VoiceAgentErrorEvent(
      code: json['code'] as String,
      fatal: json['fatal'] as bool,
      message: json['message'] as String,
      payload: json['payload'] == null
          ? null
          : json['payload'] as Map<String, dynamic>,
      source: VoiceAgentErrorSource.fromJson(json['source'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'code': code,
    'fatal': fatal,
    'message': message,
    'payload': ?payload,
    'source': source.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentErrorEvent copyWith({
    String? code,
    bool? fatal,
    String? message,
    Object? payload = unsetCopyWithValue,
    VoiceAgentErrorSource? source,
  }) => VoiceAgentErrorEvent(
    code: code ?? this.code,
    fatal: fatal ?? this.fatal,
    message: message ?? this.message,
    payload: payload == unsetCopyWithValue
        ? this.payload
        : (payload as Map?)?.cast<String, dynamic>(),
    source: source ?? this.source,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentErrorEvent &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          fatal == other.fatal &&
          message == other.message &&
          valuesDeepEqual(payload, other.payload) &&
          source == other.source;

  @override
  int get hashCode => Object.hashAll([
    code,
    fatal,
    message,
    valueDeepHashCode(payload),
    source,
  ]);

  @override
  String toString() =>
      'VoiceAgentErrorEvent('
      'code: $code, '
      'fatal: $fatal, '
      'message: $message, '
      'payload: ${payload?.length}, '
      'source: $source)';
}

/// Cumulative segment text. Updates with the same id replace earlier text.
@immutable
class VoiceAgentTranscriptEvent extends VoiceAgentEvent {
  /// Creates a [VoiceAgentTranscriptEvent].
  const VoiceAgentTranscriptEvent({
    required this.content,
    this.endTime,
    required this.isFinal,
    required this.id,
    this.language,
    required this.role,
    this.startTime,
    required this.ts,
  });

  @override
  String get type => 'transcription.segment';

  /// The content field.
  final String content;

  /// The end_time field.
  final double? endTime;

  /// The final field.
  final bool isFinal;

  /// The id field.
  final String id;

  /// The language field.
  final String? language;

  /// The role field.
  final VoiceAgentTranscriptRole role;

  /// The start_time field.
  final double? startTime;

  /// The ts field.
  final double ts;

  /// Parses a [VoiceAgentTranscriptEvent] from JSON.
  factory VoiceAgentTranscriptEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'transcription.segment') {
      throw FormatException(
        'VoiceAgentTranscriptEvent: unexpected type $value',
      );
    }
    if (json['content'] == null) {
      throw const FormatException('VoiceAgentTranscriptEvent: missing content');
    }
    if (json['final'] == null) {
      throw const FormatException('VoiceAgentTranscriptEvent: missing final');
    }
    if (json['id'] == null) {
      throw const FormatException('VoiceAgentTranscriptEvent: missing id');
    }
    if (json['role'] == null) {
      throw const FormatException('VoiceAgentTranscriptEvent: missing role');
    }
    if (json['ts'] == null) {
      throw const FormatException('VoiceAgentTranscriptEvent: missing ts');
    }
    return VoiceAgentTranscriptEvent(
      content: json['content'] as String,
      endTime: json['end_time'] == null
          ? null
          : (json['end_time'] as num).toDouble(),
      isFinal: json['final'] as bool,
      id: json['id'] as String,
      language: json['language'] == null ? null : json['language'] as String,
      role: VoiceAgentTranscriptRole.fromJson(json['role'] as String),
      startTime: json['start_time'] == null
          ? null
          : (json['start_time'] as num).toDouble(),
      ts: (json['ts'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'content': content,
    'end_time': ?endTime,
    'final': isFinal,
    'id': id,
    'language': ?language,
    'role': role.toJson(),
    'start_time': ?startTime,
    'ts': ts,
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentTranscriptEvent copyWith({
    String? content,
    Object? endTime = unsetCopyWithValue,
    bool? isFinal,
    String? id,
    Object? language = unsetCopyWithValue,
    VoiceAgentTranscriptRole? role,
    Object? startTime = unsetCopyWithValue,
    double? ts,
  }) => VoiceAgentTranscriptEvent(
    content: content ?? this.content,
    endTime: endTime == unsetCopyWithValue
        ? this.endTime
        : (endTime as num?)?.toDouble(),
    isFinal: isFinal ?? this.isFinal,
    id: id ?? this.id,
    language: language == unsetCopyWithValue
        ? this.language
        : language as String?,
    role: role ?? this.role,
    startTime: startTime == unsetCopyWithValue
        ? this.startTime
        : (startTime as num?)?.toDouble(),
    ts: ts ?? this.ts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentTranscriptEvent &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          endTime == other.endTime &&
          isFinal == other.isFinal &&
          id == other.id &&
          language == other.language &&
          role == other.role &&
          startTime == other.startTime &&
          ts == other.ts;

  @override
  int get hashCode => Object.hashAll([
    content,
    endTime,
    isFinal,
    id,
    language,
    role,
    startTime,
    ts,
  ]);

  @override
  String toString() =>
      'VoiceAgentTranscriptEvent('
      'content: $content, '
      'endTime: $endTime, '
      'isFinal: $isFinal, '
      'id: $id, '
      'language: $language, '
      'role: $role, '
      'startTime: $startTime, '
      'ts: $ts)';
}

/// The VoiceAgentStateChangedEvent wire payload.
@immutable
class VoiceAgentStateChangedEvent extends VoiceAgentEvent {
  /// Creates a [VoiceAgentStateChangedEvent].
  const VoiceAgentStateChangedEvent({
    required this.oldState,
    required this.state,
    required this.ts,
  });

  @override
  String get type => 'agent.state.changed';

  /// The old_state field.
  final VoiceAgentState oldState;

  /// The state field.
  final VoiceAgentState state;

  /// The ts field.
  final double ts;

  /// Parses a [VoiceAgentStateChangedEvent] from JSON.
  factory VoiceAgentStateChangedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'agent.state.changed') {
      throw FormatException(
        'VoiceAgentStateChangedEvent: unexpected type $value',
      );
    }
    if (json['old_state'] == null) {
      throw const FormatException(
        'VoiceAgentStateChangedEvent: missing old_state',
      );
    }
    if (json['state'] == null) {
      throw const FormatException('VoiceAgentStateChangedEvent: missing state');
    }
    if (json['ts'] == null) {
      throw const FormatException('VoiceAgentStateChangedEvent: missing ts');
    }
    return VoiceAgentStateChangedEvent(
      oldState: VoiceAgentState.fromJson(json['old_state'] as String),
      state: VoiceAgentState.fromJson(json['state'] as String),
      ts: (json['ts'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'old_state': oldState.toJson(),
    'state': state.toJson(),
    'ts': ts,
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentStateChangedEvent copyWith({
    VoiceAgentState? oldState,
    VoiceAgentState? state,
    double? ts,
  }) => VoiceAgentStateChangedEvent(
    oldState: oldState ?? this.oldState,
    state: state ?? this.state,
    ts: ts ?? this.ts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentStateChangedEvent &&
          runtimeType == other.runtimeType &&
          oldState == other.oldState &&
          state == other.state &&
          ts == other.ts;

  @override
  int get hashCode => Object.hashAll([oldState, state, ts]);

  @override
  String toString() =>
      'VoiceAgentStateChangedEvent('
      'oldState: $oldState, '
      'state: $state, '
      'ts: $ts)';
}

/// The committed voice session configuration, broadcast to room participants.
@immutable
class VoiceAgentSessionUpdatedEvent extends VoiceAgentEvent {
  /// Creates a [VoiceAgentSessionUpdatedEvent].
  const VoiceAgentSessionUpdatedEvent({
    required this.ts,
    required this.session,
  });

  @override
  String get type => 'session.updated';

  /// The ts field.
  final double ts;

  /// The session field.
  final AudioAgentConfigurationSnapshot session;

  /// Parses a [VoiceAgentSessionUpdatedEvent] from JSON.
  factory VoiceAgentSessionUpdatedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'session.updated') {
      throw FormatException(
        'VoiceAgentSessionUpdatedEvent: unexpected type $value',
      );
    }
    if (json['ts'] == null) {
      throw const FormatException('VoiceAgentSessionUpdatedEvent: missing ts');
    }
    if (json['session'] == null) {
      throw const FormatException(
        'VoiceAgentSessionUpdatedEvent: missing session',
      );
    }
    return VoiceAgentSessionUpdatedEvent(
      ts: (json['ts'] as num).toDouble(),
      session: AudioAgentConfigurationSnapshot.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'ts': ts,
    'session': session.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentSessionUpdatedEvent copyWith({
    double? ts,
    AudioAgentConfigurationSnapshot? session,
  }) => VoiceAgentSessionUpdatedEvent(
    ts: ts ?? this.ts,
    session: session ?? this.session,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentSessionUpdatedEvent &&
          runtimeType == other.runtimeType &&
          ts == other.ts &&
          session == other.session;

  @override
  int get hashCode => Object.hashAll([ts, session]);

  @override
  String toString() =>
      'VoiceAgentSessionUpdatedEvent('
      'ts: $ts, '
      'session: $session)';
}
