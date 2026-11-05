import 'package:meta/meta.dart';
import '_account_helpers.dart';

/// Unexpired credits purchased separately from the plan.
@immutable
class PurchasedBalance {
  /// Creates a purchased-credit balance.
  const PurchasedBalance({required this.balanceUsd});

  /// Remaining unexpired purchased credits in USD.
  final double balanceUsd;

  /// Parses a purchased-credit balance, validating required fields.
  factory PurchasedBalance.fromJson(Map<String, dynamic> json) =>
      PurchasedBalance(
        balanceUsd: accountDouble(
          json['balance_usd'],
          'PurchasedBalance.balance_usd',
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'balance_usd': balanceUsd};

  /// Creates a copy with replaced values.
  PurchasedBalance copyWith({double? balanceUsd}) =>
      PurchasedBalance(balanceUsd: balanceUsd ?? this.balanceUsd);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchasedBalance && balanceUsd == other.balanceUsd;

  @override
  int get hashCode => Object.hashAll([balanceUsd]);

  @override
  String toString() => 'PurchasedBalance(balanceUsd: $balanceUsd)';
}
