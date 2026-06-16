import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Reason for the model to stop generating content.
enum StopReason {
  /// The model reached a natural stopping point.
  endTurn('end_turn'),

  /// The model reached the maximum number of tokens.
  maxTokens('max_tokens'),

  /// The model encountered a stop sequence.
  stopSequence('stop_sequence'),

  /// The model is invoking a tool.
  toolUse('tool_use'),

  /// The model paused mid-turn for continuation.
  pauseTurn('pause_turn'),

  /// The model compacted prior context (beta compaction flows).
  compaction('compaction'),

  /// The model exceeded the context window.
  modelContextWindowExceeded('model_context_window_exceeded'),

  /// The model refused to generate content.
  refusal('refusal');

  const StopReason(this.value);

  /// JSON value for the stop reason.
  final String value;

  /// Converts a string to [StopReason].
  static StopReason fromJson(String value) => switch (value) {
    'end_turn' => StopReason.endTurn,
    'max_tokens' => StopReason.maxTokens,
    'stop_sequence' => StopReason.stopSequence,
    'tool_use' => StopReason.toolUse,
    'pause_turn' => StopReason.pauseTurn,
    'compaction' => StopReason.compaction,
    'model_context_window_exceeded' => StopReason.modelContextWindowExceeded,
    'refusal' => StopReason.refusal,
    _ => throw FormatException('Unknown StopReason: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}

/// Policy category that triggered a refusal.
enum RefusalCategory {
  /// Unknown category (forward compatibility for unrecognized values).
  unknown('unknown'),

  /// Cyber-related policy category.
  cyber('cyber'),

  /// Bio-related policy category.
  bio('bio'),

  /// Frontier-LLM policy category.
  frontierLlm('frontier_llm'),

  /// Reasoning-extraction policy category.
  reasoningExtraction('reasoning_extraction');

  const RefusalCategory(this.value);

  /// JSON value for this category.
  final String value;

  /// Creates a [RefusalCategory] from a JSON value.
  factory RefusalCategory.fromJson(String json) {
    return RefusalCategory.values.firstWhere(
      (e) => e.value == json,
      orElse: () => RefusalCategory.unknown,
    );
  }

  /// Converts to JSON string.
  String toJson() => value;
}

/// Structured information about why model output stopped due to a refusal.
///
/// This is non-null when [StopReason.refusal] is the stop reason.
@immutable
class RefusalStopDetails {
  /// Object type. Always "refusal".
  final String type;

  /// The policy category that triggered the refusal.
  ///
  /// `null` when the refusal doesn't map to a named category.
  final RefusalCategory? category;

  /// Human-readable explanation of the refusal.
  ///
  /// This text is not guaranteed to be stable.
  /// `null` when no explanation is available for the category.
  final String? explanation;

  /// Opaque code that refunds the cache-miss cost when retrying this refused
  /// request on the fallback model.
  ///
  /// Pass it as `fallbackCreditToken` on the retry request. Expires 5 minutes
  /// after the refusal. `null` when the refused model isn't eligible for a
  /// fallback credit.
  final String? fallbackCreditToken;

  /// Whether the accompanying [fallbackCreditToken] may be redeemed with the
  /// appended-assistant retry form.
  ///
  /// Only set when [fallbackCreditToken] is present.
  final bool? fallbackHasPrefillClaim;

  /// The server's suggested retry target for this refusal.
  ///
  /// Populated when a fallback attempt could not be made (the fallback model's
  /// rate limit was exhausted, or it was overloaded). `null` otherwise.
  final String? recommendedModel;

  /// Creates a [RefusalStopDetails].
  const RefusalStopDetails({
    this.type = 'refusal',
    this.category,
    this.explanation,
    this.fallbackCreditToken,
    this.fallbackHasPrefillClaim,
    this.recommendedModel,
  });

  /// Creates a [RefusalStopDetails] from JSON.
  factory RefusalStopDetails.fromJson(Map<String, dynamic> json) {
    return RefusalStopDetails(
      type: json['type'] as String? ?? 'refusal',
      category: json['category'] != null
          ? RefusalCategory.fromJson(json['category'] as String)
          : null,
      explanation: json['explanation'] as String?,
      fallbackCreditToken: json['fallback_credit_token'] as String?,
      fallbackHasPrefillClaim: json['fallback_has_prefill_claim'] as bool?,
      recommendedModel: json['recommended_model'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'category': category?.toJson(),
    'explanation': explanation,
    if (fallbackCreditToken != null)
      'fallback_credit_token': fallbackCreditToken,
    if (fallbackHasPrefillClaim != null)
      'fallback_has_prefill_claim': fallbackHasPrefillClaim,
    if (recommendedModel != null) 'recommended_model': recommendedModel,
  };

  /// Creates a copy with replaced values.
  RefusalStopDetails copyWith({
    String? type,
    Object? category = unsetCopyWithValue,
    Object? explanation = unsetCopyWithValue,
    Object? fallbackCreditToken = unsetCopyWithValue,
    Object? fallbackHasPrefillClaim = unsetCopyWithValue,
    Object? recommendedModel = unsetCopyWithValue,
  }) {
    return RefusalStopDetails(
      type: type ?? this.type,
      category: category == unsetCopyWithValue
          ? this.category
          : category as RefusalCategory?,
      explanation: explanation == unsetCopyWithValue
          ? this.explanation
          : explanation as String?,
      fallbackCreditToken: fallbackCreditToken == unsetCopyWithValue
          ? this.fallbackCreditToken
          : fallbackCreditToken as String?,
      fallbackHasPrefillClaim: fallbackHasPrefillClaim == unsetCopyWithValue
          ? this.fallbackHasPrefillClaim
          : fallbackHasPrefillClaim as bool?,
      recommendedModel: recommendedModel == unsetCopyWithValue
          ? this.recommendedModel
          : recommendedModel as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalStopDetails &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          category == other.category &&
          explanation == other.explanation &&
          fallbackCreditToken == other.fallbackCreditToken &&
          fallbackHasPrefillClaim == other.fallbackHasPrefillClaim &&
          recommendedModel == other.recommendedModel;

  @override
  int get hashCode => Object.hash(
    type,
    category,
    explanation,
    fallbackCreditToken,
    fallbackHasPrefillClaim,
    recommendedModel,
  );

  @override
  String toString() =>
      'RefusalStopDetails(type: $type, category: $category, '
      'explanation: $explanation, '
      'fallbackCreditToken: ${fallbackCreditToken == null ? null : '[redacted]'}, '
      'fallbackHasPrefillClaim: $fallbackHasPrefillClaim, '
      'recommendedModel: $recommendedModel)';
}
