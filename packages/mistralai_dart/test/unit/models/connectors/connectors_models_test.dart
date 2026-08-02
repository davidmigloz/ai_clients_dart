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
      'creator_id': 'user-1',
      'execution_env': {
        'tools': <Map<String, dynamic>>[],
        'tool_execution_data': {
          'integrations': <Map<String, dynamic>>[],
          'tools': <Map<String, dynamic>>[],
        },
        'errors': <String>[],
      },
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
      expect(connector.creatorId, 'user-1');
      expect(connector.executionEnv!.errors, isEmpty);
      expect(connector.executionEnv!.toolExecutionData.integrations, isEmpty);

      final back = connector.toJson();
      expect(back['id'], 'c-1');
      expect(back['owner_type'], 2);
      expect(back['visibility'], 'shared_org');
      expect(back['server_card'], {'name': 'srv', 'version': '1.0'});
      expect(back['creator_id'], 'user-1');

      expect(Connector.fromJson(back), connector);
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
    test('serializes optional auth data and headers, without protocol', () {
      const request = CreateConnectorRequest(
        name: 'n',
        description: 'd',
        server: 's',
        title: 't',
        authData: AuthData(clientId: 'id', clientSecret: 'secret'),
        headers: {'X-Org': 'value'},
        oauth2ServerMetadataUrl: 'https://meta',
        visibility: PublicResourceVisibility.sharedWorkspace,
      );
      final json = request.toJson();
      expect(json, {
        'name': 'n',
        'description': 'd',
        'server': 's',
        'title': 't',
        'auth_data': {'client_id': 'id', 'client_secret': 'secret'},
        'headers': {'X-Org': 'value'},
        'oauth2_server_metadata_url': 'https://meta',
        'visibility': 'shared_workspace',
      });
      expect(json.containsKey('protocol'), isFalse);
      expect(CreateConnectorRequest.fromJson(json), request);
    });

    test('visibility is nullable and omitted when unset', () {
      const request = CreateConnectorRequest(
        name: 'n',
        description: 'd',
        server: 's',
      );
      expect(request.visibility, isNull);
      expect(request.toJson().containsKey('visibility'), isFalse);
    });
  });

  group('UpdateConnectorRequest model', () {
    test('protocol is a fixed "mcp" getter, not a constructor field', () {
      const request = UpdateConnectorRequest(title: 'New title');
      expect(request.protocol, 'mcp');
      final json = request.toJson();
      expect(json['protocol'], 'mcp');
      expect(json.containsKey('connection_config'), isFalse);
      expect(json.containsKey('connection_secrets'), isFalse);
      expect(UpdateConnectorRequest.fromJson(json), request);
    });

    test('fromJson rejects a mismatched protocol value', () {
      expect(
        () => UpdateConnectorRequest.fromJson(const {'protocol': 'turbine'}),
        throwsFormatException,
      );
    });

    test('has no connectionConfig/connectionSecrets fields', () {
      const request = UpdateConnectorRequest(server: 'https://new.example.com');
      expect(request.toJson()['server'], 'https://new.example.com');
    });
  });

  group('CredentialsStatus / AuthenticationConfiguration / '
      'CredentialsCreateOrUpdate models', () {
    test('CredentialsStatus errorMessage retypes to enum', () {
      final status = CredentialsStatus.fromJson(const {
        'status_type': 'invalid',
        'error_message': 'oauth expired',
      });
      expect(status.errorMessage, CredentialsStatusErrorReason.oauthExpired);
      expect(status.toJson()['error_message'], 'oauth expired');
      expect(CredentialsStatus.fromJson(status.toJson()), status);
    });

    test('CredentialsStatus errorMessage falls back to unknown', () {
      final status = CredentialsStatus.fromJson(const {
        'status_type': 'invalid',
        'error_message': 'a brand new reason',
      });
      expect(status.errorMessage, CredentialsStatusErrorReason.unknown);
    });

    test('AuthenticationConfiguration round-trips optional title', () {
      final config = AuthenticationConfiguration.fromJson(const {
        'name': 'default',
        'authentication_type': 'bearer',
        'scope': 'org',
        'title': 'My credential',
      });
      expect(config.title, 'My credential');
      expect(AuthenticationConfiguration.fromJson(config.toJson()), config);
    });

    test('CredentialsCreateOrUpdate round-trips optional title', () {
      const request = CredentialsCreateOrUpdate(
        name: 'cred',
        title: 'My credential',
      );
      final json = request.toJson();
      expect(json['title'], 'My credential');
      expect(CredentialsCreateOrUpdate.fromJson(json), request);
    });
  });

  group('New public execution env models', () {
    test('PublicExecutionEnv/PublicConnectorExecutionData round-trip', () {
      final json = {
        'tools': <Map<String, dynamic>>[],
        'tool_execution_data': {
          'integrations': [
            {
              'id': 'conn-1',
              'name': 'my_connector',
              'connection_config': {
                'type': 'mcp',
                'server': 'https://mcp.example.com',
              },
            },
          ],
          'tools': [
            {
              'name': 'search',
              'integration_id': 'conn-1',
              'execution_config': {'type': 'mcp'},
            },
          ],
          'use_connectors_gateway': true,
        },
        'errors': ['some warning'],
      };
      final env = PublicExecutionEnv.fromJson(json);
      expect(env.errors, ['some warning']);
      expect(env.toolExecutionData.useConnectorsGateway, isTrue);
      expect(env.toolExecutionData.integrations.first.id, 'conn-1');
      expect(
        env.toolExecutionData.integrations.first.connectionConfig!.type,
        ConnectionConfigType.mcp,
      );
      expect(env.toolExecutionData.tools.first.integrationId, 'conn-1');
      expect(env.toolExecutionData.tools.first.executionConfig, {
        'type': 'mcp',
      });
      expect(PublicExecutionEnv.fromJson(env.toJson()), env);
    });

    test('ExecutionTool.executionConfig is unmodifiable and deep-compared', () {
      final tool = ExecutionTool(
        name: 'search',
        integrationId: 'conn-1',
        executionConfig: const {
          'nested': {
            'list': [1, 2],
          },
        },
      );
      expect(
        () => tool.executionConfig!['nested'] = 'mutated',
        throwsUnsupportedError,
      );

      final same = ExecutionTool(
        name: 'search',
        integrationId: 'conn-1',
        executionConfig: const {
          'nested': {
            'list': [1, 2],
          },
        },
      );
      expect(tool, equals(same));
      expect(tool.hashCode, equals(same.hashCode));

      final different = ExecutionTool(
        name: 'search',
        integrationId: 'conn-1',
        executionConfig: const {
          'nested': {
            'list': [1, 3],
          },
        },
      );
      expect(tool, isNot(equals(different)));
    });
  });

  group('forward-compatible connector enums', () {
    test('PublicResourceVisibility falls back to unknown', () {
      expect(
        PublicResourceVisibility.fromJson('mystery'),
        PublicResourceVisibility.unknown,
      );
      expect(
        PublicResourceVisibility.fromJson('shared_org'),
        PublicResourceVisibility.sharedOrg,
      );
    });

    test('CredentialsStatusErrorReason covers all wire values', () {
      const expected = {
        'oauth expired': CredentialsStatusErrorReason.oauthExpired,
        'oauth near expiry': CredentialsStatusErrorReason.oauthNearExpiry,
        'empty credentials': CredentialsStatusErrorReason.emptyCredentials,
        'unparsable credentials':
            CredentialsStatusErrorReason.unparsableCredentials,
        'you need to reconnect':
            CredentialsStatusErrorReason.youNeedToReconnect,
        'oauth refresh error': CredentialsStatusErrorReason.oauthRefreshError,
        'MCP server unreachable':
            CredentialsStatusErrorReason.mcpServerUnreachable,
        'MCP server timed out': CredentialsStatusErrorReason.mcpServerTimedOut,
        'MCP server error': CredentialsStatusErrorReason.mcpServerError,
        'unknown error': CredentialsStatusErrorReason.unknownError,
      };
      for (final MapEntry(key: wire, :value) in expected.entries) {
        expect(CredentialsStatusErrorReason.fromJson(wire), value);
        expect(value.toJson(), wire);
      }
      expect(
        CredentialsStatusErrorReason.fromJson('never seen before'),
        CredentialsStatusErrorReason.unknown,
      );
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
