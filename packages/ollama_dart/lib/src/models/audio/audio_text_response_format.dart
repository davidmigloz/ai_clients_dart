/// Response formats supported by Ollama audio transcription and translation.
enum AudioTextResponseFormat {
  /// JSON containing the transcribed text (the server default).
  json('json'),

  /// Plain UTF-8 text.
  text('text'),

  /// JSON containing text, duration, language, and clip-level segments.
  verboseJson('verbose_json'),

  /// An unrecognized format. Sending this value lets the server reject it.
  unknown('unknown');

  /// The API value.
  final String value;

  const AudioTextResponseFormat(this.value);

  /// Parses an API value.
  static AudioTextResponseFormat fromJson(String value) => values.firstWhere(
    (format) => format.value == value,
    orElse: () => unknown,
  );

  /// Converts to the API value.
  String toJson() => value;
}
