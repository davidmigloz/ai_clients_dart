import '../copy_with_sentinel.dart';
import 'tool_type.dart';

/// The result of a tool invocation, passed back to the API in a subsequent
/// turn alongside the corresponding [ToolCall].
class ToolResponse {
  /// Optional identifier of the tool call this response corresponds to, used
  /// to match [ToolCall.id] back to its response.
  final String? id;

  /// The response data.
  final Map<String, dynamic>? response;

  /// The type of tool that generated this response.
  final ToolType toolType;

  /// Creates a [ToolResponse].
  const ToolResponse({this.id, this.response, required this.toolType});

  /// Creates a [ToolResponse] from JSON.
  factory ToolResponse.fromJson(Map<String, dynamic> json) => ToolResponse(
    id: json['id'] as String?,
    response: json['response'] as Map<String, dynamic>?,
    toolType: toolTypeFromString(json['toolType'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (response != null) 'response': response,
    'toolType': toolTypeToString(toolType),
  };

  /// Creates a copy with replaced values.
  ToolResponse copyWith({
    Object? id = unsetCopyWithValue,
    Object? response = unsetCopyWithValue,
    Object? toolType = unsetCopyWithValue,
  }) {
    return ToolResponse(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      response: response == unsetCopyWithValue
          ? this.response
          : response as Map<String, dynamic>?,
      toolType: toolType == unsetCopyWithValue
          ? this.toolType
          : toolType! as ToolType,
    );
  }
}
