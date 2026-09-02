import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../sessions/session.dart' show SessionRosterEntry;

/// Resolved multiagent orchestration configuration as returned in API
/// responses.
///
/// Variants:
/// - [MultiagentCoordinator] — a coordinator topology with a resolved agent
///   roster.
/// - [UnknownMultiagent] — unrecognized topology, for forward compatibility.
sealed class Multiagent {
  const Multiagent();

  /// Creates a [Multiagent] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownMultiagent].
  factory Multiagent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'coordinator' => MultiagentCoordinator.fromJson(json),
      _ => UnknownMultiagent(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Resolved coordinator topology with a concrete agent roster.
@immutable
class MultiagentCoordinator extends Multiagent {
  /// The topology type, always 'coordinator'.
  String get type => 'coordinator';

  /// Agents the coordinator may spawn as session threads, each resolved to a
  /// specific version, or the platform advisor entry.
  final List<MultiagentRosterEntry> agents;

  /// Creates a [MultiagentCoordinator].
  const MultiagentCoordinator({required this.agents});

  /// Creates a [MultiagentCoordinator] from JSON.
  factory MultiagentCoordinator.fromJson(Map<String, dynamic> json) {
    return MultiagentCoordinator(
      agents: (json['agents'] as List)
          .map((e) => MultiagentRosterEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'agents': agents.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  MultiagentCoordinator copyWith({List<MultiagentRosterEntry>? agents}) {
    return MultiagentCoordinator(agents: agents ?? this.agents);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiagentCoordinator &&
          runtimeType == other.runtimeType &&
          listsEqual(agents, other.agents);

  @override
  int get hashCode => listHash(agents);

  @override
  String toString() => 'MultiagentCoordinator(agents: $agents)';
}

// ---------------------------------------------------------------------------
// MultiagentRosterEntry — sealed union
// ---------------------------------------------------------------------------

/// A resolved multiagent roster entry.
///
/// Variants:
/// - [AgentReference] — an agent resolved to a concrete version
///   (`type: "agent"`).
/// - [Advisor] — the platform advisor roster entry (`type: "advisor"`).
/// - [UnknownMultiagentRosterEntry] — unrecognized entry type (preserves raw
///   JSON).
sealed class MultiagentRosterEntry {
  const MultiagentRosterEntry();

  /// Creates a [MultiagentRosterEntry] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownMultiagentRosterEntry].
  factory MultiagentRosterEntry.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'agent' => AgentReference.fromJson(json),
      'advisor' => Advisor.fromJson(json),
      _ => UnknownMultiagentRosterEntry(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A resolved agent reference with a concrete version.
@immutable
class AgentReference extends MultiagentRosterEntry {
  /// The object type, always 'agent'.
  final String type;

  /// The agent ID.
  final String id;

  /// The specific agent version.
  final int version;

  /// Creates an [AgentReference].
  const AgentReference({
    this.type = 'agent',
    required this.id,
    required this.version,
  });

  /// Creates an [AgentReference] from JSON.
  factory AgentReference.fromJson(Map<String, dynamic> json) {
    return AgentReference(
      type: json['type'] as String? ?? 'agent',
      id: json['id'] as String,
      version: json['version'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'id': id, 'version': version};

  /// Creates a copy with replaced values.
  AgentReference copyWith({String? type, String? id, int? version}) {
    return AgentReference(
      type: type ?? this.type,
      id: id ?? this.id,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentReference &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => Object.hash(type, id, version);

  @override
  String toString() =>
      'AgentReference(type: $type, id: $id, version: $version)';
}

/// Platform advisor roster entry: a model the session's primary thread may
/// consult mid-turn.
///
/// Shared by [MultiagentRosterEntry] and `SessionRosterEntry` (declared in
/// `sessions/session.dart`) — both discriminated unions resolve their
/// `advisor` variant to this same class. It `implements SessionRosterEntry`
/// (rather than `extends`) because that union lives in a different library;
/// see the doc comment on `SessionRosterEntry` for why that union is a plain
/// abstract class rather than `sealed`.
@immutable
class Advisor extends MultiagentRosterEntry implements SessionRosterEntry {
  /// The entry type, always 'advisor'.
  final String type;

  /// The advisor model id. Must be permitted as an advisor for the agent's
  /// model.
  final String model;

  /// Creates an [Advisor].
  const Advisor({this.type = 'advisor', required this.model});

  /// Creates an [Advisor] from JSON.
  factory Advisor.fromJson(Map<String, dynamic> json) {
    return Advisor(
      type: json['type'] as String? ?? 'advisor',
      model: json['model'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'model': model};

  /// Creates a copy with replaced values.
  Advisor copyWith({String? type, String? model}) {
    return Advisor(type: type ?? this.type, model: model ?? this.model);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Advisor &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          model == other.model;

  @override
  int get hashCode => Object.hash(type, model);

  @override
  String toString() => 'Advisor(type: $type, model: $model)';
}

/// Unrecognized [MultiagentRosterEntry] type — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownMultiagentRosterEntry extends MultiagentRosterEntry {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownMultiagentRosterEntry].
  const UnknownMultiagentRosterEntry({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMultiagentRosterEntry &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownMultiagentRosterEntry(rawJson: $rawJson)';
}

/// Unrecognized multiagent topology — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownMultiagent extends Multiagent {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownMultiagent].
  const UnknownMultiagent({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMultiagent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownMultiagent(rawJson: $rawJson)';
}
