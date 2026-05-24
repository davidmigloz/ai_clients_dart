part of 'deltas.dart';

/// A streamed delta for a function tool result.
class FunctionResultDelta extends StepDeltaData {
  @override
  String get type => 'function_result';

  /// ID matching the corresponding function call.
  final String? callId;

  /// The result of the tool call.
  final ToolResult? result;

  /// The name of the tool that was called.
  final String? name;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// Creates a [FunctionResultDelta] instance.
  const FunctionResultDelta({
    this.callId,
    this.result,
    this.name,
    this.isError,
  });

  /// Creates a [FunctionResultDelta] from JSON.
  factory FunctionResultDelta.fromJson(Map<String, dynamic> json) =>
      FunctionResultDelta(
        callId: json['call_id'] as String?,
        result: json['result'] != null
            ? ToolResult.fromJson(json['result'] as Object)
            : null,
        name: json['name'] as String?,
        isError: json['is_error'] as bool?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (callId != null) 'call_id': callId,
    if (result != null) 'result': result!.toJson(),
    if (name != null) 'name': name,
    if (isError != null) 'is_error': isError,
  };
}
