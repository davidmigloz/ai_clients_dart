/// Stub implementation for unsupported platforms.
///
/// This should never be called in practice since either IO or web
/// implementations will be used.
DateTime parseHttpDate(String value) {
  throw UnsupportedError(
    'HTTP date parsing is not supported on this platform.',
  );
}

/// Stub implementation - returns false since socket exceptions
/// don't exist on platforms without dart:io.
bool isSocketException(Object error) => false;
