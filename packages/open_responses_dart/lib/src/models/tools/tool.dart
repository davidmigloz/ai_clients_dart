import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Tool definition for function calling.
sealed class Tool {
  /// Creates a [Tool].
  const Tool();

  /// Creates a [Tool] from JSON.
  factory Tool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'function' => FunctionTool.fromJson(json),
      'mcp' => McpTool.fromJson(json),
      _ => throw FormatException('Unknown Tool type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A function tool.
@immutable
class FunctionTool extends Tool {
  /// The function name.
  final String name;

  /// Description of what the function does.
  final String? description;

  /// JSON Schema for the function parameters.
  final Map<String, dynamic>? parameters;

  /// Whether to enable strict schema adherence.
  final bool? strict;

  /// Creates a [FunctionTool].
  const FunctionTool({
    required this.name,
    this.description,
    this.parameters,
    this.strict,
  });

  /// Creates a [FunctionTool] from JSON.
  factory FunctionTool.fromJson(Map<String, dynamic> json) {
    return FunctionTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function',
    'name': name,
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
    if (strict != null) 'strict': strict,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionTool &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapsEqual(parameters, other.parameters) &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(name, description, parameters, strict);

  @override
  String toString() =>
      'FunctionTool(name: $name, description: $description, parameters: $parameters, strict: $strict)';
}

/// A Model Context Protocol (MCP) tool.
///
/// Allows connecting to remote MCP servers for extended capabilities.
@immutable
class McpTool extends Tool {
  /// Label for the MCP server.
  final String serverLabel;

  /// URL of the MCP server.
  final String serverUrl;

  /// List of allowed tools from this server.
  final List<String>? allowedTools;

  /// Approval requirement for tool execution.
  final String? requireApproval;

  /// Creates an [McpTool].
  const McpTool({
    required this.serverLabel,
    required this.serverUrl,
    this.allowedTools,
    this.requireApproval,
  });

  /// Creates an [McpTool] from JSON.
  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      serverLabel: json['server_label'] as String,
      serverUrl: json['server_url'] as String,
      allowedTools: (json['allowed_tools'] as List?)?.cast<String>(),
      requireApproval: json['require_approval'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp',
    'server_label': serverLabel,
    'server_url': serverUrl,
    if (allowedTools != null) 'allowed_tools': allowedTools,
    if (requireApproval != null) 'require_approval': requireApproval,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpTool &&
          runtimeType == other.runtimeType &&
          serverLabel == other.serverLabel &&
          serverUrl == other.serverUrl &&
          listsEqual(allowedTools, other.allowedTools) &&
          requireApproval == other.requireApproval;

  @override
  int get hashCode =>
      Object.hash(serverLabel, serverUrl, allowedTools, requireApproval);

  @override
  String toString() =>
      'McpTool(serverLabel: $serverLabel, serverUrl: $serverUrl, allowedTools: $allowedTools, requireApproval: $requireApproval)';
}
