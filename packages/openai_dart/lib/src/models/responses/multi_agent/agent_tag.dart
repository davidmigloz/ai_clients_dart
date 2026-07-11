import 'package:meta/meta.dart';

/// Identifies the agent that produced an item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Unifies the `BetaAgentTag` and
/// `Beta_AgentTagParam` schemas, which are identical.
@immutable
class AgentTag {
  /// The canonical name of the agent that produced this item.
  final String agentName;

  /// Creates an [AgentTag].
  const AgentTag({required this.agentName});

  /// Creates an [AgentTag] from JSON.
  factory AgentTag.fromJson(Map<String, dynamic> json) {
    return AgentTag(agentName: json['agent_name'] as String);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'agent_name': agentName};

  /// Creates a copy with replaced values.
  AgentTag copyWith({String? agentName}) {
    return AgentTag(agentName: agentName ?? this.agentName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentTag &&
          runtimeType == other.runtimeType &&
          agentName == other.agentName;

  @override
  int get hashCode => agentName.hashCode;

  @override
  String toString() => 'AgentTag(agentName: $agentName)';
}
