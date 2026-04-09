/// Type of judge output.
enum JudgeOutputType {
  /// Regression-based scoring output.
  regression('REGRESSION'),

  /// Classification-based output.
  classification('CLASSIFICATION'),

  /// Unknown type (forward-compatible fallback).
  unknown('UNKNOWN');

  const JudgeOutputType(this.value);

  /// The string value of this type.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [JudgeOutputType] from a JSON value.
  static JudgeOutputType fromJson(String? value) => fromString(value);

  /// Creates a [JudgeOutputType] from a string value.
  static JudgeOutputType fromString(String? value) {
    if (value == null) return JudgeOutputType.unknown;
    return JudgeOutputType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => JudgeOutputType.unknown,
    );
  }
}
