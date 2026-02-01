import '../models/chat/chat.dart';
import '../models/common/finish_reason.dart';

/// Extension methods for [ChatCompletion] objects.
extension ChatCompletionExtension on ChatCompletion {
  /// Returns true if any choice has tool calls.
  bool get hasToolCalls => choices.any((c) => c.hasToolCalls);

  /// Returns all tool calls from all choices.
  List<ToolCall> get allToolCalls {
    final result = <ToolCall>[];
    for (final choice in choices) {
      if (choice.message.toolCalls case final calls?) {
        result.addAll(calls);
      }
    }
    return result;
  }

  /// Returns true if any choice has a refusal.
  bool get hasRefusal => choices.any((c) => c.message.refusal != null);

  /// Returns the first refusal message, if any.
  String? get refusal {
    for (final choice in choices) {
      if (choice.message.refusal case final r?) {
        return r;
      }
    }
    return null;
  }
}

/// Extension methods for [ChatChoice] objects.
extension ChatChoiceExtension on ChatChoice {
  /// Returns true if this choice has tool calls.
  bool get hasToolCalls =>
      message.toolCalls != null && message.toolCalls!.isNotEmpty;

  /// Returns true if this choice stopped due to tool calls.
  bool get stoppedForToolCalls => finishReason == FinishReason.toolCalls;

  /// Returns true if this choice stopped due to length limit.
  bool get stoppedForLength => finishReason == FinishReason.length;

  /// Returns true if this choice was filtered by content policy.
  bool get wasFiltered => finishReason == FinishReason.contentFilter;
}

/// Extension methods for lists of [ChatMessage] objects.
extension ChatMessageListExtension on List<ChatMessage> {
  /// Adds a user message to this list and returns a new list.
  List<ChatMessage> withUserMessage(String content) {
    return [...this, ChatMessage.user(content)];
  }

  /// Adds a system message to this list and returns a new list.
  List<ChatMessage> withSystemMessage(String content) {
    return [...this, ChatMessage.system(content)];
  }

  /// Adds an assistant message to this list and returns a new list.
  List<ChatMessage> withAssistantMessage(String content) {
    return [...this, ChatMessage.assistant(content: content)];
  }

  /// Returns only user messages.
  List<UserMessage> get userMessages => whereType<UserMessage>().toList();

  /// Returns only assistant messages.
  List<AssistantMessage> get assistantMessages =>
      whereType<AssistantMessage>().toList();

  /// Returns only system messages.
  List<SystemMessage> get systemMessages => whereType<SystemMessage>().toList();

  /// Returns only tool messages.
  List<ToolMessage> get toolMessages => whereType<ToolMessage>().toList();
}
