import 'package:meta/meta.dart';

/// A grader (testing criterion) for evaluating model outputs.
///
/// Graders define how model outputs are evaluated during an evaluation run.
/// Each grader can reference variables using template syntax:
/// - `{{item.*}}` - Data from the evaluation item
/// - `{{sample.*}}` - Model output data (e.g., `{{sample.output_text}}`)
///
/// Available grader types:
/// - [LabelModelGrader] - Uses an AI model to classify outputs into labels
/// - [StringCheckGrader] - Pattern matching on strings
/// - [TextSimilarityGrader] - Compares text similarity with a threshold
/// - [PythonGrader] - Runs custom Python code for evaluation
/// - [ScoreModelGrader] - Uses an AI model to assign numeric scores
@immutable
sealed class EvalGrader {
  const EvalGrader();

  /// Creates an [EvalGrader] from JSON.
  factory EvalGrader.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'label_model' => LabelModelGrader.fromJson(json),
      'string_check' => StringCheckGrader.fromJson(json),
      'text_similarity' => TextSimilarityGrader.fromJson(json),
      'python' => PythonGrader.fromJson(json),
      'score_model' => ScoreModelGrader.fromJson(json),
      _ => throw FormatException('Unknown grader type: $type'),
    };
  }

  /// Creates a label model grader.
  static LabelModelGrader labelModel({
    required String name,
    required String model,
    required List<String> labels,
    required List<String> passingLabels,
    required List<LabelModelInput> input,
  }) {
    return LabelModelGrader(
      name: name,
      model: model,
      labels: labels,
      passingLabels: passingLabels,
      input: input,
    );
  }

  /// Creates a string check grader.
  static StringCheckGrader stringCheck({
    required String name,
    required String input,
    required StringCheckOperation operation,
    required String reference,
  }) {
    return StringCheckGrader(
      name: name,
      input: input,
      operation: operation,
      reference: reference,
    );
  }

  /// Creates a text similarity grader.
  static TextSimilarityGrader textSimilarity({
    required String name,
    required String input,
    required String reference,
    TextSimilarityMetric? evaluationMetric,
    double? passThreshold,
  }) {
    return TextSimilarityGrader(
      name: name,
      input: input,
      reference: reference,
      evaluationMetric: evaluationMetric,
      passThreshold: passThreshold,
    );
  }

  /// Creates a Python grader.
  static PythonGrader python({
    required String name,
    required String source,
    double? passThreshold,
  }) {
    return PythonGrader(
      name: name,
      source: source,
      passThreshold: passThreshold,
    );
  }

  /// Creates a score model grader.
  static ScoreModelGrader scoreModel({
    required String name,
    required String model,
    required List<ScoreModelInput> input,
    double? passThreshold,
    String? samplingParams,
  }) {
    return ScoreModelGrader(
      name: name,
      model: model,
      input: input,
      passThreshold: passThreshold,
      samplingParams: samplingParams,
    );
  }

  /// The type of grader.
  String get type;

  /// The name of this grader.
  String get name;

  /// Converts this to JSON.
  Map<String, dynamic> toJson();
}

/// Uses an AI model to classify outputs into predefined labels.
///
/// The model evaluates inputs and assigns one of the specified labels.
/// Outputs are considered passing if they match one of the [passingLabels].
///
/// ## Example
/// ```dart
/// final grader = EvalGrader.labelModel(
///   name: 'sentiment',
///   model: 'gpt-4o-mini',
///   labels: ['positive', 'negative', 'neutral'],
///   passingLabels: ['positive'],
///   input: [
///     LabelModelInput.user('Classify: {{sample.output_text}}'),
///   ],
/// );
/// ```
@immutable
class LabelModelGrader extends EvalGrader {
  /// Creates a [LabelModelGrader].
  const LabelModelGrader({
    required this.name,
    required this.model,
    required this.labels,
    required this.passingLabels,
    required this.input,
  });

