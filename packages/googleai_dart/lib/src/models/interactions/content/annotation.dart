part of 'content.dart';

/// Citation information for model-generated content.
///
/// This is a sealed class with 4 subtypes: [UrlCitation], [FileCitation],
/// [PlaceCitation], and [WordInfo], plus an [UnknownAnnotation] fallback for
/// any `type` this client does not yet model.
sealed class Annotation {
  /// Creates an [Annotation].
  const Annotation();

  /// Creates an [Annotation] from JSON.
  ///
  /// Unrecognized `type` values are surfaced as [UnknownAnnotation] (raw JSON
  /// preserved) so a new/undocumented annotation type cannot break parsing.
  factory Annotation.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'url_citation' => UrlCitation.fromJson(json),
      'file_citation' => FileCitation.fromJson(json),
      'place_citation' => PlaceCitation.fromJson(json),
      'word_info' => WordInfo.fromJson(json),
      _ => UnknownAnnotation.fromJson(json),
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

  /// User provided metadata about the retrieved context.
  final Map<String, dynamic>? customMetadata;

  /// Media ID for image citations, if applicable.
  final String? mediaId;

  /// Page number of the cited document, if applicable.
  final int? pageNumber;

  /// Creates a [FileCitation] instance.
  const FileCitation({
    this.startIndex,
    this.endIndex,
    this.fileName,
    this.documentUri,
    this.source,
    this.customMetadata,
    this.mediaId,
    this.pageNumber,
  });

  /// Creates a [FileCitation] from JSON.
  factory FileCitation.fromJson(Map<String, dynamic> json) => FileCitation(
    startIndex: json['start_index'] as int?,
    endIndex: json['end_index'] as int?,
    fileName: json['file_name'] as String?,
    documentUri: json['document_uri'] as String?,
    source: json['source'] as String?,
    customMetadata: json['custom_metadata'] as Map<String, dynamic>?,
    mediaId: json['media_id'] as String?,
    pageNumber: json['page_number'] as int?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_citation',
    if (startIndex != null) 'start_index': startIndex,
    if (endIndex != null) 'end_index': endIndex,
    if (fileName != null) 'file_name': fileName,
    if (documentUri != null) 'document_uri': documentUri,
    if (source != null) 'source': source,
    if (customMetadata != null) 'custom_metadata': customMetadata,
    if (mediaId != null) 'media_id': mediaId,
    if (pageNumber != null) 'page_number': pageNumber,
  };

  /// Creates a copy with replaced values.
  FileCitation copyWith({
    Object? startIndex = unsetCopyWithValue,
    Object? endIndex = unsetCopyWithValue,
    Object? fileName = unsetCopyWithValue,
    Object? documentUri = unsetCopyWithValue,
    Object? source = unsetCopyWithValue,
    Object? customMetadata = unsetCopyWithValue,
    Object? mediaId = unsetCopyWithValue,
    Object? pageNumber = unsetCopyWithValue,
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
      customMetadata: customMetadata == unsetCopyWithValue
          ? this.customMetadata
          : customMetadata as Map<String, dynamic>?,
      mediaId: mediaId == unsetCopyWithValue
          ? this.mediaId
          : mediaId as String?,
      pageNumber: pageNumber == unsetCopyWithValue
          ? this.pageNumber
          : pageNumber as int?,
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

/// A word-level ASR annotation for transcription output.
///
/// Carries the word text, optional timing, and optional speaker attribution.
class WordInfo extends Annotation {
  /// End of the attributed segment, exclusive.
  final int? endIndex;

  /// End offset in time of the word relative to the start of the audio
  /// (a google-duration string, e.g. `"1.5s"`).
  ///
  /// Present when `timestamp_granularities` contains `"word"`.
  final String? endOffset;

  /// Speaker label for this word (e.g. `"spk_1"`, `"spk_2"`).
  ///
  /// Present when `diarization_mode` is set in [TranscriptionConfig].
  final String? speaker;

  /// Start of segment of the response that is attributed to this source.
  final int? startIndex;

  /// Start offset in time of the word relative to the start of the audio
  /// (a google-duration string, e.g. `"1.5s"`).
  ///
  /// Present when `timestamp_granularities` contains `"word"`.
  final String? startOffset;

  /// The transcribed word.
  final String? text;

  /// Creates a [WordInfo] instance.
  const WordInfo({
    this.endIndex,
    this.endOffset,
    this.speaker,
    this.startIndex,
    this.startOffset,
    this.text,
  });

  /// Creates a [WordInfo] from JSON.
  factory WordInfo.fromJson(Map<String, dynamic> json) => WordInfo(
    endIndex: json['end_index'] as int?,
    endOffset: json['end_offset'] as String?,
    speaker: json['speaker'] as String?,
    startIndex: json['start_index'] as int?,
    startOffset: json['start_offset'] as String?,
    text: json['text'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'word_info',
    if (endIndex != null) 'end_index': endIndex,
    if (endOffset != null) 'end_offset': endOffset,
    if (speaker != null) 'speaker': speaker,
    if (startIndex != null) 'start_index': startIndex,
    if (startOffset != null) 'start_offset': startOffset,
    if (text != null) 'text': text,
  };

  /// Creates a copy with replaced values.
  WordInfo copyWith({
    Object? endIndex = unsetCopyWithValue,
    Object? endOffset = unsetCopyWithValue,
    Object? speaker = unsetCopyWithValue,
    Object? startIndex = unsetCopyWithValue,
    Object? startOffset = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
  }) {
    return WordInfo(
      endIndex: endIndex == unsetCopyWithValue
          ? this.endIndex
          : endIndex as int?,
      endOffset: endOffset == unsetCopyWithValue
          ? this.endOffset
          : endOffset as String?,
      speaker: speaker == unsetCopyWithValue
          ? this.speaker
          : speaker as String?,
      startIndex: startIndex == unsetCopyWithValue
          ? this.startIndex
          : startIndex as int?,
      startOffset: startOffset == unsetCopyWithValue
          ? this.startOffset
          : startOffset as String?,
      text: text == unsetCopyWithValue ? this.text : text as String?,
    );
  }
}

/// An [Annotation] whose `type` is not one of the documented variants.
///
/// The Interactions API is experimental and evolving; new annotation types
/// may be returned before this client models them. Such annotations are
/// surfaced here with their raw JSON preserved instead of failing to parse,
/// keeping parsing resilient and forward-compatible.
class UnknownAnnotation extends Annotation {
  /// The raw JSON payload of the annotation, preserved verbatim.
  final Map<String, dynamic> rawJson;

  /// The type discriminator, read from [rawJson].
  String get type => rawJson['type'] as String? ?? 'unknown';

  /// Creates an [UnknownAnnotation] instance.
  const UnknownAnnotation({required this.rawJson});

  /// Creates an [UnknownAnnotation] from JSON.
  factory UnknownAnnotation.fromJson(Map<String, dynamic> json) =>
      UnknownAnnotation(rawJson: json);

  @override
  Map<String, dynamic> toJson() => rawJson;
}
