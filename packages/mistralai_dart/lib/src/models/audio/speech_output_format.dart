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
  opus('opus'),

  /// Unknown format (forward compatibility).
  unknown('unknown');

  const SpeechOutputFormat(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a string value.
  ///
  /// Returns null if [value] is null.
  /// Returns [unknown] if [value] does not match any known value.
  static SpeechOutputFormat? fromString(String? value) => switch (value) {
    'pcm' => pcm,
    'wav' => wav,
    'mp3' => mp3,
    'flac' => flac,
    'opus' => opus,
    null => null,
    _ => unknown,
  };
}
