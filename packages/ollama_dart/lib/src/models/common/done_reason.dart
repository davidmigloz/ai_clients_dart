/// Reason why generation stopped.
enum DoneReason {
  /// Generation completed naturally.
  stop,

  /// Generation stopped due to length limits.
  length,

  /// Model is being loaded.
  load,

  /// Model is being unloaded.
  unload,
}

/// Converts string to [DoneReason] enum.
///
/// Returns `null` for unknown or null values.
DoneReason? doneReasonFromString(String? value) {
  return switch (value) {
    'stop' => DoneReason.stop,
    'length' => DoneReason.length,
    'load' => DoneReason.load,
    'unload' => DoneReason.unload,
    _ => null,
  };
}

/// Converts [DoneReason] enum to string.
String doneReasonToString(DoneReason value) {
  return switch (value) {
    DoneReason.stop => 'stop',
    DoneReason.length => 'length',
    DoneReason.load => 'load',
    DoneReason.unload => 'unload',
  };
}
