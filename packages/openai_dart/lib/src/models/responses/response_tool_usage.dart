import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/json_helpers.dart';

/// Hosted-tool usage, separate from base-model ResponseUsage.
///
/// Missing tool_usage means unavailable. Tool families with no recorded usage
/// report zero counts when the object is present. Optional cache counts remain
/// unknown when absent; incomplete image call records can be skipped upstream.
/// Use billing records to reconcile final charges.
@immutable
class ResponseToolUsage {
  /// Aggregated image generation token counts.
  final ImageGenToolUsage imageGen;

  /// Billable web search requests, excluding open-page actions and discounted searches.
  final WebSearchUsage webSearch;

  /// Creates a [ResponseToolUsage].
  const ResponseToolUsage({required this.imageGen, required this.webSearch});

  /// Reads reported counts without inventing unavailable values.
  factory ResponseToolUsage.fromJson(Map<String, dynamic> json) =>
      ResponseToolUsage(
        imageGen: ImageGenToolUsage.fromJson(
          requireJsonObject(json['image_gen'], 'ResponseToolUsage.image_gen'),
        ),
        webSearch: WebSearchUsage.fromJson(
          requireJsonObject(json['web_search'], 'ResponseToolUsage.web_search'),
        ),
      );

  /// Converts to JSON, omitting unavailable optional counts.
  Map<String, dynamic> toJson() => {
    'image_gen': imageGen.toJson(),
    'web_search': webSearch.toJson(),
  };

  /// Copies reported values; explicit null clears optional fields, if any.
  ResponseToolUsage copyWith({
    ImageGenToolUsage? imageGen,
    WebSearchUsage? webSearch,
  }) => ResponseToolUsage(
    imageGen: imageGen ?? this.imageGen,
    webSearch: webSearch ?? this.webSearch,
  );

  @override
  bool operator ==(Object other) =>
      other is ResponseToolUsage &&
      runtimeType == other.runtimeType &&
      imageGen == other.imageGen &&
      webSearch == other.webSearch;

  @override
  int get hashCode => Object.hashAll([runtimeType, imageGen, webSearch]);

  @override
  String toString() =>
      'ResponseToolUsage(imageGen: $imageGen, webSearch: $webSearch)';
}

/// Billable web search request usage.
@immutable
class WebSearchUsage {
  /// Number of billable requests; use billing records to reconcile final charges.
  final int numRequests;

  /// Creates a [WebSearchUsage].
  const WebSearchUsage({required this.numRequests});

  /// Reads reported counts without inventing unavailable values.
  factory WebSearchUsage.fromJson(Map<String, dynamic> json) => WebSearchUsage(
    numRequests: requireJsonInt(
      json['num_requests'],
      'WebSearchUsage.num_requests',
    ),
  );

  /// Converts to JSON, omitting unavailable optional counts.
  Map<String, dynamic> toJson() => {'num_requests': numRequests};

  /// Copies reported values; explicit null clears optional fields, if any.
  WebSearchUsage copyWith({int? numRequests}) =>
      WebSearchUsage(numRequests: numRequests ?? this.numRequests);

  @override
  bool operator ==(Object other) =>
      other is WebSearchUsage &&
      runtimeType == other.runtimeType &&
      numRequests == other.numRequests;

  @override
  int get hashCode => Object.hashAll([runtimeType, numRequests]);

  @override
  String toString() => 'WebSearchUsage(numRequests: $numRequests)';
}

/// Aggregated image generation tool usage, separate from base-model usage.
///
/// Incomplete call records may be skipped by the server. Optional output details
/// and cached input counts remain unknown when absent.
@immutable
class ImageGenToolUsage {
  /// Image and text input tokens.
  final int inputTokens;

  /// Generated output tokens.
  final int outputTokens;

  /// Total input and output tokens.
  final int totalTokens;

  /// Input image/text token breakdown.
  final ImageGenInputUsageDetails inputTokensDetails;

  /// Output breakdown, when reported.
  final ImageGenOutputTokensDetails? outputTokensDetails;

  /// Cached input count, or null when unknown (not zero).
  final int? cachedTokens;

  /// Cached input breakdown, when reported.
  final CachedUsageDetails? cachedTokensDetails;

