import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Controls which tool the model should use.
///
/// Tool choice can be:
/// - [ToolChoiceAuto]: Let the model decide (default)
/// - [ToolChoiceNone]: Disable tool calling
/// - [ToolChoiceRequired]: Force the model to call a tool
/// - [ToolChoiceFunction]: Force a specific function
/// - [ToolChoiceAllowedTools]: Constrain to a set of allowed tools
/// - [ToolChoiceCustom]: Force a specific custom tool
///
/// ## Example
///
/// ```dart
/// // Let the model decide
/// final auto = ToolChoice.auto();
///
/// // Force specific function
/// final specific = ToolChoice.function('get_weather');
///
/// // Constrain to allowed tools
/// final allowed = ToolChoice.allowedTools(
///   mode: 'auto',
///   tools: [
///     {'type': 'function', 'function': {'name': 'get_weather'}},
///   ],
/// );
///
/// // Force specific custom tool
/// final custom = ToolChoice.custom('my_custom_tool');
/// ```
@immutable
sealed class ToolChoice {
  const ToolChoice();

  /// Creates a [ToolChoice] from JSON.
  factory ToolChoice.fromJson(Object? json) {
    if (json is String) {
      return switch (json) {
        'auto' => const ToolChoiceAuto(),
        'none' => const ToolChoiceNone(),
        'required' => const ToolChoiceRequired(),
        _ => throw FormatException('Unknown tool choice: $json'),
      };
    }
    if (json is Map<String, dynamic>) {
      final type = json['type'] as String?;
      return switch (type) {
        'function' || null => ToolChoiceFunction.fromJson(json),
        'allowed_tools' => ToolChoiceAllowedTools.fromJson(json),
        'custom' => ToolChoiceCustom.fromJson(json),
        _ => throw FormatException('Unknown tool choice type: $type'),
      };
    }
    throw FormatException('Invalid tool choice: $json');
  }

  /// Let the model decide whether to call a tool.
  static ToolChoice auto() => const ToolChoiceAuto();

  /// Disable tool calling.
  static ToolChoice none() => const ToolChoiceNone();

  /// Force the model to call a tool.
  static ToolChoice required() => const ToolChoiceRequired();

  /// Force the model to call a specific function.
  static ToolChoice function(String name) => ToolChoiceFunction(name: name);

  /// Constrain the model to a set of allowed tools.
  static ToolChoice allowedTools({
    required String mode,
    required List<Map<String, dynamic>> tools,
  }) => ToolChoiceAllowedTools(mode: mode, tools: tools);

  /// Force the model to call a specific custom tool.
  static ToolChoice custom(String name) => ToolChoiceCustom(name: name);

  /// Converts to JSON.
  Object toJson();
}

/// Let the model decide whether to call a tool.
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
  String toString() => 'ToolChoice.auto()';
}

/// Disable tool calling.
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
  String toString() => 'ToolChoice.none()';
}

/// Force the model to call a tool.
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
  String toString() => 'ToolChoice.required()';
}

/// Force the model to call a specific function.
@immutable
class ToolChoiceFunction extends ToolChoice {
  /// Creates a [ToolChoiceFunction].
  const ToolChoiceFunction({required this.name});

  /// Creates a [ToolChoiceFunction] from JSON.
  factory ToolChoiceFunction.fromJson(Map<String, dynamic> json) {
    final function = json['function'] as Map<String, dynamic>;
    return ToolChoiceFunction(name: function['name'] as String);
  }

  /// The name of the function to call.
  final String name;

  /// Creates a copy with the given fields replaced.
  ToolChoiceFunction copyWith({String? name}) {
    return ToolChoiceFunction(name: name ?? this.name);
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
  String toString() => 'ToolChoice.function($name)';
}

/// Constrain the model to a set of allowed tools.
///
/// This allows specifying which tools the model can call and a mode
/// (`"auto"` or `"required"`) controlling whether it must call one.
@immutable
class ToolChoiceAllowedTools extends ToolChoice {
  /// Creates a [ToolChoiceAllowedTools].
  const ToolChoiceAllowedTools({required this.mode, required this.tools});

  /// Creates a [ToolChoiceAllowedTools] from JSON.
  factory ToolChoiceAllowedTools.fromJson(Map<String, dynamic> json) {
    final allowedTools = json['allowed_tools'] as Map<String, dynamic>;
    return ToolChoiceAllowedTools(
      mode: allowedTools['mode'] as String,
      tools: (allowedTools['tools'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  /// The constraint mode: `"auto"` or `"required"`.
  final String mode;

  /// The list of tools the model is allowed to call.
  final List<Map<String, dynamic>> tools;

  /// Creates a copy with the given fields replaced.
  ToolChoiceAllowedTools copyWith({
    String? mode,
    List<Map<String, dynamic>>? tools,
  }) {
    return ToolChoiceAllowedTools(
      mode: mode ?? this.mode,
      tools: tools ?? this.tools,
    );
  }

  @override
  Object toJson() => {
    'type': 'allowed_tools',
    'allowed_tools': {'mode': mode, 'tools': tools},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceAllowedTools &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          listOfMapsDeepEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(mode, listOfMapsHashCode(tools));

  @override
  String toString() =>
      'ToolChoice.allowedTools(mode: $mode, tools: [${tools.length} tools])';
}

/// Force the model to call a specific custom tool.
@immutable
class ToolChoiceCustom extends ToolChoice {
  /// Creates a [ToolChoiceCustom].
  const ToolChoiceCustom({required this.name});

  /// Creates a [ToolChoiceCustom] from JSON.
  factory ToolChoiceCustom.fromJson(Map<String, dynamic> json) {
    final custom = json['custom'] as Map<String, dynamic>;
    return ToolChoiceCustom(name: custom['name'] as String);
  }

  /// The name of the custom tool to call.
  final String name;

  /// Creates a copy with the given fields replaced.
  ToolChoiceCustom copyWith({String? name}) {
    return ToolChoiceCustom(name: name ?? this.name);
  }

  @override
  Object toJson() => {
    'type': 'custom',
    'custom': {'name': name},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChoiceCustom &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ToolChoice.custom($name)';
}
