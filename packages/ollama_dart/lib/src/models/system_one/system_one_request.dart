import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/keep_alive.dart';
import '_system_one_helpers.dart';
import 'system_one_content.dart';
import 'system_one_question.dart';

/// Request for the local System One decision API, available in Ollama v0.35.0+.
///
/// Each question is evaluated independently against the shared state and full
/// question schema. The server validates limits and never truncates input.
@immutable
class SystemOneRequest {
  /// Creates a request and copies its ordered question map.
  SystemOneRequest({
    required this.model,
    required this.state,
    required Map<String, SystemOneQuestion> questions,
    this.keepAlive,
  }) : questions = Map.unmodifiable(questions);

  /// Compatible local model name, such as `nimble` or `tev1`.
  final String model;

  /// Shared text or structured JSON context.
  final SystemOneContent state;

  /// Named questions in their supplied order; the server requires 1–64.
  final Map<String, SystemOneQuestion> questions;

  /// How long to keep the model loaded after the request.
  final KeepAlive? keepAlive;

  /// Creates a request from JSON, validating field shapes.
  factory SystemOneRequest.fromJson(Map<String, dynamic> json) {
    final questions = systemOneObject(
      json['questions'],
      'SystemOneRequest.questions',
    );
    final keepAlive = json['keep_alive'];
    if (keepAlive != null && keepAlive is! String && keepAlive is! num) {
      throw const FormatException(
        'SystemOneRequest.keep_alive must be a string or number',
      );
    }
    return SystemOneRequest(
      model: systemOneString(json['model'], 'SystemOneRequest.model'),
      state: SystemOneContent.fromJson(
        json['state'],
        context: 'SystemOneRequest.state',
      ),
      questions: {
        for (final entry in questions.entries)
          entry.key: SystemOneQuestion.fromJson(
            systemOneObject(
              entry.value,
              'SystemOneRequest.questions.${entry.key}',
            ),
          ),
      },
      keepAlive: KeepAlive.fromJson(keepAlive),
    );
  }

  /// Converts to JSON without sorting question or choice keys.
  Map<String, dynamic> toJson() => {
    'model': model,
    'state': state.toJson(),
    'questions': {
      for (final entry in questions.entries) entry.key: entry.value.toJson(),
    },
    if (keepAlive != null) 'keep_alive': keepAlive!.toJson(),
  };

  /// Creates a copy; passing null clears the optional keep-alive setting.
  SystemOneRequest copyWith({
    String? model,
    SystemOneContent? state,
    Map<String, SystemOneQuestion>? questions,
    Object? keepAlive = unsetCopyWithValue,
  }) => SystemOneRequest(
    model: model ?? this.model,
    state: state ?? this.state,
    questions: questions ?? this.questions,
    keepAlive: keepAlive == unsetCopyWithValue
        ? this.keepAlive
        : keepAlive as KeepAlive?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneRequest &&
          model == other.model &&
          state == other.state &&
          systemOneOrderedMapsEqual(questions, other.questions) &&
          keepAlive == other.keepAlive;

  @override
  int get hashCode =>
      Object.hash(model, state, systemOneOrderedMapHash(questions), keepAlive);

  @override
  String toString() =>
      'SystemOneRequest(model: $model, state: $state, '
      'questions: ${questions.length} entries, keepAlive: $keepAlive)';
}
