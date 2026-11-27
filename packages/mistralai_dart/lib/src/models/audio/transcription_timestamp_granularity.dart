/// Timestamp resolution for an offline transcription.
enum TranscriptionTimestampGranularity {
  /// Timestamps for complete segments. Supported by Voxtral 3.
  segment('segment'),

  /// Timestamps for individual words. Use with a model that supports them.
  word('word'),

  /// A value introduced by a newer API version.
  unknown('unknown');

  const TranscriptionTimestampGranularity(this.value);

  /// The API wire value.
  final String value;

  /// Decodes a supported timestamp granularity.
  static TranscriptionTimestampGranularity fromJson(String value) =>
      switch (value) {
        'segment' => segment,
        'word' => word,
        _ => unknown,
      };
}
