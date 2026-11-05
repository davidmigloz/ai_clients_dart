import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '_account_helpers.dart';
import 'balance_period.dart';
import 'legacy_balance_limit.dart';

/// Included credits or plan limits returned for the authenticated account.
///
/// Variants: [IncludedBalance], [LegacyIncludedBalance], and
/// [UnknownIncludedBalance]. The wire format has no discriminator field.
@immutable
sealed class BalanceIncluded {
  const BalanceIncluded();

  /// Parses the current credits or legacy limits shape.
  ///
  /// An unfamiliar shape is retained for forward compatibility. A recognized
  /// shape still validates all required fields rather than silently defaulting.
  factory BalanceIncluded.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('balance_usd') ||
        json.containsKey('allowance_usd') ||
        json.containsKey('period')) {
      return IncludedBalance.fromJson(json);
    }
    if (json.containsKey('session') || json.containsKey('weekly')) {
      return LegacyIncludedBalance.fromJson(json);
    }
    return UnknownIncludedBalance(json);
  }

  /// Converts to the API's JSON representation.
  Map<String, dynamic> toJson();
}

/// An unfamiliar included balance shape preserved for future server versions.
@immutable
class UnknownIncludedBalance extends BalanceIncluded {
  /// Creates an immutable copy of the complete JSON payload.
  UnknownIncludedBalance(Map<String, dynamic> rawJson)
    : rawJson = accountFreezeJson(rawJson)! as Map<String, dynamic>;

  /// The complete immutable JSON value.
  final Map<String, dynamic> rawJson;

  /// Creates an unfamiliar balance from JSON.
  factory UnknownIncludedBalance.fromJson(Map<String, dynamic> json) =>
      UnknownIncludedBalance(json);

  @override
  Map<String, dynamic> toJson() => {...rawJson};

  /// Creates a copy with a replaced payload.
  UnknownIncludedBalance copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownIncludedBalance(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownIncludedBalance && mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() =>
      'UnknownIncludedBalance(rawJson: ${rawJson.length} entries)';
}

/// Included plan credits for the current monthly reset period.
@immutable
class IncludedBalance extends BalanceIncluded {
  /// Creates an included-credit balance.
  const IncludedBalance({
    required this.balanceUsd,
    required this.allowanceUsd,
    required this.period,
  });

  /// Remaining included credits in USD.
  final double balanceUsd;

  /// Included credits available for the full period in USD.
  final double allowanceUsd;

  /// The monthly included-credit period, including annual subscriptions.
  final BalancePeriod period;

  /// Parses an included-credit balance, validating required fields.
  factory IncludedBalance.fromJson(Map<String, dynamic> json) =>
      IncludedBalance(
        balanceUsd: accountDouble(
          json['balance_usd'],
          'IncludedBalance.balance_usd',
        ),
        allowanceUsd: accountDouble(
          json['allowance_usd'],
          'IncludedBalance.allowance_usd',
        ),
        period: BalancePeriod.fromJson(
          accountObject(json['period'], 'IncludedBalance.period'),
        ),
      );

  /// Converts to JSON.
  @override
  Map<String, dynamic> toJson() => {
    'balance_usd': balanceUsd,
    'allowance_usd': allowanceUsd,
    'period': period.toJson(),
  };

  /// Creates a copy with replaced values.
  IncludedBalance copyWith({
    double? balanceUsd,
    double? allowanceUsd,
    BalancePeriod? period,
  }) => IncludedBalance(
    balanceUsd: balanceUsd ?? this.balanceUsd,
    allowanceUsd: allowanceUsd ?? this.allowanceUsd,
    period: period ?? this.period,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncludedBalance &&
          balanceUsd == other.balanceUsd &&
          allowanceUsd == other.allowanceUsd &&
          period == other.period;

  @override
  int get hashCode => Object.hashAll([balanceUsd, allowanceUsd, period]);

  @override
  String toString() =>
      'IncludedBalance(balanceUsd: $balanceUsd, allowanceUsd: $allowanceUsd, period: $period)';
}

/// Session and weekly limits returned for legacy plans.
@immutable
class LegacyIncludedBalance extends BalanceIncluded {
  /// Creates a legacy included balance.
  const LegacyIncludedBalance({required this.session, required this.weekly});

  /// The remaining session limit.
  final LegacyBalanceLimit session;

  /// The remaining weekly limit.
  final LegacyBalanceLimit weekly;

  /// Parses a legacy included balance, validating required fields.
  factory LegacyIncludedBalance.fromJson(Map<String, dynamic> json) =>
      LegacyIncludedBalance(
        session: LegacyBalanceLimit.fromJson(
          accountObject(json['session'], 'LegacyIncludedBalance.session'),
        ),
        weekly: LegacyBalanceLimit.fromJson(
          accountObject(json['weekly'], 'LegacyIncludedBalance.weekly'),
        ),
      );

  /// Converts to JSON.
  @override
  Map<String, dynamic> toJson() => {
    'session': session.toJson(),
    'weekly': weekly.toJson(),
  };

  /// Creates a copy with replaced values.
  LegacyIncludedBalance copyWith({
    LegacyBalanceLimit? session,
    LegacyBalanceLimit? weekly,
  }) => LegacyIncludedBalance(
    session: session ?? this.session,
    weekly: weekly ?? this.weekly,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegacyIncludedBalance &&
          session == other.session &&
          weekly == other.weekly;

  @override
  int get hashCode => Object.hashAll([session, weekly]);

  @override
  String toString() =>
      'LegacyIncludedBalance(session: $session, weekly: $weekly)';
}
