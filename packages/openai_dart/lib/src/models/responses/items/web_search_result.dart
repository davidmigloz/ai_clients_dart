import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';

/// A result returned by the web search tool.
///
/// [WebSearchImageResult] follows the web-search guide. Future result objects are
/// retained as [UnknownWebSearchResult] without inventing a text-result schema.
sealed class WebSearchResult {
  /// Creates a [WebSearchResult].
  const WebSearchResult();

  /// The result discriminator.
  String get type;

  /// Parses known results, preserving future result objects.
  factory WebSearchResult.fromJson(
    Map<String, dynamic> json, {
    String context = 'WebSearchResult',
  }) {
    final type = requireJsonString(json['type'], '$context.type');
    return switch (type) {
      'image_result' => WebSearchImageResult.fromJson(json, context: context),
      _ => UnknownWebSearchResult(type: type, data: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// An image result from the web search tool.
@immutable
class WebSearchImageResult extends WebSearchResult {
  @override
  String get type => 'image_result';

  /// The image URL.
  final String imageUrl;

  /// The website URL that supplied the image.
  final String sourceWebsiteUrl;

  /// The thumbnail URL, when provided.
  final String? thumbnailUrl;

  /// The image caption, when provided.
  final String? caption;

  /// Creates an image result.
  const WebSearchImageResult({
    required this.imageUrl,
    required this.sourceWebsiteUrl,
    this.thumbnailUrl,
    this.caption,
  });

  /// Creates a [WebSearchImageResult] from JSON.
  ///
  /// Absent or null optional image metadata is normalized to absence for client
  /// compatibility; this is not an upstream-schema requiredness claim.
  factory WebSearchImageResult.fromJson(
    Map<String, dynamic> json, {
    String context = 'WebSearchImageResult',
  }) {
    requireJsonType(json, 'image_result', context);
    return WebSearchImageResult(
      imageUrl: requireJsonString(json['image_url'], '$context.image_url'),
      sourceWebsiteUrl: requireJsonString(
        json['source_website_url'],
        '$context.source_website_url',
      ),
      thumbnailUrl: optionalJsonString(
        json,
        'thumbnail_url',
        context,
        nullable: true,
      ),
      caption: optionalJsonString(json, 'caption', context, nullable: true),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': imageUrl,
    'source_website_url': sourceWebsiteUrl,
    if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    if (caption != null) 'caption': caption,
  };

  /// Copies every field; explicit null clears optional image metadata.
  WebSearchImageResult copyWith({
    String? imageUrl,
    String? sourceWebsiteUrl,
    Object? thumbnailUrl = unsetCopyWithValue,
    Object? caption = unsetCopyWithValue,
  }) => WebSearchImageResult(
    imageUrl: imageUrl ?? this.imageUrl,
    sourceWebsiteUrl: sourceWebsiteUrl ?? this.sourceWebsiteUrl,
    thumbnailUrl: thumbnailUrl == unsetCopyWithValue
        ? this.thumbnailUrl
        : thumbnailUrl as String?,
    caption: caption == unsetCopyWithValue ? this.caption : caption as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchImageResult &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          sourceWebsiteUrl == other.sourceWebsiteUrl &&
          thumbnailUrl == other.thumbnailUrl &&
          caption == other.caption;

  @override
  int get hashCode =>
      Object.hash(imageUrl, sourceWebsiteUrl, thumbnailUrl, caption);

  @override
  String toString() =>
      'WebSearchImageResult(type: $type, imageUrl: ${imageUrl.length} chars, sourceWebsiteUrl: ${sourceWebsiteUrl.length} chars, thumbnailUrl: ${thumbnailUrl == null ? 'null' : '${thumbnailUrl!.length} chars'}, caption: ${caption == null ? 'null' : '${caption!.length} chars'})';
}

/// A future result preserved without interpreting its JSON fields.
@immutable
class UnknownWebSearchResult extends WebSearchResult {
  @override
  final String type;

  /// A recursively immutable snapshot of the original result JSON.
  final Map<String, dynamic> data;

  /// Creates an unknown result, taking a recursively immutable snapshot.
  UnknownWebSearchResult({
    required this.type,
    required Map<String, dynamic> data,
  }) : data = freezeJsonObject({...data, 'type': type});

  @override
  Map<String, dynamic> toJson() => {...data, 'type': type};

  /// Copies every field, taking a fresh immutable snapshot of [data].
  UnknownWebSearchResult copyWith({String? type, Map<String, dynamic>? data}) =>
      UnknownWebSearchResult(type: type ?? this.type, data: data ?? this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownWebSearchResult &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(data, other.data);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(data));

  @override
  String toString() =>
      'UnknownWebSearchResult(type: $type, data: ${data.length} entries)';
}
