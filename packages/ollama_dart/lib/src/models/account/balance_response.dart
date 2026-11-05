import 'package:meta/meta.dart';
import '_account_helpers.dart';
import 'balance_included.dart';
import 'purchased_balance.dart';

/// Current included and purchased credit balances.
@immutable
class BalanceResponse {
  /// Creates a balance response.
  const BalanceResponse({required this.included, required this.purchased});

  /// Included credits or legacy plan limits.
  final BalanceIncluded included;

  /// Remaining unexpired purchased credits.
  final PurchasedBalance purchased;

  /// Parses a balance response, validating required fields.
  factory BalanceResponse.fromJson(Map<String, dynamic> json) =>
      BalanceResponse(
        included: BalanceIncluded.fromJson(
          accountObject(json['included'], 'BalanceResponse.included'),
        ),
        purchased: PurchasedBalance.fromJson(
          accountObject(json['purchased'], 'BalanceResponse.purchased'),
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'included': included.toJson(),
    'purchased': purchased.toJson(),
  };

  /// Creates a copy with replaced values.
  BalanceResponse copyWith({
    BalanceIncluded? included,
    PurchasedBalance? purchased,
  }) => BalanceResponse(
    included: included ?? this.included,
    purchased: purchased ?? this.purchased,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceResponse &&
          included == other.included &&
          purchased == other.purchased;

  @override
  int get hashCode => Object.hashAll([included, purchased]);

  @override
  String toString() =>
      'BalanceResponse(included: $included, purchased: $purchased)';
}
