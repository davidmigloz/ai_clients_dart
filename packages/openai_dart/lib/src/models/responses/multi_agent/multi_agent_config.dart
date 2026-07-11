import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

/// Configuration for server-hosted multi-agent execution.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the `BetaMultiAgentParam`
/// schema.
@immutable
class MultiAgentConfig {
  /// Whether to enable server-hosted multi-agent execution for this response.
  final bool enabled;

  /// The maximum number of subagents that can be active simultaneously
  /// across the entire agent tree.
  ///
  /// Includes all descendants — children, grandchildren, and deeper
  /// subagents — but excludes the root agent. The API does not impose a
  /// fixed upper bound on this setting. The default is `3`, which is
  /// recommended for most workloads. Multi-agent runs also have no fixed
  /// limit on tree depth or the total number of subagents created during a
  /// run.
  final int? maxConcurrentSubagents;

  /// Creates a [MultiAgentConfig].
  const MultiAgentConfig({required this.enabled, this.maxConcurrentSubagents});

  /// Creates a [MultiAgentConfig] from JSON.
  factory MultiAgentConfig.fromJson(Map<String, dynamic> json) {
    return MultiAgentConfig(
      enabled: json['enabled'] as bool,
      maxConcurrentSubagents: json['max_concurrent_subagents'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    if (maxConcurrentSubagents != null)
      'max_concurrent_subagents': maxConcurrentSubagents,
  };

  /// Creates a copy with replaced values.
  MultiAgentConfig copyWith({
    bool? enabled,
    Object? maxConcurrentSubagents = unsetCopyWithValue,
  }) {
    return MultiAgentConfig(
      enabled: enabled ?? this.enabled,
      maxConcurrentSubagents: maxConcurrentSubagents == unsetCopyWithValue
          ? this.maxConcurrentSubagents
          : maxConcurrentSubagents as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiAgentConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          maxConcurrentSubagents == other.maxConcurrentSubagents;

  @override
  int get hashCode => Object.hash(enabled, maxConcurrentSubagents);

  @override
  String toString() =>
      'MultiAgentConfig(enabled: $enabled, maxConcurrentSubagents: $maxConcurrentSubagents)';
}
