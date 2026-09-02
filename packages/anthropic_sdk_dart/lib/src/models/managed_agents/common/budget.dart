import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// A monetary amount in a specific currency.
@immutable
class MonetaryAmount {
  /// Amount in minor units of the currency, as an integer decimal string
  /// with no leading zeros: `"2500"` is $25.00 and `"50"` is fifty cents. A
  /// string rather than a number so no float rounding is ever applied.
  final String amount;

  /// Uppercase ISO-4217 currency code. `USD` is the only currency currently
  /// supported; the accepted set is closed and grows only when a new
  /// currency is priced.
  final String currency;

  /// Creates a [MonetaryAmount].
  const MonetaryAmount({required this.amount, required this.currency});

  /// Creates a [MonetaryAmount] from JSON.
  factory MonetaryAmount.fromJson(Map<String, dynamic> json) {
    return MonetaryAmount(
      amount: json['amount'] as String,
      currency: json['currency'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'amount': amount, 'currency': currency};

  /// Creates a copy with replaced values.
  MonetaryAmount copyWith({String? amount, String? currency}) {
    return MonetaryAmount(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonetaryAmount &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => 'MonetaryAmount(amount: $amount, currency: $currency)';
}

/// An enforced spend ceiling on a session or deployment.
///
/// Discriminated on `type`; [BudgetLimit] is the only kind currently
/// supported.
///
/// Variants:
/// - [BudgetLimit] — a hard spend ceiling.
/// - [UnknownBudget] — unrecognized budget type, for forward compatibility.
sealed class Budget {
  const Budget();

  /// Creates a [Budget] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownBudget].
  factory Budget.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'limit' => BudgetLimit.fromJson(json),
      _ => UnknownBudget(rawJson: json),
    };
  }

  /// Creates a [BudgetLimit].
  factory Budget.limit({required MonetaryAmount maxListCost}) =>
      BudgetLimit(maxListCost: maxListCost);

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A hard spend ceiling. The session stops issuing new model requests once
/// the tracked list cost reaches [maxListCost].
@immutable
class BudgetLimit extends Budget {
  /// The budget type, always 'limit'.
  String get type => 'limit';

  /// Maximum list cost the session may accrue. List price is used regardless
  /// of any negotiated discount, so the cap fires at or before the actual
  /// charge.
  final MonetaryAmount maxListCost;

  /// Creates a [BudgetLimit].
  const BudgetLimit({required this.maxListCost});

  /// Creates a [BudgetLimit] from JSON.
  factory BudgetLimit.fromJson(Map<String, dynamic> json) {
    return BudgetLimit(
      maxListCost: MonetaryAmount.fromJson(
        json['max_list_cost'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'max_list_cost': maxListCost.toJson(),
  };

  /// Creates a copy with replaced values.
  BudgetLimit copyWith({MonetaryAmount? maxListCost}) {
    return BudgetLimit(maxListCost: maxListCost ?? this.maxListCost);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetLimit &&
          runtimeType == other.runtimeType &&
          maxListCost == other.maxListCost;

  @override
  int get hashCode => maxListCost.hashCode;

  @override
  String toString() => 'BudgetLimit(maxListCost: $maxListCost)';
}

/// Unrecognized [Budget] type — preserves raw JSON for forward compatibility.
@immutable
class UnknownBudget extends Budget {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownBudget].
  const UnknownBudget({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownBudget &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownBudget(rawJson: $rawJson)';
}
