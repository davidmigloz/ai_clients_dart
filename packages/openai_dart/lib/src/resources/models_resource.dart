import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models/models.dart';
import 'base_resource.dart';

/// Resource for model operations.
///
/// Lists and describes the various models available in the API.
///
/// Access this resource through [OpenAIClient.models].
///
/// ## Example
///
/// ```dart
/// // List all models
/// final models = await client.models.list();
/// for (final model in models.data) {
///   print(model.id);
/// }
///
/// // Get a specific model
/// final gpt4 = await client.models.retrieve('gpt-4o');
/// ```
class ModelsResource extends ResourceBase {
  /// Creates a [ModelsResource].
  ModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/models';

  /// Lists all available models.
  ///
  /// ## Returns
  ///
  /// A [ModelList] containing all available models.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final models = await client.models.list();
  ///
  /// final gptModels = models.data.where(
  ///   (m) => m.id.startsWith('gpt'),
  /// );
  ///
  /// for (final model in gptModels) {
  ///   print('${model.id}: owned by ${model.ownedBy}');
  /// }
  /// ```
  Future<ModelList> list({Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ModelList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a model by ID.
  ///
  /// ## Parameters
  ///
  /// - [model] - The ID of the model to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Model] with the model information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final model = await client.models.retrieve('gpt-4o');
  /// print('Created: ${model.created}');
  /// print('Owned by: ${model.ownedBy}');
  /// ```
  Future<Model> retrieve(String model, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$model');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Model.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a fine-tuned model.
  ///
  /// You must have the Owner role in your organization to delete a model.
  ///
  /// ## Parameters
  ///
  /// - [model] - The ID of the model to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteModelResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.models.delete('ft:gpt-3.5-turbo:org:custom:id');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteModelResponse> delete(
    String model, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$model');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return DeleteModelResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
