import '../../utils/media_wire_options.dart';
import '../copy_with_sentinel.dart';

/// Content to extract from a video.
///
/// Retains the wire value for options added by future API versions.
extension type const VideoContentLayer(String value) {
  /// Use the default content layers.
  static const unspecified = VideoContentLayer('CONTENT_LAYER_UNSPECIFIED');

  /// Extract video frames.
  static const frames = VideoContentLayer('FRAMES');

  /// Extract the audio track.
  static const audio = VideoContentLayer('AUDIO');

  /// Extract the audio transcript.
  static const transcript = VideoContentLayer('TRANSCRIPT');

  /// Creates a value from the API representation.
  factory VideoContentLayer.fromJson(String value) => VideoContentLayer(value);

  /// Converts to JSON.
  String toJson() => value;
}

/// Video information in Files responses and clipping options for media input.
class VideoMetadata {
  /// Total file duration returned by the Files API, such as `3.5s`.
  final String? videoDuration;

  /// Clip start as a protobuf duration.
  final String? startOffset;

  /// Clip end as a protobuf duration.
  final String? endOffset;

  /// Frame rate for static video sampling, in frames per second.
  final double? fps;

  /// The layers to extract. An empty list selects the backend defaults.
  final List<VideoContentLayer>? contentLayers;

  /// Creates a [VideoMetadata].
  const VideoMetadata({
    this.videoDuration,
    this.startOffset,
    this.endOffset,
    this.fps,
    this.contentLayers,
  }) : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const VideoMetadata._({
    this.videoDuration,
    this.startOffset,
    this.endOffset,
    this.fps,
    this.contentLayers,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory VideoMetadata.fromJson(Map<String, dynamic> json) => VideoMetadata._(
    videoDuration: json['videoDuration'] as String?,
    startOffset: json['startOffset'] as String?,
    endOffset: json['endOffset'] as String?,
    fps: (json['fps'] as num?)?.toDouble(),
    contentLayers: (json['contentLayers'] as List?)
        ?.cast<String>()
        .map(VideoContentLayer.fromJson)
        .toList(),
    wireExtensions: mediaExtensions(json, const {
      'videoDuration',
      'startOffset',
      'endOffset',
      'fps',
      'contentLayers',
    }),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    if (videoDuration != null) 'videoDuration': videoDuration,
    if (startOffset != null) 'startOffset': startOffset,
    if (endOffset != null) 'endOffset': endOffset,
    if (fps != null) 'fps': fps,
    if (contentLayers != null)
      'contentLayers': contentLayers!.map((value) => value.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  VideoMetadata copyWith({
    Object? videoDuration = unsetCopyWithValue,
    Object? startOffset = unsetCopyWithValue,
    Object? endOffset = unsetCopyWithValue,
    Object? fps = unsetCopyWithValue,
    Object? contentLayers = unsetCopyWithValue,
  }) => VideoMetadata._(
    videoDuration: videoDuration == unsetCopyWithValue
        ? this.videoDuration
        : videoDuration as String?,
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as String?,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as String?,
    fps: fps == unsetCopyWithValue ? this.fps : (fps as num?)?.toDouble(),
    contentLayers: contentLayers == unsetCopyWithValue
        ? this.contentLayers
        : contentLayers as List<VideoContentLayer>?,
    wireExtensions: _wireExtensions,
  );
}
