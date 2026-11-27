import '../copy_with_sentinel.dart';
import '../interactions/usage.dart';
import 'decision_answer.dart';
import 'decision_prompt_feedback.dart';

/// Calibrated answers and usage from a batch of decision questions.
final class CreateDecisionResponse {
  /// Answers keyed by the question IDs supplied in the request.
  ///
  /// Can be absent or empty when the response contains prompt feedback.
  final Map<String, DecisionAnswer>? answers;

  /// Token usage for evaluating the batch.
  final InteractionUsage? usage;

  /// Feedback from input content filters, when present.
  final DecisionPromptFeedback? promptFeedback;

  /// Creates a decision response.
  const CreateDecisionResponse({this.answers, this.usage, this.promptFeedback});

  /// Parses a decision response.
  factory CreateDecisionResponse.fromJson(Map<String, dynamic> json) {
    final answers = json['answers'] as Map<String, dynamic>?;
    final usage = json['usage'] as Map<String, dynamic>?;
    final promptFeedback = json['prompt_feedback'] as Map<String, dynamic>?;
    return CreateDecisionResponse(
      answers: answers?.map(
        (key, value) => MapEntry(
          key,
          DecisionAnswer.fromJson(value as Map<String, dynamic>),
        ),
      ),
      usage: usage == null ? null : InteractionUsage.fromJson(usage),
      promptFeedback: promptFeedback == null
          ? null
          : DecisionPromptFeedback.fromJson(promptFeedback),
    );
  }

  /// Converts the response to its wire representation.
  Map<String, dynamic> toJson() => {
    if (answers != null)
      'answers': answers!.map((key, value) => MapEntry(key, value.toJson())),
    if (usage != null) 'usage': usage!.toJson(),
    if (promptFeedback != null) 'prompt_feedback': promptFeedback!.toJson(),
  };

  /// Returns a copy with the supplied fields replaced.
  CreateDecisionResponse copyWith({
    Object? answers = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? promptFeedback = unsetCopyWithValue,
  }) => CreateDecisionResponse(
    answers: answers == unsetCopyWithValue
        ? this.answers
        : answers as Map<String, DecisionAnswer>?,
    usage: usage == unsetCopyWithValue
        ? this.usage
        : usage as InteractionUsage?,
    promptFeedback: promptFeedback == unsetCopyWithValue
        ? this.promptFeedback
        : promptFeedback as DecisionPromptFeedback?,
  );
}
