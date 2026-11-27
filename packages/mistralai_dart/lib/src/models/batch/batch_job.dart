import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'batch_error.dart';
import 'batch_job_status.dart';

/// Parses a DateTime from various formats.
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    // Unix timestamp in seconds
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
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

  /// File IDs containing the input data.
  final List<String> inputFiles;

  /// API endpoint being called.
  final String endpoint;

  /// The model used for processing, if the job targets a model.
  final String? model;

  /// Agent used for processing, if the job targets an agent.
  final String? agentId;

  /// Inline result objects, when requested on retrieval.
  final List<Map<String, dynamic>>? outputs;

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
    required this.inputFiles,
    required this.endpoint,
    this.model,
    this.agentId,
    this.outputs,
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
    inputFiles: (json['input_files'] as List?)?.cast<String>() ?? <String>[],
    endpoint: json['endpoint'] as String? ?? '',
    model: json['model'] as String?,
    agentId: json['agent_id'] as String?,
    outputs: (json['outputs'] as List?)?.cast<Map<String, dynamic>>(),
    outputFileId:
        json['output_file'] as String? ?? json['output_file_id'] as String?,
    errorFileId:
        json['error_file'] as String? ?? json['error_file_id'] as String?,
    status: BatchJobStatus.fromString(json['status'] as String? ?? ''),
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
    'input_files': inputFiles,
    'endpoint': endpoint,
    if (model != null) 'model': model,
    if (agentId != null) 'agent_id': agentId,
    if (outputs != null) 'outputs': outputs,
    if (outputFileId != null) 'output_file': outputFileId,
    if (errorFileId != null) 'error_file': errorFileId,
    'status': status.value,
    if (totalRequests != null) 'total_requests': totalRequests,
    if (completedRequests != null) 'completed_requests': completedRequests,
    if (succeededRequests != null) 'succeeded_requests': succeededRequests,
    if (failedRequests != null) 'failed_requests': failedRequests,
    if (startedAt != null)
      'started_at': startedAt!.millisecondsSinceEpoch ~/ 1000,
    if (completedAt != null)
      'completed_at': completedAt!.millisecondsSinceEpoch ~/ 1000,
    if (createdAt != null)
      'created_at': createdAt!.millisecondsSinceEpoch ~/ 1000,
    'errors': errors.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Whether the job is pending, processing, or stopping.
  bool get isRunning =>
      status == BatchJobStatus.queued ||
      status == BatchJobStatus.running ||
      status == BatchJobStatus.cancellationRequested;

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
      other is BatchJob &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          listsEqual(inputFiles, other.inputFiles) &&
          endpoint == other.endpoint &&
          model == other.model &&
          agentId == other.agentId &&
          listOfMapsDeepEqual(outputs, other.outputs) &&
          outputFileId == other.outputFileId &&
          errorFileId == other.errorFileId &&
          status == other.status &&
          totalRequests == other.totalRequests &&
          completedRequests == other.completedRequests &&
          succeededRequests == other.succeededRequests &&
          failedRequests == other.failedRequests &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          createdAt == other.createdAt &&
          listsEqual(errors, other.errors) &&
          mapsDeepEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    id,
    object,
    listHash(inputFiles),
    endpoint,
    model,
    agentId,
    listOfMapsHashCode(outputs),
    outputFileId,
    errorFileId,
    status,
    totalRequests,
    completedRequests,
    succeededRequests,
    failedRequests,
    startedAt,
    completedAt,
    createdAt,
    listHash(errors),
    mapDeepHashCode(metadata),
  );

  @override
  String toString() =>
      'BatchJob(id: $id, model: $model, agentId: $agentId, outputs: ${outputs?.length}, '
      'status: ${status.value}, progress: ${progress.toStringAsFixed(1)}%)';
}
