import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'batch_jobs_resource.dart';

/// Resource for Batch API operations.
///
/// Batch processing allows you to send large volumes of requests asynchronously,
/// with results available once processing completes. This is useful for:
/// - Processing large datasets
/// - Running overnight jobs
/// - Cost optimization (batch requests are often discounted)
///
/// Example usage:
/// ```dart
/// // 1. Upload a JSONL file with requests
/// final file = await client.files.upload(
///   file: inputFile,
///   purpose: FilePurpose.batch,
/// );
///
/// // 2. Create a batch job
/// final job = await client.batch.jobs.create(
///   request: CreateBatchJobRequest(
///     inputFileId: file.id,
///     endpoint: '/v1/chat/completions',
///     model: 'mistral-small-latest',
///   ),
/// );
///
/// // 3. Poll for completion
/// while (!job.isComplete) {
///   await Future.delayed(Duration(seconds: 30));
///   job = await client.batch.jobs.retrieve(jobId: job.id);
///   print('Progress: ${job.progress}%');
/// }
///
/// // 4. Download results
/// if (job.outputFileId != null) {
///   final results = await client.files.download(fileId: job.outputFileId!);
///   // Process results...
/// }
/// ```
class BatchResource {
  /// Configuration.
  final MistralConfig config;

  /// HTTP client.
  final http.Client httpClient;

  /// Interceptor chain.
  final InterceptorChain interceptorChain;

  /// Request builder.
  final RequestBuilder requestBuilder;

  /// Sub-resource for batch jobs.
  late final BatchJobsResource jobs;

  /// Creates a [BatchResource].
  BatchResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
  }) {
    jobs = BatchJobsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
    );
  }
}
