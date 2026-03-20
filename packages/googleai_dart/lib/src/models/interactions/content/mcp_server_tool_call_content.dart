part of 'content.dart';

/// An MCP Server tool call content block.
class McpServerToolCallContent extends InteractionContent {
  @override
  String get type => 'mcp_server_tool_call';

  /// A unique ID for this specific tool call.
  final String? id;

  /// The name of the tool which was called.
  final String? name;

  /// The name of the used MCP server.
  final String? serverName;

  /// The JSON object of arguments for the function.
  final Map<String, dynamic>? arguments;

  /// The signature of the MCP server tool call.
  final String? signature;

  /// Creates a [McpServerToolCallContent] instance.
  const McpServerToolCallContent({
    this.id,
    this.name,
    this.serverName,
    this.arguments,
    this.signature,
  });

  /// Creates a [McpServerToolCallContent] from JSON.
  factory McpServerToolCallContent.fromJson(Map<String, dynamic> json) =>
      McpServerToolCallContent(
        id: json['id'] as String?,
        name: json['name'] as String?,
        serverName: json['server_name'] as String?,
        arguments: json['arguments'] as Map<String, dynamic>?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (serverName != null) 'server_name': serverName,
    if (arguments != null) 'arguments': arguments,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  McpServerToolCallContent copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? serverName = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return McpServerToolCallContent(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      serverName: serverName == unsetCopyWithValue
          ? this.serverName
          : serverName as String?,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments as Map<String, dynamic>?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
