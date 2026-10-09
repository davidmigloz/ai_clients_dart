import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../../fixtures/vault_wire_fixtures.dart';

Map<String, dynamic> _wire(String schema) => Map<String, dynamic>.from(
  vaultWireFixtures.singleWhere((value) => value.schema == schema).full! as Map,
);
final TypeMatcher<FormatException> _privateFormat = isA<FormatException>()
    .having(
      (value) => value.toString(),
      'private error',
      isNot(contains('PRIVATE')),
    );

void main() {
  test(
    'name bounds use trimmed UTF-8 bytes without changing the wire spelling',
    () {
      for (final name in [' x ', 'é' * 128, '🚀' * 64]) {
        final value = CreateVaultRequest(name: name);
        expect(value.toJson()['name'], name);
        expect(value.copyWith().name, name);
      }
      for (final name in ['', ' \t\n ', 'é' * 129, '🚀' * 65, 'a' * 257]) {
        expect(() => CreateVaultRequest(name: name), throwsA(_privateFormat));
        expect(
          () => UpdateVaultRequest.fromJson({'name': name}),
          throwsA(_privateFormat),
        );
        expect(
          () => CreateVaultCredentialRequest(
            name: name,
            auth: CreateVaultStaticBearerAuth(mcpServerUrl: '', token: ''),
          ),
          throwsA(_privateFormat),
        );
      }
      expect(CreateVaultRequest().toJson(), isEmpty);
      expect(UpdateVaultRequest().toJson(), isEmpty);
      expect(UpdateVaultRequest(clearName: true).toJson(), {'name': null});
      expect(
        () => CreateVaultRequest.fromJson(const {'name': null}),
        throwsFormatException,
      );
    },
  );

  test('create-vault metadata keeps its larger nullable contract', () {
    final large = {for (var i = 0; i < 1024; i++) 'k$i': 'v'};
    final value = CreateVaultRequest(metadata: large);
    large['k0'] = 'changed';
    expect(value.metadata!['k0'], 'v');
    expect(() => value.metadata!['new'] = 'v', throwsUnsupportedError);
    expect(
      () => value.copyWith(metadata: {...value.metadata!, 'new': 'v'}),
      throwsFormatException,
    );
    expect(
      CreateVaultRequest(metadata: {'k' * 256: '🚀' * 1024}).metadata,
      isNotNull,
    );
    expect(
      () => CreateVaultRequest(metadata: {'k' * 257: 'PRIVATE'}),
      throwsA(_privateFormat),
    );
    expect(CreateVaultRequest(clearMetadata: true).toJson(), {
      'metadata': null,
    });
    expect(
      () => UpdateVaultRequest(metadata: value.metadata),
      throwsFormatException,
    );
    for (final wire in [
      {'metadata': null},
      {
        'metadata': {'': 'v'},
      },
      {
        'metadata': {'k' * 65: 'PRIVATE'},
      },
      {
        'metadata': {'key': 'v' * 513},
      },
    ]) {
      expect(() => UpdateVaultRequest.fromJson(wire), throwsA(_privateFormat));
    }
    expect(UpdateVaultRequest(metadata: const {}).toJson(), {
      'metadata': <String, String>{},
    });
    // Received metadata has no request maxima; empty labels remain valid.
    final received = Vault.fromJson({
      ..._wire('VaultResource'),
      'metadata': {'': 'v' * 2048, for (var i = 0; i < 1025; i++) 'k$i': 'v'},
    });
    expect(received.metadata.length, 1026);
  });

  test(
    'rotation requires auth or metadata; null cannot clear optional-nonnull maps',
    () {
      expect(RotateVaultCredentialRequest.new, throwsFormatException);
      expect(
        () => RotateVaultCredentialRequest.fromJson(const {}),
        throwsFormatException,
      );
      expect(
        () => RotateVaultCredentialRequest.fromJson(const {'metadata': null}),
        throwsFormatException,
      );
      expect(
        () => RotateVaultCredentialRequest.fromJson(const {'auth': null}),
        throwsFormatException,
      );
      expect(RotateVaultCredentialRequest(metadata: const {}).toJson(), {
        'metadata': <String, String>{},
      });
      expect(
        RotateVaultCredentialRequest(auth: RotateVaultMcpOauthAuth()).toJson(),
        {
          'auth': {'type': 'mcp_oauth'},
        },
      );
    },
  );

  test(
    'OAuth expiry and refresh tri-state are transmitted for service semantics',
    () {
      final auth = RotateVaultMcpOauthAuth(accessToken: 'PRIVATE-new');
      expect(auth.toJson(), {
        'type': 'mcp_oauth',
        'access_token': 'PRIVATE-new',
      });
      final expired = auth.copyWith(clearExpiresAt: true);
      expect(expired.toJson()['expires_at'], isNull);
      expect(expired.toJson().containsKey('expires_at'), isTrue);
      final refresh = RotateVaultMcpOauthRefresh(
        clearRefreshToken: true,
        clearScope: true,
        tokenEndpointAuth: RotateVaultTokenEndpointClientSecretBasic(
          clearClientSecret: true,
        ),
      );
      expect(refresh.toJson(), {
        'refresh_token': null,
        'scope': null,
        'token_endpoint_auth': {
          'type': 'client_secret_basic',
          'client_secret': null,
        },
      });
      expect(refresh.copyWith().toJson(), refresh.toJson());
      expect(refresh.copyWith(scope: 'read').toJson()['scope'], 'read');
      expect(
        refresh
            .copyWith(scope: null, clearScope: false)
            .toJson()
            .containsKey('scope'),
        isFalse,
      );
      // No token trimming, timestamp parsing or environment-secret rules here.
      final source = CreateVaultMcpOauthAuth(
        mcpServerUrl: '',
        accessToken: '',
        expiresAt: 'literal-expiry',
      );
      expect(source.toJson()['expires_at'], 'literal-expiry');
      expect(
        CreateVaultStaticBearerAuth(
          mcpServerUrl: '',
          token: '\r\n\u0000',
        ).token,
        '\r\n\u0000',
      );
    },
  );

  for (final value in ['', 'PRIVATE\n', 'PRIVATE\r', 'PRIVATE\u0000']) {
    test(
      'environment secret rejects empty/line/NUL input privately ${value.length}',
      () {
        expect(
          () => CreateVaultEnvironmentVariableAuth(
            secretName: 'SERVICE_KEY',
            secretValue: value,
            networking: VaultUnrestrictedNetworking(),
          ),
          throwsA(_privateFormat),
        );
        expect(
          () => RotateVaultEnvironmentVariableAuth(secretValue: value),
          throwsA(_privateFormat),
        );
        expect(
          () => RotateVaultEnvironmentVariableAuth.fromJson({
            'type': 'environment_variable',
            'secret_value': value,
          }),
          throwsA(_privateFormat),
        );
      },
    );
  }
  for (final name in [
    '1PRIVATE',
    'PRIVATE-x',
    'PRIVATE\n',
    'CODEX_PRIVATE',
    'HTTP_PROXY',
    'https_proxy',
    'ALL_PROXY',
    'NO_PROXY',
    'SSL_CERT_FILE',
    'SSL_CERT_DIR',
    'REQUESTS_CA_BUNDLE',
    'CURL_CA_BUNDLE',
  ]) {
    test(
      'reserved or malformed secret name fails privately: ${name.length}',
      () {
        expect(
          () => CreateVaultEnvironmentVariableAuth(
            secretName: name,
            secretValue: 'PRIVATE',
            networking: VaultUnrestrictedNetworking(),
          ),
          throwsA(_privateFormat),
        );
      },
    );
  }
  test('secret-name syntax is ASCII and CODEX_ matching is case-sensitive', () {
    for (final name in [
      'SERVICE_API_KEY',
      '_key2',
      'codex_user_key',
      'PATH',
      'OPENAI_API_KEY',
    ]) {
      expect(
        CreateVaultEnvironmentVariableAuth(
          secretName: name,
          secretValue: 'PRIVATE',
          networking: VaultUnrestrictedNetworking(),
        ).secretName,
        name,
      );
    }
  });

  test(
    'request strings count Unicode characters; only names use the UTF-8 bound',
    () {
      final allowed = '🚀' * 1048576;
      expect(RotateVaultStaticBearerAuth(token: allowed).token, allowed);
      expect(
        () => RotateVaultStaticBearerAuth(token: '${allowed}x'),
        throwsA(_privateFormat),
      );
      expect(
        () => RotateVaultEnvironmentVariableAuth(secretValue: '${allowed}x'),
        throwsA(_privateFormat),
      );
    },
  );

  test(
    'limited networking validates count, normalized uniqueness and host syntax',
    () {
      final input = ['API.Example.COM', '127.0.0.1'];
      final value = VaultLimitedNetworking(allowedHosts: input);
      input[0] = 'changed';
      expect(value.allowedHosts, ['API.Example.COM', '127.0.0.1']);
      expect(
        () => value.allowedHosts.add('next.example.com'),
        throwsUnsupportedError,
      );
      for (final hosts in <List<String>>[
        [],
        List.generate(17, (i) => 'h$i.example.com'),
        ['PRIVATE.example.com', 'private.example.com'],
        ['https://PRIVATE.example.com'],
        ['PRIVATE.example.com/path'],
        ['PRIVATE.example.com:443'],
        ['*.PRIVATE.example.com'],
        ['::1'],
        ['[::1]'],
        ['256.0.0.1'],
        ['PRIVATE bad'],
        ['-PRIVATE.com'],
      ]) {
        expect(
          () => VaultLimitedNetworking(allowedHosts: hosts),
          throwsA(_privateFormat),
        );
        expect(
          () => VaultLimitedNetworkingResource(allowedHosts: hosts),
          throwsA(_privateFormat),
        );
      }
    },
  );

  test(
    'status filters preserve scalar/array, empty/duplicates and source bounds',
    () {
      final scalar = VaultStatusFilter.fromJson('active');
      expect(scalar.toJson(), 'active');
      final values = [VaultStatus.active, VaultStatus.active];
      final multiple = VaultMultipleStatuses(values);
      values.clear();
      expect(multiple.toJson(), ['active', 'active']);
      expect(VaultStatusFilter.fromJson(const []).toJson(), isEmpty);
      expect(
        VaultMultipleStatuses(
          List.filled(16384, VaultStatus.archived),
        ).statuses.length,
        16384,
      );
      expect(
        () => VaultMultipleStatuses(List.filled(16385, VaultStatus.active)),
        throwsFormatException,
      );
      expect(VaultStatus.fromJson('PRIVATE-future').toJson(), 'PRIVATE-future');
      expect(
        () => VaultSingleStatus(VaultStatus.fromJson('PRIVATE-future')),
        throwsA(_privateFormat),
      );
      expect(() => VaultStatusFilter.fromJson(const {}), throwsFormatException);
      expect(
        () => VaultStatusFilter.fromJson(const [null]),
        throwsFormatException,
      );
    },
  );

  for (final key in [
    'token',
    'access_token',
    'refresh_token',
    'client_secret',
    'secret_value',
  ]) {
    test(
      'known write-only $key cannot enter received auth/resource/extras/copies',
      () {
        for (final schema in [
          'VaultCredentialAuthResourceStaticBearer',
          'VaultCredentialAuthResourceMcpOauth',
          'VaultCredentialAuthResourceEnvironmentVariable',
          'McpOauthRefreshResource',
          'McpOauthTokenEndpointAuthResourceClientSecretBasic',
          'McpOauthTokenEndpointAuthResourceClientSecretPost',
          'McpOauthTokenEndpointAuthResourceNone',
          'VaultCredentialResource',
        ]) {
          final fixture = vaultWireFixtures.singleWhere(
            (f) => f.schema == schema,
          );
          expect(
            () => fixture.parse({..._wire(schema), key: 'PRIVATE-secret'}),
            throwsA(_privateFormat),
          );
        }
        expect(
          () => VaultStaticBearerAuth(
            mcpServerUrl: '',
            rawJson: {key: 'PRIVATE'},
          ),
          throwsA(_privateFormat),
        );
        final safe = VaultStaticBearerAuth(mcpServerUrl: '');
        expect(
          () => safe.copyWith(rawJson: {key: 'PRIVATE'}),
          throwsA(_privateFormat),
        );
        expect(
          () => VaultCredentialAuth.fromJson({
            'type': 'PRIVATE-future',
            key: 'PRIVATE',
          }),
          throwsA(_privateFormat),
        );
        expect(
          () => VaultTokenEndpointAuth.fromJson({
            'type': 'PRIVATE-future',
            key: 'PRIVATE',
          }),
          throwsA(_privateFormat),
        );
        // Metadata labels are application data and are not interpreted as auth.
        expect(
          Vault.fromJson({
            ..._wire('VaultResource'),
            'metadata': {key: 'PRIVATE-label'},
          }).metadata[key],
          'PRIVATE-label',
        );
      },
    );
  }

  test(
    'future auth/networking snapshots stay private and requests are not writable',
    () {
      final future = <String, dynamic>{
        'type': 'future_method',
        'private': {
          'nested': ['PRIVATE', null],
        },
      };
      final value = VaultCredentialAuth.fromJson(future);
      final expected = jsonDecode(jsonEncode(future));
      ((future['private'] as Map<String, dynamic>)['nested']
              as List<Object?>)[0] =
          'changed';
      expect(value.toJson(), expected);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect((value as UnknownVaultCredentialAuth).copyWith(), value);
      expect(
        () => value.copyWith(rawJson: {'type': 'static_bearer'}),
        throwsFormatException,
      );
      final unknownRequest = CreateVaultCredentialAuth.fromJson(const {
        'type': 'future_method',
        'private': 'PRIVATE',
      });
      expect(
        () => CreateVaultCredentialRequest(name: 'valid', auth: unknownRequest),
        throwsA(_privateFormat),
      );
      expect(
        () => VaultCredentialAuth.fromJson(const {'type': 'static_bearer'}),
        throwsFormatException,
      );
      expect(
        () => VaultCredentialAuth.fromJson(const {
          'type': 'mcp_oauth',
          'mcp_server_url': 'x',
        }),
        throwsFormatException,
      );
      expect(
        () => VaultCredentialNetworking.fromJson(const {
          'type': 'limited',
          'allowed_hosts': null,
        }),
        throwsFormatException,
      );
    },
  );

  test('rotation cannot change destinations, secret names or networking', () {
    for (final entry in {
      'mcp_oauth': 'mcp_server_url',
      'static_bearer': 'mcp_server_url',
      'environment_variable': 'secret_name',
    }.entries) {
      final fixture = entry.key == 'environment_variable'
          ? {'secret_value': 'PRIVATE'}
          : entry.key == 'static_bearer'
          ? {'token': 'PRIVATE'}
          : <String, dynamic>{};
      expect(
        () => RotateVaultCredentialAuth.fromJson({
          'type': entry.key,
          ...fixture,
          entry.value: 'PRIVATE',
        }),
        throwsA(_privateFormat),
      );
    }
    expect(
      () => RotateVaultCredentialAuth.fromJson(const {
        'type': 'environment_variable',
        'secret_value': 'PRIVATE',
        'networking': {'type': 'unrestricted'},
      }),
      throwsA(_privateFormat),
    );
  });

  test('received timestamps reject nonfinite integers on all platforms', () {
    final value = Vault.fromJson(_wire('VaultResource'));
    for (final dynamic invalid in [
      double.infinity,
      double.negativeInfinity,
      double.nan,
    ]) {
      expect(
        () => Vault(id: '', name: null, metadata: const {}, createdAt: invalid),
        throwsA(anyOf(isA<TypeError>(), _privateFormat)),
      );
      expect(
        () => value.copyWith(createdAt: invalid),
        throwsA(anyOf(isA<TypeError>(), _privateFormat)),
      );
      expect(
        () =>
            Vault.fromJson({..._wire('VaultResource'), 'created_at': invalid}),
        throwsA(_privateFormat),
      );
      final credential = VaultCredential.fromJson(
        _wire('VaultCredentialResource'),
      );
      for (final key in ['created_at', 'updated_at']) {
        expect(
          () => VaultCredential(
            auth: credential.auth,
            createdAt: key == 'created_at' ? invalid : credential.createdAt,
            updatedAt: key == 'updated_at' ? invalid : credential.updatedAt,
            id: '',
            metadata: const {},
            name: '',
            vaultId: '',
          ),
          throwsA(anyOf(isA<TypeError>(), _privateFormat)),
        );
        expect(
          () => key == 'created_at'
              ? credential.copyWith(createdAt: invalid)
              : credential.copyWith(updatedAt: invalid),
          throwsA(anyOf(isA<TypeError>(), _privateFormat)),
        );
        expect(
          () => VaultCredential.fromJson({
            ..._wire('VaultCredentialResource'),
            key: invalid,
          }),
          throwsA(_privateFormat),
        );
      }
    }
  });
}
