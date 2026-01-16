import 'package:meta/meta.dart';

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
