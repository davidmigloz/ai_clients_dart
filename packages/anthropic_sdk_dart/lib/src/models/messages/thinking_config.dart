import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Controls how thinking content appears in the response.
enum ThinkingDisplayMode {
  /// Thinking is returned normally (default).
  summarized,

  /// Thinking content is redacted but a signature is returned
  /// for multi-turn continuity.
  omitted,

  /// Requires `anthropic-beta: thinking-display-updates-2026-08-18`.
  ///
  /// Reasoning blocks come back with an empty `thinking` field (like
  /// [omitted]), while the short progress updates the model writes between
  /// tool calls come back as text: any `thinking` block with non-empty text
  /// is a progress update you can show the user. Available on Claude
  /// Fable 5.1, Mythos 5.1, and Fable 5.
  updates;

  /// Creates a [ThinkingDisplayMode] from a JSON string.
  static ThinkingDisplayMode fromJson(String json) => switch (json) {
    'summarized' => ThinkingDisplayMode.summarized,
    'omitted' => ThinkingDisplayMode.omitted,
    'updates' => ThinkingDisplayMode.updates,
    _ => throw FormatException('Unknown ThinkingDisplayMode: $json'),
  };

  /// Converts to a JSON string.
  String toJson() => name;
}

/// What happens when a thinking block in `messages` fails the conversation
/// check: it was created in a different conversation, or the messages
/// before it have changed since.
enum ThinkingPrefixMismatchBehavior {
  /// Fails the request with a 400 error (the default).
  error('error'),

  /// Removes the failing blocks and the request proceeds; the model no
  /// longer sees the dropped reasoning.
  dropBlock('drop_block');

  const ThinkingPrefixMismatchBehavior(this.value);

  /// The wire value for this behavior.
  final String value;

  /// Creates a [ThinkingPrefixMismatchBehavior] from a JSON string.
  static ThinkingPrefixMismatchBehavior fromJson(String json) => switch (json) {
    'error' => ThinkingPrefixMismatchBehavior.error,
    'drop_block' => ThinkingPrefixMismatchBehavior.dropBlock,
    _ => throw FormatException('Unknown ThinkingPrefixMismatchBehavior: $json'),
  };

  /// Converts to a JSON string.
  String toJson() => value;
}

/// Controls for block binding: what happens when a thinking block this
/// request sends back fails the conversation check.
///
/// Every field is optional; an empty object means every default. Requires
/// `anthropic-beta: thinking-binding-controls-2026-08-01`. Sending this
/// without the beta header is a 400 error, and it is not valid together
/// with [ThinkingConfig.disabled].
@immutable
class ThinkingBlockBinding {
  /// What happens when a thinking block in `messages` fails the
  /// conversation check.
  ///
  /// `"error"` (the default) rejects the request with a 400 error when a
  /// replayed thinking block fails the conversation check (e.g. "The block
  /// is bound to a different conversation"). `"drop_block"` drops that
  /// block and every later thinking block, reporting each one in
  /// `Message.inputTransformations`.
  final ThinkingPrefixMismatchBehavior? prefixMismatchBehavior;

  /// Creates a [ThinkingBlockBinding].
  const ThinkingBlockBinding({this.prefixMismatchBehavior});

