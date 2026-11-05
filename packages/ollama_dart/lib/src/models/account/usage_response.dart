import 'package:meta/meta.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '_account_helpers.dart';
import 'usage_bucket.dart';
import 'usage_selectors.dart';
import 'usage_summary.dart';

/// Cloud inference, web search, and web fetch usage over a UTC range.
@immutable
class UsageResponse {
  /// Creates an usage response.
  UsageResponse({
    required this.range,
    required this.scope,
    required this.granularity,
    required DateTime from,
    required DateTime until,
    required this.totals,
    required List<UsageBucket> buckets,
    this.groupBy,
  }) : from = from.toUtc(),
       until = until.toUtc(),
       buckets = List.unmodifiable(buckets);

  /// Selected time range.
  final UsageRange range;

  /// Selected usage scope.
  final UsageScope scope;

  /// Automatically selected bucket size.
  final UsageGranularity granularity;

  /// Start of the range in UTC, inclusive.
  final DateTime from;

  /// End of the range in UTC, exclusive.
  final DateTime until;

  /// Full-range usage, including groups in the remainder.
  final UsageSummary totals;

  /// Buckets in chronological order, including empty periods.
  final List<UsageBucket> buckets;

  /// Selected grouping; present when grouping was requested.
  final UsageGroupBy? groupBy;

  /// Parses an usage response, validating required fields.
  factory UsageResponse.fromJson(Map<String, dynamic> json) => UsageResponse(
    range: UsageRange.fromJson(
      accountString(json['range'], 'UsageResponse.range'),
    ),
    scope: UsageScope.fromJson(
      accountString(json['scope'], 'UsageResponse.scope'),
    ),
    granularity: UsageGranularity.fromJson(
      accountString(json['granularity'], 'UsageResponse.granularity'),
    ),
    from: accountDateTime(json['from'], 'UsageResponse.from'),
    until: accountDateTime(json['until'], 'UsageResponse.until'),
    totals: UsageSummary.fromJson(
      accountObject(json['totals'], 'UsageResponse.totals'),
    ),
    buckets: accountList(
      json['buckets'],
      'UsageResponse.buckets',
      UsageBucket.fromJson,
    ),
    groupBy: json['group_by'] == null
        ? null
        : UsageGroupBy.fromJson(
            accountString(json['group_by'], 'UsageResponse.group_by'),
          ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'range': range.toJson(),
    'scope': scope.toJson(),
    'granularity': granularity.toJson(),
    'from': from.toIso8601String(),
    'until': until.toIso8601String(),
    'totals': totals.toJson(),
    'buckets': buckets.map((item) => item.toJson()).toList(),
    if (groupBy != null) 'group_by': groupBy!.toJson(),
  };

  /// Creates a copy; explicit null clears an optional field.
  UsageResponse copyWith({
    UsageRange? range,
    UsageScope? scope,
    UsageGranularity? granularity,
    DateTime? from,
    DateTime? until,
    UsageSummary? totals,
    List<UsageBucket>? buckets,
    Object? groupBy = unsetCopyWithValue,
  }) => UsageResponse(
    range: range ?? this.range,
    scope: scope ?? this.scope,
    granularity: granularity ?? this.granularity,
    from: from ?? this.from,
    until: until ?? this.until,
    totals: totals ?? this.totals,
    buckets: buckets ?? this.buckets,
    groupBy: identical(groupBy, unsetCopyWithValue)
        ? this.groupBy
        : groupBy as UsageGroupBy?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageResponse &&
          range == other.range &&
          scope == other.scope &&
          granularity == other.granularity &&
          from == other.from &&
          until == other.until &&
          totals == other.totals &&
          listsEqual(buckets, other.buckets) &&
          groupBy == other.groupBy;

  @override
  int get hashCode => Object.hashAll([
    range,
    scope,
    granularity,
    from,
    until,
    totals,
    listHash(buckets),
    groupBy,
  ]);

  @override
  String toString() =>
      'UsageResponse(range: $range, scope: $scope, granularity: $granularity, from: $from, until: $until, totals: $totals, buckets: $buckets, groupBy: $groupBy)';
}
