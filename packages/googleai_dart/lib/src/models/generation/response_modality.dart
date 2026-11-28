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

  /// Video modality, for example for a Vertex AI Live avatar.
  video,
}

/// Converts a string to a [ResponseModality] enum value.
ResponseModality responseModalityFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'TEXT' => ResponseModality.text,
    'IMAGE' => ResponseModality.image,
    'AUDIO' => ResponseModality.audio,
    'VIDEO' => ResponseModality.video,
    _ => ResponseModality.unspecified,
  };
}

/// Converts a [ResponseModality] enum value to a string.
String responseModalityToString(ResponseModality modality) {
  return switch (modality) {
    ResponseModality.text => 'TEXT',
    ResponseModality.image => 'IMAGE',
    ResponseModality.audio => 'AUDIO',
    ResponseModality.video => 'VIDEO',
    ResponseModality.unspecified => 'MODALITY_UNSPECIFIED',
  };
}
