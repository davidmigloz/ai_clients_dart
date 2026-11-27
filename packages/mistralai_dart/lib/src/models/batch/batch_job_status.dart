/// Status of a batch job.
enum BatchJobStatus {
  /// Job is waiting to be processed.
  queued('QUEUED'),

  /// Job is currently running.
  running('RUNNING'),

  /// Job completed successfully.
  success('SUCCESS'),

  /// Job failed with an error.
  failed('FAILED'),

  /// Job timed out.
  timedOut('TIMEOUT_EXCEEDED'),

  /// Job was cancelled.
  cancelled('CANCELLED'),

  /// Job has been cancelled and is stopping.
  cancellationRequested('CANCELLATION_REQUESTED'),

  /// Job status reported by a newer API version.
  unknown('UNKNOWN');

  const BatchJobStatus(this.value);

  /// The string value of this status.
  final String value;

  /// Creates a [BatchJobStatus] from a string value.
  static BatchJobStatus fromString(String value) {
    // Read snapshots written by earlier versions of this library.
    if (value == 'TIMED_OUT') return BatchJobStatus.timedOut;
    return BatchJobStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BatchJobStatus.unknown,
    );
  }
}
