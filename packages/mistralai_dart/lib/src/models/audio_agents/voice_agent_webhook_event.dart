import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';

/// A Voice Agent webhook delivery to the backend.
@immutable
sealed class VoiceAgentWebhookEvent {
  const VoiceAgentWebhookEvent({required this.createdAt});

  /// Decodes a delivery. Verify its signature before trusting the payload.
  factory VoiceAgentWebhookEvent.fromJson(Map<String, dynamic> json) {
    final event = _required<String>(json, 'event');
    final createdAt = DateTime.tryParse(
      _required<String>(json, 'created_at'),
    )?.toUtc();
    if (createdAt == null) {
      throw const FormatException('Invalid Voice Agent webhook timestamp.');
    }
    final data = _required<Map<String, dynamic>>(json, 'data');
    switch (event) {
      case 'call_started':
        return VoiceAgentCallStartedEvent(
          createdAt: createdAt,
          sessionId: _required<String>(data, 'session_id'),
          agentId: _required<String>(data, 'agent_id'),
          model: _required<String>(data, 'model'),
          startedAtUnixSeconds: _required<int>(data, 'started_at'),
        );
      case 'call_ended':
        return VoiceAgentCallEndedEvent(
          createdAt: createdAt,
          sessionId: _required<String>(data, 'session_id'),
          agentId: _required<String>(data, 'agent_id'),
          model: _required<String>(data, 'model'),
          startedAtUnixSeconds: _required<int>(data, 'started_at'),
          endedAtUnixSeconds: _required<int>(data, 'ended_at'),
          durationSeconds: _required<int>(data, 'duration_seconds'),
          transcript: (data['transcript'] as List<Object?>?)?.map(
            (item) => VoiceAgentWebhookTranscriptTurn.fromJson(
              item! as Map<String, dynamic>,
            ),
          ),
        );
      case 'call_failed':
        return VoiceAgentCallFailedEvent(
          createdAt: createdAt,
          sessionId: _required<String>(data, 'session_id'),
          agentId: _required<String>(data, 'agent_id'),
          model: _required<String>(data, 'model'),
          error: _required<String>(data, 'error'),
        );
      default:
        return UnknownVoiceAgentWebhookEvent._(event, createdAt, json);
    }
  }

  /// Time at which Mistral emitted the event.
  final DateTime createdAt;

  /// Event discriminator on the wire.
  String get event;

  /// Serializes the parsed delivery.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentWebhookEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'VoiceAgentWebhookEvent(event: $event, createdAt: $createdAt)';
}

/// Common metadata on the documented call lifecycle events.
@immutable
sealed class VoiceAgentCallWebhookEvent extends VoiceAgentWebhookEvent {
  const VoiceAgentCallWebhookEvent({
    required super.createdAt,
    required this.sessionId,
    required this.agentId,
    required this.model,
  });

  /// Session identifier as reported by the delivery.
  final String sessionId;

  /// Agent that handled the call.
  final String agentId;

  /// Model used by the agent.
  final String model;

  Map<String, dynamic> _dataToJson() => {
    'session_id': sessionId,
    'agent_id': agentId,
    'model': model,
  };

  @override
  Map<String, dynamic> toJson() => {
    'event': event,
    'created_at': createdAt.toUtc().toIso8601String(),
    'data': _dataToJson(),
  };
}

/// The session was created and the voice pipeline is ready.
final class VoiceAgentCallStartedEvent extends VoiceAgentCallWebhookEvent {
  /// Creates a call start delivery.
  const VoiceAgentCallStartedEvent({
    required super.createdAt,
    required super.sessionId,
    required super.agentId,
    required super.model,
    required this.startedAtUnixSeconds,
  });

  @override
  String get event => 'call_started';

  /// Start time as a Unix timestamp in seconds.
  final int startedAtUnixSeconds;

  @override
  Map<String, dynamic> _dataToJson() => {
    ...super._dataToJson(),
    'started_at': startedAtUnixSeconds,
  };

  /// Copies the delivery with selected fields replaced.
  VoiceAgentCallStartedEvent copyWith({
    DateTime? createdAt,
    String? sessionId,
    String? agentId,
    String? model,
    int? startedAtUnixSeconds,
  }) => VoiceAgentCallStartedEvent(
    createdAt: createdAt ?? this.createdAt,
    sessionId: sessionId ?? this.sessionId,
    agentId: agentId ?? this.agentId,
    model: model ?? this.model,
    startedAtUnixSeconds: startedAtUnixSeconds ?? this.startedAtUnixSeconds,
  );

  @override
  String toString() =>
      'VoiceAgentCallStartedEvent(createdAt: $createdAt, '
      'sessionId: $sessionId, agentId: $agentId, model: $model, '
      'startedAtUnixSeconds: $startedAtUnixSeconds)';
}

/// The session ended normally.
final class VoiceAgentCallEndedEvent extends VoiceAgentCallWebhookEvent {
  /// Creates a completed call delivery.
  VoiceAgentCallEndedEvent({
    required super.createdAt,
    required super.sessionId,
    required super.agentId,
    required super.model,
    required this.startedAtUnixSeconds,
    required this.endedAtUnixSeconds,
    required this.durationSeconds,
    Iterable<VoiceAgentWebhookTranscriptTurn>? transcript,
  }) : transcript = transcript == null ? null : List.unmodifiable(transcript);

