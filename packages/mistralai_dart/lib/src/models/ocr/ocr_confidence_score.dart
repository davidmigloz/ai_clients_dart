import 'package:meta/meta.dart';

/// Per-word confidence score from OCR processing.
///
/// Represents the confidence level for a single word extracted by the OCR model.
@immutable
class OcrConfidenceScore {
  /// Confidence score for the word, between 0 and 1.
  final double confidence;

  /// Start index of the word in the markdown string.
  final int startIndex;

  /// The word text.
  final String text;

  /// Creates an [OcrConfidenceScore].
  const OcrConfidenceScore({
    required this.confidence,
    required this.startIndex,
    required this.text,
  });

  /// Creates an [OcrConfidenceScore] from JSON.
  factory OcrConfidenceScore.fromJson(Map<String, dynamic> json) =>
      OcrConfidenceScore(
        confidence: (json['confidence'] as num).toDouble(),
        startIndex: json['start_index'] as int,
        text: json['text'] as String,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'confidence': confidence,
    'start_index': startIndex,
    'text': text,
  };

  /// Creates a copy with the specified fields replaced.
  OcrConfidenceScore copyWith({
    double? confidence,
    int? startIndex,
    String? text,
  }) => OcrConfidenceScore(
    confidence: confidence ?? this.confidence,
    startIndex: startIndex ?? this.startIndex,
    text: text ?? this.text,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrConfidenceScore &&
          runtimeType == other.runtimeType &&
          confidence == other.confidence &&
          startIndex == other.startIndex &&
          text == other.text;

  @override
  int get hashCode => Object.hash(confidence, startIndex, text);

  @override
  String toString() =>
      'OcrConfidenceScore(confidence: $confidence, startIndex: $startIndex, '
      'text: $text)';
}
