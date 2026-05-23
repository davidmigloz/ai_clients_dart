import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

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
  /// specific version.
  final List<AgentReference> agents;

  /// Creates a [MultiagentCoordinator].
  const MultiagentCoordinator({required this.agents});

  /// Creates a [MultiagentCoordinator] from JSON.
  factory MultiagentCoordinator.fromJson(Map<String, dynamic> json) {
    return MultiagentCoordinator(
      agents: (json['agents'] as List)
          .map((e) => AgentReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'agents': agents.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  MultiagentCoordinator copyWith({List<AgentReference>? agents}) {
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

/// A resolved agent reference with a concrete version.
@immutable
class AgentReference {
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

  /// Converts to JSON.
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
