import 'package:meta/meta.dart';

import '../metadata/finish_reason.dart';

/// A choice in a FIM completion response.
@immutable
class FimChoice {
  /// The index of this choice in the list of choices.
  final int index;

  /// The generated text content.
  final String message;

  /// The reason the model stopped generating.
  final FinishReason? finishReason;

  /// Creates a [FimChoice].
  const FimChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  /// Creates a [FimChoice] from JSON.
  factory FimChoice.fromJson(Map<String, dynamic> json) => FimChoice(
    index: json['index'] as int? ?? 0,
    message: json['message'] as String? ?? '',
    finishReason: finishReasonFromString(json['finish_reason'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    'message': message,
    if (finishReason != null)
      'finish_reason': finishReasonToString(finishReason!),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FimChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          message == other.message &&
          finishReason == other.finishReason;

  @override
  int get hashCode => Object.hash(index, message, finishReason);

  @override
  String toString() =>
      'FimChoice(index: $index, message: ${message.length} chars, '
      'finishReason: $finishReason)';
}
