import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/connectors/auth_url_response.dart';
import '../../models/connectors/connector.dart';
import '../../models/connectors/connector_call_tool_request.dart';
import '../../models/connectors/connector_tool_call_response.dart';
import '../../models/connectors/connectors_query_filters.dart';
import '../../models/connectors/create_connector_request.dart';
import '../../models/connectors/credentials_create_or_update.dart';
import '../../models/connectors/credentials_response.dart';
import '../../models/connectors/message_response.dart';
import '../../models/connectors/outbound_authentication_type.dart';
import '../../models/connectors/public_authentication_method.dart';
import '../../models/connectors/tool_execution_configuration.dart';
import '../../models/connectors/update_connector_request.dart';
import '../base_resource.dart';

/// Resource for managing MCP connectors (Beta).
///
/// Connectors expose external Model Context Protocol (MCP) servers to agents
/// and conversations. This resource lets you create, list, update, and delete
/// connectors, manage their credentials, activate or deactivate them at the
/// organization, workspace, or user level, and call their tools.
///
/// Method names mirror the official Python SDK
/// (`mistralai.client.connectors`).
///
/// Example usage:
/// ```dart
/// // Create a connector
/// final connector = await client.connectors.create(
///   request: const CreateConnectorRequest(
///     name: 'my_connector',
///     description: 'My MCP connector',
///     server: 'https://mcp.example.com',
///   ),
/// );
///
/// // List the connector's tools
/// final tools = await client.connectors.listTools(
///   connectorIdOrName: connector.id,
/// );
///
/// // Call a tool
/// final result = await client.connectors.callTool(
///   connectorIdOrName: connector.id,
///   toolName: 'search',
///   request: const ConnectorCallToolRequest(arguments: {'q': 'mistral'}),
/// );
/// ```
class ConnectorsResource extends ResourceBase {
  /// Creates a [ConnectorsResource].
  ConnectorsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new connector.
  ///
  /// Maps to the official `connectors.create`
  /// (`POST /v1/connectors`).
  ///
  /// [request] contains the connector configuration.
  Future<Connector> create({required CreateConnectorRequest request}) async {
    final url = requestBuilder.buildUrl('/v1/connectors');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Connector.fromJson(responseBody);
  }

