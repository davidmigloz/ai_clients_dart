import 'package:meta/meta.dart';

import '../beta/config/output_config.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../content/input_content_block.dart';
import 'message_role.dart';

/// How long a `role: "system"` message's text stays in front of the model.
///
/// Only permitted on `role: "system"` messages. Requires
/// `anthropic-beta: mid-conversation-system-clear-at-2026-08-21`.
///
/// A turn-scoped message is text-only (no `tool_addition`/`tool_removal`
/// blocks, no `output_config`, no `cache_control`) and must be re-sent
/// verbatim on later requests: a cleared message stays in `messages`,
/// renders nothing, and costs no input tokens. A user message carrying only
/// `tool_result` blocks counts as a user message.
enum SystemMessageClearAt {
  /// Renders this message only for the user turn it follows.
  ///
  /// Once a later `role: "user"` message exists in `messages`, this message
  /// stays in the array (send it unchanged) but is no longer shown to the
  /// model.
  nextUserMessage('next_user_message'),

  /// Renders this message on every request that includes it (the default).
  never('never');

  const SystemMessageClearAt(this.value);

  /// The wire value for this clear-at policy.
  final String value;

  /// Creates a [SystemMessageClearAt] from a JSON string.
  static SystemMessageClearAt fromJson(String json) => switch (json) {
    'next_user_message' => SystemMessageClearAt.nextUserMessage,
    'never' => SystemMessageClearAt.never,
    _ => throw FormatException('Unknown SystemMessageClearAt: $json'),
  };

  /// Converts to a JSON string.
  String toJson() => value;
}

/// Per-message output configuration on a `role: "system"` input message.
///
/// Applies from the next user turn on, and preserves the prompt cache.
/// Requires `anthropic-beta: mid-conversation-output-config-2026-07-01`.
/// Supported on Claude Fable 5.1, Mythos 5.1, and Opus 5. `format` remains
/// top-level only: it is not available here.
@immutable
class SystemMessageOutputConfig {
  /// How much effort the model should put into its response.
  ///
  /// Higher effort levels may result in more thorough analysis but take
  /// longer.
  final EffortLevel? effort;

  /// Creates a [SystemMessageOutputConfig].
  ///
  /// An empty configuration (all fields `null`) is valid on a message that
  /// carries content.
  const SystemMessageOutputConfig({this.effort});

