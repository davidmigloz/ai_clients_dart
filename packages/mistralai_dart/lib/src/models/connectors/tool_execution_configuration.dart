import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Configuration controlling how a connector's tools are executed.
///
/// The [requiresConfirmation] and [skipConfirmation] fields are open unions
/// in the API (a list of tool names, a logical expression, or tool
/// properties) and are therefore represented here as freeform values.
@immutable
class ToolExecutionConfiguration {
  /// Tools or expression that require confirmation before execution.
  final Object? requiresConfirmation;

  /// Tools or expression whose confirmation should be skipped.
  final Object? skipConfirmation;

  /// Tool names to include.
  final List<String>? include;

  /// Tool names to exclude.
  final List<String>? exclude;

  /// Creates a [ToolExecutionConfiguration].
  const ToolExecutionConfiguration({
    this.requiresConfirmation,
    this.skipConfirmation,
    this.include,
    this.exclude,
  });

  /// Creates a [ToolExecutionConfiguration] from JSON.
  factory ToolExecutionConfiguration.fromJson(Map<String, dynamic> json) =>
      ToolExecutionConfiguration(
        requiresConfirmation: json['requires_confirmation'],
        skipConfirmation: json['skip_confirmation'],
        include: (json['include'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        exclude: (json['exclude'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    if (requiresConfirmation != null)
      'requires_confirmation': requiresConfirmation,
    if (skipConfirmation != null) 'skip_confirmation': skipConfirmation,
    if (include != null) 'include': include,
    if (exclude != null) 'exclude': exclude,
  };

  /// Whether this configuration carries any settings.
  bool get isEmpty =>
      requiresConfirmation == null &&
      skipConfirmation == null &&
      include == null &&
      exclude == null;

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ToolExecutionConfiguration copyWith({
    Object? requiresConfirmation = unsetCopyWithValue,
    Object? skipConfirmation = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
    Object? exclude = unsetCopyWithValue,
  }) => ToolExecutionConfiguration(
    requiresConfirmation: requiresConfirmation == unsetCopyWithValue
        ? this.requiresConfirmation
        : requiresConfirmation,
    skipConfirmation: skipConfirmation == unsetCopyWithValue
        ? this.skipConfirmation
        : skipConfirmation,
    include: include == unsetCopyWithValue
        ? this.include
        : include as List<String>?,
    exclude: exclude == unsetCopyWithValue
        ? this.exclude
        : exclude as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolExecutionConfiguration &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(requiresConfirmation, other.requiresConfirmation) &&
          valuesDeepEqual(skipConfirmation, other.skipConfirmation) &&
          listsEqual(include, other.include) &&
          listsEqual(exclude, other.exclude);

  @override
  int get hashCode => Object.hash(
    valueDeepHashCode(requiresConfirmation),
    valueDeepHashCode(skipConfirmation),
    listHash(include),
    listHash(exclude),
  );

  @override
  String toString() =>
      'ToolExecutionConfiguration('
      'requiresConfirmation: $requiresConfirmation, '
      'skipConfirmation: $skipConfirmation, '
      'include: ${include == null ? 'null' : '${include!.length} items'}, '
      'exclude: ${exclude == null ? 'null' : '${exclude!.length} items'})';
}
