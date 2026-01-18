import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Tool choice mode for allowed tools.
enum ToolChoiceMode {
  /// No tool should be called.
  none('none'),

  /// Model automatically decides whether to call tools.
  auto('auto'),

  /// Model must call at least one tool.
  required('required');

  /// The JSON value for this mode.
  final String value;

  const ToolChoiceMode(this.value);

  /// Creates a [ToolChoiceMode] from a JSON value.
  factory ToolChoiceMode.fromJson(String json) {
    return ToolChoiceMode.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw FormatException('Unknown ToolChoiceMode: $json'),
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}

/// A specific tool that can be selected.
sealed class SpecificToolChoice {
  /// Creates a [SpecificToolChoice].
  const SpecificToolChoice();

  /// Creates a [SpecificToolChoice] from JSON.
  factory SpecificToolChoice.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'function' => SpecificFunctionChoice.fromJson(json),
      _ => throw FormatException('Unknown SpecificToolChoice type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A specific function that can be selected.
@immutable
class SpecificFunctionChoice extends SpecificToolChoice {
  /// The name of the function.
  final String name;

  /// Creates a [SpecificFunctionChoice].
  const SpecificFunctionChoice({required this.name});

  /// Creates a [SpecificFunctionChoice] from JSON.
  factory SpecificFunctionChoice.fromJson(Map<String, dynamic> json) {
    return SpecificFunctionChoice(name: json['name'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'function', 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecificFunctionChoice &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'SpecificFunctionChoice(name: $name)';
}

/// Tool choice specification.
///
/// Controls how the model selects which tools to use.
sealed class ToolChoice {
  /// Creates a [ToolChoice].
  const ToolChoice();

  /// Creates a [ToolChoice] from JSON.
  factory ToolChoice.fromJson(Object json) {
    if (json is String) {
      return switch (json) {
        'none' => const ToolChoiceNone(),
        'auto' => const ToolChoiceAuto(),
        'required' => const ToolChoiceRequired(),
        _ => throw FormatException('Unknown ToolChoice string: $json'),
      };
    }

    if (json is Map<String, dynamic>) {
      final type = json['type'] as String;
      return switch (type) {
        'function' => ToolChoiceFunction.fromJson(json),
        'allowed_tools' => ToolChoiceAllowedTools.fromJson(json),
        _ => throw FormatException('Unknown ToolChoice type: $type'),
      };
    }

    throw FormatException('Invalid ToolChoice format: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// No tool should be called.
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
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ToolChoiceNone()';
}

/// Model automatically decides whether to call tools.
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
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ToolChoiceAuto()';
}

/// Model must call at least one tool.
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
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ToolChoiceRequired()';
}

/// Model must call the specified function.
@immutable
class ToolChoiceFunction extends ToolChoice {
  /// The name of the function to call.
  final String name;

  /// Creates a [ToolChoiceFunction].
  const ToolChoiceFunction({required this.name});

  /// Creates a [ToolChoiceFunction] from JSON.
  factory ToolChoiceFunction.fromJson(Map<String, dynamic> json) {
    return ToolChoiceFunction(name: json['name'] as String);
  }

  @override
  Object toJson() => {'type': 'function', 'name': name};

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

/// Model can only call the specified tools.
///
/// This allows specifying a list of allowed tools (1-128) and an optional mode.
@immutable
class ToolChoiceAllowedTools extends ToolChoice {
  /// The list of allowed tools.
  final List<SpecificToolChoice> tools;

  /// The tool choice mode.
  final ToolChoiceMode? mode;

  /// Creates a [ToolChoiceAllowedTools].
  const ToolChoiceAllowedTools({required this.tools, this.mode});

  /// Creates a [ToolChoiceAllowedTools] from JSON.
  factory ToolChoiceAllowedTools.fromJson(Map<String, dynamic> json) {
    return ToolChoiceAllowedTools(
      tools: (json['tools'] as List)
          .map((e) => SpecificToolChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      mode: json['mode'] != null
          ? ToolChoiceMode.fromJson(json['mode'] as String)
          : null,
    );
  }

  @override
  Object toJson() => {
    'type': 'allowed_tools',
    'tools': tools.map((e) => e.toJson()).toList(),
    if (mode != null) 'mode': mode!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceAllowedTools &&
          runtimeType == other.runtimeType &&
          listsEqual(tools, other.tools) &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(Object.hashAll(tools), mode);

  @override
  String toString() => 'ToolChoiceAllowedTools(tools: $tools, mode: $mode)';
}
