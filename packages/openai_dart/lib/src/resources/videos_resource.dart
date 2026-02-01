import 'dart:convert';
import 'dart:typed_data';

import '../client/openai_client.dart';
import '../errors/exceptions.dart';
import '../models/videos/videos.dart';
import 'base_resource.dart';

/// Resource for video generation operations (Sora).
///
/// Videos are generated using Sora, OpenAI's video generation model.
///
/// Access this resource through [OpenAIClient.videos].
///
/// ## Example
///
/// ```dart
/// // Create a video
/// final video = await client.videos.create(
///   CreateVideoRequest(
///     prompt: 'A cat playing piano in a jazz club',
///     model: 'sora-2',
///     size: VideoSize.size1280x720,
///     seconds: VideoSeconds.s8,
///   ),
/// );
///
/// // Check status
/// while (!video.isCompleted && !video.isFailed) {
///   await Future.delayed(Duration(seconds: 10));
///   video = await client.videos.retrieve(video.id);
///   print('Progress: ${video.progress}%');
/// }
///
/// // Download content
/// if (video.isCompleted) {
///   final content = await client.videos.retrieveContent(video.id);
///   File('video.mp4').writeAsBytesSync(content);
/// }
/// ```
class VideosResource extends BaseResource {
  /// Creates a [VideosResource] with the given client.
  VideosResource(super.client);

  static const _endpoint = '/videos';

  /// Lists all video generation jobs.
  ///
  /// ## Parameters
  ///
  /// - [limit] - Maximum number of videos to return.
  /// - [order] - Sort order (asc or desc).
  /// - [after] - Cursor for pagination (get videos after this ID).
  /// - [before] - Cursor for pagination (get videos before this ID).
  ///
  /// ## Returns
  ///
  /// A [VideoList] containing the videos.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final videos = await client.videos.list(limit: 10);
  ///
  /// for (final video in videos.data) {
  ///   print('${video.id}: ${video.status}');
  /// }
  /// ```
  Future<VideoList> list({
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return VideoList.fromJson(json);
  }

  /// Creates a new video generation job.
  ///
  /// ## Parameters
  ///
  /// - [request] - The video creation request.
  ///
  /// ## Returns
  ///
  /// A [Video] representing the generation job.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final video = await client.videos.create(
  ///   CreateVideoRequest(
  ///     prompt: 'A serene mountain lake at sunrise',
  ///     model: 'sora-2',
  ///     size: VideoSize.size1280x720,
  ///     seconds: VideoSeconds.s4,
  ///   ),
  /// );
  ///
  /// print('Created video: ${video.id}');
  /// ```
  Future<Video> create(CreateVideoRequest request) async {
    final json = await postJson(_endpoint, body: request.toJson());
    return Video.fromJson(json);
  }

  /// Retrieves a video generation job.
  ///
  /// ## Parameters
  ///
  /// - [videoId] - The ID of the video to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Video] with the current status.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final video = await client.videos.retrieve('video-abc123');
  /// print('Status: ${video.status}, Progress: ${video.progress}%');
  /// ```
  Future<Video> retrieve(String videoId) async {
    final json = await getJson('$_endpoint/$videoId');
    return Video.fromJson(json);
  }

  /// Deletes a video.
  ///
  /// ## Parameters
  ///
  /// - [videoId] - The ID of the video to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteVideoResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.videos.delete('video-abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteVideoResponse> delete(String videoId) async {
    final json = await deleteJson('$_endpoint/$videoId');
    return DeleteVideoResponse.fromJson(json);
  }

  /// Retrieves the content of a completed video.
  ///
  /// ## Parameters
  ///
  /// - [videoId] - The ID of the video.
  /// - [variant] - The content variant to retrieve (video, thumbnail, spritesheet).
  ///
  /// ## Returns
  ///
  /// The video content as bytes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Get the video file
  /// final videoBytes = await client.videos.retrieveContent('video-abc123');
  /// File('output.mp4').writeAsBytesSync(videoBytes);
  ///
  /// // Get thumbnail
  /// final thumbnail = await client.videos.retrieveContent(
  ///   'video-abc123',
  ///   variant: VideoContentVariant.thumbnail,
  /// );
  /// File('thumbnail.jpg').writeAsBytesSync(thumbnail);
  /// ```
  Future<Uint8List> retrieveContent(
    String videoId, {
    VideoContentVariant? variant,
  }) async {
    final queryParams = <String, String>{};
    if (variant != null) queryParams['variant'] = variant.toJson();

    final response = await client.get(
      '$_endpoint/$videoId/content',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode >= 400) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      throw createApiException(
        statusCode: response.statusCode,
        message: error?['message'] as String? ?? 'Unknown error',
        type: error?['type'] as String?,
        code: error?['code'] as String?,
        body: json,
      );
    }

    return response.bodyBytes;
  }

  /// Creates a remix of an existing video.
  ///
  /// A remix takes an existing generated video and creates a new version
  /// with modified characteristics based on the new prompt.
  ///
  /// ## Parameters
  ///
  /// - [videoId] - The ID of the video to remix.
  /// - [request] - The remix request with the new prompt.
  ///
  /// ## Returns
  ///
  /// A [Video] representing the new remix job.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final remix = await client.videos.remix(
  ///   'video-abc123',
  ///   CreateVideoRemixRequest(
  ///     prompt: 'Same scene but at night with northern lights',
  ///   ),
  /// );
  ///
  /// print('Remix created: ${remix.id}');
  /// print('Based on: ${remix.remixedFromVideoId}');
  /// ```
  Future<Video> remix(String videoId, CreateVideoRemixRequest request) async {
    final json = await postJson(
      '$_endpoint/$videoId/remix',
      body: request.toJson(),
    );
    return Video.fromJson(json);
  }
}
