/// Audio formats supported by Ollama speech models.
enum SpeechResponseFormat {
  /// WAV containing 16-bit little-endian mono samples at 24 kHz.
  wav,

  /// Raw 16-bit little-endian mono samples at 24 kHz, without a header.
  pcm,

  /// An unrecognized format. Sending this value lets the server reject it.
  unknown;

  /// Parses a wire-format value.
  static SpeechResponseFormat fromJson(String value) => values.firstWhere(
    (format) => format.name == value,
    orElse: () => unknown,
  );

  /// Converts to the wire-format value.
  String toJson() => name;
}
