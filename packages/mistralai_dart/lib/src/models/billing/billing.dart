import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Usage against the expected API and Vibe budgets.
@immutable
class BillingBudget {
  /// Creates a [BillingBudget].
  const BillingBudget({required this.apiBudget, required this.vibeBudget});

  /// API budget usage details.
  final BillingBudgetDetail apiBudget;

  /// Vibe-specific budget usage details.
  final BillingBudgetDetail vibeBudget;

  /// Parses a [BillingBudget] from JSON.
  factory BillingBudget.fromJson(Map<String, dynamic> json) {
    if (json['api_budget'] == null) {
      throw const FormatException('BillingBudget: missing api_budget');
    }
    if (json['vibe_budget'] == null) {
      throw const FormatException('BillingBudget: missing vibe_budget');
    }
    return BillingBudget(
      apiBudget: BillingBudgetDetail.fromJson(
        json['api_budget'] as Map<String, dynamic>,
      ),
      vibeBudget: BillingBudgetDetail.fromJson(
        json['vibe_budget'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'api_budget': apiBudget.toJson(),
    'vibe_budget': vibeBudget.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  BillingBudget copyWith({
    BillingBudgetDetail? apiBudget,
    BillingBudgetDetail? vibeBudget,
  }) => BillingBudget(
    apiBudget: apiBudget ?? this.apiBudget,
    vibeBudget: vibeBudget ?? this.vibeBudget,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingBudget &&
          runtimeType == other.runtimeType &&
          apiBudget == other.apiBudget &&
          vibeBudget == other.vibeBudget;

  @override
  int get hashCode => Object.hashAll([apiBudget, vibeBudget]);

  @override
  String toString() =>
      'BillingBudget('
      'apiBudget: $apiBudget, '
      'vibeBudget: $vibeBudget)';
}

/// Usage, budget amount, and reset time for one billing category.
@immutable
class BillingBudgetDetail {
  /// Creates a [BillingBudgetDetail].
  const BillingBudgetDetail({
    this.currency,
    required this.initialBudget,
    this.paygEnabled,
    required this.resetAt,
    required this.usagePercentage,
  });

  /// ISO 4217 currency code of the budget (e.g. EUR, USD). The applicable budget is lazily materialized for the requested period, so this is only null when no budget could be derived.
  final String? currency;

  /// Initial budget allocated for the billing period, expressed in the budget currency.
  final double initialBudget;

  /// Whether pay-as-you-go overage is enabled for this budget type. Only meaningful for the Vibe budget.
  final bool? paygEnabled;

  /// Timestamp at which the requested billing period resets (start of the next period).
  final String resetAt;

  /// Percentage of the budget consumed for the requested billing period (0-100).
  final double usagePercentage;

  /// Parses a [BillingBudgetDetail] from JSON.
  factory BillingBudgetDetail.fromJson(Map<String, dynamic> json) {
    if (json['initial_budget'] == null) {
      throw const FormatException(
        'BillingBudgetDetail: missing initial_budget',
      );
    }
    if (json['reset_at'] == null) {
      throw const FormatException('BillingBudgetDetail: missing reset_at');
    }
    if (json['usage_percentage'] == null) {
      throw const FormatException(
        'BillingBudgetDetail: missing usage_percentage',
      );
    }
    return BillingBudgetDetail(
      currency: json['currency'] == null ? null : json['currency'] as String,
      initialBudget: (json['initial_budget'] as num).toDouble(),
      paygEnabled: json['payg_enabled'] == null
          ? null
          : json['payg_enabled'] as bool,
      resetAt: json['reset_at'] as String,
      usagePercentage: (json['usage_percentage'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'currency': ?currency,
    'initial_budget': initialBudget,
    'payg_enabled': ?paygEnabled,
    'reset_at': resetAt,
    'usage_percentage': usagePercentage,
  };

  /// Creates a copy with the given fields replaced.
  BillingBudgetDetail copyWith({
    Object? currency = unsetCopyWithValue,
    double? initialBudget,
    Object? paygEnabled = unsetCopyWithValue,
    String? resetAt,
    double? usagePercentage,
  }) => BillingBudgetDetail(
    currency: currency == unsetCopyWithValue
        ? this.currency
        : currency as String?,
    initialBudget: initialBudget ?? this.initialBudget,
    paygEnabled: paygEnabled == unsetCopyWithValue
        ? this.paygEnabled
        : paygEnabled as bool?,
    resetAt: resetAt ?? this.resetAt,
    usagePercentage: usagePercentage ?? this.usagePercentage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingBudgetDetail &&
          runtimeType == other.runtimeType &&
          currency == other.currency &&
          initialBudget == other.initialBudget &&
          paygEnabled == other.paygEnabled &&
          resetAt == other.resetAt &&
          usagePercentage == other.usagePercentage;

  @override
  int get hashCode => Object.hashAll([
    currency,
    initialBudget,
    paygEnabled,
    resetAt,
    usagePercentage,
  ]);

  @override
  String toString() =>
      'BillingBudgetDetail('
      'currency: $currency, '
      'initialBudget: $initialBudget, '
      'paygEnabled: $paygEnabled, '
      'resetAt: $resetAt, '
      'usagePercentage: $usagePercentage)';
}

/// The current plan and pay-as-you-go settings.
@immutable
class BillingSubscription {
  /// Creates a [BillingSubscription].
  const BillingSubscription({
    required this.enterprise,
    required this.paygEnabled,
    required this.planName,
    required this.vibePaygEnabled,
  });

  /// Whether the organization is on the Enterprise tier (org_tier == ENTERPRISE).
  final bool enterprise;

  /// Whether pay-as-you-go is active (an API subscription is active).
  final bool paygEnabled;

  /// Unified plan name. One of: FREE, INDIVIDUAL, EDU, TEAM. Reflects the active Mistral licence (chat subscription) or FREE when no subscription exists.
  final String planName;

  /// Whether pay-as-you-go is enabled for Vibe Code specifically.
  final bool vibePaygEnabled;

  /// Parses a [BillingSubscription] from JSON.
  factory BillingSubscription.fromJson(Map<String, dynamic> json) {
    if (json['enterprise'] == null) {
      throw const FormatException('BillingSubscription: missing enterprise');
    }
    if (json['payg_enabled'] == null) {
      throw const FormatException('BillingSubscription: missing payg_enabled');
    }
    if (json['plan_name'] == null) {
      throw const FormatException('BillingSubscription: missing plan_name');
    }
    if (json['vibe_payg_enabled'] == null) {
      throw const FormatException(
        'BillingSubscription: missing vibe_payg_enabled',
      );
    }
    return BillingSubscription(
      enterprise: json['enterprise'] as bool,
      paygEnabled: json['payg_enabled'] as bool,
      planName: json['plan_name'] as String,
      vibePaygEnabled: json['vibe_payg_enabled'] as bool,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'enterprise': enterprise,
    'payg_enabled': paygEnabled,
    'plan_name': planName,
    'vibe_payg_enabled': vibePaygEnabled,
  };

  /// Creates a copy with the given fields replaced.
  BillingSubscription copyWith({
    bool? enterprise,
    bool? paygEnabled,
    String? planName,
    bool? vibePaygEnabled,
  }) => BillingSubscription(
    enterprise: enterprise ?? this.enterprise,
    paygEnabled: paygEnabled ?? this.paygEnabled,
    planName: planName ?? this.planName,
    vibePaygEnabled: vibePaygEnabled ?? this.vibePaygEnabled,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingSubscription &&
          runtimeType == other.runtimeType &&
          enterprise == other.enterprise &&
          paygEnabled == other.paygEnabled &&
          planName == other.planName &&
          vibePaygEnabled == other.vibePaygEnabled;

  @override
  int get hashCode =>
      Object.hashAll([enterprise, paygEnabled, planName, vibePaygEnabled]);

  @override
  String toString() =>
      'BillingSubscription('
      'enterprise: $enterprise, '
      'paygEnabled: $paygEnabled, '
      'planName: $planName, '
      'vibePaygEnabled: $vibePaygEnabled)';
}
