import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'consumer_type.dart';
import 'tool_execution_configuration.dart';

/// A tool-execution preference attached to a connector connection.
@immutable
class ConnectionPreference {
  /// The name of the preference.
  final String name;

  /// The tool-execution configuration.
  final ToolExecutionConfiguration toolConfiguration;

  /// Whether this is the default preference.
  final bool? isDefault;

  /// The scope at which this preference applies.
  final ConsumerType? consumerType;

  /// Creates a [ConnectionPreference].
  const ConnectionPreference({
    required this.name,
    required this.toolConfiguration,
    this.isDefault,
    this.consumerType,
  });

  /// Creates a [ConnectionPreference] from JSON.
  factory ConnectionPreference.fromJson(Map<String, dynamic> json) =>
      ConnectionPreference(
        name: json['name'] as String? ?? '',
        toolConfiguration: ToolExecutionConfiguration.fromJson(
          (json['tool_configuration'] as Map<String, dynamic>?) ?? const {},
        ),
        isDefault: json['is_default'] as bool?,
        consumerType: json['consumer_type'] != null
            ? ConsumerType.fromJson(json['consumer_type'] as String?)
            : null,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'tool_configuration': toolConfiguration.toJson(),
    if (isDefault != null) 'is_default': isDefault,
    if (consumerType != null) 'consumer_type': consumerType!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ConnectionPreference copyWith({
    String? name,
    ToolExecutionConfiguration? toolConfiguration,
    Object? isDefault = unsetCopyWithValue,
    Object? consumerType = unsetCopyWithValue,
  }) => ConnectionPreference(
    name: name ?? this.name,
    toolConfiguration: toolConfiguration ?? this.toolConfiguration,
    isDefault: isDefault == unsetCopyWithValue
        ? this.isDefault
        : isDefault as bool?,
    consumerType: consumerType == unsetCopyWithValue
        ? this.consumerType
        : consumerType as ConsumerType?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionPreference &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          toolConfiguration == other.toolConfiguration &&
          isDefault == other.isDefault &&
          consumerType == other.consumerType;

  @override
  int get hashCode =>
      Object.hash(name, toolConfiguration, isDefault, consumerType);

  @override
  String toString() =>
      'ConnectionPreference('
      'name: $name, '
      'toolConfiguration: $toolConfiguration, '
      'isDefault: $isDefault, '
      'consumerType: $consumerType)';
}
