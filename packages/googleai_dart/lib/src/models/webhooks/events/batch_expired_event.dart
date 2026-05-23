part of 'webhook_event.dart';

/// A `batch.expired` webhook event.
///
/// Delivered when a batch was not processed within the 48h timeframe.
class WebhookBatchExpiredEvent extends WebhookEvent {
  @override
  String get type => 'batch.expired';

  /// The ID of the batch.
  final String id;

  /// Creates a [WebhookBatchExpiredEvent] instance.
  const WebhookBatchExpiredEvent({
    required this.id,
    super.version,
    super.timestamp,
  });

  /// Creates a [WebhookBatchExpiredEvent] from JSON.
  factory WebhookBatchExpiredEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'batch.expired') {
      throw FormatException(
        'Expected type "batch.expired" but got "${json['type']}"',
      );
    }
    return WebhookBatchExpiredEvent(
      id: _requireDataId(json, 'WebhookBatchExpiredEvent'),
      version: json['version'] as String?,
      timestamp: _readTimestamp(json),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (version != null) 'version': version,
    if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    'data': {'id': id},
  };
}
