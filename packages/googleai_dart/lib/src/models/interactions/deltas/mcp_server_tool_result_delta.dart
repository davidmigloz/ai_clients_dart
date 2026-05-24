part of 'deltas.dart';

/// A streamed delta for an MCP server tool result.
class McpServerToolResultDelta extends StepDeltaData {
  @override
  String get type => 'mcp_server_tool_result';

  /// The output from the MCP server call.
  final ToolResult? result;

  /// Name of the tool which is called for this specific tool call.
  final String? name;

  /// The name of the MCP server.
  final String? serverName;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates an [McpServerToolResultDelta] instance.
  const McpServerToolResultDelta({
    this.result,
    this.name,
    this.serverName,
    this.signature,
  });

  /// Creates an [McpServerToolResultDelta] from JSON.
  factory McpServerToolResultDelta.fromJson(Map<String, dynamic> json) =>
      McpServerToolResultDelta(
        result: json['result'] != null
            ? ToolResult.fromJson(json['result'] as Object)
            : null,
        name: json['name'] as String?,
        serverName: json['server_name'] as String?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (result != null) 'result': result!.toJson(),
    if (name != null) 'name': name,
    if (serverName != null) 'server_name': serverName,
    if (signature != null) 'signature': signature,
  };
}
