/// Status of a fine-tuning job.
enum FineTuningJobStatus {
  /// Job is waiting to be processed.
  queued('QUEUED'),

  /// Job has started and is running.
  started('STARTED'),

  /// Job is currently validating the training data.
  validating('VALIDATING'),

  /// Job has been validated and is waiting to start.
  validated('VALIDATED'),

  /// Job is currently running.
  running('RUNNING'),

  /// Job failed with an error.
  failed('FAILED'),

  /// Job completed successfully.
  success('SUCCESS'),

  /// Job was cancelled.
  cancelled('CANCELLED'),

  /// Job has been cancelled and is stopping.
  cancellationRequested('CANCELLATION_REQUESTED');

  const FineTuningJobStatus(this.value);

  /// The string value of this status.
  final String value;

  /// Creates a [FineTuningJobStatus] from a string value.
  static FineTuningJobStatus fromString(String value) {
    return FineTuningJobStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FineTuningJobStatus.queued,
    );
  }
}
