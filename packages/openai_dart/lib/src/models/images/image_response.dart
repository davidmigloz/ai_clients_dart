import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'image_common.dart';

/// A response from the images API.
///
/// Contains the generated image(s) as URLs or base64-encoded data. For GPT
/// image models (e.g. `gpt-image-2`), also includes token-based pricing info
/// in [usage] and request-echo metadata ([background], [outputFormat],
/// [quality], [size]). These extra fields are `null` for DALL-E responses.
///
/// ## Example
///
/// ```dart
/// final response = await client.images.generate(request);
///
/// for (final image in response.data) {
///   if (image.b64Json case final b64?) {
///     final bytes = base64Decode(b64);
///     // …save bytes to disk
///   }
/// }
/// print('Total tokens: ${response.usage?.totalTokens}');
/// ```
@immutable
class ImageResponse {
  /// Creates an [ImageResponse].
  const ImageResponse({
    required this.created,
    required this.data,
    this.background,
    this.outputFormat,
    this.quality,
    this.size,
    this.usage,
  });

  /// Creates an [ImageResponse] from JSON.
  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    if (dataJson is! List) {
      throw FormatException(
        'ImageResponse.data is required — expected a List, '
        'got ${dataJson.runtimeType}',
      );
    }
    return ImageResponse(
      created: json['created'] as int,
      data: dataJson
          .map((e) => GeneratedImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      background: json['background'] != null
          ? ImageBackground.fromJson(json['background'] as String)
          : null,
      outputFormat: json['output_format'] != null
          ? ImageOutputFormat.fromJson(json['output_format'] as String)
          : null,
      quality: json['quality'] != null
          ? ImageQuality.fromJson(json['quality'] as String)
          : null,
      size: json['size'] != null
          ? ImageSize.fromJson(json['size'] as String)
          : null,
      usage: json['usage'] != null
          ? ImagesUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The Unix timestamp when the images were created.
  final int created;

  /// The list of generated images.
  final List<GeneratedImage> data;

  /// Background used (GPT image models only).
  final ImageBackground? background;

  /// Output format used (GPT image models only).
  final ImageOutputFormat? outputFormat;

  /// Quality used (GPT image models only).
  final ImageQuality? quality;

  /// Size used (GPT image models only).
  final ImageSize? size;

  /// Token usage (GPT image models only).
  final ImagesUsage? usage;

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
    if (background != null) 'background': background!.toJson(),
    if (outputFormat != null) 'output_format': outputFormat!.toJson(),
    if (quality != null) 'quality': quality!.toJson(),
    if (size != null) 'size': size!.toJson(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageResponse &&
          runtimeType == other.runtimeType &&
          created == other.created &&
          listsEqual(data, other.data) &&
          background == other.background &&
          outputFormat == other.outputFormat &&
          quality == other.quality &&
          size == other.size &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(
    created,
    listHash(data),
    background,
    outputFormat,
    quality,
    size,
    usage,
  );

  @override
  String toString() =>
      'ImageResponse(created: $created, images: ${data.length}, '
      'size: $size, usage: $usage)';
}

/// A generated image.
///
/// Contains either a URL or base64-encoded data depending on the
/// requested response format. GPT image models always return `b64Json`.
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

  /// The URL of the generated image (DALL-E only).
  ///
  /// The URL expires after 60 minutes — download the image to persist it.
  final String? url;

  /// The base64-encoded image data (GPT image models always use this).
  ///
  /// Present when `response_format` is `b64_json` or when the model is a
  /// GPT image model.
  final String? b64Json;

  /// The prompt used after server-side revision (DALL-E 3 only).
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
          b64Json == other.b64Json &&
          revisedPrompt == other.revisedPrompt;

  @override
  int get hashCode => Object.hash(url, b64Json, revisedPrompt);

  @override
  String toString() {
    if (hasUrl) {
      final preview = url!.length > 50 ? '${url!.substring(0, 50)}...' : url!;
      return 'GeneratedImage(url: $preview)';
    }
    if (hasBase64) return 'GeneratedImage(b64_json: ${b64Json!.length} chars)';
    return 'GeneratedImage()';
  }
}

/// Token usage for a GPT image generation or edit request.
///
/// Only emitted for GPT image models (e.g. `gpt-image-2`). DALL-E responses
/// have `null` usage.
@immutable
class ImagesUsage {
  /// Creates an [ImagesUsage].
  const ImagesUsage({
    required this.totalTokens,
    required this.inputTokens,
    required this.outputTokens,
    required this.inputTokensDetails,
    this.outputTokensDetails,
  });

  /// Creates an [ImagesUsage] from JSON.
  factory ImagesUsage.fromJson(Map<String, dynamic> json) {
    return ImagesUsage(
      totalTokens: json['total_tokens'] as int,
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      inputTokensDetails: ImagesUsageInputTokensDetails.fromJson(
        json['input_tokens_details'] as Map<String, dynamic>,
      ),
      outputTokensDetails: json['output_tokens_details'] != null
          ? ImagesUsageOutputTokensDetails.fromJson(
              json['output_tokens_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Total tokens (images + text) used for the request.
  final int totalTokens;

  /// Input tokens (images + text).
  final int inputTokens;

  /// Output image tokens generated.
  final int outputTokens;

  /// Breakdown of input tokens.
  final ImagesUsageInputTokensDetails inputTokensDetails;

  /// Breakdown of output tokens (not always emitted).
  final ImagesUsageOutputTokensDetails? outputTokensDetails;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'total_tokens': totalTokens,
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    'input_tokens_details': inputTokensDetails.toJson(),
    if (outputTokensDetails != null)
      'output_tokens_details': outputTokensDetails!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImagesUsage &&
          runtimeType == other.runtimeType &&
          totalTokens == other.totalTokens &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          inputTokensDetails == other.inputTokensDetails &&
          outputTokensDetails == other.outputTokensDetails;

  @override
  int get hashCode => Object.hash(
    totalTokens,
    inputTokens,
    outputTokens,
    inputTokensDetails,
    outputTokensDetails,
  );

  @override
  String toString() =>
      'ImagesUsage(total: $totalTokens, in: $inputTokens, out: $outputTokens)';
}

/// Breakdown of input tokens for an image request.
@immutable
class ImagesUsageInputTokensDetails {
  /// Creates an [ImagesUsageInputTokensDetails].
  const ImagesUsageInputTokensDetails({
    required this.textTokens,
    required this.imageTokens,
  });

  /// Creates from JSON.
  factory ImagesUsageInputTokensDetails.fromJson(Map<String, dynamic> json) {
    return ImagesUsageInputTokensDetails(
      textTokens: json['text_tokens'] as int,
      imageTokens: json['image_tokens'] as int,
    );
  }

  /// Text tokens in the input prompt.
  final int textTokens;

  /// Image tokens in the input prompt.
  final int imageTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'text_tokens': textTokens,
    'image_tokens': imageTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImagesUsageInputTokensDetails &&
          runtimeType == other.runtimeType &&
          textTokens == other.textTokens &&
          imageTokens == other.imageTokens;

  @override
  int get hashCode => Object.hash(textTokens, imageTokens);

  @override
  String toString() =>
      'ImagesUsageInputTokensDetails(text: $textTokens, image: $imageTokens)';
}

/// Breakdown of output tokens for an image request.
@immutable
class ImagesUsageOutputTokensDetails {
  /// Creates an [ImagesUsageOutputTokensDetails].
  const ImagesUsageOutputTokensDetails({
    required this.textTokens,
    required this.imageTokens,
  });

  /// Creates from JSON.
  factory ImagesUsageOutputTokensDetails.fromJson(Map<String, dynamic> json) {
    return ImagesUsageOutputTokensDetails(
      textTokens: json['text_tokens'] as int,
      imageTokens: json['image_tokens'] as int,
    );
  }

  /// Text tokens in the output.
  final int textTokens;

  /// Image tokens in the output.
  final int imageTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'text_tokens': textTokens,
    'image_tokens': imageTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImagesUsageOutputTokensDetails &&
          runtimeType == other.runtimeType &&
          textTokens == other.textTokens &&
          imageTokens == other.imageTokens;

  @override
  int get hashCode => Object.hash(textTokens, imageTokens);

  @override
  String toString() =>
      'ImagesUsageOutputTokensDetails(text: $textTokens, image: $imageTokens)';
}

/// Well-known OpenAI image model IDs.
///
/// Mirrors the `ImageModel` literal in the official Python SDK, extended
/// with `gpt-image-2`. The request `model` field is a free-form `String`;
/// use these constants or pass any custom model id directly.
abstract final class ImageModels {
  /// GPT Image 2 — flagship image model with token-based pricing,
  /// flexible sizes, high-fidelity inputs, and Batch API support.
  static const String gptImage2 = 'gpt-image-2';

  /// GPT Image 1.5.
  static const String gptImage15 = 'gpt-image-1.5';

  /// GPT Image 1.
  static const String gptImage1 = 'gpt-image-1';

  /// GPT Image 1 mini.
  static const String gptImage1Mini = 'gpt-image-1-mini';

  /// ChatGPT image latest (snapshot routed to the current ChatGPT image model).
  static const String chatgptImageLatest = 'chatgpt-image-latest';

  /// DALL-E 3.
  static const String dallE3 = 'dall-e-3';

  /// DALL-E 2.
  static const String dallE2 = 'dall-e-2';
}
