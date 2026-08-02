import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'fine_tuning_models_resource.dart';

/// Resource for Fine-tuning API operations.
///
/// Provides access to fine-tuned model management. The fine-tuning jobs API
/// has been removed upstream; use `client.files` to upload training data and
/// a Mistral console/job outside this client to launch training runs.
///
/// Example usage:
/// ```dart
/// // Update a fine-tuned model
/// final updated = await client.fineTuning.models.update(
///   modelId: 'ft:mistral-small:my-model:xyz',
///   name: 'My Model v2',
/// );
///
/// // Archive a model
/// await client.fineTuning.models.archive(modelId: updated.id);
///
/// // Unarchive a model
/// await client.fineTuning.models.unarchive(modelId: updated.id);
/// ```
class FineTuningResource {
  /// Configuration.
  final MistralConfig config;

  /// HTTP client.
  final http.Client httpClient;

  /// Interceptor chain.
  final InterceptorChain interceptorChain;

  /// Request builder.
  final RequestBuilder requestBuilder;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Sub-resource for fine-tuned model management.
  late final FineTuningModelsResource models;

  /// Creates a [FineTuningResource].
  FineTuningResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
  }) {
    models = FineTuningModelsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
