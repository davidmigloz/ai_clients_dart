part of 'steps.dart';

/// Result of a code execution call.
class CodeExecutionResultStep extends InteractionStep {
  @override
  String get type => 'code_execution_result';

  /// ID matching the corresponding [CodeExecutionCallStep.id].
  final String callId;

  /// The output of the code execution.
  final String result;

  /// Whether the code execution resulted in an error.
  final bool? isError;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [CodeExecutionResultStep] instance.
  const CodeExecutionResultStep({
    required this.callId,
    required this.result,
    this.isError,
    this.signature,
  });

  /// Creates a [CodeExecutionResultStep] from JSON.
  factory CodeExecutionResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'code_execution_result') {
      throw FormatException(
        'Expected type "code_execution_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'CodeExecutionResultStep: missing required "call_id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `result` is populated later via `step.delta`; default to empty when
    // absent.
    final result = json['result'] as String? ?? '';
    return CodeExecutionResultStep(
      callId: callId,
      result: result,
      isError: json['is_error'] as bool?,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result,
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  CodeExecutionResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return CodeExecutionResultStep(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue ? this.result : result! as String,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
