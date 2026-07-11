import '../../copy_with_sentinel.dart';
import '../content/content.dart';
import '../media_resolution.dart';
import '../steps/steps.dart';
import '../thought_summary_content.dart';
import '../tool_result.dart';

part 'arguments_delta.dart';
part 'audio_delta.dart';
part 'code_execution_call_delta.dart';
part 'code_execution_result_delta.dart';
part 'document_delta.dart';
part 'file_search_call_delta.dart';
part 'file_search_result_delta.dart';
part 'function_result_delta.dart';
part 'google_maps_call_delta.dart';
part 'google_maps_result_delta.dart';
part 'google_search_call_delta.dart';
part 'google_search_result_delta.dart';
part 'image_delta.dart';
part 'mcp_server_tool_call_delta.dart';
part 'mcp_server_tool_result_delta.dart';
part 'retrieval_call_delta.dart';
part 'retrieval_result_delta.dart';
part 'text_annotation_delta.dart';
part 'text_delta.dart';
part 'thought_signature_delta.dart';
part 'thought_summary_delta.dart';
part 'unknown_step_delta.dart';
part 'url_context_call_delta.dart';
part 'url_context_result_delta.dart';
part 'video_delta.dart';

/// A delta update for an interaction step.
///
/// This is a sealed class with subtypes for the different kinds of partial
/// payloads that can stream as part of a `step.delta` event:
/// - Content deltas: [TextDelta], [ImageDelta], [AudioDelta], [DocumentDelta],
///   [VideoDelta], [ThoughtSummaryDelta], [ThoughtSignatureDelta],
///   [TextAnnotationDelta], [ArgumentsDelta].
/// - Tool-call deltas: [CodeExecutionCallDelta], [UrlContextCallDelta],
///   [GoogleSearchCallDelta], [GoogleMapsCallDelta], [McpServerToolCallDelta],
///   [FileSearchCallDelta], [RetrievalCallDelta].
/// - Tool-result deltas: [CodeExecutionResultDelta], [UrlContextResultDelta],
///   [GoogleSearchResultDelta], [GoogleMapsResultDelta],
///   [McpServerToolResultDelta], [FileSearchResultDelta], [FunctionResultDelta],
///   [RetrievalResultDelta].
///
/// Plus an [UnknownStepDelta] fallback for any `type` this client does not yet
/// model, keeping streams forward-compatible.
sealed class StepDeltaData {
  /// The type discriminator for this delta.
  String get type;

  const StepDeltaData();

  /// Creates a [StepDeltaData] from JSON.
  ///
  /// Delta `type`s not in the published `StepDeltaData` schema are surfaced as
  /// [UnknownStepDelta] rather than throwing, keeping streams resilient and
  /// forward-compatible.
  factory StepDeltaData.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'text' => TextDelta.fromJson(json),
      'image' => ImageDelta.fromJson(json),
      'audio' => AudioDelta.fromJson(json),
      'document' => DocumentDelta.fromJson(json),
      'video' => VideoDelta.fromJson(json),
      'thought_summary' => ThoughtSummaryDelta.fromJson(json),
      'thought_signature' => ThoughtSignatureDelta.fromJson(json),
      'text_annotation_delta' => TextAnnotationDelta.fromJson(json),
      'arguments_delta' => ArgumentsDelta.fromJson(json),
      'code_execution_call' => CodeExecutionCallDelta.fromJson(json),
      'url_context_call' => UrlContextCallDelta.fromJson(json),
      'google_search_call' => GoogleSearchCallDelta.fromJson(json),
      'google_maps_call' => GoogleMapsCallDelta.fromJson(json),
      'mcp_server_tool_call' => McpServerToolCallDelta.fromJson(json),
      'file_search_call' => FileSearchCallDelta.fromJson(json),
      'code_execution_result' => CodeExecutionResultDelta.fromJson(json),
      'url_context_result' => UrlContextResultDelta.fromJson(json),
      'google_search_result' => GoogleSearchResultDelta.fromJson(json),
      'google_maps_result' => GoogleMapsResultDelta.fromJson(json),
      'mcp_server_tool_result' => McpServerToolResultDelta.fromJson(json),
      'file_search_result' => FileSearchResultDelta.fromJson(json),
      'function_result' => FunctionResultDelta.fromJson(json),
      'retrieval_call' => RetrievalCallDelta.fromJson(json),
      'retrieval_result' => RetrievalResultDelta.fromJson(json),
      _ => UnknownStepDelta.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
