import '../../copy_with_sentinel.dart';

/// Selects a prebuilt avatar for a supported Vertex AI Live model.
class LiveAvatarConfig {
  /// The avatar ID, for example `Ben`.
  final String avatarName;

  /// Requested bitrate of compressed audio, in bits per second.
  final int? audioBitrateBps;

  /// Requested bitrate of compressed video, in bits per second.
  final int? videoBitrateBps;

  /// Creates a configuration for a prebuilt avatar.
  const LiveAvatarConfig({
    required this.avatarName,
    this.audioBitrateBps,
    this.videoBitrateBps,
  });

  /// Creates a configuration from its JSON representation.
  factory LiveAvatarConfig.fromJson(Map<String, dynamic> json) =>
      LiveAvatarConfig(
        avatarName: json['avatarName'] as String,
        audioBitrateBps: json['audioBitrateBps'] as int?,
        videoBitrateBps: json['videoBitrateBps'] as int?,
      );

  /// Converts this configuration to JSON.
  Map<String, dynamic> toJson() => {
    'avatarName': avatarName,
    'audioBitrateBps': ?audioBitrateBps,
    'videoBitrateBps': ?videoBitrateBps,
  };

  /// Creates a copy, optionally replacing or clearing the requested bitrates.
  LiveAvatarConfig copyWith({
    String? avatarName,
    Object? audioBitrateBps = unsetCopyWithValue,
    Object? videoBitrateBps = unsetCopyWithValue,
  }) => LiveAvatarConfig(
    avatarName: avatarName ?? this.avatarName,
    audioBitrateBps: audioBitrateBps == unsetCopyWithValue
        ? this.audioBitrateBps
        : audioBitrateBps as int?,
    videoBitrateBps: videoBitrateBps == unsetCopyWithValue
        ? this.videoBitrateBps
        : videoBitrateBps as int?,
  );

  @override
  String toString() =>
      'LiveAvatarConfig(avatarName: $avatarName, '
      'audioBitrateBps: $audioBitrateBps, videoBitrateBps: $videoBitrateBps)';
}
