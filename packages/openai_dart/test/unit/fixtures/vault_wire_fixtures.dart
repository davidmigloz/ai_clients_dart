import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// Independent canonical values; synthetic secrets only, never read from an API.
final vaultWireFixtures = <VaultWireFixture>[
  VaultWireFixture(
    schema: 'ErrorBodyResource',
    minimal: jsonDecode(
      r'''{"type":"","code":"","message":"PRIVATE-synthetic-error","param":null}''',
    ),
    full: jsonDecode(
      r'''{"code":"PRIVATE-field","message":"PRIVATE-synthetic-error","param":"PRIVATE-field","type":"PRIVATE-field"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'code', 'message', 'param'],
    nullableKeys: ['param'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'ErrorResponse-2',
    minimal: jsonDecode(
      r'''{"error":{"type":"","code":"","message":"PRIVATE-synthetic-error","param":null}}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-field","message":"PRIVATE-synthetic-error","param":"PRIVATE-field","type":"PRIVATE-field"}}''',
    ),
    parse: (value) =>
        AgentErrorResponse.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['error'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'ListOrderParam',
    minimal: jsonDecode(r'''"asc"'''),
    full: jsonDecode(r'''"desc"'''),
    parse: AgentListOrder.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateMcpOauthRefreshParam',
    minimal: jsonDecode(
      r'''{"token_endpoint":"https://api.example.com/mcp","client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","token_endpoint_auth":{"type":"none"}}''',
    ),
    full: jsonDecode(
      r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
    ),
    parse: (value) =>
        CreateVaultMcpOauthRefresh.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'token_endpoint',
      'client_id',
      'refresh_token',
      'token_endpoint_auth',
    ],
    nullableKeys: ['resource', 'scope'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateMcpOauthTokenEndpointAuthParam',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(
      r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}''',
    ),
    parse: (value) =>
        CreateVaultTokenEndpointAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'client_secret'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateMcpOauthTokenEndpointAuthParamClientSecretBasic',
    minimal: jsonDecode(
      r'''{"type":"client_secret_basic","client_secret":"PRIVATE-CLIENT_SECRET"}''',
    ),
    full: jsonDecode(
      r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_basic"}''',
    ),
    parse: (value) => CreateVaultTokenEndpointClientSecretBasic.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'client_secret'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateMcpOauthTokenEndpointAuthParamClientSecretPost',
    minimal: jsonDecode(
      r'''{"type":"client_secret_post","client_secret":"PRIVATE-CLIENT_SECRET"}''',
    ),
    full: jsonDecode(
      r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}''',
    ),
    parse: (value) => CreateVaultTokenEndpointClientSecretPost.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'client_secret'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateMcpOauthTokenEndpointAuthParamNone',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(r'''{"type":"none"}'''),
    parse: (value) =>
        CreateVaultTokenEndpointNone.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateVaultCredentialAuthParam',
    minimal: jsonDecode(
      r'''{"type":"mcp_oauth","mcp_server_url":"https://api.example.com/mcp","access_token":"PRIVATE-ACCESS_TOKEN"}''',
    ),
    full: jsonDecode(
      r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
    ),
    parse: (value) =>
        CreateVaultCredentialAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'secret_name', 'secret_value', 'networking'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateVaultCredentialAuthParamEnvironmentVariable',
    minimal: jsonDecode(
      r'''{"type":"environment_variable","secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","networking":{"type":"unrestricted"}}''',
    ),
    full: jsonDecode(
      r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
    ),
    parse: (value) => CreateVaultEnvironmentVariableAuth.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'secret_name', 'secret_value', 'networking'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateVaultCredentialAuthParamMcpOauth',
    minimal: jsonDecode(
      r'''{"type":"mcp_oauth","mcp_server_url":"https://api.example.com/mcp","access_token":"PRIVATE-ACCESS_TOKEN"}''',
    ),
    full: jsonDecode(
      r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
    ),
    parse: (value) =>
        CreateVaultMcpOauthAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'mcp_server_url', 'access_token'],
    nullableKeys: ['expires_at', 'refresh'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateVaultCredentialAuthParamStaticBearer',
    minimal: jsonDecode(
      r'''{"type":"static_bearer","mcp_server_url":"https://api.example.com/mcp","token":"PRIVATE-TOKEN"}''',
    ),
    full: jsonDecode(
      r'''{"mcp_server_url":"https://api.example.com/mcp","token":"PRIVATE-TOKEN","type":"static_bearer"}''',
    ),
    parse: (value) =>
        CreateVaultStaticBearerAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'mcp_server_url', 'token'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateVaultCredentialParams',
    minimal: jsonDecode(
      r'''{"auth":{"type":"mcp_oauth","mcp_server_url":"https://api.example.com/mcp","access_token":"PRIVATE-ACCESS_TOKEN"},"name":"Credential café🚀"}''',
    ),
    full: jsonDecode(
      r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀"}''',
    ),
    parse: (value) =>
        CreateVaultCredentialRequest.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['auth', 'name'],
    nullableKeys: [],
    optionalNonnullKeys: ['metadata'],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'CreateVaultParams',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀"}''',
    ),
    parse: (value) =>
        CreateVaultRequest.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: ['metadata'],
    optionalNonnullKeys: ['name'],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'DeletedVaultCredentialResource',
    minimal: jsonDecode(
      r'''{"id":"credential_1","object":"vault.credential.deleted","deleted":false}''',
    ),
    full: jsonDecode(
      r'''{"deleted":true,"id":"credential_1","object":"vault.credential.deleted"}''',
    ),
    parse: (value) =>
        DeletedVaultCredential.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['id', 'object', 'deleted'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'DeletedVaultResource',
    minimal: jsonDecode(
      r'''{"id":"vault_1","object":"vault.deleted","deleted":false}''',
    ),
    full: jsonDecode(
      r'''{"deleted":true,"id":"vault_1","object":"vault.deleted"}''',
    ),
    parse: (value) => DeletedVault.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['id', 'object', 'deleted'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'McpOauthRefreshResource',
    minimal: jsonDecode(
      r'''{"token_endpoint":"","client_id":"public-synthetic-client","resource":null,"scope":null,"token_endpoint_auth":{"type":"none"}}''',
    ),
    full: jsonDecode(
      r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
    ),
    parse: (value) =>
        VaultMcpOauthRefresh.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'token_endpoint',
      'client_id',
      'resource',
      'scope',
      'token_endpoint_auth',
    ],
    nullableKeys: ['resource', 'scope'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'McpOauthTokenEndpointAuthResource',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(r'''{"type":"client_secret_post"}'''),
    parse: (value) =>
        VaultTokenEndpointAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'McpOauthTokenEndpointAuthResourceClientSecretBasic',
    minimal: jsonDecode(r'''{"type":"client_secret_basic"}'''),
    full: jsonDecode(r'''{"type":"client_secret_basic"}'''),
    parse: (value) => VaultTokenEndpointClientSecretBasic.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'McpOauthTokenEndpointAuthResourceClientSecretPost',
    minimal: jsonDecode(r'''{"type":"client_secret_post"}'''),
    full: jsonDecode(r'''{"type":"client_secret_post"}'''),
    parse: (value) => VaultTokenEndpointClientSecretPost.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'McpOauthTokenEndpointAuthResourceNone',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(r'''{"type":"none"}'''),
    parse: (value) =>
        VaultTokenEndpointNone.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'RotateMcpOauthRefreshParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
    ),
    parse: (value) =>
        RotateVaultMcpOauthRefresh.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: ['refresh_token', 'scope', 'token_endpoint_auth'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateMcpOauthTokenEndpointAuthParam',
    minimal: jsonDecode(r'''{"type":"client_secret_basic"}'''),
    full: jsonDecode(
      r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}''',
    ),
    parse: (value) =>
        RotateVaultTokenEndpointAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: ['client_secret'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateMcpOauthTokenEndpointAuthParamClientSecretBasic',
    minimal: jsonDecode(r'''{"type":"client_secret_basic"}'''),
    full: jsonDecode(
      r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_basic"}''',
    ),
    parse: (value) => RotateVaultTokenEndpointClientSecretBasic.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: ['client_secret'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateMcpOauthTokenEndpointAuthParamClientSecretPost',
    minimal: jsonDecode(r'''{"type":"client_secret_post"}'''),
    full: jsonDecode(
      r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}''',
    ),
    parse: (value) => RotateVaultTokenEndpointClientSecretPost.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: ['client_secret'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateVaultCredentialAuthParam',
    minimal: jsonDecode(r'''{"type":"mcp_oauth"}'''),
    full: jsonDecode(
      r'''{"secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
    ),
    parse: (value) =>
        RotateVaultCredentialAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'secret_value'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateVaultCredentialAuthParamEnvironmentVariable',
    minimal: jsonDecode(
      r'''{"type":"environment_variable","secret_value":"PRIVATE-SECRET_VALUE"}''',
    ),
    full: jsonDecode(
      r'''{"secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
    ),
    parse: (value) => RotateVaultEnvironmentVariableAuth.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'secret_value'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateVaultCredentialAuthParamMcpOauth',
    minimal: jsonDecode(r'''{"type":"mcp_oauth"}'''),
    full: jsonDecode(
      r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","refresh":{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
    ),
    parse: (value) =>
        RotateVaultMcpOauthAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: ['access_token', 'expires_at', 'refresh'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateVaultCredentialAuthParamStaticBearer',
    minimal: jsonDecode(
      r'''{"type":"static_bearer","token":"PRIVATE-TOKEN"}''',
    ),
    full: jsonDecode(r'''{"token":"PRIVATE-TOKEN","type":"static_bearer"}'''),
    parse: (value) =>
        RotateVaultStaticBearerAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'token'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'RotateVaultCredentialParams',
    minimal: jsonDecode(r'''{"metadata":{}}'''),
    full: jsonDecode(
      r'''{"auth":{"secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"}}''',
    ),
    parse: (value) =>
        RotateVaultCredentialRequest.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: ['auth', 'metadata'],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'UpdateVaultParams',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀"}''',
    ),
    parse: (value) =>
        UpdateVaultRequest.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: ['name'],
    optionalNonnullKeys: ['metadata'],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialAuthResource',
    minimal: jsonDecode(
      r'''{"type":"mcp_oauth","mcp_server_url":"","expires_at":null,"refresh":null}''',
    ),
    full: jsonDecode(
      r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"}''',
    ),
    parse: (value) =>
        VaultCredentialAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'secret_name', 'networking'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialAuthResourceEnvironmentVariable',
    minimal: jsonDecode(
      r'''{"type":"environment_variable","secret_name":"SERVICE_API_KEY","networking":{"type":"unrestricted"}}''',
    ),
    full: jsonDecode(
      r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"}''',
    ),
    parse: (value) =>
        VaultEnvironmentVariableAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'secret_name', 'networking'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialAuthResourceMcpOauth',
    minimal: jsonDecode(
      r'''{"type":"mcp_oauth","mcp_server_url":"","expires_at":null,"refresh":null}''',
    ),
    full: jsonDecode(
      r'''{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"}''',
    ),
    parse: (value) =>
        VaultMcpOauthAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'mcp_server_url', 'expires_at', 'refresh'],
    nullableKeys: ['expires_at', 'refresh'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialAuthResourceStaticBearer',
    minimal: jsonDecode(r'''{"type":"static_bearer","mcp_server_url":""}'''),
    full: jsonDecode(
      r'''{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"}''',
    ),
    parse: (value) =>
        VaultStaticBearerAuth.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'mcp_server_url'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialListResource',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1","has_more":true,"last_id":"credential_7","object":"list"}''',
    ),
    parse: (value) =>
        VaultCredentialList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialNetworkingParam',
    minimal: jsonDecode(r'''{"type":"unrestricted"}'''),
    full: jsonDecode(
      r'''{"allowed_hosts":["api.example.com"],"type":"limited"}''',
    ),
    parse: (value) =>
        VaultCredentialNetworking.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'allowed_hosts'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialNetworkingParamLimited',
    minimal: jsonDecode(
      r'''{"type":"limited","allowed_hosts":["api.example.com"]}''',
    ),
    full: jsonDecode(
      r'''{"allowed_hosts":["api.example.com"],"type":"limited"}''',
    ),
    parse: (value) =>
        VaultLimitedNetworking.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'allowed_hosts'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialNetworkingParamUnrestricted',
    minimal: jsonDecode(r'''{"type":"unrestricted"}'''),
    full: jsonDecode(r'''{"type":"unrestricted"}'''),
    parse: (value) =>
        VaultUnrestrictedNetworking.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialNetworkingResource',
    minimal: jsonDecode(r'''{"type":"unrestricted"}'''),
    full: jsonDecode(
      r'''{"allowed_hosts":["api.example.com"],"type":"limited"}''',
    ),
    parse: (value) => VaultCredentialNetworkingResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'allowed_hosts'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialNetworkingResourceLimited',
    minimal: jsonDecode(
      r'''{"type":"limited","allowed_hosts":["api.example.com"]}''',
    ),
    full: jsonDecode(
      r'''{"allowed_hosts":["api.example.com"],"type":"limited"}''',
    ),
    parse: (value) =>
        VaultLimitedNetworkingResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'allowed_hosts'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialNetworkingResourceUnrestricted',
    minimal: jsonDecode(r'''{"type":"unrestricted"}'''),
    full: jsonDecode(r'''{"type":"unrestricted"}'''),
    parse: (value) => VaultUnrestrictedNetworkingResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultCredentialResource',
    minimal: jsonDecode(
      r'''{"id":"credential_1","object":"vault.credential","vault_id":"vault_1","name":"Credential café🚀","auth":{"type":"mcp_oauth","mcp_server_url":"","expires_at":null,"refresh":null},"metadata":{},"created_at":0,"updated_at":0}''',
    ),
    full: jsonDecode(
      r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
    ),
    parse: (value) => VaultCredential.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'id',
      'object',
      'vault_id',
      'name',
      'auth',
      'metadata',
      'created_at',
      'updated_at',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultListResource',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1","has_more":true,"last_id":"vault_1","object":"list"}''',
    ),
    parse: (value) => VaultList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultResource',
    minimal: jsonDecode(
      r'''{"id":"vault_1","object":"vault","name":null,"metadata":{},"created_at":0}''',
    ),
    full: jsonDecode(
      r'''{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}''',
    ),
    parse: (value) => Vault.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['id', 'object', 'name', 'metadata', 'created_at'],
    nullableKeys: ['name'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  VaultWireFixture(
    schema: 'VaultStatusFilterParam',
    minimal: jsonDecode(r'''"active"'''),
    full: jsonDecode(r'''["active","archived"]'''),
    parse: VaultStatusFilter.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  VaultWireFixture(
    schema: 'VaultStatusParam',
    minimal: jsonDecode(r'''"active"'''),
    full: jsonDecode(r'''"archived"'''),
    parse: VaultStatus.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
];

/// Source requirements and actual exported parser for one schema.
class VaultWireFixture {
  const VaultWireFixture({
    required this.schema,
    required this.minimal,
    required this.full,
    required this.parse,
    required this.requiredKeys,
    required this.nullableKeys,
    required this.optionalNonnullKeys,
    required this.writable,
  });
  final String schema;
  final Object? minimal;
  final Object? full;
  final AgentJsonModel Function(Object?) parse;
  final List<String> requiredKeys;
  final List<String> nullableKeys;
  final List<String> optionalNonnullKeys;
  final bool writable;
}

/// Real typed copies for every concrete fixture branch, including shared values.
AgentJsonModel copyVaultFixture(AgentJsonModel model) => switch (model) {
  final AgentErrorBody value => value.copyWith(),
  final AgentErrorResponse value => value.copyWith(),
  final AgentListOrder value => value.copyWith(),
  final CreateVaultCredentialRequest value => value.copyWith(),
  final CreateVaultEnvironmentVariableAuth value => value.copyWith(),
  final CreateVaultMcpOauthAuth value => value.copyWith(),
  final CreateVaultMcpOauthRefresh value => value.copyWith(),
  final CreateVaultRequest value => value.copyWith(),
  final CreateVaultStaticBearerAuth value => value.copyWith(),
  final CreateVaultTokenEndpointClientSecretBasic value => value.copyWith(),
  final CreateVaultTokenEndpointClientSecretPost value => value.copyWith(),
  final CreateVaultTokenEndpointNone value => value.copyWith(),
  final DeletedVault value => value.copyWith(),
  final DeletedVaultCredential value => value.copyWith(),
  final RotateVaultCredentialRequest value => value.copyWith(),
  final RotateVaultEnvironmentVariableAuth value => value.copyWith(),
  final RotateVaultMcpOauthAuth value => value.copyWith(),
  final RotateVaultMcpOauthRefresh value => value.copyWith(),
  final RotateVaultStaticBearerAuth value => value.copyWith(),
  final RotateVaultTokenEndpointClientSecretBasic value => value.copyWith(),
  final RotateVaultTokenEndpointClientSecretPost value => value.copyWith(),
  final UpdateVaultRequest value => value.copyWith(),
  final Vault value => value.copyWith(),
  final VaultCredential value => value.copyWith(),
  final VaultCredentialList value => value.copyWith(),
  final VaultEnvironmentVariableAuth value => value.copyWith(),
  final VaultLimitedNetworking value => value.copyWith(),
  final VaultLimitedNetworkingResource value => value.copyWith(),
  final VaultList value => value.copyWith(),
  final VaultMcpOauthAuth value => value.copyWith(),
  final VaultMcpOauthRefresh value => value.copyWith(),
  final VaultMultipleStatuses value => value.copyWith(),
  final VaultSingleStatus value => value.copyWith(),
  final VaultStaticBearerAuth value => value.copyWith(),
  final VaultStatus value => value.copyWith(),
  final VaultTokenEndpointClientSecretBasic value => value.copyWith(),
  final VaultTokenEndpointClientSecretPost value => value.copyWith(),
  final VaultTokenEndpointNone value => value.copyWith(),
  final VaultUnrestrictedNetworking value => value.copyWith(),
  final VaultUnrestrictedNetworkingResource value => value.copyWith(),
  _ => throw StateError('Unrecognized source fixture type'),
};
