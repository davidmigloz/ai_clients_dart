import 'package:meta/meta.dart';

/// Content within a reasoning summary.
@immutable
class ReasoningSummaryContent {
  /// The summary text.
  final String text;

  /// Creates a [ReasoningSummaryContent].
  const ReasoningSummaryContent({required this.text});

  /// Creates a [ReasoningSummaryContent] from JSON.
  factory ReasoningSummaryContent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryContent(text: json['text'] as String);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': 'summary_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ReasoningSummaryContent(text: $text)';
}
