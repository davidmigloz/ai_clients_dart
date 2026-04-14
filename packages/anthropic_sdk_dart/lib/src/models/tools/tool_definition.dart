import 'package:meta/meta.dart';

import 'built_in_tools.dart';
import 'tool.dart';

/// A tool definition that can be passed to the model.
///
/// This sealed class represents either a [custom] user-defined tool or a
/// [builtIn] Anthropic tool (like bash, text editor, or web search).
///
/// Example usage:
/// ```dart
/// final tools = [
///   ToolDefinition.custom(
///     Tool(
///       name: 'get_weather',
///       description: 'Get the current weather in a location',
///       inputSchema: InputSchema(
///         properties: {
///           'location': {'type': 'string', 'description': 'City name'},
///         },
///         required: ['location'],
///         extra: {'additionalProperties': false},
///       ),
///     ),
///   ),
///   ToolDefinition.builtIn(BuiltInTool.webSearch()),
/// ];
/// ```
sealed class ToolDefinition {
  const ToolDefinition();

  /// Creates a custom user-defined tool.
  factory ToolDefinition.custom(Tool tool) = CustomToolDefinition;

  /// Creates a built-in Anthropic tool.
  factory ToolDefinition.builtIn(BuiltInTool tool) = BuiltInToolDefinition;

  /// Creates a [ToolDefinition] from JSON.
  ///
  /// Automatically detects whether the JSON represents a custom tool or a
  /// built-in tool based on the presence and value of the 'type' field.
  factory ToolDefinition.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    // Built-in tools have a versioned type like 'bash_20250124', 'web_search_20250305', etc.
    if (type != null && _isBuiltInType(type)) {
      return BuiltInToolDefinition(BuiltInTool.fromJson(json));
    }

    // Custom tools have type 'custom' or no type
    return CustomToolDefinition(Tool.fromJson(json));
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  static bool _isBuiltInType(String type) {
    return type.startsWith('advisor_') ||
        type.startsWith('bash_') ||
        type.startsWith('text_editor_') ||
        type.startsWith('web_search_') ||
        type.startsWith('web_fetch_') ||
        type.startsWith('memory_') ||
        type.startsWith('tool_search_tool_') ||
        type.startsWith('computer_') ||
        type.startsWith('code_execution_') ||
        type.startsWith('mcp_');
  }
}

/// A custom user-defined tool.
@immutable
class CustomToolDefinition extends ToolDefinition {
  /// The custom tool definition.
  final Tool tool;

  /// Creates a [CustomToolDefinition].
  const CustomToolDefinition(this.tool);

  @override
  Map<String, dynamic> toJson() => tool.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolDefinition &&
          runtimeType == other.runtimeType &&
          tool == other.tool;

  @override
  int get hashCode => tool.hashCode;

  @override
  String toString() => 'CustomToolDefinition(tool: $tool)';
}

/// A built-in Anthropic tool.
@immutable
class BuiltInToolDefinition extends ToolDefinition {
  /// The built-in tool.
  final BuiltInTool tool;

  /// Creates a [BuiltInToolDefinition].
  const BuiltInToolDefinition(this.tool);

  @override
  Map<String, dynamic> toJson() => tool.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuiltInToolDefinition &&
          runtimeType == other.runtimeType &&
          tool == other.tool;

  @override
  int get hashCode => tool.hashCode;

  @override
  String toString() => 'BuiltInToolDefinition(tool: $tool)';
}
