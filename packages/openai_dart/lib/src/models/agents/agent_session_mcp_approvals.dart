part of 'agent_session_models.dart';

/// Details for presenting one Managed Agents MCP tool-call approval.
final class AgentSessionMcpApprovalRequest extends AgentJsonModel {
  /// Creates a detached approval request.
  AgentSessionMcpApprovalRequest({
    required this.serverLabel,
    required this.name,
    required Object? arguments,
    required this.message,
    Map<String, dynamic> rawJson = const {},
  }) : arguments = snapshotAgentJson({
         'arguments': arguments,
       }, 'AgentSessionMcpApprovalRequest.arguments')['arguments'],
       rawJson = agentExtras(rawJson, _keys, 'AgentSessionMcpApprovalRequest');

  static const _keys = ['type', 'server_label', 'name', 'arguments', 'message'];

  /// The MCP server label.
  final String serverLabel;

  /// The tool name, if the service supplied one.
  final String? name;

  /// The proposed tool arguments as immutable JSON, or null when unavailable.
  final Object? arguments;

  /// A message to present to the reviewer.
  final String message;

  /// Additional detached metadata returned by the service.
  final Map<String, dynamic> rawJson;

  /// The fixed payload type.
  String get type => 'mcp_tool_call';

  /// Parses the approval details. Both nullable fields must occur on the wire.
  factory AgentSessionMcpApprovalRequest.fromJson(Map<String, dynamic> json) {
    const context = 'AgentSessionMcpApprovalRequest';
    requireAgentTag(json, 'type', 'mcp_tool_call', context);
    return AgentSessionMcpApprovalRequest(
      serverLabel: requireAgentString(
        json['server_label'],
        '$context.serverLabel',
      ),
      name: requiredAgentValue(
        json,
        'name',
        '$context.name',
        requireAgentString,
        nullable: true,
      ),
      arguments: requiredAgentValue<Object>(
        json,
        'arguments',
        '$context.arguments',
        (value, _) => value!,
        nullable: true,
      ),
      message: requireAgentString(json['message'], '$context.message'),
      rawJson: {
        for (final entry in json.entries)
          if (!_keys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'server_label': serverLabel,
    'name': name,
    'arguments': arguments,
    'message': message,
  };

  /// Copies the approval details, retaining omitted nullable values.
  AgentSessionMcpApprovalRequest copyWith({
    String? serverLabel,
    Object? name = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    String? message,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMcpApprovalRequest(
    serverLabel: serverLabel ?? this.serverLabel,
    name: copyAgentValue<String>(
      name,
      this.name,
      'AgentSessionMcpApprovalRequest.name',
    ),
    arguments: identical(arguments, unsetCopyWithValue)
        ? this.arguments
        : arguments,
    message: message ?? this.message,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A pending MCP approval reported in a session's required actions.
final class AgentSessionMcpApprovalRequiredAction
    extends AgentSessionRequiredAction {
  /// Creates a received action.
  AgentSessionMcpApprovalRequiredAction({
    required this.requestId,
    required this.turnId,
    required this.request,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(
         rawJson,
         _keys,
         'AgentSessionMcpApprovalRequiredAction',
       );

  static const _keys = ['type', 'request_id', 'turn_id', 'request'];

  /// The opaque approval request ID to echo when responding.
  final String requestId;

  /// The turn that requested approval.
  final String turnId;

  /// Details for presenting the proposed tool call.
  final AgentSessionMcpApprovalRequest request;

  /// Additional detached metadata returned by the service.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'mcp_approval_request';

  /// Parses a pending approval.
  factory AgentSessionMcpApprovalRequiredAction.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'AgentSessionMcpApprovalRequiredAction';
    requireAgentTag(json, 'type', 'mcp_approval_request', context);
    return AgentSessionMcpApprovalRequiredAction(
      requestId: requireAgentString(json['request_id'], '$context.requestId'),
      turnId: requireAgentString(json['turn_id'], '$context.turnId'),
      request: AgentSessionMcpApprovalRequest.fromJson(
        requireAgentObject(json['request'], '$context.request'),
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!_keys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'request_id': requestId,
    'turn_id': turnId,
    'request': request.toJson(),
  };

  /// Copies the action.
  AgentSessionMcpApprovalRequiredAction copyWith({
    String? requestId,
    String? turnId,
    AgentSessionMcpApprovalRequest? request,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMcpApprovalRequiredAction(
    requestId: requestId ?? this.requestId,
    turnId: turnId ?? this.turnId,
    request: request ?? this.request,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The explicit decision for a proposed Managed Agents MCP tool call.
enum AgentSessionMcpApprovalDecision {
  /// Approves the pending tool call.
  approve,

  /// Denies the pending tool call.
  deny,

  /// Dismisses this approval request while leaving the session and turn intact.
  cancel;

  /// Parses a supported writable decision.
  static AgentSessionMcpApprovalDecision fromJson(Object? json) =>
      switch (json) {
        'approve' => approve,
        'deny' => deny,
        'cancel' => cancel,
        _ => throw const FormatException(
          'AgentSessionMcpApprovalDecision: unknown decision',
        ),
      };

  /// Returns the wire spelling.
  String toJson() => name;
}

/// The decision payload sent for a pending MCP tool-call approval.
final class AgentSessionMcpApprovalResponse extends AgentJsonModel {
  /// Creates a response from an explicit decision.
  const AgentSessionMcpApprovalResponse({required this.decision});

  /// The decision to submit.
  final AgentSessionMcpApprovalDecision decision;

  /// The fixed payload type.
  String get type => 'mcp_tool_call';

  /// Parses a writable MCP tool-call response.
  factory AgentSessionMcpApprovalResponse.fromJson(Map<String, dynamic> json) {
    const context = 'AgentSessionMcpApprovalResponse';
    requireClosedAgentJson(json, const ['type', 'decision'], context);
    requireAgentTag(json, 'type', 'mcp_tool_call', context);
    return AgentSessionMcpApprovalResponse(
      decision: AgentSessionMcpApprovalDecision.fromJson(json['decision']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'decision': decision.toJson(),
  };

  /// Copies a response, retaining the current decision when omitted.
  AgentSessionMcpApprovalResponse copyWith({
    AgentSessionMcpApprovalDecision? decision,
  }) => AgentSessionMcpApprovalResponse(decision: decision ?? this.decision);
}

/// A manually submitted response to an MCP approval request.
final class AgentSessionMcpApprovalResultInput extends AgentSessionInput {
  /// Creates an input event for the supplied approval request.
  AgentSessionMcpApprovalResultInput({
    required this.requestId,
    required this.response,
  }) {
    validate();
  }

  /// The original approval request ID.
  final String requestId;

  /// The explicit decision payload.
  final AgentSessionMcpApprovalResponse response;

  @override
  String get type => 'agent.session.input.mcp_approval_request_result';

  /// Parses a writable approval result.
  factory AgentSessionMcpApprovalResultInput.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'AgentSessionMcpApprovalResultInput';
    requireClosedAgentJson(json, const [
      'type',
      'request_id',
      'response',
    ], context);
    requireAgentTag(
      json,
      'type',
      'agent.session.input.mcp_approval_request_result',
      context,
    );
    return AgentSessionMcpApprovalResultInput(
      requestId: requireAgentString(json['request_id'], '$context.requestId'),
      response: AgentSessionMcpApprovalResponse.fromJson(
        requireAgentObject(json['response'], '$context.response'),
      ),
    );
  }

  @override
  void validate() {
    validateAgentLength(
      requestId,
      'AgentSessionMcpApprovalResultInput.requestId',
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'request_id': requestId,
    'response': response.toJson(),
  };

  /// Copies the input.
  AgentSessionMcpApprovalResultInput copyWith({
    String? requestId,
    AgentSessionMcpApprovalResponse? response,
  }) => AgentSessionMcpApprovalResultInput(
    requestId: requestId ?? this.requestId,
    response: response ?? this.response,
  );
}
