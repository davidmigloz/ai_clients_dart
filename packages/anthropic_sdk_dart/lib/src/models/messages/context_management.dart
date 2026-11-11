import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Configures beta context edits or threshold compaction for a request.
///
/// Use `context-management-2025-06-27` for context editing, or
/// `compact-2026-01-12` for threshold compaction. On-demand compaction
/// uses a different request parameter.
@immutable
class ContextManagementConfig {
  /// Edits to apply, in order.
  final List<ContextManagementEdit>? edits;

  /// Creates a context management configuration.
  const ContextManagementConfig({this.edits});

  /// Creates a [ContextManagementConfig] from JSON.
  factory ContextManagementConfig.fromJson(Map<String, dynamic> json) {
    final edits = (json['edits'] as List?)?.cast<Map<String, dynamic>>();
    return ContextManagementConfig(
      edits: edits == null
          ? null
          : List.unmodifiable(edits.map(ContextManagementEdit.fromJson)),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (edits != null) 'edits': [for (final edit in edits!) edit.toJson()],
  };

  /// Creates a copy with replaced values.
  ContextManagementConfig copyWith({Object? edits = unsetCopyWithValue}) =>
      ContextManagementConfig(
        edits: edits == unsetCopyWithValue
            ? this.edits
            : edits as List<ContextManagementEdit>?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextManagementConfig && listsEqual(edits, other.edits);

  @override
  int get hashCode => listHash(edits);

  @override
  String toString() => 'ContextManagementConfig(edits: $edits)';
}

/// A context edit requested on Messages or beta token counting.
@immutable
sealed class ContextManagementEdit {
  const ContextManagementEdit();

  /// Clears earlier tool uses according to the supplied limits.
  const factory ContextManagementEdit.clearToolUses({
    ContextEditTrigger? trigger,
    int? keepToolUses,
    int? minimumClearedInputTokens,
    List<String>? excludeTools,
    ClearToolInputs? clearToolInputs,
  }) = ClearToolUsesEdit;

  /// Clears thinking blocks from older assistant turns.
  const factory ContextManagementEdit.clearThinking({
    ThinkingTurnsToKeep? keep,
  }) = ClearThinkingEdit;

  /// Summarizes the conversation when the input reaches a token threshold.
  const factory ContextManagementEdit.thresholdCompaction({
    int? triggerInputTokens,
    bool? pauseAfterCompaction,
    String? instructions,
  }) = ThresholdCompactionEdit;

  /// Creates a context edit from JSON.
  factory ContextManagementEdit.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'clear_tool_uses_20250919' => ClearToolUsesEdit.fromJson(json),
        'clear_thinking_20251015' => ClearThinkingEdit.fromJson(json),
        'compact_20260112' => ThresholdCompactionEdit.fromJson(json),
        final String _ => UnknownContextManagementEdit(raw: json),
        _ => throw const FormatException('Context edit requires a string type'),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextManagementEdit &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());
}

/// Threshold for clearing tool uses.
@immutable
class ContextEditTrigger {
  /// Metric evaluated by the server.
  final String type;

  /// Threshold value.
  final int value;

  /// Triggers at the given number of input tokens.
  const ContextEditTrigger.inputTokens(this.value)
    : type = 'input_tokens',
      assert(value >= 1);

  /// Triggers at the given number of tool uses.
  const ContextEditTrigger.toolUses(this.value)
    : type = 'tool_uses',
      assert(value >= 1);

  /// Creates a [ContextEditTrigger] from JSON.
  factory ContextEditTrigger.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'type': 'input_tokens', 'value': final int value} when value >= 1 =>
        ContextEditTrigger.inputTokens(value),
      {'type': 'tool_uses', 'value': final int value} when value >= 1 =>
        ContextEditTrigger.toolUses(value),
      _ => throw const FormatException('Invalid context edit trigger'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextEditTrigger && type == other.type && value == other.value;

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => 'ContextEditTrigger(type: $type, value: $value)';
}

/// Selects which tool inputs to clear alongside tool results.
@immutable
class ClearToolInputs {
  final bool? _all;
  final List<String>? _tools;

  /// Sets whether all tool inputs are cleared.
  const ClearToolInputs.all({bool enabled = true})
    : _all = enabled,
      _tools = null;

  /// Clears inputs for these named tools.
  const ClearToolInputs.only(List<String> names) : _all = null, _tools = names;

