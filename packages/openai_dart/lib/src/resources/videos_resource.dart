import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

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
class VideosResource extends ResourceBase {
  /// Creates a [VideosResource].
  VideosResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/videos';

  /// Lists all video generation jobs.
  Future<VideoList> list({
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return VideoList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a new video generation job.
  Future<Video> create(CreateVideoRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Video.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Retrieves a video generation job.
  Future<Video> retrieve(String videoId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$videoId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return Video.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a video.
  Future<DeleteVideoResponse> delete(String videoId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$videoId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteVideoResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves the content of a completed video.
  Future<Uint8List> retrieveContent(
    String videoId, {
    VideoContentVariant? variant,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (variant != null) queryParams['variant'] = variant.toJson();

    final url = requestBuilder.buildUrl(
      '$_endpoint/$videoId/content',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);

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
  Future<Video> remix(String videoId, CreateVideoRemixRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$videoId/remix');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Video.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Creates a new video edit from an existing video.
  ///
  /// References an existing video by ID. Direct video file uploads via
  /// multipart are not yet supported.
  Future<Video> createEdit(CreateVideoEditRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/edits');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Video.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Creates an extension of a completed video.
  ///
  /// References an existing video by ID. Direct video file uploads via
  /// multipart are not yet supported.
  Future<Video> createExtension(CreateVideoExtendRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/extensions');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Video.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Retrieves a video character.
  Future<VideoCharacter> retrieveCharacter(String characterId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/characters/$characterId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return VideoCharacter.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
