import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'create_response_request.dart';

/// Request to compact a response.
///
/// Sent to the `POST /responses/compact` endpoint to summarize previous
/// turns into an opaque compaction item, reducing context size for
/// follow-up requests.
@immutable
class CompactResponseRequest {
  /// The model to use for compaction.
  final String model;

  /// The input items to compact.
  ///
  /// Can be a [ResponseTextInput] (for simple text) or [ResponseItemsInput]
  /// (for complex messages).
  final ResponseInput? input;

  /// System (or developer) message inserted into the model's context.
  ///
  /// When used along with [previousResponseId], the instructions from a
  /// previous response will not be carried over to the next response.
  final String? instructions;

  /// ID of a previous response for multi-turn conversation.
  final String? previousResponseId;

  /// A key to use when reading from or writing to the prompt cache.
  final String? promptCacheKey;

  /// Creates a [CompactResponseRequest].
  const CompactResponseRequest({
    required this.model,
    this.input,
    this.instructions,
    this.previousResponseId,
    this.promptCacheKey,
  });

  /// Creates a [CompactResponseRequest] from JSON.
  factory CompactResponseRequest.fromJson(Map<String, dynamic> json) {
    return CompactResponseRequest(
      model: json['model'] as String,
      input: json['input'] != null
          ? ResponseInput.fromJson(json['input'] as Object)
          : null,
      instructions: json['instructions'] as String?,
      previousResponseId: json['previous_response_id'] as String?,
      promptCacheKey: json['prompt_cache_key'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (input != null) 'input': input!.toJson(),
    if (instructions != null) 'instructions': instructions,
    if (previousResponseId != null) 'previous_response_id': previousResponseId,
    if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
  };

  /// Creates a copy with replaced values.
  CompactResponseRequest copyWith({
    String? model,
    Object? input = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? previousResponseId = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
  }) {
    return CompactResponseRequest(
      model: model ?? this.model,
      input: input == unsetCopyWithValue ? this.input : input as ResponseInput?,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      previousResponseId: previousResponseId == unsetCopyWithValue
          ? this.previousResponseId
          : previousResponseId as String?,
      promptCacheKey: promptCacheKey == unsetCopyWithValue
          ? this.promptCacheKey
          : promptCacheKey as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactResponseRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          instructions == other.instructions &&
          previousResponseId == other.previousResponseId &&
          promptCacheKey == other.promptCacheKey;

  @override
  int get hashCode => Object.hash(
    model,
    input,
    instructions,
    previousResponseId,
    promptCacheKey,
  );

  @override
  String toString() =>
      'CompactResponseRequest(model: $model, input: $input, instructions: $instructions, previousResponseId: $previousResponseId, promptCacheKey: $promptCacheKey)';
}
