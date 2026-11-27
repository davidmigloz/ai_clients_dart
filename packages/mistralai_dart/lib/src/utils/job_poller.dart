import '../client/mistral_client.dart';
import '../errors/exceptions.dart';
import '../models/batch/batch_job.dart';

/// Poller for long-running batch jobs.
///
/// Some operations are asynchronous and require polling to check completion.
/// This utility provides convenient methods for waiting until a job completes.
///
/// Example (batch):
/// ```dart
/// final job = await client.batch.jobs.create(...);
/// final poller = BatchJobPoller(
///   client: client,
///   jobId: job.id,
/// );
/// final completed = await poller.poll();
/// print('Output file: ${completed.outputFileId}');
/// ```

/// Poller for batch jobs.
class BatchJobPoller {
  /// The client to use for polling.
  final MistralClient client;

  /// The job ID to poll.
  final String jobId;

  /// Interval between poll attempts.
  final Duration pollInterval;

  /// Maximum time to wait for completion.
  final Duration? timeout;

  /// Optional callback for progress updates.
  final void Function(BatchJob job)? onProgress;

  /// Creates a [BatchJobPoller].
  const BatchJobPoller({
    required this.client,
    required this.jobId,
    this.pollInterval = const Duration(seconds: 30),
    this.timeout = const Duration(hours: 24),
    this.onProgress,
  });

  /// Polls the job until it completes.
  ///
  /// Returns the completed [BatchJob] when the job succeeds.
  ///
  /// Throws an [ApiException] if the job fails.
  /// Throws a [TimeoutException] if polling times out.
  Future<BatchJob> poll() async {
    final clock = Stopwatch()..start();
    final limit = timeout;

    TimeoutException deadlineExceeded() => TimeoutException(
      message: 'Batch job polling timed out after ${limit!.inMilliseconds}ms',
      timeout: limit,
      elapsed: clock.elapsed,
    );

    while (true) {
      final remaining = limit == null ? null : limit - clock.elapsed;
      if (remaining != null && remaining <= Duration.zero) {
        throw deadlineExceeded();
      }

      final request = client.batch.jobs.retrieve(jobId: jobId);
      final job = remaining == null
          ? await request
          : await request.timeout(
              remaining,
              onTimeout: () => throw deadlineExceeded(),
            );
      onProgress?.call(job);

      if (job.isSuccess) return job;
      if (job.isComplete) {
        throw ApiException(
          statusCode: 400,
          message: 'Batch job failed with status: ${job.status.value}',
          details: [for (final error in job.errors) ?error.message],
        );
      }

      final afterProgress = limit == null ? null : limit - clock.elapsed;
      final wait = afterProgress != null && afterProgress < pollInterval
          ? afterProgress
          : pollInterval;
      if (wait > Duration.zero) await Future<void>.delayed(wait);
    }
  }
}
