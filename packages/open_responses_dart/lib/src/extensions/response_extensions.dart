import '../models/content/output_content.dart';
import '../models/items/output_item.dart';
import '../models/metadata/response_status.dart';
import '../models/response/response_resource.dart';

/// Convenience extensions for [ResponseResource].
extension ResponseResourceExtensions on ResponseResource {
  /// Concatenated text from all output text parts.
  ///
  /// Returns null if no text content exists.
  /// Matches OpenAI SDK's `output_text` property.
  String? get outputText {
    final buffer = StringBuffer();
    for (final item in output ?? []) {
      if (item is MessageOutputItem) {
        for (final content in item.content) {
          if (content is OutputTextContent) {
            buffer.write(content.text);
          }
        }
      }
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  /// All function calls from the response output.
  List<FunctionCallOutputItemResponse> get functionCalls {
    return [
      for (final item in output ?? [])
        if (item is FunctionCallOutputItemResponse) item,
    ];
  }

  /// All reasoning items from the output.
  List<ReasoningItem> get reasoningItems {
    return [
      for (final item in output ?? [])
        if (item is ReasoningItem) item,
    ];
  }

  /// Whether this response has tool calls that need execution.
  bool get hasToolCalls => functionCalls.isNotEmpty;

  /// Whether the response completed successfully.
  bool get isCompleted => status == ResponseStatus.completed;

  /// Whether the response failed.
  bool get isFailed => status == ResponseStatus.failed;

  /// Whether the response is still in progress.
  bool get isInProgress => status == ResponseStatus.inProgress;
}
