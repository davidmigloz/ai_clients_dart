import '../../models/common/copy_with_sentinel.dart';
import '../../models/organization/federation_rule.dart';
import '../../models/organization/organization_page.dart';
import 'organization_transport.dart';

/// Manages authorization rules for Workload Identity Federation.
///
/// Use an OAuth access token with `org:admin`. OAuth callers can write rules
/// with `workspace:developer` or `workspace:inference` scope. Other rule
/// scopes are configured in Claude Console.
final class OrganizationFederationRulesResource {
  /// Creates the federation rules resource.
  OrganizationFederationRulesResource(this._transport)
    : workspaces = OrganizationFederationRuleWorkspacesResource(_transport);

  final OrganizationTransport _transport;

  /// Workspaces in which a federation rule is enabled.
  final OrganizationFederationRuleWorkspacesResource workspaces;

  /// Lists rules with an optional issuer filter and opaque pagination.
  Future<OrganizationCursorPage<FederationRule>> list({
    String? issuerId,
    bool? includeArchived,
    String? page,
    int? limit,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/federation_rules',
    (json) => OrganizationCursorPage.fromJson(json, FederationRule.fromJson),
    query: {
      ..._page(page, limit),
      'issuer_id': ?issuerId,
      'include_archived': ?includeArchived?.toString(),
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Creates a rule. Supply a [workspaceId] or enable it for every workspace.
  ///
  /// [attributes] is reserved for CEL-derived attributes. The service accepts
  /// only an empty map or omission while attribute extraction is unavailable.
  Future<FederationRule> create({
    required String issuerId,
    required String name,
    required FederationRuleMatch match,
    required FederationServiceAccountTarget target,
    required String oauthScope,
    String? workspaceId,
    bool? appliesToAllWorkspaces,
    String? description,
    int? tokenLifetimeSeconds,
    Map<String, String>? attributes,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) {
    if (appliesToAllWorkspaces != true && workspaceId?.isNotEmpty != true) {
      throw ArgumentError('Select a workspace or enable the rule for all.');
    }
    _validateMatch(match);
    _validateLifetime(tokenLifetimeSeconds);
    _validateAttributes(attributes);
    return _transport.send(
      'POST',
      '/federation_rules',
      FederationRule.fromJson,
      body: {
        'issuer_id': issuerId,
        'name': name,
        'match': match.toJson(),
        'target': target.toRequestJson(),
        'oauth_scope': oauthScope,
        'workspace_id': ?workspaceId,
        'applies_to_all_workspaces': ?appliesToAllWorkspaces,
        'description': ?description,
        'token_lifetime_seconds': ?tokenLifetimeSeconds,
        'attributes': ?attributes,
      },
      beta: _beta(betas),
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves one federation rule.
  Future<FederationRule> retrieve(
    String ruleId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _rulePath(ruleId),
    FederationRule.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Updates the fields supplied. Pass null to clear [description] or
  /// [attributes]. When supplied, [match] and [target] replace their objects.
  Future<FederationRule> update(
    String ruleId, {
    String? name,
    FederationRuleMatch? match,
    FederationServiceAccountTarget? target,
    String? oauthScope,
    String? workspaceId,
    bool? appliesToAllWorkspaces,
    Object? description = unsetCopyWithValue,
    int? tokenLifetimeSeconds,
    Object? attributes = unsetCopyWithValue,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) {
    if (match != null) _validateMatch(match);
    _validateLifetime(tokenLifetimeSeconds);
    final hasAttributes = !identical(attributes, unsetCopyWithValue);
    final attributeMap = hasAttributes && attributes != null
        ? Map<String, String>.from(attributes as Map)
        : null;
    _validateAttributes(attributeMap);
    return _transport.send(
      'POST',
      _rulePath(ruleId),
      FederationRule.fromJson,
      body: {
        'name': ?name,
        'match': ?match?.toJson(),
        'target': ?target?.toRequestJson(),
        'oauth_scope': ?oauthScope,
        'workspace_id': ?workspaceId,
        'applies_to_all_workspaces': ?appliesToAllWorkspaces,
        if (!identical(description, unsetCopyWithValue))
          'description': description as String?,
        'token_lifetime_seconds': ?tokenLifetimeSeconds,
        if (hasAttributes) 'attributes': attributeMap,
      },
      beta: _beta(betas),
      abortTrigger: abortTrigger,
    );
  }

  /// Archives a federation rule and prevents future exchanges against it.
  Future<FederationRule> archive(
    String ruleId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_rulePath(ruleId)}/archive',
    FederationRule.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );
}

/// Manages the workspaces enabled for one federation rule.
final class OrganizationFederationRuleWorkspacesResource {
  /// Creates the rule's workspace resource.
  const OrganizationFederationRuleWorkspacesResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists enabled workspaces with opaque pagination.
  Future<OrganizationCursorPage<FederationRuleWorkspace>> list(
    String ruleId, {
    String? page,
    int? limit,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '${_rulePath(ruleId)}/workspaces',
    (json) =>
        OrganizationCursorPage.fromJson(json, FederationRuleWorkspace.fromJson),
    query: _page(page, limit),
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Enables the rule in the specified workspace.
  Future<FederationRuleWorkspace> add(
    String ruleId, {
    required String workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_rulePath(ruleId)}/workspaces',
    FederationRuleWorkspace.fromJson,
    body: {'workspace_id': workspaceId},
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Removes a workspace binding.
  Future<DeletedFederationRuleWorkspace> remove(
    String ruleId,
    String workspaceId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    '${_rulePath(ruleId)}/workspaces/'
        '${organizationIdSegment(workspaceId, 'workspaceId')}',
    DeletedFederationRuleWorkspace.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );
}

Map<String, dynamic> _page(String? page, int? limit) => {
  'page': ?page,
  'limit': ?limit?.toString(),
};

String _rulePath(String ruleId) =>
    '/federation_rules/${organizationIdSegment(ruleId, 'ruleId')}';

String? _beta(List<String> values) => values.isEmpty ? null : values.join(',');

void _validateMatch(FederationRuleMatch match) {
  final subject = match.subjectPrefix?.trim() ?? '';
  final hasSubject = subject.isNotEmpty && !RegExp(r'^\*+$').hasMatch(subject);
  if (!hasSubject &&
      match.claims?.isNotEmpty != true &&
      match.condition?.trim().isNotEmpty != true) {
    throw ArgumentError(
      'A rule needs a subject, a claim matcher, or a CEL condition.',
    );
  }
}

void _validateLifetime(int? seconds) {
  if (seconds != null) RangeError.checkValueInInterval(seconds, 60, 86400);
}

void _validateAttributes(Map<String, String>? attributes) {
  if (attributes?.isNotEmpty == true) {
    throw ArgumentError('Federation attribute extraction is unavailable.');
  }
}
