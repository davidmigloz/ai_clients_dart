import '../copy_with_sentinel.dart';
import 'tool_type.dart';

/// A server-side tool invocation predicted by the model.
///
/// Clients should echo this back to the API in a subsequent turn alongside
/// the matching [ToolResponse].
class ToolCall {
  /// The arguments for the tool call.
  final Map<String, dynamic>? args;

  /// Optional unique ID of the tool call.
  final String? id;

  /// The type of tool being called.
  final ToolType toolType;

  /// Creates a [ToolCall].
  const ToolCall({this.args, this.id, required this.toolType});

  /// Creates a [ToolCall] from JSON.
  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
    args: json['args'] as Map<String, dynamic>?,
    id: json['id'] as String?,
    toolType: toolTypeFromString(json['toolType'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (args != null) 'args': args,
    if (id != null) 'id': id,
    'toolType': toolTypeToString(toolType),
  };

  /// Creates a copy with replaced values.
  ToolCall copyWith({
    Object? args = unsetCopyWithValue,
    Object? id = unsetCopyWithValue,
    Object? toolType = unsetCopyWithValue,
  }) {
    return ToolCall(
      args: args == unsetCopyWithValue
          ? this.args
          : args as Map<String, dynamic>?,
      id: id == unsetCopyWithValue ? this.id : id as String?,
      toolType: toolType == unsetCopyWithValue
          ? this.toolType
          : toolType! as ToolType,
    );
  }
}
