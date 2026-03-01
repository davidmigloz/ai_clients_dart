import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models/model_info.dart';
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
  /// - [abortTrigger]: Allows canceling the request.
  Future<ModelListResponse> list({
    String? beforeId,
    String? afterId,
    int? limit,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{};
    if (beforeId != null) queryParams['before_id'] = beforeId;
    if (afterId != null) queryParams['after_id'] = afterId;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = requestBuilder.buildUrl(
      '/v1/models',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return ModelListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific model.
  ///
  /// Returns information about a specific model.
  ///
  /// Parameters:
  /// - [modelId]: The ID of the model to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ModelInfo> retrieve(
    String modelId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/models/$modelId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return ModelInfo.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
