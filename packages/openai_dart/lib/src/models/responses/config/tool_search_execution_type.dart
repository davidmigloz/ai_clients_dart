/// The execution type for tool search.
enum ToolSearchExecutionType {
  /// Unknown type (fallback for unrecognized values).
  unknown('unknown'),

  /// Server-side execution.
  server('server'),

  /// Client-side execution.
  client('client');

  /// The JSON value for this type.
  final String value;

  const ToolSearchExecutionType(this.value);

  /// Creates a [ToolSearchExecutionType] from a JSON value.
  factory ToolSearchExecutionType.fromJson(String json) {
    return ToolSearchExecutionType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ToolSearchExecutionType.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
