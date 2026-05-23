part of 'webhook_event.dart';

/// A `batch.succeeded` webhook event.
///
/// Delivered when batch processing finishes successfully.
class WebhookBatchSucceededEvent extends WebhookEvent {
  @override
  String get type => 'batch.succeeded';

  /// The ID of the batch.
  final String id;

  /// The URI to the batch's output file.
  final String? outputFileUri;

  /// Creates a [WebhookBatchSucceededEvent] instance.
  const WebhookBatchSucceededEvent({
    required this.id,
    this.outputFileUri,
    super.version,
    super.timestamp,
  });

  /// Creates a [WebhookBatchSucceededEvent] from JSON.
  factory WebhookBatchSucceededEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'batch.succeeded') {
      throw FormatException(
        'Expected type "batch.succeeded" but got "${json['type']}"',
      );
    }
    final id = _requireDataId(json, 'WebhookBatchSucceededEvent');
    final data = _readData(json)!;
    return WebhookBatchSucceededEvent(
      id: id,
      outputFileUri: data['output_file_uri'] as String?,
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
      if (outputFileUri != null) 'output_file_uri': outputFileUri,
    },
  };
}
