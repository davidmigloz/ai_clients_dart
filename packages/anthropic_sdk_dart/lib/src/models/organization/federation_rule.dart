import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Claims that must match an identity token before it can be exchanged.
@immutable
final class FederationRuleMatch {
  /// Creates a rule's matching expression.
  FederationRuleMatch({
    this.audience,
    this.subjectPrefix,
    Map<String, String>? claims,
    this.condition,
  }) : claims = claims == null ? null : Map.unmodifiable(claims);

  /// Expected JWT audience, if the rule specifies one.
  final String? audience;

  /// Exact subject or prefix ending in `*`.
  final String? subjectPrefix;

  /// Exact-match constraints on string-valued top-level claims.
  final Map<String, String>? claims;

  /// A CEL expression over claims.
  final String? condition;

  /// Decodes a stored matching expression.
  factory FederationRuleMatch.fromJson(Map<String, dynamic> json) =>
      FederationRuleMatch(
        audience: _optional<String>(json, 'audience'),
        subjectPrefix: _optional<String>(json, 'subject_prefix'),
        claims: _stringMap(_optional<Map<String, dynamic>>(json, 'claims')),
        condition: _optional<String>(json, 'condition'),
      );

  /// Encodes a matching expression.
  Map<String, dynamic> toJson() => {
    'audience': ?audience,
    'subject_prefix': ?subjectPrefix,
    'claims': ?claims,
    'condition': ?condition,
  };

  /// Copies the match, clearing nullable fields when null is supplied.
  FederationRuleMatch copyWith({
    Object? audience = unsetCopyWithValue,
    Object? subjectPrefix = unsetCopyWithValue,
    Object? claims = unsetCopyWithValue,
    Object? condition = unsetCopyWithValue,
  }) => FederationRuleMatch(
    audience: identical(audience, unsetCopyWithValue)
        ? this.audience
        : audience as String?,
    subjectPrefix: identical(subjectPrefix, unsetCopyWithValue)
        ? this.subjectPrefix
        : subjectPrefix as String?,
    claims: identical(claims, unsetCopyWithValue)
        ? this.claims
        : claims == null
        ? null
        : Map<String, String>.from(claims as Map),
    condition: identical(condition, unsetCopyWithValue)
        ? this.condition
        : condition as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is FederationRuleMatch &&
      audience == other.audience &&
      subjectPrefix == other.subjectPrefix &&
      mapsEqual(claims, other.claims) &&
      condition == other.condition;

  @override
  int get hashCode =>
      Object.hash(audience, subjectPrefix, mapHash(claims), condition);

  @override
  String toString() =>
      'FederationRuleMatch(audience: ${audience == null ? null : "[REDACTED]"}, '
      'subjectPrefix: ${subjectPrefix == null ? null : "[REDACTED]"}, '
      'claims: ${claims?.length}, '
      'condition: ${condition == null ? null : "[REDACTED]"})';
}

/// The service account that receives the minted token.
@immutable
final class FederationServiceAccountTarget {
  /// Creates a target identified by its tagged account ID.
  const FederationServiceAccountTarget({
    required this.serviceAccountId,
    this.serviceAccountName,
  });

  /// The tagged service account ID.
  final String serviceAccountId;

  /// The read-time account name, when supplied by the service.
  final String? serviceAccountName;

  /// The wire discriminator.
  String get type => 'service_account';

  /// Decodes the rule target.
  factory FederationServiceAccountTarget.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'service_account');
    return FederationServiceAccountTarget(
      serviceAccountId: _required<String>(json, 'service_account_id'),
      serviceAccountName: _optional<String>(json, 'service_account_name'),
    );
  }

  /// Encodes the target as returned by the Admin API.
  Map<String, dynamic> toJson() => {
    'type': type,
    'service_account_id': serviceAccountId,
    'service_account_name': ?serviceAccountName,
  };

  /// Encodes a write request without the server-managed name.
  Map<String, dynamic> toRequestJson() => {
    'type': type,
    'service_account_id': serviceAccountId,
  };

  /// Copies the target, allowing its read-time name to be cleared.
  FederationServiceAccountTarget copyWith({
    String? serviceAccountId,
    Object? serviceAccountName = unsetCopyWithValue,
  }) => FederationServiceAccountTarget(
    serviceAccountId: serviceAccountId ?? this.serviceAccountId,
    serviceAccountName: identical(serviceAccountName, unsetCopyWithValue)
        ? this.serviceAccountName
        : serviceAccountName as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is FederationServiceAccountTarget &&
      serviceAccountId == other.serviceAccountId &&
      serviceAccountName == other.serviceAccountName;

  @override
  int get hashCode => Object.hash(serviceAccountId, serviceAccountName);

  @override
  String toString() =>
      'FederationServiceAccountTarget(serviceAccountId: $serviceAccountId, '
      'serviceAccountName: $serviceAccountName)';
}

