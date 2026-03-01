/// Stub implementation for unsupported platforms.
///
/// This should never be called in practice since either IO or web
/// implementations will be used.
String? getEnvironmentVariable(String key) {
  throw UnsupportedError(
    'Environment variables are not supported on this platform.',
  );
}
