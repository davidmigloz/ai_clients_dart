/// Confirmation status of a tool call in a conversation.
enum ConfirmationStatus {
  /// The tool call is awaiting confirmation.
  pending('pending'),

  /// The tool call was allowed.
  allowed('allowed'),

  /// The tool call was denied.
  denied('denied'),

  /// An unknown status not yet supported by this client.
  unknown('unknown');

  const ConfirmationStatus(this.value);

  /// The string value of this status.
  final String value;

  /// Creates a [ConfirmationStatus] from a JSON string value.
  factory ConfirmationStatus.fromJson(String json) {
    return ConfirmationStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ConfirmationStatus.unknown,
    );
  }

  /// Converts to JSON string.
  String toJson() => value;
}
