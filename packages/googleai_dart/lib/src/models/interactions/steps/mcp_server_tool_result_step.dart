part of 'steps.dart';

/// Result of an MCP server tool call.
class McpServerToolResultStep extends InteractionStep {
  @override
  String get type => 'mcp_server_tool_result';

  /// ID matching the corresponding [McpServerToolCallStep.id].
  final String callId;

  /// The output from the MCP server call.
  final ToolResult result;

  /// Name of the tool which is called for this specific tool call.
  final String? name;

  /// The name of the MCP server.
  final String? serverName;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// Creates an [McpServerToolResultStep] instance.
  const McpServerToolResultStep({
    required this.callId,
    required this.result,
    this.name,
    this.serverName,
    this.isError,
  });

  /// Creates an [McpServerToolResultStep] from JSON.
  factory McpServerToolResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'mcp_server_tool_result') {
      throw FormatException(
        'Expected type "mcp_server_tool_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'McpServerToolResultStep: missing required "call_id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `result` is populated later via `step.delta`; default to empty when
    // absent.
    final resultJson = json['result'];
    final result = resultJson == null
        ? const ToolResultText('')
        : ToolResult.fromJson(resultJson as Object);
    return McpServerToolResultStep(
      callId: callId,
      result: result,
      name: json['name'] as String?,
      serverName: json['server_name'] as String?,
      isError: json['is_error'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.toJson(),
    if (name != null) 'name': name,
    if (serverName != null) 'server_name': serverName,
    if (isError != null) 'is_error': isError,
  };

  /// Creates a copy with replaced values.
  McpServerToolResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? serverName = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
  }) {
    return McpServerToolResultStep(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as ToolResult,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      serverName: serverName == unsetCopyWithValue
          ? this.serverName
          : serverName as String?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
    );
  }
}
