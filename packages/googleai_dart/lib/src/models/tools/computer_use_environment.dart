/// The environment for computer use.
enum ComputerUseEnvironment {
  /// Unspecified environment.
  unspecified,

  /// Browser environment.
  browser,
}

/// Converts a string to a [ComputerUseEnvironment] enum value.
ComputerUseEnvironment computerUseEnvironmentFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'ENVIRONMENT_BROWSER' => ComputerUseEnvironment.browser,
    _ => ComputerUseEnvironment.unspecified,
  };
}

/// Converts a [ComputerUseEnvironment] enum value to a string.
String computerUseEnvironmentToString(ComputerUseEnvironment env) {
  return switch (env) {
    ComputerUseEnvironment.browser => 'ENVIRONMENT_BROWSER',
    ComputerUseEnvironment.unspecified => 'ENVIRONMENT_UNSPECIFIED',
  };
}
