part of 'steps.dart';

/// A code execution tool call step.
class CodeExecutionCallStep extends InteractionStep {
  @override
  String get type => 'code_execution_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The arguments to pass to the code execution.
  final CodeExecutionCallStepArguments arguments;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [CodeExecutionCallStep] instance.
  const CodeExecutionCallStep({
    required this.id,
    required this.arguments,
    this.signature,
  });

  /// Creates a [CodeExecutionCallStep] from JSON.
  factory CodeExecutionCallStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'code_execution_call') {
      throw FormatException(
        'Expected type "code_execution_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException(
        'CodeExecutionCallStep: missing required "id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `arguments` is populated later via `step.delta`; default to empty when
    // absent.
    final argumentsJson = json['arguments'];
    final arguments = argumentsJson is Map<String, dynamic>
        ? CodeExecutionCallStepArguments.fromJson(argumentsJson)
        : const CodeExecutionCallStepArguments();
    return CodeExecutionCallStep(
      id: id,
      arguments: arguments,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'arguments': arguments.toJson(),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  CodeExecutionCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return CodeExecutionCallStep(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments! as CodeExecutionCallStepArguments,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// Programming language used by [CodeExecutionCallStepArguments].
enum CodeExecutionLanguage {
  /// Python >= 3.10, with numpy and simpy available.
  python,
}

/// Converts a JSON string to a [CodeExecutionLanguage], or `null` if
/// unrecognized (forward-compatible).
CodeExecutionLanguage? codeExecutionLanguageFromString(String? value) {
  return switch (value) {
    'python' => CodeExecutionLanguage.python,
    _ => null,
  };
}

/// Converts a [CodeExecutionLanguage] to its JSON string.
String codeExecutionLanguageToString(CodeExecutionLanguage value) {
  return switch (value) {
    CodeExecutionLanguage.python => 'python',
  };
}

/// The arguments to pass to the code execution tool.
class CodeExecutionCallStepArguments {
  /// The code to be executed.
  final String? code;

  /// Programming language of the [code].
  final CodeExecutionLanguage? language;

  /// Creates a [CodeExecutionCallStepArguments] instance.
  const CodeExecutionCallStepArguments({this.code, this.language});

  /// Creates a [CodeExecutionCallStepArguments] from JSON.
  factory CodeExecutionCallStepArguments.fromJson(Map<String, dynamic> json) =>
      CodeExecutionCallStepArguments(
        code: json['code'] as String?,
        language: codeExecutionLanguageFromString(json['language'] as String?),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code,
    if (language != null) 'language': codeExecutionLanguageToString(language!),
  };

  /// Creates a copy with replaced values.
  CodeExecutionCallStepArguments copyWith({
    Object? code = unsetCopyWithValue,
    Object? language = unsetCopyWithValue,
  }) {
    return CodeExecutionCallStepArguments(
      code: code == unsetCopyWithValue ? this.code : code as String?,
      language: language == unsetCopyWithValue
          ? this.language
          : language as CodeExecutionLanguage?,
    );
  }
}
