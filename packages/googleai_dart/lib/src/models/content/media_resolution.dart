import '../copy_with_sentinel.dart';

/// Media resolution for a media part.
class MediaResolution {
  /// The media resolution level used.
  final MediaResolutionLevel? level;

  /// The number of tokens used for the media part at this resolution.
  final int? numTokens;

  /// Creates a [MediaResolution].
  const MediaResolution({this.level, this.numTokens});

  /// Creates a [MediaResolution] from JSON.
  factory MediaResolution.fromJson(Map<String, dynamic> json) =>
      MediaResolution(
        level: json['level'] != null
            ? mediaResolutionLevelFromString(json['level'] as String)
            : null,
        numTokens: json['numTokens'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (level != null) 'level': mediaResolutionLevelToString(level!),
    if (numTokens != null) 'numTokens': numTokens,
  };

  /// Creates a copy with replaced values.
  MediaResolution copyWith({
    Object? level = unsetCopyWithValue,
    Object? numTokens = unsetCopyWithValue,
  }) {
    return MediaResolution(
      level: level == unsetCopyWithValue
          ? this.level
          : level as MediaResolutionLevel?,
      numTokens: numTokens == unsetCopyWithValue
          ? this.numTokens
          : numTokens as int?,
    );
  }

  @override
  String toString() => 'MediaResolution(level: $level, numTokens: $numTokens)';
}

/// Media resolution level.
enum MediaResolutionLevel {
  /// Media resolution has not been set.
  unspecified,

  /// Media resolution set to low.
  low,

  /// Media resolution set to medium.
  medium,

  /// Media resolution set to high.
  high,

  /// Media resolution set to ultra high.
  ultraHigh,
}

/// Converts a string to a [MediaResolutionLevel] enum value.
MediaResolutionLevel mediaResolutionLevelFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'MEDIA_RESOLUTION_LOW' => MediaResolutionLevel.low,
    'MEDIA_RESOLUTION_MEDIUM' => MediaResolutionLevel.medium,
    'MEDIA_RESOLUTION_HIGH' => MediaResolutionLevel.high,
    'MEDIA_RESOLUTION_ULTRA_HIGH' => MediaResolutionLevel.ultraHigh,
    _ => MediaResolutionLevel.unspecified,
  };
}

/// Converts a [MediaResolutionLevel] enum value to a string.
String mediaResolutionLevelToString(MediaResolutionLevel level) {
  return switch (level) {
    MediaResolutionLevel.low => 'MEDIA_RESOLUTION_LOW',
    MediaResolutionLevel.medium => 'MEDIA_RESOLUTION_MEDIUM',
    MediaResolutionLevel.high => 'MEDIA_RESOLUTION_HIGH',
    MediaResolutionLevel.ultraHigh => 'MEDIA_RESOLUTION_ULTRA_HIGH',
    MediaResolutionLevel.unspecified => 'MEDIA_RESOLUTION_UNSPECIFIED',
  };
}
