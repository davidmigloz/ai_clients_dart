part of 'agent_session_models.dart';

/// The user's decision for a browser origin access request.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionBrowserOriginAccessDecision extends AgentJsonModel {
  const AgentSessionBrowserOriginAccessDecision._(this.value);

  /// The `approve` wire value.
  static const AgentSessionBrowserOriginAccessDecision approve =
      AgentSessionBrowserOriginAccessDecision._('approve');

  /// The `deny` wire value.
  static const AgentSessionBrowserOriginAccessDecision deny =
      AgentSessionBrowserOriginAccessDecision._('deny');

  /// The `cancel` wire value.
  static const AgentSessionBrowserOriginAccessDecision cancel =
      AgentSessionBrowserOriginAccessDecision._('cancel');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionBrowserOriginAccessDecision.fromJson(Object? json) {
    final value = requireAgentString(
      json,
      'AgentSessionBrowserOriginAccessDecision',
    );
    return switch (value) {
      'approve' => approve,
      'deny' => deny,
      'cancel' => cancel,
      _ => AgentSessionBrowserOriginAccessDecision._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['approve', 'deny', 'cancel'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionBrowserOriginAccessDecision copyWith({String? value}) =>
      AgentSessionBrowserOriginAccessDecision.fromJson(value ?? this.value);
}

/// The CPU and memory tier for a new OpenAI-hosted session environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionContainerSizeConfig extends AgentJsonModel {
  const AgentSessionContainerSizeConfig._(this.value);

  /// The `small` wire value.
  static const AgentSessionContainerSizeConfig small =
      AgentSessionContainerSizeConfig._('small');

  /// The `medium` wire value.
  static const AgentSessionContainerSizeConfig medium =
      AgentSessionContainerSizeConfig._('medium');

  /// The `large` wire value.
  static const AgentSessionContainerSizeConfig large =
      AgentSessionContainerSizeConfig._('large');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionContainerSizeConfig.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionContainerSizeConfig');
    return switch (value) {
      'small' => small,
      'medium' => medium,
      'large' => large,
      _ => AgentSessionContainerSizeConfig._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['small', 'medium', 'large'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionContainerSizeConfig copyWith({String? value}) =>
      AgentSessionContainerSizeConfig.fromJson(value ?? this.value);
}

/// The effective CPU and memory tier of an OpenAI-hosted environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionContainerSizeResource extends AgentJsonModel {
  const AgentSessionContainerSizeResource._(this.value);

  /// The `small` wire value.
  static const AgentSessionContainerSizeResource small =
      AgentSessionContainerSizeResource._('small');

  /// The `medium` wire value.
  static const AgentSessionContainerSizeResource medium =
      AgentSessionContainerSizeResource._('medium');

  /// The `large` wire value.
  static const AgentSessionContainerSizeResource large =
      AgentSessionContainerSizeResource._('large');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionContainerSizeResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionContainerSizeResource');
    return switch (value) {
      'small' => small,
      'medium' => medium,
      'large' => large,
      _ => AgentSessionContainerSizeResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['small', 'medium', 'large'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionContainerSizeResource copyWith({String? value}) =>
      AgentSessionContainerSizeResource.fromJson(value ?? this.value);
}

/// The status of a tool call.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionFunctionCallStatusResource extends AgentJsonModel {
  const AgentSessionFunctionCallStatusResource._(this.value);

  /// The `in_progress` wire value.
  static const AgentSessionFunctionCallStatusResource inProgress =
      AgentSessionFunctionCallStatusResource._('in_progress');

  /// The `completed` wire value.
  static const AgentSessionFunctionCallStatusResource completed =
      AgentSessionFunctionCallStatusResource._('completed');

  /// The `failed` wire value.
  static const AgentSessionFunctionCallStatusResource failed =
      AgentSessionFunctionCallStatusResource._('failed');

  /// The `incomplete` wire value.
  static const AgentSessionFunctionCallStatusResource incomplete =
      AgentSessionFunctionCallStatusResource._('incomplete');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionFunctionCallStatusResource.fromJson(Object? json) {
    final value = requireAgentString(
      json,
      'AgentSessionFunctionCallStatusResource',
    );
    return switch (value) {
      'in_progress' => inProgress,
      'completed' => completed,
      'failed' => failed,
      'incomplete' => incomplete,
      _ => AgentSessionFunctionCallStatusResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'in_progress',
    'completed',
    'failed',
    'incomplete',
  ].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionFunctionCallStatusResource copyWith({String? value}) =>
      AgentSessionFunctionCallStatusResource.fromJson(value ?? this.value);
}

/// The phase of an assistant message.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionMessagePhaseResource extends AgentJsonModel {
  const AgentSessionMessagePhaseResource._(this.value);

  /// The `commentary` wire value.
  static const AgentSessionMessagePhaseResource commentary =
      AgentSessionMessagePhaseResource._('commentary');

  /// The `final_answer` wire value.
  static const AgentSessionMessagePhaseResource finalAnswer =
      AgentSessionMessagePhaseResource._('final_answer');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionMessagePhaseResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionMessagePhaseResource');
    return switch (value) {
      'commentary' => commentary,
      'final_answer' => finalAnswer,
      _ => AgentSessionMessagePhaseResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['commentary', 'final_answer'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionMessagePhaseResource copyWith({String? value}) =>
      AgentSessionMessagePhaseResource.fromJson(value ?? this.value);
}

/// The network access mode for an OpenAI-hosted environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionNetworkAccessConfig extends AgentJsonModel {
  const AgentSessionNetworkAccessConfig._(this.value);

  /// The `enabled` wire value.
  static const AgentSessionNetworkAccessConfig enabled =
      AgentSessionNetworkAccessConfig._('enabled');

  /// The `disabled` wire value.
  static const AgentSessionNetworkAccessConfig disabled =
      AgentSessionNetworkAccessConfig._('disabled');

  /// The `restricted` wire value.
  static const AgentSessionNetworkAccessConfig restricted =
      AgentSessionNetworkAccessConfig._('restricted');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionNetworkAccessConfig.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionNetworkAccessConfig');
    return switch (value) {
      'enabled' => enabled,
      'disabled' => disabled,
      'restricted' => restricted,
      _ => AgentSessionNetworkAccessConfig._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown =>
      const ['enabled', 'disabled', 'restricted'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionNetworkAccessConfig copyWith({String? value}) =>
      AgentSessionNetworkAccessConfig.fromJson(value ?? this.value);
}

/// The network access mode for an OpenAI-hosted environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionNetworkAccessResource extends AgentJsonModel {
  const AgentSessionNetworkAccessResource._(this.value);

  /// The `enabled` wire value.
  static const AgentSessionNetworkAccessResource enabled =
      AgentSessionNetworkAccessResource._('enabled');

  /// The `disabled` wire value.
  static const AgentSessionNetworkAccessResource disabled =
      AgentSessionNetworkAccessResource._('disabled');

  /// The `restricted` wire value.
  static const AgentSessionNetworkAccessResource restricted =
      AgentSessionNetworkAccessResource._('restricted');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionNetworkAccessResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionNetworkAccessResource');
    return switch (value) {
      'enabled' => enabled,
      'disabled' => disabled,
      'restricted' => restricted,
      _ => AgentSessionNetworkAccessResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown =>
      const ['enabled', 'disabled', 'restricted'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionNetworkAccessResource copyWith({String? value}) =>
      AgentSessionNetworkAccessResource.fromJson(value ?? this.value);
}

/// The status of an agent output item.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionOutputItemStatusResource extends AgentJsonModel {
  const AgentSessionOutputItemStatusResource._(this.value);

  /// The `in_progress` wire value.
  static const AgentSessionOutputItemStatusResource inProgress =
      AgentSessionOutputItemStatusResource._('in_progress');

  /// The `completed` wire value.
  static const AgentSessionOutputItemStatusResource completed =
      AgentSessionOutputItemStatusResource._('completed');

  /// The `incomplete` wire value.
  static const AgentSessionOutputItemStatusResource incomplete =
      AgentSessionOutputItemStatusResource._('incomplete');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionOutputItemStatusResource.fromJson(Object? json) {
    final value = requireAgentString(
      json,
      'AgentSessionOutputItemStatusResource',
    );
    return switch (value) {
      'in_progress' => inProgress,
      'completed' => completed,
      'incomplete' => incomplete,
      _ => AgentSessionOutputItemStatusResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown =>
      const ['in_progress', 'completed', 'incomplete'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionOutputItemStatusResource copyWith({String? value}) =>
      AgentSessionOutputItemStatusResource.fromJson(value ?? this.value);
}

/// The connection status of a session environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionEnvironmentStatusResource extends AgentJsonModel {
  const AgentSessionEnvironmentStatusResource._(this.value);

  /// The `pending` wire value.
  static const AgentSessionEnvironmentStatusResource pending =
      AgentSessionEnvironmentStatusResource._('pending');

  /// The `ready` wire value.
  static const AgentSessionEnvironmentStatusResource ready =
      AgentSessionEnvironmentStatusResource._('ready');

  /// The `connected` wire value.
  static const AgentSessionEnvironmentStatusResource connected =
      AgentSessionEnvironmentStatusResource._('connected');

  /// The `disconnected` wire value.
  static const AgentSessionEnvironmentStatusResource disconnected =
      AgentSessionEnvironmentStatusResource._('disconnected');

  /// The `suspended` wire value.
  static const AgentSessionEnvironmentStatusResource suspended =
      AgentSessionEnvironmentStatusResource._('suspended');

  /// The `expired` wire value.
  static const AgentSessionEnvironmentStatusResource expired =
      AgentSessionEnvironmentStatusResource._('expired');

  /// The `failed` wire value.
  static const AgentSessionEnvironmentStatusResource failed =
      AgentSessionEnvironmentStatusResource._('failed');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionEnvironmentStatusResource.fromJson(Object? json) {
    final value = requireAgentString(
      json,
      'AgentSessionEnvironmentStatusResource',
    );
    return switch (value) {
      'pending' => pending,
      'ready' => ready,
      'connected' => connected,
      'disconnected' => disconnected,
      'suspended' => suspended,
      'expired' => expired,
      'failed' => failed,
      _ => AgentSessionEnvironmentStatusResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'pending',
    'ready',
    'connected',
    'disconnected',
    'suspended',
    'expired',
    'failed',
  ].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionEnvironmentStatusResource copyWith({String? value}) =>
      AgentSessionEnvironmentStatusResource.fromJson(value ?? this.value);
}

/// The author of a session message.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionMessageRoleResource extends AgentJsonModel {
  const AgentSessionMessageRoleResource._(this.value);

  /// The `user` wire value.
  static const AgentSessionMessageRoleResource user =
      AgentSessionMessageRoleResource._('user');

  /// The `assistant` wire value.
  static const AgentSessionMessageRoleResource assistant =
      AgentSessionMessageRoleResource._('assistant');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionMessageRoleResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionMessageRoleResource');
    return switch (value) {
      'user' => user,
      'assistant' => assistant,
      _ => AgentSessionMessageRoleResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['user', 'assistant'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionMessageRoleResource copyWith({String? value}) =>
      AgentSessionMessageRoleResource.fromJson(value ?? this.value);
}

/// The current status of a session.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionStatusResource extends AgentJsonModel {
  const AgentSessionStatusResource._(this.value);

  /// The `idle` wire value.
  static const AgentSessionStatusResource idle = AgentSessionStatusResource._(
    'idle',
  );

  /// The `in_progress` wire value.
  static const AgentSessionStatusResource inProgress =
      AgentSessionStatusResource._('in_progress');

  /// The `requires_action` wire value.
  static const AgentSessionStatusResource requiresAction =
      AgentSessionStatusResource._('requires_action');

  /// The `failed` wire value.
  static const AgentSessionStatusResource failed = AgentSessionStatusResource._(
    'failed',
  );

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionStatusResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionStatusResource');
    return switch (value) {
      'idle' => idle,
      'in_progress' => inProgress,
      'requires_action' => requiresAction,
      'failed' => failed,
      _ => AgentSessionStatusResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'idle',
    'in_progress',
    'requires_action',
    'failed',
  ].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionStatusResource copyWith({String? value}) =>
      AgentSessionStatusResource.fromJson(value ?? this.value);
}

/// Stable public categories for session request failures.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionTurnErrorCodeResource extends AgentJsonModel {
  const AgentSessionTurnErrorCodeResource._(this.value);

  /// The `context_length_exceeded` wire value.
  static const AgentSessionTurnErrorCodeResource contextLengthExceeded =
      AgentSessionTurnErrorCodeResource._('context_length_exceeded');

  /// The `session_budget_exceeded` wire value.
  static const AgentSessionTurnErrorCodeResource sessionBudgetExceeded =
      AgentSessionTurnErrorCodeResource._('session_budget_exceeded');

  /// The `usage_limit_exceeded` wire value.
  static const AgentSessionTurnErrorCodeResource usageLimitExceeded =
      AgentSessionTurnErrorCodeResource._('usage_limit_exceeded');

  /// The `project_spend_limit_exceeded` wire value.
  static const AgentSessionTurnErrorCodeResource projectSpendLimitExceeded =
      AgentSessionTurnErrorCodeResource._('project_spend_limit_exceeded');

  /// The `organization_spend_limit_exceeded` wire value.
  static const AgentSessionTurnErrorCodeResource
  organizationSpendLimitExceeded = AgentSessionTurnErrorCodeResource._(
    'organization_spend_limit_exceeded',
  );

  /// The `organization_usage_limit_exceeded` wire value.
  static const AgentSessionTurnErrorCodeResource
  organizationUsageLimitExceeded = AgentSessionTurnErrorCodeResource._(
    'organization_usage_limit_exceeded',
  );

  /// The `billing_not_active` wire value.
  static const AgentSessionTurnErrorCodeResource billingNotActive =
      AgentSessionTurnErrorCodeResource._('billing_not_active');

  /// The `credit_balance_exhausted` wire value.
  static const AgentSessionTurnErrorCodeResource creditBalanceExhausted =
      AgentSessionTurnErrorCodeResource._('credit_balance_exhausted');

  /// The `rate_limit_exceeded` wire value.
  static const AgentSessionTurnErrorCodeResource rateLimitExceeded =
      AgentSessionTurnErrorCodeResource._('rate_limit_exceeded');

  /// The `flex_unavailable` wire value.
  static const AgentSessionTurnErrorCodeResource flexUnavailable =
      AgentSessionTurnErrorCodeResource._('flex_unavailable');

  /// The `server_overloaded` wire value.
  static const AgentSessionTurnErrorCodeResource serverOverloaded =
      AgentSessionTurnErrorCodeResource._('server_overloaded');

  /// The `cyber_policy` wire value.
  static const AgentSessionTurnErrorCodeResource cyberPolicy =
      AgentSessionTurnErrorCodeResource._('cyber_policy');

  /// The `misalignment_policy_violation` wire value.
  static const AgentSessionTurnErrorCodeResource misalignmentPolicyViolation =
      AgentSessionTurnErrorCodeResource._('misalignment_policy_violation');

  /// The `connection_failed` wire value.
  static const AgentSessionTurnErrorCodeResource connectionFailed =
      AgentSessionTurnErrorCodeResource._('connection_failed');

  /// The `server_error` wire value.
  static const AgentSessionTurnErrorCodeResource serverError =
      AgentSessionTurnErrorCodeResource._('server_error');

  /// The `authentication_error` wire value.
  static const AgentSessionTurnErrorCodeResource authenticationError =
      AgentSessionTurnErrorCodeResource._('authentication_error');

  /// The `invalid_request` wire value.
  static const AgentSessionTurnErrorCodeResource invalidRequest =
      AgentSessionTurnErrorCodeResource._('invalid_request');

  /// The `resource_not_found` wire value.
  static const AgentSessionTurnErrorCodeResource resourceNotFound =
      AgentSessionTurnErrorCodeResource._('resource_not_found');

  /// The `sandbox_error` wire value.
  static const AgentSessionTurnErrorCodeResource sandboxError =
      AgentSessionTurnErrorCodeResource._('sandbox_error');

  /// The `executor_version_incompatible` wire value.
  static const AgentSessionTurnErrorCodeResource executorVersionIncompatible =
      AgentSessionTurnErrorCodeResource._('executor_version_incompatible');

  /// The `active_turn_not_steerable` wire value.
  static const AgentSessionTurnErrorCodeResource activeTurnNotSteerable =
      AgentSessionTurnErrorCodeResource._('active_turn_not_steerable');

  /// The `request_timeout` wire value.
  static const AgentSessionTurnErrorCodeResource requestTimeout =
      AgentSessionTurnErrorCodeResource._('request_timeout');

  /// The `internal_error` wire value.
  static const AgentSessionTurnErrorCodeResource internalError =
      AgentSessionTurnErrorCodeResource._('internal_error');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionTurnErrorCodeResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionTurnErrorCodeResource');
    return switch (value) {
      'context_length_exceeded' => contextLengthExceeded,
      'session_budget_exceeded' => sessionBudgetExceeded,
      'usage_limit_exceeded' => usageLimitExceeded,
      'project_spend_limit_exceeded' => projectSpendLimitExceeded,
      'organization_spend_limit_exceeded' => organizationSpendLimitExceeded,
      'organization_usage_limit_exceeded' => organizationUsageLimitExceeded,
      'billing_not_active' => billingNotActive,
      'credit_balance_exhausted' => creditBalanceExhausted,
      'rate_limit_exceeded' => rateLimitExceeded,
      'flex_unavailable' => flexUnavailable,
      'server_overloaded' => serverOverloaded,
      'cyber_policy' => cyberPolicy,
      'misalignment_policy_violation' => misalignmentPolicyViolation,
      'connection_failed' => connectionFailed,
      'server_error' => serverError,
      'authentication_error' => authenticationError,
      'invalid_request' => invalidRequest,
      'resource_not_found' => resourceNotFound,
      'sandbox_error' => sandboxError,
      'executor_version_incompatible' => executorVersionIncompatible,
      'active_turn_not_steerable' => activeTurnNotSteerable,
      'request_timeout' => requestTimeout,
      'internal_error' => internalError,
      _ => AgentSessionTurnErrorCodeResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'context_length_exceeded',
    'session_budget_exceeded',
    'usage_limit_exceeded',
    'project_spend_limit_exceeded',
    'organization_spend_limit_exceeded',
    'organization_usage_limit_exceeded',
    'billing_not_active',
    'credit_balance_exhausted',
    'rate_limit_exceeded',
    'flex_unavailable',
    'server_overloaded',
    'cyber_policy',
    'misalignment_policy_violation',
    'connection_failed',
    'server_error',
    'authentication_error',
    'invalid_request',
    'resource_not_found',
    'sandbox_error',
    'executor_version_incompatible',
    'active_turn_not_steerable',
    'request_timeout',
    'internal_error',
  ].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionTurnErrorCodeResource copyWith({String? value}) =>
      AgentSessionTurnErrorCodeResource.fromJson(value ?? this.value);
}

/// The object type for a subagent.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionSubagentObjectResource extends AgentJsonModel {
  const AgentSessionSubagentObjectResource._(this.value);

  /// The `agent.session.subagent` wire value.
  static const AgentSessionSubagentObjectResource agentSessionSubagent =
      AgentSessionSubagentObjectResource._('agent.session.subagent');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionSubagentObjectResource.fromJson(Object? json) {
    final value = requireAgentString(
      json,
      'AgentSessionSubagentObjectResource',
    );
    return switch (value) {
      'agent.session.subagent' => agentSessionSubagent,
      _ => AgentSessionSubagentObjectResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['agent.session.subagent'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionSubagentObjectResource copyWith({String? value}) =>
      AgentSessionSubagentObjectResource.fromJson(value ?? this.value);
}

/// The current status of a subagent.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionSubagentStatusResource extends AgentJsonModel {
  const AgentSessionSubagentStatusResource._(this.value);

  /// The `active` wire value.
  static const AgentSessionSubagentStatusResource active =
      AgentSessionSubagentStatusResource._('active');

  /// The `closed` wire value.
  static const AgentSessionSubagentStatusResource closed =
      AgentSessionSubagentStatusResource._('closed');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionSubagentStatusResource.fromJson(Object? json) {
    final value = requireAgentString(
      json,
      'AgentSessionSubagentStatusResource',
    );
    return switch (value) {
      'active' => active,
      'closed' => closed,
      _ => AgentSessionSubagentStatusResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['active', 'closed'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionSubagentStatusResource copyWith({String? value}) =>
      AgentSessionSubagentStatusResource.fromJson(value ?? this.value);
}

/// The object type for a turn.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionTurnObjectResource extends AgentJsonModel {
  const AgentSessionTurnObjectResource._(this.value);

  /// The `agent.session.turn` wire value.
  static const AgentSessionTurnObjectResource agentSessionTurn =
      AgentSessionTurnObjectResource._('agent.session.turn');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionTurnObjectResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionTurnObjectResource');
    return switch (value) {
      'agent.session.turn' => agentSessionTurn,
      _ => AgentSessionTurnObjectResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['agent.session.turn'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionTurnObjectResource copyWith({String? value}) =>
      AgentSessionTurnObjectResource.fromJson(value ?? this.value);
}

/// The current status of a turn.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentSessionTurnStatusResource extends AgentJsonModel {
  const AgentSessionTurnStatusResource._(this.value);

  /// The `queued` wire value.
  static const AgentSessionTurnStatusResource queued =
      AgentSessionTurnStatusResource._('queued');

  /// The `in_progress` wire value.
  static const AgentSessionTurnStatusResource inProgress =
      AgentSessionTurnStatusResource._('in_progress');

  /// The `waiting` wire value.
  static const AgentSessionTurnStatusResource waiting =
      AgentSessionTurnStatusResource._('waiting');

  /// The `completed` wire value.
  static const AgentSessionTurnStatusResource completed =
      AgentSessionTurnStatusResource._('completed');

  /// The `failed` wire value.
  static const AgentSessionTurnStatusResource failed =
      AgentSessionTurnStatusResource._('failed');

  /// The `cancelled` wire value.
  static const AgentSessionTurnStatusResource cancelled =
      AgentSessionTurnStatusResource._('cancelled');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentSessionTurnStatusResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionTurnStatusResource');
    return switch (value) {
      'queued' => queued,
      'in_progress' => inProgress,
      'waiting' => waiting,
      'completed' => completed,
      'failed' => failed,
      'cancelled' => cancelled,
      _ => AgentSessionTurnStatusResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'queued',
    'in_progress',
    'waiting',
    'completed',
    'failed',
    'cancelled',
  ].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future wire value.
  AgentSessionTurnStatusResource copyWith({String? value}) =>
      AgentSessionTurnStatusResource.fromJson(value ?? this.value);
}
