import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'decision_cache.dart';
import 'decision_helpers.dart';
import 'decision_input.dart';
import 'decision_question.dart';

/// A request to answer ordered predicate, choice, or score questions.
///
/// The Decisions API supports `gpt-6-luna` with conversation/tool history,
/// JSON, and data URL or public HTTP(S) images. The model identifier remains
/// open for future models. A request accepts 1–400 questions; the server
/// validates aggregate request/image limits.
@immutable
class DecisionRequest {
  /// Creates a [DecisionRequest], snapshotting [questions].
  DecisionRequest({
    required this.model,
    required this.input,
    required List<DecisionQuestion> questions,
    this.safetyIdentifier,
    this.promptCacheKey,
    this.promptCacheOptions,
  }) : questions = List.unmodifiable(questions) {
    if (promptCacheKey != null && promptCacheKey!.runes.length > 64) {
      throw ArgumentError(
        'DecisionRequest.promptCacheKey: maximum 64 characters',
      );
    }
  }

  /// Creates a [DecisionRequest] from JSON.
  factory DecisionRequest.fromJson(Map<String, dynamic> json) {
    final cacheKey = json['prompt_cache_key'] == null
        ? null
        : requireDecisionString(
            json['prompt_cache_key'],
            'DecisionRequest.prompt_cache_key',
          );
    if (cacheKey != null && cacheKey.runes.length > 64) {
      throw const FormatException(
        'DecisionRequest.prompt_cache_key: maximum 64 characters',
      );
    }
    return DecisionRequest(
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
      promptCacheKey: cacheKey,
      promptCacheOptions: json['prompt_cache_options'] == null
          ? null
          : DecisionPromptCacheOptions.fromJson(
              requireDecisionMap(
                json['prompt_cache_options'],
                'DecisionRequest.prompt_cache_options',
              ),
            ),
    );
  }

  /// The model identifier, currently `gpt-6-luna`.
  final String model;

  /// Shared text, conversation/tool history, images, and structured JSON.
  final DecisionInput input;

  /// The ordered questions to answer.
  final List<DecisionQuestion> questions;

  /// A stable identifier for an end user, used for abuse detection.
  ///
  /// Must contain at most 128 characters. Omitted when absent.
  final String? safetyIdentifier;

  /// An optional partition key for shared-input cache reuse (maximum 64 chars).
  final String? promptCacheKey;

  /// Cache controls for shared input. Question content is not cached.
  final DecisionPromptCacheOptions? promptCacheOptions;

  /// Converts to the JSON request body.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input.toJson(),
    'questions': questions.map((question) => question.toJson()).toList(),
    if (safetyIdentifier != null) 'safety_identifier': safetyIdentifier,
    if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
    if (promptCacheOptions != null)
      'prompt_cache_options': promptCacheOptions!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass explicit null to clear the safety identifier, cache key, or options.
  DecisionRequest copyWith({
    String? model,
    DecisionInput? input,
    List<DecisionQuestion>? questions,
    Object? safetyIdentifier = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
    Object? promptCacheOptions = unsetCopyWithValue,
  }) => DecisionRequest(
    model: model ?? this.model,
    input: input ?? this.input,
    questions: questions ?? this.questions,
    safetyIdentifier: safetyIdentifier == unsetCopyWithValue
        ? this.safetyIdentifier
        : safetyIdentifier as String?,
    promptCacheKey: identical(promptCacheKey, unsetCopyWithValue)
        ? this.promptCacheKey
        : promptCacheKey as String?,
    promptCacheOptions: identical(promptCacheOptions, unsetCopyWithValue)
        ? this.promptCacheOptions
        : promptCacheOptions as DecisionPromptCacheOptions?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          listsEqual(questions, other.questions) &&
          safetyIdentifier == other.safetyIdentifier &&
          promptCacheKey == other.promptCacheKey &&
          promptCacheOptions == other.promptCacheOptions;

  @override
  int get hashCode => Object.hash(
    model,
    input,
    Object.hashAll(questions),
    safetyIdentifier,
    promptCacheKey,
    promptCacheOptions,
  );

  @override
  String toString() =>
      'DecisionRequest(model: $model, input: $input, '
      'questions: ${questions.length} items, safetyIdentifier: $safetyIdentifier, '
      'promptCacheKey: ${promptCacheKey == null ? null : '[${promptCacheKey!.length} chars]'}, promptCacheOptions: $promptCacheOptions)';
}
