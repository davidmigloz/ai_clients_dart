import '../../copy_with_sentinel.dart';
import 'agent.dart';

/// The response from listing agents.
class ListAgentsResponse {
  /// The agents on this page.
  final List<Agent>? agents;

  /// Token for retrieving the next page of results, if any.
  final String? nextPageToken;

  /// Creates a [ListAgentsResponse].
  const ListAgentsResponse({this.agents, this.nextPageToken});

  /// Creates a [ListAgentsResponse] from JSON.
  factory ListAgentsResponse.fromJson(Map<String, dynamic> json) =>
      ListAgentsResponse(
        agents: (json['agents'] as List<dynamic>?)
            ?.map((e) => Agent.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['nextPageToken'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (agents != null) 'agents': agents!.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'nextPageToken': nextPageToken,
  };

  /// Creates a copy with replaced values.
  ListAgentsResponse copyWith({
    Object? agents = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) {
    return ListAgentsResponse(
      agents: agents == unsetCopyWithValue
          ? this.agents
          : agents as List<Agent>?,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
    );
  }
}
