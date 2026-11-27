part of 'content.dart';

/// A video content block.
class VideoContent extends InteractionContent {
  @override
  String get type => 'video';

  /// Base64-encoded video data.
  final String? data;

  /// URI of the video.
  final String? uri;

  /// The MIME type of the video.
  final String? mimeType;

  /// The resolution of the media.
  final InteractionMediaResolution? resolution;

  /// Video processing mode or clip and layer selection.
  final InteractionVideoProcessing? processing;

  /// The name the model can use to refer to this content block.
  final String? name;

  /// Creates a [VideoContent] instance.
  const VideoContent({
    this.data,
    this.uri,
    this.mimeType,
    this.resolution,
    this.processing,
    this.name,
  });

  /// Creates a [VideoContent] from JSON.
  factory VideoContent.fromJson(Map<String, dynamic> json) => VideoContent(
    data: json['data'] as String?,
    uri: json['uri'] as String?,
    mimeType: json['mime_type'] as String?,
    resolution: json['resolution'] != null
        ? interactionMediaResolutionFromString(json['resolution'] as String?)
        : null,
    processing: json['processing'] == null
        ? null
        : InteractionVideoProcessing.fromJson(json['processing'] as Object),
    name: json['name'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data,
    if (uri != null) 'uri': uri,
    if (mimeType != null) 'mime_type': mimeType,
    if (resolution != null)
      'resolution': interactionMediaResolutionToString(resolution!),
    'processing': ?processing?.toJson(),
    'name': ?name,
  };

  /// Creates a copy with replaced values.
  VideoContent copyWith({
    Object? data = unsetCopyWithValue,
    Object? uri = unsetCopyWithValue,
    Object? mimeType = unsetCopyWithValue,
    Object? resolution = unsetCopyWithValue,
    Object? processing = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
  }) {
    return VideoContent(
      data: data == unsetCopyWithValue ? this.data : data as String?,
      uri: uri == unsetCopyWithValue ? this.uri : uri as String?,
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as String?,
      resolution: resolution == unsetCopyWithValue
          ? this.resolution
          : resolution as InteractionMediaResolution?,
      processing: processing == unsetCopyWithValue
          ? this.processing
          : processing as InteractionVideoProcessing?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
    );
  }
}
