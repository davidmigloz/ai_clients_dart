import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// How the model should use the provided tools.
sealed class ToolChoice {
  const ToolChoice();

  /// The model will automatically decide whether to use tools.
  factory ToolChoice.auto({bool? disableParallelToolUse}) = ToolChoiceAuto;

  /// The model will use any available tools.
  factory ToolChoice.any({bool? disableParallelToolUse}) = ToolChoiceAny;

  /// The model will use the specified tool.
  factory ToolChoice.tool(String name, {bool? disableParallelToolUse}) =
      ToolChoiceTool;

  /// The model will not be allowed to use tools.
  factory ToolChoice.none() = ToolChoiceNone;

  /// Creates a [ToolChoice] from JSON.
  factory ToolChoice.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'auto' => ToolChoiceAuto.fromJson(json),
      'any' => ToolChoiceAny.fromJson(json),
      'tool' => ToolChoiceTool.fromJson(json),
      'none' => ToolChoiceNone.fromJson(json),
      _ => throw FormatException('Unknown ToolChoice type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The model will automatically decide whether to use tools.
@immutable
class ToolChoiceAuto extends ToolChoice {
  /// Whether to disable parallel tool use.
  ///
  /// Defaults to false. If true, the model will output at most one tool use.
  final bool? disableParallelToolUse;

  /// Creates a [ToolChoiceAuto].
  const ToolChoiceAuto({this.disableParallelToolUse});

  /// Creates a [ToolChoiceAuto] from JSON.
  factory ToolChoiceAuto.fromJson(Map<String, dynamic> json) {
    return ToolChoiceAuto(
      disableParallelToolUse: json['disable_parallel_tool_use'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'auto',
    if (disableParallelToolUse != null)
      'disable_parallel_tool_use': disableParallelToolUse,
  };

  /// Creates a copy with replaced values.
  ToolChoiceAuto copyWith({
    Object? disableParallelToolUse = unsetCopyWithValue,
  }) {
    return ToolChoiceAuto(
      disableParallelToolUse: disableParallelToolUse == unsetCopyWithValue
          ? this.disableParallelToolUse
          : disableParallelToolUse as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceAuto &&
          runtimeType == other.runtimeType &&
          disableParallelToolUse == other.disableParallelToolUse;

  @override
  int get hashCode => disableParallelToolUse.hashCode;

  @override
  String toString() =>
      'ToolChoiceAuto(disableParallelToolUse: $disableParallelToolUse)';
}

/// The model will use any available tools.
@immutable
class ToolChoiceAny extends ToolChoice {
  /// Whether to disable parallel tool use.
  ///
  /// Defaults to false. If true, the model will output exactly one tool use.
  final bool? disableParallelToolUse;

  /// Creates a [ToolChoiceAny].
  const ToolChoiceAny({this.disableParallelToolUse});

  /// Creates a [ToolChoiceAny] from JSON.
  factory ToolChoiceAny.fromJson(Map<String, dynamic> json) {
    return ToolChoiceAny(
      disableParallelToolUse: json['disable_parallel_tool_use'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'any',
    if (disableParallelToolUse != null)
      'disable_parallel_tool_use': disableParallelToolUse,
  };

  /// Creates a copy with replaced values.
  ToolChoiceAny copyWith({
    Object? disableParallelToolUse = unsetCopyWithValue,
  }) {
    return ToolChoiceAny(
      disableParallelToolUse: disableParallelToolUse == unsetCopyWithValue
          ? this.disableParallelToolUse
          : disableParallelToolUse as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceAny &&
          runtimeType == other.runtimeType &&
          disableParallelToolUse == other.disableParallelToolUse;

  @override
  int get hashCode => disableParallelToolUse.hashCode;

  @override
  String toString() =>
      'ToolChoiceAny(disableParallelToolUse: $disableParallelToolUse)';
}

/// The model will use the specified tool.
@immutable
class ToolChoiceTool extends ToolChoice {
  /// The name of the tool to use.
  final String name;

  /// Whether to disable parallel tool use.
  ///
  /// Defaults to false. If true, the model will output exactly one tool use.
  final bool? disableParallelToolUse;

  /// Creates a [ToolChoiceTool].
  const ToolChoiceTool(this.name, {this.disableParallelToolUse});

  /// Creates a [ToolChoiceTool] from JSON.
  factory ToolChoiceTool.fromJson(Map<String, dynamic> json) {
    return ToolChoiceTool(
      json['name'] as String,
      disableParallelToolUse: json['disable_parallel_tool_use'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool',
    'name': name,
    if (disableParallelToolUse != null)
      'disable_parallel_tool_use': disableParallelToolUse,
  };

  /// Creates a copy with replaced values.
  ToolChoiceTool copyWith({
    String? name,
    Object? disableParallelToolUse = unsetCopyWithValue,
  }) {
    return ToolChoiceTool(
      name ?? this.name,
      disableParallelToolUse: disableParallelToolUse == unsetCopyWithValue
          ? this.disableParallelToolUse
          : disableParallelToolUse as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceTool &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          disableParallelToolUse == other.disableParallelToolUse;

  @override
  int get hashCode => Object.hash(name, disableParallelToolUse);

  @override
  String toString() =>
      'ToolChoiceTool(name: $name, '
      'disableParallelToolUse: $disableParallelToolUse)';
}

/// The model will not be allowed to use tools.
@immutable
class ToolChoiceNone extends ToolChoice {
  /// Creates a [ToolChoiceNone].
  const ToolChoiceNone();

  /// Creates a [ToolChoiceNone] from JSON.
  factory ToolChoiceNone.fromJson(Map<String, dynamic> _) {
    return const ToolChoiceNone();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'none'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceNone && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ToolChoiceNone()';
}
