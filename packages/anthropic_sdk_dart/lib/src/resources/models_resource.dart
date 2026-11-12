import 'package:http/http.dart' as http;

import '../errors/response_error.dart';
import '../models/models/model_info.dart';
import '../utils/path_segment.dart';
import 'base_resource.dart';

/// Resource for the Models API.
///
/// The Models API allows you to list and retrieve information
/// about available Claude models.
class ModelsResource extends ResourceBase {
  /// Creates a [ModelsResource].
  ModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists available models.
  ///
  /// Returns a paginated list of models available to your organization.
  ///
  /// Parameters:
  /// - [beforeId]: Return models before this ID for pagination.
  /// - [afterId]: Return models after this ID for pagination.
  /// - [limit]: Maximum number of models to return (default: 20).
  /// - [lifecycle]: Return models in any of these stages. If omitted, the API
  ///   includes active and deprecated models. Request [ModelLifecycle.retired]
  ///   explicitly to include retired models.
  /// - [betas]: Beta features to request, such as `compact-2026-09-04`.
  /// - [workspaceId]: Select a workspace when the credential can act on more
  ///   than one workspace. For workspace-scoped credentials, omit it or use
  ///   the credential's workspace.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ModelListResponse> list({
    String? beforeId,
    String? afterId,
    int? limit,
    List<ModelLifecycle> lifecycle = const [],
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{};
    if (beforeId != null) queryParams['before_id'] = beforeId;
    if (afterId != null) queryParams['after_id'] = afterId;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (lifecycle.isNotEmpty) {
      queryParams['lifecycle[]'] = lifecycle
          .map((stage) => stage.toJson())
          .toList();
    }

    final url = requestBuilder.buildUrl(
      '/v1/models',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = _headers(betas: betas, workspaceId: workspaceId);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return decodeApiJsonResponse(response, ModelListResponse.fromJson);
  }

  /// Retrieves a specific model.
  ///
  /// Returns information about a specific model.
  ///
  /// Parameters:
  /// - [modelId]: The ID of the model to retrieve.
  /// - [betas]: Beta features to request, such as `compact-2026-09-04`.
  /// - [workspaceId]: Select a workspace when the credential can act on more
  ///   than one workspace.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ModelInfo> retrieve(
    String modelId, {
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/models/${encodePathSegment(modelId, 'modelId')}',
    );
    final headers = _headers(betas: betas, workspaceId: workspaceId);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return decodeApiJsonResponse(response, ModelInfo.fromJson);
  }

  Map<String, String> _headers({
    required List<String> betas,
    required String? workspaceId,
  }) => requestBuilder.buildHeaders(
    additionalHeaders: {
      if (betas.isNotEmpty) 'anthropic-beta': betas.join(','),
      'anthropic-workspace-id': ?workspaceId,
    },
  );
}
