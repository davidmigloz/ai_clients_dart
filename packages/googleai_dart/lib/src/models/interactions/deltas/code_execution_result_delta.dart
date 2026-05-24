part of 'deltas.dart';

/// A streamed delta for a code execution result.
class CodeExecutionResultDelta extends StepDeltaData {
  @override
  String get type => 'code_execution_result';

  /// The result of the code execution.
  final String? result;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [CodeExecutionResultDelta] instance.
  const CodeExecutionResultDelta({this.result, this.isError, this.signature});

  /// Creates a [CodeExecutionResultDelta] from JSON.
  factory CodeExecutionResultDelta.fromJson(Map<String, dynamic> json) =>
      CodeExecutionResultDelta(
        result: json['result'] as String?,
        isError: json['is_error'] as bool?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (result != null) 'result': result,
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };
}