  /// Creates a [LabelModelGrader] from JSON.
  factory LabelModelGrader.fromJson(Map<String, dynamic> json) {
    return LabelModelGrader(
      name: json['name'] as String,
      model: json['model'] as String,
      labels: (json['labels'] as List<dynamic>).cast<String>(),
      passingLabels: (json['passing_labels'] as List<dynamic>).cast<String>(),
      input: (json['input'] as List<dynamic>)
          .map((e) => LabelModelInput.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  final String name;

  /// The model to use for classification.
  final String model;

  /// The possible labels the model can assign.
  final List<String> labels;

  /// Labels that are considered passing.
  final List<String> passingLabels;

  /// The input messages for the model.
  final List<LabelModelInput> input;

  @override
  String get type => 'label_model';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'model': model,
    'labels': labels,
    'passing_labels': passingLabels,
    'input': input.map((i) => i.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelModelGrader &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'LabelModelGrader(name: $name, model: $model)';
}

/// Input message for a label model grader.
@immutable
class LabelModelInput {
  /// Creates a [LabelModelInput].
  const LabelModelInput({required this.role, required this.content});

  /// Creates a [LabelModelInput] from JSON.
  factory LabelModelInput.fromJson(Map<String, dynamic> json) {
    return LabelModelInput(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  /// Creates a system message.
  const LabelModelInput.system(String content)
    : this(role: 'system', content: content);

  /// Creates a user message.
  const LabelModelInput.user(String content)
    : this(role: 'user', content: content);

  /// Creates an assistant message.
  const LabelModelInput.assistant(String content)
    : this(role: 'assistant', content: content);

  /// The role of this message.
  final String role;

  /// The content of this message (can include template variables).
  final String content;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelModelInput &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'LabelModelInput(role: $role)';
}

/// Pattern matching grader that checks strings against patterns.
///
/// ## Example
/// ```dart
/// final grader = EvalGrader.stringCheck(
///   name: 'contains_greeting',
///   input: '{{sample.output_text}}',
///   operation: StringCheckOperation.ilike,
///   reference: '%hello%',
/// );
/// ```
@immutable
class StringCheckGrader extends EvalGrader {
  /// Creates a [StringCheckGrader].
  const StringCheckGrader({
    required this.name,
    required this.input,
    required this.operation,
    required this.reference,
  });

  /// Creates a [StringCheckGrader] from JSON.
  factory StringCheckGrader.fromJson(Map<String, dynamic> json) {
    return StringCheckGrader(
      name: json['name'] as String,
      input: json['input'] as String,
      operation: StringCheckOperation.fromJson(json['operation'] as String),
      reference: json['reference'] as String,
    );
  }

  @override
  final String name;

  /// The input string to check (can include template variables).
  final String input;

  /// The operation to perform.
  final StringCheckOperation operation;

  /// The reference string to compare against.
  final String reference;

  @override
  String get type => 'string_check';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'input': input,
    'operation': operation.toJson(),
    'reference': reference,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringCheckGrader &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'StringCheckGrader(name: $name, operation: $operation)';
}

/// Operations for string check grader.
///
/// The OpenAI Evals API supports the following operations:
/// - `eq` - Equal (case-sensitive match)
/// - `ne` - Not equal
/// - `like` - Pattern match (SQL LIKE-style, case-sensitive)
/// - `ilike` - Pattern match (case-insensitive)
enum StringCheckOperation {
  /// Checks if input equals reference (case-sensitive).
  equals._('eq'),

  /// Checks if input does not equal reference.
  notEquals._('ne'),

  /// Checks if input matches reference pattern (case-sensitive).
  ///
  /// Use `%` as wildcard for any sequence of characters.
  /// Example: `%hello%` matches any string containing "hello".
  like._('like'),

  /// Checks if input matches reference pattern (case-insensitive).
  ///
  /// Use `%` as wildcard for any sequence of characters.
  /// Example: `%hello%` matches any string containing "hello" in any case.
  ilike._('ilike');

  const StringCheckOperation._(this._value);

  /// Creates from JSON string.
  factory StringCheckOperation.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown operation: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Compares text similarity using a specified metric.
///
/// Useful for checking if model output is semantically similar to expected text.
///
/// ## Example
/// ```dart
/// final grader = EvalGrader.textSimilarity(
///   name: 'answer_similarity',
///   input: '{{sample.output_text}}',
///   reference: '{{item.expected_answer}}',
///   evaluationMetric: TextSimilarityMetric.cosine,
///   passThreshold: 0.8,
/// );
/// ```
@immutable
class TextSimilarityGrader extends EvalGrader {
  /// Creates a [TextSimilarityGrader].
  const TextSimilarityGrader({
    required this.name,
    required this.input,
    required this.reference,
    this.evaluationMetric,
    this.passThreshold,
  });

  /// Creates a [TextSimilarityGrader] from JSON.
  factory TextSimilarityGrader.fromJson(Map<String, dynamic> json) {
    return TextSimilarityGrader(
      name: json['name'] as String,
      input: json['input'] as String,
      reference: json['reference'] as String,
      evaluationMetric: json['evaluation_metric'] != null
          ? TextSimilarityMetric.fromJson(json['evaluation_metric'] as String)
          : null,
      passThreshold: (json['pass_threshold'] as num?)?.toDouble(),
    );
  }

  @override
  final String name;

  /// The input text to compare (can include template variables).
  final String input;

  /// The reference text to compare against.
  final String reference;

  /// The similarity metric to use.
  final TextSimilarityMetric? evaluationMetric;

  /// The minimum similarity score required to pass.
  final double? passThreshold;

  @override
  String get type => 'text_similarity';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'input': input,
    'reference': reference,
    if (evaluationMetric != null)
      'evaluation_metric': evaluationMetric!.toJson(),
    if (passThreshold != null) 'pass_threshold': passThreshold,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSimilarityGrader &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'TextSimilarityGrader(name: $name, passThreshold: $passThreshold)';
}

/// Metrics for text similarity comparison.
enum TextSimilarityMetric {
  /// Cosine similarity between text embeddings.
  cosine._('cosine'),

  /// Fuzzy string matching.
  fuzzyMatch._('fuzzy_match'),

  /// Normalized Levenshtein distance.
  levenshtein._('levenshtein'),

  /// BLEU score for translation quality.
  bleu._('bleu');

  const TextSimilarityMetric._(this._value);

  /// Creates from JSON string.
  factory TextSimilarityMetric.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown metric: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Runs custom Python code for evaluation.
///
/// The Python code should define a `grade` function that returns a score.
///
/// ## Example
/// ```dart
/// final grader = EvalGrader.python(
///   name: 'custom_check',
///   source: '''
/// def grade(item, sample):
///     return 1.0 if sample.output_text.startswith('Hello') else 0.0
/// ''',
///   passThreshold: 0.5,
/// );
/// ```
@immutable
class PythonGrader extends EvalGrader {
  /// Creates a [PythonGrader].
  const PythonGrader({
    required this.name,
    required this.source,
    this.passThreshold,
  });

  /// Creates a [PythonGrader] from JSON.
  factory PythonGrader.fromJson(Map<String, dynamic> json) {
    return PythonGrader(
      name: json['name'] as String,
      source: json['source'] as String,
      passThreshold: (json['pass_threshold'] as num?)?.toDouble(),
    );
  }

  @override
  final String name;

  /// The Python source code containing the `grade` function.
  final String source;

  /// The minimum score required to pass.
  final double? passThreshold;

  @override
  String get type => 'python';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'source': source,
    if (passThreshold != null) 'pass_threshold': passThreshold,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PythonGrader &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'PythonGrader(name: $name, passThreshold: $passThreshold)';
}

/// Uses an AI model to assign numeric scores.
///
/// The model evaluates inputs and returns a score, which is compared
/// against the [passThreshold].
///
/// ## Example
/// ```dart
/// final grader = EvalGrader.scoreModel(
///   name: 'quality_score',
///   model: 'gpt-4o-mini',
///   input: [
///     ScoreModelInput.system('Rate the quality of this response from 0-10.'),
///     ScoreModelInput.user('Response: {{sample.output_text}}'),
///   ],
///   passThreshold: 7.0,
/// );
/// ```
@immutable
class ScoreModelGrader extends EvalGrader {
  /// Creates a [ScoreModelGrader].
  const ScoreModelGrader({
    required this.name,
    required this.model,
    required this.input,
    this.passThreshold,
    this.samplingParams,
  });

  /// Creates a [ScoreModelGrader] from JSON.
  factory ScoreModelGrader.fromJson(Map<String, dynamic> json) {
    return ScoreModelGrader(
      name: json['name'] as String,
      model: json['model'] as String,
      input: (json['input'] as List<dynamic>)
          .map((e) => ScoreModelInput.fromJson(e as Map<String, dynamic>))
          .toList(),
      passThreshold: (json['pass_threshold'] as num?)?.toDouble(),
      samplingParams: json['sampling_params'] as String?,
    );
  }

  @override
  final String name;

  /// The model to use for scoring.
  final String model;

  /// The input messages for the model.
  final List<ScoreModelInput> input;

  /// The minimum score required to pass.
  final double? passThreshold;

  /// Optional sampling parameters as JSON string.
  final String? samplingParams;

  @override
  String get type => 'score_model';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'model': model,
    'input': input.map((i) => i.toJson()).toList(),
    if (passThreshold != null) 'pass_threshold': passThreshold,
    if (samplingParams != null) 'sampling_params': samplingParams,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreModelGrader &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'ScoreModelGrader(name: $name, model: $model, passThreshold: $passThreshold)';
}

/// Input message for a score model grader.
@immutable
class ScoreModelInput {
  /// Creates a [ScoreModelInput].
  const ScoreModelInput({required this.role, required this.content});

  /// Creates a [ScoreModelInput] from JSON.
  factory ScoreModelInput.fromJson(Map<String, dynamic> json) {
    return ScoreModelInput(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  /// Creates a system message.
  const ScoreModelInput.system(String content)
    : this(role: 'system', content: content);

  /// Creates a user message.
  const ScoreModelInput.user(String content)
    : this(role: 'user', content: content);

  /// Creates an assistant message.
  const ScoreModelInput.assistant(String content)
    : this(role: 'assistant', content: content);

  /// The role of this message.
  final String role;

  /// The content of this message (can include template variables).
  final String content;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreModelInput &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'ScoreModelInput(role: $role)';
}
