part of 'webhook_event.dart';

/// An `interaction.failed` webhook event.
///
/// Delivered when an interaction fails.
class WebhookInteractionFailedEvent extends WebhookEvent {
  @override
  String get type => 'interaction.failed';

  /// The ID of the interaction.
  final String id;

  /// Server-supplied error code, if any.
  final String? errorCode;

  /// Server-supplied error message, if any.
  final String? errorMessage;

  /// Creates a [WebhookInteractionFailedEvent] instance.
  const WebhookInteractionFailedEvent({
    required this.id,
    this.errorCode,
    this.errorMessage,
    super.version,
    super.timestamp,
  });

  /// Creates a [WebhookInteractionFailedEvent] from JSON.
  factory WebhookInteractionFailedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'interaction.failed') {
      throw FormatException(
        'Expected type "interaction.failed" but got "${json['type']}"',
      );
    }
    final id = _requireDataId(json, 'WebhookInteractionFailedEvent');
    final data = _readData(json)!;
    return WebhookInteractionFailedEvent(
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
