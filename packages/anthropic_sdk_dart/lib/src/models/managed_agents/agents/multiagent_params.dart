import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../sessions/create_session_params.dart';

/// Multiagent orchestration configuration for create/update requests.
///
/// Currently supports the `coordinator` topology.
///
/// Variants:
/// - [MultiagentCoordinatorParams] — a coordinator topology with a roster.
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
