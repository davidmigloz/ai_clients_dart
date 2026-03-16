/// The mode of the predictor to be used in dynamic retrieval.
enum DynamicRetrievalMode {
  /// Always trigger retrieval.
  unspecified,

  /// Run retrieval only when system decides it is necessary.
  // ignore: constant_identifier_names
  dynamic_,
}

/// Converts a string to a [DynamicRetrievalMode] enum value.
DynamicRetrievalMode dynamicRetrievalModeFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'MODE_DYNAMIC' => DynamicRetrievalMode.dynamic_,
    _ => DynamicRetrievalMode.unspecified,
  };
}

/// Converts a [DynamicRetrievalMode] enum value to a string.
String dynamicRetrievalModeToString(DynamicRetrievalMode mode) {
  return switch (mode) {
    DynamicRetrievalMode.dynamic_ => 'MODE_DYNAMIC',
    DynamicRetrievalMode.unspecified => 'MODE_UNSPECIFIED',
  };
}
