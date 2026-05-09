import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

// =============================================================================
// RealtimeTracingConfig
// =============================================================================

/// Tracing configuration for Realtime sessions.
///
/// A discriminated union covering:
///
/// - [TracingAuto] — the bare string `"auto"`, enabling tracing with default
///   values.
/// - [TracingConfiguration] — an object with optional `group_id`, `metadata`,
///   and `workflow_name` for granular tracing control.
///
/// An [UnknownRealtimeTracingConfig] fallback preserves any unrecognised
/// payload so future server additions do not break existing clients.
sealed class RealtimeTracingConfig {
  const RealtimeTracingConfig();

  /// Auto tracing.
  const factory RealtimeTracingConfig.auto() = TracingAuto;

  /// Granular tracing configuration.
  const factory RealtimeTracingConfig.configuration({
    String? groupId,
    Map<String, dynamic>? metadata,
    String? workflowName,
  }) = TracingConfiguration;

  /// Creates from JSON.
  ///
  /// Accepts the bare string `"auto"` or an object with optional fields.
  factory RealtimeTracingConfig.fromJson(Object json) {
    if (json == 'auto') return const TracingAuto();
    if (json is Map<String, dynamic>) {
      return TracingConfiguration.fromJson(json);
    }
    return UnknownRealtimeTracingConfig({'value': json});
  }

  /// Converts to JSON. Returns either the string `"auto"` or a `Map`.
  Object toJson();
}

/// `auto` tracing strategy.
@immutable
class TracingAuto extends RealtimeTracingConfig {
  /// Creates a [TracingAuto].
  const TracingAuto();

  @override
  Object toJson() => 'auto';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TracingAuto && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'auto'.hashCode;

  @override
  String toString() => 'RealtimeTracingConfig.auto()';
}

/// Granular tracing configuration.
@immutable
class TracingConfiguration extends RealtimeTracingConfig {
  /// Creates a [TracingConfiguration].
  const TracingConfiguration({this.groupId, this.metadata, this.workflowName});

  /// Creates from JSON.
  factory TracingConfiguration.fromJson(Map<String, dynamic> json) {
    return TracingConfiguration(
      groupId: json['group_id'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      workflowName: json['workflow_name'] as String?,
    );
  }

  /// Optional group identifier for filtering in the Traces Dashboard.
  final String? groupId;

  /// Optional arbitrary metadata.
  final Map<String, dynamic>? metadata;

  /// Optional workflow name.
  final String? workflowName;

  @override
  Map<String, dynamic> toJson() => {
    if (groupId != null) 'group_id': groupId,
    if (metadata != null) 'metadata': metadata,
    if (workflowName != null) 'workflow_name': workflowName,
  };

  /// Returns a copy of this [TracingConfiguration] with the given fields replaced.
  ///
  /// Pass `null` for any field to clear the existing value.
  TracingConfiguration copyWith({
    Object? groupId = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? workflowName = unsetCopyWithValue,
  }) => TracingConfiguration(
    groupId: identical(groupId, unsetCopyWithValue)
        ? this.groupId
        : groupId as String?,
    metadata: identical(metadata, unsetCopyWithValue)
        ? this.metadata
        : metadata as Map<String, dynamic>?,
    workflowName: identical(workflowName, unsetCopyWithValue)
        ? this.workflowName
        : workflowName as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TracingConfiguration &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          mapsDeepEqual(metadata, other.metadata) &&
          workflowName == other.workflowName;

  @override
  int get hashCode =>
      Object.hash(groupId, mapDeepHashCode(metadata), workflowName);

  @override
  String toString() =>
      'TracingConfiguration(groupId: $groupId, metadata: $metadata, '
      'workflowName: $workflowName)';
}

/// Forward-compatible fallback for unknown [RealtimeTracingConfig] payloads.
@immutable
class UnknownRealtimeTracingConfig extends RealtimeTracingConfig {
  /// Creates an [UnknownRealtimeTracingConfig] from the raw payload.
  const UnknownRealtimeTracingConfig(this.json);

  /// The raw JSON map preserved verbatim.
  final Map<String, dynamic> json;

  @override
  Object toJson() {
    if (json.length == 1 && json.containsKey('value')) {
      return json['value'] as Object;
    }
    return Map<String, dynamic>.from(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRealtimeTracingConfig &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(json, other.json);

  @override
  int get hashCode => mapDeepHashCode(json);

  @override
  String toString() => 'UnknownRealtimeTracingConfig($json)';
}
