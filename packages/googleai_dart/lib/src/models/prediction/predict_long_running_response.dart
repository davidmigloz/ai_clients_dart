import '../copy_with_sentinel.dart';
import 'media.dart';
import 'predict_long_running_generated_video_response.dart';

/// Response message for PredictLongRunning operation.
class PredictLongRunningResponse {
  /// The nested video generation response returned by the Gemini Developer API.
  final PredictLongRunningGeneratedVideoResponse? generateVideoResponse;

  /// Videos returned directly in the Vertex AI prediction response.
  final List<Video>? videos;

  /// Number of videos filtered by responsible AI policies on Vertex AI.
  final int? raiMediaFilteredCount;

  /// Reasons that outputs were filtered on Vertex AI.
  final List<String>? raiMediaFilteredReasons;

  /// Protobuf type URL returned by Vertex AI in the `@type` field.
  final String? responseType;

  /// Creates a [PredictLongRunningResponse].
  const PredictLongRunningResponse({
    this.generateVideoResponse,
    this.videos,
    this.raiMediaFilteredCount,
    this.raiMediaFilteredReasons,
    this.responseType,
  });

  /// Creates a [PredictLongRunningResponse] from JSON.
  factory PredictLongRunningResponse.fromJson(Map<String, dynamic> json) =>
      PredictLongRunningResponse(
        generateVideoResponse: json['generateVideoResponse'] != null
            ? PredictLongRunningGeneratedVideoResponse.fromJson(
                json['generateVideoResponse'] as Map<String, dynamic>,
              )
            : null,
        videos: (json['videos'] as List<dynamic>?)
            ?.map(
              (video) => Video.fromVertexJson(video as Map<String, dynamic>),
            )
            .toList(),
        raiMediaFilteredCount: json['raiMediaFilteredCount'] as int?,
        raiMediaFilteredReasons: (json['raiMediaFilteredReasons'] as List?)
            ?.cast<String>(),
        responseType: json['@type'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (generateVideoResponse != null)
      'generateVideoResponse': generateVideoResponse!.toJson(),
    if (videos != null)
      'videos': [for (final video in videos!) video.toVertexJson()],
    'raiMediaFilteredCount': ?raiMediaFilteredCount,
    'raiMediaFilteredReasons': ?raiMediaFilteredReasons,
    '@type': ?responseType,
  };

  /// Creates a copy with replaced values.
  PredictLongRunningResponse copyWith({
    Object? generateVideoResponse = unsetCopyWithValue,
    Object? videos = unsetCopyWithValue,
    Object? raiMediaFilteredCount = unsetCopyWithValue,
    Object? raiMediaFilteredReasons = unsetCopyWithValue,
    Object? responseType = unsetCopyWithValue,
  }) {
    return PredictLongRunningResponse(
      generateVideoResponse: generateVideoResponse == unsetCopyWithValue
          ? this.generateVideoResponse
          : generateVideoResponse as PredictLongRunningGeneratedVideoResponse?,
      videos: videos == unsetCopyWithValue
          ? this.videos
          : videos as List<Video>?,
      raiMediaFilteredCount: raiMediaFilteredCount == unsetCopyWithValue
          ? this.raiMediaFilteredCount
          : raiMediaFilteredCount as int?,
      raiMediaFilteredReasons: raiMediaFilteredReasons == unsetCopyWithValue
          ? this.raiMediaFilteredReasons
          : raiMediaFilteredReasons as List<String>?,
      responseType: responseType == unsetCopyWithValue
          ? this.responseType
          : responseType as String?,
    );
  }
}
