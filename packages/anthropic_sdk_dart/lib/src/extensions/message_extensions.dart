import '../models/content/content_block.dart';
import '../models/messages/message.dart';
import '../models/metadata/stop_reason.dart';

/// Extensions on [Message] for convenient access to content.
extension MessageExtensions on Message {
  /// Returns the concatenated text content of all text blocks.
  ///
  /// Returns an empty string if there are no text blocks.
  String get text {
    final buffer = StringBuffer();
    for (final block in content) {
      if (block is TextBlock) {
        buffer.write(block.text);
      }
    }
    return buffer.toString();
  }

  /// Returns all tool use blocks in the message.
  List<ToolUseBlock> get toolUseBlocks {
    return content.whereType<ToolUseBlock>().toList();
  }

  /// Returns true if the message contains any tool use blocks.
  bool get hasToolUse => content.any((block) => block is ToolUseBlock);

  /// Returns all thinking blocks in the message.
  List<ThinkingBlock> get thinkingBlocks {
    return content.whereType<ThinkingBlock>().toList();
  }

  /// Returns true if the message contains any thinking blocks.
  bool get hasThinking => content.any((block) => block is ThinkingBlock);

  /// Returns the concatenated thinking content.
  String get thinking {
    final buffer = StringBuffer();
    for (final block in content) {
      if (block is ThinkingBlock) {
        buffer.write(block.thinking);
      }
    }
    return buffer.toString();
  }

  /// Returns all text blocks in the message.
  List<TextBlock> get textBlocks {
    return content.whereType<TextBlock>().toList();
  }

  /// Returns true if the message stopped due to reaching max tokens.
  bool get isMaxTokens => stopReason == StopReason.maxTokens;

  /// Returns true if the message completed normally.
  bool get isEndTurn => stopReason == StopReason.endTurn;

  /// Returns true if the message stopped for tool use.
  bool get isToolUse => stopReason == StopReason.toolUse;
}
