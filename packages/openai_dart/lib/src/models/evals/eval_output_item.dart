import 'package:meta/meta.dart';

/// An output item from an evaluation run.
///
/// Each output item represents one evaluation data point with its
/// model sample and grading results.
@immutable
class EvalOutputItem {
  /// Creates an [EvalOutputItem].
  const EvalOutputItem({
    required this.id,
    required this.evalId,
    required this.runId,
    required this.createdAt,
    required this.object,
    required this.status,
    required this.datasourceItem,
    required this.datasourceItemId,
    required this.sample,
    required this.results,
  });

  /// Creates an [EvalOutputItem] from JSON.
  factory EvalOutputItem.fromJson(Map<String, dynamic> json) {
    return EvalOutputItem(
      id: json['id'] as String,
      evalId: json['eval_id'] as String,
      runId: json['run_id'] as String,
      createdAt: json['created_at'] as int,
      object: json['object'] as String,
      status: json['status'] as String,
      datasourceItem: Map<String, dynamic>.from(
        json['datasource_item'] as Map<dynamic, dynamic>,
      ),
      datasourceItemId: json['datasource_item_id'] as int,
      sample: EvalOutputItemSample.fromJson(
        Map<String, dynamic>.from(json['sample'] as Map<dynamic, dynamic>),
      ),
      results: (json['results'] as List<dynamic>)
          .map(
            (e) => EvalOutputItemResult.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList(),
    );
  }

  /// The unique identifier for this output item.
  final String id;

  /// The ID of the parent evaluation.
  final String evalId;

  /// The ID of the parent run.
  final String runId;

  /// The Unix timestamp (in seconds) when this item was created.
  final int createdAt;

  /// The object type (always "eval.run.output_item").
  final String object;

  /// The status of this output item (e.g., "pass", "fail").
  final String status;

  /// The original data source item that was evaluated.
  final Map<String, dynamic> datasourceItem;

  /// The numeric ID of the data source item.
  final int datasourceItemId;

  /// The model sample generated for this item.
  final EvalOutputItemSample sample;

  /// The grading results for this item.
  final List<EvalOutputItemResult> results;

  /// Whether this item passed all graders.
  bool get passed => status == 'pass';

  /// Whether this item failed any grader.
  bool get failed => status == 'fail';

  /// The number of graders that passed.
  int get passedCount => results.where((r) => r.passed).length;

  /// The number of graders that failed.
  int get failedCount => results.where((r) => !r.passed).length;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'eval_id': evalId,
    'run_id': runId,
    'created_at': createdAt,
    'object': object,
    'status': status,
    'datasource_item': datasourceItem,
    'datasource_item_id': datasourceItemId,
    'sample': sample.toJson(),
    'results': results.map((r) => r.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EvalOutputItem(id: $id, status: $status)';
}

/// A paginated list of evaluation output items.
@immutable
class EvalOutputItemList {
  /// Creates an [EvalOutputItemList].
  const EvalOutputItemList({
    required this.object,
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates an [EvalOutputItemList] from JSON.
  factory EvalOutputItemList.fromJson(Map<String, dynamic> json) {
    return EvalOutputItemList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => EvalOutputItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of output items.
  final List<EvalOutputItem> data;

  /// Whether there are more items available.
  final bool hasMore;

  /// The ID of the first item in this page.
  final String? firstId;

  /// The ID of the last item in this page.
  final String? lastId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((i) => i.toJson()).toList(),
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalOutputItemList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'EvalOutputItemList(${data.length} items)';
}

/// A grading result for an output item.
@immutable
class EvalOutputItemResult {
  /// Creates an [EvalOutputItemResult].
  const EvalOutputItemResult({
    required this.name,
    required this.passed,
    this.score,
    this.sample,
    this.type,
  });

  /// Creates an [EvalOutputItemResult] from JSON.
  factory EvalOutputItemResult.fromJson(Map<String, dynamic> json) {
    return EvalOutputItemResult(
      name: json['name'] as String,
      passed: json['passed'] as bool,
      score: (json['score'] as num?)?.toDouble(),
      sample: json['sample'] as String?,
      type: json['type'] as String?,
    );
  }

  /// The name of the grader.
  final String name;

  /// Whether this grader passed.
  final bool passed;

  /// The numeric score (if applicable).
  final double? score;

  /// Sample data (e.g., the model label for label graders).
  final String? sample;

  /// The type of grader.
  final String? type;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'passed': passed,
    if (score != null) 'score': score,
    if (sample != null) 'sample': sample,
    if (type != null) 'type': type,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalOutputItemResult &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'EvalOutputItemResult(name: $name, passed: $passed, score: $score)';
}

/// Sample data from model evaluation.
@immutable
class EvalOutputItemSample {
  /// Creates an [EvalOutputItemSample].
  const EvalOutputItemSample({
    this.input,
    this.output,
    this.model,
    this.error,
    this.finishReason,
    this.usage,
    this.maxCompletionTokens,
    this.seed,
    this.temperature,
    this.topP,
  });

  /// Creates an [EvalOutputItemSample] from JSON.
  factory EvalOutputItemSample.fromJson(Map<String, dynamic> json) {
    return EvalOutputItemSample(
      input: (json['input'] as List<dynamic>?)
          ?.map((e) => EvalSampleMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      output: (json['output'] as List<dynamic>?)
          ?.map((e) => EvalSampleMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      model: json['model'] as String?,
      error: json['error'] as String?,
      finishReason: json['finish_reason'] as String?,
      usage: json['usage'] != null
          ? EvalSampleUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      maxCompletionTokens: json['max_completion_tokens'] as int?,
      seed: json['seed'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
    );
  }

  /// The input messages sent to the model.
  final List<EvalSampleMessage>? input;

  /// The output messages generated by the model.
  final List<EvalSampleMessage>? output;

  /// The model used.
  final String? model;

  /// Error message if the sample failed.
  final String? error;

  /// The finish reason for the completion.
  final String? finishReason;

  /// Token usage for this sample.
  final EvalSampleUsage? usage;

  /// Maximum completion tokens configured.
  final int? maxCompletionTokens;

  /// Random seed used.
  final int? seed;

  /// Temperature used.
  final double? temperature;

  /// Top-p value used.
  final double? topP;

  /// The output text (concatenated from output messages).
  String get outputText {
    if (output == null || output!.isEmpty) return '';
    return output!.map((m) => m.content).join();
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (input != null) 'input': input!.map((m) => m.toJson()).toList(),
    if (output != null) 'output': output!.map((m) => m.toJson()).toList(),
    if (model != null) 'model': model,
    if (error != null) 'error': error,
    if (finishReason != null) 'finish_reason': finishReason,
    if (usage != null) 'usage': usage!.toJson(),
    if (maxCompletionTokens != null)
      'max_completion_tokens': maxCompletionTokens,
    if (seed != null) 'seed': seed,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalOutputItemSample && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(model, finishReason);

  @override
  String toString() =>
      'EvalOutputItemSample(model: $model, finishReason: $finishReason)';
}

/// A message in a sample.
@immutable
class EvalSampleMessage {
  /// Creates an [EvalSampleMessage].
  const EvalSampleMessage({required this.role, required this.content});

  /// Creates an [EvalSampleMessage] from JSON.
  factory EvalSampleMessage.fromJson(Map<String, dynamic> json) {
    return EvalSampleMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  /// The role (system, user, assistant).
  final String role;

  /// The message content.
  final String content;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalSampleMessage &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'EvalSampleMessage(role: $role)';
}

/// Token usage for a sample.
@immutable
class EvalSampleUsage {
  /// Creates an [EvalSampleUsage].
  const EvalSampleUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.cachedTokens,
  });

  /// Creates an [EvalSampleUsage] from JSON.
  factory EvalSampleUsage.fromJson(Map<String, dynamic> json) {
    return EvalSampleUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
      cachedTokens: json['cached_tokens'] as int?,
    );
  }

  /// Number of prompt tokens.
  final int promptTokens;

  /// Number of completion tokens.
  final int completionTokens;

  /// Total tokens.
  final int totalTokens;

  /// Number of cached tokens.
  final int? cachedTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt_tokens': promptTokens,
    'completion_tokens': completionTokens,
    'total_tokens': totalTokens,
    if (cachedTokens != null) 'cached_tokens': cachedTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalSampleUsage &&
          runtimeType == other.runtimeType &&
          totalTokens == other.totalTokens;

  @override
  int get hashCode => totalTokens.hashCode;

  @override
  String toString() => 'EvalSampleUsage(total: $totalTokens)';
}

/// Status filter for listing output items.
enum EvalOutputItemStatus {
  /// Only items that passed.
  pass._('pass'),

  /// Only items that failed.
  fail._('fail');

  const EvalOutputItemStatus._(this._value);

  /// Creates from JSON string.
  factory EvalOutputItemStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown output item status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