/// A rule binding an OIDC issuer to a service account and OAuth scope.
@immutable
final class FederationRule {
  /// Creates this Admin API record.
  FederationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.issuerId,
    required this.issuerName,
    required this.match,
    required this.target,
    required this.oauthScope,
    required this.tokenLifetimeSeconds,
    required this.workspaceId,
    required List<String> workspaceIds,
    required this.appliesToAllWorkspaces,
    required Map<String, String>? attributes,
    required this.createdAt,
    required this.createdByActorId,
    required this.updatedAt,
    required this.updatedByActorId,
    required this.archivedAt,
    required this.archivedByActorId,
  }) : workspaceIds = List.unmodifiable(workspaceIds),
       attributes = attributes == null ? null : Map.unmodifiable(attributes);

  /// The tagged rule ID.
  final String id;

  /// The organization-unique rule slug.
  final String name;

  /// Optional description of the rule.
  final String? description;

  /// The federation issuer ID.
  final String issuerId;

  /// The issuer name at read time, when available.
  final String? issuerName;

  /// The claims an incoming token must match.
  final FederationRuleMatch match;

  /// The service account authorized by this rule.
  final FederationServiceAccountTarget target;

  /// The OAuth scope granted to a matched token.
  final String oauthScope;

  /// The minted token lifetime in seconds.
  final int tokenLifetimeSeconds;

  /// The legacy single-workspace binding, if recorded.
  final String? workspaceId;

  /// The workspaces enabled for the rule.
  final List<String> workspaceIds;

  /// Whether the rule applies to every workspace.
  final bool appliesToAllWorkspaces;

  /// Stored CEL attribute expressions, if reported.
  final Map<String, String>? attributes;

  /// When the rule was created.
  final DateTime createdAt;

  /// The actor who created the rule, when known.
  final String? createdByActorId;

  /// When the rule was last updated.
  final DateTime updatedAt;

  /// The actor who last updated the rule, when known.
  final String? updatedByActorId;

  /// When the rule was archived, when applicable.
  final DateTime? archivedAt;

  /// The actor who archived the rule, when known.
  final String? archivedByActorId;

  /// The wire discriminator.
  String get type => 'federation_rule';

  /// Decodes this Admin API record.
  factory FederationRule.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'federation_rule');
    return FederationRule(
      id: _required<String>(json, 'id'),
      name: _required<String>(json, 'name'),
      description: _required<String?>(json, 'description'),
      issuerId: _required<String>(json, 'issuer_id'),
      issuerName: _required<String?>(json, 'issuer_name'),
      match: FederationRuleMatch.fromJson(
        _required<Map<String, dynamic>>(json, 'match'),
      ),
      target: FederationServiceAccountTarget.fromJson(
        _required<Map<String, dynamic>>(json, 'target'),
      ),
      oauthScope: _required<String>(json, 'oauth_scope'),
      tokenLifetimeSeconds: _required<int>(json, 'token_lifetime_seconds'),
      workspaceId: json.containsKey('workspace_id')
          ? _required<String?>(json, 'workspace_id')
          : null,
      workspaceIds: _stringList(
        _required<List<dynamic>>(json, 'workspace_ids'),
      ),
      appliesToAllWorkspaces: _required<bool>(
        json,
        'applies_to_all_workspaces',
      ),
      attributes: json.containsKey('attributes')
          ? _stringMap(_required<Map<String, dynamic>?>(json, 'attributes'))
          : null,
      createdAt: DateTime.parse(_required<String>(json, 'created_at')),
      createdByActorId: _required<String?>(json, 'created_by_actor_id'),
      updatedAt: DateTime.parse(_required<String>(json, 'updated_at')),
      updatedByActorId: _required<String?>(json, 'updated_by_actor_id'),
      archivedAt: _nullableTime(json, 'archived_at'),
      archivedByActorId: _required<String?>(json, 'archived_by_actor_id'),
    );
  }

  /// Encodes this record using its wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'description': description,
    'issuer_id': issuerId,
    'issuer_name': issuerName,
    'match': match.toJson(),
    'target': target.toJson(),
    'oauth_scope': oauthScope,
    'token_lifetime_seconds': tokenLifetimeSeconds,
    'workspace_id': workspaceId,
    'workspace_ids': workspaceIds,
    'applies_to_all_workspaces': appliesToAllWorkspaces,
    'attributes': attributes,
    'created_at': createdAt.toUtc().toIso8601String(),
    'created_by_actor_id': createdByActorId,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'updated_by_actor_id': updatedByActorId,
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'archived_by_actor_id': archivedByActorId,
  };

  /// Copies this record with the supplied fields replaced.
  FederationRule copyWith({
    String? id,
    String? name,
    Object? description = unsetCopyWithValue,
    String? issuerId,
    Object? issuerName = unsetCopyWithValue,
    FederationRuleMatch? match,
    FederationServiceAccountTarget? target,
    String? oauthScope,
    int? tokenLifetimeSeconds,
    Object? workspaceId = unsetCopyWithValue,
    List<String>? workspaceIds,
    bool? appliesToAllWorkspaces,
    Object? attributes = unsetCopyWithValue,
    DateTime? createdAt,
    Object? createdByActorId = unsetCopyWithValue,
    DateTime? updatedAt,
    Object? updatedByActorId = unsetCopyWithValue,
    Object? archivedAt = unsetCopyWithValue,
    Object? archivedByActorId = unsetCopyWithValue,
  }) => FederationRule(
    id: id ?? this.id,
    name: name ?? this.name,
    description: identical(description, unsetCopyWithValue)
        ? this.description
        : description as String?,
    issuerId: issuerId ?? this.issuerId,
    issuerName: identical(issuerName, unsetCopyWithValue)
        ? this.issuerName
        : issuerName as String?,
    match: match ?? this.match,
    target: target ?? this.target,
    oauthScope: oauthScope ?? this.oauthScope,
    tokenLifetimeSeconds: tokenLifetimeSeconds ?? this.tokenLifetimeSeconds,
    workspaceId: identical(workspaceId, unsetCopyWithValue)
        ? this.workspaceId
        : workspaceId as String?,
    workspaceIds: workspaceIds ?? this.workspaceIds,
    appliesToAllWorkspaces:
        appliesToAllWorkspaces ?? this.appliesToAllWorkspaces,
    attributes: identical(attributes, unsetCopyWithValue)
        ? this.attributes
        : attributes == null
        ? null
        : Map<String, String>.from(attributes as Map),
    createdAt: createdAt ?? this.createdAt,
    createdByActorId: identical(createdByActorId, unsetCopyWithValue)
        ? this.createdByActorId
        : createdByActorId as String?,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedByActorId: identical(updatedByActorId, unsetCopyWithValue)
        ? this.updatedByActorId
        : updatedByActorId as String?,
    archivedAt: identical(archivedAt, unsetCopyWithValue)
        ? this.archivedAt
        : archivedAt as DateTime?,
    archivedByActorId: identical(archivedByActorId, unsetCopyWithValue)
        ? this.archivedByActorId
        : archivedByActorId as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is FederationRule &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      issuerId == other.issuerId &&
      issuerName == other.issuerName &&
      match == other.match &&
      target == other.target &&
      oauthScope == other.oauthScope &&
      tokenLifetimeSeconds == other.tokenLifetimeSeconds &&
      workspaceId == other.workspaceId &&
      listsEqual(workspaceIds, other.workspaceIds) &&
      appliesToAllWorkspaces == other.appliesToAllWorkspaces &&
      mapsEqual(attributes, other.attributes) &&
      createdAt == other.createdAt &&
      createdByActorId == other.createdByActorId &&
      updatedAt == other.updatedAt &&
      updatedByActorId == other.updatedByActorId &&
      archivedAt == other.archivedAt &&
      archivedByActorId == other.archivedByActorId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    issuerId,
    issuerName,
    match,
    target,
    oauthScope,
    tokenLifetimeSeconds,
    workspaceId,
    listHash(workspaceIds),
    appliesToAllWorkspaces,
    mapHash(attributes),
    createdAt,
    createdByActorId,
    updatedAt,
    updatedByActorId,
    archivedAt,
    archivedByActorId,
  );

  @override
  String toString() =>
      'FederationRule(id: $id, name: $name, description: ${description?.length}, '
      'issuerId: $issuerId, issuerName: $issuerName, match: $match, '
      'target: $target, oauthScope: $oauthScope, tokenLifetimeSeconds: $tokenLifetimeSeconds, '
      'workspaceId: $workspaceId, workspaceIds: ${workspaceIds.length}, appliesToAllWorkspaces: $appliesToAllWorkspaces, '
      'attributes: ${attributes?.length}, createdAt: $createdAt, createdByActorId: $createdByActorId, '
      'updatedAt: $updatedAt, updatedByActorId: $updatedByActorId, archivedAt: $archivedAt, '
      'archivedByActorId: $archivedByActorId)';
}

