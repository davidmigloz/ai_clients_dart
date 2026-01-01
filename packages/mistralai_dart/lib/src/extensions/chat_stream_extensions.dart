import '../models/chat/chat_choice_delta.dart';
import '../models/chat/chat_completion_stream_response.dart';
import '../models/metadata/finish_reason.dart';
import '../models/tools/tool_call.dart';

/// Convenience extensions for [ChatCompletionStreamResponse].
extension ChatCompletionStreamResponseExtensions
    on ChatCompletionStreamResponse {
  /// Returns the first choice delta, or null if none exist.
  ChatChoiceDelta? get firstChoice => choices.firstOrNull;

  /// The text content from the first choice's delta.
  ///
  /// Returns null if no text content exists.
  ///
  /// Example:
  /// ```dart
  /// await for (final chunk in client.chat.createStream(request: request)) {
  ///   final text = chunk.text;
  ///   if (text != null) {
  ///     stdout.write(text);
  ///   }
  /// }
  /// ```
  String? get text => firstChoice?.delta.content;

  /// Tool calls from the first choice's delta.
  ///
  /// Returns an empty list if no tool calls exist.
  List<ToolCall> get toolCalls => firstChoice?.delta.toolCalls ?? [];

  /// Whether this chunk has tool calls.
  bool get hasToolCalls => toolCalls.isNotEmpty;

  /// The finish reason from the first choice.
  FinishReason? get finishReason => firstChoice?.finishReason;

  /// Whether this is the final chunk (has a finish reason).
  bool get isFinal => finishReason != null;

  /// Whether this chunk indicates tool calls are complete.
  bool get stoppedForToolCalls => finishReason == FinishReason.toolCalls;

  /// Whether the stream stopped naturally.
  bool get stoppedNaturally => finishReason == FinishReason.stop;
}

/// Convenience extensions for [ChatChoiceDelta].
extension ChatChoiceDeltaExtensions on ChatChoiceDelta {
  /// The text content from this delta.
  String? get text => delta.content;

  /// Tool calls from this delta.
  List<ToolCall> get toolCalls => delta.toolCalls ?? [];

  /// Whether this delta has tool calls.
  bool get hasToolCalls => toolCalls.isNotEmpty;

  /// Whether this is the final delta (has a finish reason).
  bool get isFinal => finishReason != null;

  /// Whether this delta indicates tool calls are complete.
  bool get stoppedForToolCalls => finishReason == FinishReason.toolCalls;
}

/// Convenience extensions for streaming chat completion.
extension ChatStreamExtensions on Stream<ChatCompletionStreamResponse> {
  /// Collects all text content from the stream into a single string.
  ///
  /// Example:
  /// ```dart
  /// final stream = client.chat.createStream(request: request);
  /// final fullText = await stream.text;
  /// print(fullText);
  /// ```
  Future<String> get text async {
    final buffer = StringBuffer();
    await for (final chunk in this) {
      final content = chunk.text;
      if (content != null) {
        buffer.write(content);
      }
    }
    return buffer.toString();
  }

  /// Collects all tool calls from the stream.
  ///
  /// Note: Tool calls in streaming may be split across chunks.
  /// This collects all tool call deltas - you may need to
  /// merge them based on their indices.
  Future<List<ToolCall>> get allToolCalls async {
    final calls = <ToolCall>[];
    await for (final chunk in this) {
      calls.addAll(chunk.toolCalls);
    }
    return calls;
  }

  /// Prints each text chunk to stdout as it arrives.
  ///
  /// Returns the complete text after the stream ends.
  ///
  /// Example:
  /// ```dart
  /// final stream = client.chat.createStream(request: request);
  /// final fullText = await stream.printText();
  /// ```
  Future<String> printText() async {
    final buffer = StringBuffer();
    await for (final chunk in this) {
      final content = chunk.text;
      if (content != null) {
        // ignore: avoid_print
        print(content);
        buffer.write(content);
      }
    }
    return buffer.toString();
  }
}
