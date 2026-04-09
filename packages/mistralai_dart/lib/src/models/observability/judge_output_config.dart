import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'judge_classification_output.dart';
import 'judge_classification_output_option.dart';
import 'judge_regression_output.dart';

/// Discriminated union for judge output configuration.
///
/// Use [JudgeOutputConfig.classification] or [JudgeOutputConfig.regression]
/// factory constructors to create instances.
@immutable
sealed class JudgeOutputConfig {
  const JudgeOutputConfig();

  /// Creates a classification output config.
  factory JudgeOutputConfig.classification({
    required List<JudgeClassificationOutputOption> options,
  }) = JudgeOutputConfigClassification;

  /// Creates a regression output config.
  factory JudgeOutputConfig.regression({
    double min,
    required String minDescription,
    double max,
    required String maxDescription,
  }) = JudgeOutputConfigRegression;

  /// Creates a [JudgeOutputConfig] from JSON using the `type` discriminator.
  factory JudgeOutputConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'CLASSIFICATION' => JudgeOutputConfigClassification._(
        JudgeClassificationOutput.fromJson(json),
      ),
      'REGRESSION' => JudgeOutputConfigRegression._(
        JudgeRegressionOutput.fromJson(json),
      ),
      _ => JudgeOutputConfigUnknown._(type ?? 'unknown', json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Classification variant of [JudgeOutputConfig].
@immutable
class JudgeOutputConfigClassification extends JudgeOutputConfig {
  /// The underlying classification output.
  final JudgeClassificationOutput value;

  /// Creates a [JudgeOutputConfigClassification].
  JudgeOutputConfigClassification({
    required List<JudgeClassificationOutputOption> options,
  }) : value = JudgeClassificationOutput(options: options);

  const JudgeOutputConfigClassification._(this.value);

  @override
  Map<String, dynamic> toJson() => value.toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeOutputConfigClassification) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'JudgeOutputConfig.classification(${value.options})';
}

/// Regression variant of [JudgeOutputConfig].
@immutable
class JudgeOutputConfigRegression extends JudgeOutputConfig {
  /// The underlying regression output.
  final JudgeRegressionOutput value;

  /// Creates a [JudgeOutputConfigRegression].
  JudgeOutputConfigRegression({
    double min = 0,
    required String minDescription,
    double max = 1,
    required String maxDescription,
  }) : value = JudgeRegressionOutput(
         min: min,
         minDescription: minDescription,
         max: max,
         maxDescription: maxDescription,
       );

  const JudgeOutputConfigRegression._(this.value);

  @override
  Map<String, dynamic> toJson() => value.toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeOutputConfigRegression) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'JudgeOutputConfig.regression(${value.min}-${value.max})';
}

/// Unknown variant of [JudgeOutputConfig] for forward compatibility.
///
/// Returned when the API sends a discriminator value not yet supported
/// by this client version. The raw JSON is preserved in [rawJson].
@immutable
class JudgeOutputConfigUnknown extends JudgeOutputConfig {
  /// The unknown type discriminator value.
  final String type;

  /// The raw JSON for this config.
  final Map<String, dynamic> rawJson;

  JudgeOutputConfigUnknown._(this.type, Map<String, dynamic> rawJson)
    : rawJson = Map.unmodifiable(rawJson);

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeOutputConfigUnknown) return false;
    return type == other.type && mapsDeepEqual(rawJson, other.rawJson);
  }

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(rawJson));

  @override
  String toString() => 'JudgeOutputConfig.unknown($type)';
}
