import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// Reset windows accepted by the spend-limit requests.
enum OrganizationSpendPeriod {
  /// Resets every day.
  daily,

  /// Resets every week.
  weekly,

  /// Resets every month.
  monthly,
}

@immutable
abstract class _SpendRecord {
  _SpendRecord(Map<String, dynamic> json) : _json = deepUnmodifiableMap(json);

  final Map<String, dynamic> _json;

  T _field<T>(String name) =>
      requiredOrganizationField<T>(_json, name, runtimeType.toString());

  /// Converts the record to JSON without dropping unknown provider fields.
  Map<String, dynamic> toJson() => _json;

  @override
  bool operator ==(Object other) =>
      other is _SpendRecord &&
      runtimeType == other.runtimeType &&
      mapsDeepEqual(_json, other._json);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_json));
}

/// The member or scoped API key involved in a spend-limit operation.
final class OrganizationSpendActor extends _SpendRecord {
  /// Parses the actor and preserves future discriminator values.
  OrganizationSpendActor.fromJson(super.json) {
    type = _field<String>('type');
    switch (type) {
      case 'user_actor':
        _field<String>('user_id');
        _field<String?>('email_address');
        _field<String?>('name');
        _field<bool>('deleted');
      case 'scoped_api_key_actor':
        _field<String>('scoped_api_key_id');
    }
  }

  /// The original actor type.
  late final String type;

  /// Member ID for a user actor.
  String? get userId => _json['user_id'] as String?;

  /// Email address for a user actor, if disclosed.
  String? get emailAddress => _json['email_address'] as String?;

  /// Name for a user actor, if disclosed.
  String? get name => _json['name'] as String?;

  /// Whether the user was deleted.
  bool? get deleted => _json['deleted'] as bool?;

  /// Key ID for a scoped API key actor.
  String? get scopedApiKeyId => _json['scoped_api_key_id'] as String?;
}

/// The entity or rule that a spend limit applies to.
final class OrganizationSpendScope extends _SpendRecord {
  /// Parses current and future spend-limit scopes.
  OrganizationSpendScope.fromJson(super.json) {
    type = _field<String>('type');
    switch (type) {
      case 'user':
        _field<String>('user_id');
      case 'workspace':
        _field<String>('workspace_id');
      case 'seat_tier':
        _field<String>('seat_tier');
      case 'rbac_group':
        _field<String>('rbac_group_id');
      case 'organization_service':
        _field<String>('service');
    }
  }

  /// Sets a limit on an Enterprise organization member.
  factory OrganizationSpendScope.user(String userId) =>
      OrganizationSpendScope.fromJson({'type': 'user', 'user_id': userId});

  /// Sets a limit on a Claude Console organization.
  factory OrganizationSpendScope.organization() =>
      OrganizationSpendScope.fromJson(const {'type': 'organization'});

  /// Sets a limit on a Claude Console workspace.
  factory OrganizationSpendScope.workspace(String workspaceId) =>
      OrganizationSpendScope.fromJson({
        'type': 'workspace',
        'workspace_id': workspaceId,
      });

  /// The wire scope discriminator.
  late final String type;

  /// The user ID for a user-scoped limit.
  String? get userId => _json['user_id'] as String?;

  /// The workspace ID for a workspace-scoped limit.
  String? get workspaceId => _json['workspace_id'] as String?;

  /// The tier name for a seat-tier limit.
  String? get seatTier => _json['seat_tier'] as String?;

  /// The group ID for a group-scoped limit.
  String? get groupId => _json['rbac_group_id'] as String?;

  /// The service name for an organization service limit.
  String? get service => _json['service'] as String?;
}

/// A configured spend limit and its billing scope.
final class OrganizationSpendLimit extends _SpendRecord {
  /// Parses a configured limit.
  OrganizationSpendLimit.fromJson(Map<String, dynamic> json) : super(json) {
    checkOrganizationType(json, 'spend_limit');
    id = _field<String>('id');
    amount = _field<String?>('amount');
    currency = _field<String>('currency');
    period = _field<String>('period');
    isEnabled = _field<bool>('is_enabled');
    scope = OrganizationSpendScope.fromJson(_field('scope'));
    createdAt = DateTime.parse(_field('created_at'));
    updatedAt = DateTime.parse(_field('updated_at'));
  }

