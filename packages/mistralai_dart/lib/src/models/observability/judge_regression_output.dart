import 'package:meta/meta.dart';

/// Regression judge output configuration.
@immutable
class JudgeRegressionOutput {
  /// Output type discriminator (always "REGRESSION").
  final String type;

  /// Minimum score value.
  final double min;

  /// Description of the minimum score.
  final String minDescription;

  /// Maximum score value.
  final double max;

  /// Description of the maximum score.
  final String maxDescription;

  /// Creates a [JudgeRegressionOutput].
  const JudgeRegressionOutput({
    this.type = 'REGRESSION',
    this.min = 0,
    required this.minDescription,
    this.max = 1,
    required this.maxDescription,
  });

  /// Creates a [JudgeRegressionOutput] from JSON.
  factory JudgeRegressionOutput.fromJson(Map<String, dynamic> json) =>
      JudgeRegressionOutput(
        type: json['type'] as String? ?? 'REGRESSION',
        min: (json['min'] as num?)?.toDouble() ?? 0,
        minDescription: json['min_description'] as String? ?? '',
        max: (json['max'] as num?)?.toDouble() ?? 1,
        maxDescription: json['max_description'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'min': min,
    'min_description': minDescription,
    'max': max,
    'max_description': maxDescription,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeRegressionOutput) return false;
    if (runtimeType != other.runtimeType) return false;
    return type == other.type &&
        min == other.min &&
        minDescription == other.minDescription &&
        max == other.max &&
        maxDescription == other.maxDescription;
  }

  @override
  int get hashCode =>
      Object.hash(type, min, minDescription, max, maxDescription);

  @override
  String toString() =>
      'JudgeRegressionOutput(type: $type, min: $min, '
      'minDescription: $minDescription, max: $max, '
      'maxDescription: $maxDescription)';
}
