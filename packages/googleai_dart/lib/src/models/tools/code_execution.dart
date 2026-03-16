/// Tool that enables code execution capability.
///
/// This is an empty marker class — code execution requires no additional
/// configuration.
class CodeExecution {
  /// Creates a [CodeExecution].
  const CodeExecution();

  /// Creates a [CodeExecution] from JSON.
  // ignore: avoid_unused_constructor_parameters
  factory CodeExecution.fromJson(Map<String, dynamic> json) =>
      const CodeExecution();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {};

  @override
  String toString() => 'CodeExecution()';
}
