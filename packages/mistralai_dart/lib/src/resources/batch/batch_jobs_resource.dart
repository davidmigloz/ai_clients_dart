import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/batch/batch_job.dart';
import '../../models/batch/batch_job_list.dart';
import '../../models/batch/create_batch_job_request.dart';
import '../base_resource.dart';

/// Resource for batch jobs.
///
/// Provides methods to create, list, retrieve, and cancel batch jobs.
///
/// Example usage:
/// ```dart
/// // List batch jobs
/// final jobs = await client.batch.jobs.list();
/// for (final job in jobs.data) {
///   print('${job.id}: ${job.status}');
/// }
///
/// // Create a batch job
/// final job = await client.batch.jobs.create(
///   request: CreateBatchJobRequest(
///     inputFileId: 'file-abc123',
///     endpoint: '/v1/chat/completions',
///     model: 'mistral-small-latest',
///   ),
/// );
/// ```
class BatchJobsResource extends ResourceBase {
  /// Creates a [BatchJobsResource].
  BatchJobsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Lists all batch jobs.
  ///
  /// Returns a paginated list of jobs. Use [page] and [pageSize] for pagination.
  ///
  /// Optional filters:
  /// - [model] - Filter by model name
  /// - [status] - Filter by job status
  /// - [createdAfter] - Filter jobs created after this date (ISO 8601 format)
  Future<BatchJobList> list({
    int? page,
    int? pageSize,
    String? model,
    String? status,
    String? createdAfter,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (model != null) queryParams['model'] = model;
    if (status != null) queryParams['status'] = status;
    if (createdAfter != null) queryParams['created_after'] = createdAfter;

    final url = requestBuilder.buildUrl(
      '/v1/batch/jobs',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchJobList.fromJson(responseBody);
  }

  /// Creates a new batch job.
  ///
  /// The [request] must specify:
  /// - [inputFileId] - ID of the input file containing batch requests (JSONL format)
  /// - [endpoint] - API endpoint to process requests against (e.g., `/v1/chat/completions`)
  /// - [model] - Model to use for processing
  ///
  /// Returns the created batch job.
  Future<BatchJob> create({required CreateBatchJobRequest request}) async {
    final url = requestBuilder.buildUrl('/v1/batch/jobs');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchJob.fromJson(responseBody);
  }

  /// Retrieves a specific batch job.
  ///
  /// Returns the job with its current status and progress.
  Future<BatchJob> retrieve({required String jobId}) async {
    final url = requestBuilder.buildUrl('/v1/batch/jobs/$jobId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchJob.fromJson(responseBody);
  }

  /// Cancels a running batch job.
  ///
  /// Returns the job with updated status (CANCELLATION_REQUESTED or CANCELLED).
  Future<BatchJob> cancel({required String jobId}) async {
    final url = requestBuilder.buildUrl('/v1/batch/jobs/$jobId/cancel');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchJob.fromJson(responseBody);
  }
}
