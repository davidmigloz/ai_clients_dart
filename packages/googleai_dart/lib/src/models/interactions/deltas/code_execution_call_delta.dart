part of 'deltas.dart';

/// A streamed delta for a code execution tool call.
class CodeExecutionCallDelta extends StepDeltaData {
  @override
  String get type => 'code_execution_call';

  /// The arguments for the code execution call.
  final CodeExecutionCallStepArguments? arguments;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [CodeExecutionCallDelta] instance.
  const CodeExecutionCallDelta({this.arguments, this.signature});

  /// Creates a [CodeExecutionCallDelta] from JSON.
  factory CodeExecutionCallDelta.fromJson(Map<String, dynamic> json) =>
      CodeExecutionCallDelta(
        arguments: json['arguments'] is Map<String, dynamic>
            ? CodeExecutionCallStepArguments.fromJson(
                json['arguments'] as Map<String, dynamic>,
              )
            : null,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (arguments != null) 'arguments': arguments!.toJson(),
    if (signature != null) 'signature': signature,
  };
}
