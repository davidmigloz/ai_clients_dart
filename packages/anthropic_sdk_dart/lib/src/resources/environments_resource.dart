import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/environments/agent_environment.dart';
import '../models/managed_agents/environments/environment_params.dart';
import 'base_resource.dart';
import 'environment_work_resource.dart';

/// Manages the environments where Claude Managed Agents sessions run.
///
/// The required Managed Agents beta header is sent automatically. Use the
/// configured workspace or provide a workspace override for a request.
class EnvironmentsResource extends ResourceBase {
  /// Creates an [EnvironmentsResource].
  EnvironmentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Accesses the work queue for a self-hosted environment.
  ///
  /// Set [bearerToken] to send only that scoped credential on worker routes.
  EnvironmentWorkResource work(String environmentId, {String? bearerToken}) =>
      EnvironmentWorkResource(
        environmentId: environmentId,
        bearerToken: bearerToken,
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
      );

  /// Creates a cloud or self-hosted environment.
  Future<AgentEnvironment> create(
    CreateEnvironmentParams request, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    '/v1/environments',
    AgentEnvironment.fromJson,
    body: request.toJson(),
    workspaceId: workspaceId,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Gets an environment by ID.
  Future<AgentEnvironment> retrieve(
    String environmentId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    _path(environmentId),
    AgentEnvironment.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Updates an environment. Omitted fields retain their server values.
  Future<AgentEnvironment> update(
    String environmentId,
    UpdateEnvironmentParams request, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    _path(environmentId),
    AgentEnvironment.fromJson,
    body: request.toJson(),
    workspaceId: workspaceId,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Lists environments. Pass [EnvironmentListResponse.nextPage] as [page]
  /// to continue after the current page.
  Future<EnvironmentListResponse> list({
    int? limit,
    String? page,
    bool? includeArchived,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    '/v1/environments',
    EnvironmentListResponse.fromJson,
    query: {
      'limit': ?limit?.toString(),
      'page': ?page,
      'include_archived': ?includeArchived?.toString(),
    },
    workspaceId: workspaceId,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Deletes an environment. Existing references can prevent deletion.
  Future<EnvironmentDeleteResponse> delete(
    String environmentId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'DELETE',
    _path(environmentId),
    EnvironmentDeleteResponse.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Archives an environment so it cannot be used for new sessions.
  Future<AgentEnvironment> archive(
    String environmentId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    '${_path(environmentId)}/archive',
    AgentEnvironment.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  String _path(String environmentId) {
    if (environmentId.isEmpty) {
      throw ArgumentError.value(environmentId, 'environmentId', 'is empty');
    }
    return '/v1/environments/${Uri.encodeComponent(environmentId)}';
  }

  Future<T> _send<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parse, {
    required String? workspaceId,
    required List<String> betas,
    required Future<void>? abortTrigger,
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    ensureNotClosed?.call();
    final request =
        http.Request(method, requestBuilder.buildUrl(path, queryParams: query))
          ..headers.addAll(
            requestBuilder.buildHeaders(
              additionalHeaders: {
                'anthropic-beta': {
                  ...betas,
                  'managed-agents-2026-04-01',
                }.join(','),
                'anthropic-workspace-id': ?workspaceId,
              },
            ),
          );
    if (body != null) request.body = jsonEncode(body);
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return parse(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
