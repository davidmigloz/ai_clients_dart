/// Role of a message in a conversation.
enum MessageRole {
  /// User message.
  user('user'),

  /// Assistant message.
  assistant('assistant');

  const MessageRole(this.value);

  /// JSON value for the message role.
  final String value;

  /// Converts a string to [MessageRole].
  static MessageRole fromJson(String value) => switch (value) {
    'user' => MessageRole.user,
    'assistant' => MessageRole.assistant,
    _ => throw FormatException('Unknown MessageRole: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}