  @override
  String get event => 'call_ended';

  /// Start time as a Unix timestamp in seconds.
  final int startedAtUnixSeconds;

  /// End time as a Unix timestamp in seconds.
  final int endedAtUnixSeconds;

  /// Length of the call in seconds.
  final int durationSeconds;

  /// Final transcript, when available. Mistral can deliver a null transcript.
  final List<VoiceAgentWebhookTranscriptTurn>? transcript;

  @override
  Map<String, dynamic> _dataToJson() => {
    ...super._dataToJson(),
    'started_at': startedAtUnixSeconds,
    'ended_at': endedAtUnixSeconds,
    'duration_seconds': durationSeconds,
    'transcript': transcript?.map((turn) => turn.toJson()).toList(),
  };

  /// Copies the delivery. Pass null for [transcript] to clear it.
  VoiceAgentCallEndedEvent copyWith({
    DateTime? createdAt,
    String? sessionId,
    String? agentId,
    String? model,
    int? startedAtUnixSeconds,
    int? endedAtUnixSeconds,
    int? durationSeconds,
    Object? transcript = unsetCopyWithValue,
  }) => VoiceAgentCallEndedEvent(
    createdAt: createdAt ?? this.createdAt,
    sessionId: sessionId ?? this.sessionId,
    agentId: agentId ?? this.agentId,
    model: model ?? this.model,
    startedAtUnixSeconds: startedAtUnixSeconds ?? this.startedAtUnixSeconds,
    endedAtUnixSeconds: endedAtUnixSeconds ?? this.endedAtUnixSeconds,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    transcript: identical(transcript, unsetCopyWithValue)
        ? this.transcript
        : (transcript as Iterable<Object?>?)
              ?.cast<VoiceAgentWebhookTranscriptTurn>(),
  );

  @override
  String toString() =>
      'VoiceAgentCallEndedEvent(createdAt: $createdAt, '
      'sessionId: $sessionId, agentId: $agentId, model: $model, '
      'startedAtUnixSeconds: $startedAtUnixSeconds, '
      'endedAtUnixSeconds: $endedAtUnixSeconds, durationSeconds: $durationSeconds, '
      'transcript: ${transcript?.length} turns)';
}

/// The session failed to start or encountered a fatal error.
final class VoiceAgentCallFailedEvent extends VoiceAgentCallWebhookEvent {
  /// Creates a failed call delivery.
  const VoiceAgentCallFailedEvent({
    required super.createdAt,
    required super.sessionId,
    required super.agentId,
    required super.model,
    required this.error,
  });

  @override
  String get event => 'call_failed';

  /// Machine-readable failure reason.
  final String error;

  @override
  Map<String, dynamic> _dataToJson() => {
    ...super._dataToJson(),
    'error': error,
  };

  /// Copies the delivery with selected fields replaced.
  VoiceAgentCallFailedEvent copyWith({
    DateTime? createdAt,
    String? sessionId,
    String? agentId,
    String? model,
    String? error,
  }) => VoiceAgentCallFailedEvent(
    createdAt: createdAt ?? this.createdAt,
    sessionId: sessionId ?? this.sessionId,
    agentId: agentId ?? this.agentId,
    model: model ?? this.model,
    error: error ?? this.error,
  );

  @override
  String toString() =>
      'VoiceAgentCallFailedEvent(createdAt: $createdAt, '
      'sessionId: $sessionId, agentId: $agentId, model: $model, error: $error)';
}

/// A turn in the transcript of a completed call.
@immutable
final class VoiceAgentWebhookTranscriptTurn {
  /// Creates a transcript turn.
  const VoiceAgentWebhookTranscriptTurn({required this.role, this.content});

  /// Decodes a transcript turn.
  factory VoiceAgentWebhookTranscriptTurn.fromJson(Map<String, dynamic> json) =>
      VoiceAgentWebhookTranscriptTurn(
        role: _required<String>(json, 'role'),
        content: json['content'] as String?,
      );

  /// Speaker role, currently `user` or `assistant`.
  final String role;

  /// Text for this turn, if any.
  final String? content;

  /// Serializes a transcript turn.
  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  /// Copies the turn. Pass null for [content] to clear it.
  VoiceAgentWebhookTranscriptTurn copyWith({
    String? role,
    Object? content = unsetCopyWithValue,
  }) => VoiceAgentWebhookTranscriptTurn(
    role: role ?? this.role,
    content: identical(content, unsetCopyWithValue)
        ? this.content
        : content as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is VoiceAgentWebhookTranscriptTurn &&
      role == other.role &&
      content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() =>
      'VoiceAgentWebhookTranscriptTurn(role: $role, '
      'content: ${content?.length} characters)';
}

/// A delivery with a future event discriminator.
final class UnknownVoiceAgentWebhookEvent extends VoiceAgentWebhookEvent {
  UnknownVoiceAgentWebhookEvent._(
    this.event,
    DateTime createdAt,
    Map<String, dynamic> json,
  ) : rawJson = deepUnmodifiableJson(json)! as Map<String, dynamic>,
      super(createdAt: createdAt);

  @override
  final String event;

  /// Original JSON envelope including fields from newer API versions.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);
}

T _required<T extends Object>(Map<String, dynamic> json, String key) {
  if (json[key] case final T value) return value;
  throw FormatException('Invalid Voice Agent webhook field "$key".');
}
