import 'package:meta/meta.dart';

import '../chat/chat_choice_delta.dart';
import '../chat/message_content.dart';
import '../metadata/finish_reason.dart';

/// A delta choice in a FIM completion stream response.
@immutable
class FimChoiceDelta {
  /// The index of this choice in the list of choices.
  final int index;

  final String? _legacyDelta;

  /// The generated text, including text from chunked message content.
  String? get delta => _legacyDelta ?? messageDelta?.content?.text;

  /// The structured message delta returned by the current API.
  final DeltaContent? messageDelta;

  /// The reason the model stopped generating.
  final FinishReason? finishReason;

  /// Creates a [FimChoiceDelta] with a legacy plain-text delta.
  const FimChoiceDelta({required this.index, String? delta, this.finishReason})
    : _legacyDelta = delta,
      messageDelta = null;

  /// Creates a [FimChoiceDelta] with a structured message delta.
  const FimChoiceDelta.structured({
    required this.index,
    required DeltaContent this.messageDelta,
    this.finishReason,
  }) : _legacyDelta = null;

  /// Creates a [FimChoiceDelta] from JSON.
  factory FimChoiceDelta.fromJson(Map<String, dynamic> json) {
    final index = json['index'] as int? ?? 0;
    final finishReason = finishReasonFromString(
      json['finish_reason'] as String?,
    );
    final delta = json['delta'];
    if (delta is Map<String, dynamic>) {
      return FimChoiceDelta.structured(
        index: index,
        messageDelta: DeltaContent.fromJson(delta),
        finishReason: finishReason,
      );
    }
    return FimChoiceDelta(
      index: index,
      delta: delta as String?,
      finishReason: finishReason,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    if (_legacyDelta != null || messageDelta != null)
      'delta': _legacyDelta ?? messageDelta!.toJson(),
    if (messageDelta != null || finishReason != null)
      'finish_reason': finishReason == null
          ? null
          : finishReasonToString(finishReason!),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FimChoiceDelta &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          _legacyDelta == other._legacyDelta &&
          messageDelta == other.messageDelta &&
          finishReason == other.finishReason;

  @override
  int get hashCode =>
      Object.hash(index, _legacyDelta, messageDelta, finishReason);

  @override
  String toString() =>
      'FimChoiceDelta(index: $index, delta: $delta, '
      'messageDelta: ${messageDelta != null}, finishReason: $finishReason)';
}
