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
sealed class ResponseToolChoice {
  /// Creates a [ResponseToolChoice].
  const ResponseToolChoice();

  /// Creates a [ResponseToolChoice] from JSON.
  factory ResponseToolChoice.fromJson(Object json) {
    if (json is String) {
      return switch (json) {
        'none' => const ResponseToolChoiceNone(),
        'auto' => const ResponseToolChoiceAuto(),
        'required' => const ResponseToolChoiceRequired(),
        _ => throw FormatException('Unknown ResponseToolChoice string: $json'),
      };
    }

    if (json is Map<String, dynamic>) {
      final type = json['type'] as String;
      return switch (type) {
        'function' => ResponseToolChoiceFunction.fromJson(json),
        'allowed_tools' => ResponseToolChoiceAllowedTools.fromJson(json),
        _ => throw FormatException('Unknown ResponseToolChoice type: $type'),
      };
    }

    throw FormatException('Invalid ResponseToolChoice format: $json');
  }

  /// Creates a "none" choice - no tools should be called.
  static const ResponseToolChoiceNone none = ResponseToolChoiceNone();

  /// Creates an "auto" choice - model decides whether to call tools.
  static const ResponseToolChoiceAuto auto = ResponseToolChoiceAuto();

  /// Creates a "required" choice - model must call at least one tool.
  static const ResponseToolChoiceRequired required =
      ResponseToolChoiceRequired();

  /// Creates a function choice - model must call the specified function.
  static ResponseToolChoiceFunction function({required String name}) =>
      ResponseToolChoiceFunction(name: name);

  /// Converts to JSON.
  Object toJson();
}

/// No tool should be called.
@immutable
class ResponseToolChoiceNone extends ResponseToolChoice {
  /// Creates a [ResponseToolChoiceNone].
  const ResponseToolChoiceNone();

  @override
  Object toJson() => 'none';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseToolChoiceNone && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ResponseToolChoiceNone()';
}

/// Model automatically decides whether to call tools.
@immutable
class ResponseToolChoiceAuto extends ResponseToolChoice {
  /// Creates a [ResponseToolChoiceAuto].
  const ResponseToolChoiceAuto();

  @override
  Object toJson() => 'auto';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseToolChoiceAuto && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ResponseToolChoiceAuto()';
}

/// Model must call at least one tool.
@immutable
class ResponseToolChoiceRequired extends ResponseToolChoice {
  /// Creates a [ResponseToolChoiceRequired].
  const ResponseToolChoiceRequired();

  @override
  Object toJson() => 'required';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseToolChoiceRequired && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ResponseToolChoiceRequired()';
}

/// Model must call the specified function.
@immutable
class ResponseToolChoiceFunction extends ResponseToolChoice {
  /// The name of the function to call.
  final String name;

  /// Creates a [ResponseToolChoiceFunction].
  const ResponseToolChoiceFunction({required this.name});

  /// Creates a [ResponseToolChoiceFunction] from JSON.
  factory ResponseToolChoiceFunction.fromJson(Map<String, dynamic> json) {
    return ResponseToolChoiceFunction(name: json['name'] as String);
  }

  @override
  Object toJson() => {'type': 'function', 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseToolChoiceFunction &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ResponseToolChoiceFunction(name: $name)';
}

/// Model can only call the specified tools.
///
/// This allows specifying a list of allowed tools (1-128) and an optional mode.
@immutable
class ResponseToolChoiceAllowedTools extends ResponseToolChoice {
  /// The list of allowed tools.
  final List<SpecificToolChoice> tools;

  /// The tool choice mode.
  final ToolChoiceMode? mode;

  /// Creates a [ResponseToolChoiceAllowedTools].
  const ResponseToolChoiceAllowedTools({required this.tools, this.mode});

  /// Creates a [ResponseToolChoiceAllowedTools] from JSON.
  factory ResponseToolChoiceAllowedTools.fromJson(Map<String, dynamic> json) {
    return ResponseToolChoiceAllowedTools(
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
      other is ResponseToolChoiceAllowedTools &&
          runtimeType == other.runtimeType &&
          listsEqual(tools, other.tools) &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(Object.hashAll(tools), mode);

  @override
  String toString() =>
      'ResponseToolChoiceAllowedTools(tools: $tools, mode: $mode)';
}