  /// Creates a [SystemMessageOutputConfig] from JSON.
  factory SystemMessageOutputConfig.fromJson(Map<String, dynamic> json) {
    return SystemMessageOutputConfig(
      effort: json['effort'] != null
          ? EffortLevel.fromJson(json['effort'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort!.toJson(),
  };

  /// Creates a copy with replaced values.
  SystemMessageOutputConfig copyWith({Object? effort = unsetCopyWithValue}) {
    return SystemMessageOutputConfig(
      effort: effort == unsetCopyWithValue
          ? this.effort
          : effort as EffortLevel?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessageOutputConfig &&
          runtimeType == other.runtimeType &&
          effort == other.effort;

  @override
  int get hashCode => effort.hashCode;

  @override
  String toString() => 'SystemMessageOutputConfig(effort: $effort)';
}

/// Content for an input message.
///
/// Can be a simple string or a list of content blocks.
sealed class MessageContent {
  const MessageContent();

  /// Creates a text content.
  factory MessageContent.text(String text) = TextMessageContent;

  /// Creates a blocks content.
  factory MessageContent.blocks(List<InputContentBlock> blocks) =
      BlocksMessageContent;

  /// Creates a [MessageContent] from dynamic JSON value.
  factory MessageContent.fromJson(dynamic json) {
    if (json is String) {
      return TextMessageContent(json);
    }
    if (json is List) {
      return BlocksMessageContent(
        json
            .map((e) => InputContentBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid MessageContent: $json');
  }

  /// Converts to JSON.
  dynamic toJson();
}

/// Text content for a message.
@immutable
class TextMessageContent extends MessageContent {
  /// The text content.
  final String text;

  /// Creates a [TextMessageContent].
  const TextMessageContent(this.text);

  @override
  String toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessageContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextMessageContent(text: [${text.length} chars])';
}

/// Block content for a message.
@immutable
class BlocksMessageContent extends MessageContent {
  /// The content blocks.
  final List<InputContentBlock> blocks;

  /// Creates a [BlocksMessageContent].
  const BlocksMessageContent(this.blocks);

  @override
  List<Map<String, dynamic>> toJson() => blocks.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlocksMessageContent &&
          runtimeType == other.runtimeType &&
          listsEqual(blocks, other.blocks);

  @override
  int get hashCode => listHash(blocks);

  @override
  String toString() => 'BlocksMessageContent(blocks: $blocks)';
}

/// A message in the conversation input.
@immutable
class InputMessage {
  /// Role of the message author.
  final MessageRole role;

  /// Content of the message.
  final MessageContent content;

  /// How long this message's text stays in front of the model.
  ///
  /// Only permitted on `role: "system"` messages. Requires
  /// `anthropic-beta: mid-conversation-system-clear-at-2026-08-21`.
  final SystemMessageClearAt? clearAt;

  /// Per-message output configuration.
  ///
  /// Only permitted on `role: "system"` messages. Requires
  /// `anthropic-beta: mid-conversation-output-config-2026-07-01`.
  final SystemMessageOutputConfig? outputConfig;

  /// Creates an [InputMessage].
  const InputMessage({
    required this.role,
    required this.content,
    this.clearAt,
    this.outputConfig,
  });

  /// Creates a user message with text content.
  factory InputMessage.user(String text) =>
      InputMessage(role: MessageRole.user, content: MessageContent.text(text));

  /// Creates a user message with block content.
  factory InputMessage.userBlocks(List<InputContentBlock> blocks) =>
      InputMessage(
        role: MessageRole.user,
        content: MessageContent.blocks(blocks),
      );

  /// Creates an assistant message with text content.
  factory InputMessage.assistant(String text) => InputMessage(
    role: MessageRole.assistant,
    content: MessageContent.text(text),
  );

  /// Creates an assistant message with block content.
  factory InputMessage.assistantBlocks(List<InputContentBlock> blocks) =>
      InputMessage(
        role: MessageRole.assistant,
        content: MessageContent.blocks(blocks),
      );

  /// Creates a system message with text content.
  ///
  /// Lets you place system instructions inside the messages array (e.g.
  /// mid-conversation, with Claude Opus 4.8 and later) instead of only the
  /// top-level `system` prompt.
  ///
  /// A content-carrying system message must follow a user turn or a
  /// `tool_result` turn, and precede an assistant turn. Pass [clearAt] to
  /// make the message turn-scoped (requires
  /// `anthropic-beta: mid-conversation-system-clear-at-2026-08-21`).
  factory InputMessage.system(String text, {SystemMessageClearAt? clearAt}) =>
      InputMessage(
        role: MessageRole.system,
        content: MessageContent.text(text),
        clearAt: clearAt,
      );

  /// Creates a system message with block content.
  ///
  /// See [InputMessage.system] for placement rules.
  factory InputMessage.systemBlocks(
    List<InputContentBlock> blocks, {
    SystemMessageClearAt? clearAt,
  }) => InputMessage(
    role: MessageRole.system,
    content: MessageContent.blocks(blocks),
    clearAt: clearAt,
  );

  /// Creates an effort-only system message.
  ///
  /// Sets [EffortLevel] for the response from the next user turn on,
  /// without carrying any content. Unlike a content-carrying system
  /// message, an effort-only message is accepted anywhere in `messages`.
  /// Requires `anthropic-beta: mid-conversation-output-config-2026-07-01`.
  factory InputMessage.systemEffort(EffortLevel effort) => InputMessage(
    role: MessageRole.system,
    content: MessageContent.blocks(const []),
    outputConfig: SystemMessageOutputConfig(effort: effort),
  );

  /// Returns the content as a list of [InputContentBlock]s.
  ///
  /// For [TextMessageContent], wraps the text in a single [TextInputBlock].
  /// For [BlocksMessageContent], returns the blocks directly.
  List<InputContentBlock> get blocks => switch (content) {
    TextMessageContent(:final text) => [TextInputBlock(text)],
    BlocksMessageContent(:final blocks) => blocks,
  };

  /// Creates an [InputMessage] from JSON.
  factory InputMessage.fromJson(Map<String, dynamic> json) {
    return InputMessage(
      role: MessageRole.fromJson(json['role'] as String),
      content: MessageContent.fromJson(json['content']),
      clearAt: json['clear_at'] != null
          ? SystemMessageClearAt.fromJson(json['clear_at'] as String)
          : null,
      outputConfig: json['output_config'] != null
          ? SystemMessageOutputConfig.fromJson(
              json['output_config'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'role': role.toJson(),
    'content': content.toJson(),
    if (clearAt != null) 'clear_at': clearAt!.toJson(),
    if (outputConfig != null) 'output_config': outputConfig!.toJson(),
  };

  /// Creates a copy with replaced values.
  InputMessage copyWith({
    MessageRole? role,
    MessageContent? content,
    Object? clearAt = unsetCopyWithValue,
    Object? outputConfig = unsetCopyWithValue,
  }) {
    return InputMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      clearAt: clearAt == unsetCopyWithValue
          ? this.clearAt
          : clearAt as SystemMessageClearAt?,
      outputConfig: outputConfig == unsetCopyWithValue
          ? this.outputConfig
          : outputConfig as SystemMessageOutputConfig?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputMessage &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content &&
          clearAt == other.clearAt &&
          outputConfig == other.outputConfig;

  @override
  int get hashCode => Object.hash(role, content, clearAt, outputConfig);

  @override
  String toString() =>
      'InputMessage(role: $role, content: $content, clearAt: $clearAt, '
      'outputConfig: $outputConfig)';
}
