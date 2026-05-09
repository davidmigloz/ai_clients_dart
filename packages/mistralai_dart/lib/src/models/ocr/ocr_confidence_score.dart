import 'package:meta/meta.dart';

/// Confidence score for a span of OCR-extracted text.
///
/// Each entry corresponds to a contiguous span of characters within the
/// containing text (page or table) starting at [startIndex] with the given
/// [text]. [confidence] is in the range `[0, 1]` where higher values indicate
/// higher reliability of the OCR for that span.
@immutable
class OcrConfidenceScore {
  /// Reliability score for the OCR-extracted span (0.0 to 1.0).
  final double confidence;

  /// Start index of the span in the containing text (0-based).
  final int startIndex;

  /// The extracted text for this span.
  final String text;

  /// Creates an [OcrConfidenceScore].
  const OcrConfidenceScore({
    required this.confidence,
    required this.startIndex,
    required this.text,
  });

  /// Creates an [OcrConfidenceScore] from JSON.
  ///
  /// Throws a [FormatException] if any required field is missing or null.
  factory OcrConfidenceScore.fromJson(Map<String, dynamic> json) {
    final confidence = json['confidence'];
    if (confidence is! num) {
      throw const FormatException(
        'OcrConfidenceScore: missing required field "confidence"',
      );
    }
    final startIndex = json['start_index'];
    if (startIndex is! int) {
      throw const FormatException(
        'OcrConfidenceScore: missing required field "start_index"',
      );
    }
    final text = json['text'];
    if (text is! String) {
      throw const FormatException(
        'OcrConfidenceScore: missing required field "text"',
      );
    }
    return OcrConfidenceScore(
      confidence: confidence.toDouble(),
      startIndex: startIndex,
      text: text,
    );
  }

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
      'OcrConfidenceScore(confidence: $confidence, '
      'startIndex: $startIndex, text: ${text.length} chars)';
}