  /// Creates a [ClearToolInputs] from its JSON boolean or string list.
  factory ClearToolInputs.fromJson(Object json) => switch (json) {
    final bool value => ClearToolInputs.all(enabled: value),
    final List<Object?> tools => ClearToolInputs.only(
      List.unmodifiable(tools.cast<String>()),
    ),
    _ => throw const FormatException('Expected a boolean or tool name list'),
  };

  /// Converts to JSON.
  Object toJson() => _all ?? _tools!;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClearToolInputs &&
          _all == other._all &&
          listsEqual(_tools, other._tools);

  @override
  int get hashCode => Object.hash(_all, listHash(_tools));

  @override
  String toString() => 'ClearToolInputs(${toJson()})';
}

/// Number of recent assistant turns whose thinking blocks stay in context.
@immutable
class ThinkingTurnsToKeep {
  /// Number of assistant turns to retain, or null to retain all.
  final int? turns;
  final bool _objectForm;

  /// Keeps every thinking turn. Serializes as the string `all`.
  const ThinkingTurnsToKeep.all() : turns = null, _objectForm = false;

  /// Keeps every thinking turn using the object form.
  const ThinkingTurnsToKeep.allObject() : turns = null, _objectForm = true;

  /// Keeps the given number of recent assistant turns.
  const ThinkingTurnsToKeep.recent(int this.turns)
    : _objectForm = true,
      assert(turns >= 1);

  /// Creates a [ThinkingTurnsToKeep] from JSON.
  factory ThinkingTurnsToKeep.fromJson(Object json) => switch (json) {
    'all' => const ThinkingTurnsToKeep.all(),
    {'type': 'all'} => const ThinkingTurnsToKeep.allObject(),
    {'type': 'thinking_turns', 'value': final int value} when value >= 1 =>
      ThinkingTurnsToKeep.recent(value),
    _ => throw const FormatException('Invalid thinking turn retention setting'),
  };

  /// Converts to JSON.
  Object toJson() {
    final turns = this.turns;
    if (turns != null) return {'type': 'thinking_turns', 'value': turns};
    return _objectForm ? {'type': 'all'} : 'all';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingTurnsToKeep &&
          turns == other.turns &&
          _objectForm == other._objectForm;

  @override
  int get hashCode => Object.hash(turns, _objectForm);

  @override
  String toString() => 'ThinkingTurnsToKeep(${toJson()})';
}

/// Clears tool results and optionally their inputs (beta).
@immutable
class ClearToolUsesEdit extends ContextManagementEdit {
  /// Condition that triggers this edit.
  final ContextEditTrigger? trigger;

  /// Number of recent tool uses to retain.
  final int? keepToolUses;

  /// Apply the edit only when at least this many tokens can be cleared.
  final int? minimumClearedInputTokens;

  /// Names of tools whose uses are preserved.
  final List<String>? excludeTools;

  /// Tool inputs to clear alongside results.
  final ClearToolInputs? clearToolInputs;

  /// Creates a [ClearToolUsesEdit].
  const ClearToolUsesEdit({
    this.trigger,
    this.keepToolUses,
    this.minimumClearedInputTokens,
    this.excludeTools,
    this.clearToolInputs,
  }) : assert(keepToolUses == null || keepToolUses >= 0),
       assert(
         minimumClearedInputTokens == null || minimumClearedInputTokens >= 0,
       );

  /// Creates a [ClearToolUsesEdit] from JSON.
  factory ClearToolUsesEdit.fromJson(Map<String, dynamic> json) {
    _requireType(json, 'clear_tool_uses_20250919');
    final trigger = json['trigger'] as Map<String, dynamic>?;
    final clearInputs = json['clear_tool_inputs'];
    return ClearToolUsesEdit(
      trigger: trigger == null ? null : ContextEditTrigger.fromJson(trigger),
      keepToolUses: _limitValue(json['keep'], 'tool_uses', 0),
      minimumClearedInputTokens: _limitValue(
        json['clear_at_least'],
        'input_tokens',
        0,
      ),
      excludeTools: (json['exclude_tools'] as List?)?.cast<String>(),
      clearToolInputs: clearInputs == null
          ? null
          : ClearToolInputs.fromJson(clearInputs),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'clear_tool_uses_20250919',
    'trigger': ?trigger?.toJson(),
    if (keepToolUses != null)
      'keep': {'type': 'tool_uses', 'value': keepToolUses},
    if (minimumClearedInputTokens != null)
      'clear_at_least': {
        'type': 'input_tokens',
        'value': minimumClearedInputTokens,
      },
    'exclude_tools': ?excludeTools,
    'clear_tool_inputs': ?clearToolInputs?.toJson(),
  };

  @override
  String toString() => 'ClearToolUsesEdit(${toJson()})';
}

/// Clears earlier assistant thinking blocks (beta).
@immutable
class ClearThinkingEdit extends ContextManagementEdit {
  /// Which recent assistant turns retain their thinking blocks.
  final ThinkingTurnsToKeep? keep;

