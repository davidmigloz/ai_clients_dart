import 'package:meta/meta.dart';

/// An option for a classification judge output.
@immutable
class JudgeClassificationOutputOption {
  /// The option value.
  final String value;

  /// Description of this option.
  final String description;

  /// Creates a [JudgeClassificationOutputOption].
  const JudgeClassificationOutputOption({
    required this.value,
    required this.description,
  });

  /// Creates a [JudgeClassificationOutputOption] from JSON.
  factory JudgeClassificationOutputOption.fromJson(Map<String, dynamic> json) =>
      JudgeClassificationOutputOption(
        value: json['value'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'value': value, 'description': description};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeClassificationOutputOption) return false;
    if (runtimeType != other.runtimeType) return false;
    return value == other.value && description == other.description;
  }

  @override
  int get hashCode => Object.hash(value, description);

  @override
  String toString() =>
      'JudgeClassificationOutputOption(value: $value, '
      'description: $description)';
}
