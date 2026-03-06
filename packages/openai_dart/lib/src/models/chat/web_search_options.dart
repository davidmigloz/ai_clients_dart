import 'package:meta/meta.dart';

/// Web search options for the Chat Completions API.
///
/// This tool searches the web for relevant results to use in a response.
/// Learn more about the
/// [web search tool](https://platform.openai.com/docs/guides/tools-web-search?api-mode=chat).
@immutable
class WebSearchOptions {
  /// The amount of context to include from web search results.
  ///
  /// Can be `low`, `medium`, or `high`. Defaults to `medium`.
  final String? searchContextSize;

  /// The user's approximate location for localized search results.
  final WebSearchUserLocation? userLocation;

  /// Creates [WebSearchOptions].
  const WebSearchOptions({this.searchContextSize, this.userLocation});

  /// Creates [WebSearchOptions] from JSON.
  factory WebSearchOptions.fromJson(Map<String, dynamic> json) {
    return WebSearchOptions(
      searchContextSize: json['search_context_size'] as String?,
      userLocation: json['user_location'] != null
          ? WebSearchUserLocation.fromJson(
              json['user_location'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (searchContextSize != null) 'search_context_size': searchContextSize,
    if (userLocation != null) 'user_location': userLocation!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchOptions &&
          runtimeType == other.runtimeType &&
          searchContextSize == other.searchContextSize &&
          userLocation == other.userLocation;

  @override
  int get hashCode => Object.hash(searchContextSize, userLocation);

  @override
  String toString() =>
      'WebSearchOptions(searchContextSize: $searchContextSize, userLocation: $userLocation)';
}

/// User location wrapper for web search in Chat Completions.
///
/// Contains an `approximate` field with the actual location data.
/// This nesting matches the Chat Completions API JSON structure:
/// `{"type": "approximate", "approximate": {"country": "US", ...}}`.
@immutable
class WebSearchUserLocation {
  /// The approximate location of the user.
  final WebSearchLocation approximate;

  /// Creates a [WebSearchUserLocation].
  const WebSearchUserLocation({required this.approximate});

  /// Creates a [WebSearchUserLocation] from JSON.
  factory WebSearchUserLocation.fromJson(Map<String, dynamic> json) {
    return WebSearchUserLocation(
      approximate: WebSearchLocation.fromJson(
        json['approximate'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'approximate',
    'approximate': approximate.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchUserLocation &&
          runtimeType == other.runtimeType &&
          approximate == other.approximate;

  @override
  int get hashCode => approximate.hashCode;

  @override
  String toString() => 'WebSearchUserLocation(approximate: $approximate)';
}

/// Approximate location parameters for web search.
@immutable
class WebSearchLocation {
  /// The two-letter ISO country code (e.g. `US`).
  final String? country;

  /// Free text region or state (e.g. `California`).
  final String? region;

  /// Free text city name (e.g. `San Francisco`).
  final String? city;

  /// The IANA timezone (e.g. `America/Los_Angeles`).
  final String? timezone;

  /// Creates a [WebSearchLocation].
  const WebSearchLocation({
    this.country,
    this.region,
    this.city,
    this.timezone,
  });

  /// Creates a [WebSearchLocation] from JSON.
  factory WebSearchLocation.fromJson(Map<String, dynamic> json) {
    return WebSearchLocation(
      country: json['country'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (country != null) 'country': country,
    if (region != null) 'region': region,
    if (city != null) 'city': city,
    if (timezone != null) 'timezone': timezone,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchLocation &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          region == other.region &&
          city == other.city &&
          timezone == other.timezone;

  @override
  int get hashCode => Object.hash(country, region, city, timezone);

  @override
  String toString() =>
      'WebSearchLocation(country: $country, region: $region, city: $city, timezone: $timezone)';
}
