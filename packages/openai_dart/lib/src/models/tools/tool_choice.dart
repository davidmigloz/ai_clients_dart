import 'package:meta/meta.dart';

/// Controls which tool the model should use.
///
/// Tool choice can be:
/// - [ToolChoiceAuto]: Let the model decide (default)
/// - [ToolChoiceNone]: Disable tool calling
/// - [ToolChoiceRequired]: Force the model to call a tool
/// - [ToolChoiceFunction]: Force a specific function
///
/// ## Example
///
/// ```dart
/// // Let the model decide
/// final auto = ToolChoice.auto();
///
/// // Force specific function
/// final specific = ToolChoice.function('get_weather');
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
      return ToolChoiceFunction.fromJson(json);
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
