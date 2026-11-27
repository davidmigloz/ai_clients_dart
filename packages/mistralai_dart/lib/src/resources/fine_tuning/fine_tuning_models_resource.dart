import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/fine_tuning/archive_ft_model_response.dart';
import '../../models/fine_tuning/ft_model_out.dart';
import '../../models/fine_tuning/update_ft_model_request.dart';
import '../base_resource.dart';

/// Resource for managing fine-tuned models.
///
/// Provides operations to update, archive, and unarchive fine-tuned models.
///
/// Example usage:
/// ```dart
/// // Update a model's metadata
/// final updated = await client.fineTuning.models.update(
///   modelId: 'ft:mistral-small:my-model:xyz',
///   name: 'My Improved Model',
///   description: 'Fine-tuned for customer support',
/// );
///
/// // Archive a model
/// final archived = await client.fineTuning.models.archive(
///   modelId: 'ft:mistral-small:my-model:xyz',
/// );
/// print('Archived: ${archived.archived}');
///
/// // Unarchive a model
/// final unarchived = await client.fineTuning.models.unarchive(
///   modelId: 'ft:mistral-small:my-model:xyz',
/// );
/// ```
class FineTuningModelsResource extends ResourceBase {
  /// Creates a [FineTuningModelsResource].
  FineTuningModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Updates a fine-tuned model's metadata.
  ///
  /// [modelId] is the ID of the fine-tuned model to update.
  /// [name] is the new name for the model.
  /// [description] is the new description for the model.
  /// Set [clearName] or [clearDescription] to send an explicit JSON null for
  /// that field. Omit both the value and its flag to leave it unchanged.
  Future<FTModelOut> update({
    required String modelId,
    String? name,
    String? description,
    bool clearName = false,
    bool clearDescription = false,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/fine_tuning/models/${Uri.encodeComponent(modelId)}',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = UpdateFTModelRequest(
      name: name,
      description: description,
      clearName: clearName,
      clearDescription: clearDescription,
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FTModelOut.fromJson(responseBody);
  }

  /// Archives a fine-tuned model.
  ///
  /// Archived models are hidden from the default model list but can be
  /// unarchived later.
  ///
  /// [modelId] is the ID of the fine-tuned model to archive.
  Future<ArchiveFTModelResponse> archive({required String modelId}) async {
    final url = requestBuilder.buildUrl(
      '/v1/fine_tuning/models/${Uri.encodeComponent(modelId)}/archive',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ArchiveFTModelResponse.fromJson(responseBody);
  }

  /// Unarchives a fine-tuned model.
  ///
  /// Restores an archived model to the default model list.
  ///
  /// [modelId] is the ID of the fine-tuned model to unarchive.
  Future<ArchiveFTModelResponse> unarchive({required String modelId}) async {
    final url = requestBuilder.buildUrl(
      '/v1/fine_tuning/models/${Uri.encodeComponent(modelId)}/archive',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ArchiveFTModelResponse.fromJson(
      responseBody,
      defaultArchived: false,
    );
  }
}
