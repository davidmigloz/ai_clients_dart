@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Connector model', () {
    final json = {
      'id': 'c-1',
      'name': 'my_connector',
      'description': 'desc',
      'created_at': '2024-01-01T00:00:00.000Z',
      'modified_at': '2024-01-02T00:00:00.000Z',
      'owner_type': 2,
      'visibility': 'shared_org',
      'private_tool_execution': false,
      'title': 'My Connector',
      'server': 'https://mcp.example.com',
      'protocol': 'mcp',
      'mistral': false,
      'active': true,
      'is_authenticated': true,
      'supported_auth_methods': [
        {'method_type': 'oauth2', 'has_default_credentials': true},
      ],
      'connection_config': {
        'type': 'mcp',
        'base_url': 'https://x',
        'signed': true,
      },
      'server_card': {'name': 'srv', 'version': '1.0'},
    };

    test('round-trips through JSON', () {
      final connector = Connector.fromJson(json);
      expect(connector.id, 'c-1');
      expect(connector.ownerType, ResourceType.org);
      expect(connector.visibility, ResourceVisibility.sharedOrg);
      expect(connector.protocol, ConnectorProtocol.mcp);
      expect(connector.active, isTrue);
      expect(
        connector.supportedAuthMethods!.first.methodType,
        OutboundAuthenticationType.oauth2,
      );
      expect(connector.connectionConfig!.type, ConnectionConfigType.mcp);
      expect(connector.serverCard!['name'], 'srv');

      final back = connector.toJson();
      expect(back['id'], 'c-1');
      expect(back['owner_type'], 2);
      expect(back['visibility'], 'shared_org');
      expect(back['server_card'], {'name': 'srv', 'version': '1.0'});
    });

    test('equality is value-based', () {
      expect(Connector.fromJson(json), Connector.fromJson(json));
      expect(
        Connector.fromJson(json).hashCode,
        Connector.fromJson(json).hashCode,
      );
    });

    test('copyWith clears nullable fields with explicit null', () {
      final connector = Connector.fromJson(json);
      final cleared = connector.copyWith(title: null, active: null);
      expect(cleared.title, isNull);
      expect(cleared.active, isNull);
      expect(cleared.id, connector.id);
    });

    test('unknown enum values fall back to unknown', () {
      final connector = Connector.fromJson({
        ...json,
        'owner_type': 99,
        'visibility': 'mystery',
      });
      expect(connector.ownerType, ResourceType.unknown);
      expect(connector.visibility, ResourceVisibility.unknown);
    });
  });

  group('PaginatedConnectors model', () {
    test('round-trips through JSON', () {
      final json = {
        'items': <Map<String, dynamic>>[],
        'pagination': {'page_size': 25, 'next_cursor': 'abc'},
      };
      final paged = PaginatedConnectors.fromJson(json);
      expect(paged.isEmpty, isTrue);
      expect(paged.pagination.pageSize, 25);
      expect(paged.pagination.nextCursor, 'abc');
      expect(paged.toJson()['pagination'], {
        'page_size': 25,
        'next_cursor': 'abc',
      });
    });
  });

  group('CreateConnectorRequest model', () {
    test('serializes optional auth data and headers', () {
      const request = CreateConnectorRequest(
        name: 'n',
        description: 'd',
        server: 's',
        title: 't',
        authData: AuthData(clientId: 'id', clientSecret: 'secret'),
        headers: {'X-Org': 'value'},
        oauth2ServerMetadataUrl: 'https://meta',
      );
      final json = request.toJson();
      expect(json, {
        'name': 'n',
        'description': 'd',
        'server': 's',
        'protocol': 'mcp',
        'title': 't',
        'auth_data': {'client_id': 'id', 'client_secret': 'secret'},
        'headers': {'X-Org': 'value'},
        'oauth2_server_metadata_url': 'https://meta',
      });
      expect(CreateConnectorRequest.fromJson(json), request);
    });
  });

  group('CredentialsCreateOrUpdate / ConnectionCredentials models', () {
    test('round-trips through JSON', () {
      const request = CredentialsCreateOrUpdate(
        name: 'cred',
        isDefault: false,
        credentials: ConnectionCredentials(
          bearerToken: 'token',
          headers: {'Authorization': 'Bearer x'},
        ),
      );
      final json = request.toJson();
      expect(json['name'], 'cred');
      expect(json['is_default'], false);
      expect((json['credentials'] as Map)['bearer_token'], 'token');
      expect(CredentialsCreateOrUpdate.fromJson(json), request);
    });

    test('OAuth2Token round-trips datetimes', () {
      final token = OAuth2Token(
        accessToken: 'a',
        expiresIn: 3600,
        expiresAt: DateTime.utc(2030, 1, 1),
      );
      final back = OAuth2Token.fromJson(token.toJson());
      expect(back.accessToken, 'a');
      expect(back.expiresIn, 3600);
      expect(back.expiresAt, DateTime.utc(2030, 1, 1));
    });
  });

  group('CredentialsResponse model', () {
    test('round-trips authentication configurations', () {
      final json = {
        'credentials': [
          {
            'name': 'default',
            'authentication_type': 'bearer',
            'scope': 'org',
            'status': {'status_type': 'valid'},
            'is_default': true,
          },
        ],
        'connector_preset_credentials_for_auth': ['oauth2', 'none'],
      };
      final response = CredentialsResponse.fromJson(json);
      expect(response.credentials.first.scope, ConsumerType.org);
      expect(response.credentials.first.status!.statusType, AuthStatus.valid);
      expect(response.connectorPresetCredentialsForAuth, [
        OutboundAuthenticationType.oauth2,
        OutboundAuthenticationType.none,
      ]);
      expect(CredentialsResponse.fromJson(response.toJson()), response);
    });
  });

  group('ConnectorToolCallResponse model', () {
    test('round-trips content and nested metadata', () {
      final json = {
        'content': [
          {'type': 'text', 'text': 'hello'},
        ],
        'metadata': {
          'mcp_meta': {
            'isError': true,
            'structuredContent': {'k': 'v'},
          },
        },
      };
      final response = ConnectorToolCallResponse.fromJson(json);
      expect(response.content.first['text'], 'hello');
      expect(response.metadata!.mcpMeta!.isError, isTrue);
      expect(response.metadata!.mcpMeta!.structuredContent, {'k': 'v'});
      expect(ConnectorToolCallResponse.fromJson(response.toJson()), response);
    });
  });

  group('ToolExecutionConfiguration model', () {
    test('round-trips include/exclude and freeform confirmation', () {
      const config = ToolExecutionConfiguration(
        include: ['a'],
        exclude: ['b'],
        requiresConfirmation: ['c'],
      );
      final json = config.toJson();
      expect(json, {
        'requires_confirmation': ['c'],
        'include': ['a'],
        'exclude': ['b'],
      });
      expect(ToolExecutionConfiguration.fromJson(json), config);
    });
  });

  group('forward-compatible enums', () {
    test('fall back to unknown for unrecognized values', () {
      expect(
        OutboundAuthenticationType.fromJson('???'),
        OutboundAuthenticationType.unknown,
      );
      expect(AuthStatus.fromJson('???'), AuthStatus.unknown);
      expect(ConsumerType.fromJson(null), ConsumerType.unknown);
      expect(ResourceType.fromJson(null), ResourceType.unknown);
    });
  });
}