  /// Tagged limit ID.
  late final String id;

  /// Exact integer decimal in minor units, or null for no numeric cap.
  late final String? amount;

  /// ISO 4217 billing currency.
  late final String currency;

  /// Reset window as sent by the server.
  late final String period;

  /// Whether this limit is in force.
  late final bool isEnabled;

  /// What the configured limit applies to.
  late final OrganizationSpendScope scope;

  /// When the limit was first set.
  late final DateTime createdAt;

  /// When the limit was last changed.
  late final DateTime updatedAt;
}

/// The effective limit and measured spend for one actor and period.
final class OrganizationEffectiveSpendLimit extends _SpendRecord {
  /// Parses a per-actor report row.
  OrganizationEffectiveSpendLimit.fromJson(super.json) {
    actor = OrganizationSpendActor.fromJson(_field('actor'));
    amount = _field<String?>('amount');
    currency = _field<String>('currency');
    period = _field<String>('period');
    periodToDateSpend = _field<String>('period_to_date_spend');
    scope = OrganizationSpendScope.fromJson(_field('scope'));
    source = OrganizationSpendScope.fromJson(_field('source'));
    spendLimitId = _field<String>('spend_limit_id');
  }

  /// The member or scoped API key being reported.
  late final OrganizationSpendActor actor;

  /// Exact minor-unit amount, or null when this period is uncapped.
  late final String? amount;

  /// ISO 4217 billing currency.
  late final String currency;

  /// Reset window as returned by the API.
  late final String period;

  /// Exact minor-unit spend, including fractional minor units if reported.
  late final String periodToDateSpend;

  /// The reported scope.
  late final OrganizationSpendScope scope;

  /// Where this effective limit came from.
  late final OrganizationSpendScope source;

  /// ID of the source spend limit.
  late final String spendLimitId;
}

/// A request to increase a member's spend limit.
final class OrganizationSpendIncreaseRequest extends _SpendRecord {
  /// Parses a request, including the spend limit in an approval receipt.
  OrganizationSpendIncreaseRequest.fromJson(
    Map<String, dynamic> json, {
    bool approval = false,
  }) : super(json) {
    checkOrganizationType(json, 'spend_limit_increase_request');
    id = _field<String>('id');
    status = _field<String>('status');
    period = _field<String>('period');
    createdAt = DateTime.parse(_field('created_at'));
    final resolved = _field<String?>('resolved_at');
    resolvedAt = resolved == null ? null : DateTime.parse(resolved);
    actor = OrganizationSpendActor.fromJson(_field('actor'));
    final resolver = _field<Map<String, dynamic>?>('resolved_by');
    resolvedBy = resolver == null
        ? null
        : OrganizationSpendActor.fromJson(resolver);
    final summary = _field<Map<String, dynamic>?>('spend_summary');
    spendSummary = summary == null
        ? null
        : OrganizationEffectiveSpendLimit.fromJson(summary);
    final limit = approval || json.containsKey('spend_limit')
        ? _field<Map<String, dynamic>?>('spend_limit')
        : null;
    spendLimit = limit == null ? null : OrganizationSpendLimit.fromJson(limit);
  }

  /// The request ID.
  late final String id;

  /// Open wire status, such as pending, approved or denied.
  late final String status;

  /// The reset window requested.
  late final String period;

  /// When the request was submitted.
  late final DateTime createdAt;

  /// When a pending request was resolved, if applicable.
  late final DateTime? resolvedAt;

  /// Who submitted the request.
  late final OrganizationSpendActor actor;

  /// Who resolved the request, if it has been resolved.
  late final OrganizationSpendActor? resolvedBy;

  /// Spend and limit information associated with the request.
  late final OrganizationEffectiveSpendLimit? spendSummary;

  /// The configured limit returned by an approval, if included.
  late final OrganizationSpendLimit? spendLimit;
}

/// Confirmation that a configured spend limit was deleted.
final class DeletedOrganizationSpendLimit extends _SpendRecord {
  /// Parses a deletion receipt.
  DeletedOrganizationSpendLimit.fromJson(Map<String, dynamic> json)
    : super(json) {
    checkOrganizationType(json, 'spend_limit_deleted');
    id = _field<String>('id');
  }

  /// The deleted limit ID.
  late final String id;
}
