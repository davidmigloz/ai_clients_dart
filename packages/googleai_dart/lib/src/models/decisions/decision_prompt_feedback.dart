import '../copy_with_sentinel.dart';

/// A Decisions prompt block reason.
///
/// The API may introduce additional reasons. Their wire values are retained.
extension type const DecisionBlockReason(String value) {
  /// The prompt was blocked by safety filters.
  static const safety = DecisionBlockReason('safety');

  /// The prompt was blocked for another reason.
  static const other = DecisionBlockReason('other');

  /// The prompt contains terms from a blocklist.
  static const blocklist = DecisionBlockReason('blocklist');

  /// The prompt contains prohibited content.
  static const prohibitedContent = DecisionBlockReason('prohibited_content');

  /// The prompt contains unsafe image content.
  static const imageSafety = DecisionBlockReason('image_safety');
}

/// Input content filter feedback from the Decisions API.
final class DecisionPromptFeedback {
  /// The reason the prompt was blocked, when reported.
  final DecisionBlockReason? blockReason;

  /// A human-readable explanation of why the prompt was blocked.
  final String? blockReasonMessage;

  /// Creates prompt feedback.
  const DecisionPromptFeedback({this.blockReason, this.blockReasonMessage});

  /// Parses prompt feedback.
  factory DecisionPromptFeedback.fromJson(Map<String, dynamic> json) {
    final reason = json['block_reason'] as String?;
    return DecisionPromptFeedback(
      blockReason: reason == null ? null : DecisionBlockReason(reason),
      blockReasonMessage: json['block_reason_message'] as String?,
    );
  }

  /// Converts prompt feedback to its wire representation.
  Map<String, dynamic> toJson() => {
    if (blockReason != null) 'block_reason': blockReason!.value,
    if (blockReasonMessage != null) 'block_reason_message': blockReasonMessage,
  };

  /// Returns a copy with the supplied fields replaced.
  DecisionPromptFeedback copyWith({
    Object? blockReason = unsetCopyWithValue,
    Object? blockReasonMessage = unsetCopyWithValue,
  }) => DecisionPromptFeedback(
    blockReason: blockReason == unsetCopyWithValue
        ? this.blockReason
        : blockReason as DecisionBlockReason?,
    blockReasonMessage: blockReasonMessage == unsetCopyWithValue
        ? this.blockReasonMessage
        : blockReasonMessage as String?,
  );
}
