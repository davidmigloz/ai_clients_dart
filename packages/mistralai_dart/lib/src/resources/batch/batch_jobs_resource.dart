import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/batch/batch_job.dart';
import '../../models/batch/batch_job_list.dart';
import '../../models/batch/batch_job_status.dart';
import '../../models/batch/create_batch_job_request.dart';
import '../../models/batch/delete_batch_job_response.dart';
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
///     inputFiles: ['file-abc123'],
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
    super.ensureNotClosed,
  });

  /// Lists all batch jobs.
  ///
  /// Returns a paginated list of jobs. Use [page] and [pageSize] for pagination.
  ///
  /// Optional filters:
  /// - [model] - Filter by model name
  /// - [agentId] - Filter by agent ID
  /// - [status] - Filter by a single wire status
  /// - [statuses] - Filter by any of several job statuses
  /// - [metadata] - Filter by metadata entries using exploded form serialization
  /// - [createdByMe] - Include only jobs created by the caller
  /// - [orderBy] - Order by `created` (ascending) or `-created` (descending)
  /// - [createdAfter] - Filter jobs created after this date (ISO 8601 format)
  Future<BatchJobList> list({
    int? page,
    int? pageSize,
    String? model,
    String? agentId,
    String? status,
    List<BatchJobStatus>? statuses,
    Map<String, dynamic>? metadata,
    String? createdAfter,
    bool? createdByMe,
    String? orderBy,
  }) async {
    if (status != null && statuses != null) {
      throw ArgumentError('Specify either status or statuses.');
    }
    final queryParams = <String, dynamic>{
      for (final entry in (metadata ?? const <String, dynamic>{}).entries)
        if (entry.value != null)
          entry.key: entry.value is String
              ? entry.value
              : jsonEncode(entry.value),
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      'model': ?model,
      'agent_id': ?agentId,
      if (status != null)
        'status': status == 'TIMED_OUT'
            ? BatchJobStatus.timedOut.value
            : status,
      if (statuses != null)
        'status': [for (final value in statuses) value.value],
      'created_after': ?createdAfter,
      if (createdByMe != null) 'created_by_me': createdByMe.toString(),
      'order_by': ?orderBy,
    };

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
  /// Provide input file IDs or inline requests and the endpoint to process.
  /// Select a model or agent as appropriate for that endpoint.
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
  /// Set [inline] to include available result objects in [BatchJob.outputs].
  Future<BatchJob> retrieve({required String jobId, bool? inline}) async {
    final url = requestBuilder.buildUrl(
      '/v1/batch/jobs/${Uri.encodeComponent(jobId)}',
      queryParams: {if (inline != null) 'inline': inline.toString()},
    );
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
    final url = requestBuilder.buildUrl(
      '/v1/batch/jobs/${Uri.encodeComponent(jobId)}/cancel',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchJob.fromJson(responseBody);
  }

  /// Deletes a batch job.
  ///
  /// Returns a [DeleteBatchJobResponse] confirming the deletion.
  Future<DeleteBatchJobResponse> delete({required String jobId}) async {
    final url = requestBuilder.buildUrl(
      '/v1/batch/jobs/${Uri.encodeComponent(jobId)}',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DeleteBatchJobResponse.fromJson(responseBody);
  }
}
