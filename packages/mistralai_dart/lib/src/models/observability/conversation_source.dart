/// Source of a conversation in a dataset.
enum ConversationSource {
  /// From the event explorer.
  explorer('EXPLORER'),

  /// From an uploaded file.
  uploadedFile('UPLOADED_FILE'),

  /// From direct input.
  directInput('DIRECT_INPUT'),

  /// From the playground.
  playground('PLAYGROUND'),

  /// Unknown source (forward-compatible fallback).
  unknown('UNKNOWN');

  const ConversationSource(this.value);

  /// The string value of this source.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [ConversationSource] from a JSON value.
  static ConversationSource fromJson(String? value) => fromString(value);

  /// Creates a [ConversationSource] from a string value.
  static ConversationSource fromString(String? value) {
    if (value == null) return ConversationSource.unknown;
    return ConversationSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConversationSource.unknown,
    );
  }
}
