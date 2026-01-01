import '../models/models/model_info.dart';
import 'base_resource.dart';

/// Resource for the Models API.
///
/// The Models API allows you to list and retrieve information
/// about available Claude models.
class ModelsResource extends ResourceBase {
  /// Creates a [ModelsResource].
  ModelsResource({required super.chain, required super.requestBuilder});

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
    final queryParams = <String, dynamic>{};
    if (beforeId != null) queryParams['before_id'] = beforeId;
    if (afterId != null) queryParams['after_id'] = afterId;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await get(
      '/v1/models',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      abortTrigger: abortTrigger,
    );

    return ModelListResponse.fromJson(response);
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
    final response = await get(
      '/v1/models/$modelId',
      abortTrigger: abortTrigger,
    );

    return ModelInfo.fromJson(response);
  }
}
