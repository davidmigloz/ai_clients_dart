import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/reasoning_effort.dart';
import '../metadata/reasoning_summary.dart';

/// Configuration for reasoning models.
@immutable
class ReasoningConfig {
  /// The reasoning effort level.
  final ReasoningEffort? effort;

  /// How to summarize the reasoning.
  final ReasoningSummary? summary;

  /// Creates a [ReasoningConfig].
  const ReasoningConfig({this.effort, this.summary});

  /// Creates a [ReasoningConfig] from JSON.
  factory ReasoningConfig.fromJson(Map<String, dynamic> json) {
    return ReasoningConfig(
      effort: json['effort'] != null
          ? ReasoningEffort.fromJson(json['effort'] as String)
          : null,
      summary: json['summary'] != null
          ? ReasoningSummary.fromJson(json['summary'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort!.toJson(),
    if (summary != null) 'summary': summary!.toJson(),
  };

  /// Creates a copy with replaced values.
  ReasoningConfig copyWith({
    Object? effort = unsetCopyWithValue,
    Object? summary = unsetCopyWithValue,
  }) {
    return ReasoningConfig(
      effort: effort == unsetCopyWithValue
          ? this.effort
          : effort as ReasoningEffort?,
      summary: summary == unsetCopyWithValue
          ? this.summary
          : summary as ReasoningSummary?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningConfig &&
          runtimeType == other.runtimeType &&
          effort == other.effort &&
          summary == other.summary;

  @override
  int get hashCode => Object.hash(effort, summary);

  @override
  String toString() => 'ReasoningConfig(effort: $effort, summary: $summary)';
}
