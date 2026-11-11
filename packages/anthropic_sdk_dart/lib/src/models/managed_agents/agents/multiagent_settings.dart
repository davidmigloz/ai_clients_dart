import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// Enables or disables inline agents for workflows or subagents.
@immutable
final class MultiagentInlineAgents {
  /// The policy's wire value.
  final String type;
  final Map<String, dynamic>? _raw;

  /// Enables agents defined in a workflow plan or a spawn call.
  const MultiagentInlineAgents.enabled() : type = 'enabled', _raw = null;

  /// Only allows predefined agents.
  const MultiagentInlineAgents.disabled() : type = 'disabled', _raw = null;

  MultiagentInlineAgents._(this.type, Map<String, dynamic> raw)
    : _raw = deepUnmodifiableMap(raw);

  /// Parses the policy and preserves future policy values.
  factory MultiagentInlineAgents.fromJson(Map<String, dynamic> json) =>
      switch (json) {
        {'type': 'enabled'} => const MultiagentInlineAgents.enabled(),
        {'type': 'disabled'} => const MultiagentInlineAgents.disabled(),
        {'type': final String type} => MultiagentInlineAgents._(type, json),
        _ => throw const FormatException('Inline agents policy requires type'),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {...?_raw, 'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentInlineAgents &&
          type == other.type &&
          mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(_raw));

  @override
  String toString() => 'MultiagentInlineAgents(type: $type)';
}

/// Advisor settings for a v20261001 agent.
@immutable
final class MultiagentAdvisorSettings {
  /// The advisor setting's wire value.
  final String type;

  /// Advisor model when enabled.
  final String? model;
  final Map<String, dynamic>? _raw;

  /// Enables the advisor with a specific model.
  const MultiagentAdvisorSettings.enabled(String this.model)
    : type = 'enabled',
      _raw = null;

  /// Disables the advisor.
  const MultiagentAdvisorSettings.disabled()
    : type = 'disabled',
      model = null,
      _raw = null;

  MultiagentAdvisorSettings._(this.type, Map<String, dynamic> raw)
    : model = null,
      _raw = deepUnmodifiableMap(raw);

  /// Parses advisor settings and preserves future variants.
  factory MultiagentAdvisorSettings.fromJson(Map<String, dynamic> json) =>
      switch (json) {
        {'type': 'enabled', 'model': final String model} =>
          MultiagentAdvisorSettings.enabled(model),
        {'type': 'enabled'} => throw const FormatException(
          'Enabled advisor requires model',
        ),
        {'type': 'disabled'} => const MultiagentAdvisorSettings.disabled(),
        {'type': final String type} => MultiagentAdvisorSettings._(type, json),
        _ => throw const FormatException('Advisor settings require type'),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {...?_raw, 'type': type, 'model': ?model};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentAdvisorSettings &&
          type == other.type &&
          model == other.model &&
          mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => Object.hash(type, model, mapDeepHashCode(_raw));

  @override
  String toString() => 'MultiagentAdvisorSettings(type: $type, model: $model)';
}

/// Resolved workflow or subagent settings. The agent representation depends
/// on whether this is an agent response or a session snapshot.
@immutable
final class MultiagentWorkers<T> {
  /// The resolved state, such as `enabled` or `disabled`.
  final String type;

  /// Resolved policy for inline agents when enabled.
  final MultiagentInlineAgents? inlineAgents;

  /// Resolved predefined agents when enabled.
  final List<T>? predefinedAgents;
  final Map<String, dynamic> _raw;

  MultiagentWorkers._(
    this.type,
    this.inlineAgents,
    this.predefinedAgents,
    Map<String, dynamic> json,
  ) : _raw = deepUnmodifiableMap(json);

  /// Parses a worker setting using the appropriate agent representation.
  static MultiagentWorkers<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseAgent,
  ) {
    if (json case {
      'type': 'enabled',
      'inline_agents': final Map<String, dynamic> inlineAgents,
      'predefined_agents': final List<Object?> agents,
    }) {
      return MultiagentWorkers<T>._(
        'enabled',
        MultiagentInlineAgents.fromJson(inlineAgents),
        List.unmodifiable(agents.cast<Map<String, dynamic>>().map(parseAgent)),
        json,
      );
    }
    final type = json['type'];
    if (type is String && type != 'enabled') {
      return MultiagentWorkers<T>._(type, null, null, json);
    }
    throw const FormatException(
      'Enabled multiagent workers require inline_agents and predefined_agents',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentWorkers<T> && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() =>
      'MultiagentWorkers(type: $type, inlineAgents: $inlineAgents, '
      'predefinedAgents: ${predefinedAgents?.length})';
}
