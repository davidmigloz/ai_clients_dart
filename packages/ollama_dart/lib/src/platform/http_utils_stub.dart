/// Stub implementation for unsupported platforms.
///
/// This should never be called in practice since either IO or web
/// implementations will be used.
DateTime parseHttpDate(String value) {
  throw UnsupportedError(
    'HTTP date parsing is not supported on this platform.',
  );
}

/// Stub implementation - should never be called.
bool isSocketException(Object error) {
  throw UnsupportedError(
    'Socket exception checking is not supported on this platform.',
  );
}
