/// Lifecycle stage of a model.
enum ModelStage {
  /// Unspecified stage.
  unspecified,

  /// Unstable experimental stage.
  unstableExperimental,

  /// Experimental stage.
  experimental,

  /// Preview stage.
  preview,

  /// Stable stage.
  stable,

  /// Legacy stage.
  legacy,

  /// Deprecated stage.
  deprecated,

  /// Retired stage.
  retired,
}

/// Parses a [ModelStage] from its string representation.
///
/// Unrecognized values map to [ModelStage.unspecified].
ModelStage modelStageFromString(String? value) {
  final normalized = value?.toUpperCase();
  return switch (normalized) {
    'MODEL_STAGE_UNSPECIFIED' => ModelStage.unspecified,
    'UNSTABLE_EXPERIMENTAL' => ModelStage.unstableExperimental,
    'EXPERIMENTAL' => ModelStage.experimental,
    'PREVIEW' => ModelStage.preview,
    'STABLE' => ModelStage.stable,
    'LEGACY' => ModelStage.legacy,
    'DEPRECATED' => ModelStage.deprecated,
    'RETIRED' => ModelStage.retired,
    _ => ModelStage.unspecified,
  };
}

/// Converts a [ModelStage] to its string representation.
String modelStageToString(ModelStage value) {
  return switch (value) {
    ModelStage.unspecified => 'MODEL_STAGE_UNSPECIFIED',
    ModelStage.unstableExperimental => 'UNSTABLE_EXPERIMENTAL',
    ModelStage.experimental => 'EXPERIMENTAL',
    ModelStage.preview => 'PREVIEW',
    ModelStage.stable => 'STABLE',
    ModelStage.legacy => 'LEGACY',
    ModelStage.deprecated => 'DEPRECATED',
    ModelStage.retired => 'RETIRED',
  };
}
