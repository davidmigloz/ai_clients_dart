import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../responses/common/equality_helpers.dart';
import 'content_part.dart';
import 'reasoning_detail.dart';
import 'tool_call.dart';
import 'user_message_content.dart';

/// A message in a chat conversation.
///
/// Messages represent the conversation history between the user, assistant,
/// and system. Different message types have different capabilities:
///
/// - [SystemMessage]: Sets the behavior and context for the assistant
/// - [DeveloperMessage]: Similar to system but for multi-turn conversations
/// - [UserMessage]: User input (text, images, or audio)
/// - [AssistantMessage]: Model responses, including tool calls
/// - [ToolMessage]: Results from tool/function calls
///
/// ## Example
///
/// ```dart
/// final messages = [
///   ChatMessage.system('You are a helpful assistant.'),
///   ChatMessage.user('Hello!'),
///   ChatMessage.assistant(content: 'Hi! How can I help you today?'),
/// ];
/// ```
@immutable
sealed class ChatMessage {
  const ChatMessage();

  /// Creates a [ChatMessage] from JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String;
    return switch (role) {
      'system' => SystemMessage.fromJson(json),
      'developer' => DeveloperMessage.fromJson(json),
      'user' => UserMessage.fromJson(json),
      'assistant' => AssistantMessage.fromJson(json),
      'tool' => ToolMessage.fromJson(json),
      _ => throw FormatException('Unknown message role: $role'),
    };
  }

  /// Creates a system message.
  static ChatMessage system(String content, {String? name}) =>
      SystemMessage(content: content, name: name);

  /// Creates a developer message.
  static ChatMessage developer(String content, {String? name}) =>
      DeveloperMessage(content: content, name: name);

  /// Creates a user message with text or multipart content.
  ///
  /// The [content] can be:
  /// - A [String] for simple text messages
  /// - A [List<ContentPart>] for multimodal messages
  /// - A [UserMessageContent] for type-safe content
  static ChatMessage user(Object content, {String? name}) {
    final messageContent = switch (content) {
      final String text => UserMessageContent.text(text),
      final List<ContentPart> parts => UserMessageContent.parts(parts),
      final UserMessageContent c => c,
      _ => throw ArgumentError.value(
        content,
        'content',
        'Must be String, List<ContentPart>, or UserMessageContent',
      ),
    };
    return UserMessage(content: messageContent, name: name);
  }

  /// Creates an assistant message.
  static ChatMessage assistant({
    String? content,
    String? name,
    String? refusal,
    List<ToolCall>? toolCalls,
  }) => AssistantMessage(
    content: content,
    name: name,
    refusal: refusal,
    toolCalls: toolCalls,
  );

  /// Creates a tool message with the result of a tool call.
  static ChatMessage tool({
    required String toolCallId,
    required String content,
  }) => ToolMessage(toolCallId: toolCallId, content: content);

  /// The role of the message author.
  String get role;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A system message that sets behavior and context.
///
/// System messages help set the behavior of the assistant. For example,
/// you can modify the personality or provide specific instructions.
///
/// ## Example
///
/// ```dart
/// final message = ChatMessage.system(
///   'You are a helpful assistant that speaks like a pirate.',
/// );
/// ```
@immutable
class SystemMessage extends ChatMessage {
  /// Creates a [SystemMessage].
  const SystemMessage({required this.content, this.name});

  /// Creates a [SystemMessage] from JSON.
  factory SystemMessage.fromJson(Map<String, dynamic> json) {
    return SystemMessage(
      content: json['content'] as String,
      name: json['name'] as String?,
    );
  }

  /// The content of the system message.
  final String content;

  /// An optional name for the participant.
  final String? name;

