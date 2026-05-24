import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../config/agent_tool.dart';
import '../config/mcp_server.dart';

/// Agent configuration patch applied mid-session via an UpdateSession request.
///
/// Full-replacement semantics apply per field:
/// - Provide an array to replace the current value entirely.
/// - Provide an empty array to clear the current value.
/// - Omit a field (leave it `null`) to preserve its current value.
@immutable
class SessionAgentUpdate {
  /// Tool configurations to apply to the agent.
  ///
  /// When provided, this array fully replaces the agent's current tools. An
  /// empty array clears all tools. Omit to preserve the current tools.
  final List<AgentToolParams>? tools;

  /// MCP server connections to apply to the agent.
  ///
  /// When provided, this array fully replaces the agent's current MCP servers.
  /// An empty array clears all MCP servers. Omit to preserve the current
  /// servers.
  final List<MCPServerParams>? mcpServers;

  /// Creates a [SessionAgentUpdate].
  const SessionAgentUpdate({this.tools, this.mcpServers});

  /// Creates a [SessionAgentUpdate] from JSON.
  factory SessionAgentUpdate.fromJson(Map<String, dynamic> json) {
    return SessionAgentUpdate(
      tools: (json['tools'] as List?)
          ?.map((e) => AgentToolParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      mcpServers: (json['mcp_servers'] as List?)
          ?.map((e) => MCPServerParams.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  ///
  /// Null lists are omitted (preserve semantics). Empty lists are serialized
  /// as `[]` to clear the corresponding value on the server.
  Map<String, dynamic> toJson() => {
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (mcpServers != null)
      'mcp_servers': mcpServers!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  SessionAgentUpdate copyWith({
    List<AgentToolParams>? tools,
    List<MCPServerParams>? mcpServers,
  }) {
    return SessionAgentUpdate(
      tools: tools ?? this.tools,
      mcpServers: mcpServers ?? this.mcpServers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAgentUpdate &&
          runtimeType == other.runtimeType &&
          listsEqual(tools, other.tools) &&
          listsEqual(mcpServers, other.mcpServers);

  @override
  int get hashCode => Object.hash(listHash(tools), listHash(mcpServers));

  @override
  String toString() =>
      'SessionAgentUpdate(tools: $tools, mcpServers: $mcpServers)';
}
