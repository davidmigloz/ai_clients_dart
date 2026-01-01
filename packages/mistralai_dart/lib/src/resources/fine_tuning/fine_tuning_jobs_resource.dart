import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/fine_tuning/create_fine_tuning_job_request.dart';
import '../../models/fine_tuning/fine_tuning_job.dart';
import '../../models/fine_tuning/fine_tuning_job_list.dart';
import '../base_resource.dart';

/// Resource for fine-tuning jobs.
///
/// Provides methods to create, list, retrieve, and manage fine-tuning jobs.
///
/// Example usage:
/// ```dart
/// final jobs = await client.fineTuning.jobs.list();
/// for (final job in jobs.data) {
///   print('${job.id}: ${job.status}');
/// }
/// ```
class FineTuningJobsResource extends ResourceBase {
  /// Creates a [FineTuningJobsResource].
  FineTuningJobsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Lists all fine-tuning jobs.
  ///
  /// Returns a paginated list of jobs. Use [page] and [pageSize] for pagination.
  Future<FineTuningJobList> list({
    int? page,
    int? pageSize,
    String? model,
    String? createdAfter,
    String? createdByMe,
    String? status,
    String? wandbProject,
    String? wandbName,
    String? suffix,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (model != null) queryParams['model'] = model;
    if (createdAfter != null) queryParams['created_after'] = createdAfter;
    if (createdByMe != null) queryParams['created_by_me'] = createdByMe;
    if (status != null) queryParams['status'] = status;
    if (wandbProject != null) queryParams['wandb_project'] = wandbProject;
    if (wandbName != null) queryParams['wandb_name'] = wandbName;
    if (suffix != null) queryParams['suffix'] = suffix;

    final url = requestBuilder.buildUrl(
      '/v1/fine_tuning/jobs',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FineTuningJobList.fromJson(responseBody);
  }

  /// Creates a new fine-tuning job.
  ///
  /// Returns the created job.
  Future<FineTuningJob> create({
    required CreateFineTuningJobRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/fine_tuning/jobs');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FineTuningJob.fromJson(responseBody);
  }

  /// Retrieves a specific fine-tuning job.
  Future<FineTuningJob> retrieve({required String jobId}) async {
    final url = requestBuilder.buildUrl('/v1/fine_tuning/jobs/$jobId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FineTuningJob.fromJson(responseBody);
  }

  /// Cancels a running fine-tuning job.
  Future<FineTuningJob> cancel({required String jobId}) async {
    final url = requestBuilder.buildUrl('/v1/fine_tuning/jobs/$jobId/cancel');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FineTuningJob.fromJson(responseBody);
  }

  /// Starts a fine-tuning job that was created with autoStart=false.
  Future<FineTuningJob> start({required String jobId}) async {
    final url = requestBuilder.buildUrl('/v1/fine_tuning/jobs/$jobId/start');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FineTuningJob.fromJson(responseBody);
  }
}
