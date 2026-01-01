import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models/model.dart';
import '../models/models/model_list.dart';
import 'base_resource.dart';

/// Resource for the Models API.
///
/// Provides access to list, retrieve, and delete models.
///
/// Example usage:
/// ```dart
/// // List all models
/// final models = await client.models.list();
/// for (final model in models.data) {
///   print('${model.id}: ${model.name}');
/// }
///
/// // Get a specific model
/// final model = await client.models.get('mistral-small-latest');
/// print('Max context: ${model.maxContextLength}');
/// ```
class ModelsResource extends ResourceBase {
  /// Creates a [ModelsResource].
  ModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Lists all available models.
  ///
  /// Returns a [ModelList] containing all models accessible to your account.
  ///
  /// Throws [MistralException] if the request fails.
  Future<ModelList> list() async {
    final url = requestBuilder.buildUrl('/v1/models');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ModelList.fromJson(responseBody);
  }

  /// Retrieves a specific model by ID.
  ///
  /// The [modelId] is the unique identifier of the model.
  ///
  /// Returns a [Model] with detailed information about the model.
  ///
  /// Throws [MistralException] if the model is not found or the request fails.
  Future<Model> get(String modelId) async {
    final url = requestBuilder.buildUrl('/v1/models/$modelId');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Model.fromJson(responseBody);
  }

  /// Deletes a fine-tuned model.
  ///
  /// The [modelId] is the unique identifier of the model to delete.
  ///
  /// Returns `true` if the model was successfully deleted.
  ///
  /// Note: Only fine-tuned models can be deleted. Attempting to delete a
  /// base model will result in an error.
  ///
  /// Throws [MistralException] if the model cannot be deleted or the request
  /// fails.
  Future<bool> delete(String modelId) async {
    final url = requestBuilder.buildUrl('/v1/models/$modelId');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    // Check if deletion was successful
    if (response.statusCode == 200 || response.statusCode == 204) {
      // Try to parse response for "deleted" field if present
      if (response.body.isNotEmpty) {
        try {
          final responseBody =
              jsonDecode(response.body) as Map<String, dynamic>;
          return responseBody['deleted'] as bool? ?? true;
        } catch (_) {
          return true;
        }
      }
      return true;
    }
    return false;
  }
}
