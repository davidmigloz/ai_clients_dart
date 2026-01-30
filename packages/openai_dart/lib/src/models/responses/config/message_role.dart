/// The role of a message in a conversation.
enum MessageRole {
  /// Unknown role (fallback for unrecognized values).
  unknown('unknown'),

  /// User message.
  user('user'),

  /// System message.
  system('system'),

  /// Developer message.
  developer('developer'),

  /// Assistant message.
  assistant('assistant');

  /// The JSON value for this role.
  final String value;

  const MessageRole(this.value);

  /// Creates a [MessageRole] from a JSON value.
  factory MessageRole.fromJson(String json) {
    return MessageRole.values.firstWhere(
      (e) => e.value == json,
      orElse: () => MessageRole.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
