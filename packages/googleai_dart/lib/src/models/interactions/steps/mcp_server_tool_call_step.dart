part of 'steps.dart';

/// An MCP server tool call step.
class McpServerToolCallStep extends InteractionStep {
  @override
  String get type => 'mcp_server_tool_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The name of the tool to call.
  final String name;

  /// The name of the MCP server.
  final String serverName;

  /// The JSON object of arguments for the function.
  final Map<String, dynamic> arguments;

  /// Creates an [McpServerToolCallStep] instance.
  const McpServerToolCallStep({
    required this.id,
    required this.name,
    required this.serverName,
    required this.arguments,
  });

  /// Creates an [McpServerToolCallStep] from JSON.
  factory McpServerToolCallStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'mcp_server_tool_call') {
      throw FormatException(
        'Expected type "mcp_server_tool_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException(
        'McpServerToolCallStep: missing required "id"',
      );
    }
    final name = json['name'];
    if (name is! String) {
      throw const FormatException(
        'McpServerToolCallStep: missing required "name"',
      );
    }
    final serverName = json['server_name'];
    if (serverName is! String) {
      throw const FormatException(
        'McpServerToolCallStep: missing required "server_name"',
      );
    }
    final arguments = json['arguments'];
    if (arguments is! Map<String, dynamic>) {
      throw const FormatException(
        'McpServerToolCallStep: missing required "arguments"',
      );
    }
    return McpServerToolCallStep(
      id: id,
      name: name,
      serverName: serverName,
      arguments: arguments,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'server_name': serverName,
    'arguments': arguments,
  };

  /// Creates a copy with replaced values.
  McpServerToolCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? serverName = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
  }) {
    return McpServerToolCallStep(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      name: name == unsetCopyWithValue ? this.name : name! as String,
      serverName: serverName == unsetCopyWithValue
          ? this.serverName
          : serverName! as String,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments! as Map<String, dynamic>,
    );
  }
}
