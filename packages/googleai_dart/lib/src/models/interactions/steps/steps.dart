import '../../copy_with_sentinel.dart';
import '../content/content.dart';
import '../interaction_review_snippet.dart';
import '../thought_summary_content.dart';
import '../tool_result.dart';

part 'code_execution_call_step.dart';
part 'code_execution_result_step.dart';
part 'file_search_call_step.dart';
part 'file_search_result_step.dart';
part 'function_call_step.dart';
part 'function_result_step.dart';
part 'google_maps_call_step.dart';
part 'google_maps_result_step.dart';
part 'google_search_call_step.dart';
part 'google_search_result_step.dart';
part 'mcp_server_tool_call_step.dart';
part 'mcp_server_tool_result_step.dart';
part 'model_output_step.dart';
part 'thought_step.dart';
part 'unknown_step.dart';
part 'url_context_call_step.dart';
part 'url_context_result_step.dart';
part 'user_input_step.dart';

/// A step in an interaction.
///
/// This is a sealed class with 17 documented subtypes representing the
/// different kinds of steps an interaction can contain (user input, model
/// output, thought, tool calls, and tool results), plus an [UnknownStep]
/// fallback for any `type` this client does not yet model.
sealed class InteractionStep {
  /// The type discriminator for this step.
  String get type;

  const InteractionStep();

  /// Creates an [InteractionStep] from JSON.
  ///
  /// Unrecognized `type` values are surfaced as [UnknownStep] (raw JSON
  /// preserved) so a new/undocumented step type cannot break parsing of a
  /// `steps` list or a streamed `step.start` event.
  factory InteractionStep.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'user_input' => UserInputStep.fromJson(json),
      'model_output' => ModelOutputStep.fromJson(json),
      'thought' => ThoughtStep.fromJson(json),
      'function_call' => FunctionCallStep.fromJson(json),
      'function_result' => FunctionResultStep.fromJson(json),
      'code_execution_call' => CodeExecutionCallStep.fromJson(json),
      'code_execution_result' => CodeExecutionResultStep.fromJson(json),
      'url_context_call' => UrlContextCallStep.fromJson(json),
      'url_context_result' => UrlContextResultStep.fromJson(json),
      'google_search_call' => GoogleSearchCallStep.fromJson(json),
      'google_search_result' => GoogleSearchResultStep.fromJson(json),
      'google_maps_call' => GoogleMapsCallStep.fromJson(json),
      'google_maps_result' => GoogleMapsResultStep.fromJson(json),
      'file_search_call' => FileSearchCallStep.fromJson(json),
      'file_search_result' => FileSearchResultStep.fromJson(json),
      'mcp_server_tool_call' => McpServerToolCallStep.fromJson(json),
      'mcp_server_tool_result' => McpServerToolResultStep.fromJson(json),
      _ => UnknownStep.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
