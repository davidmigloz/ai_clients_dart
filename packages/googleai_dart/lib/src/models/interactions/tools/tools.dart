import '../../copy_with_sentinel.dart';
import '../../tools/computer_use_safety_policy.dart';
import '../allowed_tools.dart';
import 'exa_ai_search_config.dart';
import 'parallel_ai_search_config.dart';
import 'rag_store_config.dart';
import 'vertex_ai_search_config.dart';

part 'code_execution_tool.dart';
part 'computer_use_tool.dart';
part 'file_search_tool.dart';
part 'function_tool.dart';
part 'google_maps_tool.dart';
part 'google_search_tool.dart';
part 'mcp_server_tool.dart';
part 'retrieval_tool.dart';
part 'tool_search_tool.dart';
part 'url_context_tool.dart';

/// A tool that can be used by the model.
///
/// Variants include [FunctionTool], [GoogleMapsTool], [GoogleSearchTool],
/// [CodeExecutionTool], [UrlContextTool], [ComputerUseTool], [McpServerTool],
/// [FileSearchTool], [RetrievalTool], and [ToolSearchTool]. A future tool
/// search execution mode is retained as [UnknownInteractionTool].
sealed class InteractionTool {
  /// The type discriminator for this tool.
  String get type;

  const InteractionTool();

  /// Creates an [InteractionTool] from JSON.
  factory InteractionTool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'function' => FunctionTool.fromJson(json),
      'google_maps' => GoogleMapsTool.fromJson(json),
      'google_search' => GoogleSearchTool.fromJson(json),
      'code_execution' => CodeExecutionTool.fromJson(json),
      'url_context' => UrlContextTool.fromJson(json),
      'computer_use' => ComputerUseTool.fromJson(json),
      'mcp_server' => McpServerTool.fromJson(json),
      'file_search' => FileSearchTool.fromJson(json),
      'retrieval' => RetrievalTool.fromJson(json),
      'tool_search'
          when !const {null, 'server', 'client'}.contains(json['execution']) =>
        UnknownInteractionTool(json),
      'tool_search' => ToolSearchTool.fromJson(json),
      _ => throw ArgumentError('Unknown tool type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// An Interactions tool whose wire variant is newer than this client supports.
final class UnknownInteractionTool extends InteractionTool {
  @override
  final String type;

  /// The original tool declaration.
  final Map<String, dynamic> rawJson;

  /// Retains a tool declaration for inspection or round-tripping.
  UnknownInteractionTool(Map<String, dynamic> json)
    : type = json['type'] as String,
      rawJson = Map.unmodifiable(json);

  @override
  Map<String, dynamic> toJson() => rawJson;
}
