part of 'webhook_event.dart';

/// A `batch.failed` webhook event.
///
/// Delivered when a batch job failed.
class WebhookBatchFailedEvent extends WebhookEvent {
  @override
  String get type => 'batch.failed';

  /// The ID of the batch.
  final String id;

  /// Server-supplied error code, if any.
  final String? errorCode;

  /// Server-supplied error message, if any.
  final String? errorMessage;

  /// Creates a [WebhookBatchFailedEvent] instance.
  const WebhookBatchFailedEvent({
    required this.id,
    this.errorCode,
    this.errorMessage,
    super.version,
    super.timestamp,
  });

  /// Creates a [WebhookBatchFailedEvent] from JSON.
  factory WebhookBatchFailedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'batch.failed') {
      throw FormatException(
        'Expected type "batch.failed" but got "${json['type']}"',
      );
    }
    final id = _requireDataId(json, 'WebhookBatchFailedEvent');
    final data = _readData(json)!;
    return WebhookBatchFailedEvent(
      id: id,
      errorCode: data['error_code'] as String?,
      errorMessage: data['error_message'] as String?,
      version: json['version'] as String?,
      timestamp: _readTimestamp(json),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (version != null) 'version': version,
    if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    'data': {
      'id': id,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
    },
  };
}
