/// The resolution of media content in interactions.
enum InteractionMediaResolution {
  /// Low resolution.
  low,

  /// Medium resolution.
  medium,

  /// High resolution.
  high,

  /// Ultra high resolution.
  ultraHigh,
}

/// Converts a string to [InteractionMediaResolution].
InteractionMediaResolution interactionMediaResolutionFromString(String? value) {
  return switch (value) {
    'low' => InteractionMediaResolution.low,
    'medium' => InteractionMediaResolution.medium,
    'high' => InteractionMediaResolution.high,
    'ultra_high' => InteractionMediaResolution.ultraHigh,
    _ => InteractionMediaResolution.low,
  };
}

/// Converts [InteractionMediaResolution] to a string.
String interactionMediaResolutionToString(
  InteractionMediaResolution resolution,
) {
  return switch (resolution) {
    InteractionMediaResolution.low => 'low',
    InteractionMediaResolution.medium => 'medium',
    InteractionMediaResolution.high => 'high',
    InteractionMediaResolution.ultraHigh => 'ultra_high',
  };
}
