import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A variable used by a [PromptDefinition] template.
@immutable
class PromptVariable {
  /// Stable object name.
  final String? name;

  /// Creates a [PromptVariable].
  const PromptVariable({this.name});

  /// Creates a [PromptVariable] from JSON.
  factory PromptVariable.fromJson(Map<String, dynamic> json) =>
      PromptVariable(name: json['name'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (name != null) 'name': name};

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  PromptVariable copyWith({Object? name = unsetCopyWithValue}) =>
      PromptVariable(
        name: name == unsetCopyWithValue ? this.name : name as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptVariable &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'PromptVariable(name: $name)';
}
