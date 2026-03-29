part of 'content.dart';

/// An MCP Server tool result content block.
class McpServerToolResultContent extends InteractionContent {
  @override
  String get type => 'mcp_server_tool_result';

  /// ID to match the ID from the MCP server tool call block.
  final String callId;

  /// Name of the tool which is called for this specific tool call.
  final String? name;

  /// The name of the used MCP server.
  final String? serverName;

  /// The result of the tool call.
  final ToolResult result;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// The signature of the MCP server tool result.
  final String? signature;

  /// Creates a [McpServerToolResultContent] instance.
  const McpServerToolResultContent({
    required this.callId,
    required this.result,
    this.name,
    this.serverName,
    this.isError,
    this.signature,
  });

  /// Creates a [McpServerToolResultContent] from JSON.
  ///
  /// Required fields default to empty values when absent
  /// (e.g. content.start events).
  factory McpServerToolResultContent.fromJson(Map<String, dynamic> json) =>
      McpServerToolResultContent(
        callId: json['call_id'] as String? ?? '',
        name: json['name'] as String?,
        serverName: json['server_name'] as String?,
        result: json['result'] != null
            ? ToolResult.fromJson(json['result'] as Object)
            : const ToolResultText(''),
        isError: json['is_error'] as bool?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    if (name != null) 'name': name,
    if (serverName != null) 'server_name': serverName,
    'result': result.toJson(),
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  McpServerToolResultContent copyWith({
    Object? callId = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? serverName = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return McpServerToolResultContent(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      serverName: serverName == unsetCopyWithValue
          ? this.serverName
          : serverName as String?,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as ToolResult,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
