part of 'steps.dart';

/// Result of a code execution call.
class CodeExecutionResultStep extends InteractionStep {
  @override
  String get type => 'code_execution_result';

  /// ID matching the corresponding [CodeExecutionCallStep.id].
  final String callId;

  final Object _result;
  final List<dynamic>? _wireResult;

  /// Text output, or an empty string when the result contains media.
  String get result => switch (_result) {
    final String text => text,
    _ => '',
  };

  /// Structured text or media output, if the returned content is recognized.
  ///
  /// Use [copyWith] to supply updated content for serialization.
  List<InteractionContent>? get resultContent => switch (_result) {
    final List<InteractionContent> content => content,
    _ => null,
  };

  /// Whether the code execution resulted in an error.
  final bool? isError;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [CodeExecutionResultStep] instance.
  const CodeExecutionResultStep({
    required this.callId,
    required String this._result,
    this.isError,
    this.signature,
  }) : _wireResult = null;

  /// Creates a code execution result with structured content.
  const CodeExecutionResultStep.content({
    required this.callId,
    required List<InteractionContent> resultContent,
    this.isError,
    this.signature,
  }) : _result = resultContent,
       _wireResult = null;

  const CodeExecutionResultStep._({
    required this.callId,
    required this._result,
    this._wireResult,
    this.isError,
    this.signature,
  });

  /// Creates a [CodeExecutionResultStep] from JSON.
  factory CodeExecutionResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'code_execution_result') {
      throw FormatException(
        'Expected type "code_execution_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'CodeExecutionResultStep: missing required "call_id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `result` is populated later via `step.delta`; default to empty when
    // absent.
    final raw = json['result'] ?? '';
    return CodeExecutionResultStep._(
      callId: callId,
      result: _decodeResult(raw),
      wireResult: raw is List ? raw.map(_copyJsonValue).toList() : null,
      isError: json['is_error'] as bool?,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': _copyJsonValue(
      _wireResult ??
          switch (_result) {
            final List<InteractionContent> entries =>
              entries.map((entry) => entry.toJson()).toList(),
            final Object raw => raw,
          },
    ),
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  CodeExecutionResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? resultContent = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    final Object output;
    if (result != unsetCopyWithValue) {
      output = result! as String;
    } else if (resultContent != unsetCopyWithValue) {
      output = resultContent as List<InteractionContent>? ?? '';
    } else {
      output = _result;
    }
    return CodeExecutionResultStep._(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: output,
      wireResult:
          result == unsetCopyWithValue && resultContent == unsetCopyWithValue
          ? _wireResult
          : null,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }

  static Object _decodeResult(Object raw) {
    if (raw is! List) return raw;
    try {
      return List<InteractionContent>.unmodifiable(
        raw.map(
          (entry) => InteractionContent.fromJson(entry as Map<String, dynamic>),
        ),
      );
    } on ArgumentError {
      return raw;
    } on TypeError {
      return raw;
    }
  }

  static Object? _copyJsonValue(Object? value) => switch (value) {
    final Map<String, dynamic> object => {
      for (final entry in object.entries)
        entry.key: _copyJsonValue(entry.value),
    },
    final List<dynamic> array => [
      for (final item in array) _copyJsonValue(item),
    ],
    _ => value,
  };
}
