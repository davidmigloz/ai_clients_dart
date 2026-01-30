import 'package:meta/meta.dart';

/// The role of a message in a conversation.
///
/// Extends the standard roles (user, assistant, system, developer) with
/// additional conversation-specific roles.
@immutable
class ConversationRole {
  /// The role value.
  final String value;

  const ConversationRole._(this.value);

  /// A user message.
  static const user = ConversationRole._('user');

  /// An assistant message.
  static const assistant = ConversationRole._('assistant');

  /// A system message.
  static const system = ConversationRole._('system');

  /// A developer message.
  static const developer = ConversationRole._('developer');

  /// A tool message.
  static const tool = ConversationRole._('tool');

  /// An unknown role (for forward compatibility).
  static const unknown = ConversationRole._('unknown');

  /// A critic role (used in certain evaluation contexts).
  static const critic = ConversationRole._('critic');

  /// A discriminator role (used in certain evaluation contexts).
  static const discriminator = ConversationRole._('discriminator');

  /// Creates a [ConversationRole] from a JSON string.
  factory ConversationRole.fromJson(String json) {
    return switch (json) {
      'user' => user,
      'assistant' => assistant,
      'system' => system,
      'developer' => developer,
      'tool' => tool,
      'unknown' => unknown,
      'critic' => critic,
      'discriminator' => discriminator,
      _ => ConversationRole._(json),
    };
  }

  /// Converts this role to JSON.
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationRole &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ConversationRole($value)';
}
