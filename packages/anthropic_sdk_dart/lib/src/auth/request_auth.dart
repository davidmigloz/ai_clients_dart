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

void _checkWorkspace(Map<String, String> headers) {
  if (headers.containsKey('anthropic-workspace-id')) {
    throw ArgumentError(
      'Workload identity tokens use the workspace selected at exchange.',
    );
  }
}
