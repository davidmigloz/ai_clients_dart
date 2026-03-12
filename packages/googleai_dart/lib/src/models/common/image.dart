import '../copy_with_sentinel.dart';

/// An image result from a web search.
class GroundingImage {
  /// Optional. The domain of the image.
  final String? domain;

  /// Optional. The URI of the image.
  final String? imageUri;

  /// Optional. The source URI of the image.
  final String? sourceUri;

  /// Optional. The title of the image.
  final String? title;

  /// Creates an [GroundingImage].
  const GroundingImage({
    this.domain,
    this.imageUri,
    this.sourceUri,
    this.title,
  });

  /// Creates an [GroundingImage] from JSON.
  factory GroundingImage.fromJson(Map<String, dynamic> json) => GroundingImage(
    domain: json['domain'] as String?,
    imageUri: json['imageUri'] as String?,
    sourceUri: json['sourceUri'] as String?,
    title: json['title'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (domain != null) 'domain': domain,
    if (imageUri != null) 'imageUri': imageUri,
    if (sourceUri != null) 'sourceUri': sourceUri,
    if (title != null) 'title': title,
  };

  /// Creates a copy with replaced values.
  GroundingImage copyWith({
    Object? domain = unsetCopyWithValue,
    Object? imageUri = unsetCopyWithValue,
    Object? sourceUri = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
  }) {
    return GroundingImage(
      domain: domain == unsetCopyWithValue ? this.domain : domain as String?,
      imageUri: imageUri == unsetCopyWithValue
          ? this.imageUri
          : imageUri as String?,
      sourceUri: sourceUri == unsetCopyWithValue
          ? this.sourceUri
          : sourceUri as String?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
    );
  }

  @override
  String toString() =>
      'GroundingImage(domain: $domain, imageUri: $imageUri, sourceUri: $sourceUri, title: $title)';
}
