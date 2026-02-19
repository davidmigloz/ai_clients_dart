import 'package:meta/meta.dart';

/// A batch job for processing many requests asynchronously.
///
/// Batches allow you to send large volumes of requests at a 50% discount
/// with a 24-hour turnaround time.
///
/// ## Example
///
/// ```dart
/// final batch = await client.batches.create(
///   CreateBatchRequest(
///     inputFileId: 'file-abc123',
///     endpoint: BatchEndpoint.chatCompletions,
///     completionWindow: CompletionWindow.hours24,
///   ),
/// );
///
/// // Poll for completion
/// while (batch.status != BatchStatus.completed) {
///   await Future.delayed(Duration(minutes: 1));
///   batch = await client.batches.retrieve(batch.id);
/// }
/// ```
@immutable
class Batch {
  /// Creates a [Batch].
  const Batch({
    required this.id,
    required this.object,
    required this.endpoint,
    required this.inputFileId,
    required this.completionWindow,
    required this.status,
    required this.createdAt,
    this.errors,
    this.outputFileId,
    this.errorFileId,
    this.inProgressAt,
    this.expiresAt,
    this.finalizingAt,
    this.completedAt,
    this.failedAt,
    this.expiredAt,
    this.cancellingAt,
    this.cancelledAt,
    this.requestCounts,
    this.metadata,
  });

