part of 'steps.dart';

/// Result of a function tool call.
class FunctionResultStep extends InteractionStep {
  @override
  String get type => 'function_result';

  /// ID matching the corresponding [FunctionCallStep.id].
  final String callId;

  /// The result of the tool call.
  final ToolResult result;

  /// The name of the tool that was called.
  final String? name;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// Creates a [FunctionResultStep] instance.
  const FunctionResultStep({
    required this.callId,
    required this.result,
    this.name,
    this.isError,
  });

  /// Creates a [FunctionResultStep] from JSON.
  factory FunctionResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'function_result') {
      throw FormatException(
        'Expected type "function_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'FunctionResultStep: missing required "call_id"',
      );
    }
    final result = json['result'];
    if (result == null) {
      throw const FormatException(
        'FunctionResultStep: missing required "result"',
      );
    }
    return FunctionResultStep(
      callId: callId,
      result: ToolResult.fromJson(result as Object),
      name: json['name'] as String?,
      isError: json['is_error'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.toJson(),
    if (name != null) 'name': name,
    if (isError != null) 'is_error': isError,
  };

  /// Creates a copy with replaced values.
  FunctionResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
  }) {
    return FunctionResultStep(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as ToolResult,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
    );
  }
}
