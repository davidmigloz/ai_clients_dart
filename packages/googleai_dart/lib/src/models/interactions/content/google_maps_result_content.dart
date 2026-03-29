part of 'content.dart';

/// A Google Maps result content block.
class GoogleMapsResultContent extends InteractionContent {
  @override
  String get type => 'google_maps_result';

  /// ID to match the ID from the Google Maps call block.
  final String callId;

  /// The results of the Google Maps search.
  final List<GoogleMapsResult> result;

  /// The signature of the Google Maps result.
  final String? signature;

  /// Creates a [GoogleMapsResultContent] instance.
  const GoogleMapsResultContent({
    required this.callId,
    required this.result,
    this.signature,
  });

  /// Creates a [GoogleMapsResultContent] from JSON.
  ///
  /// Required fields default to empty values when absent
  /// (e.g. content.start events).
  factory GoogleMapsResultContent.fromJson(Map<String, dynamic> json) =>
      GoogleMapsResultContent(
        callId: json['call_id'] as String? ?? '',
        result:
            (json['result'] as List<dynamic>?)
                ?.map(
                  (e) => GoogleMapsResult.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.map((e) => e.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  GoogleMapsResultContent copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleMapsResultContent(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as List<GoogleMapsResult>,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// A Google Maps result item.
class GoogleMapsResult {
  /// The places returned from the search.
  final List<Places>? places;

  /// Widget context token for rendering.
  final String? widgetContextToken;

  /// Creates a [GoogleMapsResult] instance.
  const GoogleMapsResult({this.places, this.widgetContextToken});

  /// Creates a [GoogleMapsResult] from JSON.
  factory GoogleMapsResult.fromJson(Map<String, dynamic> json) =>
      GoogleMapsResult(
        places: (json['places'] as List<dynamic>?)
            ?.map((e) => Places.fromJson(e as Map<String, dynamic>))
            .toList(),
        widgetContextToken: json['widget_context_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (places != null) 'places': places!.map((e) => e.toJson()).toList(),
    if (widgetContextToken != null) 'widget_context_token': widgetContextToken,
  };

  /// Creates a copy with replaced values.
  GoogleMapsResult copyWith({
    Object? places = unsetCopyWithValue,
    Object? widgetContextToken = unsetCopyWithValue,
  }) {
    return GoogleMapsResult(
      places: places == unsetCopyWithValue
          ? this.places
          : places as List<Places>?,
      widgetContextToken: widgetContextToken == unsetCopyWithValue
          ? this.widgetContextToken
          : widgetContextToken as String?,
    );
  }
}

/// A place result from Google Maps.
class Places {
  /// The name of the place.
  final String? name;

  /// The place ID.
  final String? placeId;

  /// Review snippets for the place.
  final List<InteractionReviewSnippet>? reviewSnippets;

  /// The URL for the place.
  final String? url;

  /// Creates a [Places] instance.
  const Places({this.name, this.placeId, this.reviewSnippets, this.url});

  /// Creates a [Places] from JSON.
  factory Places.fromJson(Map<String, dynamic> json) => Places(
    name: json['name'] as String?,
    placeId: json['place_id'] as String?,
    reviewSnippets: (json['review_snippets'] as List<dynamic>?)
        ?.map(
          (e) => InteractionReviewSnippet.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
    url: json['url'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (placeId != null) 'place_id': placeId,
    if (reviewSnippets != null)
      'review_snippets': reviewSnippets!.map((e) => e.toJson()).toList(),
    if (url != null) 'url': url,
  };

  /// Creates a copy with replaced values.
  Places copyWith({
    Object? name = unsetCopyWithValue,
    Object? placeId = unsetCopyWithValue,
    Object? reviewSnippets = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
  }) {
    return Places(
      name: name == unsetCopyWithValue ? this.name : name as String?,
      placeId: placeId == unsetCopyWithValue
          ? this.placeId
          : placeId as String?,
      reviewSnippets: reviewSnippets == unsetCopyWithValue
          ? this.reviewSnippets
          : reviewSnippets as List<InteractionReviewSnippet>?,
      url: url == unsetCopyWithValue ? this.url : url as String?,
    );
  }
}

/// A review snippet from an interaction (uses snake_case JSON keys).
///
/// Named `InteractionReviewSnippet` to avoid collision with the
/// `ReviewSnippet` class in the metadata models (which uses camelCase keys).
class InteractionReviewSnippet {
  /// The ID of the review.
  final String? reviewId;

  /// The title of the review.
  final String? title;

  /// The URL of the review.
  final String? url;

  /// Creates an [InteractionReviewSnippet] instance.
  const InteractionReviewSnippet({this.reviewId, this.title, this.url});

  /// Creates an [InteractionReviewSnippet] from JSON.
  factory InteractionReviewSnippet.fromJson(Map<String, dynamic> json) =>
      InteractionReviewSnippet(
        reviewId: json['review_id'] as String?,
        title: json['title'] as String?,
        url: json['url'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (reviewId != null) 'review_id': reviewId,
    if (title != null) 'title': title,
    if (url != null) 'url': url,
  };

  /// Creates a copy with replaced values.
  InteractionReviewSnippet copyWith({
    Object? reviewId = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
  }) {
    return InteractionReviewSnippet(
      reviewId: reviewId == unsetCopyWithValue
          ? this.reviewId
          : reviewId as String?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      url: url == unsetCopyWithValue ? this.url : url as String?,
    );
  }
}
