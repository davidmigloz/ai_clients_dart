part of 'deltas.dart';

/// A function result delta update.
class FunctionResultDelta extends InteractionDelta {
  @override
  String get type => 'function_result';

  /// The name of the function.
  final String? name;

  /// The result of the function call.
  final ToolResult? result;

  /// Whether the function call resulted in an error.
  final bool? isError;

  /// A signature for this tool call.
  final String? signature;

  /// The ID of the tool call that produced this result.
  final String? callId;

  /// Creates a [FunctionResultDelta] instance.
  const FunctionResultDelta({
    this.name,
    this.result,
    this.isError,
    this.signature,
    this.callId,
  });

  /// Creates a [FunctionResultDelta] from JSON.
  factory FunctionResultDelta.fromJson(Map<String, dynamic> json) =>
      FunctionResultDelta(
        name: json['name'] as String?,
        result: json['result'] != null
            ? ToolResult.fromJson(json['result'] as Object)
            : null,
        isError: json['is_error'] as bool?,
        signature: json['signature'] as String?,
        callId: json['call_id'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (name != null) 'name': name,
    if (result != null) 'result': result!.toJson(),
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
    if (callId != null) 'call_id': callId,
  };
}
