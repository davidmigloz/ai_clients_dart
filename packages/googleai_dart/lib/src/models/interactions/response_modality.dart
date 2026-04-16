/// The modality of a response.
enum InteractionResponseModality {
  /// Text response modality.
  text,

  /// Image response modality.
  image,

  /// Audio response modality.
  audio,

  /// Video response modality.
  video,

  /// Document response modality.
  document,
}

/// Converts a string to [InteractionResponseModality].
InteractionResponseModality interactionResponseModalityFromString(
  String? value,
) {
  return switch (value) {
    'text' => InteractionResponseModality.text,
    'image' => InteractionResponseModality.image,
    'audio' => InteractionResponseModality.audio,
    'video' => InteractionResponseModality.video,
    'document' => InteractionResponseModality.document,
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
    InteractionResponseModality.video => 'video',
    InteractionResponseModality.document => 'document',
  };
}