  /// Creates a [ThinkingBlockBinding] from JSON.
  factory ThinkingBlockBinding.fromJson(Map<String, dynamic> json) {
    return ThinkingBlockBinding(
      prefixMismatchBehavior: json['prefix_mismatch_behavior'] != null
          ? ThinkingPrefixMismatchBehavior.fromJson(
              json['prefix_mismatch_behavior'] as String,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (prefixMismatchBehavior != null)
      'prefix_mismatch_behavior': prefixMismatchBehavior!.toJson(),
  };

  /// Creates a copy with replaced values.
  ThinkingBlockBinding copyWith({
    Object? prefixMismatchBehavior = unsetCopyWithValue,
  }) {
    return ThinkingBlockBinding(
      prefixMismatchBehavior: prefixMismatchBehavior == unsetCopyWithValue
          ? this.prefixMismatchBehavior
          : prefixMismatchBehavior as ThinkingPrefixMismatchBehavior?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingBlockBinding &&
          runtimeType == other.runtimeType &&
          prefixMismatchBehavior == other.prefixMismatchBehavior;

  @override
  int get hashCode => prefixMismatchBehavior.hashCode;

  @override
  String toString() =>
      'ThinkingBlockBinding(prefixMismatchBehavior: $prefixMismatchBehavior)';
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
    ThinkingBlockBinding? blockBinding,
  }) = ThinkingEnabled;

  /// Disables extended thinking.
  factory ThinkingConfig.disabled() = ThinkingDisabled;

  /// Enables adaptive thinking mode.
  ///
  /// In adaptive mode, the model automatically determines the thinking budget.
  factory ThinkingConfig.adaptive({
    ThinkingDisplayMode? display,
    ThinkingBlockBinding? blockBinding,
  }) = ThinkingAdaptive;

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

  /// Controls for block binding on replayed thinking blocks.
  ///
  /// Requires `anthropic-beta: thinking-binding-controls-2026-08-01`.
  final ThinkingBlockBinding? blockBinding;

  /// Creates a [ThinkingEnabled].
  const ThinkingEnabled({
    required this.budgetTokens,
    this.display,
    this.blockBinding,
  });

  /// Creates a [ThinkingEnabled] from JSON.
  factory ThinkingEnabled.fromJson(Map<String, dynamic> json) {
    return ThinkingEnabled(
      budgetTokens: json['budget_tokens'] as int,
      display: json['display'] != null
          ? ThinkingDisplayMode.fromJson(json['display'] as String)
          : null,
      blockBinding: json['block_binding'] != null
          ? ThinkingBlockBinding.fromJson(
              json['block_binding'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'enabled',
    'budget_tokens': budgetTokens,
    if (display != null) 'display': display!.toJson(),
    if (blockBinding != null) 'block_binding': blockBinding!.toJson(),
  };

  /// Creates a copy with replaced values.
  ThinkingEnabled copyWith({
    int? budgetTokens,
    Object? display = unsetCopyWithValue,
    Object? blockBinding = unsetCopyWithValue,
  }) {
    return ThinkingEnabled(
      budgetTokens: budgetTokens ?? this.budgetTokens,
      display: display == unsetCopyWithValue
          ? this.display
          : display as ThinkingDisplayMode?,
      blockBinding: blockBinding == unsetCopyWithValue
          ? this.blockBinding
          : blockBinding as ThinkingBlockBinding?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingEnabled &&
          runtimeType == other.runtimeType &&
          budgetTokens == other.budgetTokens &&
          display == other.display &&
          blockBinding == other.blockBinding;

  @override
  int get hashCode => Object.hash(budgetTokens, display, blockBinding);

  @override
  String toString() =>
      'ThinkingEnabled(budgetTokens: $budgetTokens, display: $display, '
      'blockBinding: $blockBinding)';
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

  /// Controls for block binding on replayed thinking blocks.
  ///
  /// Requires `anthropic-beta: thinking-binding-controls-2026-08-01`.
  final ThinkingBlockBinding? blockBinding;

  /// Creates a [ThinkingAdaptive].
  const ThinkingAdaptive({this.display, this.blockBinding});

  /// Creates a [ThinkingAdaptive] from JSON.
  factory ThinkingAdaptive.fromJson(Map<String, dynamic> json) {
    return ThinkingAdaptive(
      display: json['display'] != null
          ? ThinkingDisplayMode.fromJson(json['display'] as String)
          : null,
      blockBinding: json['block_binding'] != null
          ? ThinkingBlockBinding.fromJson(
              json['block_binding'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'adaptive',
    if (display != null) 'display': display!.toJson(),
    if (blockBinding != null) 'block_binding': blockBinding!.toJson(),
  };

  /// Creates a copy with replaced values.
  ThinkingAdaptive copyWith({
    Object? display = unsetCopyWithValue,
    Object? blockBinding = unsetCopyWithValue,
  }) {
    return ThinkingAdaptive(
      display: display == unsetCopyWithValue
          ? this.display
          : display as ThinkingDisplayMode?,
      blockBinding: blockBinding == unsetCopyWithValue
          ? this.blockBinding
          : blockBinding as ThinkingBlockBinding?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingAdaptive &&
          runtimeType == other.runtimeType &&
          display == other.display &&
          blockBinding == other.blockBinding;

  @override
  int get hashCode => Object.hash(runtimeType, display, blockBinding);

  @override
  String toString() =>
      'ThinkingAdaptive(display: $display, blockBinding: $blockBinding)';
}
