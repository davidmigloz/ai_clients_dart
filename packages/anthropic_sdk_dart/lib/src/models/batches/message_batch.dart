import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../messages/message.dart';
import '../metadata/processing_status.dart';

/// Counts of requests in different states within a batch.
@immutable
class RequestCounts {
  /// Number of requests being processed.
  final int processing;

  /// Number of successfully completed requests.
  final int succeeded;

  /// Number of requests that errored.
  final int errored;

  /// Number of canceled requests.
  final int canceled;

  /// Number of expired requests.
  final int expired;

  /// Creates a [RequestCounts].
  const RequestCounts({
    required this.processing,
    required this.succeeded,
    required this.errored,
    required this.canceled,
    required this.expired,
  });

  /// Creates a [RequestCounts] from JSON.
  factory RequestCounts.fromJson(Map<String, dynamic> json) {
    return RequestCounts(
      processing: json['processing'] as int,
      succeeded: json['succeeded'] as int,
      errored: json['errored'] as int,
      canceled: json['canceled'] as int,
      expired: json['expired'] as int,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'processing': processing,
    'succeeded': succeeded,
    'errored': errored,
    'canceled': canceled,
    'expired': expired,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestCounts &&
          runtimeType == other.runtimeType &&
          processing == other.processing &&
          succeeded == other.succeeded &&
          errored == other.errored &&
          canceled == other.canceled &&
          expired == other.expired;

  @override
  int get hashCode =>
      Object.hash(processing, succeeded, errored, canceled, expired);

  @override
  String toString() =>
      'RequestCounts(processing: $processing, succeeded: $succeeded, '
      'errored: $errored, canceled: $canceled, expired: $expired)';
}

/// A message batch object.
@immutable
class MessageBatch {
  /// Unique batch identifier.
  final String id;

  /// Object type. Always "message_batch".
  final String type;

  /// Processing status of the batch.
  final ProcessingStatus processingStatus;

  /// Counts of requests by status.
  final RequestCounts requestCounts;

  /// Time at which the batch ended.
  final DateTime? endedAt;

  /// Time at which the batch was created.
  final DateTime createdAt;

  /// Time at which the batch expires.
  final DateTime expiresAt;

  /// Time at which result archiving started.
  final DateTime? archivedAt;

  /// Time at which request canceling started.
  final DateTime? cancelInitiatedAt;

  /// URL to the results file.
  final String? resultsUrl;

  /// Creates a [MessageBatch].
  const MessageBatch({
    required this.id,
    this.type = 'message_batch',
    required this.processingStatus,
    required this.requestCounts,
    this.endedAt,
    required this.createdAt,
    required this.expiresAt,
    this.archivedAt,
    this.cancelInitiatedAt,
    this.resultsUrl,
  });

  /// Creates a [MessageBatch] from JSON.
  factory MessageBatch.fromJson(Map<String, dynamic> json) {
    return MessageBatch(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'message_batch',
      processingStatus: ProcessingStatus.fromJson(
        json['processing_status'] as String,
      ),
      requestCounts: RequestCounts.fromJson(
        json['request_counts'] as Map<String, dynamic>,
      ),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
      cancelInitiatedAt: json['cancel_initiated_at'] != null
          ? DateTime.parse(json['cancel_initiated_at'] as String)
          : null,
      resultsUrl: json['results_url'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'processing_status': processingStatus.toJson(),
    'request_counts': requestCounts.toJson(),
    if (endedAt != null) 'ended_at': endedAt!.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'expires_at': expiresAt.toUtc().toIso8601String(),
    if (archivedAt != null)
      'archived_at': archivedAt!.toUtc().toIso8601String(),
    if (cancelInitiatedAt != null)
      'cancel_initiated_at': cancelInitiatedAt!.toUtc().toIso8601String(),
    if (resultsUrl != null) 'results_url': resultsUrl,
  };

  /// Creates a copy with replaced values.
  MessageBatch copyWith({
    String? id,
    String? type,
    ProcessingStatus? processingStatus,
    RequestCounts? requestCounts,
    Object? endedAt = unsetCopyWithValue,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? archivedAt = unsetCopyWithValue,
    Object? cancelInitiatedAt = unsetCopyWithValue,
    Object? resultsUrl = unsetCopyWithValue,
  }) {
    return MessageBatch(
      id: id ?? this.id,
      type: type ?? this.type,
      processingStatus: processingStatus ?? this.processingStatus,
      requestCounts: requestCounts ?? this.requestCounts,
      endedAt: endedAt == unsetCopyWithValue
          ? this.endedAt
          : endedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      archivedAt: archivedAt == unsetCopyWithValue
          ? this.archivedAt
          : archivedAt as DateTime?,
      cancelInitiatedAt: cancelInitiatedAt == unsetCopyWithValue
          ? this.cancelInitiatedAt
          : cancelInitiatedAt as DateTime?,
      resultsUrl: resultsUrl == unsetCopyWithValue
          ? this.resultsUrl
          : resultsUrl as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageBatch &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          processingStatus == other.processingStatus &&
          requestCounts == other.requestCounts &&
          endedAt == other.endedAt &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt &&
          archivedAt == other.archivedAt &&
          cancelInitiatedAt == other.cancelInitiatedAt &&
          resultsUrl == other.resultsUrl;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    processingStatus,
    requestCounts,
    endedAt,
    createdAt,
    expiresAt,
    archivedAt,
    cancelInitiatedAt,
    resultsUrl,
  );

  @override
  String toString() =>
      'MessageBatch(id: $id, type: $type, processingStatus: $processingStatus, '
      'requestCounts: $requestCounts, endedAt: $endedAt, createdAt: $createdAt, '
      'expiresAt: $expiresAt, archivedAt: $archivedAt, '
      'cancelInitiatedAt: $cancelInitiatedAt, resultsUrl: $resultsUrl)';
}

/// Response for listing message batches.
@immutable
class MessageBatchListResponse {
  /// List of batches.
  final List<MessageBatch> data;

  /// Whether there are more results.
  final bool hasMore;

  /// ID of the first batch in the list.
  final String? firstId;

  /// ID of the last batch in the list.
  final String? lastId;

  /// Creates a [MessageBatchListResponse].
  const MessageBatchListResponse({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates a [MessageBatchListResponse] from JSON.
  factory MessageBatchListResponse.fromJson(Map<String, dynamic> json) {
    return MessageBatchListResponse(
      data: (json['data'] as List)
          .map((e) => MessageBatch.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageBatchListResponse &&
          runtimeType == other.runtimeType &&
          _listsEqual(data, other.data) &&
          hasMore == other.hasMore &&
          firstId == other.firstId &&
          lastId == other.lastId;

  @override
  int get hashCode => Object.hash(data, hasMore, firstId, lastId);

  @override
  String toString() =>
      'MessageBatchListResponse(data: $data, hasMore: $hasMore, '
      'firstId: $firstId, lastId: $lastId)';
}

/// Delete response for a message batch.
@immutable
class DeletedMessageBatch {
  /// Unique batch identifier.
  final String id;

  /// Object type. Always "message_batch_deleted".
  final String type;

  /// Creates a [DeletedMessageBatch].
  const DeletedMessageBatch({
    required this.id,
    this.type = 'message_batch_deleted',
  });

  /// Creates a [DeletedMessageBatch] from JSON.
  factory DeletedMessageBatch.fromJson(Map<String, dynamic> json) {
    return DeletedMessageBatch(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'message_batch_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedMessageBatch &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'DeletedMessageBatch(id: $id, type: $type)';
}

/// Result of a batch request.
sealed class BatchResult {
  const BatchResult();

  /// Creates a [BatchResult] from JSON.
  factory BatchResult.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'succeeded' => BatchResultSucceeded.fromJson(json),
      'errored' => BatchResultErrored.fromJson(json),
      'canceled' => BatchResultCanceled.fromJson(json),
      'expired' => BatchResultExpired.fromJson(json),
      _ => throw FormatException('Unknown BatchResult type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Successful batch result.
@immutable
class BatchResultSucceeded extends BatchResult {
  /// The message response.
  final Message message;

  /// Creates a [BatchResultSucceeded].
  const BatchResultSucceeded({required this.message});

  /// Creates a [BatchResultSucceeded] from JSON.
  factory BatchResultSucceeded.fromJson(Map<String, dynamic> json) {
    return BatchResultSucceeded(
      message: Message.fromJson(json['message'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'succeeded',
    'message': message.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchResultSucceeded &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'BatchResultSucceeded(message: $message)';
}

/// Error information in batch results.
@immutable
class BatchError {
  /// The error type.
  final String type;

  /// The error message.
  final String message;

  /// Creates a [BatchError].
  const BatchError({required this.type, required this.message});

  /// Creates a [BatchError] from JSON.
  factory BatchError.fromJson(Map<String, dynamic> json) {
    return BatchError(
      type: json['type'] as String,
      message: json['message'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message;

  @override
  int get hashCode => Object.hash(type, message);

  @override
  String toString() => 'BatchError(type: $type, message: $message)';
}

/// Errored batch result.
@immutable
class BatchResultErrored extends BatchResult {
  /// The error information.
  final BatchError error;

  /// Creates a [BatchResultErrored].
  const BatchResultErrored({required this.error});

  /// Creates a [BatchResultErrored] from JSON.
  factory BatchResultErrored.fromJson(Map<String, dynamic> json) {
    return BatchResultErrored(
      error: BatchError.fromJson(json['error'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'errored', 'error': error.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchResultErrored &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'BatchResultErrored(error: $error)';
}

/// Canceled batch result.
@immutable
class BatchResultCanceled extends BatchResult {
  /// Creates a [BatchResultCanceled].
  const BatchResultCanceled();

  /// Creates a [BatchResultCanceled] from JSON.
  factory BatchResultCanceled.fromJson(Map<String, dynamic> _) {
    return const BatchResultCanceled();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'canceled'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchResultCanceled && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BatchResultCanceled()';
}

/// Expired batch result.
@immutable
class BatchResultExpired extends BatchResult {
  /// Creates a [BatchResultExpired].
  const BatchResultExpired();

  /// Creates a [BatchResultExpired] from JSON.
  factory BatchResultExpired.fromJson(Map<String, dynamic> _) {
    return const BatchResultExpired();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'expired'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchResultExpired && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BatchResultExpired()';
}

/// Individual batch response item.
@immutable
class BatchIndividualResponse {
  /// Custom ID provided in the request.
  final String customId;

  /// The result of the request.
  final BatchResult result;

  /// Creates a [BatchIndividualResponse].
  const BatchIndividualResponse({required this.customId, required this.result});

  /// Creates a [BatchIndividualResponse] from JSON.
  factory BatchIndividualResponse.fromJson(Map<String, dynamic> json) {
    return BatchIndividualResponse(
      customId: json['custom_id'] as String,
      result: BatchResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_id': customId,
    'result': result.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchIndividualResponse &&
          runtimeType == other.runtimeType &&
          customId == other.customId &&
          result == other.result;

  @override
  int get hashCode => Object.hash(customId, result);

  @override
  String toString() =>
      'BatchIndividualResponse(customId: $customId, result: $result)';
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