  /// Creates a [Batch] from JSON.
  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as String,
      object: json['object'] as String,
      endpoint: json['endpoint'] as String,
      inputFileId: json['input_file_id'] as String,
      completionWindow: json['completion_window'] as String,
      status: BatchStatus.fromJson(json['status'] as String),
      createdAt: json['created_at'] as int,
      errors: json['errors'] != null
          ? BatchErrors.fromJson(json['errors'] as Map<String, dynamic>)
          : null,
      outputFileId: json['output_file_id'] as String?,
      errorFileId: json['error_file_id'] as String?,
      inProgressAt: json['in_progress_at'] as int?,
      expiresAt: json['expires_at'] as int?,
      finalizingAt: json['finalizing_at'] as int?,
      completedAt: json['completed_at'] as int?,
      failedAt: json['failed_at'] as int?,
      expiredAt: json['expired_at'] as int?,
      cancellingAt: json['cancelling_at'] as int?,
      cancelledAt: json['cancelled_at'] as int?,
      requestCounts: json['request_counts'] != null
          ? BatchRequestCounts.fromJson(
              json['request_counts'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// The batch identifier.
  final String id;

  /// The object type (always "batch").
  final String object;

  /// The API endpoint for this batch.
  final String endpoint;

  /// The input file ID containing the batch requests.
  final String inputFileId;

  /// The completion window for the batch.
  final String completionWindow;

  /// The current status of the batch.
  final BatchStatus status;

  /// The Unix timestamp when the batch was created.
  final int createdAt;

  /// Errors that occurred during batch processing.
  final BatchErrors? errors;

  /// The output file ID (when completed).
  final String? outputFileId;

  /// The error file ID (contains failed requests).
  final String? errorFileId;

  /// The Unix timestamp when processing started.
  final int? inProgressAt;

  /// The Unix timestamp when the batch expires.
  final int? expiresAt;

  /// The Unix timestamp when finalization started.
  final int? finalizingAt;

  /// The Unix timestamp when the batch completed.
  final int? completedAt;

  /// The Unix timestamp when the batch failed.
  final int? failedAt;

  /// The Unix timestamp when the batch expired.
  final int? expiredAt;

  /// The Unix timestamp when cancellation started.
  final int? cancellingAt;

  /// The Unix timestamp when the batch was cancelled.
  final int? cancelledAt;

  /// Request counts for the batch.
  final BatchRequestCounts? requestCounts;

  /// Custom metadata for the batch.
  final Map<String, String>? metadata;

  /// Whether the batch is still processing.
  bool get isProcessing =>
      status == BatchStatus.validating ||
      status == BatchStatus.inProgress ||
      status == BatchStatus.finalizing;

  /// Whether the batch completed successfully.
  bool get isCompleted => status == BatchStatus.completed;

  /// Whether the batch failed.
  bool get isFailed => status == BatchStatus.failed;

  /// Whether the batch was cancelled.
  bool get isCancelled => status == BatchStatus.cancelled;

  /// Whether the batch has expired.
  bool get isExpired => status == BatchStatus.expired;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'endpoint': endpoint,
    'input_file_id': inputFileId,
    'completion_window': completionWindow,
    'status': status.toJson(),
    'created_at': createdAt,
    if (errors != null) 'errors': errors!.toJson(),
    if (outputFileId != null) 'output_file_id': outputFileId,
    if (errorFileId != null) 'error_file_id': errorFileId,
    if (inProgressAt != null) 'in_progress_at': inProgressAt,
    if (expiresAt != null) 'expires_at': expiresAt,
    if (finalizingAt != null) 'finalizing_at': finalizingAt,
    if (completedAt != null) 'completed_at': completedAt,
    if (failedAt != null) 'failed_at': failedAt,
    if (expiredAt != null) 'expired_at': expiredAt,
    if (cancellingAt != null) 'cancelling_at': cancellingAt,
    if (cancelledAt != null) 'cancelled_at': cancelledAt,
    if (requestCounts != null) 'request_counts': requestCounts!.toJson(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Batch && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Batch(id: $id, status: $status)';
}

/// A list of batches.
@immutable
class BatchList {
  /// Creates a [BatchList].
  const BatchList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [BatchList] from JSON.
  factory BatchList.fromJson(Map<String, dynamic> json) {
    return BatchList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Batch.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of batches.
  final List<Batch> data;

  /// The ID of the first batch in the list.
  final String? firstId;

  /// The ID of the last batch in the list.
  final String? lastId;

  /// Whether there are more batches to retrieve.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((b) => b.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'BatchList(${data.length} batches)';
}

/// A request to create a batch.
@immutable
class CreateBatchRequest {
  /// Creates a [CreateBatchRequest].
  const CreateBatchRequest({
    required this.inputFileId,
    required this.endpoint,
    required this.completionWindow,
    this.metadata,
  });

  /// Creates a [CreateBatchRequest] from JSON.
  factory CreateBatchRequest.fromJson(Map<String, dynamic> json) {
    return CreateBatchRequest(
      inputFileId: json['input_file_id'] as String,
      endpoint: BatchEndpoint.fromJson(json['endpoint'] as String),
      completionWindow: CompletionWindow.fromJson(
        json['completion_window'] as String,
      ),
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// The ID of the input file containing batch requests.
  ///
  /// The file must be in JSONL format with each line being a request object.
  final String inputFileId;

  /// The API endpoint to use for processing.
  final BatchEndpoint endpoint;

  /// The time window for completing the batch.
  final CompletionWindow completionWindow;

  /// Custom metadata for the batch.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_file_id': inputFileId,
    'endpoint': endpoint.toJson(),
    'completion_window': completionWindow.toJson(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateBatchRequest &&
          runtimeType == other.runtimeType &&
          inputFileId == other.inputFileId &&
          endpoint == other.endpoint;

  @override
  int get hashCode => Object.hash(inputFileId, endpoint);

  @override
  String toString() => 'CreateBatchRequest(inputFileId: $inputFileId)';
}

/// Errors that occurred during batch processing.
@immutable
class BatchErrors {
  /// Creates a [BatchErrors].
  const BatchErrors({required this.object, required this.data});

  /// Creates a [BatchErrors] from JSON.
  factory BatchErrors.fromJson(Map<String, dynamic> json) {
    return BatchErrors(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => BatchError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The object type.
  final String object;

  /// The list of errors.
  final List<BatchError> data;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchErrors &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'BatchErrors(${data.length} errors)';
}

/// A single batch error.
@immutable
class BatchError {
  /// Creates a [BatchError].
  const BatchError({this.code, this.message, this.param, this.line});

  /// Creates a [BatchError] from JSON.
  factory BatchError.fromJson(Map<String, dynamic> json) {
    return BatchError(
      code: json['code'] as String?,
      message: json['message'] as String?,
      param: json['param'] as String?,
      line: json['line'] as int?,
    );
  }

  /// The error code.
  final String? code;

  /// The error message.
  final String? message;

  /// The parameter that caused the error.
  final String? param;

  /// The line number in the input file.
  final int? line;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    if (param != null) 'param': param,
    if (line != null) 'line': line,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          line == other.line;

  @override
  int get hashCode => Object.hash(code, line);

  @override
  String toString() => 'BatchError(code: $code, line: $line)';
}

/// Request counts for a batch.
@immutable
class BatchRequestCounts {
  /// Creates a [BatchRequestCounts].
  const BatchRequestCounts({
    required this.total,
    required this.completed,
    required this.failed,
  });

  /// Creates a [BatchRequestCounts] from JSON.
  factory BatchRequestCounts.fromJson(Map<String, dynamic> json) {
    return BatchRequestCounts(
      total: json['total'] as int,
      completed: json['completed'] as int,
      failed: json['failed'] as int,
    );
  }

  /// The total number of requests.
  final int total;

  /// The number of completed requests.
  final int completed;

  /// The number of failed requests.
  final int failed;

  /// The number of pending requests.
  int get pending => total - completed - failed;

  /// The completion percentage.
  double get completionPercentage =>
      total > 0 ? (completed + failed) / total * 100 : 0;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'total': total,
    'completed': completed,
    'failed': failed,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchRequestCounts &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          completed == other.completed &&
          failed == other.failed;

  @override
  int get hashCode => Object.hash(total, completed, failed);

  @override
  String toString() =>
      'BatchRequestCounts(completed: $completed/$total, failed: $failed)';
}

/// Batch status values.
enum BatchStatus {
  /// The batch is being validated.
  validating._('validating'),

  /// The batch failed validation.
  failed._('failed'),

  /// The batch is queued for processing.
  inProgress._('in_progress'),

  /// The batch is being finalized.
  finalizing._('finalizing'),

  /// The batch completed successfully.
  completed._('completed'),

  /// The batch has expired.
  expired._('expired'),

  /// The batch is being cancelled.
  cancelling._('cancelling'),

  /// The batch was cancelled.
  cancelled._('cancelled');

  const BatchStatus._(this._value);

  /// Creates from JSON string.
  factory BatchStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Batch endpoint options.
enum BatchEndpoint {
  /// Responses endpoint.
  responses._('/v1/responses'),

  /// Chat completions endpoint.
  chatCompletions._('/v1/chat/completions'),

  /// Embeddings endpoint.
  embeddings._('/v1/embeddings'),

  /// Completions endpoint (legacy).
  completions._('/v1/completions'),

  /// Moderations endpoint.
  moderations._('/v1/moderations'),

  /// Image generations endpoint.
  imagesGenerations._('/v1/images/generations'),

  /// Image edits endpoint.
  imagesEdits._('/v1/images/edits');

  const BatchEndpoint._(this._value);

  /// Creates from JSON string.
  factory BatchEndpoint.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown endpoint: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Completion window options.
enum CompletionWindow {
  /// 24-hour completion window.
  hours24._('24h');

  const CompletionWindow._(this._value);

  /// Creates from JSON string.
  factory CompletionWindow.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown window: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
