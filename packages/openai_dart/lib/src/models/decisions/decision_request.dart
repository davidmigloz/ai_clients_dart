import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'decision_helpers.dart';
import 'decision_input.dart';
import 'decision_question.dart';

/// A request to answer ordered predicate, choice, or score questions.
///
/// The Decisions API currently supports `gpt-6-luna` with user text and inline
/// images. The model identifier remains open for future models. A request accepts
/// 1–200 questions and up to 128 images; the server validates these limits.
@immutable
class DecisionRequest {
  /// Creates a [DecisionRequest], snapshotting [questions].
  DecisionRequest({
    required this.model,
    required this.input,
    required List<DecisionQuestion> questions,
    this.safetyIdentifier,
  }) : questions = List.unmodifiable(questions);

  /// Creates a [DecisionRequest] from JSON.
  factory DecisionRequest.fromJson(Map<String, dynamic> json) =>
      DecisionRequest(
        model: requireDecisionString(json['model'], 'DecisionRequest.model'),
        input: DecisionInput.fromJson(json['input']),
        questions: parseDecisionObjects(
          json['questions'],
          DecisionQuestion.fromJson,
          'DecisionRequest.questions',
        ),
        safetyIdentifier: json['safety_identifier'] == null
            ? null
            : requireDecisionString(
                json['safety_identifier'],
                'DecisionRequest.safety_identifier',
              ),
      );

  /// The model identifier, currently `gpt-6-luna`.
  final String model;

  /// Text or user messages containing text and inline images.
  final DecisionInput input;

  /// The ordered questions to answer.
  final List<DecisionQuestion> questions;

  /// A stable identifier for an end user, used for abuse detection.
  ///
  /// Must contain at most 128 characters. Omitted when absent.
  final String? safetyIdentifier;

  /// Converts to the JSON request body.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input.toJson(),
    'questions': questions.map((question) => question.toJson()).toList(),
    if (safetyIdentifier != null) 'safety_identifier': safetyIdentifier,
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass `safetyIdentifier: null` to clear the identifier.
  DecisionRequest copyWith({
    String? model,
    DecisionInput? input,
    List<DecisionQuestion>? questions,
    Object? safetyIdentifier = unsetCopyWithValue,
  }) => DecisionRequest(
    model: model ?? this.model,
    input: input ?? this.input,
    questions: questions ?? this.questions,
    safetyIdentifier: safetyIdentifier == unsetCopyWithValue
        ? this.safetyIdentifier
        : safetyIdentifier as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          listsEqual(questions, other.questions) &&
          safetyIdentifier == other.safetyIdentifier;

  @override
  int get hashCode =>
      Object.hash(model, input, Object.hashAll(questions), safetyIdentifier);

  @override
  String toString() =>
      'DecisionRequest(model: $model, input: $input, '
      'questions: ${questions.length} items, safetyIdentifier: $safetyIdentifier)';
}
