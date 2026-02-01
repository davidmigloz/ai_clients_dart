import 'package:meta/meta.dart';

/// Predicted output for faster responses.
///
/// When you have high confidence in a significant portion of the response,
/// providing a prediction allows the model to focus on differences,
/// potentially reducing latency significantly.
///
/// ## Supported Models
///
/// - `gpt-4o`
/// - `gpt-4o-mini`
/// - `gpt-4.1`
///
/// ## Example
///
/// ```dart
/// // If you know most of the response content ahead of time
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-4o',
///   messages: [
///     ChatMessage.user('Update the copyright year to 2024 in: $existingCode'),
///   ],
///   prediction: Prediction.content(existingCodeWithMinorChanges),
/// );
/// ```
///
/// ## Use Cases
///
/// Predicted outputs work best when:
/// - Regenerating code with small modifications
/// - Updating documents with minor changes
/// - Auto-completing text with known patterns
///
/// The model will compare its output against your prediction and can
/// skip generating matching portions, resulting in faster responses.
sealed class Prediction {
  const Prediction._();

  /// Creates a content prediction.
  ///
  /// The [content] should be your best guess at what the model will generate.
  /// The more accurate the prediction, the faster the response.
  const factory Prediction.content(String content) = _ContentPrediction;

  /// Creates from JSON.
  factory Prediction.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'content') {
      return Prediction.content(json['content'] as String);
    }
    throw FormatException('Unknown Prediction type: $type');
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Content-based prediction.
@immutable
class _ContentPrediction extends Prediction {
  const _ContentPrediction(this.content) : super._();

  /// The predicted content.
  final String content;

  @override
  Map<String, dynamic> toJson() => {'type': 'content', 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ContentPrediction &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'Prediction.content(${content.length} chars)';
}
