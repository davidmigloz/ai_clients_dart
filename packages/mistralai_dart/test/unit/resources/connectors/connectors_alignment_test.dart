import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const Map<String, Object?> _connector = {
  'id': 'connector-1',
  'name': 'catalog-reader',
  'description': 'Reads public catalog records',
  'created_at': '2026-11-27T09:00:00.000Z',
  'modified_at': '2026-11-27T09:00:00.000Z',
  'owner_type': 'user',
  'visibility': 'private',
  'private_tool_execution': false,
  'protocol': 'http',
  'supports_mcp': true,
  'blocked_by': ['workspace'],
  'openapi_spec': {
    'source': {'type': 'file', 'filename': 'catalog.yaml'},
  },
};
const _message = {'message': 'OK'};
const _issuer = 'https://oauth.example.com';
const _token = '$_issuer/token';
const _globalSecret = 'test-header-value';
const _clientSecret = 'test-client-secret';

MistralClient _client(
  String method,
  String path,
  Object response, {
  int status = 200,
  Map<String, String> query = const {},
  Map<String, Object?>? body,
}) {
  final client = MistralClient.withApiKey(
    'offline-key',
    httpClient: MockClient((request) async {
      expect(request.method, method);
      expect(request.url.path, path);
      expect(request.url.queryParameters, query);
      expect(request.headers['authorization'], 'Bearer offline-key');
      if (body == null) {
        expect(request.body, isEmpty);
      } else {
        expect(request.headers['content-type'], startsWith('application/json'));
        expect(jsonDecode(request.body), body);
      }
      return http.Response(
        jsonEncode(response),
        status,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
  addTearDown(client.close);
  return client;
}

void main() {
  test('creates HTTP connectors with OAuth and typed global headers', () async {
    final client = _client(
      'POST',
      '/v1/connectors',
      _connector,
      status: 201,
      body: {
        'protocol': 'http',
        'name': 'catalog-reader',
        'description': 'Reads public catalog records',
        'server': 'https://example.com/api',
        'auth_methods': [
          {
            'method_type': 'oauth2',
            'grant_type': 'client_credentials',
            'token_endpoint_auth_method': 'client_secret_post',
            'oauth2_server_metadata': {
              'issuer': _issuer,
              'token_endpoint': _token,
            },
          },
        ],
        'global_headers': {
          'X-Example': {'is_secret': true, 'value': _globalSecret},
        },
      },
    );
    const request = CreateConnectorRequest(
      protocol: 'http',
      name: 'catalog-reader',
      description: 'Reads public catalog records',
      server: 'https://example.com/api',
      authMethods: [
        OAuthClientCredentialsConnectorAuthMethod(
          tokenEndpointAuthMethod:
              ConnectorOAuthTokenAuthMethod.clientSecretPost,
          oauth2ServerMetadata: ConnectorOAuthServerMetadata(
            issuer: _issuer,
            tokenEndpoint: _token,
          ),
        ),
      ],
      globalHeaders: {
        'X-Example': ConnectorGlobalHeader(
          isSecret: true,
          value: _globalSecret,
        ),
      },
    );
    final result = await client.connectors.create(request: request);
    expect(result.protocol, ConnectorProtocol.http);
    expect(result.supportsMcp, isTrue);
    expect(result.ownerScope, ConsumerType.user);
    expect(result.ownerType, ResourceType.user);
    expect(result.toJson()['owner_type'], 'user');
    expect(result.blockedBy, [ConsumerType.workspace]);
    expect(
      result.openapiSpec?.source,
      const ConnectorOpenApiFileSource(filename: 'catalog.yaml'),
    );
    expect(CreateConnectorRequest.fromJson(request.toJson()), request);
    expect(
      request.globalHeaders!['X-Example'].toString(),
      isNot(contains(_globalSecret)),
    );
  });

  test(
    'catalog listing accepts flat supports_mcp and preserves cursor',
    () async {
      final client = _client(
        'GET',
        '/v1/connectors',
        {
          'items': [_connector],
          'pagination': {'next_cursor': 'page+2', 'page_size': 25},
        },
        query: {'supports_mcp': 'false', 'page_size': '25', 'cursor': 'page+1'},
      );
      final result = await client.connectors.list(
        queryFilters: const ConnectorsQueryFilters(supportsMcp: false),
        cursor: 'page+1',
        pageSize: 25,
      );
      expect(result.pagination.nextCursor, 'page+2');
      expect(result.items.single.name, 'catalog-reader');
    },
  );

  test(
    'patches HTTP configuration and preserves explicit nullable fields',
    () async {
      const payload = {
        'protocol': 'http',
        'description': null,
        'auth_methods': null,
      };
      final client = _client(
        'PATCH',
        '/v1/connectors/connector-1',
        _connector,
        body: payload,
      );
      final request = UpdateConnectorRequest.fromJson(payload);
      expect(
        request,
        const UpdateConnectorRequest(
          protocol: 'http',
          sendNullFields: {
            ConnectorUpdateField.description,
            ConnectorUpdateField.authMethods,
          },
        ),
      );
      expect(const UpdateConnectorRequest(description: null).toJson(), {
        'protocol': 'mcp',
      });
      final result = await client.connectors.update(
        connectorId: 'connector-1',
        request: request.copyWith(),
      );
      expect(result.openapiSpec?.source, isA<ConnectorOpenApiFileSource>());
    },
  );

  test(
    'passes OAuth display titles and reads public method metadata',
    () async {
      final urls = _client(
        'GET',
        '/v1/connectors/catalog-reader/auth_url',
        {'auth_url': '$_issuer/authorize', 'ttl': 300},
        query: {
          'method_type': 'github_app',
          'credentials_name': 'my-reader',
          'credentials_title': 'My reader',
          'app_return_url': 'https://example.com/done?next=catalog',
        },
      );
      final url = await urls.connectors.getAuthUrl(
        connectorIdOrName: 'catalog-reader',
        methodType: OutboundAuthenticationType.githubApp,
        credentialsName: 'my-reader',
        credentialsTitle: 'My reader',
        appReturnUrl: 'https://example.com/done?next=catalog',
      );
      expect(url.authUrl, '$_issuer/authorize');

      final methods = _client(
        'GET',
        '/v1/connectors/catalog-reader/authentication_methods',
        [
          {
            'method_type': 'oauth2',
            'grant_type': 'authorization_code',
            'token_endpoint_auth_method': 'client_secret_basic',
            'oauth2_server_metadata': {
              'issuer': _issuer,
              'token_endpoint': _token,
            },
            'global_headers': {
              'X-Org': {'value': 'example'},
            },
          },
        ],
      );
      final response = await methods.connectors.getAuthenticationMethods(
        connectorIdOrName: 'catalog-reader',
      );
      expect(
        response.single.grantType,
        ConnectorOAuthGrantType.authorizationCode,
      );
      expect(response.single.oauth2ServerMetadata?.tokenEndpoint, _token);
      expect(response.single.globalHeaders?['X-Org']?.value, 'example');
      expect(response.single.copyWith(headers: []).headers, isEmpty);
    },
  );

  test('lists both MCP schema tools and compact tool output', () async {
    final full = _client(
      'GET',
      '/v1/connectors/catalog-reader/tools',
      [
        {
          'name': 'search_catalog',
          'description': 'Search catalog entries',
          'inputSchema': {'type': 'object'},
          'annotations': {'readOnlyHint': true},
          '_meta': {'example': 'extension'},
          'future_field': 1,
        },
      ],
      query: {
        'page_size': '5',
        'refresh': 'true',
        'credentials_name': 'reader',
      },
    );
    final typed = await full.connectors.listMcpTools(
      connectorIdOrName: 'catalog-reader',
      pageSize: 5,
      refresh: true,
      credentialsName: 'reader',
    );
    expect(typed.single.annotations?.readOnlyHint, isTrue);
    expect(typed.single.meta, {'example': 'extension'});
    expect(typed.single.toJson()['future_field'], 1);

    const output = [
      {'name': 'search_catalog', 'inputSchema': 'compact'},
    ];
    final compact = _client(
      'GET',
      '/v1/connectors/catalog-reader/tools',
      output,
      query: {'pretty': 'true'},
    );
    expect(
      await compact.connectors.listTools(
        connectorIdOrName: 'catalog-reader',
        pretty: true,
      ),
      output,
    );
  });

  test(
    'creates scoped credentials and upserts organization credentials',
    () async {
      const credentials = ConnectionCredentials(
        clientCredentials: ConnectorOAuthClientCredentials(
          clientId: 'client-id',
          clientSecret: _clientSecret,
        ),
        queryParams: {'customer': 'test'},
      );
      const request = CredentialsCreateOrUpdate(
        name: 'catalog-reader',
        credentials: credentials,
      );
      const body = {
        'name': 'catalog-reader',
        'credentials': {
          'oauth': {
            'grant_type': 'client_credentials',
            'client_id': 'client-id',
            'client_secret': _clientSecret,
          },
          'query_params': {'customer': 'test'},
        },
      };
      final create = _client(
        'POST',
        '/v1/connectors/catalog-reader/workspace/credentials',
        _message,
        body: body,
      );
      final patch = _client(
        'PATCH',
        '/v1/connectors/catalog-reader/organization/credentials',
        _message,
        body: body,
      );
      await create.connectors.createCredentials(
        connectorIdOrName: 'catalog-reader',
        scope: ConnectorConsumerScope.workspace,
        request: request,
      );
      await patch.connectors.createOrUpdateOrganizationCredentials(
        connectorIdOrName: 'catalog-reader',
        request: request,
      );
      expect(
        () => create.connectors.createCredentials(
          connectorIdOrName: 'catalog-reader',
          scope: ConnectorConsumerScope.organization,
          request: request,
        ),
        throwsArgumentError,
      );
      expect(ConnectionCredentials.fromJson(credentials.toJson()), credentials);
      expect(credentials.toString(), isNot(contains(_clientSecret)));
    },
  );

  test('reads and removes scoped credentials', () async {
    final get = _client(
      'GET',
      '/v1/connectors/catalog-reader/workspace/credentials',
      {
        'credentials': [
          {
            'name': 'reader',
            'authentication_type': 'oauth2',
            'scope': 'workspace',
            'creator_id': 'user-1',
          },
        ],
      },
      query: {'auth_type': 'oauth2', 'fetch_default': 'true'},
    );
    final response = await get.connectors.listCredentials(
      connectorIdOrName: 'catalog-reader',
      scope: ConnectorConsumerScope.workspace,
      authType: OutboundAuthenticationType.oauth2,
      fetchDefault: true,
    );
    expect(response.credentials.single.creatorId, 'user-1');
    final drop = _client(
      'DELETE',
      '/v1/connectors/catalog-reader/workspace/credentials/reader',
      _message,
    );
    await drop.connectors.deleteCredentials(
      connectorIdOrName: 'catalog-reader',
      scope: ConnectorConsumerScope.workspace,
      credentialsName: 'reader',
    );
  });

  test('shares and unshares with workspace and organization scopes', () async {
    const path = '/v1/connectors/connector-1';
    await _client(
      'PUT',
      '$path/share',
      _message,
    ).connectors.share(connectorId: 'connector-1');
    await _client(
      'DELETE',
      '$path/share',
      _message,
    ).connectors.unshare(connectorId: 'connector-1');
    await _client(
      'PUT',
      '$path/organization/share',
      _message,
    ).connectors.shareToOrganization(connectorId: 'connector-1');
    await _client(
      'DELETE',
      '$path/organization/share',
      _message,
    ).connectors.unshareFromOrganization(connectorId: 'connector-1');
  });

  test('current activation endpoints have no request body', () async {
    const path = '/v1/connectors/connector-1';
    await _client(
      'POST',
      '$path/organization/activate',
      _message,
    ).connectors.activate(
      connectorId: 'connector-1',
      scope: ConnectorConsumerScope.organization,
    );
    await _client(
      'POST',
      '$path/organization/deactivate',
      _message,
    ).connectors.deactivate(
      connectorId: 'connector-1',
      scope: ConnectorConsumerScope.organization,
    );
  });

  test('preserves connector error code and status', () async {
    final client = _client(
      'POST',
      '/v1/connectors',
      {
        'code': 'custom_connectors_disabled',
        'detail': 'Custom connectors are disabled',
      },
      status: 403,
      body: {
        'name': 'reader',
        'description': 'Read catalog',
        'server': 'https://example.com',
      },
    );
    await expectLater(
      client.connectors.create(
        request: const CreateConnectorRequest(
          name: 'reader',
          description: 'Read catalog',
          server: 'https://example.com',
        ),
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 403)
            .having(
              (error) => ConnectorErrorResponse.fromJson(
                error.details.single as Map<String, dynamic>,
              ).code,
              'connector error code',
              ConnectorErrorCode.customConnectorsDisabled,
            ),
      ),
    );
  });
  group('credential diagnostics', () {
    const credentials = CredentialsCreateOrUpdate(
      name: 'example',
      credentials: ConnectionCredentials(bearerToken: _clientSecret),
    );
    final writes = <String, Future<Object> Function(MistralClient)>{
      'create': (client) => client.connectors.create(
        request: const CreateConnectorRequest(
          name: 'reader',
          description: 'Read catalog',
          server: 'https://example.com',
          authData: AuthData(clientId: 'client', clientSecret: _clientSecret),
        ),
      ),
      'update': (client) => client.connectors.update(
        connectorId: 'connector-1',
        request: const UpdateConnectorRequest(
          authMethods: [
            ConnectorAuthMethodPatch(
              methodType: OutboundAuthenticationType.oauth2,
              oauth2MetadataSecrets: ConnectorOAuthMetadataSecrets(
                clientSecret: _clientSecret,
              ),
            ),
          ],
        ),
      ),
      'create credentials': (client) => client.connectors.createCredentials(
        connectorIdOrName: 'connector-1',
        scope: ConnectorConsumerScope.user,
        request: credentials,
      ),
      'update credentials': (client) => client.connectors.updateCredentials(
        connectorIdOrName: 'connector-1',
        scope: ConnectorConsumerScope.organization,
        request: credentials,
      ),
    };

    for (final entry in writes.entries) {
      test('${entry.key} suppresses an echoed secret', () async {
        final records = <LogRecord>[];
        final subscription = Logger.root.onRecord.listen(records.add);
        addTearDown(subscription.cancel);
        final transport = _EchoingConnectorTransport();
        final client = MistralClient.withApiKey(
          'offline-key',
          httpClient: transport,
        );
        addTearDown(client.close);

        await expectLater(
          entry.value(client),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'status', 422)
                .having((error) => error.details, 'details', isEmpty)
                .having(
                  (error) => error.message,
                  'message',
                  isNot(contains(_clientSecret)),
                )
                .having(
                  (error) => error.toString(),
                  'diagnostic',
                  isNot(contains(_clientSecret)),
                )
                .having(
                  (error) => error.responseMetadata?.bodyExcerpt,
                  'body',
                  '[REDACTED]',
                )
                .having(
                  (error) => error.responseMetadata?.headers,
                  'headers',
                  isEmpty,
                ),
          ),
        );
        expect(transport.requests, 1);
        final messages = records.where(
          (record) => record.loggerName == 'mistralai_dart',
        );
        expect(
          messages.any((record) => record.message.contains('HTTP 422 error')),
          isTrue,
        );
        expect(
          messages.every((record) => !record.message.contains(_clientSecret)),
          isTrue,
        );
      });
    }
  });

  test('OAuth diagnostics display expiry without the secret', () {
    const metadata = ConnectorOAuthMetadataSecrets(
      clientSecret: _clientSecret,
      clientSecretExpiresAt: 1795770000,
    );
    expect(metadata.toString(), contains('clientSecretExpiresAt: 1795770000'));
    expect(metadata.toString(), isNot(contains(_clientSecret)));
  });
}

class _EchoingConnectorTransport extends http.BaseClient {
  int requests = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests++;
    expect(request.followRedirects, isFalse);
    final body = await request.finalize().bytesToString();
    expect(body, contains(_clientSecret));
    return http.StreamedResponse(
      Stream.value(
        utf8.encode(
          jsonEncode({
            'detail': {'message': 'Rejected $body'},
          }),
        ),
      ),
      422,
      headers: {
        'content-type': 'application/json',
        'x-echoed-credential': _clientSecret,
      },
    );
  }
}
