part of 'deltas.dart';

/// A thought summary delta update.
class ThoughtSummaryDelta extends StepDeltaData {
  @override
  String get type => 'thought_summary';

  /// The new summary item to be added to the thought
  /// (text or image content).
  final ThoughtSummaryContent? content;

  /// Creates a [ThoughtSummaryDelta] instance.
  const ThoughtSummaryDelta({this.content});

  /// Creates a [ThoughtSummaryDelta] from JSON.
  factory ThoughtSummaryDelta.fromJson(Map<String, dynamic> json) =>
      ThoughtSummaryDelta(
        content: json['content'] != null
            ? ThoughtSummaryContent.fromJson(
                json['content'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (content != null) 'content': content!.toJson(),
  };
}