  /// Creates a [ImageGenToolUsage].
  const ImageGenToolUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.inputTokensDetails,
    this.outputTokensDetails,
    this.cachedTokens,
    this.cachedTokensDetails,
  });

  /// Reads reported counts without inventing unavailable values.
  factory ImageGenToolUsage.fromJson(Map<String, dynamic> json) =>
      ImageGenToolUsage(
        inputTokens: requireJsonInt(
          json['input_tokens'],
          'ImageGenToolUsage.input_tokens',
        ),
        outputTokens: requireJsonInt(
          json['output_tokens'],
          'ImageGenToolUsage.output_tokens',
        ),
        totalTokens: requireJsonInt(
          json['total_tokens'],
          'ImageGenToolUsage.total_tokens',
        ),
        inputTokensDetails: ImageGenInputUsageDetails.fromJson(
          requireJsonObject(
            json['input_tokens_details'],
            'ImageGenToolUsage.input_tokens_details',
          ),
        ),
        outputTokensDetails: json.containsKey('output_tokens_details')
            ? ImageGenOutputTokensDetails.fromJson(
                requireJsonObject(
                  json['output_tokens_details'],
                  'ImageGenToolUsage.output_tokens_details',
                ),
              )
            : null,
        cachedTokens: optionalJsonInt(
          json,
          'cached_tokens',
          'ImageGenToolUsage',
        ),
        cachedTokensDetails: json.containsKey('cached_tokens_details')
            ? CachedUsageDetails.fromJson(
                requireJsonObject(
                  json['cached_tokens_details'],
                  'ImageGenToolUsage.cached_tokens_details',
                ),
              )
            : null,
      );

  /// Converts to JSON, omitting unavailable optional counts.
  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    'total_tokens': totalTokens,
    'input_tokens_details': inputTokensDetails.toJson(),
    if (outputTokensDetails != null)
      'output_tokens_details': outputTokensDetails!.toJson(),
    if (cachedTokens != null) 'cached_tokens': cachedTokens,
    if (cachedTokensDetails != null)
      'cached_tokens_details': cachedTokensDetails!.toJson(),
  };

  /// Copies reported values; explicit null clears optional fields, if any.
  ImageGenToolUsage copyWith({
    int? inputTokens,
    int? outputTokens,
    int? totalTokens,
    ImageGenInputUsageDetails? inputTokensDetails,
    Object? outputTokensDetails = unsetCopyWithValue,
    Object? cachedTokens = unsetCopyWithValue,
    Object? cachedTokensDetails = unsetCopyWithValue,
  }) => ImageGenToolUsage(
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
    totalTokens: totalTokens ?? this.totalTokens,
    inputTokensDetails: inputTokensDetails ?? this.inputTokensDetails,
    outputTokensDetails: identical(outputTokensDetails, unsetCopyWithValue)
        ? this.outputTokensDetails
        : outputTokensDetails as ImageGenOutputTokensDetails?,
    cachedTokens: identical(cachedTokens, unsetCopyWithValue)
        ? this.cachedTokens
        : cachedTokens as int?,
    cachedTokensDetails: identical(cachedTokensDetails, unsetCopyWithValue)
        ? this.cachedTokensDetails
        : cachedTokensDetails as CachedUsageDetails?,
  );

  @override
  bool operator ==(Object other) =>
      other is ImageGenToolUsage &&
      runtimeType == other.runtimeType &&
      inputTokens == other.inputTokens &&
      outputTokens == other.outputTokens &&
      totalTokens == other.totalTokens &&
      inputTokensDetails == other.inputTokensDetails &&
      outputTokensDetails == other.outputTokensDetails &&
      cachedTokens == other.cachedTokens &&
      cachedTokensDetails == other.cachedTokensDetails;

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    inputTokens,
    outputTokens,
    totalTokens,
    inputTokensDetails,
    outputTokensDetails,
    cachedTokens,
    cachedTokensDetails,
  ]);

  @override
  String toString() =>
      'ImageGenToolUsage(inputTokens: $inputTokens, outputTokens: $outputTokens, totalTokens: $totalTokens, inputTokensDetails: $inputTokensDetails, outputTokensDetails: $outputTokensDetails, cachedTokens: $cachedTokens, cachedTokensDetails: $cachedTokensDetails)';
}

/// Input token breakdown for the image generation tool.
@immutable
class ImageGenInputUsageDetails {
  /// Text input tokens.
  final int textTokens;

  /// Image input tokens.
  final int imageTokens;

  /// Creates a [ImageGenInputUsageDetails].
  const ImageGenInputUsageDetails({
    required this.textTokens,
    required this.imageTokens,
  });

  /// Reads reported counts without inventing unavailable values.
  factory ImageGenInputUsageDetails.fromJson(Map<String, dynamic> json) =>
      ImageGenInputUsageDetails(
        textTokens: requireJsonInt(
          json['text_tokens'],
          'ImageGenInputUsageDetails.text_tokens',
        ),
        imageTokens: requireJsonInt(
          json['image_tokens'],
          'ImageGenInputUsageDetails.image_tokens',
        ),
      );

