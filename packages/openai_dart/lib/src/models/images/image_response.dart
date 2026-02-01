import 'package:meta/meta.dart';

/// A response from the images API.
///
/// Contains the generated image(s) as URLs or base64-encoded data.
///
/// ## Example
///
/// ```dart
/// final response = await client.images.generate(request);
///
/// for (final image in response.data) {
///   if (image.url != null) {
///     print('Image URL: ${image.url}');
///   }
/// }
/// ```
@immutable
class ImageResponse {
  /// Creates an [ImageResponse].
  const ImageResponse({required this.created, required this.data});

  /// Creates an [ImageResponse] from JSON.
  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    return ImageResponse(
      created: json['created'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => GeneratedImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The Unix timestamp when the images were created.
  final int created;

  /// The list of generated images.
  final List<GeneratedImage> data;

  /// Gets the first generated image.
  GeneratedImage get first => data.first;

  /// Gets the URL of the first image.
  ///
  /// Returns null if the response format was base64.
  String? get firstUrl => data.first.url;

  /// Gets the base64 data of the first image.
  ///
  /// Returns null if the response format was URL.
  String? get firstBase64 => data.first.b64Json;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'created': created,
    'data': data.map((i) => i.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageResponse &&
          runtimeType == other.runtimeType &&
          created == other.created &&
          data.length == other.data.length;

  @override
  int get hashCode => Object.hash(created, data.length);

  @override
  String toString() =>
      'ImageResponse(created: $created, images: ${data.length})';
}

/// A generated image.
///
/// Contains either a URL or base64-encoded data depending on the
/// requested response format.
@immutable
class GeneratedImage {
  /// Creates a [GeneratedImage].
  const GeneratedImage({this.url, this.b64Json, this.revisedPrompt});

  /// Creates a [GeneratedImage] from JSON.
  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      url: json['url'] as String?,
      b64Json: json['b64_json'] as String?,
      revisedPrompt: json['revised_prompt'] as String?,
    );
  }

  /// The URL of the generated image.
  ///
  /// The URL expires after 1 hour. Download the image if you need
  /// to persist it.
  final String? url;

  /// The base64-encoded image data.
  ///
  /// Present when `response_format` is set to `b64_json`.
  final String? b64Json;

  /// The prompt that was used to generate the image.
  ///
  /// For DALL-E 3, the model may revise the prompt for safety or quality.
  final String? revisedPrompt;

  /// Whether this image has a URL.
  bool get hasUrl => url != null;

  /// Whether this image has base64 data.
  bool get hasBase64 => b64Json != null;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (url != null) 'url': url,
    if (b64Json != null) 'b64_json': b64Json,
    if (revisedPrompt != null) 'revised_prompt': revisedPrompt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratedImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          b64Json == other.b64Json;

  @override
  int get hashCode => Object.hash(url, b64Json);

  @override
  String toString() {
    if (hasUrl) return 'GeneratedImage(url: ${url!.substring(0, 50)}...)';
    if (hasBase64) return 'GeneratedImage(b64_json: ${b64Json!.length} chars)';
    return 'GeneratedImage()';
  }
}
