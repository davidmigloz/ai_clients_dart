/// The modality of a response.
enum InteractionResponseModality {
  /// Text response modality.
  text,

  /// Image response modality.
  image,

  /// Audio response modality.
  audio,

  /// Document response modality.
  document,

  /// Video response modality.
  video,
}

/// Converts a string to [InteractionResponseModality].
InteractionResponseModality interactionResponseModalityFromString(
  String? value,
) {
  return switch (value) {
    'text' => InteractionResponseModality.text,
    'image' => InteractionResponseModality.image,
    'audio' => InteractionResponseModality.audio,
    'document' => InteractionResponseModality.document,
    'video' => InteractionResponseModality.video,
    _ => InteractionResponseModality.text,
  };
}

/// Converts [InteractionResponseModality] to a string.
String interactionResponseModalityToString(
  InteractionResponseModality modality,
) {
  return switch (modality) {
    InteractionResponseModality.text => 'text',
    InteractionResponseModality.image => 'image',
    InteractionResponseModality.audio => 'audio',
    InteractionResponseModality.document => 'document',
    InteractionResponseModality.video => 'video',
  };
}
