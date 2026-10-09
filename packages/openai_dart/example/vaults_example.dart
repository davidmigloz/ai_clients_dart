// ignore_for_file: avoid_print
// Run: dart run example/vaults_example.dart
// All ten operations use mock HTTP, synthetic values and no API key ($0).
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var requests = 0;
  var vault = <String, dynamic>{
    'id': 'vault_demo',
    'object': 'vault',
    'name': null,
    'metadata': <String, String>{},
    'created_at': 1,
  };
  Map<String, dynamic>? credential;
  final transport = MockClient((request) async {
    requests++;
    final path = request.url.pathSegments;
    final isCredentials = path.contains('credentials');
    final isCollection =
        path.last == (isCredentials ? 'credentials' : 'vaults');
    final body = request.bodyBytes.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
    Object wire;
    var status = 200;
    if (request.method == 'DELETE') {
      wire = {
        'id': isCredentials ? 'credential_demo' : 'vault_demo',
        'object': isCredentials ? 'vault.credential.deleted' : 'vault.deleted',
        'deleted': true,
      };
    } else if (request.method == 'POST') {
      if (isCredentials) {
        if (isCollection) {
          status = 201;
          final auth = body['auth'] as Map<String, dynamic>;
          // The returned representation contains no secret_value field.
          credential = {
            'id': 'credential_demo',
            'object': 'vault.credential',
            'vault_id': 'vault_demo',
            'name': body['name'],
            'metadata': body['metadata'] ?? <String, String>{},
            'auth': {
              'type': auth['type'],
              'secret_name': auth['secret_name'],
              'networking': auth['networking'],
            },
            'created_at': 1,
            'updated_at': 1,
          };
        } else {
          credential = {
            ...credential!,
            if (body.containsKey('metadata')) 'metadata': body['metadata'],
            'updated_at': 2,
          };
        }
        wire = credential!;
      } else {
        if (isCollection) status = 201;
        vault = {...vault, ...body};
        wire = vault;
      }
    } else if (isCollection) {
      final resource = isCredentials ? credential! : vault;
      wire = {
        'object': 'list',
        'data': [resource],
        'first_id': resource['id'],
        'last_id': resource['id'],
        'has_more': false,
      };
    } else {
      wire = isCredentials ? credential! : vault;
    }
    return http.Response.bytes(
      utf8.encode(jsonEncode(wire)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
  final client = OpenAIClient.withApiKey(
    'synthetic-offline',
    httpClient: transport,
  );
  try {
    final vault = await client.vaults.create(
      CreateVaultRequest(
        name: 'Example Vault',
        metadata: const {'application': 'demo'},
      ),
    );
    final credential = await client.vaults.credentials.create(
      vault.id,
      CreateVaultCredentialRequest(
        name: 'Example hosted API key',
        auth: CreateVaultEnvironmentVariableAuth(
          secretName: 'SERVICE_API_KEY',
          secretValue: 'synthetic-write-only-value',
          networking: VaultCredentialNetworking.limited(
            allowedHosts: const ['api.example.com'],
          ),
        ),
      ),
    );
    await client.vaults.retrieve(vault.id);
    await client.vaults.list(
      metadata: {'application': 'demo'},
      status: VaultStatusFilter.multiple(const [
        VaultStatus.active,
        VaultStatus.archived,
      ]),
    );
    await client.vaults.update(
      vault.id,
      UpdateVaultRequest(metadata: const {}),
    );
    final safe = await client.vaults.credentials.retrieve(
      vault.id,
      credential.id,
    );
    final page = await client.vaults.credentials.list(vault.id, limit: 20);
    print(
      'Safe auth kind: ${safe.auth.type}; ${page.data.length} credential metadata record.',
    );
    await client.vaults.credentials.rotate(
      vault.id,
      credential.id,
      RotateVaultCredentialRequest(
        auth: RotateVaultEnvironmentVariableAuth(
          secretValue: 'synthetic-replacement-value',
        ),
        metadata: const {},
      ),
    );
    // Rotation preserves secret_name/networking; it does not promise immediate
    // replacement inside an existing sandbox. Attach the vault to NEW sessions
    // or environments. Sandbox code receives a placeholder, never this value.
    // Proxy substitution applies to permitted hosted HTTPS requests on 443/8443;
    // environment network policy must also permit the destination. Credential
    // networking unrestricted requires restricted environment access with
    // explicit allowed_domains. Local computation/self-hosted/function tools
    // cannot retrieve the real secret through this placeholder mechanism.
    await client.vaults.credentials.delete(vault.id, credential.id);
    await client.vaults.delete(vault.id);
    // Provider OAuth consent/revocation stays caller-owned. Record deletion
    // does not revoke provider tokens or cancel any running session.
    if (requests != 10) throw StateError('Expected all ten mock operations');
    print('Vault lifecycle complete: $requests mock requests; cost \$0.');
  } finally {
    client.close();
    transport.close();
  }
}
