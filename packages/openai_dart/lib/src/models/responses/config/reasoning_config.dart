import 'package:meta/meta.dart';

import 'reasoning_context.dart';
import 'reasoning_effort.dart';
import 'reasoning_summary.dart';

/// Configuration for reasoning models.
@immutable
class ReasoningConfig {
  /// The reasoning effort level.
  final ReasoningEffort? effort;

  /// How to summarize the reasoning.
  final ReasoningSummary? summary;

  /// Controls which reasoning items are rendered back to the model on later
  /// turns. When returned on a response, this is the effective reasoning
  /// context mode used for the response.
  final ReasoningContext? context;

  /// Creates a [ReasoningConfig].
  const ReasoningConfig({this.effort, this.summary, this.context});

  /// Creates a [ReasoningConfig] from JSON.
  factory ReasoningConfig.fromJson(Map<String, dynamic> json) {
    return ReasoningConfig(
      effort: json['effort'] != null
          ? ReasoningEffort.fromJson(json['effort'] as String)
          : null,
      summary: json['summary'] != null
          ? ReasoningSummary.fromJson(json['summary'] as String)
          : null,
      context: json['context'] != null
          ? ReasoningContext.fromJson(json['context'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort!.toJson(),
    if (summary != null) 'summary': summary!.toJson(),
    if (context != null) 'context': context!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningConfig &&
          runtimeType == other.runtimeType &&
          effort == other.effort &&
          summary == other.summary &&
          context == other.context;

  @override
  int get hashCode => Object.hash(effort, summary, context);

  @override
  String toString() =>
      'ReasoningConfig(effort: $effort, summary: $summary, context: $context)';
}
