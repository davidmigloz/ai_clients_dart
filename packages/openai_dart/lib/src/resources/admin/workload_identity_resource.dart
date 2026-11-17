import '../../client/admin_http.dart';
import '../../models/admin/admin.dart';

const _providersPath = '/organization/workload_identity_providers';

/// Organization workload identity provider management.
final class AdminWorkloadIdentityProvidersResource {
  /// Creates a resource sharing the Admin HTTP policy.
  AdminWorkloadIdentityProvidersResource(this._http);

  final AdminHttp _http;
  AdminWorkloadIdentityFederationRulesResource? _federationRules;

  /// Rules that map an external identity to a project service account.
  AdminWorkloadIdentityFederationRulesResource get federationRules {
    _http.ensureOpen();
    return _federationRules ??= AdminWorkloadIdentityFederationRulesResource(
      _http,
    );
  }

  /// Creates a workload identity provider.
  Future<WorkloadIdentityProvider> create(
    CreateWorkloadIdentityProviderRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    request.validate();
    return _http.json(
      'POST',
      _providersPath,
      WorkloadIdentityProvider.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Returns a single page of providers.
  Future<WorkloadIdentityCursorPage<WorkloadIdentityProvider>> list({
    int? limit,
    AdminListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    return _http.json(
      'GET',
      _providersPath,
      (json) => WorkloadIdentityCursorPage<WorkloadIdentityProvider>.fromJson(
        json,
        WorkloadIdentityProvider.fromJson,
      ),
      query: _pageQuery(limit: limit, order: order, after: after),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves a provider by ID.
  Future<WorkloadIdentityProvider> retrieve(
    String providerId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'GET',
    _providerPath(_http, providerId),
    WorkloadIdentityProvider.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  /// Updates the supplied fields on a provider.
  Future<WorkloadIdentityProvider> update(
    String providerId,
    UpdateWorkloadIdentityProviderRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    final path = _providerPath(_http, providerId);
    request.validate();
    return _http.json(
      'POST',
      path,
      WorkloadIdentityProvider.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes a provider.
  Future<WorkloadIdentityDeletion> delete(
    String providerId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'DELETE',
    _providerPath(_http, providerId),
    (json) => WorkloadIdentityDeletion.fromJson(
      json,
      expectedObject: 'organization.workload_identity_provider.deleted',
    ),
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );
}

/// Admin operations for rules nested under workload identity providers.
final class AdminWorkloadIdentityFederationRulesResource {
  /// Creates a resource sharing the Admin HTTP policy.
  AdminWorkloadIdentityFederationRulesResource(this._http);

  final AdminHttp _http;

  /// Creates a federation rule under [providerId].
  Future<WorkloadIdentityFederationRule> create(
    String providerId,
    CreateWorkloadIdentityFederationRuleRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    final path = _collectionPath(providerId);
    request.validate();
    return _http.json(
      'POST',
      path,
      WorkloadIdentityFederationRule.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Returns a single page of rules, optionally filtered by service account.
  Future<WorkloadIdentityCursorPage<WorkloadIdentityFederationRule>> list(
    String providerId, {
    int? limit,
    AdminListOrder? order,
    String? after,
    String? serviceAccountId,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'GET',
    _collectionPath(providerId),
    (json) =>
        WorkloadIdentityCursorPage<WorkloadIdentityFederationRule>.fromJson(
          json,
          WorkloadIdentityFederationRule.fromJson,
        ),
    query: _pageQuery(
      limit: limit,
      order: order,
      after: after,
      serviceAccountId: serviceAccountId,
    ),
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  /// Retrieves one rule under [providerId].
  Future<WorkloadIdentityFederationRule> retrieve(
    String providerId,
    String ruleId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'GET',
    _itemPath(providerId, ruleId),
    WorkloadIdentityFederationRule.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  /// Updates the supplied fields on a rule.
  Future<WorkloadIdentityFederationRule> update(
    String providerId,
    String ruleId,
    UpdateWorkloadIdentityFederationRuleRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    final path = _itemPath(providerId, ruleId);
    request.validate();
    return _http.json(
      'POST',
      path,
      WorkloadIdentityFederationRule.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes one rule under [providerId].
  Future<WorkloadIdentityDeletion> delete(
    String providerId,
    String ruleId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'DELETE',
    _itemPath(providerId, ruleId),
    (json) => WorkloadIdentityDeletion.fromJson(
      json,
      expectedObject: 'organization.workload_identity_federation_rule.deleted',
    ),
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  String _collectionPath(String providerId) =>
      '${_providerPath(_http, providerId)}/federation_rules';

  String _itemPath(String providerId, String ruleId) =>
      '${_collectionPath(providerId)}/${adminPathId(ruleId, 'ruleId')}';
}

String _providerPath(AdminHttp http, String providerId) {
  http.ensureOpen();
  return '$_providersPath/${adminPathId(providerId, 'providerId')}';
}

Map<String, String> _pageQuery({
  int? limit,
  AdminListOrder? order,
  String? after,
  String? serviceAccountId,
}) {
  if (limit != null && (limit < 1 || limit > 100)) {
    throw const FormatException(
      'limit: expected an integer from 1 through 100',
    );
  }
  if (order != null && !order.isKnown) {
    throw const FormatException('order: expected asc or desc');
  }
  return {
    if (limit != null) 'limit': '$limit',
    if (order != null) 'order': order.value,
    if (after != null) 'after': _queryId(after, 'after'),
    if (serviceAccountId != null)
      'service_account_id': _queryId(serviceAccountId, 'serviceAccountId'),
  };
}

String _queryId(String value, String context) {
  if (value.isEmpty) throw FormatException('$context: invalid identifier');
  return adminQueryString(value, context);
}
