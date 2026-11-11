import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// The group associated with an organization or workspace rate-limit entry.
@immutable
final class OrganizationRateLimitGroup {
  /// Parses the current group metadata.
  OrganizationRateLimitGroup.fromJson(Map<String, dynamic> json)
    : type = requiredOrganizationField<String>(
        json,
        'type',
        'Rate-limit group',
      ),
      id = requiredOrganizationField<String>(json, 'id', 'Rate-limit group'),
      displayName = json['display_name'] as String?;

  /// The current type, such as `model_group` or `batch`.
  final String type;

  /// Stable ID of this group across organizations.
  final String id;

  /// Human-readable label when the server provides one.
  final String? displayName;

  /// Converts the group to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'display_name': ?displayName,
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationRateLimitGroup &&
      type == other.type &&
      id == other.id &&
      displayName == other.displayName;

  @override
  int get hashCode => Object.hash(type, id, displayName);
}

/// An effective rate-limiter value.
@immutable
final class OrganizationRateLimitValue {
  /// Parses a limiter value and the optional workspace override metadata.
  OrganizationRateLimitValue.fromJson(Map<String, dynamic> json)
    : type = requiredOrganizationField<String>(
        json,
        'type',
        'Rate-limit value',
      ),
      value = requiredOrganizationField<int>(json, 'value', 'Rate-limit value'),
      organizationLimit = json['org_limit'] as int?,
      source = (json['source'] as Map<String, dynamic>?)?['type'] as String?,
      _hasOrganizationLimit = json.containsKey('org_limit');

  /// The limiter name.
  final String type;

  /// Effective value applied by the server.
  final int value;

  /// Corresponding organization limit, if available on a workspace entry.
  final int? organizationLimit;

  /// The effective source (`organization` or `workspace`) when supplied.
  final String? source;

  final bool _hasOrganizationLimit;

  /// Converts this entry to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    if (_hasOrganizationLimit) 'org_limit': organizationLimit,
    if (source != null) 'source': {'type': source},
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationRateLimitValue &&
      mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());
}

/// Rate limits for a group at organization or workspace scope.
@immutable
final class OrganizationRateLimit {
  const OrganizationRateLimit._({
    required this.id,
    required this.type,
    required this.group,
    required this.legacyGroupType,
    required this.workspaceId,
    required this.models,
    required this.limits,
  });

  /// Reads the current nested group or the legacy group_type representation.
  factory OrganizationRateLimit.fromJson(Map<String, dynamic> json) {
    const model = 'OrganizationRateLimit';
    final type = requiredOrganizationField<String>(json, 'type', model);
    final workspace = type == 'workspace_rate_limit';
    if (!workspace && type != 'rate_limit') {
      throw const FormatException('Invalid rate-limit type');
    }
    final rawGroup = json['group'] as Map<String, dynamic>?;
    final legacyGroupType = json['group_type'] as String?;
    if (rawGroup == null && legacyGroupType == null) {
      throw const FormatException('Rate limit: missing group');
    }
    final models = requiredOrganizationField<List<Object?>?>(
      json,
      'models',
      model,
    );
    return OrganizationRateLimit._(
      type: type,
      id: requiredOrganizationField<String>(
        json,
        workspace ? 'rate_limit_id' : 'id',
        model,
      ),
      group: rawGroup == null
          ? null
          : OrganizationRateLimitGroup.fromJson(rawGroup),
      legacyGroupType: legacyGroupType,
      workspaceId: workspace
          ? requiredOrganizationField<String>(json, 'workspace_id', model)
          : null,
      models: models == null ? null : List.unmodifiable(models.cast<String>()),
      limits: List.unmodifiable(
        requiredOrganizationField<List<Object?>>(json, 'limits', model).map(
          (entry) => OrganizationRateLimitValue.fromJson(
            entry! as Map<String, dynamic>,
          ),
        ),
      ),
    );
  }

  /// The rate-limit ID.
  final String id;

  /// Scope-specific wire discriminator.
  final String type;

  /// Group metadata supplied by the current contract.
  final OrganizationRateLimitGroup? group;

  /// Group type from older API responses.
  final String? legacyGroupType;

  /// The current group type, with a fallback for legacy responses.
  String get groupType => (group?.type ?? legacyGroupType)!;

  /// The workspace ID for workspace overrides.
  final String? workspaceId;

  /// Models included in the group, or null for a non-model group.
  final List<String>? models;

  /// Effective limiter values.
  final List<OrganizationRateLimitValue> limits;

  /// Converts this group and its limits to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    (workspaceId == null ? 'id' : 'rate_limit_id'): id,
    'workspace_id': ?workspaceId,
    'group': ?group?.toJson(),
    'group_type': ?legacyGroupType,
    'models': models,
    'limits': limits.map((entry) => entry.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationRateLimit && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() => 'OrganizationRateLimit(id: $id, groupType: $groupType)';
}

/// One workspace override to set or clear.
@immutable
final class WorkspaceRateLimitUpdate {
  /// Sets [type] to [value]. Null clears the workspace override.
  WorkspaceRateLimitUpdate({required this.type, required this.value}) {
    if (value case final int limit when limit < 0 || limit > 9007199254740991) {
      throw RangeError.range(limit, 0, 9007199254740991, 'value');
    }
  }

  /// The limiter type being updated.
  final String type;

  /// New limit, or null to inherit the organization value.
  final int? value;

  /// Converts this update to JSON, including a null clearing value.
  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

/// The organization's compliance settings toggle.
enum OrganizationComplianceState {
  /// Compliance settings enabled.
  enabled,

  /// Compliance settings disabled.
  disabled,
}

/// The current organization compliance settings.
@immutable
final class OrganizationComplianceSettings {
  const OrganizationComplianceSettings._(this.state);

  /// Parses the compliance settings state.
  factory OrganizationComplianceSettings.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'compliance_settings');
    const model = 'OrganizationComplianceSettings';
    final state = requiredOrganizationField<Map<String, dynamic>>(
      json,
      'state',
      model,
    );
    return OrganizationComplianceSettings._(
      requiredOrganizationField<String>(state, 'type', model),
    );
  }

  /// The server's state value.
  final String state;

  /// Converts the state to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'compliance_settings',
    'state': {'type': state},
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationComplianceSettings && state == other.state;

  @override
  int get hashCode => state.hashCode;
}
