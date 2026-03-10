import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';

/// Configuration for a tool's behavior.
///
/// Allows filtering which functions the tool can access and whether
/// tool calls require user confirmation before execution.
@immutable
class ToolConfiguration {
  /// List of function names to exclude from the tool.
  final List<String>? exclude;

  /// List of function names to include for the tool.
  final List<String>? include;

  /// List of function names that require user confirmation before execution.
  final List<String>? requiresConfirmation;

  /// Creates a [ToolConfiguration].
  const ToolConfiguration({
    this.exclude,
    this.include,
    this.requiresConfirmation,
  });

  /// Creates a [ToolConfiguration] from JSON.
  factory ToolConfiguration.fromJson(Map<String, dynamic> json) =>
      ToolConfiguration(
        exclude: (json['exclude'] as List?)?.cast<String>(),
        include: (json['include'] as List?)?.cast<String>(),
        requiresConfirmation: (json['requires_confirmation'] as List?)
            ?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (exclude != null) 'exclude': exclude,
    if (include != null) 'include': include,
    if (requiresConfirmation != null)
      'requires_confirmation': requiresConfirmation,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolConfiguration &&
          runtimeType == other.runtimeType &&
          listsEqual(exclude, other.exclude) &&
          listsEqual(include, other.include) &&
          listsEqual(requiresConfirmation, other.requiresConfirmation);

  @override
  int get hashCode => Object.hash(
    listHash(exclude),
    listHash(include),
    listHash(requiresConfirmation),
  );

  @override
  String toString() =>
      'ToolConfiguration('
      'exclude: $exclude, include: $include, '
      'requiresConfirmation: $requiresConfirmation)';
}
