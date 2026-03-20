part of 'content.dart';

/// Citation information for model-generated content.
///
/// This is a sealed class with 3 subtypes: [UrlCitation], [FileCitation],
/// and [PlaceCitation].
sealed class Annotation {
  /// Creates an [Annotation].
  const Annotation();

  /// Creates an [Annotation] from JSON.
  factory Annotation.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'url_citation' => UrlCitation.fromJson(json),
      'file_citation' => FileCitation.fromJson(json),
      'place_citation' => PlaceCitation.fromJson(json),
      _ => throw ArgumentError('Unknown annotation type: ${json['type']}'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A URL citation annotation.
class UrlCitation extends Annotation {
  /// Start of segment of the response that is attributed to this source.
  final int? startIndex;

  /// End of the attributed segment, exclusive.
  final int? endIndex;

  /// Title of the cited source.
  final String? title;

  /// URL of the cited source.
  final String? url;

  /// Creates a [UrlCitation] instance.
  const UrlCitation({this.startIndex, this.endIndex, this.title, this.url});

  /// Creates a [UrlCitation] from JSON.
  factory UrlCitation.fromJson(Map<String, dynamic> json) => UrlCitation(
    startIndex: json['start_index'] as int?,
    endIndex: json['end_index'] as int?,
    title: json['title'] as String?,
    url: json['url'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'url_citation',
    if (startIndex != null) 'start_index': startIndex,
    if (endIndex != null) 'end_index': endIndex,
    if (title != null) 'title': title,
    if (url != null) 'url': url,
  };

  /// Creates a copy with replaced values.
  UrlCitation copyWith({
    Object? startIndex = unsetCopyWithValue,
    Object? endIndex = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
  }) {
    return UrlCitation(
      startIndex: startIndex == unsetCopyWithValue
          ? this.startIndex
          : startIndex as int?,
      endIndex: endIndex == unsetCopyWithValue
          ? this.endIndex
          : endIndex as int?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      url: url == unsetCopyWithValue ? this.url : url as String?,
    );
  }
}

/// A file citation annotation.
class FileCitation extends Annotation {
  /// Start of segment of the response that is attributed to this source.
  final int? startIndex;

  /// End of the attributed segment, exclusive.
  final int? endIndex;

  /// The name of the cited file.
  final String? fileName;

  /// The URI of the cited document.
  final String? documentUri;

  /// The source identifier.
  final String? source;

  /// Creates a [FileCitation] instance.
  const FileCitation({
    this.startIndex,
    this.endIndex,
    this.fileName,
    this.documentUri,
    this.source,
  });

  /// Creates a [FileCitation] from JSON.
  factory FileCitation.fromJson(Map<String, dynamic> json) => FileCitation(
    startIndex: json['start_index'] as int?,
    endIndex: json['end_index'] as int?,
    fileName: json['file_name'] as String?,
    documentUri: json['document_uri'] as String?,
    source: json['source'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_citation',
    if (startIndex != null) 'start_index': startIndex,
    if (endIndex != null) 'end_index': endIndex,
    if (fileName != null) 'file_name': fileName,
    if (documentUri != null) 'document_uri': documentUri,
    if (source != null) 'source': source,
  };

  /// Creates a copy with replaced values.
  FileCitation copyWith({
    Object? startIndex = unsetCopyWithValue,
    Object? endIndex = unsetCopyWithValue,
    Object? fileName = unsetCopyWithValue,
    Object? documentUri = unsetCopyWithValue,
    Object? source = unsetCopyWithValue,
  }) {
    return FileCitation(
      startIndex: startIndex == unsetCopyWithValue
          ? this.startIndex
          : startIndex as int?,
      endIndex: endIndex == unsetCopyWithValue
          ? this.endIndex
          : endIndex as int?,
      fileName: fileName == unsetCopyWithValue
          ? this.fileName
          : fileName as String?,
      documentUri: documentUri == unsetCopyWithValue
          ? this.documentUri
          : documentUri as String?,
      source: source == unsetCopyWithValue ? this.source : source as String?,
    );
  }
}

/// A place citation annotation.
class PlaceCitation extends Annotation {
  /// Start of segment of the response that is attributed to this source.
  final int? startIndex;

  /// End of the attributed segment, exclusive.
  final int? endIndex;

  /// The name of the place.
  final String? name;

  /// The place ID.
  final String? placeId;

  /// The URL for the place.
  final String? url;

  /// Review snippets for the place.
  final List<InteractionReviewSnippet>? reviewSnippets;

  /// Creates a [PlaceCitation] instance.
  const PlaceCitation({
    this.startIndex,
    this.endIndex,
    this.name,
    this.placeId,
    this.url,
    this.reviewSnippets,
  });

  /// Creates a [PlaceCitation] from JSON.
  factory PlaceCitation.fromJson(Map<String, dynamic> json) => PlaceCitation(
    startIndex: json['start_index'] as int?,
    endIndex: json['end_index'] as int?,
    name: json['name'] as String?,
    placeId: json['place_id'] as String?,
    url: json['url'] as String?,
    reviewSnippets: (json['review_snippets'] as List<dynamic>?)
        ?.map(
          (e) => InteractionReviewSnippet.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'place_citation',
    if (startIndex != null) 'start_index': startIndex,
    if (endIndex != null) 'end_index': endIndex,
    if (name != null) 'name': name,
    if (placeId != null) 'place_id': placeId,
    if (url != null) 'url': url,
    if (reviewSnippets != null)
      'review_snippets': reviewSnippets!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  PlaceCitation copyWith({
    Object? startIndex = unsetCopyWithValue,
    Object? endIndex = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? placeId = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
    Object? reviewSnippets = unsetCopyWithValue,
  }) {
    return PlaceCitation(
      startIndex: startIndex == unsetCopyWithValue
          ? this.startIndex
          : startIndex as int?,
      endIndex: endIndex == unsetCopyWithValue
          ? this.endIndex
          : endIndex as int?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      placeId: placeId == unsetCopyWithValue
          ? this.placeId
          : placeId as String?,
      url: url == unsetCopyWithValue ? this.url : url as String?,
      reviewSnippets: reviewSnippets == unsetCopyWithValue
          ? this.reviewSnippets
          : reviewSnippets as List<InteractionReviewSnippet>?,
    );
  }
}
