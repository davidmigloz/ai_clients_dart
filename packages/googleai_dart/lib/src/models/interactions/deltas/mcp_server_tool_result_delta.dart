part of 'deltas.dart';

/// An MCP Server tool result delta update.
class McpServerToolResultDelta extends InteractionDelta {
  @override
  String get type => 'mcp_server_tool_result';

  /// The name of the tool.
  final String? name;

  /// The name of the MCP server.
  final String? serverName;

  /// The result of the tool call.
  final ToolResult? result;

  /// A signature for this tool call.
  final String? signature;

  /// The ID of the tool call that produced this result.
  final String? callId;

  /// Creates a [McpServerToolResultDelta] instance.
  const McpServerToolResultDelta({
    this.name,
    this.serverName,
    this.result,
    this.signature,
    this.callId,
  });

  /// Creates a [McpServerToolResultDelta] from JSON.
  factory McpServerToolResultDelta.fromJson(Map<String, dynamic> json) =>
      McpServerToolResultDelta(
        name: json['name'] as String?,
        serverName: json['server_name'] as String?,
        result: json['result'] != null
            ? ToolResult.fromJson(json['result'] as Object)
            : null,
        signature: json['signature'] as String?,
        callId: json['call_id'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (name != null) 'name': name,
    if (serverName != null) 'server_name': serverName,
    if (result != null) 'result': result!.toJson(),
    if (signature != null) 'signature': signature,
    if (callId != null) 'call_id': callId,
  };
}
