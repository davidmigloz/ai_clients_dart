import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../responses/response_usage.dart';
import 'decision_answer.dart';
import 'decision_helpers.dart';

/// The ordered answers and token usage returned by the Decisions API.
@immutable
class DecisionResponse {
  /// Creates a [DecisionResponse], snapshotting [answers].
  DecisionResponse({
    required this.model,
    required List<DecisionAnswer> answers,
    required this.usage,
  }) : answers = List.unmodifiable(answers);

  /// Creates a [DecisionResponse] from JSON.
  ///
  /// Decisions requires all usage counters and both detail objects. Those fields
  /// are checked here while the shared [ResponseUsage] parser remains compatible
  /// with older Responses and compatible-provider usage shapes.
  factory DecisionResponse.fromJson(Map<String, dynamic> json) {
    final usage = requireDecisionMap(json['usage'], 'DecisionResponse.usage');
    _validateDecisionUsage(usage);
    return DecisionResponse(
      model: requireDecisionString(json['model'], 'DecisionResponse.model'),
      answers: parseDecisionObjects(
        json['answers'],
        DecisionAnswer.fromJson,
        'DecisionResponse.answers',
      ),
      usage: ResponseUsage.fromJson(usage),
    );
  }

  /// The model that answered the questions.
  final String model;

  /// Answers in the same order as the request's questions.
  ///
  /// A [RefusalDecisionAnswer] may appear alongside successful answers.
  final List<DecisionAnswer> answers;

  /// Reported token counts, including cached, cache-write, and reasoning tokens.
  final ResponseUsage usage;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'answers': answers.map((answer) => answer.toJson()).toList(),
    'usage': usage.toJson(),
  };

  /// Creates a copy with replaced values.
  DecisionResponse copyWith({
    String? model,
    List<DecisionAnswer>? answers,
    ResponseUsage? usage,
  }) => DecisionResponse(
    model: model ?? this.model,
    answers: answers ?? this.answers,
    usage: usage ?? this.usage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionResponse &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          listsEqual(answers, other.answers) &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(model, Object.hashAll(answers), usage);

  @override
  String toString() =>
      'DecisionResponse(model: $model, answers: ${answers.length} items, '
      'usage: $usage)';
}

void _validateDecisionUsage(Map<String, dynamic> usage) {
  for (final field in ['input_tokens', 'output_tokens', 'total_tokens']) {
    requireDecisionInt(usage[field], 'DecisionResponse.usage.$field');
  }
  final input = requireDecisionMap(
    usage['input_tokens_details'],
    'DecisionResponse.usage.input_tokens_details',
  );
  for (final field in ['cached_tokens', 'cache_write_tokens']) {
    requireDecisionInt(
      input[field],
      'DecisionResponse.usage.input_tokens_details.$field',
    );
  }
  final output = requireDecisionMap(
    usage['output_tokens_details'],
    'DecisionResponse.usage.output_tokens_details',
  );
  requireDecisionInt(
    output['reasoning_tokens'],
    'DecisionResponse.usage.output_tokens_details.reasoning_tokens',
  );
}
