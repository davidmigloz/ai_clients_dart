/// Lifecycle stage of a model.
enum ModelStage {
  /// Unspecified stage.
  modelStageUnspecified,

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

  /// Unknown stage.
  unknown,
}

/// Parses a [ModelStage] from its string representation.
ModelStage modelStageFromString(String? value) {
  return switch (value) {
    'MODEL_STAGE_UNSPECIFIED' => ModelStage.modelStageUnspecified,
    'UNSTABLE_EXPERIMENTAL' => ModelStage.unstableExperimental,
    'EXPERIMENTAL' => ModelStage.experimental,
    'PREVIEW' => ModelStage.preview,
    'STABLE' => ModelStage.stable,
    'LEGACY' => ModelStage.legacy,
    'DEPRECATED' => ModelStage.deprecated,
    'RETIRED' => ModelStage.retired,
    _ => ModelStage.unknown,
  };
}

/// Converts a [ModelStage] to its string representation.
String modelStageToString(ModelStage value) {
  return switch (value) {
    ModelStage.modelStageUnspecified => 'MODEL_STAGE_UNSPECIFIED',
    ModelStage.unstableExperimental => 'UNSTABLE_EXPERIMENTAL',
    ModelStage.experimental => 'EXPERIMENTAL',
    ModelStage.preview => 'PREVIEW',
    ModelStage.stable => 'STABLE',
    ModelStage.legacy => 'LEGACY',
    ModelStage.deprecated => 'DEPRECATED',
    ModelStage.retired => 'RETIRED',
    ModelStage.unknown => 'unknown',
  };
}
