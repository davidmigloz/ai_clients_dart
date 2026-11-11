import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// The organization or workspace bound to an API key.
@immutable
final class OrganizationApiKeyScope {
  /// Parses a workspace or organization scope.
  OrganizationApiKeyScope.fromJson(Map<String, dynamic> json)
    : _raw = deepUnmodifiableMap(json),
      type = requiredOrganizationField<String>(json, 'type', 'API key scope'),
      workspaceId = json['type'] == 'workspace'
          ? requiredOrganizationField<String>(
              json,
              'workspace_id',
              'API key scope',
            )
          : null;

  /// The wire scope type, currently `organization` or `workspace`.
  final String type;

  /// The real workspace ID for a workspace-scoped key, including Default.
  final String? workspaceId;

  final Map<String, dynamic> _raw;

  /// Converts the scope to JSON.
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      other is OrganizationApiKeyScope && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);
}

/// Metadata for an API key returned by the Admin API.
@immutable
final class OrganizationApiKey {
  const OrganizationApiKey._({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.partialKeyHint,
    required this.createdBy,
    required this.principal,
    required this.scope,
    required this.legacyWorkspaceId,
    required this._hasLegacyWorkspaceId,
  });

  /// Parses API key metadata, including the legacy workspace field.
  factory OrganizationApiKey.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'api_key');
    const model = 'OrganizationApiKey';
    final scope = json['scope'] as Map<String, dynamic>?;
    if (scope == null && !json.containsKey('workspace_id')) {
      throw const FormatException('OrganizationApiKey: missing scope');
    }
    final expiresAt = requiredOrganizationField<String?>(
      json,
      'expires_at',
      model,
    );
    final creator = requiredOrganizationField<Map<String, dynamic>?>(
      json,
      'created_by',
      model,
    );
    final principal = requiredOrganizationField<Map<String, dynamic>?>(
      json,
      'principal',
      model,
    );
    return OrganizationApiKey._(
      id: requiredOrganizationField<String>(json, 'id', model),
      name: requiredOrganizationField<String>(json, 'name', model),
      status: requiredOrganizationField<String>(json, 'status', model),
      createdAt: DateTime.parse(
        requiredOrganizationField<String>(json, 'created_at', model),
      ),
      expiresAt: expiresAt == null ? null : DateTime.parse(expiresAt),
      partialKeyHint: requiredOrganizationField<String?>(
        json,
        'partial_key_hint',
        model,
      ),
      createdBy: creator == null ? null : deepUnmodifiableMap(creator),
      principal: principal == null ? null : deepUnmodifiableMap(principal),
      scope: scope == null ? null : OrganizationApiKeyScope.fromJson(scope),
      legacyWorkspaceId: json['workspace_id'] as String?,
      hasLegacyWorkspaceId: json.containsKey('workspace_id'),
    );
  }

  /// The ID used to retrieve or update the key.
  final String id;

  /// The display name.
  final String name;

  /// The server's status value.
  final String status;

  /// The time the key was created.
  final DateTime createdAt;

  /// The expiration time, if any.
  final DateTime? expiresAt;

  /// The partial key hint returned by the API.
  final String? partialKeyHint;

  /// The creator's wire identity, if available.
  final Map<String, dynamic>? createdBy;

  /// The user or service account principal's wire identity, if bound.
  final Map<String, dynamic>? principal;

  /// The current scope. May be absent on historical responses.
  final OrganizationApiKeyScope? scope;

  /// The old workspace field from historical responses. A null value was
  /// ambiguous and does not identify a workspace.
  final String? legacyWorkspaceId;

  final bool _hasLegacyWorkspaceId;

  /// Converts the key metadata to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'api_key',
    'name': name,
    'status': status,
    'created_at': createdAt.toUtc().toIso8601String(),
    'expires_at': expiresAt?.toUtc().toIso8601String(),
    'partial_key_hint': partialKeyHint,
    'created_by': createdBy,
    'principal': principal,
    if (scope != null) 'scope': scope!.toJson(),
    if (_hasLegacyWorkspaceId) 'workspace_id': legacyWorkspaceId,
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationApiKey && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() => 'OrganizationApiKey(id: $id, status: $status)';
}

/// Statuses accepted when updating an organization API key.
enum OrganizationApiKeyStatus {
  /// The key can authenticate.
  active,

  /// The key is inactive.
  inactive,

  /// The key is archived.
  archived,
}
