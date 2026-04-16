part of 'content.dart';

/// An audio content block.
class AudioContent extends InteractionContent {
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

  /// Creates an [AudioContent] instance.
  const AudioContent({
    this.data,
    this.uri,
    this.mimeType,
    this.channels,
    this.rate,
  });

  /// Creates an [AudioContent] from JSON.
  factory AudioContent.fromJson(Map<String, dynamic> json) => AudioContent(
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

  /// Creates a copy with replaced values.
  AudioContent copyWith({
    Object? data = unsetCopyWithValue,
    Object? uri = unsetCopyWithValue,
    Object? mimeType = unsetCopyWithValue,
    Object? channels = unsetCopyWithValue,
    Object? rate = unsetCopyWithValue,
  }) {
    return AudioContent(
      data: data == unsetCopyWithValue ? this.data : data as String?,
      uri: uri == unsetCopyWithValue ? this.uri : uri as String?,
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as String?,
      channels: channels == unsetCopyWithValue
          ? this.channels
          : channels as int?,
      rate: rate == unsetCopyWithValue ? this.rate : rate as int?,
    );
  }
}
