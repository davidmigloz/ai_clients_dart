/// Redacts opaque Live credentials and their URI-encoded forms.
String redactLiveDiagnosticValues(String message, Set<String> values) {
  final secrets = values.where((value) => value.isNotEmpty).toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  var safe = message;
  for (final value in secrets) {
    safe = safe.replaceAll(value, '[redacted]');
    for (final encoded in {
      Uri.encodeComponent(value),
      Uri.encodeQueryComponent(value),
    }) {
      if (encoded == value) continue;
      safe = safe.replaceAll(
        RegExp(RegExp.escape(encoded), caseSensitive: false),
        '[redacted]',
      );
    }
  }
  return safe;
}
