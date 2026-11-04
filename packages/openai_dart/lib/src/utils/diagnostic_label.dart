/// Internal identity labels for request-scoped private automatic diagnostics.
///
/// Explicit payload/cause access is unchanged. Labels never enter headers or
/// JSON, and remain sticky if an application reuses an exception instance.
final Expando<bool> _privateDiagnostics = Expando<bool>();

/// Marks an exception or response without changing its class or payload.
T markPrivateDiagnostics<T extends Object>(T value) {
  _privateDiagnostics[value] = true;
  return value;
}

/// Whether an exception was handled in a private request scope.
bool hasPrivateDiagnostics(Object value) => _privateDiagnostics[value] ?? false;
