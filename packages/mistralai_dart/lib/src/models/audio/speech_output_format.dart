/// Output audio format for speech synthesis.
///
/// Used with `SpeechRequest.responseFormat` to specify the desired
/// audio format of the generated speech.
enum SpeechOutputFormat {
  /// Raw PCM audio data.
  pcm('pcm'),

  /// WAV audio format.
  wav('wav'),

  /// MP3 audio format (default).
  mp3('mp3'),

  /// FLAC lossless audio format.
  flac('flac'),

  /// Opus audio format.
  opus('opus');

  const SpeechOutputFormat(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  ///
  /// Returns null if [value] is null or does not match any known value.
  static SpeechOutputFormat? fromString(String? value) {
    if (value == null) return null;
    for (final format in SpeechOutputFormat.values) {
      if (format.value == value) return format;
    }
    return null;
  }
}
