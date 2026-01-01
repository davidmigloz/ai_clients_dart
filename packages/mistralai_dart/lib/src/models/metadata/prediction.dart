import 'package:meta/meta.dart';

/// Prediction configuration for speculative decoding.
///
/// Enables users to define anticipated output content, optimizing response
/// times by leveraging known or predictable content.
///
/// This is particularly useful for scenarios like code modification tasks,
/// where significant portions of the output are often predetermined.
///
/// Supported models: `mistral-large-2411`, `codestral-latest`
///
/// Note: The `n` parameter (number of completions) is not supported when
/// using predicted outputs.
@immutable
sealed class Prediction {
  const Prediction();

  /// Creates a content prediction.
  ///
  /// [content] is the expected or known output text.
  const factory Prediction.content(String content) = ContentPrediction;

  /// Creates a [Prediction] from JSON.
  factory Prediction.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'content':
        return ContentPrediction(json['content'] as String? ?? '');
      default:
        throw ArgumentError('Unknown prediction type: $type');
    }
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A content-based prediction.
@immutable
class ContentPrediction extends Prediction {
  /// The predicted content.
  final String content;

  /// Creates a [ContentPrediction].
  const ContentPrediction(this.content);

  @override
  Map<String, dynamic> toJson() => {'type': 'content', 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPrediction &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'ContentPrediction(content: ${content.length} chars)';
}
