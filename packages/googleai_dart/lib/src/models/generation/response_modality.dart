/// The modality of the response.
enum ResponseModality {
  /// Unspecified modality.
  unspecified,

  /// Text modality.
  text,

  /// Image modality.
  image,

  /// Audio modality.
  audio,
}

/// Converts a string to a [ResponseModality] enum value.
ResponseModality responseModalityFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'TEXT' => ResponseModality.text,
    'IMAGE' => ResponseModality.image,
    'AUDIO' => ResponseModality.audio,
    _ => ResponseModality.unspecified,
  };
}

/// Converts a [ResponseModality] enum value to a string.
String responseModalityToString(ResponseModality modality) {
  return switch (modality) {
    ResponseModality.text => 'TEXT',
    ResponseModality.image => 'IMAGE',
    ResponseModality.audio => 'AUDIO',
    ResponseModality.unspecified => 'MODALITY_UNSPECIFIED',
  };
}
