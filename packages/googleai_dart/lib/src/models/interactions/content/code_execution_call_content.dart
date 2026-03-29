part of 'content.dart';

/// A code execution call content block.
class CodeExecutionCallContent extends InteractionContent {
  @override
  String get type => 'code_execution_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The programming language of the code.
  final String? language;

  /// The code to execute.
  final String? code;

  /// The signature of the code execution call.
  final String? signature;

  /// Creates a [CodeExecutionCallContent] instance.
  const CodeExecutionCallContent({
    required this.id,
    this.language,
    this.code,
    this.signature,
  });

  /// Creates a [CodeExecutionCallContent] from JSON.
  ///
  /// The [id] field defaults to `''` when absent (e.g. content.start events).
  factory CodeExecutionCallContent.fromJson(Map<String, dynamic> json) {
    final arguments = json['arguments'] as Map<String, dynamic>?;
    return CodeExecutionCallContent(
      id: json['id'] as String? ?? '',
      language: arguments?['language'] as String?,
      code: arguments?['code'] as String?,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'arguments': {
      if (language != null) 'language': language,
      if (code != null) 'code': code,
    },
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  CodeExecutionCallContent copyWith({
    Object? id = unsetCopyWithValue,
    Object? language = unsetCopyWithValue,
    Object? code = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return CodeExecutionCallContent(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      language: language == unsetCopyWithValue
          ? this.language
          : language as String?,
      code: code == unsetCopyWithValue ? this.code : code as String?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
