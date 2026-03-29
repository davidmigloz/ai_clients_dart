part of 'content.dart';

/// A function tool result content block.
class FunctionResultContent extends InteractionContent {
  @override
  String get type => 'function_result';

  /// ID to match the ID from the function call block.
  final String callId;

  /// The result of the tool call.
  final ToolResult result;

  /// The name of the tool that was called.
  final String? name;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// The signature of the function result.
  final String? signature;

  /// Creates a [FunctionResultContent] instance.
  const FunctionResultContent({
    required this.callId,
    required this.result,
    this.name,
    this.isError,
    this.signature,
  });

  /// Creates a [FunctionResultContent] from JSON.
  ///
  /// Required fields default to empty values when absent
  /// (e.g. content.start events).
  factory FunctionResultContent.fromJson(Map<String, dynamic> json) =>
      FunctionResultContent(
        callId: json['call_id'] as String? ?? '',
        result: json['result'] != null
            ? ToolResult.fromJson(json['result'] as Object)
            : const ToolResultText(''),
        name: json['name'] as String?,
        isError: json['is_error'] as bool?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.toJson(),
    if (name != null) 'name': name,
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FunctionResultContent copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FunctionResultContent(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as ToolResult,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
