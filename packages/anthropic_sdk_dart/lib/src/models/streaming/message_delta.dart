import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/stop_reason.dart';

/// Delta update for message properties during streaming.
@immutable
class MessageDelta {
  /// The stop reason if the message has finished.
  final StopReason? stopReason;

  /// The stop sequence that caused the stop, if applicable.
  final String? stopSequence;

  /// Creates a [MessageDelta].
  const MessageDelta({this.stopReason, this.stopSequence});

  /// Creates a [MessageDelta] from JSON.
  factory MessageDelta.fromJson(Map<String, dynamic> json) {
    return MessageDelta(
      stopReason: json['stop_reason'] != null
          ? StopReason.fromJson(json['stop_reason'] as String)
          : null,
      stopSequence: json['stop_sequence'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (stopReason != null) 'stop_reason': stopReason!.toJson(),
    if (stopSequence != null) 'stop_sequence': stopSequence,
  };

  /// Creates a copy with replaced values.
  MessageDelta copyWith({
    Object? stopReason = unsetCopyWithValue,
    Object? stopSequence = unsetCopyWithValue,
  }) {
    return MessageDelta(
      stopReason: stopReason == unsetCopyWithValue
          ? this.stopReason
          : stopReason as StopReason?,
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
          stopReason == other.stopReason &&
          stopSequence == other.stopSequence;

  @override
  int get hashCode => Object.hash(stopReason, stopSequence);

  @override
  String toString() =>
      'MessageDelta(stopReason: $stopReason, stopSequence: $stopSequence)';
}

/// Usage information in delta events.
@immutable
class MessageDeltaUsage {
  /// The number of output tokens generated so far.
  final int outputTokens;

  /// Creates a [MessageDeltaUsage].
  const MessageDeltaUsage({required this.outputTokens});

  /// Creates a [MessageDeltaUsage] from JSON.
  factory MessageDeltaUsage.fromJson(Map<String, dynamic> json) {
    return MessageDeltaUsage(outputTokens: json['output_tokens'] as int);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'output_tokens': outputTokens};

  /// Creates a copy with replaced values.
  MessageDeltaUsage copyWith({int? outputTokens}) {
    return MessageDeltaUsage(outputTokens: outputTokens ?? this.outputTokens);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDeltaUsage &&
          runtimeType == other.runtimeType &&
          outputTokens == other.outputTokens;

  @override
  int get hashCode => outputTokens.hashCode;

  @override
  String toString() => 'MessageDeltaUsage(outputTokens: $outputTokens)';
}
