/// The environment for computer use.
enum ComputerUseEnvironment {
  /// Unspecified environment.
  unspecified,

  /// Browser environment.
  browser,

  /// Mobile environment.
  mobile,

  /// Desktop environment.
  desktop,
}

/// Converts a string to a [ComputerUseEnvironment] enum value.
ComputerUseEnvironment computerUseEnvironmentFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'ENVIRONMENT_BROWSER' => ComputerUseEnvironment.browser,
    'ENVIRONMENT_MOBILE' => ComputerUseEnvironment.mobile,
    'ENVIRONMENT_DESKTOP' => ComputerUseEnvironment.desktop,
    _ => ComputerUseEnvironment.unspecified,
  };
}

/// Converts a [ComputerUseEnvironment] enum value to a string.
String computerUseEnvironmentToString(ComputerUseEnvironment env) {
  return switch (env) {
    ComputerUseEnvironment.browser => 'ENVIRONMENT_BROWSER',
    ComputerUseEnvironment.mobile => 'ENVIRONMENT_MOBILE',
    ComputerUseEnvironment.desktop => 'ENVIRONMENT_DESKTOP',
    ComputerUseEnvironment.unspecified => 'ENVIRONMENT_UNSPECIFIED',
  };
}
