import 'package:meta/meta.dart';
import '_account_helpers.dart';

/// The UTC boundaries of the included credit period.
@immutable
class BalancePeriod {
  /// Creates a balance period.
  BalancePeriod({required DateTime from, required DateTime until})
    : from = from.toUtc(),
      until = until.toUtc();

  /// Start of the period in UTC, inclusive.
  final DateTime from;

  /// End of the period in UTC, exclusive.
  final DateTime until;

  /// Parses a balance period, validating required fields.
  factory BalancePeriod.fromJson(Map<String, dynamic> json) => BalancePeriod(
    from: accountDateTime(json['from'], 'BalancePeriod.from'),
    until: accountDateTime(json['until'], 'BalancePeriod.until'),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'from': from.toIso8601String(),
    'until': until.toIso8601String(),
  };

  /// Creates a copy with replaced values.
  BalancePeriod copyWith({DateTime? from, DateTime? until}) =>
      BalancePeriod(from: from ?? this.from, until: until ?? this.until);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalancePeriod && from == other.from && until == other.until;

  @override
  int get hashCode => Object.hashAll([from, until]);

  @override
  String toString() => 'BalancePeriod(from: $from, until: $until)';
}
