import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'response_input.dart';

/// Request to compact response conversation state.
@immutable
class CompactResponseRequest {
  /// The model to use for compaction.
  final String model;

  /// Optional input to compact. Can be plain text or item history.
  final ResponseInput? input;

  /// Optional previous response ID to compact from.
  final String? previousResponseId;

  /// Optional instructions to apply during compaction.
  final String? instructions;

  /// Creates a [CompactResponseRequest].
  const CompactResponseRequest({
    required this.model,
    this.input,
    this.previousResponseId,
    this.instructions,
  });

  /// Creates a [CompactResponseRequest] from JSON.
  factory CompactResponseRequest.fromJson(Map<String, dynamic> json) {
    return CompactResponseRequest(
      model: json['model'] as String,
      input: json['input'] != null
          ? ResponseInput.fromJson(json['input'])
          : null,
      previousResponseId: json['previous_response_id'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (input != null) 'input': input!.toJson(),
    if (previousResponseId != null) 'previous_response_id': previousResponseId,
    if (instructions != null) 'instructions': instructions,
  };

  /// Creates a copy with replaced values.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  CompactResponseRequest copyWith({
    String? model,
    Object? input = unsetCopyWithValue,
    Object? previousResponseId = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
  }) {
    return CompactResponseRequest(
      model: model ?? this.model,
      input: input == unsetCopyWithValue ? this.input : input as ResponseInput?,
      previousResponseId: previousResponseId == unsetCopyWithValue
          ? this.previousResponseId
          : previousResponseId as String?,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactResponseRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          previousResponseId == other.previousResponseId &&
          instructions == other.instructions;

  @override
  int get hashCode =>
      Object.hash(model, input, previousResponseId, instructions);

  @override
  String toString() =>
      'CompactResponseRequest(model: $model, previousResponseId: $previousResponseId)';
}
