part of 'deltas.dart';

/// An audio delta update.
class AudioDelta extends InteractionDelta {
  @override
  String get type => 'audio';

  /// Base64-encoded audio data.
  final String? data;

  /// URI of the audio.
  final String? uri;

  /// The MIME type of the audio.
  final String? mimeType;

  /// The number of audio channels.
  final int? channels;

  /// The sample rate of the audio.
  final int? rate;

  /// Creates an [AudioDelta] instance.
  const AudioDelta({
    this.data,
    this.uri,
    this.mimeType,
    this.channels,
    this.rate,
  });

  /// Creates an [AudioDelta] from JSON.
  factory AudioDelta.fromJson(Map<String, dynamic> json) => AudioDelta(
    data: json['data'] as String?,
    uri: json['uri'] as String?,
    mimeType: json['mime_type'] as String?,
    channels: json['channels'] as int?,
    rate: json['rate'] as int?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data,
    if (uri != null) 'uri': uri,
    if (mimeType != null) 'mime_type': mimeType,
    if (channels != null) 'channels': channels,
    if (rate != null) 'rate': rate,
  };
}
