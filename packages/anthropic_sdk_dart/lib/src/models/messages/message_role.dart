/// Role of a message in a conversation.
enum MessageRole {
  /// User message.
  user('user'),

  /// Assistant message.
  assistant('assistant'),

  /// System message (e.g. mid-conversation system instructions supplied inside
  /// the messages array).
  system('system');

  const MessageRole(this.value);

  /// JSON value for the message role.
  final String value;

  /// Converts a string to [MessageRole].
  static MessageRole fromJson(String value) => switch (value) {
    'user' => MessageRole.user,
    'assistant' => MessageRole.assistant,
    'system' => MessageRole.system,
    _ => throw FormatException('Unknown MessageRole: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}
