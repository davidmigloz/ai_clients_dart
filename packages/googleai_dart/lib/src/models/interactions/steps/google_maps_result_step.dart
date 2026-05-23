part of 'steps.dart';

/// Result of a Google Maps call.
class GoogleMapsResultStep extends InteractionStep {
  @override
  String get type => 'google_maps_result';

  /// ID matching the corresponding [GoogleMapsCallStep.id].
  final String callId;

  /// The results of the Google Maps query.
  final List<GoogleMapsResultItem> result;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleMapsResultStep] instance.
  const GoogleMapsResultStep({
    required this.callId,
    required this.result,
    this.signature,
  });

  /// Creates a [GoogleMapsResultStep] from JSON.
  factory GoogleMapsResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'google_maps_result') {
      throw FormatException(
        'Expected type "google_maps_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'GoogleMapsResultStep: missing required "call_id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `result` is populated later via `step.delta`; default to empty when
    // absent.
    final resultJson = json['result'];
    final result = resultJson is List
        ? resultJson
              .map(
                (e) => GoogleMapsResultItem.fromJson(e as Map<String, dynamic>),
              )
              .toList()
        : <GoogleMapsResultItem>[];
    return GoogleMapsResultStep(
      callId: callId,
      result: result,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.map((e) => e.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  GoogleMapsResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleMapsResultStep(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as List<GoogleMapsResultItem>,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// A single item from a Google Maps query result.
class GoogleMapsResultItem {
  /// The places returned for the query.
  final List<GoogleMapsResultPlaces>? places;

  /// Widget context token for rendering Google Maps results.
  final String? widgetContextToken;

  /// Creates a [GoogleMapsResultItem] instance.
  const GoogleMapsResultItem({this.places, this.widgetContextToken});

  /// Creates from JSON.
  factory GoogleMapsResultItem.fromJson(Map<String, dynamic> json) =>
      GoogleMapsResultItem(
        places: (json['places'] as List<dynamic>?)
            ?.map(
              (e) => GoogleMapsResultPlaces.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        widgetContextToken: json['widget_context_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (places != null) 'places': places!.map((e) => e.toJson()).toList(),
    if (widgetContextToken != null) 'widget_context_token': widgetContextToken,
  };

  /// Creates a copy with replaced values.
  GoogleMapsResultItem copyWith({
    Object? places = unsetCopyWithValue,
    Object? widgetContextToken = unsetCopyWithValue,
  }) {
    return GoogleMapsResultItem(
      places: places == unsetCopyWithValue
          ? this.places
          : places as List<GoogleMapsResultPlaces>?,
      widgetContextToken: widgetContextToken == unsetCopyWithValue
          ? this.widgetContextToken
          : widgetContextToken as String?,
    );
  }
}

/// A place returned in a [GoogleMapsResultItem].
class GoogleMapsResultPlaces {
  /// The name of the place.
  final String? name;

  /// The place ID.
  final String? placeId;

  /// Review snippets for the place.
  final List<InteractionReviewSnippet>? reviewSnippets;

  /// The URL for the place.
  final String? url;

  /// Creates a [GoogleMapsResultPlaces] instance.
  const GoogleMapsResultPlaces({
    this.name,
    this.placeId,
    this.reviewSnippets,
    this.url,
  });

  /// Creates from JSON.
  factory GoogleMapsResultPlaces.fromJson(Map<String, dynamic> json) =>
      GoogleMapsResultPlaces(
        name: json['name'] as String?,
        placeId: json['place_id'] as String?,
        reviewSnippets: (json['review_snippets'] as List<dynamic>?)
            ?.map(
              (e) =>
                  InteractionReviewSnippet.fromJson(e as Map<String, dynamic>),
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
  GoogleMapsResultPlaces copyWith({
    Object? name = unsetCopyWithValue,
    Object? placeId = unsetCopyWithValue,
    Object? reviewSnippets = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
  }) {
    return GoogleMapsResultPlaces(
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
