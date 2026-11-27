import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// The CategoricalStatistics wire payload.
@immutable
final class CategoricalStatistics extends EvaluatorStatistics {
  /// Creates a [CategoricalStatistics].
  const CategoricalStatistics({
    this.confusionMatrix,
    required this.count,
    this.excludedCount,
    required this.frequencies,
    required this.mode,
    this.values,
  });

  /// The fixed type discriminator.
  String get type => 'categorical';

  /// The confusion_matrix field.
  final ConfusionMatrix? confusionMatrix;

  /// The count field.
  final int count;

  /// The excluded_count field.
  final int? excludedCount;

  /// The frequencies field.
  final Map<String, int> frequencies;

  /// The mode field.
  final List<String> mode;

  /// The values field.
  final List<ScalarStatisticValue>? values;

  /// Parses a [CategoricalStatistics] from JSON.
  factory CategoricalStatistics.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'categorical') {
      throw FormatException('CategoricalStatistics: unexpected type $value');
    }
    if (json['count'] == null) {
      throw const FormatException('CategoricalStatistics: missing count');
    }
    if (json['frequencies'] == null) {
      throw const FormatException('CategoricalStatistics: missing frequencies');
    }
    if (json['mode'] == null) {
      throw const FormatException('CategoricalStatistics: missing mode');
    }
    return CategoricalStatistics(
      confusionMatrix: json['confusion_matrix'] == null
          ? null
          : ConfusionMatrix.fromJson(
              json['confusion_matrix'] as Map<String, dynamic>,
            ),
      count: json['count'] as int,
      excludedCount: json['excluded_count'] == null
          ? null
          : json['excluded_count'] as int,
      frequencies: (json['frequencies'] as Map<String, Object?>).map(
        (key, item) => MapEntry(key, item! as int),
      ),
      mode: (json['mode'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      values: json['values'] == null
          ? null
          : (json['values'] as List<Object?>)
                .map(
                  (item) => ScalarStatisticValue.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (confusionMatrix != null) 'confusion_matrix': confusionMatrix!.toJson(),
    'count': count,
    'excluded_count': ?excludedCount,
    'frequencies': frequencies,
    'mode': mode,
    if (values != null) 'values': values!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  CategoricalStatistics copyWith({
    Object? confusionMatrix = unsetCopyWithValue,
    int? count,
    Object? excludedCount = unsetCopyWithValue,
    Map<String, int>? frequencies,
    List<String>? mode,
    Object? values = unsetCopyWithValue,
  }) => CategoricalStatistics(
    confusionMatrix: confusionMatrix == unsetCopyWithValue
        ? this.confusionMatrix
        : confusionMatrix as ConfusionMatrix?,
    count: count ?? this.count,
    excludedCount: excludedCount == unsetCopyWithValue
        ? this.excludedCount
        : excludedCount as int?,
    frequencies: frequencies ?? this.frequencies,
    mode: mode ?? this.mode,
    values: values == unsetCopyWithValue
        ? this.values
        : (values as List<Object?>?)?.cast<ScalarStatisticValue>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoricalStatistics &&
          runtimeType == other.runtimeType &&
          confusionMatrix == other.confusionMatrix &&
          count == other.count &&
          excludedCount == other.excludedCount &&
          valuesDeepEqual(frequencies, other.frequencies) &&
          valuesDeepEqual(mode, other.mode) &&
          valuesDeepEqual(values, other.values);

  @override
  int get hashCode => Object.hashAll([
    confusionMatrix,
    count,
    excludedCount,
    valueDeepHashCode(frequencies),
    valueDeepHashCode(mode),
    valueDeepHashCode(values),
  ]);

  @override
  String toString() =>
      'CategoricalStatistics('
      'confusionMatrix: $confusionMatrix, '
      'count: $count, '
      'excludedCount: $excludedCount, '
      'frequencies: ${frequencies.length}, '
      'mode: ${mode.length}, '
      'values: ${values?.length})';
}

/// A classification metric (``precision``/``recall``/``f1``) over ``(expected, predicted)`` pairs. The predicted label is the score ``value``; the expected label is read from the score ``metadata`` under ``expected_key`` (default ``"expected"``). Provide **exactly one** of ``positive_label`` (a binary metric scored against that one class) or ``average`` (a multi-class averaging scheme). ``labels`` pins the class universe so filtered views keep a stable, comparable denominator.
@immutable
final class ClassificationStatisticSpec extends EvaluatorStatisticSpec {
  /// Creates a [ClassificationStatisticSpec].
  const ClassificationStatisticSpec({
    this.average,
    this.expectedKey,
    this.goal,
    required this.kind,
    this.labels,
    this.positiveLabel,
  });

  /// The average field.
  final String? average;

  /// The expected_key field.
  final String? expectedKey;

  /// The goal field.
  final GoalSpec? goal;

  /// The kind field.
  final String kind;

  /// The labels field.
  final List<String>? labels;

  /// The positive_label field.
  final String? positiveLabel;

  /// Parses a [ClassificationStatisticSpec] from JSON.
  factory ClassificationStatisticSpec.fromJson(Map<String, dynamic> json) {
    if (json['kind'] == null) {
      throw const FormatException('ClassificationStatisticSpec: missing kind');
    }
    return ClassificationStatisticSpec(
      average: json['average'] == null ? null : json['average'] as String,
      expectedKey: json['expected_key'] == null
          ? null
          : json['expected_key'] as String,
      goal: json['goal'] == null
          ? null
          : GoalSpec.fromJson(json['goal'] as Map<String, dynamic>),
      kind: json['kind'] as String,
      labels: json['labels'] == null
          ? null
          : (json['labels'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      positiveLabel: json['positive_label'] == null
          ? null
          : json['positive_label'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'average': ?average,
    'expected_key': ?expectedKey,
    if (goal != null) 'goal': goal!.toJson(),
    'kind': kind,
    'labels': ?labels,
    'positive_label': ?positiveLabel,
  };

  /// Creates a copy with the given fields replaced.
  ClassificationStatisticSpec copyWith({
    Object? average = unsetCopyWithValue,
    Object? expectedKey = unsetCopyWithValue,
    Object? goal = unsetCopyWithValue,
    String? kind,
    Object? labels = unsetCopyWithValue,
    Object? positiveLabel = unsetCopyWithValue,
  }) => ClassificationStatisticSpec(
    average: average == unsetCopyWithValue ? this.average : average as String?,
    expectedKey: expectedKey == unsetCopyWithValue
        ? this.expectedKey
        : expectedKey as String?,
    goal: goal == unsetCopyWithValue ? this.goal : goal as GoalSpec?,
    kind: kind ?? this.kind,
    labels: labels == unsetCopyWithValue
        ? this.labels
        : (labels as List<Object?>?)?.cast<String>(),
    positiveLabel: positiveLabel == unsetCopyWithValue
        ? this.positiveLabel
        : positiveLabel as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationStatisticSpec &&
          runtimeType == other.runtimeType &&
          average == other.average &&
          expectedKey == other.expectedKey &&
          goal == other.goal &&
          kind == other.kind &&
          valuesDeepEqual(labels, other.labels) &&
          positiveLabel == other.positiveLabel;

  @override
  int get hashCode => Object.hashAll([
    average,
    expectedKey,
    goal,
    kind,
    valueDeepHashCode(labels),
    positiveLabel,
  ]);

  @override
  String toString() =>
      'ClassificationStatisticSpec('
      'average: $average, '
      'expectedKey: $expectedKey, '
      'goal: $goal, '
      'kind: $kind, '
      'labels: ${labels?.length}, '
      'positiveLabel: $positiveLabel)';
}

/// A confusion matrix over ``(expected, predicted)`` label pairs. ``matrix[i][j]`` is the number of samples whose expected label is ``labels[i]`` and predicted label is ``labels[j]``. It is the complete, aggregatable representation: precision/recall/f1 for any class derive from it, and matrices from several runs merge by element-wise sum.
@immutable
class ConfusionMatrix {
  /// Creates a [ConfusionMatrix].
  const ConfusionMatrix({required this.labels, required this.matrix});

  /// The labels field.
  final List<String> labels;

  /// The matrix field.
  final List<List<int>> matrix;

  /// Parses a [ConfusionMatrix] from JSON.
  factory ConfusionMatrix.fromJson(Map<String, dynamic> json) {
    if (json['labels'] == null) {
      throw const FormatException('ConfusionMatrix: missing labels');
    }
    if (json['matrix'] == null) {
      throw const FormatException('ConfusionMatrix: missing matrix');
    }
    return ConfusionMatrix(
      labels: (json['labels'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      matrix: (json['matrix'] as List<Object?>)
          .map(
            (item) =>
                (item! as List<Object?>).map((item) => item! as int).toList(),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'labels': labels, 'matrix': matrix};

  /// Creates a copy with the given fields replaced.
  ConfusionMatrix copyWith({List<String>? labels, List<List<int>>? matrix}) =>
      ConfusionMatrix(
        labels: labels ?? this.labels,
        matrix: matrix ?? this.matrix,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfusionMatrix &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(labels, other.labels) &&
          valuesDeepEqual(matrix, other.matrix);

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(labels), valueDeepHashCode(matrix)]);

  @override
  String toString() =>
      'ConfusionMatrix('
      'labels: ${labels.length}, '
      'matrix: ${matrix.length})';
}

/// Values for DisplayFormat.
enum DisplayFormat {
  /// Represents number.
  number('number'),

  /// Represents percent.
  percent('percent'),

  /// Represents integer.
  integer('integer'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const DisplayFormat(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static DisplayFormat fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// How the UI renders an evaluator's numeric values (scores, score-scale statistics, goal thresholds). Display only: stored values and computed statistics never change. ``percent`` reads the value as a fraction (0.63 renders as 63%), ``integer`` rounds it, ``number`` renders ``decimals`` decimals. ``unit`` is a free suffix ("s", "ms", "chars"), not allowed with ``percent`` (its ``%`` is the unit). All fields unset = the default rendering. ``metric`` (run evaluators only) names the run evaluator metric this format applies to. Without it, the spec formats the main value and is the default format of every metric.
@immutable
class DisplaySpec {
  /// Creates a [DisplaySpec].
  const DisplaySpec({this.decimals, this.format, this.metric, this.unit});

  /// The decimals field.
  final int? decimals;

  /// The format field.
  final DisplayFormat? format;

  /// The metric field.
  final String? metric;

  /// The unit field.
  final String? unit;

  /// Parses a [DisplaySpec] from JSON.
  factory DisplaySpec.fromJson(Map<String, dynamic> json) {
    return DisplaySpec(
      decimals: json['decimals'] == null ? null : json['decimals'] as int,
      format: json['format'] == null
          ? null
          : DisplayFormat.fromJson(json['format'] as String),
      metric: json['metric'] == null ? null : json['metric'] as String,
      unit: json['unit'] == null ? null : json['unit'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'decimals': ?decimals,
    if (format != null) 'format': format!.toJson(),
    'metric': ?metric,
    'unit': ?unit,
  };

  /// Creates a copy with the given fields replaced.
  DisplaySpec copyWith({
    Object? decimals = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
    Object? metric = unsetCopyWithValue,
    Object? unit = unsetCopyWithValue,
  }) => DisplaySpec(
    decimals: decimals == unsetCopyWithValue ? this.decimals : decimals as int?,
    format: format == unsetCopyWithValue
        ? this.format
        : format as DisplayFormat?,
    metric: metric == unsetCopyWithValue ? this.metric : metric as String?,
    unit: unit == unsetCopyWithValue ? this.unit : unit as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplaySpec &&
          runtimeType == other.runtimeType &&
          decimals == other.decimals &&
          format == other.format &&
          metric == other.metric &&
          unit == other.unit;

  @override
  int get hashCode => Object.hashAll([decimals, format, metric, unit]);

  @override
  String toString() =>
      'DisplaySpec('
      'decimals: $decimals, '
      'format: $format, '
      'metric: $metric, '
      'unit: $unit)';
}

/// A variant of [EvaluatorStatistics] returned or accepted by Observability.
sealed class EvaluatorStatistics {
  const EvaluatorStatistics();

  /// Decodes a variant from its API representation.
  factory EvaluatorStatistics.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'numeric' => NumericStatistics.fromJson(json),
        'categorical' => CategoricalStatistics.fromJson(json),
        'unsupported' => UnsupportedStatistics.fromJson(json),
        _ => UnknownEvaluatorStatistics(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [EvaluatorStatistics] unknown to this client.
@immutable
final class UnknownEvaluatorStatistics extends EvaluatorStatistics {
  /// Retains the original payload.
  UnknownEvaluatorStatistics(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownEvaluatorStatistics && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The GoalResult wire payload.
@immutable
class GoalResult {
  /// Creates a [GoalResult].
  const GoalResult({this.missing, required this.passed, required this.results});

  /// The missing field.
  final List<MissingGoalItem>? missing;

  /// The passed field.
  final bool? passed;

  /// The results field.
  final List<GoalResultItem> results;

  /// Parses a [GoalResult] from JSON.
  factory GoalResult.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('passed')) {
      throw const FormatException('GoalResult: missing passed');
    }
    if (json['results'] == null) {
      throw const FormatException('GoalResult: missing results');
    }
    return GoalResult(
      missing: json['missing'] == null
          ? null
          : (json['missing'] as List<Object?>)
                .map(
                  (item) =>
                      MissingGoalItem.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
      passed: json['passed'] == null ? null : json['passed'] as bool,
      results: (json['results'] as List<Object?>)
          .map((item) => GoalResultItem.fromJson(item! as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (missing != null)
      'missing': missing!.map((item) => item.toJson()).toList(),
    'passed': passed,
    'results': results.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  GoalResult copyWith({
    Object? missing = unsetCopyWithValue,
    Object? passed = unsetCopyWithValue,
    List<GoalResultItem>? results,
  }) => GoalResult(
    missing: missing == unsetCopyWithValue
        ? this.missing
        : (missing as List<Object?>?)?.cast<MissingGoalItem>(),
    passed: passed == unsetCopyWithValue ? this.passed : passed as bool?,
    results: results ?? this.results,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalResult &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(missing, other.missing) &&
          passed == other.passed &&
          valuesDeepEqual(results, other.results);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(missing),
    passed,
    valueDeepHashCode(results),
  ]);

  @override
  String toString() =>
      'GoalResult('
      'missing: ${missing?.length}, '
      'passed: $passed, '
      'results: ${results.length})';
}

/// The GoalResultItem wire payload.
@immutable
class GoalResultItem {
  /// Creates a [GoalResultItem].
  const GoalResultItem({
    required this.actual,
    this.direction,
    required this.metric,
    required this.operator,
    required this.passed,
    this.target,
    this.targetMax,
    this.targetMin,
  });

  /// The actual field.
  final double actual;

  /// The direction field.
  final String? direction;

  /// The metric field.
  final String metric;

  /// The operator field.
  final String operator;

  /// The passed field.
  final bool passed;

  /// The target field.
  final double? target;

  /// The target_max field.
  final double? targetMax;

  /// The target_min field.
  final double? targetMin;

  /// Parses a [GoalResultItem] from JSON.
  factory GoalResultItem.fromJson(Map<String, dynamic> json) {
    if (json['actual'] == null) {
      throw const FormatException('GoalResultItem: missing actual');
    }
    if (json['metric'] == null) {
      throw const FormatException('GoalResultItem: missing metric');
    }
    if (json['operator'] == null) {
      throw const FormatException('GoalResultItem: missing operator');
    }
    if (json['passed'] == null) {
      throw const FormatException('GoalResultItem: missing passed');
    }
    return GoalResultItem(
      actual: (json['actual'] as num).toDouble(),
      direction: json['direction'] == null ? null : json['direction'] as String,
      metric: json['metric'] as String,
      operator: json['operator'] as String,
      passed: json['passed'] as bool,
      target: json['target'] == null
          ? null
          : (json['target'] as num).toDouble(),
      targetMax: json['target_max'] == null
          ? null
          : (json['target_max'] as num).toDouble(),
      targetMin: json['target_min'] == null
          ? null
          : (json['target_min'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'actual': actual,
    'direction': ?direction,
    'metric': metric,
    'operator': operator,
    'passed': passed,
    'target': ?target,
    'target_max': ?targetMax,
    'target_min': ?targetMin,
  };

  /// Creates a copy with the given fields replaced.
  GoalResultItem copyWith({
    double? actual,
    Object? direction = unsetCopyWithValue,
    String? metric,
    String? operator,
    bool? passed,
    Object? target = unsetCopyWithValue,
    Object? targetMax = unsetCopyWithValue,
    Object? targetMin = unsetCopyWithValue,
  }) => GoalResultItem(
    actual: actual ?? this.actual,
    direction: direction == unsetCopyWithValue
        ? this.direction
        : direction as String?,
    metric: metric ?? this.metric,
    operator: operator ?? this.operator,
    passed: passed ?? this.passed,
    target: target == unsetCopyWithValue
        ? this.target
        : (target as num?)?.toDouble(),
    targetMax: targetMax == unsetCopyWithValue
        ? this.targetMax
        : (targetMax as num?)?.toDouble(),
    targetMin: targetMin == unsetCopyWithValue
        ? this.targetMin
        : (targetMin as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalResultItem &&
          runtimeType == other.runtimeType &&
          actual == other.actual &&
          direction == other.direction &&
          metric == other.metric &&
          operator == other.operator &&
          passed == other.passed &&
          target == other.target &&
          targetMax == other.targetMax &&
          targetMin == other.targetMin;

  @override
  int get hashCode => Object.hashAll([
    actual,
    direction,
    metric,
    operator,
    passed,
    target,
    targetMax,
    targetMin,
  ]);

  @override
  String toString() =>
      'GoalResultItem('
      'actual: $actual, '
      'direction: $direction, '
      'metric: $metric, '
      'operator: $operator, '
      'passed: $passed, '
      'target: $target, '
      'targetMax: $targetMax, '
      'targetMin: $targetMin)';
}

/// The GoalSpec wire payload.
@immutable
class GoalSpec {
  /// Creates a [GoalSpec].
  const GoalSpec({
    this.max,
    this.metric,
    this.min,
    this.operator,
    this.value,
    this.values,
  });

  /// The max field.
  final double? max;

  /// The metric field.
  final String? metric;

  /// The min field.
  final double? min;

  /// The operator field.
  final String? operator;

  /// The value field.
  final Object? value;

  /// The values field.
  final List<Object?>? values;

  /// Parses a [GoalSpec] from JSON.
  factory GoalSpec.fromJson(Map<String, dynamic> json) {
    return GoalSpec(
      max: json['max'] == null ? null : (json['max'] as num).toDouble(),
      metric: json['metric'] == null ? null : json['metric'] as String,
      min: json['min'] == null ? null : (json['min'] as num).toDouble(),
      operator: json['operator'] == null ? null : json['operator'] as String,
      value: json['value'],
      values: json['values'] == null
          ? null
          : (json['values'] as List<Object?>).map((item) => item).toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'max': ?max,
    'metric': ?metric,
    'min': ?min,
    'operator': ?operator,
    'value': ?value,
    'values': ?values,
  };

  /// Creates a copy with the given fields replaced.
  GoalSpec copyWith({
    Object? max = unsetCopyWithValue,
    Object? metric = unsetCopyWithValue,
    Object? min = unsetCopyWithValue,
    Object? operator = unsetCopyWithValue,
    Object? value = unsetCopyWithValue,
    Object? values = unsetCopyWithValue,
  }) => GoalSpec(
    max: max == unsetCopyWithValue ? this.max : (max as num?)?.toDouble(),
    metric: metric == unsetCopyWithValue ? this.metric : metric as String?,
    min: min == unsetCopyWithValue ? this.min : (min as num?)?.toDouble(),
    operator: operator == unsetCopyWithValue
        ? this.operator
        : operator as String?,
    value: value == unsetCopyWithValue ? this.value : value,
    values: values == unsetCopyWithValue
        ? this.values
        : (values as List<Object?>?)?.cast<Object>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalSpec &&
          runtimeType == other.runtimeType &&
          max == other.max &&
          metric == other.metric &&
          min == other.min &&
          operator == other.operator &&
          value == other.value &&
          valuesDeepEqual(values, other.values);

  @override
  int get hashCode => Object.hashAll([
    max,
    metric,
    min,
    operator,
    value,
    valueDeepHashCode(values),
  ]);

  @override
  String toString() =>
      'GoalSpec('
      'max: $max, '
      'metric: $metric, '
      'min: $min, '
      'operator: $operator, '
      'value: $value, '
      'values: ${values?.length})';
}

/// Which way a run evaluator metric improves. The main value's direction stays the evaluator's ``direction``.
@immutable
class MetricDirectionSpec {
  /// Creates a [MetricDirectionSpec].
  const MetricDirectionSpec({required this.direction, required this.metric});

  /// The direction field.
  final String direction;

  /// The metric field.
  final String metric;

  /// Parses a [MetricDirectionSpec] from JSON.
  factory MetricDirectionSpec.fromJson(Map<String, dynamic> json) {
    if (json['direction'] == null) {
      throw const FormatException('MetricDirectionSpec: missing direction');
    }
    if (json['metric'] == null) {
      throw const FormatException('MetricDirectionSpec: missing metric');
    }
    return MetricDirectionSpec(
      direction: json['direction'] as String,
      metric: json['metric'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'direction': direction, 'metric': metric};

  /// Creates a copy with the given fields replaced.
  MetricDirectionSpec copyWith({String? direction, String? metric}) =>
      MetricDirectionSpec(
        direction: direction ?? this.direction,
        metric: metric ?? this.metric,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricDirectionSpec &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          metric == other.metric;

  @override
  int get hashCode => Object.hashAll([direction, metric]);

  @override
  String toString() =>
      'MetricDirectionSpec('
      'direction: $direction, '
      'metric: $metric)';
}

/// A run evaluator goal on a metric the scorer did not return: it fails, with no number to show. Kept out of ``results`` so ``GoalResultItem.actual`` stays a number for clients that require one.
@immutable
class MissingGoalItem {
  /// Creates a [MissingGoalItem].
  const MissingGoalItem({
    required this.message,
    required this.metric,
    required this.operator,
    this.target,
    this.targetMax,
    this.targetMin,
  });

  /// The message field.
  final String message;

  /// The metric field.
  final String metric;

  /// The operator field.
  final String operator;

  /// The target field.
  final double? target;

  /// The target_max field.
  final double? targetMax;

  /// The target_min field.
  final double? targetMin;

  /// Parses a [MissingGoalItem] from JSON.
  factory MissingGoalItem.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw const FormatException('MissingGoalItem: missing message');
    }
    if (json['metric'] == null) {
      throw const FormatException('MissingGoalItem: missing metric');
    }
    if (json['operator'] == null) {
      throw const FormatException('MissingGoalItem: missing operator');
    }
    return MissingGoalItem(
      message: json['message'] as String,
      metric: json['metric'] as String,
      operator: json['operator'] as String,
      target: json['target'] == null
          ? null
          : (json['target'] as num).toDouble(),
      targetMax: json['target_max'] == null
          ? null
          : (json['target_max'] as num).toDouble(),
      targetMin: json['target_min'] == null
          ? null
          : (json['target_min'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'message': message,
    'metric': metric,
    'operator': operator,
    'target': ?target,
    'target_max': ?targetMax,
    'target_min': ?targetMin,
  };

  /// Creates a copy with the given fields replaced.
  MissingGoalItem copyWith({
    String? message,
    String? metric,
    String? operator,
    Object? target = unsetCopyWithValue,
    Object? targetMax = unsetCopyWithValue,
    Object? targetMin = unsetCopyWithValue,
  }) => MissingGoalItem(
    message: message ?? this.message,
    metric: metric ?? this.metric,
    operator: operator ?? this.operator,
    target: target == unsetCopyWithValue
        ? this.target
        : (target as num?)?.toDouble(),
    targetMax: targetMax == unsetCopyWithValue
        ? this.targetMax
        : (targetMax as num?)?.toDouble(),
    targetMin: targetMin == unsetCopyWithValue
        ? this.targetMin
        : (targetMin as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissingGoalItem &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          metric == other.metric &&
          operator == other.operator &&
          target == other.target &&
          targetMax == other.targetMax &&
          targetMin == other.targetMin;

  @override
  int get hashCode =>
      Object.hashAll([message, metric, operator, target, targetMax, targetMin]);

  @override
  String toString() =>
      'MissingGoalItem('
      'message: $message, '
      'metric: $metric, '
      'operator: $operator, '
      'target: $target, '
      'targetMax: $targetMax, '
      'targetMin: $targetMin)';
}

/// Values for NumericScoreMetric.
enum NumericScoreMetric {
  /// Represents avg.
  avg('avg'),

  /// Represents min.
  min('min'),

  /// Represents max.
  max('max'),

  /// Represents std.
  std('std'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const NumericScoreMetric(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static NumericScoreMetric fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The NumericStatistics wire payload.
@immutable
final class NumericStatistics extends EvaluatorStatistics {
  /// Creates a [NumericStatistics].
  const NumericStatistics({
    this.avg,
    this.count,
    this.max,
    this.min,
    this.sampleCount,
    this.std,
    this.values,
  });

  /// The fixed type discriminator.
  String get type => 'numeric';

  /// The avg field.
  final double? avg;

  /// The count field.
  final int? count;

  /// The max field.
  final double? max;

  /// The min field.
  final double? min;

  /// The sample_count field.
  final int? sampleCount;

  /// The std field.
  final double? std;

  /// The values field.
  final List<ScalarStatisticValue>? values;

  /// Parses a [NumericStatistics] from JSON.
  factory NumericStatistics.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'numeric') {
      throw FormatException('NumericStatistics: unexpected type $value');
    }
    return NumericStatistics(
      avg: json['avg'] == null ? null : (json['avg'] as num).toDouble(),
      count: json['count'] == null ? null : json['count'] as int,
      max: json['max'] == null ? null : (json['max'] as num).toDouble(),
      min: json['min'] == null ? null : (json['min'] as num).toDouble(),
      sampleCount: json['sample_count'] == null
          ? null
          : json['sample_count'] as int,
      std: json['std'] == null ? null : (json['std'] as num).toDouble(),
      values: json['values'] == null
          ? null
          : (json['values'] as List<Object?>)
                .map(
                  (item) => ScalarStatisticValue.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'avg': ?avg,
    'count': ?count,
    'max': ?max,
    'min': ?min,
    'sample_count': ?sampleCount,
    'std': ?std,
    if (values != null) 'values': values!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  NumericStatistics copyWith({
    Object? avg = unsetCopyWithValue,
    Object? count = unsetCopyWithValue,
    Object? max = unsetCopyWithValue,
    Object? min = unsetCopyWithValue,
    Object? sampleCount = unsetCopyWithValue,
    Object? std = unsetCopyWithValue,
    Object? values = unsetCopyWithValue,
  }) => NumericStatistics(
    avg: avg == unsetCopyWithValue ? this.avg : (avg as num?)?.toDouble(),
    count: count == unsetCopyWithValue ? this.count : count as int?,
    max: max == unsetCopyWithValue ? this.max : (max as num?)?.toDouble(),
    min: min == unsetCopyWithValue ? this.min : (min as num?)?.toDouble(),
    sampleCount: sampleCount == unsetCopyWithValue
        ? this.sampleCount
        : sampleCount as int?,
    std: std == unsetCopyWithValue ? this.std : (std as num?)?.toDouble(),
    values: values == unsetCopyWithValue
        ? this.values
        : (values as List<Object?>?)?.cast<ScalarStatisticValue>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumericStatistics &&
          runtimeType == other.runtimeType &&
          avg == other.avg &&
          count == other.count &&
          max == other.max &&
          min == other.min &&
          sampleCount == other.sampleCount &&
          std == other.std &&
          valuesDeepEqual(values, other.values);

  @override
  int get hashCode => Object.hashAll([
    avg,
    count,
    max,
    min,
    sampleCount,
    std,
    valueDeepHashCode(values),
  ]);

  @override
  String toString() =>
      'NumericStatistics('
      'avg: $avg, '
      'count: $count, '
      'max: $max, '
      'min: $min, '
      'sampleCount: $sampleCount, '
      'std: $std, '
      'values: ${values?.length})';
}

/// The ``p``-th percentile (``0 &lt;= p &lt;= 100``), computed with the type-7 algorithm.
@immutable
final class PercentileStatisticSpec extends EvaluatorStatisticSpec {
  /// Creates a [PercentileStatisticSpec].
  const PercentileStatisticSpec({this.goal, required this.percentile});

  /// The fixed kind discriminator.
  String get kind => 'percentile';

  /// The goal field.
  final GoalSpec? goal;

  /// The percentile field.
  final num percentile;

  /// Parses a [PercentileStatisticSpec] from JSON.
  factory PercentileStatisticSpec.fromJson(Map<String, dynamic> json) {
    if (json['kind'] case final value? when value != 'percentile') {
      throw FormatException('PercentileStatisticSpec: unexpected kind $value');
    }
    if (json['percentile'] == null) {
      throw const FormatException(
        'PercentileStatisticSpec: missing percentile',
      );
    }
    return PercentileStatisticSpec(
      goal: json['goal'] == null
          ? null
          : GoalSpec.fromJson(json['goal'] as Map<String, dynamic>),
      percentile: json['percentile'] as num,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'kind': kind,
    if (goal != null) 'goal': goal!.toJson(),
    'percentile': percentile,
  };

  /// Creates a copy with the given fields replaced.
  PercentileStatisticSpec copyWith({
    Object? goal = unsetCopyWithValue,
    num? percentile,
  }) => PercentileStatisticSpec(
    goal: goal == unsetCopyWithValue ? this.goal : goal as GoalSpec?,
    percentile: percentile ?? this.percentile,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PercentileStatisticSpec &&
          runtimeType == other.runtimeType &&
          goal == other.goal &&
          percentile == other.percentile;

  @override
  int get hashCode => Object.hashAll([goal, percentile]);

  @override
  String toString() =>
      'PercentileStatisticSpec('
      'goal: $goal, '
      'percentile: $percentile)';
}

/// The RunStatisticsResponse wire payload.
@immutable
class RunStatisticsResponse {
  /// Creates a [RunStatisticsResponse].
  const RunStatisticsResponse({
    this.goalResults,
    this.passed,
    required this.runId,
    required this.statistics,
  });

  /// The goal_results field.
  final Map<String, GoalResult>? goalResults;

  /// The passed field.
  final bool? passed;

  /// The run_id field.
  final String runId;

  /// The statistics field.
  final Map<String, EvaluatorStatistics> statistics;

  /// Parses a [RunStatisticsResponse] from JSON.
  factory RunStatisticsResponse.fromJson(Map<String, dynamic> json) {
    if (json['run_id'] == null) {
      throw const FormatException('RunStatisticsResponse: missing run_id');
    }
    if (json['statistics'] == null) {
      throw const FormatException('RunStatisticsResponse: missing statistics');
    }
    return RunStatisticsResponse(
      goalResults: json['goal_results'] == null
          ? null
          : (json['goal_results'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                GoalResult.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      passed: json['passed'] == null ? null : json['passed'] as bool,
      runId: json['run_id'] as String,
      statistics: (json['statistics'] as Map<String, Object?>).map(
        (key, item) => MapEntry(
          key,
          EvaluatorStatistics.fromJson(item! as Map<String, dynamic>),
        ),
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (goalResults != null)
      'goal_results': goalResults!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'passed': ?passed,
    'run_id': runId,
    'statistics': statistics.map((key, item) => MapEntry(key, item.toJson())),
  };

  /// Creates a copy with the given fields replaced.
  RunStatisticsResponse copyWith({
    Object? goalResults = unsetCopyWithValue,
    Object? passed = unsetCopyWithValue,
    String? runId,
    Map<String, EvaluatorStatistics>? statistics,
  }) => RunStatisticsResponse(
    goalResults: goalResults == unsetCopyWithValue
        ? this.goalResults
        : (goalResults as Map?)?.cast<String, GoalResult>(),
    passed: passed == unsetCopyWithValue ? this.passed : passed as bool?,
    runId: runId ?? this.runId,
    statistics: statistics ?? this.statistics,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunStatisticsResponse &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(goalResults, other.goalResults) &&
          passed == other.passed &&
          runId == other.runId &&
          valuesDeepEqual(statistics, other.statistics);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(goalResults),
    passed,
    runId,
    valueDeepHashCode(statistics),
  ]);

  @override
  String toString() =>
      'RunStatisticsResponse('
      'goalResults: ${goalResults?.length}, '
      'passed: $passed, '
      'runId: $runId, '
      'statistics: ${statistics.length})';
}

/// A single scalar computed run-level statistic: its canonical id and numeric value. ``value`` is ``None`` when the statistic is not evaluable (e.g. a ``sum`` or percentile over an empty numeric sample). A declared ``count`` is always evaluable and is ``0`` on an empty sample. The ``type`` discriminator lets future result shapes (e.g. a categorical ``categories`` or a ``distribution``) join a union without overloading this model; consumers dispatch on ``type``.
@immutable
class ScalarStatisticValue {
  /// Creates a [ScalarStatisticValue].
  const ScalarStatisticValue({required this.id, this.sampleCount, this.value});

  /// The fixed type discriminator.
  String get type => 'scalar';

  /// The id field.
  final String id;

  /// The sample_count field.
  final int? sampleCount;

  /// The value field.
  final double? value;

  /// Parses a [ScalarStatisticValue] from JSON.
  factory ScalarStatisticValue.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'scalar') {
      throw FormatException('ScalarStatisticValue: unexpected type $value');
    }
    if (json['id'] == null) {
      throw const FormatException('ScalarStatisticValue: missing id');
    }
    return ScalarStatisticValue(
      id: json['id'] as String,
      sampleCount: json['sample_count'] == null
          ? null
          : json['sample_count'] as int,
      value: json['value'] == null ? null : (json['value'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'sample_count': ?sampleCount,
    'value': ?value,
  };

  /// Creates a copy with the given fields replaced.
  ScalarStatisticValue copyWith({
    String? id,
    Object? sampleCount = unsetCopyWithValue,
    Object? value = unsetCopyWithValue,
  }) => ScalarStatisticValue(
    id: id ?? this.id,
    sampleCount: sampleCount == unsetCopyWithValue
        ? this.sampleCount
        : sampleCount as int?,
    value: value == unsetCopyWithValue
        ? this.value
        : (value as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScalarStatisticValue &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sampleCount == other.sampleCount &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([id, sampleCount, value]);

  @override
  String toString() =>
      'ScalarStatisticValue('
      'id: $id, '
      'sampleCount: $sampleCount, '
      'value: $value)';
}

/// A scalar numeric reduction (``avg``/``sum``/``min``/``max``/``std``/``count``). ``weight_key`` (``avg`` only) turns the mean into a weighted mean, ``sum(w * x) / sum(w)``, where each score's weight ``w`` is read from its ``metadata`` under that key. Scores whose weight is missing, non-numeric or negative are left out of that statistic.
@immutable
final class SimpleNumericStatisticSpec extends EvaluatorStatisticSpec {
  /// Creates a [SimpleNumericStatisticSpec].
  const SimpleNumericStatisticSpec({
    this.goal,
    required this.kind,
    this.weightKey,
  });

  /// The goal field.
  final GoalSpec? goal;

  /// The kind field.
  final String kind;

  /// The weight_key field.
  final String? weightKey;

  /// Parses a [SimpleNumericStatisticSpec] from JSON.
  factory SimpleNumericStatisticSpec.fromJson(Map<String, dynamic> json) {
    if (json['kind'] == null) {
      throw const FormatException('SimpleNumericStatisticSpec: missing kind');
    }
    return SimpleNumericStatisticSpec(
      goal: json['goal'] == null
          ? null
          : GoalSpec.fromJson(json['goal'] as Map<String, dynamic>),
      kind: json['kind'] as String,
      weightKey: json['weight_key'] == null
          ? null
          : json['weight_key'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (goal != null) 'goal': goal!.toJson(),
    'kind': kind,
    'weight_key': ?weightKey,
  };

  /// Creates a copy with the given fields replaced.
  SimpleNumericStatisticSpec copyWith({
    Object? goal = unsetCopyWithValue,
    String? kind,
    Object? weightKey = unsetCopyWithValue,
  }) => SimpleNumericStatisticSpec(
    goal: goal == unsetCopyWithValue ? this.goal : goal as GoalSpec?,
    kind: kind ?? this.kind,
    weightKey: weightKey == unsetCopyWithValue
        ? this.weightKey
        : weightKey as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleNumericStatisticSpec &&
          runtimeType == other.runtimeType &&
          goal == other.goal &&
          kind == other.kind &&
          weightKey == other.weightKey;

  @override
  int get hashCode => Object.hashAll([goal, kind, weightKey]);

  @override
  String toString() =>
      'SimpleNumericStatisticSpec('
      'goal: $goal, '
      'kind: $kind, '
      'weightKey: $weightKey)';
}

/// The UnsupportedStatistics wire payload.
@immutable
final class UnsupportedStatistics extends EvaluatorStatistics {
  /// Creates a [UnsupportedStatistics].
  const UnsupportedStatistics({required this.count});

  /// The fixed type discriminator.
  String get type => 'unsupported';

  /// The count field.
  final int count;

  /// Parses a [UnsupportedStatistics] from JSON.
  factory UnsupportedStatistics.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'unsupported') {
      throw FormatException('UnsupportedStatistics: unexpected type $value');
    }
    if (json['count'] == null) {
      throw const FormatException('UnsupportedStatistics: missing count');
    }
    return UnsupportedStatistics(count: json['count'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'count': count};

  /// Creates a copy with the given fields replaced.
  UnsupportedStatistics copyWith({int? count}) =>
      UnsupportedStatistics(count: count ?? this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnsupportedStatistics &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => Object.hashAll([count]);

  @override
  String toString() =>
      'UnsupportedStatistics('
      'count: $count)';
}

/// A variant of [EvaluatorStatisticSpec] returned or accepted by Observability.
sealed class EvaluatorStatisticSpec {
  const EvaluatorStatisticSpec();

  /// Decodes a variant from its API representation.
  factory EvaluatorStatisticSpec.fromJson(Map<String, dynamic> json) =>
      switch (json['kind']) {
        'avg' ||
        'sum' ||
        'min' ||
        'max' ||
        'std' ||
        'count' => SimpleNumericStatisticSpec.fromJson(json),
        'percentile' => PercentileStatisticSpec.fromJson(json),
        'precision' ||
        'recall' ||
        'f1' => ClassificationStatisticSpec.fromJson(json),
        _ => UnknownEvaluatorStatisticSpec(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [EvaluatorStatisticSpec] unknown to this client.
@immutable
final class UnknownEvaluatorStatisticSpec extends EvaluatorStatisticSpec {
  /// Retains the original payload.
  UnknownEvaluatorStatisticSpec(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownEvaluatorStatisticSpec && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}
