/// Error codes for observability API errors.
enum ObservabilityErrorCode {
  /// An unknown error occurred.
  unknownError('UNKNOWN_ERROR'),

  /// Request validation failed.
  validationError('VALIDATION_ERROR'),

  /// Authorization forbidden.
  authForbidden('AUTH_FORBIDDEN'),

  /// Not a workspace admin.
  authForbiddenNotWorkspaceAdmin('AUTH_FORBIDDEN_NOT_WORKSPACE_ADMIN'),

  /// Workspace not found.
  authForbiddenWorkspaceNotFound('AUTH_FORBIDDEN_WORKSPACE_NOT_FOUND'),

  /// Role not found.
  authForbiddenRoleNotFound('AUTH_FORBIDDEN_ROLE_NOT_FOUND'),

  /// Organization not whitelisted.
  authForbiddenOrgNotWhitelisted('AUTH_FORBIDDEN_ORG_NOT_WHITELISTED'),

  /// Unauthorized.
  authUnauthorized('AUTH_UNAUTHORIZED'),

  /// Feature not supported.
  featureNotSupported('FEATURE_NOT_SUPPORTED'),

  /// Bad request for fields.
  fieldsBadRequest('FIELDS_BAD_REQUEST'),

  /// Fields not found.
  fieldsNotFound('FIELDS_NOT_FOUND'),

  /// Search not found.
  searchNotFound('SEARCH_NOT_FOUND'),

  /// Bad search request.
  searchBadRequest('SEARCH_BAD_REQUEST'),

  /// Search service unavailable.
  searchServiceUnavailable('SEARCH_SERVICE_UNAVAILABLE'),

  /// Database error.
  databaseError('DATABASE_ERROR'),

  /// Database timeout.
  databaseTimeout('DATABASE_TIMEOUT'),

  /// Database unavailable.
  databaseUnavailable('DATABASE_UNAVAILABLE'),

  /// Database query error.
  databaseQueryError('DATABASE_QUERY_ERROR'),

  /// Filter to SQL conversion error.
  searchFilterToSqlConversionError('SEARCH_FILTER_TO_SQL_CONVERSION_ERROR'),

  /// Judge conversation format error.
  judgeConversationFormatError('JUDGE_CONVERSATION_FORMAT_ERROR'),

  /// Judge Mistral API error.
  judgeMistralApiError('JUDGE_MISTRAL_API_ERROR'),

  /// Judge Mistral API timeout.
  judgeMistralApiTimeout('JUDGE_MISTRAL_API_TIMEOUT'),

  /// Judge name already exists.
  judgeNameAlreadyExists('JUDGE_NAME_ALREADY_EXISTS'),

  /// Judge not found.
  judgeNotFound('JUDGE_NOT_FOUND'),

  /// Judge already has a new version.
  judgeAlreadyHasNewVersion('JUDGE_ALREADY_HAS_NEW_VERSION'),

  /// Judge used in campaign cannot be updated.
  judgeUsedInCampaignCannotBeUpdated(
    'JUDGE_USED_IN_CAMPAIGN_CANNOT_BE_UPDATED',
  ),

  /// Judge did not change.
  judgeDidNotChange('JUDGE_DID_NOT_CHANGE'),

  /// Campaign not found.
  campaignNotFound('CAMPAIGN_NOT_FOUND'),

  /// Campaign has no matching events.
  campaignNoMatchingEvents('CAMPAIGN_NO_MATCHING_EVENTS'),

  /// Dataset not found.
  datasetNotFound('DATASET_NOT_FOUND'),

  /// Dataset task not found.
  datasetTaskNotFound('DATASET_TASK_NOT_FOUND'),

  /// Dataset record not found.
  datasetRecordNotFound('DATASET_RECORD_NOT_FOUND'),

  /// Dataset record format error.
  datasetRecordFormatError('DATASET_RECORD_FORMAT_ERROR'),

  /// Agent not found.
  agentNotFound('AGENT_NOT_FOUND'),

  /// Agent Mistral API error.
  agentMistralApiError('AGENT_MISTRAL_API_ERROR'),

  /// Evaluation not found.
  evaluationNotFound('EVALUATION_NOT_FOUND'),

  /// Evaluation currently running.
  evaluationCurrentlyRunning('EVALUATION_CURRENTLY_RUNNING'),

  /// Evaluation record not found.
  evaluationRecordNotFound('EVALUATION_RECORD_NOT_FOUND'),

  /// Evaluation run not found.
  evaluationRunNotFound('EVALUATION_RUN_NOT_FOUND'),

  /// Evaluation run transition is invalid.
  evaluationRunTransitionIsInvalid('EVALUATION_RUN_TRANSITION_IS_INVALID'),

  /// Evaluation run is already running.
  evaluationRunTransitionIsRunningAlready(
    'EVALUATION_RUN_TRANSITION_IS_RUNNING_ALREADY',
  ),

  /// Evaluation run transition error.
  evaluationRunTransitionError('EVALUATION_RUN_TRANSITION_ERROR'),

  /// Template syntax error.
  templateSyntaxError('TEMPLATE_SYNTAX_ERROR'),

  /// Unknown error code (forward-compatible fallback).
  unknown('UNKNOWN');

  const ObservabilityErrorCode(this.value);

  /// The string value of this error code.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates an [ObservabilityErrorCode] from a JSON value.
  static ObservabilityErrorCode fromJson(String? value) => fromString(value);

  /// Creates an [ObservabilityErrorCode] from a string value.
  static ObservabilityErrorCode fromString(String? value) {
    if (value == null) return ObservabilityErrorCode.unknown;
    return ObservabilityErrorCode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ObservabilityErrorCode.unknown,
    );
  }
}
