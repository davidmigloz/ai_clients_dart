import 'package:meta/meta.dart';

import '../metadata/finish_reason.dart';

/// A delta choice in a FIM completion stream response.
@immutable
class FimChoiceDelta {
  /// The index of this choice in the list of choices.
  final int index;

  /// The generated text content delta.
  final String? delta;

  /// The reason the model stopped generating.
  final FinishReason? finishReason;

  /// Creates a [FimChoiceDelta].
  const FimChoiceDelta({required this.index, this.delta, this.finishReason});

  /// Creates a [FimChoiceDelta] from JSON.
  factory FimChoiceDelta.fromJson(Map<String, dynamic> json) => FimChoiceDelta(
    index: json['index'] as int? ?? 0,
    delta: json['delta'] as String?,
    finishReason: finishReasonFromString(json['finish_reason'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    if (delta != null) 'delta': delta,
    if (finishReason != null)
      'finish_reason': finishReasonToString(finishReason!),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FimChoiceDelta &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          delta == other.delta &&
          finishReason == other.finishReason;

  @override
  int get hashCode => Object.hash(index, delta, finishReason);

  @override
  String toString() =>
      'FimChoiceDelta(index: $index, delta: $delta, '
      'finishReason: $finishReason)';
}
