/// Processing status of a Message Batch.
enum ProcessingStatus {
  /// The batch is currently being processed.
  inProgress('in_progress'),

  /// The batch is being canceled.
  canceling('canceling'),

  /// The batch has finished processing.
  ended('ended');

  const ProcessingStatus(this.value);

  /// JSON value for the processing status.
  final String value;

  /// Converts a string to [ProcessingStatus].
  static ProcessingStatus fromJson(String value) => switch (value) {
    'in_progress' => ProcessingStatus.inProgress,
    'canceling' => ProcessingStatus.canceling,
    'ended' => ProcessingStatus.ended,
    _ => throw FormatException('Unknown ProcessingStatus: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}
