/// Type of workflow.
enum WorkflowType {
  /// A code-based workflow.
  code('code'),

  /// Unknown type (forward-compatibility fallback).
  unknown('unknown');

  const WorkflowType(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [WorkflowType] from a JSON string value.
  static WorkflowType fromJson(String? value) {
    if (value == null) return WorkflowType.unknown;
    return WorkflowType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkflowType.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
