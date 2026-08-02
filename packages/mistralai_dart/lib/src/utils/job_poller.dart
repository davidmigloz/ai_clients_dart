import '../client/mistral_client.dart';
import '../errors/exceptions.dart';
import '../models/batch/batch_job.dart';
import '../models/batch/batch_job_status.dart';

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
/// print('Output file: ${completed.outputFile}');
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
    final startTime = DateTime.now();

    while (true) {
      final job = await client.batch.jobs.retrieve(jobId: jobId);

      // Notify progress
      onProgress?.call(job);

      if (_isTerminalState(job.status)) {
        if (job.status == BatchJobStatus.success) {
          return job;
        }

        // Job failed
        throw ApiException(
          statusCode: 400,
          message: 'Batch job failed with status: ${job.status}',
          details: [for (final error in job.errors) ?error.message],
        );
      }

      // Check timeout
      if (timeout != null) {
        final elapsed = DateTime.now().difference(startTime);
        if (elapsed > timeout!) {
          throw TimeoutException(
            message: 'Batch job polling timed out after ${timeout!.inSeconds}s',
            timeout: timeout!,
            elapsed: elapsed,
          );
        }
      }

      // Wait before next poll
      await Future<void>.delayed(pollInterval);
    }
  }

  bool _isTerminalState(BatchJobStatus status) {
    return status == BatchJobStatus.success ||
        status == BatchJobStatus.failed ||
        status == BatchJobStatus.cancelled ||
        status == BatchJobStatus.timedOut ||
        status == BatchJobStatus.cancellationRequested;
  }
}
