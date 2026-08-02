import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'prompt_variable.dart';

/// Versioned prompt content.
@immutable
class PromptDefinition {
  /// Prompt template content.
  final String content;

  /// Variables used by the prompt.
  final List<PromptVariable>? variables;

  /// Creates a [PromptDefinition].
  const PromptDefinition({required this.content, this.variables});

  /// Creates a [PromptDefinition] from JSON.
  ///
  /// Throws a [FormatException] if [content] is missing or null.
  factory PromptDefinition.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    if (content is! String) {
      throw FormatException('Missing or invalid "content" field: $json');
    }
    return PromptDefinition(
      content: content,
      variables: (json['variables'] as List?)
          ?.map((e) => PromptVariable.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'content': content,
    if (variables != null)
      'variables': variables!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  PromptDefinition copyWith({
    String? content,
    Object? variables = unsetCopyWithValue,
  }) => PromptDefinition(
    content: content ?? this.content,
    variables: variables == unsetCopyWithValue
        ? this.variables
        : variables as List<PromptVariable>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptDefinition &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          listsEqual(variables, other.variables);

  @override
  int get hashCode => Object.hash(content, listHash(variables));

  @override
  String toString() =>
      'PromptDefinition(content: ${content.length} chars, '
      'variables: ${variables?.length})';
}