  @override
  String get role => 'system';

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    if (name != null) 'name': name,
  };

  /// Creates a copy with the given fields replaced.
  SystemMessage copyWith({String? content, Object? name = unsetCopyWithValue}) {
    return SystemMessage(
      content: content ?? this.content,
      name: name == unsetCopyWithValue ? this.name : name as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessage &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          name == other.name;

  @override
  int get hashCode => Object.hash(content, name);

  @override
  String toString() => 'ChatMessage.system(content: $content, name: $name)';
}

/// A developer message for multi-turn developer instructions.
///
/// Developer messages are similar to system messages but can appear
/// anywhere in the conversation to provide ongoing instructions.
@immutable
class DeveloperMessage extends ChatMessage {
  /// Creates a [DeveloperMessage].
  const DeveloperMessage({required this.content, this.name});

  /// Creates a [DeveloperMessage] from JSON.
  factory DeveloperMessage.fromJson(Map<String, dynamic> json) {
    return DeveloperMessage(
      content: json['content'] as String,
      name: json['name'] as String?,
    );
  }

  /// The content of the developer message.
  final String content;

  /// An optional name for the participant.
  final String? name;

  @override
  String get role => 'developer';

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    if (name != null) 'name': name,
  };

  /// Creates a copy with the given fields replaced.
  DeveloperMessage copyWith({
    String? content,
    Object? name = unsetCopyWithValue,
  }) {
    return DeveloperMessage(
      content: content ?? this.content,
      name: name == unsetCopyWithValue ? this.name : name as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeveloperMessage &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          name == other.name;

  @override
  int get hashCode => Object.hash(content, name);

  @override
  String toString() => 'ChatMessage.developer(content: $content, name: $name)';
}

/// A user message containing text, images, or audio.
///
/// User messages can contain:
/// - Simple text (as [UserTextContent])
/// - Multiple content parts (as [UserPartsContent])
///
/// ## Examples
///
/// ```dart
/// // Simple text message
/// final textMessage = ChatMessage.user('Hello!');
///
/// // Multimodal message with image
/// final imageMessage = ChatMessage.user([
///   ContentPart.text('What is in this image?'),
///   ContentPart.imageUrl('https://example.com/image.jpg'),
/// ]);
/// ```
@immutable
class UserMessage extends ChatMessage {
  /// Creates a [UserMessage].
  const UserMessage({required this.content, this.name});

  /// Creates a [UserMessage] from JSON.
  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
      content: UserMessageContent.fromJson(json['content'] as Object),
      name: json['name'] as String?,
    );
  }

  /// The content of the user message.
  final UserMessageContent content;

  /// An optional name for the participant.
  final String? name;

  /// Gets the text content if this is a simple text message.
  String? get text => switch (content) {
    UserTextContent(:final text) => text,
    UserPartsContent() => null,
  };

  /// Gets the content parts if this is a multimodal message.
  List<ContentPart>? get parts => switch (content) {
    UserTextContent() => null,
    UserPartsContent(:final parts) => parts,
  };

  @override
  String get role => 'user';

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content.toJson(),
    if (name != null) 'name': name,
  };

  /// Creates a copy with the given fields replaced.
  UserMessage copyWith({
    UserMessageContent? content,
    Object? name = unsetCopyWithValue,
  }) {
    return UserMessage(
      content: content ?? this.content,
      name: name == unsetCopyWithValue ? this.name : name as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessage &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          name == other.name;

  @override
  int get hashCode => Object.hash(content, name);

  @override
  String toString() => switch (content) {
    UserTextContent(:final text) =>
      'ChatMessage.user(content: $text, name: $name)',
    UserPartsContent(:final parts) =>
      'ChatMessage.user(content: [${parts.length} parts], name: $name)',
  };
}

/// An assistant message containing a response or tool calls.
///
/// Assistant messages represent responses from the model. They can contain:
/// - Text content
/// - Tool/function calls
/// - A refusal message
/// - Reasoning content (for models that support reasoning like DeepSeek R1)
///
/// ## Example
///
/// ```dart
/// final message = ChatMessage.assistant(
///   content: 'The weather in San Francisco is sunny.',
/// );
/// ```
@immutable
class AssistantMessage extends ChatMessage {
  /// Creates an [AssistantMessage].
  const AssistantMessage({
    this.content,
    this.name,
    this.refusal,
    this.toolCalls,
    this.reasoningContent,
    this.reasoning,
    this.reasoningDetails,
  });

  /// Creates an [AssistantMessage] from JSON.
  factory AssistantMessage.fromJson(Map<String, dynamic> json) {
    return AssistantMessage(
      content: json['content'] as String?,
      name: json['name'] as String?,
      refusal: json['refusal'] as String?,
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Reasoning fields for OpenRouter/DeepSeek compatibility
      reasoningContent: json['reasoning_content'] as String?,
      reasoning: json['reasoning'] as String?,
      reasoningDetails: (json['reasoning_details'] as List<dynamic>?)
          ?.map((e) => ReasoningDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The text content of the assistant message.
  final String? content;

  /// An optional name for the participant.
  final String? name;

  /// The refusal message if the model declined to respond.
  final String? refusal;

  /// The tool calls made by the assistant.
  final List<ToolCall>? toolCalls;

  /// **DeepSeek R1 / vLLM only.** The reasoning content from the model.
  ///
  /// Not part of the official OpenAI API. This field contains the model's
  /// internal reasoning process when using models that support it.
  final String? reasoningContent;

  /// **OpenRouter only.** The reasoning summary from the model.
  ///
  /// Not part of the official OpenAI API. This is a simplified version of
  /// the reasoning returned by OpenRouter.
  final String? reasoning;

  /// **OpenRouter only.** Detailed reasoning information.
  ///
  /// Not part of the official OpenAI API. Contains structured reasoning
  /// details including summaries, text, and encrypted data.
  final List<ReasoningDetail>? reasoningDetails;

  /// Whether this message contains tool calls.
  bool get hasToolCalls => toolCalls != null && toolCalls!.isNotEmpty;

  /// Whether the model refused to respond.
  bool get isRefusal => refusal != null;

  /// Whether this message contains reasoning content.
  bool get hasReasoningContent =>
      reasoningContent != null ||
      reasoning != null ||
      (reasoningDetails != null && reasoningDetails!.isNotEmpty);

  @override
  String get role => 'assistant';

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    if (content != null) 'content': content,
    if (name != null) 'name': name,
    if (refusal != null) 'refusal': refusal,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((tc) => tc.toJson()).toList(),
    // Include reasoning fields in toJson for serialization/debugging
    if (reasoningContent != null) 'reasoning_content': reasoningContent,
    if (reasoning != null) 'reasoning': reasoning,
    if (reasoningDetails != null)
      'reasoning_details': reasoningDetails!.map((rd) => rd.toJson()).toList(),
  };

  /// Converts to JSON for sending back to the API.
  ///
  /// **IMPORTANT:** This method excludes reasoning fields that would cause
  /// 400 errors when sent back to some providers. Use this instead of
  /// [toJson] when sending messages back to the API.
  Map<String, dynamic> toApiJson() => {
    'role': role,
    if (content != null) 'content': content,
    if (name != null) 'name': name,
    if (refusal != null) 'refusal': refusal,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((tc) => tc.toJson()).toList(),
    // NOTE: reasoning fields intentionally excluded for API compatibility
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantMessage &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          name == other.name &&
          refusal == other.refusal &&
          listsEqual(toolCalls, other.toolCalls) &&
          reasoningContent == other.reasoningContent &&
          reasoning == other.reasoning &&
          listsEqual(reasoningDetails, other.reasoningDetails);

  @override
  int get hashCode => Object.hash(
    content,
    name,
    refusal,
    toolCalls != null ? Object.hashAll(toolCalls!) : null,
    reasoningContent,
    reasoning,
    reasoningDetails != null ? Object.hashAll(reasoningDetails!) : null,
  );

  /// Creates a copy with the given fields replaced.
  AssistantMessage copyWith({
    Object? content = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? refusal = unsetCopyWithValue,
    Object? toolCalls = unsetCopyWithValue,
    Object? reasoningContent = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? reasoningDetails = unsetCopyWithValue,
  }) {
    return AssistantMessage(
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      refusal: refusal == unsetCopyWithValue
          ? this.refusal
          : refusal as String?,
      toolCalls: toolCalls == unsetCopyWithValue
          ? this.toolCalls
          : toolCalls as List<ToolCall>?,
      reasoningContent: reasoningContent == unsetCopyWithValue
          ? this.reasoningContent
          : reasoningContent as String?,
      reasoning: reasoning == unsetCopyWithValue
          ? this.reasoning
          : reasoning as String?,
      reasoningDetails: reasoningDetails == unsetCopyWithValue
          ? this.reasoningDetails
          : reasoningDetails as List<ReasoningDetail>?,
    );
  }

  @override
  String toString() {
    if (hasToolCalls) {
      return 'ChatMessage.assistant(toolCalls: ${toolCalls!.length})';
    }
    if (hasReasoningContent) {
      return 'ChatMessage.assistant($content, hasReasoning: true)';
    }
    return 'ChatMessage.assistant($content)';
  }
}

/// A tool message containing the result of a tool call.
///
/// Tool messages are used to provide the results of function/tool calls
/// back to the model so it can continue generating.
///
/// ## Example
///
/// ```dart
/// final message = ChatMessage.tool(
///   toolCallId: 'call_abc123',
///   content: '{"temperature": 72, "condition": "sunny"}',
/// );
/// ```
@immutable
class ToolMessage extends ChatMessage {
  /// Creates a [ToolMessage].
  const ToolMessage({required this.toolCallId, required this.content});

  /// Creates a [ToolMessage] from JSON.
  factory ToolMessage.fromJson(Map<String, dynamic> json) {
    return ToolMessage(
      toolCallId: json['tool_call_id'] as String,
      content: json['content'] as String,
    );
  }

  /// The ID of the tool call this message is responding to.
  final String toolCallId;

  /// The content of the tool response (typically JSON).
  final String content;

  @override
  String get role => 'tool';

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'tool_call_id': toolCallId,
    'content': content,
  };

  /// Creates a copy with the given fields replaced.
  ToolMessage copyWith({String? toolCallId, String? content}) {
    return ToolMessage(
      toolCallId: toolCallId ?? this.toolCallId,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolMessage &&
          runtimeType == other.runtimeType &&
          toolCallId == other.toolCallId &&
          content == other.content;

  @override
  int get hashCode => Object.hash(toolCallId, content);

  @override
  String toString() =>
      'ChatMessage.tool(toolCallId: $toolCallId, content: $content)';
}
