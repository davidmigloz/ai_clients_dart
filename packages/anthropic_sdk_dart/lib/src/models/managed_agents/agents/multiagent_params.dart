import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../sessions/create_session_params.dart';
import 'multiagent_settings.dart';

/// Multiagent orchestration configuration for create/update requests.
///
/// Supports coordinator and v20261001 configurations.
///
/// Variants:
/// - [MultiagentCoordinatorParams] — a coordinator topology with a roster.
/// - [Multiagent20261001Params] — independent workflow, subagent and advisor settings.
/// - [UnknownMultiagentParams] — unrecognized topology, for forward
///   compatibility.
sealed class MultiagentParams {
  const MultiagentParams();

  /// Creates a [MultiagentParams] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownMultiagentParams].
  factory MultiagentParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'coordinator' => MultiagentCoordinatorParams.fromJson(json),
      'multiagent_20261001' => Multiagent20261001Params.fromJson(json),
      _ => UnknownMultiagentParams(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A coordinator topology: the session's primary thread orchestrates work by
/// spawning session threads, each running an agent drawn from the [agents]
/// roster.
@immutable
class MultiagentCoordinatorParams extends MultiagentParams {
  /// The topology type, always 'coordinator'.
  String get type => 'coordinator';

  /// Agents the coordinator may spawn as session threads. 1–20 entries. Each
  /// entry is an agent ID string, a versioned agent reference, or `self` to
  /// allow recursive self-invocation.
  final List<MultiagentRosterEntryParams> agents;

  /// Creates a [MultiagentCoordinatorParams].
  const MultiagentCoordinatorParams({required this.agents});

  /// Creates a [MultiagentCoordinatorParams] from JSON.
  factory MultiagentCoordinatorParams.fromJson(Map<String, dynamic> json) {
    return MultiagentCoordinatorParams(
      agents: (json['agents'] as List)
          .map((e) => MultiagentRosterEntryParams.fromJson(e as Object))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'agents': agents.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  MultiagentCoordinatorParams copyWith({
    List<MultiagentRosterEntryParams>? agents,
  }) {
    return MultiagentCoordinatorParams(agents: agents ?? this.agents);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentCoordinatorParams &&
          runtimeType == other.runtimeType &&
          listsEqual(agents, other.agents);

  @override
  int get hashCode => listHash(agents);

  @override
  String toString() => 'MultiagentCoordinatorParams(agents: $agents)';
}

/// Unrecognized multiagent topology params — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownMultiagentParams extends MultiagentParams {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownMultiagentParams].
  const UnknownMultiagentParams({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMultiagentParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownMultiagentParams(rawJson: $rawJson)';
}

/// An entry in a multiagent roster: an agent ID string, a versioned agent
/// reference, `self`, or the platform advisor entry.
///
/// Variants:
/// - [MultiagentRosterEntryAgent] — an agent ID string or versioned reference
///   (reuses the [AgentParams] family).
/// - [MultiagentSelfParams] — the sentinel `self` entry.
/// - [MultiagentRosterEntryAdvisor] — the platform advisor entry.
/// - [UnknownMultiagentRosterEntryParams] — unrecognized object form.
sealed class MultiagentRosterEntryParams {
  const MultiagentRosterEntryParams();

  /// Creates a [MultiagentRosterEntryParams] from JSON.
  ///
  /// A [String] or `{"type":"agent",…}` object becomes a
  /// [MultiagentRosterEntryAgent]; `{"type":"self"}` becomes a
  /// [MultiagentSelfParams]; `{"type":"advisor",…}` becomes a
  /// [MultiagentRosterEntryAdvisor]; any other object falls back to
  /// [UnknownMultiagentRosterEntryParams].
  static MultiagentRosterEntryParams fromJson(Object json) {
    if (json is String) {
      return MultiagentRosterEntryAgent(agent: AgentParamsId(id: json));
    }
    final map = json as Map<String, dynamic>;
    return switch (map['type'] as String?) {
      'self' => const MultiagentSelfParams(),
      'agent' => MultiagentRosterEntryAgent(
        agent: AgentParamsObject.fromJson(map),
      ),
      'advisor' => MultiagentRosterEntryAdvisor.fromJson(map),
      _ => UnknownMultiagentRosterEntryParams(rawJson: map),
    };
  }

  /// Creates a [MultiagentRosterEntryAdvisor] for the given advisor [model].
  factory MultiagentRosterEntryParams.advisor(String model) =>
      MultiagentRosterEntryAdvisor(model: model);

  /// Converts to JSON.
  Object toJson();
}

/// A roster entry referencing an agent — a plain ID string or a versioned
/// reference, modeled via the existing [AgentParams] family.
@immutable
class MultiagentRosterEntryAgent extends MultiagentRosterEntryParams {
  /// The agent reference (an [AgentParamsId] or [AgentParamsObject]).
  final AgentParams agent;

  /// Creates a [MultiagentRosterEntryAgent].
  const MultiagentRosterEntryAgent({required this.agent});

  @override
  Object toJson() => agent.toJson();

  /// Creates a copy with replaced values.
  MultiagentRosterEntryAgent copyWith({AgentParams? agent}) {
    return MultiagentRosterEntryAgent(agent: agent ?? this.agent);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentRosterEntryAgent &&
          runtimeType == other.runtimeType &&
          agent == other.agent;

  @override
  int get hashCode => agent.hashCode;

  @override
  String toString() => 'MultiagentRosterEntryAgent(agent: $agent)';
}

/// Sentinel roster entry meaning "the agent that owns this configuration".
/// Resolved server-side to a concrete agent reference.
@immutable
class MultiagentSelfParams extends MultiagentRosterEntryParams {
  /// The entry type, always 'self'.
  String get type => 'self';

  /// Creates a [MultiagentSelfParams].
  const MultiagentSelfParams();

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentSelfParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'MultiagentSelfParams()';
}

/// Platform advisor roster entry: a model the session's primary thread may
/// consult mid-turn.
///
/// At most one per roster; the entry occupies the roster name
/// `anthropic.advisor`.
@immutable
class MultiagentRosterEntryAdvisor extends MultiagentRosterEntryParams {
  /// The entry type, always 'advisor'.
  String get type => 'advisor';

  /// A Claude model id. The model must be permitted as an advisor for this
  /// agent's model.
  final String model;

  /// Creates a [MultiagentRosterEntryAdvisor].
  const MultiagentRosterEntryAdvisor({required this.model});

  /// Creates a [MultiagentRosterEntryAdvisor] from JSON.
  factory MultiagentRosterEntryAdvisor.fromJson(Map<String, dynamic> json) {
    return MultiagentRosterEntryAdvisor(model: json['model'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'model': model};

  /// Creates a copy with replaced values.
  MultiagentRosterEntryAdvisor copyWith({String? model}) {
    return MultiagentRosterEntryAdvisor(model: model ?? this.model);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentRosterEntryAdvisor &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'MultiagentRosterEntryAdvisor(model: $model)';
}

/// Unrecognized roster entry object — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownMultiagentRosterEntryParams extends MultiagentRosterEntryParams {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownMultiagentRosterEntryParams].
  const UnknownMultiagentRosterEntryParams({required this.rawJson});

  @override
  Object toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMultiagentRosterEntryParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownMultiagentRosterEntryParams(rawJson: $rawJson)';
}

/// Multiagent settings with independent workflow, subagent and advisor modes.
///
/// On an update with the same version, omitted settings retain their current
/// values and explicit null restores the service default for that setting.
@immutable
final class Multiagent20261001Params extends MultiagentParams {
  final Object? _workflows;
  final Object? _subagents;
  final Object? _advisor;
  static const _type = 'multiagent_20261001';

  /// Workflow settings when specified and non-null.
  MultiagentWorkersParams? get workflows => _workflows == unsetCopyWithValue
      ? null
      : _workflows as MultiagentWorkersParams?;

  /// Subagent settings when specified and non-null.
  MultiagentWorkersParams? get subagents => _subagents == unsetCopyWithValue
      ? null
      : _subagents as MultiagentWorkersParams?;

  /// Advisor settings when specified and non-null.
  MultiagentAdvisorSettings? get advisor => _advisor == unsetCopyWithValue
      ? null
      : _advisor as MultiagentAdvisorSettings?;

  /// Creates v20261001 settings. Pass [MultiagentWorkersParams] for workflows
  /// and subagents, and [MultiagentAdvisorSettings] for advisor. Omit a setting
  /// to preserve it on update, or use null to restore the server default.
  const Multiagent20261001Params({
    this._workflows = unsetCopyWithValue,
    this._subagents = unsetCopyWithValue,
    this._advisor = unsetCopyWithValue,
  });

  /// Parses a v20261001 configuration.
  factory Multiagent20261001Params.fromJson(Map<String, dynamic> json) {
    if (json['type'] != _type) {
      throw const FormatException('Expected multiagent_20261001');
    }
    return Multiagent20261001Params(
      workflows: _readSetting(
        json,
        'workflows',
        MultiagentWorkersParams.fromJson,
      ),
      subagents: _readSetting(
        json,
        'subagents',
        MultiagentWorkersParams.fromJson,
      ),
      advisor: _readSetting(
        json,
        'advisor',
        MultiagentAdvisorSettings.fromJson,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': _type,
    if (_workflows != unsetCopyWithValue) 'workflows': workflows?.toJson(),
    if (_subagents != unsetCopyWithValue) 'subagents': subagents?.toJson(),
    if (_advisor != unsetCopyWithValue) 'advisor': advisor?.toJson(),
  };

  /// Replaces only the supplied settings.
  Multiagent20261001Params copyWith({
    Object? workflows = unsetCopyWithValue,
    Object? subagents = unsetCopyWithValue,
    Object? advisor = unsetCopyWithValue,
  }) => Multiagent20261001Params(
    workflows: workflows == unsetCopyWithValue ? _workflows : workflows,
    subagents: subagents == unsetCopyWithValue ? _subagents : subagents,
    advisor: advisor == unsetCopyWithValue ? _advisor : advisor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Multiagent20261001Params &&
          _workflows == other._workflows &&
          _subagents == other._subagents &&
          _advisor == other._advisor;

  @override
  int get hashCode => Object.hash(_workflows, _subagents, _advisor);

  @override
  String toString() =>
      'Multiagent20261001Params(workflows: $workflows, subagents: $subagents, advisor: $advisor)';
}

/// Request settings for the workflow or subagent workers.
@immutable
final class MultiagentWorkersParams {
  /// The worker setting's wire value.
  final String type;
  final Object? _inlineAgents;
  final Object? _predefinedAgents;
  final Map<String, dynamic>? _raw;

  /// Inline-agent setting when specified and non-null.
  MultiagentInlineAgents? get inlineAgents =>
      _inlineAgents == unsetCopyWithValue
      ? null
      : _inlineAgents as MultiagentInlineAgents?;

  /// Predefined agents when specified and non-null.
  List<MultiagentRosterEntryParams>? get predefinedAgents =>
      _predefinedAgents == unsetCopyWithValue
      ? null
      : _predefinedAgents as List<MultiagentRosterEntryParams>?;

  /// Enables the workers. Pass a [MultiagentInlineAgents] policy and a list of
  /// agent references or self entries. Omit values on an update to keep them,
  /// or pass null to restore the defaults.
  /// When inline agents are disabled, the final configuration must contain
  /// at least one predefined agent.
  const MultiagentWorkersParams.enabled({
    this._inlineAgents = unsetCopyWithValue,
    this._predefinedAgents = unsetCopyWithValue,
  }) : type = 'enabled',
       _raw = null;

  /// Disables the workers.
  const MultiagentWorkersParams.disabled()
    : type = 'disabled',
      _inlineAgents = unsetCopyWithValue,
      _predefinedAgents = unsetCopyWithValue,
      _raw = null;

  MultiagentWorkersParams._(this.type, Map<String, dynamic> json)
    : _inlineAgents = unsetCopyWithValue,
      _predefinedAgents = unsetCopyWithValue,
      _raw = deepUnmodifiableMap(json);

  /// Parses worker settings and preserves future worker modes.
  factory MultiagentWorkersParams.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'enabled' => MultiagentWorkersParams.enabled(
        inlineAgents: _readSetting(
          json,
          'inline_agents',
          MultiagentInlineAgents.fromJson,
        ),
        predefinedAgents: _readSetting(
          json,
          'predefined_agents',
          (List<Object?> agents) =>
              List<MultiagentRosterEntryParams>.unmodifiable(
                agents.map((agent) {
                  if (agent == null) {
                    throw const FormatException(
                      'Predefined agents cannot contain null',
                    );
                  }
                  return MultiagentRosterEntryParams.fromJson(agent);
                }),
              ),
        ),
      ),
      'disabled' => const MultiagentWorkersParams.disabled(),
      final String type => MultiagentWorkersParams._(type, json),
      _ => throw const FormatException(
        'Multiagent worker settings require type',
      ),
    };
  }

  /// Converts to JSON, preserving omitted and explicitly cleared settings.
  Map<String, dynamic> toJson() => {
    ...?_raw,
    'type': type,
    if (_inlineAgents != unsetCopyWithValue)
      'inline_agents': inlineAgents?.toJson(),
    if (_predefinedAgents != unsetCopyWithValue)
      'predefined_agents': predefinedAgents
          ?.map(_predefinedAgentToJson)
          .toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentWorkersParams &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'MultiagentWorkersParams(type: $type, inlineAgents: $inlineAgents, '
      'predefinedAgents: $predefinedAgents)';
}

Object? _readSetting<T>(
  Map<String, dynamic> json,
  String field,
  Object Function(T) parse,
) {
  if (!json.containsKey(field)) return unsetCopyWithValue;
  final value = json[field];
  return value == null ? null : parse(value as T);
}

Object _predefinedAgentToJson(MultiagentRosterEntryParams agent) {
  if (agent is MultiagentRosterEntryAdvisor ||
      agent is MultiagentRosterEntryAgent &&
          agent.agent is AgentParamsWithOverrides) {
    throw ArgumentError('Predefined agents must be agent references or self');
  }
  return agent.toJson();
}
