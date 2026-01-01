import 'package:meta/meta.dart';

/// Sealed class for tool choice options.
///
/// Controls how the model should use the provided tools.
sealed class ToolChoice {
  const ToolChoice();

  /// Creates a [ToolChoice] from JSON.
  ///
  /// Can handle both string values ("none", "auto", "any", "required")
  /// and object values ({"type": "function", "function": {"name": "..."}}).
  factory ToolChoice.fromJson(Object json) {
    if (json is String) {
      return switch (json) {
        'none' => const ToolChoiceNone(),
        'auto' => const ToolChoiceAuto(),
        'any' => const ToolChoiceAny(),
        'required' => const ToolChoiceRequired(),
        _ => throw FormatException('Unknown tool_choice: $json'),
      };
    }
    if (json is Map<String, dynamic>) {
      return ToolChoiceFunction.fromJson(json);
    }
    throw FormatException('Invalid tool_choice type: ${json.runtimeType}');
  }

  /// Converts to JSON.
  Object toJson();

  /// No tools should be used.
  static const none = ToolChoiceNone();

  /// Model decides whether to use tools.
  static const auto = ToolChoiceAuto();

  /// Model must use at least one tool.
  static const any = ToolChoiceAny();

  /// Model must use a tool (same as 'any').
  static const required = ToolChoiceRequired();

  /// Model must use a specific function.
  static ToolChoiceFunction function(String name) =>
      ToolChoiceFunction(name: name);
}

/// No tools should be used.
@immutable
class ToolChoiceNone extends ToolChoice {
  /// Creates a [ToolChoiceNone].
  const ToolChoiceNone();

  @override
  Object toJson() => 'none';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceNone && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'none'.hashCode;

  @override
  String toString() => 'ToolChoiceNone()';
}

/// Model decides whether to use tools.
@immutable
class ToolChoiceAuto extends ToolChoice {
  /// Creates a [ToolChoiceAuto].
  const ToolChoiceAuto();

  @override
  Object toJson() => 'auto';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceAuto && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'auto'.hashCode;

  @override
  String toString() => 'ToolChoiceAuto()';
}

/// Model must use at least one tool.
@immutable
class ToolChoiceAny extends ToolChoice {
  /// Creates a [ToolChoiceAny].
  const ToolChoiceAny();

  @override
  Object toJson() => 'any';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceAny && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'any'.hashCode;

  @override
  String toString() => 'ToolChoiceAny()';
}

/// Model must use a tool (same as 'any').
@immutable
class ToolChoiceRequired extends ToolChoice {
  /// Creates a [ToolChoiceRequired].
  const ToolChoiceRequired();

  @override
  Object toJson() => 'required';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceRequired && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'required'.hashCode;

  @override
  String toString() => 'ToolChoiceRequired()';
}

/// Model must use a specific function.
@immutable
class ToolChoiceFunction extends ToolChoice {
  /// The name of the function to call.
  final String name;

  /// Creates a [ToolChoiceFunction].
  const ToolChoiceFunction({required this.name});

  /// Creates a [ToolChoiceFunction] from JSON.
  factory ToolChoiceFunction.fromJson(Map<String, dynamic> json) {
    final function = json['function'] as Map<String, dynamic>?;
    return ToolChoiceFunction(
      name: function?['name'] as String? ?? json['name'] as String? ?? '',
    );
  }

  @override
  Object toJson() => {
    'type': 'function',
    'function': {'name': name},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceFunction &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ToolChoiceFunction(name: $name)';
}