  /// Converts to JSON, omitting unavailable optional counts.
  Map<String, dynamic> toJson() => {
    'text_tokens': textTokens,
    'image_tokens': imageTokens,
  };

  /// Copies reported values; explicit null clears optional fields, if any.
  ImageGenInputUsageDetails copyWith({int? textTokens, int? imageTokens}) =>
      ImageGenInputUsageDetails(
        textTokens: textTokens ?? this.textTokens,
        imageTokens: imageTokens ?? this.imageTokens,
      );

  @override
  bool operator ==(Object other) =>
      other is ImageGenInputUsageDetails &&
      runtimeType == other.runtimeType &&
      textTokens == other.textTokens &&
      imageTokens == other.imageTokens;

  @override
  int get hashCode => Object.hashAll([runtimeType, textTokens, imageTokens]);

  @override
  String toString() =>
      'ImageGenInputUsageDetails(textTokens: $textTokens, imageTokens: $imageTokens)';
}

/// Output token breakdown for the image generation tool.
@immutable
class ImageGenOutputTokensDetails {
  /// Generated text tokens.
  final int textTokens;

  /// Generated image tokens.
  final int imageTokens;

  /// Creates a [ImageGenOutputTokensDetails].
  const ImageGenOutputTokensDetails({
    required this.textTokens,
    required this.imageTokens,
  });

  /// Reads reported counts without inventing unavailable values.
  factory ImageGenOutputTokensDetails.fromJson(Map<String, dynamic> json) =>
      ImageGenOutputTokensDetails(
        textTokens: requireJsonInt(
          json['text_tokens'],
          'ImageGenOutputTokensDetails.text_tokens',
        ),
        imageTokens: requireJsonInt(
          json['image_tokens'],
          'ImageGenOutputTokensDetails.image_tokens',
        ),
      );

  /// Converts to JSON, omitting unavailable optional counts.
  Map<String, dynamic> toJson() => {
    'text_tokens': textTokens,
    'image_tokens': imageTokens,
  };

  /// Copies reported values; explicit null clears optional fields, if any.
  ImageGenOutputTokensDetails copyWith({int? textTokens, int? imageTokens}) =>
      ImageGenOutputTokensDetails(
        textTokens: textTokens ?? this.textTokens,
        imageTokens: imageTokens ?? this.imageTokens,
      );

  @override
  bool operator ==(Object other) =>
      other is ImageGenOutputTokensDetails &&
      runtimeType == other.runtimeType &&
      textTokens == other.textTokens &&
      imageTokens == other.imageTokens;

  @override
  int get hashCode => Object.hashAll([runtimeType, textTokens, imageTokens]);

  @override
  String toString() =>
      'ImageGenOutputTokensDetails(textTokens: $textTokens, imageTokens: $imageTokens)';
}

/// Cached input breakdown for the image generation tool.
@immutable
class CachedUsageDetails {
  /// Cached text input tokens.
  final int cachedTextTokens;

  /// Cached image input tokens.
  final int cachedImageTokens;

  /// Creates a [CachedUsageDetails].
  const CachedUsageDetails({
    required this.cachedTextTokens,
    required this.cachedImageTokens,
  });

  /// Reads reported counts without inventing unavailable values.
  factory CachedUsageDetails.fromJson(Map<String, dynamic> json) =>
      CachedUsageDetails(
        cachedTextTokens: requireJsonInt(
          json['cached_text_tokens'],
          'CachedUsageDetails.cached_text_tokens',
        ),
        cachedImageTokens: requireJsonInt(
          json['cached_image_tokens'],
          'CachedUsageDetails.cached_image_tokens',
        ),
      );

  /// Converts to JSON, omitting unavailable optional counts.
  Map<String, dynamic> toJson() => {
    'cached_text_tokens': cachedTextTokens,
    'cached_image_tokens': cachedImageTokens,
  };

  /// Copies reported values; explicit null clears optional fields, if any.
  CachedUsageDetails copyWith({
    int? cachedTextTokens,
    int? cachedImageTokens,
  }) => CachedUsageDetails(
    cachedTextTokens: cachedTextTokens ?? this.cachedTextTokens,
    cachedImageTokens: cachedImageTokens ?? this.cachedImageTokens,
  );

  @override
  bool operator ==(Object other) =>
      other is CachedUsageDetails &&
      runtimeType == other.runtimeType &&
      cachedTextTokens == other.cachedTextTokens &&
      cachedImageTokens == other.cachedImageTokens;

  @override
  int get hashCode =>
      Object.hashAll([runtimeType, cachedTextTokens, cachedImageTokens]);

  @override
  String toString() =>
      'CachedUsageDetails(cachedTextTokens: $cachedTextTokens, cachedImageTokens: $cachedImageTokens)';
}
