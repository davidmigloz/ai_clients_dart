import 'package:meta/meta.dart';

/// A generated video job.
///
/// Structured information describing a generated video job from Sora.
///
/// ## Example
///
/// ```dart
/// final video = await client.videos.retrieve('video-abc123');
/// print('Status: ${video.status}');
/// print('Progress: ${video.progress}%');
/// ```
@immutable
class Video {
  /// Creates a [Video].
  const Video({
    required this.id,
    required this.object,
    required this.model,
    required this.status,
    required this.progress,
    required this.createdAt,
    required this.completedAt,
    required this.expiresAt,
    required this.prompt,
    required this.size,
    required this.seconds,
    required this.remixedFromVideoId,
    this.error,
  });

  /// Creates a [Video] from JSON.
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'video',
      model: json['model'] as String,
      status: VideoStatus.fromJson(json['status'] as String),
      progress: json['progress'] as int,
      createdAt: json['created_at'] as int,
      completedAt: json['completed_at'] as int?,
      expiresAt: json['expires_at'] as int?,
      prompt: json['prompt'] as String?,
      size: VideoSize.fromJson(json['size'] as String),
      seconds: VideoSeconds.fromJson(json['seconds'] as String),
      remixedFromVideoId: json['remixed_from_video_id'] as String?,
      error: json['error'] != null
          ? VideoError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Unique identifier for the video job.
  final String id;

  /// The object type, which is always `video`.
  final String object;

  /// The video generation model that produced the job.
  final String model;

  /// Current lifecycle status of the video job.
  final VideoStatus status;

  /// Approximate completion percentage for the generation task.
  final int progress;

  /// Unix timestamp (seconds) for when the job was created.
  final int createdAt;

  /// Unix timestamp (seconds) for when the job completed, if finished.
  final int? completedAt;

  /// Unix timestamp (seconds) for when the downloadable assets expire, if set.
  final int? expiresAt;

  /// The prompt that was used to generate the video.
  final String? prompt;

  /// The resolution of the generated video.
  final VideoSize size;

  /// Duration of the generated clip in seconds.
  final VideoSeconds seconds;

  /// Identifier of the source video if this video is a remix.
  final String? remixedFromVideoId;

  /// Error payload that explains why generation failed, if applicable.
  final VideoError? error;

  /// The creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// The completion time as a DateTime, if completed.
  DateTime? get completedAtDateTime => completedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(completedAt! * 1000)
      : null;

  /// The expiration time as a DateTime, if set.
  DateTime? get expiresAtDateTime => expiresAt != null
      ? DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000)
      : null;

  /// Whether this video is a remix of another video.
  bool get isRemix => remixedFromVideoId != null;

  /// Whether the video generation has completed.
  bool get isCompleted => status == VideoStatus.completed;

  /// Whether the video generation has failed.
  bool get isFailed => status == VideoStatus.failed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'model': model,
    'status': status.toJson(),
    'progress': progress,
    'created_at': createdAt,
    'completed_at': completedAt,
    'expires_at': expiresAt,
    'prompt': prompt,
    'size': size.toJson(),
    'seconds': seconds.toJson(),
    'remixed_from_video_id': remixedFromVideoId,
    if (error != null) 'error': error!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Video && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Video(id: $id, status: $status, progress: $progress%)';
}

