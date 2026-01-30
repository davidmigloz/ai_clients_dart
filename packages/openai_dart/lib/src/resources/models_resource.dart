import '../client/openai_client.dart';
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
class ModelsResource extends BaseResource {
  /// Creates a [ModelsResource] with the given client.
  ModelsResource(super.client);

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
    final json = await getJson(_endpoint, abortTrigger: abortTrigger);
    return ModelList.fromJson(json);
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
    final json = await getJson('$_endpoint/$model', abortTrigger: abortTrigger);
    return Model.fromJson(json);
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
    final json = await deleteJson(
      '$_endpoint/$model',
      abortTrigger: abortTrigger,
    );
    return DeleteModelResponse.fromJson(json);
  }
}
