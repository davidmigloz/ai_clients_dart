import '../models/chat/chat_choice.dart';
import '../models/chat/chat_completion_response.dart';
import '../models/chat/chat_message.dart';
import '../models/content/content_part.dart';
import '../models/metadata/finish_reason.dart';
import '../models/tools/function_call.dart';
import '../models/tools/tool_call.dart';

/// Convenience extensions for [ChatCompletionResponse].
extension ChatCompletionResponseExtensions on ChatCompletionResponse {
  /// Returns the first choice, or null if none exist.
  ChatChoice? get firstChoice => choices.firstOrNull;

  /// Returns the last choice, or null if none exist.
  ChatChoice? get lastChoice => choices.lastOrNull;

  /// The text content from the first choice's message.
  ///
  /// Returns null if no text content exists.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.chat.create(request: request);
  /// print(response.text); // Prints the generated text
  /// ```
  String? get text => firstChoice?.message.content;

  /// All text content from all choices, concatenated.
  ///
  /// Returns null if no text content exists in any choice.
  String? get allText {
    final buffer = StringBuffer();
    var hasText = false;
    for (final choice in choices) {
      final content = choice.message.content;
      if (content != null) {
        buffer.write(content);
        hasText = true;
      }
    }
    return hasText ? buffer.toString() : null;
  }

  /// The message from the first choice.
  ///
  /// Throws [StateError] if no choices exist.
  ChatMessage get message => choices.first.message;

  /// All messages from all choices.
  List<ChatMessage> get messages => choices.map((c) => c.message).toList();

  /// Tool calls from the first choice's message.
  ///
  /// Returns an empty list if no tool calls exist.
  List<ToolCall> get toolCalls =>
      firstChoice?.message.toolCalls ?? <ToolCall>[];

  /// All tool calls from all choices.
  List<ToolCall> get allToolCalls => [
    for (final choice in choices) ...choice.message.toolCalls ?? <ToolCall>[],
  ];

  /// Whether the first choice has tool calls.
  bool get hasToolCalls => toolCalls.isNotEmpty;

  /// Function calls from the first choice's message.
  ///
  /// Extracts function call information from tool calls.
  List<FunctionCall> get functionCalls =>
      toolCalls.map((tc) => tc.function).toList();

  /// Whether the response has valid content.
  bool get hasContent => text != null || hasToolCalls;

  /// The finish reason from the first choice.
  FinishReason? get finishReason => firstChoice?.finishReason;

  /// Whether the response was stopped due to tool calls.
  bool get stoppedForToolCalls => finishReason == FinishReason.toolCalls;

  /// Whether the response was stopped naturally.
  bool get stoppedNaturally => finishReason == FinishReason.stop;

  /// Whether the response was stopped due to length limit.
  bool get stoppedDueToLength => finishReason == FinishReason.length;
}

/// Convenience extensions for [ChatChoice].
extension ChatChoiceExtensions on ChatChoice {
  /// The text content from this choice's message.
  String? get text => message.content;

  /// Tool calls from this choice's message.
  List<ToolCall> get toolCalls => message.toolCalls ?? <ToolCall>[];

  /// Whether this choice has tool calls.
  bool get hasToolCalls => toolCalls.isNotEmpty;

  /// Function calls from this choice's tool calls.
  List<FunctionCall> get functionCalls =>
      toolCalls.map((tc) => tc.function).toList();

  /// Whether this choice stopped due to tool calls.
  bool get stoppedForToolCalls => finishReason == FinishReason.toolCalls;

  /// Whether this choice stopped naturally.
  bool get stoppedNaturally => finishReason == FinishReason.stop;
}

/// Convenience extensions for [AssistantMessage].
extension AssistantMessageExtensions on AssistantMessage {
  /// Whether this message has tool calls.
  bool get hasToolCalls => toolCalls?.isNotEmpty ?? false;

  /// The number of tool calls in this message.
  int get toolCallCount => toolCalls?.length ?? 0;

  /// Function calls from this message's tool calls.
  List<FunctionCall> get functionCalls =>
      toolCalls?.map((tc) => tc.function).toList() ?? [];

  /// Whether this message has text content.
  bool get hasContent => content?.isNotEmpty ?? false;
}

/// Convenience extensions for [SystemMessage].
extension SystemMessageExtensions on SystemMessage {
  /// Whether this message has text content.
  bool get hasContent => content.isNotEmpty;
}

/// Convenience extensions for [UserMessage].
extension UserMessageExtensions on UserMessage {
  /// Whether this message contains text content.
  bool get isTextOnly => content is String;

  /// Whether this message contains multimodal content.
  bool get isMultimodal => content is List<ContentPart>;

  /// The text content if this is a text-only message, null otherwise.
  String? get textContent => content is String ? content as String : null;
}

/// Convenience extensions for [ToolMessage].
extension ToolMessageExtensions on ToolMessage {
  /// Whether this message has text content.
  bool get hasContent => content.isNotEmpty;
}