/// A list of videos.
@immutable
class VideoList {
  /// Creates a [VideoList].
  const VideoList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [VideoList] from JSON.
  factory VideoList.fromJson(Map<String, dynamic> json) {
    return VideoList(
      object: json['object'] as String? ?? 'list',
      data: (json['data'] as List<dynamic>)
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type, which is always `list`.
  final String object;

  /// The list of videos.
  final List<Video> data;

  /// The ID of the first item in the list.
  final String? firstId;

  /// The ID of the last item in the list.
  final String? lastId;

  /// Whether there are more items available.
  final bool hasMore;

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of videos.
  int get length => data.length;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((v) => v.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          data.length == other.data.length;

  @override
  int get hashCode => Object.hash(object, data.length);

  @override
  String toString() => 'VideoList(${data.length} videos)';
}

/// The response from deleting a video.
@immutable
class DeleteVideoResponse {
  /// Creates a [DeleteVideoResponse].
  const DeleteVideoResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteVideoResponse] from JSON.
  factory DeleteVideoResponse.fromJson(Map<String, dynamic> json) {
    return DeleteVideoResponse(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'video.deleted',
      deleted: json['deleted'] as bool,
    );
  }

  /// Identifier of the deleted video.
  final String id;

  /// The object type that signals the deletion response.
  final String object;

  /// Indicates that the video resource was deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteVideoResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(id, deleted);

  @override
  String toString() => 'DeleteVideoResponse(id: $id, deleted: $deleted)';
}

/// Error information for a failed video generation.
@immutable
class VideoError {
  /// Creates a [VideoError].
  const VideoError({this.message, this.type, this.code});

  /// Creates a [VideoError] from JSON.
  factory VideoError.fromJson(Map<String, dynamic> json) {
    return VideoError(
      message: json['message'] as String?,
      type: json['type'] as String?,
      code: json['code'] as String?,
    );
  }

  /// The error message.
  final String? message;

  /// The error type.
  final String? type;

  /// The error code.
  final String? code;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (message != null) 'message': message,
    if (type != null) 'type': type,
    if (code != null) 'code': code,
  };

  @override
  String toString() => 'VideoError(message: $message)';
}

/// A video character created from an uploaded video.
@immutable
class VideoCharacter {
  /// Unix timestamp (in seconds) when the character was created.
  final int createdAt;

  /// Unique identifier for the character.
  final String? id;

  /// Display name for the character.
  final String? name;

  /// Creates a [VideoCharacter].
  const VideoCharacter({required this.createdAt, this.id, this.name});

  /// Creates a [VideoCharacter] from JSON.
  factory VideoCharacter.fromJson(Map<String, dynamic> json) {
    return VideoCharacter(
      createdAt: json['created_at'] as int,
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,
    'id': id,
    'name': name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoCharacter &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(createdAt, id, name);

  @override
  String toString() => 'VideoCharacter(id: $id, name: $name)';
}

/// Current lifecycle status of a video job.
enum VideoStatus {
  /// Video is queued for processing.
  queued._('queued'),

  /// Video generation is in progress.
  inProgress._('in_progress'),

  /// Video generation has completed.
  completed._('completed'),

  /// Video generation has failed.
  failed._('failed');

  const VideoStatus._(this._value);

  /// Creates from JSON string.
  factory VideoStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown video status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Video resolution.
enum VideoSize {
  /// 720x1280 (portrait).
  size720x1280._('720x1280'),

  /// 1280x720 (landscape).
  size1280x720._('1280x720'),

  /// 1024x1792 (tall portrait).
  size1024x1792._('1024x1792'),

  /// 1792x1024 (wide landscape).
  size1792x1024._('1792x1024');

  const VideoSize._(this._value);

  /// Creates from JSON string.
  factory VideoSize.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown video size: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Video duration in seconds.
enum VideoSeconds {
  /// 4 seconds.
  s4._('4'),

  /// 8 seconds.
  s8._('8'),

  /// 12 seconds.
  s12._('12'),

  /// 16 seconds (extensions only).
  s16._('16'),

  /// 20 seconds (extensions only).
  s20._('20');

  const VideoSeconds._(this._value);

  /// Creates from JSON string.
  factory VideoSeconds.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown video seconds: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  /// The duration as an integer.
  int get asInt => int.parse(_value);

  @override
  String toString() => _value;
}

/// Video content variant for download.
enum VideoContentVariant {
  /// The full video content.
  video._('video'),

  /// A thumbnail image.
  thumbnail._('thumbnail'),

  /// A sprite sheet preview.
  spritesheet._('spritesheet');

  const VideoContentVariant._(this._value);

  /// Creates from JSON string.
  factory VideoContentVariant.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () =>
          throw FormatException('Unknown video content variant: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
