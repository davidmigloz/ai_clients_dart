/// How the model processes transcript text.
enum AudioTranscriptionConfigMode {
  /// Let the API choose the default mode.
  unspecified('MODE_UNSPECIFIED'),

  /// Transcribe the spoken words as heard.
  verbatim('VERBATIM'),

  /// Clean up, format, and edit the transcript based on speech.
  smart('SMART');

  const AudioTranscriptionConfigMode(this.value);

  /// The API wire value.
  final String value;

  /// Parses a wire value, returning `null` for unrecognized modes.
  static AudioTranscriptionConfigMode? fromJson(String json) {
    for (final mode in values) {
      if (mode.value == json) return mode;
    }
    return null;
  }

  /// Converts to the API wire value.
  String toJson() => value;
}
