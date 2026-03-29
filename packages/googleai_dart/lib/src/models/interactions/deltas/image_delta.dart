part of 'deltas.dart';

/// An image delta update.
class ImageDelta extends InteractionDelta {
  @override
  String get type => 'image';

  /// Base64-encoded image data.
  final String? data;

  /// URI of the image.
  final String? uri;

  /// The MIME type of the image.
  final String? mimeType;

  /// The resolution of the media.
  final InteractionMediaResolution? resolution;

  /// Creates an [ImageDelta] instance.
  const ImageDelta({this.data, this.uri, this.mimeType, this.resolution});

  /// Creates an [ImageDelta] from JSON.
  factory ImageDelta.fromJson(Map<String, dynamic> json) => ImageDelta(
    data: json['data'] as String?,
    uri: json['uri'] as String?,
    mimeType: json['mime_type'] as String?,
    resolution: json['resolution'] != null
        ? interactionMediaResolutionFromString(json['resolution'] as String?)
        : null,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data,
    if (uri != null) 'uri': uri,
    if (mimeType != null) 'mime_type': mimeType,
    if (resolution != null)
      'resolution': interactionMediaResolutionToString(resolution!),
  };
}
