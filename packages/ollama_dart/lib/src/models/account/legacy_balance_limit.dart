import 'package:meta/meta.dart';
import '_account_helpers.dart';

/// The remaining percentage of a legacy plan limit.
@immutable
class LegacyBalanceLimit {
  /// Creates a legacy plan limit.
  LegacyBalanceLimit({
    required this.remainingPercent,
    required DateTime resetsAt,
  }) : resetsAt = resetsAt.toUtc();

  /// Percentage of the limit remaining, from 0 to 100.
  final double remainingPercent;

  /// Next reset time in UTC.
  final DateTime resetsAt;

  /// Parses a legacy plan limit, validating required fields.
  factory LegacyBalanceLimit.fromJson(Map<String, dynamic> json) =>
      LegacyBalanceLimit(
        remainingPercent: accountDouble(
          json['remaining_percent'],
          'LegacyBalanceLimit.remaining_percent',
        ),
        resetsAt: accountDateTime(
          json['resets_at'],
          'LegacyBalanceLimit.resets_at',
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'remaining_percent': remainingPercent,
    'resets_at': resetsAt.toIso8601String(),
  };

  /// Creates a copy with replaced values.
  LegacyBalanceLimit copyWith({double? remainingPercent, DateTime? resetsAt}) =>
      LegacyBalanceLimit(
        remainingPercent: remainingPercent ?? this.remainingPercent,
        resetsAt: resetsAt ?? this.resetsAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegacyBalanceLimit &&
          remainingPercent == other.remainingPercent &&
          resetsAt == other.resetsAt;

  @override
  int get hashCode => Object.hashAll([remainingPercent, resetsAt]);

  @override
  String toString() =>
      'LegacyBalanceLimit(remainingPercent: $remainingPercent, resetsAt: $resetsAt)';
}