  /// Lists all connectors with keyset pagination and filters.
  ///
  /// Maps to the official `connectors.list` (`GET /v1/connectors`).
  ///
  /// [queryFilters] optionally filters the results.
  /// [cursor] is the pagination cursor for the next page.
  /// [pageSize] is the number of connectors per page.
  Future<PaginatedConnectors> list({
    ConnectorsQueryFilters? queryFilters,
    String? cursor,
    int? pageSize,
  }) async {
    final queryParams = <String, String>{
      if (queryFilters?.active != null)
        'active': queryFilters!.active.toString(),
      'cursor': ?cursor,
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/connectors',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedConnectors.fromJson(responseBody);
  }

  /// Retrieves a connector by its ID or name.
  ///
  /// Maps to the official `connectors.get`
  /// (`GET /v1/connectors/{connector_id_or_name}`). This single operation
  /// covers both the `{connector_id}` and `{connector_id_or_name}` path
  /// variants.
  ///
  /// [connectorIdOrName] is the unique identifier or name of the connector.
  Future<Connector> get({required String connectorIdOrName}) async {
    final url = requestBuilder.buildUrl('/v1/connectors/$connectorIdOrName');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Connector.fromJson(responseBody);
  }

  /// Updates a connector by its ID.
  ///
  /// Maps to the official `connectors.update`
  /// (`PATCH /v1/connectors/{connector_id}`).
  ///
  /// [connectorId] is the unique identifier of the connector.
  /// [request] contains the fields to update.
  Future<Connector> update({
    required String connectorId,
    required UpdateConnectorRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/connectors/$connectorId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Connector.fromJson(responseBody);
  }

  /// Deletes a connector by its ID.
  ///
  /// Maps to the official `connectors.delete`
  /// (`DELETE /v1/connectors/{connector_id}`).
  ///
  /// [connectorId] is the unique identifier of the connector to delete.
  Future<MessageResponse> delete({required String connectorId}) async {
    final url = requestBuilder.buildUrl('/v1/connectors/$connectorId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return MessageResponse.fromJson(responseBody);
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// Gets the OAuth2 authorization URL for a connector.
  ///
  /// Maps to the official `connectors.get_auth_url`
  /// (`GET /v1/connectors/{connector_id_or_name}/auth_url`).
  ///
  /// [connectorIdOrName] is the connector ID or name.
  /// [appReturnUrl] is an optional URL to return to after authorization.
  /// [methodType] selects the auth method to use.
  /// [credentialsName] selects a specific credential.
  /// [githubInstallationLink] requests a GitHub App installation URL.
  Future<AuthUrlResponse> getAuthUrl({
    required String connectorIdOrName,
    String? appReturnUrl,
    OutboundAuthenticationType? methodType,
    String? credentialsName,
    bool? githubInstallationLink,
  }) async {
    final queryParams = <String, String>{
      'app_return_url': ?appReturnUrl,
      if (methodType != null) 'method_type': methodType.value,
      'credentials_name': ?credentialsName,
      if (githubInstallationLink != null)
        'github_installation_link': githubInstallationLink.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorIdOrName/auth_url',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthUrlResponse.fromJson(responseBody);
  }

  /// Gets the supported authentication methods for a connector.
  ///
  /// Maps to the official `connectors.get_authentication_methods`
  /// (`GET /v1/connectors/{connector_id_or_name}/authentication_methods`).
  ///
  /// [connectorIdOrName] is the connector ID or name.
  Future<List<PublicAuthenticationMethod>> getAuthenticationMethods({
    required String connectorIdOrName,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorIdOrName/authentication_methods',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody
        .map(
          (e) => PublicAuthenticationMethod.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Tools
  // ---------------------------------------------------------------------------

  /// Lists the tools available on a connector.
  ///
  /// Maps to the official `connectors.list_tools`
  /// (`GET /v1/connectors/{connector_id_or_name}/tools`).
  ///
  /// The response is an open union of tool shapes (full [ConnectorTool]
  /// objects, MCP tools, or — when [pretty] is true — a simplified payload),
  /// so the raw list of JSON objects is returned.
  ///
  /// [connectorIdOrName] is the connector ID or name.
  /// [page] is the page number to retrieve.
  /// [pageSize] is the number of tools per page.
  /// [refresh] forces a refresh of the connector's tool list.
  /// [pretty] returns a simplified payload.
  /// [credentialsName] selects a specific credential.
  Future<List<Map<String, dynamic>>> listTools({
    required String connectorIdOrName,
    int? page,
    int? pageSize,
    bool? refresh,
    bool? pretty,
    String? credentialsName,
  }) async {
    final queryParams = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (refresh != null) 'refresh': refresh.toString(),
      if (pretty != null) 'pretty': pretty.toString(),
      'credentials_name': ?credentialsName,
    };

    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorIdOrName/tools',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Calls a tool on a connector.
  ///
  /// Maps to the official `connectors.call_tool`
  /// (`POST /v1/connectors/{connector_id_or_name}/tools/{tool_name}/call`).
  ///
  /// [connectorIdOrName] is the connector ID or name.
  /// [toolName] is the name of the tool to call.
  /// [request] contains the tool arguments.
  /// [credentialsName] selects a specific credential.
  Future<ConnectorToolCallResponse> callTool({
    required String connectorIdOrName,
    required String toolName,
    ConnectorCallToolRequest request = const ConnectorCallToolRequest(),
    String? credentialsName,
  }) async {
    final queryParams = <String, String>{'credentials_name': ?credentialsName};

    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorIdOrName/tools/$toolName/call',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ConnectorToolCallResponse.fromJson(responseBody);
  }

  // ---------------------------------------------------------------------------
  // Credentials
  // ---------------------------------------------------------------------------

  /// Lists organization-level credentials for a connector.
  ///
  /// Maps to the official `connectors.list_organization_credentials`
  /// (`GET /v1/connectors/{connector_id_or_name}/organization/credentials`).
  Future<CredentialsResponse> listOrganizationCredentials({
    required String connectorIdOrName,
    OutboundAuthenticationType? authType,
    bool? fetchDefault,
  }) => _listCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'organization',
    authType: authType,
    fetchDefault: fetchDefault,
  );

  /// Lists workspace-level credentials for a connector.
  ///
  /// Maps to the official `connectors.list_workspace_credentials`
  /// (`GET /v1/connectors/{connector_id_or_name}/workspace/credentials`).
  Future<CredentialsResponse> listWorkspaceCredentials({
    required String connectorIdOrName,
    OutboundAuthenticationType? authType,
    bool? fetchDefault,
  }) => _listCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'workspace',
    authType: authType,
    fetchDefault: fetchDefault,
  );

  /// Lists user-level credentials for a connector.
  ///
  /// Maps to the official `connectors.list_user_credentials`
  /// (`GET /v1/connectors/{connector_id_or_name}/user/credentials`).
  Future<CredentialsResponse> listUserCredentials({
    required String connectorIdOrName,
    OutboundAuthenticationType? authType,
    bool? fetchDefault,
  }) => _listCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'user',
    authType: authType,
    fetchDefault: fetchDefault,
  );

  Future<CredentialsResponse> _listCredentials({
    required String connectorIdOrName,
    required String level,
    OutboundAuthenticationType? authType,
    bool? fetchDefault,
  }) async {
    final queryParams = <String, String>{
      if (authType != null) 'auth_type': authType.value,
      if (fetchDefault != null) 'fetch_default': fetchDefault.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorIdOrName/$level/credentials',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CredentialsResponse.fromJson(responseBody);
  }

  /// Creates or updates organization-level credentials for a connector.
  ///
  /// Maps to the official `connectors.create_or_update_organization_credentials`
  /// (`POST /v1/connectors/{connector_id_or_name}/organization/credentials`).
  Future<MessageResponse> createOrUpdateOrganizationCredentials({
    required String connectorIdOrName,
    required CredentialsCreateOrUpdate request,
  }) => _createOrUpdateCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'organization',
    request: request,
  );

  /// Creates or updates workspace-level credentials for a connector.
  ///
  /// Maps to the official `connectors.create_or_update_workspace_credentials`
  /// (`POST /v1/connectors/{connector_id_or_name}/workspace/credentials`).
  Future<MessageResponse> createOrUpdateWorkspaceCredentials({
    required String connectorIdOrName,
    required CredentialsCreateOrUpdate request,
  }) => _createOrUpdateCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'workspace',
    request: request,
  );

  /// Creates or updates user-level credentials for a connector.
  ///
  /// Maps to the official `connectors.create_or_update_user_credentials`
  /// (`POST /v1/connectors/{connector_id_or_name}/user/credentials`).
  Future<MessageResponse> createOrUpdateUserCredentials({
    required String connectorIdOrName,
    required CredentialsCreateOrUpdate request,
  }) => _createOrUpdateCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'user',
    request: request,
  );

  Future<MessageResponse> _createOrUpdateCredentials({
    required String connectorIdOrName,
    required String level,
    required CredentialsCreateOrUpdate request,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorIdOrName/$level/credentials',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return MessageResponse.fromJson(responseBody);
  }

  /// Deletes organization-level credentials for a connector.
  ///
  /// Maps to the official `connectors.delete_organization_credentials`
  /// (`DELETE /v1/connectors/{connector_id_or_name}/organization/credentials/`
  /// `{credentials_name}`).
  Future<MessageResponse> deleteOrganizationCredentials({
    required String connectorIdOrName,
    required String credentialsName,
  }) => _deleteCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'organization',
    credentialsName: credentialsName,
  );

  /// Deletes workspace-level credentials for a connector.
  ///
  /// Maps to the official `connectors.delete_workspace_credentials`
  /// (`DELETE /v1/connectors/{connector_id_or_name}/workspace/credentials/`
  /// `{credentials_name}`).
  Future<MessageResponse> deleteWorkspaceCredentials({
    required String connectorIdOrName,
    required String credentialsName,
  }) => _deleteCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'workspace',
    credentialsName: credentialsName,
  );

  /// Deletes user-level credentials for a connector.
  ///
  /// Maps to the official `connectors.delete_user_credentials`
  /// (`DELETE /v1/connectors/{connector_id_or_name}/user/credentials/`
  /// `{credentials_name}`).
  Future<MessageResponse> deleteUserCredentials({
    required String connectorIdOrName,
    required String credentialsName,
  }) => _deleteCredentials(
    connectorIdOrName: connectorIdOrName,
    level: 'user',
    credentialsName: credentialsName,
  );

  Future<MessageResponse> _deleteCredentials({
    required String connectorIdOrName,
    required String level,
    required String credentialsName,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorIdOrName/$level/credentials/$credentialsName',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return MessageResponse.fromJson(responseBody);
  }

  // ---------------------------------------------------------------------------
  // Activation
  // ---------------------------------------------------------------------------

  /// Activates a connector for the organization.
  ///
  /// Maps to the official `connectors.activate_for_organization`
  /// (`POST /v1/connectors/{connector_id}/organization/activate`).
  ///
  /// [connectorId] is the connector ID.
  /// [toolConfiguration] optionally configures tool execution.
  Future<MessageResponse> activateForOrganization({
    required String connectorId,
    ToolExecutionConfiguration? toolConfiguration,
  }) => _activate(
    connectorId: connectorId,
    level: 'organization',
    toolConfiguration: toolConfiguration,
  );

  /// Deactivates a connector for the organization.
  ///
  /// Maps to the official `connectors.deactivate_for_organization`
  /// (`POST /v1/connectors/{connector_id}/organization/deactivate`).
  Future<MessageResponse> deactivateForOrganization({
    required String connectorId,
  }) => _deactivate(connectorId: connectorId, level: 'organization');

  /// Activates a connector for the workspace.
  ///
  /// Maps to the official `connectors.activate_for_workspace`
  /// (`POST /v1/connectors/{connector_id}/workspace/activate`).
  Future<MessageResponse> activateForWorkspace({
    required String connectorId,
    ToolExecutionConfiguration? toolConfiguration,
  }) => _activate(
    connectorId: connectorId,
    level: 'workspace',
    toolConfiguration: toolConfiguration,
  );

  /// Deactivates a connector for the workspace.
  ///
  /// Maps to the official `connectors.deactivate_for_workspace`
  /// (`POST /v1/connectors/{connector_id}/workspace/deactivate`).
  Future<MessageResponse> deactivateForWorkspace({
    required String connectorId,
  }) => _deactivate(connectorId: connectorId, level: 'workspace');

  /// Activates a connector for the current user.
  ///
  /// Maps to the official `connectors.activate_for_user`
  /// (`POST /v1/connectors/{connector_id}/user/activate`).
  Future<MessageResponse> activateForUser({
    required String connectorId,
    ToolExecutionConfiguration? toolConfiguration,
  }) => _activate(
    connectorId: connectorId,
    level: 'user',
    toolConfiguration: toolConfiguration,
  );

  /// Deactivates a connector for the current user.
  ///
  /// Maps to the official `connectors.deactivate_for_user`
  /// (`POST /v1/connectors/{connector_id}/user/deactivate`).
  Future<MessageResponse> deactivateForUser({required String connectorId}) =>
      _deactivate(connectorId: connectorId, level: 'user');

  Future<MessageResponse> _activate({
    required String connectorId,
    required String level,
    ToolExecutionConfiguration? toolConfiguration,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorId/$level/activate',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(toolConfiguration?.toJson() ?? const {});

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return MessageResponse.fromJson(responseBody);
  }

  Future<MessageResponse> _deactivate({
    required String connectorId,
    required String level,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/connectors/$connectorId/$level/deactivate',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return MessageResponse.fromJson(responseBody);
  }
}
