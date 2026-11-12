import 'package:http/http.dart' as http;

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
      if (lower.startsWith('bearer ') || lower.startsWith('basic ')) {
        final token = value.substring(value.indexOf(' ') + 1).trim();
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

// Transport-only metadata. Body credentials never become HTTP headers.
final _requestDiagnosticCredentials = Expando<Set<String>>();
final _responseDiagnosticCredentials = Expando<Set<String>>();
final _requestCredentialObservers = Expando<void Function(Set<String>)>();

/// Credentials supplied in the request body and withheld from diagnostics.
Set<String> requestDiagnosticCredentials(http.BaseRequest request) =>
    _requestDiagnosticCredentials[request] ?? const {};

/// Keeps diagnostic credentials with this request through local copies.
T withRequestDiagnosticCredentials<T extends http.BaseRequest>(
  T request,
  Set<String> credentials,
) {
  if (credentials.isNotEmpty) {
    _requestDiagnosticCredentials[request] = credentials;
  }
  return request;
}

/// Attaches a logical request's credential observer to one transport attempt.
T withRequestCredentialObserver<T extends http.BaseRequest>(
  T request,
  void Function(Set<String>)? observe,
) {
  if (observe != null) _requestCredentialObservers[request] = observe;
  return request;
}

/// Returns the observer to carry through redirects and provider adaptation.
void Function(Set<String>)? requestCredentialObserver(
  http.BaseRequest request,
) => _requestCredentialObservers[request];

/// Combines credentials observed at dispatch with optional response metadata.
Set<String> responseCredentialValues(http.BaseResponse response) => {
  ...?_responseDiagnosticCredentials[response],
  if (response.request case final request?) ...{
    ...requestCredentialValues(request.headers),
    ...requestDiagnosticCredentials(request),
  },
};

/// Records effective credentials while retaining the transport's response.
T withResponseDiagnosticCredentials<T extends http.BaseResponse>(
  T response,
  Set<String> credentials,
) {
  if (credentials.isNotEmpty) {
    _responseDiagnosticCredentials[response] = {
      ...?_responseDiagnosticCredentials[response],
      ...credentials,
    };
  }
  return response;
}

void _checkWorkspace(Map<String, String> headers) {
  if (headers.containsKey('anthropic-workspace-id')) {
    throw ArgumentError(
      'Workload identity tokens use the workspace selected at exchange.',
    );
  }
}
