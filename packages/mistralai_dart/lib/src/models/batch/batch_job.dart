import 'package:meta/meta.dart';

import 'batch_error.dart';
import 'batch_job_status.dart';

/// Parses a DateTime from various formats.
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    // Unix timestamp in seconds
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

/// A batch processing job.
@immutable
class BatchJob {
  /// Unique identifier for the job.
  final String id;

  /// Object type (always "batch").
  final String object;

  /// File ID containing the input data.
  final String inputFileId;

  /// API endpoint being called.
  final String endpoint;

  /// The model to use for processing.
  final String model;

  /// File ID containing the output data.
  final String? outputFileId;

  /// File ID containing errors.
  final String? errorFileId;

  /// Current status of the job.
  final BatchJobStatus status;

  /// Total number of requests in the batch.
  final int? totalRequests;

  /// Number of completed requests.
  final int? completedRequests;

  /// Number of succeeded requests.
  final int? succeededRequests;

  /// Number of failed requests.
  final int? failedRequests;

  /// Timestamp when the job started processing.
  final DateTime? startedAt;

  /// Timestamp when the job completed.
  final DateTime? completedAt;

  /// Timestamp when the job was created.
  final DateTime? createdAt;

  /// List of errors that occurred during processing.
  final List<BatchError> errors;

  /// Job metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [BatchJob].
  const BatchJob({
    required this.id,
    this.object = 'batch',
    required this.inputFileId,
    required this.endpoint,
    required this.model,
    this.outputFileId,
    this.errorFileId,
    required this.status,
    this.totalRequests,
    this.completedRequests,
    this.succeededRequests,
    this.failedRequests,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.errors = const [],
    this.metadata,
  });

  /// Creates a [BatchJob] from JSON.
  factory BatchJob.fromJson(Map<String, dynamic> json) => BatchJob(
    id: json['id'] as String? ?? '',
    object: json['object'] as String? ?? 'batch',
    inputFileId:
        json['input_file_id'] as String? ??
        json['input_files'] as String? ??
        '',
    endpoint: json['endpoint'] as String? ?? '',
    model: json['model'] as String? ?? '',
    outputFileId:
        json['output_file_id'] as String? ?? json['output_file'] as String?,
    errorFileId:
        json['error_file_id'] as String? ?? json['error_file'] as String?,
    status: BatchJobStatus.fromString(json['status'] as String? ?? 'QUEUED'),
    totalRequests: json['total_requests'] as int?,
    completedRequests: json['completed_requests'] as int?,
    succeededRequests: json['succeeded_requests'] as int?,
    failedRequests: json['failed_requests'] as int?,
    startedAt: _parseDateTime(json['started_at']),
    completedAt: _parseDateTime(json['completed_at']),
    createdAt: _parseDateTime(json['created_at']),
    errors:
        (json['errors'] as List?)
            ?.map((e) => BatchError.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'input_file_id': inputFileId,
    'endpoint': endpoint,
    'model': model,
    if (outputFileId != null) 'output_file_id': outputFileId,
    if (errorFileId != null) 'error_file_id': errorFileId,
    'status': status.value,
    if (totalRequests != null) 'total_requests': totalRequests,
    if (completedRequests != null) 'completed_requests': completedRequests,
    if (succeededRequests != null) 'succeeded_requests': succeededRequests,
    if (failedRequests != null) 'failed_requests': failedRequests,
    if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
    if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (errors.isNotEmpty) 'errors': errors.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Whether the job is still running.
  bool get isRunning =>
      status == BatchJobStatus.queued || status == BatchJobStatus.running;

  /// Whether the job has completed (success or failure).
  bool get isComplete =>
      status == BatchJobStatus.success ||
      status == BatchJobStatus.failed ||
      status == BatchJobStatus.timedOut ||
      status == BatchJobStatus.cancelled;

  /// Whether the job succeeded.
  bool get isSuccess => status == BatchJobStatus.success;

  /// Whether the job failed.
  bool get isFailed =>
      status == BatchJobStatus.failed || status == BatchJobStatus.timedOut;

  /// Progress percentage (0-100).
  double get progress {
    if (totalRequests == null || totalRequests == 0) return 0;
    final completed = completedRequests ?? 0;
    return (completed / totalRequests!) * 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchJob && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BatchJob(id: $id, status: ${status.value}, progress: ${progress.toStringAsFixed(1)}%)';
}
