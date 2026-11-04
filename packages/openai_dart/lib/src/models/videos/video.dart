import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import '../responses/misalignment_details.dart';
import '../responses/websocket/websocket_json_helpers.dart';

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

/// Error information for a failed video generation (OpenAPI Error-2).
///
/// Errors with details snapshot finite metadata and headers. Legacy optional
/// scalar message/code construction remains available as a const constructor.
@immutable
class VideoError {
  /// Creates a legacy scalar error, preserving existing const calls.
  const VideoError({
    this.message,
    this.type,
    this.code,
    this.param,
    bool? hasType,
    bool? hasParam,
  }) : hasType = hasType ?? type != null,
       hasParam = hasParam ?? param != null,
       headers = null,
       misalignment = null,
       rawJson = const {};

  /// Creates an error with deeply owned metadata and immutable retry headers.
  factory VideoError.withDetails({
    String? message,
    String? type,
    String? code,
    String? param,
    Map<String, String>? headers,
    ResponsesMisalignmentDetails? misalignment,
    bool? hasType,
    bool? hasParam,
    Map<String, dynamic> rawJson = const {},
  }) => VideoError._(
    message: message,
    type: type,
    code: code,
    param: param,
    headers: headers == null ? null : Map<String, String>.unmodifiable(headers),
    misalignment: misalignment == null
        ? null
        : ResponsesMisalignmentDetails.fromJson(misalignment.toJson()),
    hasType: hasType ?? type != null,
    hasParam: hasParam ?? param != null,
    rawJson: snapshotResponsesJson(rawJson, 'VideoError.rawJson'),
  );

  const VideoError._({
    required this.message,
    required this.type,
    required this.code,
    required this.param,
    required this.headers,
    required this.misalignment,
    required this.hasType,
    required this.hasParam,
    required this.rawJson,
  });

  /// The error message, absent on legacy incomplete objects.
  final String? message;

  /// The original error type, or null when unavailable.
  final String? type;

  /// The error code.
  final String? code;

  /// The associated parameter, or null when unavailable.
  final String? param;

  /// Retry headers recorded with the original error.
  final Map<String, String>? headers;

  /// Passive review details, when supplied.
  final ResponsesMisalignmentDetails? misalignment;

  /// Whether the nullable type field was supplied.
  final bool hasType;

  /// Whether the nullable param field was supplied.
  final bool hasParam;

  /// Original finite immutable metadata after parsing.
  final Map<String, dynamic> rawJson;

  /// Parses diagnostics while preserving explicit null type/param and metadata.
  factory VideoError.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'VideoError');
    Map<String, String>? headers;
    if (snapshot.containsKey('headers')) {
      final object = requireJsonObject(
        snapshot['headers'],
        'VideoError.headers',
      );
      headers = Map<String, String>.unmodifiable({
        for (final e in object.entries)
          e.key: requireJsonString(e.value, 'VideoError.headers value'),
      });
    }
    return VideoError.withDetails(
      message: optionalJsonString(
        snapshot,
        'message',
        'VideoError',
        nullable: true,
      ),
      type: optionalJsonString(snapshot, 'type', 'VideoError', nullable: true),
      code: optionalJsonString(snapshot, 'code', 'VideoError', nullable: true),
      param: optionalJsonString(
        snapshot,
        'param',
        'VideoError',
        nullable: true,
      ),
      hasType: snapshot.containsKey('type'),
      hasParam: snapshot.containsKey('param'),
      headers: headers,
      misalignment: snapshot.containsKey('misalignment')
          ? ResponsesMisalignmentDetails.fromJson(
              requireJsonObject(
                snapshot['misalignment'],
                'VideoError.misalignment',
              ),
            )
          : null,
      rawJson: snapshot,
    );
  }

  /// Converts effective fields to JSON, retaining future metadata.
  Map<String, dynamic> toJson() {
    snapshotResponsesJson(rawJson, 'VideoError.rawJson');
    return mergeResponsesJson(
      rawJson,
      const {'message', 'code', 'type', 'param', 'headers', 'misalignment'},
      {
        if (message != null) 'message': message,
        if (code != null) 'code': code,
        if (hasType) 'type': type,
        if (hasParam) 'param': param,
        if (headers != null) 'headers': Map<String, String>.from(headers!),
        if (misalignment != null)
          'misalignment': mergeResponsesModelJson(
            rawJson['misalignment'],
            misalignment!.toJson(),
            const {
              'detailed_explanation',
              'error_type',
              'review_target',
              'steer',
            },
            childKeys: const {
              'steer': {'message'},
            },
          ),
      },
    );
  }

  /// Copies fields; explicit null preserves nullable type/param. Clear their
  /// presence flags as well to omit them. Fresh children replace old metadata.
  VideoError copyWith({
    Object? message = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
    Object? code = unsetCopyWithValue,
    Object? param = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    Object? misalignment = unsetCopyWithValue,
    bool? hasType,
    bool? hasParam,
    Map<String, dynamic>? rawJson,
  }) {
    final newHeaders = identical(headers, unsetCopyWithValue)
        ? this.headers
        : headers as Map<String, String>?;
    final details = identical(misalignment, unsetCopyWithValue)
        ? this.misalignment
        : misalignment as ResponsesMisalignmentDetails?;
    final retained = rawJson ?? this.rawJson;
    final replaced =
        identical(misalignment, unsetCopyWithValue) || rawJson != null
        ? retained
        : replaceResponsesTypedJson(
            retained,
            {
              if (this.misalignment != null)
                'misalignment': toJson()['misalignment'],
            },
            {if (details != null) 'misalignment': details.toJson()},
          );
    return VideoError.withDetails(
      message: identical(message, unsetCopyWithValue)
          ? this.message
          : message as String?,
      type: identical(type, unsetCopyWithValue) ? this.type : type as String?,
      code: identical(code, unsetCopyWithValue) ? this.code : code as String?,
      param: identical(param, unsetCopyWithValue)
          ? this.param
          : param as String?,
      headers: newHeaders == null
          ? null
          : Map<String, String>.unmodifiable(newHeaders),
      misalignment: details,
      hasType:
          hasType ?? (!identical(type, unsetCopyWithValue) || this.hasType),
      hasParam:
          hasParam ?? (!identical(param, unsetCopyWithValue) || this.hasParam),
      rawJson: snapshotResponsesJson(replaced, 'VideoError.rawJson'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VideoError &&
      runtimeType == other.runtimeType &&
      mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));
  @override
  String toString() =>
      'VideoError(message: [REDACTED], type: [REDACTED], code: [REDACTED], param: [REDACTED], headers: ${headers == null ? null : "${headers!.length} entries"}, misalignment: ${responsesPresence(misalignment)}, hasType: $hasType, hasParam: $hasParam, rawJson: ${rawJson.length} entries)';
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
