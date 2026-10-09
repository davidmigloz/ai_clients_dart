part of 'vault_models.dart';

void _validateVaultName(String value, String context) {
  final length = utf8.encode(value.trim()).length;
  if (length < 1 || length > 256) {
    throw FormatException(
      '$context: expected 1–256 UTF-8 bytes after trimming',
    );
  }
}

void _validateVaultSecretValue(String value, String context) {
  if (value.isEmpty || value.contains(RegExp(r'[\r\n\x00]'))) {
    throw FormatException('$context: expected a nonempty single-line secret');
  }
}

void _validateVaultSecretName(String value, String context) {
  final match = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').firstMatch(value);
  final upper = value.toUpperCase();
  if (match == null ||
      match.end != value.length ||
      value.startsWith('CODEX_') ||
      const {
        'HTTP_PROXY',
        'HTTPS_PROXY',
        'ALL_PROXY',
        'NO_PROXY',
        'SSL_CERT_FILE',
        'SSL_CERT_DIR',
        'REQUESTS_CA_BUNDLE',
        'CURL_CA_BUNDLE',
      }.contains(upper)) {
    throw FormatException('$context: invalid or reserved secret name');
  }
}

void _validateVaultHosts(List<String> hosts, String context) {
  final normalized = <String>{};
  for (final host in hosts) {
    final name = host.toLowerCase();
    final match = RegExp(
      r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)*\.?$',
    ).firstMatch(name);
    if (match == null || match.end != name.length || !normalized.add(name)) {
      throw FormatException('$context: expected distinct hostnames or IPv4');
    }
    if (RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$').hasMatch(name) &&
        name
            .split('.')
            .any((part) => part.length > 3 || int.parse(part) > 255)) {
      throw FormatException('$context: expected valid IPv4 octets');
    }
  }
}

const _vaultReadbackKeys = {
  'token',
  'access_token',
  'refresh_token',
  'client_secret',
  'secret_value',
};

void _rejectVaultReadbackKeys(Map<String, dynamic> json, String context) {
  if (json.keys.any(_vaultReadbackKeys.contains)) {
    throw FormatException(
      '$context: write-only fields are not returned metadata',
    );
  }
}

Map<String, dynamic> _vaultReceivedExtras(
  Map<String, dynamic> json,
  List<String> knownKeys,
  String context,
) {
  _rejectVaultReadbackKeys(json, context);
  return agentExtras(json, knownKeys, context);
}
