import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'fine_tuning_jobs_resource.dart';
import 'fine_tuning_models_resource.dart';

/// Resource for Fine-tuning API operations.
///
/// Provides access to fine-tuning job and model management.
///
/// Example usage:
/// ```dart
/// // List jobs
/// final jobs = await client.fineTuning.jobs.list();
///
/// // Create a job
/// final job = await client.fineTuning.jobs.create(
///   request: CreateFineTuningJobRequest.single(
///     model: 'mistral-small-latest',
///     trainingFileId: 'file-abc123',
///   ),
/// );
///
/// // Check status
/// final updatedJob = await client.fineTuning.jobs.retrieve(jobId: job.id);
/// print('Status: ${updatedJob.status}');
///
/// // Update a fine-tuned model
/// final updated = await client.fineTuning.models.update(
///   modelId: 'ft:mistral-small:my-model:xyz',
///   name: 'My Model v2',
/// );
///
/// // Archive a model
/// await client.fineTuning.models.archive(modelId: updated.id);
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

  /// Sub-resource for fine-tuning jobs.
  late final FineTuningJobsResource jobs;

  /// Sub-resource for fine-tuned model management.
  late final FineTuningModelsResource models;

  /// Creates a [FineTuningResource].
  FineTuningResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
  }) {
    jobs = FineTuningJobsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
    );
    models = FineTuningModelsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
    );
  }
}
