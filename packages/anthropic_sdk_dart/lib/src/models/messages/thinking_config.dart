import 'package:meta/meta.dart';

/// Configuration for extended thinking mode.
///
/// Extended thinking allows the model to reason through complex problems
/// before generating a response.
sealed class ThinkingConfig {
  const ThinkingConfig();

  /// Enables extended thinking with a budget.
  factory ThinkingConfig.enabled({required int budgetTokens}) = ThinkingEnabled;

  /// Disables extended thinking.
  factory ThinkingConfig.disabled() = ThinkingDisabled;

  /// Creates a [ThinkingConfig] from JSON.
  factory ThinkingConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'enabled' => ThinkingEnabled.fromJson(json),
      'disabled' => ThinkingDisabled.fromJson(json),
      _ => throw FormatException('Unknown ThinkingConfig type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Enables extended thinking with a token budget.
@immutable
class ThinkingEnabled extends ThinkingConfig {
  /// Maximum tokens for thinking.
  ///
  /// Must be at least 1024 and less than max_tokens.
  final int budgetTokens;

  /// Creates a [ThinkingEnabled].
  const ThinkingEnabled({required this.budgetTokens});

  /// Creates a [ThinkingEnabled] from JSON.
  factory ThinkingEnabled.fromJson(Map<String, dynamic> json) {
    return ThinkingEnabled(budgetTokens: json['budget_tokens'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'enabled',
    'budget_tokens': budgetTokens,
  };

  /// Creates a copy with replaced values.
  ThinkingEnabled copyWith({int? budgetTokens}) {
    return ThinkingEnabled(budgetTokens: budgetTokens ?? this.budgetTokens);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingEnabled &&
          runtimeType == other.runtimeType &&
          budgetTokens == other.budgetTokens;

  @override
  int get hashCode => budgetTokens.hashCode;

  @override
  String toString() => 'ThinkingEnabled(budgetTokens: $budgetTokens)';
}

/// Disables extended thinking.
@immutable
class ThinkingDisabled extends ThinkingConfig {
  /// Creates a [ThinkingDisabled].
  const ThinkingDisabled();

  /// Creates a [ThinkingDisabled] from JSON.
  factory ThinkingDisabled.fromJson(Map<String, dynamic> _) {
    return const ThinkingDisabled();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'disabled'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingDisabled && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ThinkingDisabled()';
}