  /// Creates a [ClearThinkingEdit].
  const ClearThinkingEdit({this.keep});

  /// Creates a [ClearThinkingEdit] from JSON.
  factory ClearThinkingEdit.fromJson(Map<String, dynamic> json) {
    _requireType(json, 'clear_thinking_20251015');
    final keep = json['keep'];
    return ClearThinkingEdit(
      keep: keep == null ? null : ThinkingTurnsToKeep.fromJson(keep),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'clear_thinking_20251015',
    'keep': ?keep?.toJson(),
  };

  @override
  String toString() => 'ClearThinkingEdit(keep: $keep)';
}

/// Server-side threshold compaction (beta).
@immutable
class ThresholdCompactionEdit extends ContextManagementEdit {
  /// Number of input tokens at which compaction triggers.
  final int? triggerInputTokens;

  /// Whether to return immediately after compaction.
  final bool? pauseAfterCompaction;

  /// Summarization instructions.
  final String? instructions;

  /// Creates a [ThresholdCompactionEdit].
  const ThresholdCompactionEdit({
    this.triggerInputTokens,
    this.pauseAfterCompaction,
    this.instructions,
  }) : assert(triggerInputTokens == null || triggerInputTokens >= 1);

  /// Creates a [ThresholdCompactionEdit] from JSON.
  factory ThresholdCompactionEdit.fromJson(Map<String, dynamic> json) {
    _requireType(json, 'compact_20260112');
    return ThresholdCompactionEdit(
      triggerInputTokens: _limitValue(json['trigger'], 'input_tokens', 1),
      pauseAfterCompaction: json['pause_after_compaction'] as bool?,
      instructions: json['instructions'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compact_20260112',
    if (triggerInputTokens != null)
      'trigger': {'type': 'input_tokens', 'value': triggerInputTokens},
    'pause_after_compaction': ?pauseAfterCompaction,
    'instructions': ?instructions,
  };

  @override
  String toString() =>
      'ThresholdCompactionEdit(triggerInputTokens: $triggerInputTokens, '
      'pauseAfterCompaction: $pauseAfterCompaction, '
      'hasInstructions: ${instructions != null})';
}

/// A context management edit introduced by the server.
@immutable
class UnknownContextManagementEdit extends ContextManagementEdit {
  /// Original provider JSON.
  final Map<String, dynamic> raw;

  /// Creates an edit that retains the original payload.
  UnknownContextManagementEdit({required Map<String, dynamic> raw})
    : raw = deepUnmodifiableMap(raw);

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  String toString() => 'UnknownContextManagementEdit(type: ${raw['type']})';
}

/// Context editing results returned on Messages.
@immutable
class ContextManagementResult {
  /// Edits the server applied.
  final List<AppliedContextEdit> appliedEdits;

  /// Creates a [ContextManagementResult].
  const ContextManagementResult({required this.appliedEdits});

  /// Creates a [ContextManagementResult] from JSON.
  factory ContextManagementResult.fromJson(Map<String, dynamic> json) {
    final edits = json['applied_edits'];
    if (edits is! List) {
      throw const FormatException(
        'Context management result requires applied_edits',
      );
    }
    return ContextManagementResult(
      appliedEdits: List.unmodifiable(
        edits.cast<Map<String, dynamic>>().map(AppliedContextEdit.fromJson),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'applied_edits': [for (final edit in appliedEdits) edit.toJson()],
  };

  /// Creates a copy with replaced values.
  ContextManagementResult copyWith({List<AppliedContextEdit>? appliedEdits}) =>
      ContextManagementResult(appliedEdits: appliedEdits ?? this.appliedEdits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextManagementResult &&
          listsEqual(appliedEdits, other.appliedEdits);

  @override
  int get hashCode => listHash(appliedEdits);

  @override
  String toString() => 'ContextManagementResult(appliedEdits: $appliedEdits)';
}

/// A context edit applied by the server.
@immutable
sealed class AppliedContextEdit {
  const AppliedContextEdit();

  /// Creates an [AppliedContextEdit] from JSON.
  factory AppliedContextEdit.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'clear_tool_uses_20250919' => ClearedToolUsesEdit(
          clearedInputTokens: _requiredCount(json, 'cleared_input_tokens'),
          clearedToolUses: _requiredCount(json, 'cleared_tool_uses'),
        ),
        'clear_thinking_20251015' => ClearedThinkingEdit(
          clearedInputTokens: _requiredCount(json, 'cleared_input_tokens'),
          clearedThinkingTurns: _requiredCount(json, 'cleared_thinking_turns'),
        ),
        final String _ => UnknownAppliedContextEdit(raw: json),
        _ => throw const FormatException(
          'Applied context edit requires a string type',
        ),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppliedContextEdit &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());
}

/// Counts of tool uses and tokens cleared by a context edit.
@immutable
class ClearedToolUsesEdit extends AppliedContextEdit {
  /// Number of input tokens cleared.
  final int clearedInputTokens;

  /// Number of tool uses cleared.
  final int clearedToolUses;

  /// Creates a [ClearedToolUsesEdit].
  const ClearedToolUsesEdit({
    required this.clearedInputTokens,
    required this.clearedToolUses,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': 'clear_tool_uses_20250919',
    'cleared_input_tokens': clearedInputTokens,
    'cleared_tool_uses': clearedToolUses,
  };

  @override
  String toString() => 'ClearedToolUsesEdit(${toJson()})';
}

/// Counts of thinking turns and tokens cleared by a context edit.
@immutable
class ClearedThinkingEdit extends AppliedContextEdit {
  /// Number of input tokens cleared.
  final int clearedInputTokens;

  /// Number of assistant thinking turns cleared.
  final int clearedThinkingTurns;

  /// Creates a [ClearedThinkingEdit].
  const ClearedThinkingEdit({
    required this.clearedInputTokens,
    required this.clearedThinkingTurns,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': 'clear_thinking_20251015',
    'cleared_input_tokens': clearedInputTokens,
    'cleared_thinking_turns': clearedThinkingTurns,
  };

  @override
  String toString() => 'ClearedThinkingEdit(${toJson()})';
}

/// An unrecognized applied context edit.
@immutable
class UnknownAppliedContextEdit extends AppliedContextEdit {
  /// Original provider JSON.
  final Map<String, dynamic> raw;

  /// Creates an edit that retains the original payload.
  UnknownAppliedContextEdit({required Map<String, dynamic> raw})
    : raw = deepUnmodifiableMap(raw);

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  String toString() => 'UnknownAppliedContextEdit(type: ${raw['type']})';
}

/// Information about context management returned by beta token counting.
@immutable
class TokenCountContextManagement {
  /// Input tokens before context edits were applied.
  final int originalInputTokens;

  /// Creates a [TokenCountContextManagement].
  const TokenCountContextManagement({required this.originalInputTokens});

  /// Creates a [TokenCountContextManagement] from JSON.
  factory TokenCountContextManagement.fromJson(Map<String, dynamic> json) =>
      TokenCountContextManagement(
        originalInputTokens: _requiredCount(json, 'original_input_tokens'),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'original_input_tokens': originalInputTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenCountContextManagement &&
          originalInputTokens == other.originalInputTokens;

  @override
  int get hashCode => originalInputTokens.hashCode;

  @override
  String toString() =>
      'TokenCountContextManagement(originalInputTokens: $originalInputTokens)';
}

void _requireType(Map<String, dynamic> json, String type) {
  if (json['type'] != type) {
    throw FormatException('Expected context edit "$type"');
  }
}

int? _limitValue(Object? json, String type, int minimum) {
  return switch (json) {
    null => null,
    {'type': final String wireType, 'value': final int value}
        when wireType == type && value >= minimum =>
      value,
    _ => throw FormatException('Expected $type threshold of at least $minimum'),
  };
}

int _requiredCount(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is int && value >= 0) return value;
  throw FormatException('Context management requires a nonnegative "$field"');
}