/// A workspace enabled for a federation rule.
@immutable
final class FederationRuleWorkspace {
  /// Creates this Admin API record.
  const FederationRuleWorkspace({
    required this.federationRuleId,
    required this.workspaceId,
    required this.workspaceName,
    required this.createdAt,
    required this.createdByActorId,
  });

  /// The tagged rule ID.
  final String federationRuleId;

  /// The tagged workspace ID.
  final String workspaceId;

  /// The workspace name, when returned.
  final String? workspaceName;

  /// When the rule was enabled for this workspace.
  final DateTime createdAt;

  /// The actor who enabled the workspace, when known.
  final String? createdByActorId;

  /// The wire discriminator.
  String get type => 'federation_rule_workspace';

  /// Decodes this Admin API record.
  factory FederationRuleWorkspace.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'federation_rule_workspace');
    return FederationRuleWorkspace(
      federationRuleId: _required<String>(json, 'federation_rule_id'),
      workspaceId: _required<String>(json, 'workspace_id'),
      workspaceName: _required<String?>(json, 'workspace_name'),
      createdAt: DateTime.parse(_required<String>(json, 'created_at')),
      createdByActorId: _required<String?>(json, 'created_by_actor_id'),
    );
  }

  /// Encodes this record using its wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'federation_rule_id': federationRuleId,
    'workspace_id': workspaceId,
    'workspace_name': workspaceName,
    'created_at': createdAt.toUtc().toIso8601String(),
    'created_by_actor_id': createdByActorId,
  };

  /// Copies this record with the supplied fields replaced.
  FederationRuleWorkspace copyWith({
    String? federationRuleId,
    String? workspaceId,
    Object? workspaceName = unsetCopyWithValue,
    DateTime? createdAt,
    Object? createdByActorId = unsetCopyWithValue,
  }) => FederationRuleWorkspace(
    federationRuleId: federationRuleId ?? this.federationRuleId,
    workspaceId: workspaceId ?? this.workspaceId,
    workspaceName: identical(workspaceName, unsetCopyWithValue)
        ? this.workspaceName
        : workspaceName as String?,
    createdAt: createdAt ?? this.createdAt,
    createdByActorId: identical(createdByActorId, unsetCopyWithValue)
        ? this.createdByActorId
        : createdByActorId as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is FederationRuleWorkspace &&
      federationRuleId == other.federationRuleId &&
      workspaceId == other.workspaceId &&
      workspaceName == other.workspaceName &&
      createdAt == other.createdAt &&
      createdByActorId == other.createdByActorId;

  @override
  int get hashCode => Object.hash(
    federationRuleId,
    workspaceId,
    workspaceName,
    createdAt,
    createdByActorId,
  );

  @override
  String toString() =>
      'FederationRuleWorkspace(federationRuleId: $federationRuleId, workspaceId: $workspaceId, workspaceName: $workspaceName, '
      'createdAt: $createdAt, createdByActorId: $createdByActorId)';
}

