/// An action executed as part of the beta multi-agent protocol.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Unifies the
/// `BetaMultiAgentAction` and `BetaMultiAgentAction1` schemas, which are
/// identical enums.
enum MultiAgentAction {
  /// Unknown action (fallback for unrecognized values).
  unknown('unknown'),

  /// Spawn a new subagent.
  spawnAgent('spawn_agent'),

  /// Interrupt a running subagent.
  interruptAgent('interrupt_agent'),

  /// List active subagents.
  listAgents('list_agents'),

  /// Send a message to a subagent.
  sendMessage('send_message'),

  /// Assign a follow-up task to a subagent.
  followupTask('followup_task'),

  /// Wait for a subagent to complete.
  waitAgent('wait_agent');

  /// The JSON value for this action.
  final String value;

  const MultiAgentAction(this.value);

  /// Creates a [MultiAgentAction] from a JSON value.
  factory MultiAgentAction.fromJson(String json) {
    return MultiAgentAction.values.firstWhere(
      (e) => e.value == json,
      orElse: () => MultiAgentAction.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
