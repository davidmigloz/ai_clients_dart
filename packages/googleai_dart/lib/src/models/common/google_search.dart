import '../copy_with_sentinel.dart';
import 'interval.dart';
import 'search_types.dart';

/// Google Search tool configuration.
class GoogleSearch {
  /// Optional. Search types configuration.
  final SearchTypes? searchTypes;

  /// Optional. Time range filter for the search.
  final Interval? timeRangeFilter;

  /// Creates a [GoogleSearch].
  const GoogleSearch({this.searchTypes, this.timeRangeFilter});

  /// Creates a [GoogleSearch] from JSON.
  factory GoogleSearch.fromJson(Map<String, dynamic> json) => GoogleSearch(
    searchTypes: json['searchTypes'] != null
        ? SearchTypes.fromJson(json['searchTypes'] as Map<String, dynamic>)
        : null,
    timeRangeFilter: json['timeRangeFilter'] != null
        ? Interval.fromJson(json['timeRangeFilter'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (searchTypes != null) 'searchTypes': searchTypes!.toJson(),
    if (timeRangeFilter != null) 'timeRangeFilter': timeRangeFilter!.toJson(),
  };

  /// Creates a copy with replaced values.
  GoogleSearch copyWith({
    Object? searchTypes = unsetCopyWithValue,
    Object? timeRangeFilter = unsetCopyWithValue,
  }) {
    return GoogleSearch(
      searchTypes: searchTypes == unsetCopyWithValue
          ? this.searchTypes
          : searchTypes as SearchTypes?,
      timeRangeFilter: timeRangeFilter == unsetCopyWithValue
          ? this.timeRangeFilter
          : timeRangeFilter as Interval?,
    );
  }

  @override
  String toString() =>
      'GoogleSearch(searchTypes: $searchTypes, timeRangeFilter: $timeRangeFilter)';
}
