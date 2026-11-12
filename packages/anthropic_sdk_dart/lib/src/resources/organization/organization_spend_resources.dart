import '../../models/organization/organization_page.dart';
import '../../models/organization/organization_spend.dart';
import 'organization_transport.dart';

/// Reads and manages configured and effective organization spend limits.
final class OrganizationSpendLimitsResource {
  /// Creates the spend-limit resource.
  OrganizationSpendLimitsResource(this._transport)
    : increaseRequests = OrganizationSpendIncreaseRequestsResource(_transport);

  final OrganizationTransport _transport;

  /// Member requests for spend-limit increases.
  final OrganizationSpendIncreaseRequestsResource increaseRequests;

  /// Lists configured limits. Claude Console reads may require preview access.
  Future<OrganizationCursorPage<OrganizationSpendLimit>> list({
    List<String>? scopeTypes,
    String? workspaceId,
    String? page,
    int? limit,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/spend_limits',
    (json) =>
        OrganizationCursorPage.fromJson(json, OrganizationSpendLimit.fromJson),
    query: {
      ...organizationCursorQuery(page, limit),
      'scope_type[]': ?scopeTypes,
      'workspace_id': ?workspaceId,
    },
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: 'spend-limit-reads-2026-09-26',
    abortTrigger: abortTrigger,
  );

  /// Retrieves one configured limit.
  Future<OrganizationSpendLimit> retrieve(
    String spendLimitId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _limit(spendLimitId),
    OrganizationSpendLimit.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Sets a user, organization, or workspace limit for the selected period.
  ///
  /// [amount] is a non-negative integer string in billing minor units.
  /// A user override can pass null to remove the numeric cap for that period.
  /// Console organization and workspace limits are monthly and need an amount.
  Future<OrganizationSpendLimit> set({
    required OrganizationSpendScope scope,
    required String? amount,
    OrganizationSpendPeriod? period,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) {
    final target = switch (scope.type) {
      'user' => {'type': 'user', 'user_id': scope.userId!},
      'organization' => {'type': 'organization'},
      'workspace' => {'type': 'workspace', 'workspace_id': scope.workspaceId!},
      _ => throw ArgumentError.value(
        scope.type,
        'scope',
        'Unsupported write scope',
      ),
    };
    if (scope.type != 'user') {
      if (amount == null) {
        throw ArgumentError.notNull('amount');
      }
      if (period != null && period != OrganizationSpendPeriod.monthly) {
        throw ArgumentError.value(period, 'period', 'Expected monthly');
      }
    }
    return _transport.send(
      'POST',
      '/spend_limits',
      OrganizationSpendLimit.fromJson,
      body: {
        'scope': target,
        'amount': amount == null ? null : _spendAmount(amount),
        'period': ?period?.name,
      },
      beta: betas.isEmpty ? null : betas.join(','),
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes one configured limit.
  Future<DeletedOrganizationSpendLimit> delete(
    String spendLimitId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _limit(spendLimitId),
    DeletedOrganizationSpendLimit.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Lists effective limits and current spend by member and reset period.
  Future<OrganizationCursorPage<OrganizationEffectiveSpendLimit>>
  listEffective({
    List<String>? userIds,
    List<OrganizationSpendPeriod>? periods,
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/spend_limits/effective',
    (json) => OrganizationCursorPage.fromJson(
      json,
      OrganizationEffectiveSpendLimit.fromJson,
    ),
    query: {
      ...organizationCursorQuery(page, limit),
      'user_ids[]': ?userIds,
      'period[]': ?periods?.map((period) => period.name).toList(),
    },
    abortTrigger: abortTrigger,
  );

  static String _limit(String id) =>
      '/spend_limits/${organizationIdSegment(id, 'spendLimitId')}';
}

/// Reads and resolves member requests for an increased limit.
final class OrganizationSpendIncreaseRequestsResource {
  /// Creates the increase-request resource.
  const OrganizationSpendIncreaseRequestsResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists increase requests with optional actor and status filters.
  Future<OrganizationCursorPage<OrganizationSpendIncreaseRequest>> list({
    List<String>? actorIds,
    List<String>? statuses,
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/spend_limit_increase_requests',
    (json) => OrganizationCursorPage.fromJson(
      json,
      OrganizationSpendIncreaseRequest.fromJson,
    ),
    query: {
      ...organizationCursorQuery(page, limit),
      'actor_ids[]': ?actorIds,
      'status[]': ?statuses,
    },
    abortTrigger: abortTrigger,
  );

  /// Retrieves a request by ID.
  Future<OrganizationSpendIncreaseRequest> retrieve(
    String requestId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _request(requestId),
    OrganizationSpendIncreaseRequest.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Approves a request and sets the member's new limit.
  Future<OrganizationSpendIncreaseRequest> approve(
    String requestId, {
    required String amount,
    OrganizationSpendPeriod? period,
    bool? suppressNotification,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_request(requestId)}/approve',
    (json) => OrganizationSpendIncreaseRequest.fromJson(json, approval: true),
    body: {
      'amount': _spendAmount(amount),
      'period': ?period?.name,
      'suppress_notification': ?suppressNotification,
    },
    abortTrigger: abortTrigger,
  );

  /// Denies a request without modifying the member's configured limit.
  Future<OrganizationSpendIncreaseRequest> deny(
    String requestId, {
    bool? suppressNotification,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_request(requestId)}/deny',
    OrganizationSpendIncreaseRequest.fromJson,
    body: {'suppress_notification': ?suppressNotification},
    abortTrigger: abortTrigger,
  );

  static String _request(String id) =>
      '/spend_limit_increase_requests/${organizationIdSegment(id, 'requestId')}';
}

final _minorUnits = RegExp(r'^[0-9]+$');

String _spendAmount(String amount) {
  if (!_minorUnits.hasMatch(amount)) {
    throw ArgumentError.value(amount, 'amount', 'Expected integer minor units');
  }
  return amount;
}
