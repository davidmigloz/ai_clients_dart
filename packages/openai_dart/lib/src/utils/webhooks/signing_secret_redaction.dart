import 'dart:convert';

import 'package:http/http.dart' as http;

/// Whether a malformed response can contain a newly revealed signing secret.
bool revealsWebhookSigningSecret(http.BaseRequest request) =>
    request.method == 'POST' &&
    (request.url.path.endsWith('/webhook_endpoints') ||
        (request.url.path.contains('/webhook_endpoints/') &&
            request.url.path.endsWith('/rotate_secret')));

/// Redacts signing-secret JSON properties before diagnostic truncation.
///
/// The caller's response/body is untouched. Other responses keep their original
/// formatting. Malformed secret-bearing responses are omitted from diagnostics.
String redactWebhookSigningSecretBody(
  String body, {
  bool secretBearingResponse = false,
}) {
  var found = false;
  try {
    final decoded = jsonDecode(body);
    if (secretBearingResponse && decoded is! Map<String, dynamic>) {
      return '[REDACTED webhook response body]';
    }
    final secrets = _signingSecrets(decoded);
    Object? redact(Object? value) {
      if (value is Map<String, dynamic>) {
        final result = <String, dynamic>{};
        for (final entry in value.entries) {
          if (entry.key == 'signing_secret') {
            found = true;
            result[entry.key] = '[REDACTED]';
          } else {
            result[entry.key] = redact(entry.value);
          }
        }
        return result;
      }
      if (value is List<dynamic>) return value.map(redact).toList();
      if (value is String) return _redactText(value, secrets);
      return value;
    }

    final redacted = redact(decoded);
    return found ? jsonEncode(redacted) : body;
  } on FormatException {
    return secretBearingResponse || body.contains('signing_secret')
        ? '[REDACTED webhook response body]'
        : body;
  } on JsonUnsupportedObjectError {
    return found || secretBearingResponse || body.contains('signing_secret')
        ? '[REDACTED webhook response body]'
        : body;
  }
}

/// Prevents a structured error from echoing its signing secret in diagnostics.
///
/// Raw exception body access remains unchanged. Only exact known secret values
/// discovered in signing_secret properties are replaced in diagnostic strings.
String? redactWebhookSecretErrorValue(String? text, Object? body) =>
    text == null ? null : _redactText(text, _signingSecrets(body));

List<String> _signingSecrets(Object? body) {
  final secrets = <String>{};
  final visited = Set<Object>.identity();
  void collect(Object? value) {
    if (value is Map<dynamic, dynamic>) {
      if (!visited.add(value)) return;
      for (final entry in value.entries) {
        if (entry.key == 'signing_secret' &&
            entry.value is String &&
            (entry.value as String).isNotEmpty) {
          secrets.add(entry.value as String);
        } else {
          collect(entry.value);
        }
      }
    } else if (value is List<dynamic>) {
      if (!visited.add(value)) return;
      value.forEach(collect);
    }
  }

  collect(body);
  return secrets.toList()..sort((a, b) => b.length.compareTo(a.length));
}

String _redactText(String text, List<String> secrets) {
  var result = text;
  for (final secret in secrets) {
    result = result.replaceAll(secret, '[REDACTED]');
  }
  return result;
}