/// Receipt for removing a workspace from a federation rule.
@immutable
final class DeletedFederationRuleWorkspace {
  /// Creates this Admin API record.
  const DeletedFederationRuleWorkspace({
    required this.federationRuleId,
    required this.workspaceId,
  });

  /// The tagged rule ID.
  final String federationRuleId;

  /// The tagged workspace ID.
  final String workspaceId;

  /// The wire discriminator.
  String get type => 'federation_rule_workspace_deleted';

  /// Decodes this Admin API record.
  factory DeletedFederationRuleWorkspace.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'federation_rule_workspace_deleted');
    return DeletedFederationRuleWorkspace(
      federationRuleId: _required<String>(json, 'federation_rule_id'),
      workspaceId: _required<String>(json, 'workspace_id'),
    );
  }

  /// Encodes this record using its wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'federation_rule_id': federationRuleId,
    'workspace_id': workspaceId,
  };

  /// Copies this record with the supplied fields replaced.
  DeletedFederationRuleWorkspace copyWith({
    String? federationRuleId,
    String? workspaceId,
  }) => DeletedFederationRuleWorkspace(
    federationRuleId: federationRuleId ?? this.federationRuleId,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      other is DeletedFederationRuleWorkspace &&
      federationRuleId == other.federationRuleId &&
      workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(federationRuleId, workspaceId);

  @override
  String toString() =>
      'DeletedFederationRuleWorkspace(federationRuleId: $federationRuleId, workspaceId: $workspaceId)';
}

T _required<T>(Map<String, dynamic> json, String key) =>
    requiredOrganizationField<T>(json, key, 'Federation rule');

T? _optional<T>(Map<String, dynamic> json, String key) =>
    json.containsKey(key) ? _required<T?>(json, key) : null;

DateTime? _nullableTime(Map<String, dynamic> json, String key) {
  final value = _required<String?>(json, key);
  return value == null ? null : DateTime.parse(value);
}

Map<String, String>? _stringMap(Map<String, dynamic>? values) =>
    values?.map((key, value) {
      if (value is! String) {
        throw const FormatException('Expected federation string values');
      }
      return MapEntry(key, value);
    });

List<String> _stringList(List<dynamic> values) => values.map((value) {
  if (value is! String) {
    throw const FormatException('Expected a federation workspace ID');
  }
  return value;
}).toList();
