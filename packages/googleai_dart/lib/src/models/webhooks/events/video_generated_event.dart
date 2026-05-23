part of 'webhook_event.dart';

/// A `video.generated` webhook event.
///
/// Delivered when video generation completes.
class WebhookVideoGeneratedEvent extends WebhookEvent {
  @override
  String get type => 'video.generated';

  /// The ID of the generated video.
  final String id;

  /// The URI of the generated video file.
  final String? outputFileUri;

  /// The name of the generated video file.
  final String? fileName;

  /// Creates a [WebhookVideoGeneratedEvent] instance.
  const WebhookVideoGeneratedEvent({
    required this.id,
    this.outputFileUri,
    this.fileName,
    super.version,
    super.timestamp,
  });

  /// Creates a [WebhookVideoGeneratedEvent] from JSON.
  factory WebhookVideoGeneratedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'video.generated') {
      throw FormatException(
        'Expected type "video.generated" but got "${json['type']}"',
      );
    }
    final id = _requireDataId(json, 'WebhookVideoGeneratedEvent');
    final data = _readData(json)!;
    return WebhookVideoGeneratedEvent(
      id: id,
      outputFileUri: data['output_file_uri'] as String?,
      fileName: data['file_name'] as String?,
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
      if (fileName != null) 'file_name': fileName,
    },
  };
}
