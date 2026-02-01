import '../models/fine_tuning/fine_tuning.dart';
import 'base_resource.dart';

/// Resource for Fine-tuning API operations.
///
/// Fine-tuning allows you to train custom models on your own data.
///
/// Access this resource through [OpenAIClient.fineTuning].
///
/// ## Example
///
/// ```dart
/// // Create a fine-tuning job
/// final job = await client.fineTuning.jobs.create(
///   CreateFineTuningJobRequest(
///     model: 'gpt-4o-mini-2024-07-18',
///     trainingFile: 'file-abc123',
///   ),
/// );
///
/// // Monitor the job
/// while (job.isRunning) {
///   await Future.delayed(Duration(seconds: 30));
///   job = await client.fineTuning.jobs.retrieve(job.id);
/// }
///
/// print('Fine-tuned model: ${job.fineTunedModel}');
/// ```
class FineTuningResource extends BaseResource {
  /// Creates a [FineTuningResource] with the given client.
  FineTuningResource(super.client);

  FineTuningJobsResource? _jobs;

  /// Access to fine-tuning job operations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final job = await client.fineTuning.jobs.create(
  ///   CreateFineTuningJobRequest(
  ///     model: 'gpt-4o-mini-2024-07-18',
  ///     trainingFile: 'file-abc123',
  ///   ),
  /// );
  /// ```
  FineTuningJobsResource get jobs => _jobs ??= FineTuningJobsResource(client);
}

/// Resource for fine-tuning job operations.
class FineTuningJobsResource extends BaseResource {
  /// Creates a [FineTuningJobsResource] with the given client.
  FineTuningJobsResource(super.client);

  static const _endpoint = '/fine_tuning/jobs';

  /// Creates a fine-tuning job.
  ///
  /// ## Parameters
  ///
  /// - [request] - The job creation request.
  ///
  /// ## Returns
  ///
  /// A [FineTuningJob] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final job = await client.fineTuning.jobs.create(
  ///   CreateFineTuningJobRequest(
  ///     model: 'gpt-4o-mini-2024-07-18',
  ///     trainingFile: 'file-abc123',
  ///     hyperparameters: HyperparametersRequest(nEpochs: 3),
  ///   ),
  /// );
  /// ```
  Future<FineTuningJob> create(CreateFineTuningJobRequest request) async {
    final json = await postJson(_endpoint, body: request.toJson());
    return FineTuningJob.fromJson(json);
  }

  /// Lists fine-tuning jobs.
  ///
  /// ## Parameters
  ///
  /// - [after] - Cursor for pagination.
  /// - [limit] - Maximum number to return (1-100, default 20).
  ///
  /// ## Returns
  ///
  /// A [FineTuningJobList] containing the jobs.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final jobs = await client.fineTuning.jobs.list(limit: 10);
  /// for (final job in jobs.data) {
  ///   print('${job.id}: ${job.status}');
  /// }
  /// ```
  Future<FineTuningJobList> list({String? after, int? limit}) async {
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return FineTuningJobList.fromJson(json);
  }

  /// Retrieves a fine-tuning job by ID.
  ///
  /// ## Parameters
  ///
  /// - [fineTuningJobId] - The ID of the fine-tuning job.
  ///
  /// ## Returns
  ///
  /// A [FineTuningJob] with the job information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final job = await client.fineTuning.jobs.retrieve('ftjob-abc123');
  /// print('Status: ${job.status}');
  /// ```
  Future<FineTuningJob> retrieve(String fineTuningJobId) async {
    final json = await getJson('$_endpoint/$fineTuningJobId');
    return FineTuningJob.fromJson(json);
  }

  /// Cancels a fine-tuning job.
  ///
  /// ## Parameters
  ///
  /// - [fineTuningJobId] - The ID of the job to cancel.
  ///
  /// ## Returns
  ///
  /// A [FineTuningJob] with the updated status.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final cancelled = await client.fineTuning.jobs.cancel('ftjob-abc123');
  /// print('Status: ${cancelled.status}');
  /// ```
  Future<FineTuningJob> cancel(String fineTuningJobId) async {
    final json = await postJson('$_endpoint/$fineTuningJobId/cancel', body: {});
    return FineTuningJob.fromJson(json);
  }

  /// Lists events for a fine-tuning job.
  ///
  /// ## Parameters
  ///
  /// - [fineTuningJobId] - The ID of the fine-tuning job.
  /// - [after] - Cursor for pagination.
  /// - [limit] - Maximum number to return (1-100, default 20).
  ///
  /// ## Returns
  ///
  /// A [FineTuningEventList] containing the events.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final events = await client.fineTuning.jobs.listEvents('ftjob-abc123');
  /// for (final event in events.data) {
  ///   print('${event.level}: ${event.message}');
  /// }
  /// ```
  Future<FineTuningEventList> listEvents(
    String fineTuningJobId, {
    String? after,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();

    final json = await getJson(
      '$_endpoint/$fineTuningJobId/events',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return FineTuningEventList.fromJson(json);
  }

  /// Lists checkpoints for a fine-tuning job.
  ///
  /// ## Parameters
  ///
  /// - [fineTuningJobId] - The ID of the fine-tuning job.
  /// - [after] - Cursor for pagination.
  /// - [limit] - Maximum number to return (1-100, default 10).
  ///
  /// ## Returns
  ///
  /// A [FineTuningCheckpointList] containing the checkpoints.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final checkpoints = await client.fineTuning.jobs.listCheckpoints(
  ///   'ftjob-abc123',
  /// );
  /// for (final checkpoint in checkpoints.data) {
  ///   print('Step ${checkpoint.stepNumber}: ${checkpoint.fineTunedModelCheckpoint}');
  /// }
  /// ```
  Future<FineTuningCheckpointList> listCheckpoints(
    String fineTuningJobId, {
    String? after,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();

    final json = await getJson(
      '$_endpoint/$fineTuningJobId/checkpoints',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return FineTuningCheckpointList.fromJson(json);
  }
}
