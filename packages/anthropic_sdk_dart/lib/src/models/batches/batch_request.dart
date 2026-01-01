import 'package:meta/meta.dart';

import '../messages/message_create_request.dart';

/// Individual request item for batch creation.
@immutable
class BatchRequestItem {
  /// Custom identifier for this request.
  ///
  /// Must be unique within the batch.
  final String customId;

  /// The request parameters for message creation.
  final MessageCreateRequest params;

  /// Creates a [BatchRequestItem].
  const BatchRequestItem({required this.customId, required this.params});

  /// Creates a [BatchRequestItem] from JSON.
  factory BatchRequestItem.fromJson(Map<String, dynamic> json) {
    return BatchRequestItem(
      customId: json['custom_id'] as String,
      params: MessageCreateRequest.fromJson(
        json['params'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_id': customId,
    'params': params.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchRequestItem &&
          runtimeType == other.runtimeType &&
          customId == other.customId &&
          params == other.params;

  @override
  int get hashCode => Object.hash(customId, params);

  @override
  String toString() => 'BatchRequestItem(customId: $customId, params: $params)';
}

/// Request for creating a message batch.
@immutable
class MessageBatchCreateRequest {
  /// List of requests to process.
  final List<BatchRequestItem> requests;

  /// Creates a [MessageBatchCreateRequest].
  const MessageBatchCreateRequest({required this.requests});

  /// Creates a [MessageBatchCreateRequest] from JSON.
  factory MessageBatchCreateRequest.fromJson(Map<String, dynamic> json) {
    return MessageBatchCreateRequest(
      requests: (json['requests'] as List)
          .map((e) => BatchRequestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'requests': requests.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageBatchCreateRequest &&
          runtimeType == other.runtimeType &&
          _listsEqual(requests, other.requests);

  @override
  int get hashCode => requests.hashCode;

  @override
  String toString() => 'MessageBatchCreateRequest(requests: $requests)';
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
