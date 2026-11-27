import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A user, assistant, or tool turn in a stored audio transcript.
///
/// [AudioUserTranscriptTurn], [AudioAssistantTranscriptTurn], [AudioToolTranscriptTurn], or [UnknownAudioTranscriptTurn].
@immutable
sealed class AudioTranscriptTurn {
  const AudioTranscriptTurn();

  /// Parses an API payload.
  factory AudioTranscriptTurn.fromJson(Map<String, dynamic> json) =>
      switch (json['role']) {
        'user' => AudioUserTranscriptTurn.fromJson(json),
        'assistant' => AudioAssistantTranscriptTurn.fromJson(json),
        'tool' => AudioToolTranscriptTurn.fromJson(json),
        _ => UnknownAudioTranscriptTurn(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();

  /// The wire role.
  String get role;
}

/// A future AudioTranscriptTurn value.
@immutable
final class UnknownAudioTranscriptTurn extends AudioTranscriptTurn {
  /// Creates a fallback from the original payload.
  UnknownAudioTranscriptTurn(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  String get role => switch (raw['role']) {
    final String value => value,
    _ => 'unknown',
  };

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownAudioTranscriptTurn && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The AudioUserTranscriptTurn wire payload.
@immutable
class AudioUserTranscriptTurn extends AudioTranscriptTurn {
  /// Creates a [AudioUserTranscriptTurn].
  const AudioUserTranscriptTurn({
    this.content,
    this.durationMs,
    required this.latency,
    required this.timestamp,
  });

  @override
  String get role => 'user';

  /// Text as delivered in the conversation: the recognized transcript for user turns, and the audio actually played to the caller for assistant turns. Null only as a fallback for incomplete data.
  final String? content;

  /// The duration_ms field.
  final double? durationMs;

  /// The latency field.
  final AudioLatencyBreakdownUser latency;

  /// The timestamp field.
  final DateTime timestamp;

  /// Parses a [AudioUserTranscriptTurn] from JSON.
  factory AudioUserTranscriptTurn.fromJson(Map<String, dynamic> json) {
    if (json['role'] case final value? when value != 'user') {
      throw FormatException('AudioUserTranscriptTurn: unexpected role $value');
    }
    if (json['latency'] == null) {
      throw const FormatException('AudioUserTranscriptTurn: missing latency');
    }
    if (json['timestamp'] == null) {
      throw const FormatException('AudioUserTranscriptTurn: missing timestamp');
    }
    return AudioUserTranscriptTurn(
      content: json['content'] == null ? null : json['content'] as String,
      durationMs: json['duration_ms'] == null
          ? null
          : (json['duration_ms'] as num).toDouble(),
      latency: AudioLatencyBreakdownUser.fromJson(
        json['latency'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': ?content,
    'duration_ms': ?durationMs,
    'latency': latency.toJson(),
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  AudioUserTranscriptTurn copyWith({
    Object? content = unsetCopyWithValue,
    Object? durationMs = unsetCopyWithValue,
    AudioLatencyBreakdownUser? latency,
    DateTime? timestamp,
  }) => AudioUserTranscriptTurn(
    content: content == unsetCopyWithValue ? this.content : content as String?,
    durationMs: durationMs == unsetCopyWithValue
        ? this.durationMs
        : (durationMs as num?)?.toDouble(),
    latency: latency ?? this.latency,
    timestamp: timestamp ?? this.timestamp,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioUserTranscriptTurn &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          durationMs == other.durationMs &&
          latency == other.latency &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hashAll([content, durationMs, latency, timestamp]);

  @override
  String toString() =>
      'AudioUserTranscriptTurn('
      'content: $content, '
      'durationMs: $durationMs, '
      'latency: $latency, '
      'timestamp: $timestamp)';
}

/// The AudioAssistantTranscriptTurn wire payload.
@immutable
class AudioAssistantTranscriptTurn extends AudioTranscriptTurn {
  /// Creates a [AudioAssistantTranscriptTurn].
  const AudioAssistantTranscriptTurn({
    this.content,
    this.durationMs,
    this.isInterruption,
    required this.latency,
    required this.timestamp,
    this.toolCalls,
  });

  @override
  String get role => 'assistant';

  /// Text as delivered in the conversation: the recognized transcript for user turns, and the audio actually played to the caller for assistant turns. Null only as a fallback for incomplete data.
  final String? content;

  /// The duration_ms field.
  final double? durationMs;

  /// The is_interruption field.
  final bool? isInterruption;

  /// The latency field.
  final AudioLatencyBreakdownAssistant latency;

  /// The timestamp field.
  final DateTime timestamp;

  /// Tools the model requested in this step. Each result follows as a `tool` turn with the same id.
  final List<AudioToolCall>? toolCalls;

  /// Parses a [AudioAssistantTranscriptTurn] from JSON.
  factory AudioAssistantTranscriptTurn.fromJson(Map<String, dynamic> json) {
    if (json['role'] case final value? when value != 'assistant') {
      throw FormatException(
        'AudioAssistantTranscriptTurn: unexpected role $value',
      );
    }
    if (json['latency'] == null) {
      throw const FormatException(
        'AudioAssistantTranscriptTurn: missing latency',
      );
    }
    if (json['timestamp'] == null) {
      throw const FormatException(
        'AudioAssistantTranscriptTurn: missing timestamp',
      );
    }
    return AudioAssistantTranscriptTurn(
      content: json['content'] == null ? null : json['content'] as String,
      durationMs: json['duration_ms'] == null
          ? null
          : (json['duration_ms'] as num).toDouble(),
      isInterruption: json['is_interruption'] == null
          ? null
          : json['is_interruption'] as bool,
      latency: AudioLatencyBreakdownAssistant.fromJson(
        json['latency'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      toolCalls: json['tool_calls'] == null
          ? null
          : (json['tool_calls'] as List)
                .map(
                  (item) =>
                      AudioToolCall.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': ?content,
    'duration_ms': ?durationMs,
    'is_interruption': ?isInterruption,
    'latency': latency.toJson(),
    'timestamp': timestamp.toUtc().toIso8601String(),
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AudioAssistantTranscriptTurn copyWith({
    Object? content = unsetCopyWithValue,
    Object? durationMs = unsetCopyWithValue,
    Object? isInterruption = unsetCopyWithValue,
    AudioLatencyBreakdownAssistant? latency,
    DateTime? timestamp,
    Object? toolCalls = unsetCopyWithValue,
  }) => AudioAssistantTranscriptTurn(
    content: content == unsetCopyWithValue ? this.content : content as String?,
    durationMs: durationMs == unsetCopyWithValue
        ? this.durationMs
        : (durationMs as num?)?.toDouble(),
    isInterruption: isInterruption == unsetCopyWithValue
        ? this.isInterruption
        : isInterruption as bool?,
    latency: latency ?? this.latency,
    timestamp: timestamp ?? this.timestamp,
    toolCalls: toolCalls == unsetCopyWithValue
        ? this.toolCalls
        : (toolCalls as List?)?.cast<AudioToolCall>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAssistantTranscriptTurn &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          durationMs == other.durationMs &&
          isInterruption == other.isInterruption &&
          latency == other.latency &&
          timestamp == other.timestamp &&
          valuesDeepEqual(toolCalls, other.toolCalls);

  @override
  int get hashCode => Object.hashAll([
    content,
    durationMs,
    isInterruption,
    latency,
    timestamp,
    valueDeepHashCode(toolCalls),
  ]);

  @override
  String toString() =>
      'AudioAssistantTranscriptTurn('
      'content: $content, '
      'durationMs: $durationMs, '
      'isInterruption: $isInterruption, '
      'latency: $latency, '
      'timestamp: $timestamp, '
      'toolCalls: ${toolCalls?.length})';
}

/// The AudioToolTranscriptTurn wire payload.
@immutable
class AudioToolTranscriptTurn extends AudioTranscriptTurn {
  /// Creates a [AudioToolTranscriptTurn].
  const AudioToolTranscriptTurn({
    this.durationMs,
    required this.name,
    this.result,
    required this.status,
    required this.timestamp,
    required this.toolCallId,
  });

  @override
  String get role => 'tool';

  /// The duration_ms field.
  final double? durationMs;

  /// The name field.
  final String name;

  /// Decoded JSON or plain text; null when unavailable or withheld.
  final Object? result;

  /// The status field.
  final AudioToolTranscriptTurnStatus status;

  /// When the tool started executing.
  final DateTime timestamp;

  /// The tool_call_id field.
  final String toolCallId;

  /// Parses a [AudioToolTranscriptTurn] from JSON.
  factory AudioToolTranscriptTurn.fromJson(Map<String, dynamic> json) {
    if (json['role'] case final value? when value != 'tool') {
      throw FormatException('AudioToolTranscriptTurn: unexpected role $value');
    }
    if (json['name'] == null) {
      throw const FormatException('AudioToolTranscriptTurn: missing name');
    }
    if (json['status'] == null) {
      throw const FormatException('AudioToolTranscriptTurn: missing status');
    }
    if (json['timestamp'] == null) {
      throw const FormatException('AudioToolTranscriptTurn: missing timestamp');
    }
    if (json['tool_call_id'] == null) {
      throw const FormatException(
        'AudioToolTranscriptTurn: missing tool_call_id',
      );
    }
    return AudioToolTranscriptTurn(
      durationMs: json['duration_ms'] == null
          ? null
          : (json['duration_ms'] as num).toDouble(),
      name: json['name'] as String,
      result: json['result'],
      status: AudioToolTranscriptTurnStatus.fromJson(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      toolCallId: json['tool_call_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'duration_ms': ?durationMs,
    'name': name,
    'result': ?result,
    'status': status.toJson(),
    'timestamp': timestamp.toUtc().toIso8601String(),
    'tool_call_id': toolCallId,
  };

  /// Creates a copy with the given fields replaced.
  AudioToolTranscriptTurn copyWith({
    Object? durationMs = unsetCopyWithValue,
    String? name,
    Object? result = unsetCopyWithValue,
    AudioToolTranscriptTurnStatus? status,
    DateTime? timestamp,
    String? toolCallId,
  }) => AudioToolTranscriptTurn(
    durationMs: durationMs == unsetCopyWithValue
        ? this.durationMs
        : (durationMs as num?)?.toDouble(),
    name: name ?? this.name,
    result: result == unsetCopyWithValue ? this.result : result,
    status: status ?? this.status,
    timestamp: timestamp ?? this.timestamp,
    toolCallId: toolCallId ?? this.toolCallId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioToolTranscriptTurn &&
          runtimeType == other.runtimeType &&
          durationMs == other.durationMs &&
          name == other.name &&
          valuesDeepEqual(result, other.result) &&
          status == other.status &&
          timestamp == other.timestamp &&
          toolCallId == other.toolCallId;

  @override
  int get hashCode => Object.hashAll([
    durationMs,
    name,
    valueDeepHashCode(result),
    status,
    timestamp,
    toolCallId,
  ]);

  @override
  String toString() =>
      'AudioToolTranscriptTurn('
      'durationMs: $durationMs, '
      'name: $name, '
      'result: $result, '
      'status: $status, '
      'timestamp: $timestamp, '
      'toolCallId: $toolCallId)';
}

/// Values for AudioToolTranscriptTurnStatus.
enum AudioToolTranscriptTurnStatus {
  /// Represents success.
  success('success'),

  /// Represents error.
  error('error'),

  /// Represents unknown.
  unknown('unknown');

  const AudioToolTranscriptTurnStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AudioToolTranscriptTurnStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The AudioLatencyBreakdownAssistant wire payload.
@immutable
class AudioLatencyBreakdownAssistant {
  /// Creates a [AudioLatencyBreakdownAssistant].
  const AudioLatencyBreakdownAssistant({
    this.e2eLatencyMs,
    this.llmDurationMs,
    this.llmTtftMs,
    this.ttsDurationMs,
    this.ttsTtfbMs,
  });

  /// The e2e_latency_ms field.
  final double? e2eLatencyMs;

  /// The llm_duration_ms field.
  final double? llmDurationMs;

  /// The llm_ttft_ms field.
  final double? llmTtftMs;

  /// The tts_duration_ms field.
  final double? ttsDurationMs;

  /// The tts_ttfb_ms field.
  final double? ttsTtfbMs;

  /// Parses a [AudioLatencyBreakdownAssistant] from JSON.
  factory AudioLatencyBreakdownAssistant.fromJson(Map<String, dynamic> json) {
    return AudioLatencyBreakdownAssistant(
      e2eLatencyMs: json['e2e_latency_ms'] == null
          ? null
          : (json['e2e_latency_ms'] as num).toDouble(),
      llmDurationMs: json['llm_duration_ms'] == null
          ? null
          : (json['llm_duration_ms'] as num).toDouble(),
      llmTtftMs: json['llm_ttft_ms'] == null
          ? null
          : (json['llm_ttft_ms'] as num).toDouble(),
      ttsDurationMs: json['tts_duration_ms'] == null
          ? null
          : (json['tts_duration_ms'] as num).toDouble(),
      ttsTtfbMs: json['tts_ttfb_ms'] == null
          ? null
          : (json['tts_ttfb_ms'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'e2e_latency_ms': ?e2eLatencyMs,
    'llm_duration_ms': ?llmDurationMs,
    'llm_ttft_ms': ?llmTtftMs,
    'tts_duration_ms': ?ttsDurationMs,
    'tts_ttfb_ms': ?ttsTtfbMs,
  };

  /// Creates a copy with the given fields replaced.
  AudioLatencyBreakdownAssistant copyWith({
    Object? e2eLatencyMs = unsetCopyWithValue,
    Object? llmDurationMs = unsetCopyWithValue,
    Object? llmTtftMs = unsetCopyWithValue,
    Object? ttsDurationMs = unsetCopyWithValue,
    Object? ttsTtfbMs = unsetCopyWithValue,
  }) => AudioLatencyBreakdownAssistant(
    e2eLatencyMs: e2eLatencyMs == unsetCopyWithValue
        ? this.e2eLatencyMs
        : (e2eLatencyMs as num?)?.toDouble(),
    llmDurationMs: llmDurationMs == unsetCopyWithValue
        ? this.llmDurationMs
        : (llmDurationMs as num?)?.toDouble(),
    llmTtftMs: llmTtftMs == unsetCopyWithValue
        ? this.llmTtftMs
        : (llmTtftMs as num?)?.toDouble(),
    ttsDurationMs: ttsDurationMs == unsetCopyWithValue
        ? this.ttsDurationMs
        : (ttsDurationMs as num?)?.toDouble(),
    ttsTtfbMs: ttsTtfbMs == unsetCopyWithValue
        ? this.ttsTtfbMs
        : (ttsTtfbMs as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioLatencyBreakdownAssistant &&
          runtimeType == other.runtimeType &&
          e2eLatencyMs == other.e2eLatencyMs &&
          llmDurationMs == other.llmDurationMs &&
          llmTtftMs == other.llmTtftMs &&
          ttsDurationMs == other.ttsDurationMs &&
          ttsTtfbMs == other.ttsTtfbMs;

  @override
  int get hashCode => Object.hashAll([
    e2eLatencyMs,
    llmDurationMs,
    llmTtftMs,
    ttsDurationMs,
    ttsTtfbMs,
  ]);

  @override
  String toString() =>
      'AudioLatencyBreakdownAssistant('
      'e2eLatencyMs: $e2eLatencyMs, '
      'llmDurationMs: $llmDurationMs, '
      'llmTtftMs: $llmTtftMs, '
      'ttsDurationMs: $ttsDurationMs, '
      'ttsTtfbMs: $ttsTtfbMs)';
}

/// The AudioLatencyBreakdownUser wire payload.
@immutable
class AudioLatencyBreakdownUser {
  /// Creates a [AudioLatencyBreakdownUser].
  const AudioLatencyBreakdownUser({
    this.endOfTurnDelayMs,
    this.transcriptionDelayMs,
  });

  /// The end_of_turn_delay_ms field.
  final double? endOfTurnDelayMs;

  /// The transcription_delay_ms field.
  final double? transcriptionDelayMs;

  /// Parses a [AudioLatencyBreakdownUser] from JSON.
  factory AudioLatencyBreakdownUser.fromJson(Map<String, dynamic> json) {
    return AudioLatencyBreakdownUser(
      endOfTurnDelayMs: json['end_of_turn_delay_ms'] == null
          ? null
          : (json['end_of_turn_delay_ms'] as num).toDouble(),
      transcriptionDelayMs: json['transcription_delay_ms'] == null
          ? null
          : (json['transcription_delay_ms'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'end_of_turn_delay_ms': ?endOfTurnDelayMs,
    'transcription_delay_ms': ?transcriptionDelayMs,
  };

  /// Creates a copy with the given fields replaced.
  AudioLatencyBreakdownUser copyWith({
    Object? endOfTurnDelayMs = unsetCopyWithValue,
    Object? transcriptionDelayMs = unsetCopyWithValue,
  }) => AudioLatencyBreakdownUser(
    endOfTurnDelayMs: endOfTurnDelayMs == unsetCopyWithValue
        ? this.endOfTurnDelayMs
        : (endOfTurnDelayMs as num?)?.toDouble(),
    transcriptionDelayMs: transcriptionDelayMs == unsetCopyWithValue
        ? this.transcriptionDelayMs
        : (transcriptionDelayMs as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioLatencyBreakdownUser &&
          runtimeType == other.runtimeType &&
          endOfTurnDelayMs == other.endOfTurnDelayMs &&
          transcriptionDelayMs == other.transcriptionDelayMs;

  @override
  int get hashCode => Object.hashAll([endOfTurnDelayMs, transcriptionDelayMs]);

  @override
  String toString() =>
      'AudioLatencyBreakdownUser('
      'endOfTurnDelayMs: $endOfTurnDelayMs, '
      'transcriptionDelayMs: $transcriptionDelayMs)';
}

/// The AudioToolCall wire payload.
@immutable
class AudioToolCall {
  /// Creates a [AudioToolCall].
  const AudioToolCall({this.arguments, required this.id, required this.name});

  /// JSON text, or null when unavailable or withheld.
  final String? arguments;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// Parses a [AudioToolCall] from JSON.
  factory AudioToolCall.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('AudioToolCall: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('AudioToolCall: missing name');
    }
    return AudioToolCall(
      arguments: json['arguments'] == null ? null : json['arguments'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'arguments': ?arguments,
    'id': id,
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  AudioToolCall copyWith({
    Object? arguments = unsetCopyWithValue,
    String? id,
    String? name,
  }) => AudioToolCall(
    arguments: arguments == unsetCopyWithValue
        ? this.arguments
        : arguments as String?,
    id: id ?? this.id,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioToolCall &&
          runtimeType == other.runtimeType &&
          arguments == other.arguments &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([arguments, id, name]);

  @override
  String toString() =>
      'AudioToolCall('
      'arguments: $arguments, '
      'id: $id, '
      'name: $name)';
}
