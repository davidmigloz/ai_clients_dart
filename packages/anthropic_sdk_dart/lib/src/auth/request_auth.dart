import 'auth_provider.dart';
import 'workload_identity.dart';

/// Adds provider credentials without overwriting explicit auth headers.
Future<Map<String, String>> resolveCredentialHeaders(
  Map<String, String> headers,
  AuthProvider provider,
) async {
  final override =
      headers.containsKey('authorization') || headers.containsKey('x-api-key');
  if (provider is WorkloadIdentityAuthProvider) {
    if (override) return const {};
    _checkWorkspace(headers);
  }
  switch (await provider.getCredentials()) {
    case ApiKeyCredentials(:final apiKey):
      return {if (!headers.containsKey('x-api-key')) 'x-api-key': apiKey};
    case BearerTokenCredentials(:final token, :final workspaceScoped):
      if (override) return const {};
      if (workspaceScoped) _checkWorkspace(headers);
      final betas = [
        for (final flag in (headers['anthropic-beta'] ?? '').split(','))
          if (flag.trim().isNotEmpty) flag.trim(),
      ];
      if (!betas.contains(oauthBetaHeader)) betas.add(oauthBetaHeader);
      return {
        'authorization': 'Bearer $token',
        'anthropic-beta': betas.join(','),
      };
    case NoAuthCredentials():
      return const {};
  }
}

/// Values that must stay out of diagnostics for the effective request.
///
/// A cloud transport can attach the request it actually sent to the response.
/// Its credential headers are applied after the ordinary client interceptors.
Set<String> requestCredentialValues(
  Map<String, String> headers, {
  Map<String, String>? sentHeaders,
}) {
  final values = <String>{};
  for (final source in [headers, ?sentHeaders]) {
    for (final entry in source.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      if (const {
        'authorization',
        'x-api-key',
        'api-key',
        'x-amz-security-token',
      }.contains(key)) {
        values.add(value);
      }
      if (key != 'authorization') continue;
      final lower = value.toLowerCase();
      if (lower.startsWith('bearer ')) {
        final token = value.substring(7).trim();
        if (token.isNotEmpty) values.add(token);
      } else if (lower.startsWith('aws4-hmac-sha256 ')) {
        final signature = _awsSignature.firstMatch(value)?.group(1);
        if (signature != null) values.add(signature);
      }
    }
  }
  return values;
}

final _awsSignature = RegExp(r'\bSignature=([a-fA-F0-9]{64})\b');

void _checkWorkspace(Map<String, String> headers) {
  if (headers.containsKey('anthropic-workspace-id')) {
    throw ArgumentError(
      'Workload identity tokens use the workspace selected at exchange.',
    );
  }
}
