import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

// =============================================================================
// RealtimeReasoningEffort
// =============================================================================

/// Reasoning effort levels for reasoning-capable Realtime models.
///
/// Constrains the amount of reasoning the model performs before responding,
/// trading latency for quality. Currently applies only to reasoning Realtime
/// models such as `gpt-realtime-2`.
///
/// Unknown values from `fromJson` throw `FormatException`, matching the
/// package's existing enum convention.
enum RealtimeReasoningEffort {
  /// Minimal reasoning. Lowest latency.
  minimal._('minimal'),

  /// Low reasoning effort.
  low._('low'),

  /// Medium reasoning effort.
  medium._('medium'),

  /// High reasoning effort.
  high._('high'),

  /// Extra-high reasoning effort.
  xhigh._('xhigh');

  const RealtimeReasoningEffort._(this._value);

  /// Creates from JSON string. Throws `FormatException` for unknown values.
  factory RealtimeReasoningEffort.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () =>
          throw FormatException('Unknown RealtimeReasoningEffort: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// RealtimeReasoning
// =============================================================================

/// Configuration for reasoning-capable Realtime models such as `gpt-realtime-2`.
@immutable
class RealtimeReasoning {
  /// Creates a [RealtimeReasoning].
  const RealtimeReasoning({this.effort});

  /// Creates a [RealtimeReasoning] from JSON.
  factory RealtimeReasoning.fromJson(Map<String, dynamic> json) {
    return RealtimeReasoning(
      effort: json['effort'] != null
          ? RealtimeReasoningEffort.fromJson(json['effort'] as String)
          : null,
    );
  }

  /// The reasoning effort level. `null` means use the model default.
  final RealtimeReasoningEffort? effort;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort!.toJson(),
  };

  /// Returns a copy of this [RealtimeReasoning] with the given fields replaced.
  ///
  /// Pass `null` for [effort] to clear the existing value.
  RealtimeReasoning copyWith({Object? effort = unsetCopyWithValue}) =>
      RealtimeReasoning(
        effort: identical(effort, unsetCopyWithValue)
            ? this.effort
            : effort as RealtimeReasoningEffort?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeReasoning &&
          runtimeType == other.runtimeType &&
          effort == other.effort;

  @override
  int get hashCode => effort.hashCode;

  @override
  String toString() => 'RealtimeReasoning(effort: $effort)';
}
