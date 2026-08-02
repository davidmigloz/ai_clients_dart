import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A tool made available for execution against a connector integration.
///
/// [executionConfig] is intentionally untyped (freeform JSON): the API keeps
/// this shape open since MCP configuration is not yet stable.
@immutable
class ExecutionTool {
  /// The tool name.
  final String name;

  /// The connector integration identifier this tool belongs to.
  final String integrationId;

  /// Freeform execution configuration for the tool.
  final Map<String, dynamic>? executionConfig;

  /// Creates an [ExecutionTool].
  ExecutionTool({
    required this.name,
    required this.integrationId,
    Map<String, dynamic>? executionConfig,
  }) : executionConfig = executionConfig == null
           ? null
           : Map.unmodifiable(executionConfig);

  /// Creates an [ExecutionTool] from JSON.
  factory ExecutionTool.fromJson(Map<String, dynamic> json) => ExecutionTool(
    name: json['name'] as String? ?? '',
    integrationId: json['integration_id'] as String? ?? '',
    executionConfig: json['execution_config'] as Map<String, dynamic>?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'integration_id': integrationId,
    if (executionConfig != null) 'execution_config': executionConfig,
  };

  /// Creates a copy with replaced values.
  ExecutionTool copyWith({
    String? name,
    String? integrationId,
    Object? executionConfig = unsetCopyWithValue,
  }) {
    return ExecutionTool(
      name: name ?? this.name,
      integrationId: integrationId ?? this.integrationId,
      executionConfig: executionConfig == unsetCopyWithValue
          ? this.executionConfig
          : executionConfig as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExecutionTool) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        integrationId == other.integrationId &&
        mapsDeepEqual(executionConfig, other.executionConfig);
  }

  @override
  int get hashCode =>
      Object.hash(name, integrationId, mapDeepHashCode(executionConfig));

  @override
  String toString() =>
      'ExecutionTool('
      'name: $name, '
      'integrationId: $integrationId, '
      'executionConfig: ${executionConfig?.length ?? 'null'} entries)';
}
