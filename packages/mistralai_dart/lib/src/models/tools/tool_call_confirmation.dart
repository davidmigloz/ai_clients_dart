import 'package:meta/meta.dart';

/// A confirmation response for a tool call that requires user approval.
@immutable
class ToolCallConfirmation {
  /// The ID of the tool call being confirmed.
  final String toolCallId;

  /// The confirmation decision: "allow" or "deny".
  final String confirmation;

  /// Creates a [ToolCallConfirmation].
  const ToolCallConfirmation({
    required this.toolCallId,
    required this.confirmation,
  });

  /// Creates a [ToolCallConfirmation] that allows execution.
  const ToolCallConfirmation.allow({required this.toolCallId})
    : confirmation = 'allow';

  /// Creates a [ToolCallConfirmation] that denies execution.
  const ToolCallConfirmation.deny({required this.toolCallId})
    : confirmation = 'deny';

  /// Creates a [ToolCallConfirmation] from JSON.
  factory ToolCallConfirmation.fromJson(Map<String, dynamic> json) =>
      ToolCallConfirmation(
        toolCallId: json['tool_call_id'] as String? ?? '',
        confirmation: json['confirmation'] as String? ?? 'deny',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'tool_call_id': toolCallId,
    'confirmation': confirmation,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCallConfirmation &&
          runtimeType == other.runtimeType &&
          toolCallId == other.toolCallId &&
          confirmation == other.confirmation;

  @override
  int get hashCode => Object.hash(toolCallId, confirmation);

  @override
  String toString() =>
      'ToolCallConfirmation(toolCallId: $toolCallId, '
      'confirmation: $confirmation)';
}
