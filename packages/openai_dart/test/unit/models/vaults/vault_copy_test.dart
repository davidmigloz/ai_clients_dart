import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'CreateVaultMcpOauthRefresh.clientId: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client_alternate","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(clientId: replacement.clientId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultMcpOauthRefresh.refreshToken: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN_alternate","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(refreshToken: replacement.refreshToken);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultMcpOauthRefresh.resource: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp_alternate","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(resource: replacement.resource);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(resource: null);
      expect(cleared.toJson().containsKey('resource'), isTrue);
      expect(cleared.toJson()['resource'], isNull);
      final omitted = original.copyWith(resource: null, clearResource: false);
      expect(omitted.toJson().containsKey('resource'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(resource: original.resource);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(resource: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateVaultMcpOauthRefresh.scope: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write_alternate","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(scope: replacement.scope);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(scope: null);
      expect(cleared.toJson().containsKey('scope'), isTrue);
      expect(cleared.toJson()['scope'], isNull);
      final omitted = original.copyWith(scope: null, clearScope: false);
      expect(omitted.toJson().containsKey('scope'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(scope: original.scope);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(scope: Object()), throwsFormatException);
    },
  );
  test(
    'CreateVaultMcpOauthRefresh.tokenEndpoint: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp_alternate","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        tokenEndpoint: replacement.tokenEndpoint,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultMcpOauthRefresh.tokenEndpointAuth: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        tokenEndpointAuth: replacement.tokenEndpointAuth,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultTokenEndpointClientSecretBasic.clientSecret: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultTokenEndpointClientSecretBasic.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_basic"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultTokenEndpointClientSecretBasic.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET_alternate","type":"client_secret_basic"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(clientSecret: replacement.clientSecret);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultTokenEndpointClientSecretPost.clientSecret: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultTokenEndpointClientSecretPost.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultTokenEndpointClientSecretPost.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET_alternate","type":"client_secret_post"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(clientSecret: replacement.clientSecret);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultEnvironmentVariableAuth.networking: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(networking: replacement.networking);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultEnvironmentVariableAuth.secretName: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY_alternate","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(secretName: replacement.secretName);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultEnvironmentVariableAuth.secretValue: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE_alternate","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(secretValue: replacement.secretValue);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultMcpOauthAuth.accessToken: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN_alternate","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(accessToken: replacement.accessToken);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultMcpOauthAuth.expiresAt: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z_alternate","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(expiresAt: replacement.expiresAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(expiresAt: null);
      expect(cleared.toJson().containsKey('expires_at'), isTrue);
      expect(cleared.toJson()['expires_at'], isNull);
      final omitted = original.copyWith(expiresAt: null, clearExpiresAt: false);
      expect(omitted.toJson().containsKey('expires_at'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(expiresAt: original.expiresAt);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(expiresAt: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateVaultMcpOauthAuth.mcpServerUrl: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp_alternate","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(mcpServerUrl: replacement.mcpServerUrl);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultMcpOauthAuth.refresh: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"token_endpoint":"https://api.example.com/mcp","client_id":"public-synthetic-client","refresh_token":"PRIVATE-REFRESH_TOKEN","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(refresh: replacement.refresh);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(refresh: null);
      expect(cleared.toJson().containsKey('refresh'), isTrue);
      expect(cleared.toJson()['refresh'], isNull);
      final omitted = original.copyWith(refresh: null, clearRefresh: false);
      expect(omitted.toJson().containsKey('refresh'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(refresh: original.refresh);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(refresh: Object()), throwsFormatException);
    },
  );
  test(
    'CreateVaultStaticBearerAuth.mcpServerUrl: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultStaticBearerAuth.fromJson(
        jsonDecode(
              r'''{"mcp_server_url":"https://api.example.com/mcp","token":"PRIVATE-TOKEN","type":"static_bearer"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultStaticBearerAuth.fromJson(
        jsonDecode(
              r'''{"mcp_server_url":"https://api.example.com/mcp_alternate","token":"PRIVATE-TOKEN","type":"static_bearer"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(mcpServerUrl: replacement.mcpServerUrl);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultStaticBearerAuth.token: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultStaticBearerAuth.fromJson(
        jsonDecode(
              r'''{"mcp_server_url":"https://api.example.com/mcp","token":"PRIVATE-TOKEN","type":"static_bearer"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultStaticBearerAuth.fromJson(
        jsonDecode(
              r'''{"mcp_server_url":"https://api.example.com/mcp","token":"PRIVATE-TOKEN_alternate","type":"static_bearer"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(token: replacement.token);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultCredentialRequest.auth: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"type":"mcp_oauth","mcp_server_url":"https://api.example.com/mcp","access_token":"PRIVATE-ACCESS_TOKEN"},"metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(auth: replacement.auth);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultCredentialRequest.metadata: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"alternate":"PRIVATE-new-metadata"},"name":"Credential café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(metadata: replacement.metadata);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(metadata: null);
      expect(cleared.toJson().containsKey('metadata'), isFalse);
      expect(
        () => original.copyWith(metadata: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateVaultCredentialRequest.name: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateVaultRequest.metadata: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"alternate":"PRIVATE-new-metadata"},"name":"Vault café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(metadata: replacement.metadata);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(metadata: null);
      expect(cleared.toJson().containsKey('metadata'), isTrue);
      expect(cleared.toJson()['metadata'], isNull);
      final omitted = original.copyWith(metadata: null, clearMetadata: false);
      expect(omitted.toJson().containsKey('metadata'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(metadata: original.metadata);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(metadata: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateVaultRequest.name: replacement, full equality/hash and copy presence',
    () {
      final original = CreateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(name: null);
      expect(cleared.toJson().containsKey('name'), isFalse);
      expect(() => original.copyWith(name: Object()), throwsFormatException);
    },
  );
  test(
    'DeletedVaultCredential.deleted: replacement, full equality/hash and copy presence',
    () {
      final original = DeletedVaultCredential.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"credential_1","object":"vault.credential.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = DeletedVaultCredential.fromJson(
        jsonDecode(
              r'''{"deleted":false,"id":"credential_1","object":"vault.credential.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(deleted: replacement.deleted);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'DeletedVaultCredential.id: replacement, full equality/hash and copy presence',
    () {
      final original = DeletedVaultCredential.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"credential_1","object":"vault.credential.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = DeletedVaultCredential.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"credential_1_alternate","object":"vault.credential.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'DeletedVault.deleted: replacement, full equality/hash and copy presence',
    () {
      final original = DeletedVault.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"vault_1","object":"vault.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = DeletedVault.fromJson(
        jsonDecode(
              r'''{"deleted":false,"id":"vault_1","object":"vault.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(deleted: replacement.deleted);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test('DeletedVault.id: replacement, full equality/hash and copy presence', () {
    final original = DeletedVault.fromJson(
      jsonDecode(
            r'''{"deleted":true,"id":"vault_1","object":"vault.deleted"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = DeletedVault.fromJson(
      jsonDecode(
            r'''{"deleted":true,"id":"vault_1_alternate","object":"vault.deleted"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(id: replacement.id);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
  });
  test(
    'VaultMcpOauthRefresh.clientId: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client_alternate","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(clientId: replacement.clientId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultMcpOauthRefresh.resource: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp_alternate","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(resource: replacement.resource);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(resource: null);
      expect(cleared.toJson().containsKey('resource'), isTrue);
      expect(cleared.toJson()['resource'], isNull);
      expect(
        () => original.copyWith(resource: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'VaultMcpOauthRefresh.scope: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write_alternate","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(scope: replacement.scope);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(scope: null);
      expect(cleared.toJson().containsKey('scope'), isTrue);
      expect(cleared.toJson()['scope'], isNull);
      expect(() => original.copyWith(scope: Object()), throwsFormatException);
    },
  );
  test(
    'VaultMcpOauthRefresh.tokenEndpoint: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp_alternate","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        tokenEndpoint: replacement.tokenEndpoint,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultMcpOauthRefresh.tokenEndpointAuth: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        tokenEndpointAuth: replacement.tokenEndpointAuth,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'RotateVaultMcpOauthRefresh.refreshToken: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"refresh_token":"PRIVATE-REFRESH_TOKEN_alternate","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(refreshToken: replacement.refreshToken);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(refreshToken: null);
      expect(cleared.toJson().containsKey('refresh_token'), isTrue);
      expect(cleared.toJson()['refresh_token'], isNull);
      final omitted = original.copyWith(
        refreshToken: null,
        clearRefreshToken: false,
      );
      expect(omitted.toJson().containsKey('refresh_token'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(refreshToken: original.refreshToken);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(refreshToken: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'RotateVaultMcpOauthRefresh.scope: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write_alternate","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(scope: replacement.scope);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(scope: null);
      expect(cleared.toJson().containsKey('scope'), isTrue);
      expect(cleared.toJson()['scope'], isNull);
      final omitted = original.copyWith(scope: null, clearScope: false);
      expect(omitted.toJson().containsKey('scope'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(scope: original.scope);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(scope: Object()), throwsFormatException);
    },
  );
  test(
    'RotateVaultMcpOauthRefresh.tokenEndpointAuth: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultMcpOauthRefresh.fromJson(
        jsonDecode(
              r'''{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"type":"client_secret_basic"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        tokenEndpointAuth: replacement.tokenEndpointAuth,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(tokenEndpointAuth: null);
      expect(cleared.toJson().containsKey('token_endpoint_auth'), isTrue);
      expect(cleared.toJson()['token_endpoint_auth'], isNull);
      final omitted = original.copyWith(
        tokenEndpointAuth: null,
        clearTokenEndpointAuth: false,
      );
      expect(omitted.toJson().containsKey('token_endpoint_auth'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(
        tokenEndpointAuth: original.tokenEndpointAuth,
      );
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(tokenEndpointAuth: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'RotateVaultTokenEndpointClientSecretBasic.clientSecret: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultTokenEndpointClientSecretBasic.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_basic"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultTokenEndpointClientSecretBasic.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET_alternate","type":"client_secret_basic"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(clientSecret: replacement.clientSecret);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(clientSecret: null);
      expect(cleared.toJson().containsKey('client_secret'), isTrue);
      expect(cleared.toJson()['client_secret'], isNull);
      final omitted = original.copyWith(
        clientSecret: null,
        clearClientSecret: false,
      );
      expect(omitted.toJson().containsKey('client_secret'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(clientSecret: original.clientSecret);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(clientSecret: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'RotateVaultTokenEndpointClientSecretPost.clientSecret: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultTokenEndpointClientSecretPost.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultTokenEndpointClientSecretPost.fromJson(
        jsonDecode(
              r'''{"client_secret":"PRIVATE-CLIENT_SECRET_alternate","type":"client_secret_post"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(clientSecret: replacement.clientSecret);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(clientSecret: null);
      expect(cleared.toJson().containsKey('client_secret'), isTrue);
      expect(cleared.toJson()['client_secret'], isNull);
      final omitted = original.copyWith(
        clientSecret: null,
        clearClientSecret: false,
      );
      expect(omitted.toJson().containsKey('client_secret'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(clientSecret: original.clientSecret);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(clientSecret: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'RotateVaultEnvironmentVariableAuth.secretValue: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"secret_value":"PRIVATE-SECRET_VALUE_alternate","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(secretValue: replacement.secretValue);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'RotateVaultMcpOauthAuth.accessToken: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","refresh":{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN_alternate","expires_at":"2030-01-01T00:00:00Z","refresh":{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(accessToken: replacement.accessToken);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(accessToken: null);
      expect(cleared.toJson().containsKey('access_token'), isTrue);
      expect(cleared.toJson()['access_token'], isNull);
      final omitted = original.copyWith(
        accessToken: null,
        clearAccessToken: false,
      );
      expect(omitted.toJson().containsKey('access_token'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(accessToken: original.accessToken);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(accessToken: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'RotateVaultMcpOauthAuth.expiresAt: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","refresh":{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z_alternate","refresh":{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(expiresAt: replacement.expiresAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(expiresAt: null);
      expect(cleared.toJson().containsKey('expires_at'), isTrue);
      expect(cleared.toJson()['expires_at'], isNull);
      final omitted = original.copyWith(expiresAt: null, clearExpiresAt: false);
      expect(omitted.toJson().containsKey('expires_at'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(expiresAt: original.expiresAt);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(expiresAt: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'RotateVaultMcpOauthAuth.refresh: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","refresh":{"refresh_token":"PRIVATE-REFRESH_TOKEN","scope":"read write","token_endpoint_auth":{"client_secret":"PRIVATE-CLIENT_SECRET","type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"access_token":"PRIVATE-ACCESS_TOKEN","expires_at":"2030-01-01T00:00:00Z","refresh":{},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(refresh: replacement.refresh);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(refresh: null);
      expect(cleared.toJson().containsKey('refresh'), isTrue);
      expect(cleared.toJson()['refresh'], isNull);
      final omitted = original.copyWith(refresh: null, clearRefresh: false);
      expect(omitted.toJson().containsKey('refresh'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(refresh: original.refresh);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(refresh: Object()), throwsFormatException);
    },
  );
  test(
    'RotateVaultStaticBearerAuth.token: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultStaticBearerAuth.fromJson(
        jsonDecode(r'''{"token":"PRIVATE-TOKEN","type":"static_bearer"}''')
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultStaticBearerAuth.fromJson(
        jsonDecode(
              r'''{"token":"PRIVATE-TOKEN_alternate","type":"static_bearer"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(token: replacement.token);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'RotateVaultCredentialRequest.auth: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"type":"mcp_oauth"},"metadata":{"user_id":"PRIVATE-metadata"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(auth: replacement.auth);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(auth: null);
      expect(cleared.toJson().containsKey('auth'), isFalse);
      expect(() => original.copyWith(auth: Object()), throwsFormatException);
    },
  );
  test(
    'RotateVaultCredentialRequest.metadata: replacement, full equality/hash and copy presence',
    () {
      final original = RotateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"user_id":"PRIVATE-metadata"}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = RotateVaultCredentialRequest.fromJson(
        jsonDecode(
              r'''{"auth":{"secret_value":"PRIVATE-SECRET_VALUE","type":"environment_variable"},"metadata":{"alternate":"PRIVATE-new-metadata"}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(metadata: replacement.metadata);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(metadata: null);
      expect(cleared.toJson().containsKey('metadata'), isFalse);
      expect(
        () => original.copyWith(metadata: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'UpdateVaultRequest.metadata: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"alternate":"PRIVATE-new-metadata"},"name":"Vault café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(metadata: replacement.metadata);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(metadata: null);
      expect(cleared.toJson().containsKey('metadata'), isFalse);
      expect(
        () => original.copyWith(metadata: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'UpdateVaultRequest.name: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateVaultRequest.fromJson(
        jsonDecode(
              r'''{"metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(name: null);
      expect(cleared.toJson().containsKey('name'), isTrue);
      expect(cleared.toJson()['name'], isNull);
      final omitted = original.copyWith(name: null, clearName: false);
      expect(omitted.toJson().containsKey('name'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(name: original.name);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(name: Object()), throwsFormatException);
    },
  );
  test(
    'VaultEnvironmentVariableAuth.networking: replacement, full equality/hash and copy presence',
    () {
      final original = VaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(networking: replacement.networking);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultEnvironmentVariableAuth.secretName: replacement, full equality/hash and copy presence',
    () {
      final original = VaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultEnvironmentVariableAuth.fromJson(
        jsonDecode(
              r'''{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY_alternate","type":"environment_variable"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(secretName: replacement.secretName);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultMcpOauthAuth.expiresAt: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"expires_at":"2030-01-01T00:00:00Z_alternate","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(expiresAt: replacement.expiresAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(expiresAt: null);
      expect(cleared.toJson().containsKey('expires_at'), isTrue);
      expect(cleared.toJson()['expires_at'], isNull);
      expect(
        () => original.copyWith(expiresAt: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'VaultMcpOauthAuth.mcpServerUrl: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp_alternate","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(mcpServerUrl: replacement.mcpServerUrl);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultMcpOauthAuth.refresh: replacement, full equality/hash and copy presence',
    () {
      final original = VaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultMcpOauthAuth.fromJson(
        jsonDecode(
              r'''{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"token_endpoint":"","client_id":"public-synthetic-client","resource":null,"scope":null,"token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(refresh: replacement.refresh);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(refresh: null);
      expect(cleared.toJson().containsKey('refresh'), isTrue);
      expect(cleared.toJson()['refresh'], isNull);
      expect(() => original.copyWith(refresh: Object()), throwsFormatException);
    },
  );
  test(
    'VaultStaticBearerAuth.mcpServerUrl: replacement, full equality/hash and copy presence',
    () {
      final original = VaultStaticBearerAuth.fromJson(
        jsonDecode(
              r'''{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultStaticBearerAuth.fromJson(
        jsonDecode(
              r'''{"mcp_server_url":"https://api.example.com/mcp_alternate","type":"static_bearer"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(mcpServerUrl: replacement.mcpServerUrl);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredentialList.data: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1","has_more":true,"last_id":"credential_7","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"credential_1","object":"vault.credential","vault_id":"vault_1","name":"Credential café🚀","auth":{"type":"mcp_oauth","mcp_server_url":"","expires_at":null,"refresh":null},"metadata":{},"created_at":0,"updated_at":0}],"first_id":"credential_1","has_more":true,"last_id":"credential_7","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredentialList.firstId: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1","has_more":true,"last_id":"credential_7","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1_alternate","has_more":true,"last_id":"credential_7","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(firstId: replacement.firstId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(firstId: null);
      expect(cleared.toJson().containsKey('first_id'), isTrue);
      expect(cleared.toJson()['first_id'], isNull);
      expect(() => original.copyWith(firstId: Object()), throwsFormatException);
    },
  );
  test(
    'VaultCredentialList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1","has_more":true,"last_id":"credential_7","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1","has_more":false,"last_id":"credential_7","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredentialList.lastId: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1","has_more":true,"last_id":"credential_7","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredentialList.fromJson(
        jsonDecode(
              r'''{"data":[{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"none"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_2","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_basic"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_3","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"expires_at":"2030-01-01T00:00:00Z","mcp_server_url":"https://api.example.com/mcp","refresh":{"client_id":"public-synthetic-client","resource":"https://api.example.com/mcp","scope":"read write","token_endpoint":"https://api.example.com/mcp","token_endpoint_auth":{"type":"client_secret_post"}},"type":"mcp_oauth"},"created_at":1700000000,"id":"credential_4","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"mcp_server_url":"https://api.example.com/mcp","type":"static_bearer"},"created_at":1700000000,"id":"credential_5","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_6","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"},{"auth":{"networking":{"type":"unrestricted"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_7","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}],"first_id":"credential_1","has_more":true,"last_id":"credential_7_alternate","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(lastId: replacement.lastId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(lastId: null);
      expect(cleared.toJson().containsKey('last_id'), isTrue);
      expect(cleared.toJson()['last_id'], isNull);
      expect(() => original.copyWith(lastId: Object()), throwsFormatException);
    },
  );
  test(
    'VaultLimitedNetworking.allowedHosts: replacement, full equality/hash and copy presence',
    () {
      final original = VaultLimitedNetworking.fromJson(
        jsonDecode(
              r'''{"allowed_hosts":["api.example.com"],"type":"limited"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultLimitedNetworking.fromJson(
        jsonDecode(
              r'''{"allowed_hosts":["next.example.com"],"type":"limited"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(allowedHosts: replacement.allowedHosts);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultLimitedNetworkingResource.allowedHosts: replacement, full equality/hash and copy presence',
    () {
      final original = VaultLimitedNetworkingResource.fromJson(
        jsonDecode(
              r'''{"allowed_hosts":["api.example.com"],"type":"limited"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultLimitedNetworkingResource.fromJson(
        jsonDecode(
              r'''{"allowed_hosts":["next.example.com"],"type":"limited"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(allowedHosts: replacement.allowedHosts);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredential.auth: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"type":"mcp_oauth","mcp_server_url":"","expires_at":null,"refresh":null},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(auth: replacement.auth);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredential.createdAt: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000001,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(createdAt: replacement.createdAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test('VaultCredential.id: replacement, full equality/hash and copy presence', () {
    final original = VaultCredential.fromJson(
      jsonDecode(
            r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = VaultCredential.fromJson(
      jsonDecode(
            r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1_alternate","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(id: replacement.id);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
  });
  test(
    'VaultCredential.metadata: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"alternate":"PRIVATE-new-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(metadata: replacement.metadata);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredential.name: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀_alternate","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredential.updatedAt: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000001,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(updatedAt: replacement.updatedAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'VaultCredential.vaultId: replacement, full equality/hash and copy presence',
    () {
      final original = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = VaultCredential.fromJson(
        jsonDecode(
              r'''{"auth":{"networking":{"allowed_hosts":["api.example.com"],"type":"limited"},"secret_name":"SERVICE_API_KEY","type":"environment_variable"},"created_at":1700000000,"id":"credential_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Credential café🚀","object":"vault.credential","updated_at":1700000000,"vault_id":"vault_1_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(vaultId: replacement.vaultId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test('VaultList.data: replacement, full equality/hash and copy presence', () {
    final original = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1","has_more":true,"last_id":"vault_1","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"id":"vault_1","object":"vault","name":null,"metadata":{},"created_at":0}],"first_id":"vault_1","has_more":true,"last_id":"vault_1","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(data: replacement.data);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
  });
  test('VaultList.firstId: replacement, full equality/hash and copy presence', () {
    final original = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1","has_more":true,"last_id":"vault_1","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1_alternate","has_more":true,"last_id":"vault_1","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(firstId: replacement.firstId);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
    final cleared = original.copyWith(firstId: null);
    expect(cleared.toJson().containsKey('first_id'), isTrue);
    expect(cleared.toJson()['first_id'], isNull);
    expect(() => original.copyWith(firstId: Object()), throwsFormatException);
  });
  test('VaultList.hasMore: replacement, full equality/hash and copy presence', () {
    final original = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1","has_more":true,"last_id":"vault_1","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1","has_more":false,"last_id":"vault_1","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(hasMore: replacement.hasMore);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
  });
  test('VaultList.lastId: replacement, full equality/hash and copy presence', () {
    final original = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1","has_more":true,"last_id":"vault_1","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = VaultList.fromJson(
      jsonDecode(
            r'''{"data":[{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}],"first_id":"vault_1","has_more":true,"last_id":"vault_1_alternate","object":"list"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(lastId: replacement.lastId);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
    final cleared = original.copyWith(lastId: null);
    expect(cleared.toJson().containsKey('last_id'), isTrue);
    expect(cleared.toJson()['last_id'], isNull);
    expect(() => original.copyWith(lastId: Object()), throwsFormatException);
  });
  test('Vault.createdAt: replacement, full equality/hash and copy presence', () {
    final original = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000001,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(createdAt: replacement.createdAt);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
  });
  test('Vault.id: replacement, full equality/hash and copy presence', () {
    final original = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000000,"id":"vault_1_alternate","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(id: replacement.id);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
  });
  test('Vault.metadata: replacement, full equality/hash and copy presence', () {
    final original = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000000,"id":"vault_1","metadata":{"alternate":"PRIVATE-new-metadata"},"name":"Vault café🚀","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(metadata: replacement.metadata);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
  });
  test('Vault.name: replacement, full equality/hash and copy presence', () {
    final original = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final replacement = Vault.fromJson(
      jsonDecode(
            r'''{"created_at":1700000000,"id":"vault_1","metadata":{"user_id":"PRIVATE-metadata"},"name":"Vault café🚀_alternate","object":"vault"}''',
          )
          as Map<String, dynamic>,
    );
    final result = original.copyWith(name: replacement.name);
    expect(result.toJson(), replacement.toJson());
    expect(result, replacement);
    expect(result.hashCode, replacement.hashCode);
    expect(result, isNot(original));
    expect(original.copyWith().toJson(), original.toJson());
    final cleared = original.copyWith(name: null);
    expect(cleared.toJson().containsKey('name'), isTrue);
    expect(cleared.toJson()['name'], isNull);
    expect(() => original.copyWith(name: Object()), throwsFormatException);
  });
}
