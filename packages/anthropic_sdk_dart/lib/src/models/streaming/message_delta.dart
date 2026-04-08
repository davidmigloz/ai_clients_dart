import 'package:meta/meta.dart';

import '../beta/config/container.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/speed.dart';
import '../metadata/stop_reason.dart';
import '../metadata/usage.dart';

/// Delta update for message properties during streaming.
@immutable
class MessageDelta {
  /// Container metadata when server-side code execution was used.
  final Container? container;

  /// The stop reason if the message has finished.
  final StopReason? stopReason;

  /// Structured information about why model output stopped.
  ///
  /// This is non-null when [stopReason] is [StopReason.refusal].
  final RefusalStopDetails? stopDetails;

  /// The stop sequence that caused the stop, if applicable.
  final String? stopSequence;

  /// Creates a [MessageDelta].
  const MessageDelta({
    this.container,
    this.stopReason,
    this.stopDetails,
    this.stopSequence,
  });

  /// Creates a [MessageDelta] from JSON.
  factory MessageDelta.fromJson(Map<String, dynamic> json) {
    return MessageDelta(
      container: json['container'] != null
          ? Container.fromJson(json['container'] as Map<String, dynamic>)
          : null,
      stopReason: json['stop_reason'] != null
          ? StopReason.fromJson(json['stop_reason'] as String)
          : null,
      stopDetails: json['stop_details'] != null
          ? RefusalStopDetails.fromJson(
              json['stop_details'] as Map<String, dynamic>,
            )
          : null,
      stopSequence: json['stop_sequence'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (container != null) 'container': container!.toJson(),
    if (stopReason != null) 'stop_reason': stopReason!.toJson(),
    if (stopDetails != null) 'stop_details': stopDetails!.toJson(),
    if (stopSequence != null) 'stop_sequence': stopSequence,
  };

  /// Creates a copy with replaced values.
  MessageDelta copyWith({
    Object? container = unsetCopyWithValue,
    Object? stopReason = unsetCopyWithValue,
    Object? stopDetails = unsetCopyWithValue,
    Object? stopSequence = unsetCopyWithValue,
  }) {
    return MessageDelta(
      container: container == unsetCopyWithValue
          ? this.container
          : container as Container?,
      stopReason: stopReason == unsetCopyWithValue
          ? this.stopReason
          : stopReason as StopReason?,
      stopDetails: stopDetails == unsetCopyWithValue
          ? this.stopDetails
          : stopDetails as RefusalStopDetails?,
      stopSequence: stopSequence == unsetCopyWithValue
          ? this.stopSequence
          : stopSequence as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDelta &&
          runtimeType == other.runtimeType &&
          container == other.container &&
          stopReason == other.stopReason &&
          stopDetails == other.stopDetails &&
          stopSequence == other.stopSequence;

  @override
  int get hashCode =>
      Object.hash(container, stopReason, stopDetails, stopSequence);

  @override
  String toString() =>
      'MessageDelta(container: $container, stopReason: $stopReason, '
      'stopDetails: $stopDetails, stopSequence: $stopSequence)';
}

/// Usage information in delta events.
@immutable
class MessageDeltaUsage {
  /// The cumulative number of output tokens generated so far.
  final int outputTokens;

  /// The cumulative number of input tokens used.
  final int? inputTokens;

  /// Cumulative cache creation input token count.
  final int? cacheCreationInputTokens;

  /// Cumulative cache read input token count.
  final int? cacheReadInputTokens;

  /// Server tool usage metrics.
  final ServerToolUsage? serverToolUse;

  /// Iteration usage metrics (beta / compaction-related).
  final List<IterationUsage>? iterations;

  /// Speed mode used for this response (beta).
  final Speed? speed;

  /// Creates a [MessageDeltaUsage].
  const MessageDeltaUsage({
    required this.outputTokens,
    this.inputTokens,
    this.cacheCreationInputTokens,
    this.cacheReadInputTokens,
    this.serverToolUse,
    this.iterations,
    this.speed,
  });

  /// Creates a [MessageDeltaUsage] from JSON.
  factory MessageDeltaUsage.fromJson(Map<String, dynamic> json) {
    return MessageDeltaUsage(
      outputTokens: json['output_tokens'] as int,
      inputTokens: json['input_tokens'] as int?,
      cacheCreationInputTokens: json['cache_creation_input_tokens'] as int?,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int?,
      serverToolUse: json['server_tool_use'] != null
          ? ServerToolUsage.fromJson(
              json['server_tool_use'] as Map<String, dynamic>,
            )
          : null,
      iterations: json['iterations'] != null
          ? (json['iterations'] as List)
                .map((e) => IterationUsage.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      speed: json['speed'] != null
          ? Speed.fromJson(json['speed'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'output_tokens': outputTokens,
    if (inputTokens != null) 'input_tokens': inputTokens,
    if (cacheCreationInputTokens != null)
      'cache_creation_input_tokens': cacheCreationInputTokens,
    if (cacheReadInputTokens != null)
      'cache_read_input_tokens': cacheReadInputTokens,
    if (serverToolUse != null) 'server_tool_use': serverToolUse!.toJson(),
    if (iterations != null)
      'iterations': iterations!.map((e) => e.toJson()).toList(),
    if (speed != null) 'speed': speed!.toJson(),
  };

  /// Creates a copy with replaced values.
  MessageDeltaUsage copyWith({
    int? outputTokens,
    Object? inputTokens = unsetCopyWithValue,
    Object? cacheCreationInputTokens = unsetCopyWithValue,
    Object? cacheReadInputTokens = unsetCopyWithValue,
    Object? serverToolUse = unsetCopyWithValue,
    Object? iterations = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
  }) {
    return MessageDeltaUsage(
      outputTokens: outputTokens ?? this.outputTokens,
      inputTokens: inputTokens == unsetCopyWithValue
          ? this.inputTokens
          : inputTokens as int?,
      cacheCreationInputTokens: cacheCreationInputTokens == unsetCopyWithValue
          ? this.cacheCreationInputTokens
          : cacheCreationInputTokens as int?,
      cacheReadInputTokens: cacheReadInputTokens == unsetCopyWithValue
          ? this.cacheReadInputTokens
          : cacheReadInputTokens as int?,
      serverToolUse: serverToolUse == unsetCopyWithValue
          ? this.serverToolUse
          : serverToolUse as ServerToolUsage?,
      iterations: iterations == unsetCopyWithValue
          ? this.iterations
          : iterations as List<IterationUsage>?,
      speed: speed == unsetCopyWithValue ? this.speed : speed as Speed?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDeltaUsage &&
          runtimeType == other.runtimeType &&
          outputTokens == other.outputTokens &&
          inputTokens == other.inputTokens &&
          cacheCreationInputTokens == other.cacheCreationInputTokens &&
          cacheReadInputTokens == other.cacheReadInputTokens &&
          serverToolUse == other.serverToolUse &&
          listsEqual(iterations, other.iterations) &&
          speed == other.speed;

  @override
  int get hashCode => Object.hash(
    outputTokens,
    inputTokens,
    cacheCreationInputTokens,
    cacheReadInputTokens,
    serverToolUse,
    listHash(iterations),
    speed,
  );

  @override
  String toString() =>
      'MessageDeltaUsage(outputTokens: $outputTokens, inputTokens: $inputTokens, '
      'cacheCreationInputTokens: $cacheCreationInputTokens, '
      'cacheReadInputTokens: $cacheReadInputTokens, '
      'serverToolUse: $serverToolUse, iterations: $iterations, speed: $speed)';
}
