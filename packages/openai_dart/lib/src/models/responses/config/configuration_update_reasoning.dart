import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/json_helpers.dart';
import 'reasoning_effort.dart';

/// Reasoning fields that can be changed by a configuration update item.
///
/// Unlike request-level reasoning configuration, this object exposes only
/// [effort]. Explicit parsed null is accepted and normalized to omission, as
/// with other optional nullable configuration fields.
@immutable
class ConfigurationUpdateReasoning {
  /// The reasoning effort for subsequent responses.
  final ReasoningEffort? effort;

  /// Creates a [ConfigurationUpdateReasoning].
  const ConfigurationUpdateReasoning({this.effort});

  /// Creates a [ConfigurationUpdateReasoning] from JSON.
  factory ConfigurationUpdateReasoning.fromJson(
    Map<String, dynamic> json, {
    String context = 'ConfigurationUpdateReasoning',
  }) {
    final effort = optionalJsonString(json, 'effort', context, nullable: true);
    return ConfigurationUpdateReasoning(
      effort: effort == null ? null : ReasoningEffort.fromJson(effort),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort!.toJson(),
  };

  /// Copies the configuration; explicit null clears [effort].
  ConfigurationUpdateReasoning copyWith({
    Object? effort = unsetCopyWithValue,
  }) => ConfigurationUpdateReasoning(
    effort: effort == unsetCopyWithValue
        ? this.effort
        : effort as ReasoningEffort?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationUpdateReasoning &&
          runtimeType == other.runtimeType &&
          effort == other.effort;

  @override
  int get hashCode => effort.hashCode;

  @override
  String toString() => 'ConfigurationUpdateReasoning(effort: $effort)';
}
