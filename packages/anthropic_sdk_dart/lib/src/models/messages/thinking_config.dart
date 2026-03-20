import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Controls how thinking content appears in the response.
enum ThinkingDisplayMode {
  /// Thinking is returned normally (default).
  summarized,

  /// Thinking content is redacted but a signature is returned
  /// for multi-turn continuity.
  omitted;

  /// Creates a [ThinkingDisplayMode] from a JSON string.
  static ThinkingDisplayMode fromJson(String json) => switch (json) {
    'summarized' => ThinkingDisplayMode.summarized,
    'omitted' => ThinkingDisplayMode.omitted,
    _ => throw FormatException('Unknown ThinkingDisplayMode: $json'),
  };

  /// Converts to a JSON string.
  String toJson() => name;
}

/// Configuration for extended thinking mode.
///
/// Extended thinking allows the model to reason through complex problems
/// before generating a response.
sealed class ThinkingConfig {
  const ThinkingConfig();

  /// Enables extended thinking with a budget.
  factory ThinkingConfig.enabled({
    required int budgetTokens,
    ThinkingDisplayMode? display,
  }) = ThinkingEnabled;

  /// Disables extended thinking.
  factory ThinkingConfig.disabled() = ThinkingDisabled;

  /// Enables adaptive thinking mode.
  ///
  /// In adaptive mode, the model automatically determines the thinking budget.
  factory ThinkingConfig.adaptive({ThinkingDisplayMode? display}) =
      ThinkingAdaptive;

  /// Creates a [ThinkingConfig] from JSON.
  factory ThinkingConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'enabled' => ThinkingEnabled.fromJson(json),
      'disabled' => ThinkingDisabled.fromJson(json),
      'adaptive' => ThinkingAdaptive.fromJson(json),
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

  /// Controls how thinking content appears in the response.
  final ThinkingDisplayMode? display;

  /// Creates a [ThinkingEnabled].
  const ThinkingEnabled({required this.budgetTokens, this.display});

  /// Creates a [ThinkingEnabled] from JSON.
  factory ThinkingEnabled.fromJson(Map<String, dynamic> json) {
    return ThinkingEnabled(
      budgetTokens: json['budget_tokens'] as int,
      display: json['display'] != null
          ? ThinkingDisplayMode.fromJson(json['display'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'enabled',
    'budget_tokens': budgetTokens,
    if (display != null) 'display': display!.toJson(),
  };

  /// Creates a copy with replaced values.
  ThinkingEnabled copyWith({
    int? budgetTokens,
    Object? display = unsetCopyWithValue,
  }) {
    return ThinkingEnabled(
      budgetTokens: budgetTokens ?? this.budgetTokens,
      display: display == unsetCopyWithValue
          ? this.display
          : display as ThinkingDisplayMode?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingEnabled &&
          runtimeType == other.runtimeType &&
          budgetTokens == other.budgetTokens &&
          display == other.display;

  @override
  int get hashCode => Object.hash(budgetTokens, display);

  @override
  String toString() =>
      'ThinkingEnabled(budgetTokens: $budgetTokens, display: $display)';
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

  /// Creates a copy with replaced values.
  ThinkingDisabled copyWith() {
    return const ThinkingDisabled();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingDisabled && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ThinkingDisabled()';
}

/// Enables adaptive thinking where budget is determined by the model.
@immutable
class ThinkingAdaptive extends ThinkingConfig {
  /// Controls how thinking content appears in the response.
  final ThinkingDisplayMode? display;

  /// Creates a [ThinkingAdaptive].
  const ThinkingAdaptive({this.display});

  /// Creates a [ThinkingAdaptive] from JSON.
  factory ThinkingAdaptive.fromJson(Map<String, dynamic> json) {
    return ThinkingAdaptive(
      display: json['display'] != null
          ? ThinkingDisplayMode.fromJson(json['display'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'adaptive',
    if (display != null) 'display': display!.toJson(),
  };

  /// Creates a copy with replaced values.
  ThinkingAdaptive copyWith({Object? display = unsetCopyWithValue}) {
    return ThinkingAdaptive(
      display: display == unsetCopyWithValue
          ? this.display
          : display as ThinkingDisplayMode?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingAdaptive &&
          runtimeType == other.runtimeType &&
          display == other.display;

  @override
  int get hashCode => Object.hash(runtimeType, display);

  @override
  String toString() => 'ThinkingAdaptive(display: $display)';
}
