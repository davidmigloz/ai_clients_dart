import 'dart:convert';

import 'package:http/http.dart' as http;

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
class FineTuningResource extends ResourceBase {
  /// Creates a [FineTuningResource].
  FineTuningResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

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
  FineTuningJobsResource get jobs => _jobs ??= FineTuningJobsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );
}

/// Resource for fine-tuning job operations.
class FineTuningJobsResource extends ResourceBase {
  /// Creates a [FineTuningJobsResource].
  FineTuningJobsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return FineTuningJob.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return FineTuningJobList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a fine-tuning job by ID.
  Future<FineTuningJob> retrieve(String fineTuningJobId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$fineTuningJobId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return FineTuningJob.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Cancels a fine-tuning job.
  Future<FineTuningJob> cancel(String fineTuningJobId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$fineTuningJobId/cancel');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
    final response = await interceptorChain.execute(httpRequest);
    return FineTuningJob.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists events for a fine-tuning job.
  Future<FineTuningEventList> listEvents(
    String fineTuningJobId, {
    String? after,
    int? limit,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = requestBuilder.buildUrl(
      '$_endpoint/$fineTuningJobId/events',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return FineTuningEventList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists checkpoints for a fine-tuning job.
  Future<FineTuningCheckpointList> listCheckpoints(
    String fineTuningJobId, {
    String? after,
    int? limit,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = requestBuilder.buildUrl(
      '$_endpoint/$fineTuningJobId/checkpoints',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return FineTuningCheckpointList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
