part of 'deltas.dart';

/// A streamed delta for an MCP server tool call.
class McpServerToolCallDelta extends StepDeltaData {
  @override
  String get type => 'mcp_server_tool_call';

  /// The JSON-encoded arguments for the MCP server tool call.
  final Map<String, dynamic>? arguments;

  /// Name of the tool which is called for this specific tool call.
  final String? name;

  /// The name of the MCP server.
  final String? serverName;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates an [McpServerToolCallDelta] instance.
  const McpServerToolCallDelta({
    this.arguments,
    this.name,
    this.serverName,
    this.signature,
  });

  /// Creates an [McpServerToolCallDelta] from JSON.
  factory McpServerToolCallDelta.fromJson(Map<String, dynamic> json) =>
      McpServerToolCallDelta(
        arguments: json['arguments'] as Map<String, dynamic>?,
        name: json['name'] as String?,
        serverName: json['server_name'] as String?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (arguments != null) 'arguments': arguments,
    if (name != null) 'name': name,
    if (serverName != null) 'server_name': serverName,
    if (signature != null) 'signature': signature,
  };
}
