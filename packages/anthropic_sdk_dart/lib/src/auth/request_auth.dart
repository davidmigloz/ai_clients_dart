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
Set<String> requestCredentialValues(Map<String, String> headers) {
  final authorization = headers['authorization']?.trim();
  final apiKey = headers['x-api-key']?.trim();
  final credentials = <String>{
    if (authorization != null && authorization.isNotEmpty) authorization,
    if (apiKey != null && apiKey.isNotEmpty) apiKey,
  };
  if (authorization != null &&
      authorization.toLowerCase().startsWith('bearer ')) {
    final token = authorization.substring(7).trim();
    if (token.isNotEmpty) credentials.add(token);
  }
  return credentials;
}

void _checkWorkspace(Map<String, String> headers) {
  if (headers.containsKey('anthropic-workspace-id')) {
    throw ArgumentError(
      'Workload identity tokens use the workspace selected at exchange.',
    );
  }
}
