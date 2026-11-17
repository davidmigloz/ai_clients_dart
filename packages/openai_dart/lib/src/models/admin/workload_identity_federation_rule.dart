import 'admin_json.dart';
import 'workload_identity.dart';

/// A rule that maps external identity attributes to a service account.
final class WorkloadIdentityFederationRule extends AdminJsonValue {
  /// Creates a federation rule from service values.
  WorkloadIdentityFederationRule({
    required this.id,
    required this.workloadIdentityProviderId,
    required this.projectId,
    required this.serviceAccountId,
    required this.name,
    required this.description,
    required Map<String, Object> attributeMatchers,
    required this.permissions,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  }) : attributeMatchers = workloadIdentityMatchers(attributeMatchers);

  /// The rule identifier.
  final String id;

  /// The provider that supplies the identity assertion.
  final String workloadIdentityProviderId;

  /// The project containing the service account.
  final String projectId;

  /// The service account used when the rule matches.
  final String serviceAccountId;

  /// Optional display name.
  final String? name;

  /// Optional human-readable description.
  final String? description;

  /// Attribute names and their expected scalar values.
  final Map<String, Object> attributeMatchers;

  /// Effective permissions carried by credentials issued through the rule.
  final WorkloadIdentityPermissions permissions;

  /// Whether the rule is enabled.
  final bool enabled;

  /// Creation time, in Unix seconds.
  final int createdAt;

  /// Last update time, in Unix seconds.
  final int updatedAt;

  /// Fixed resource discriminator.
  String get object => 'organization.workload_identity_federation_rule';

  /// Parses a federation rule response.
  factory WorkloadIdentityFederationRule.fromJson(Map<String, dynamic> json) {
    const context = 'WorkloadIdentityFederationRule';
    adminTag(
      json,
      'object',
      'organization.workload_identity_federation_rule',
      context,
    );
    return WorkloadIdentityFederationRule(
      id: adminString(json['id'], '$context.id'),
      workloadIdentityProviderId: adminString(
        json['workload_identity_provider_id'],
        '$context.workloadIdentityProviderId',
      ),
      projectId: adminString(json['project_id'], '$context.projectId'),
      serviceAccountId: adminString(
        json['service_account_id'],
        '$context.serviceAccountId',
      ),
      name: adminRequired(
        json,
        'name',
        '$context.name',
        adminString,
        nullable: true,
      ),
      description: adminRequired(
        json,
        'description',
        '$context.description',
        adminString,
        nullable: true,
      ),
      attributeMatchers: workloadIdentityMatchers(json['attribute_matchers']),
      permissions: _parsePermissions(
        json['permissions'],
        '$context.permissions',
      ),
      enabled: adminBool(json['enabled'], '$context.enabled'),
      createdAt: adminInt(json['created_at'], '$context.createdAt'),
      updatedAt: adminInt(json['updated_at'], '$context.updatedAt'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'object': object,
    'id': id,
    'workload_identity_provider_id': workloadIdentityProviderId,
    'project_id': projectId,
    'service_account_id': serviceAccountId,
    'name': name,
    'description': description,
    'attribute_matchers': attributeMatchers,
    'permissions': permissions.toJson(),
    'enabled': enabled,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/// The inputs for creating a workload identity federation rule.
final class CreateWorkloadIdentityFederationRuleRequest extends AdminJsonValue {
  /// Creates a rule from a project, service account and attribute matchers.
  CreateWorkloadIdentityFederationRuleRequest({
    required this.projectId,
    required this.serviceAccountId,
    required Map<String, Object> attributeMatchers,
    this.name,
    this.description,
    this.permissions,
    this.enabled,
  }) : attributeMatchers = workloadIdentityMatchers(attributeMatchers) {
    validate();
  }

  /// The project containing the service account.
  final String projectId;

  /// The service account used when the rule matches.
  final String serviceAccountId;

  /// Attribute names and their expected scalar values.
  final Map<String, Object> attributeMatchers;

  /// Optional display name.
  final String? name;

  /// Optional human-readable description.
  final String? description;

  /// Permissions to constrain the issued credentials.
  final WorkloadIdentityPermissions? permissions;

  /// Whether to enable the rule.
  final bool? enabled;

  /// Parses a rule creation request.
  factory CreateWorkloadIdentityFederationRuleRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'CreateWorkloadIdentityFederationRuleRequest';
    return CreateWorkloadIdentityFederationRuleRequest(
      projectId: adminString(json['project_id'], '$context.projectId'),
      serviceAccountId: adminString(
        json['service_account_id'],
        '$context.serviceAccountId',
      ),
      attributeMatchers: workloadIdentityMatchers(json['attribute_matchers']),
      name: adminOptional(json, 'name', '$context.name', adminString),
      description: adminOptional(
        json,
        'description',
        '$context.description',
        adminString,
      ),
      permissions: adminOptional(
        json,
        'permissions',
        '$context.permissions',
        _parsePermissions,
      ),
      enabled: adminOptional(json, 'enabled', '$context.enabled', adminBool),
    );
  }

  @override
  void validate() {
    adminLength(
      projectId,
      'CreateWorkloadIdentityFederationRuleRequest.projectId',
      min: 1,
    );
    adminLength(
      serviceAccountId,
      'CreateWorkloadIdentityFederationRuleRequest.serviceAccountId',
      min: 1,
    );
    permissions?.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    'project_id': projectId,
    'service_account_id': serviceAccountId,
    'attribute_matchers': attributeMatchers,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (permissions != null) 'permissions': permissions!.toJson(),
    if (enabled != null) 'enabled': enabled,
  };
}

/// A partial update to a workload identity federation rule.
final class UpdateWorkloadIdentityFederationRuleRequest extends AdminJsonValue {
  /// Creates a rule update. Pass null to clear [name] or [description].
  UpdateWorkloadIdentityFederationRuleRequest({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Map<String, Object>? attributeMatchers,
    this.permissions,
    this.enabled,
  }) : hasName = !identical(name, unsetCopyWithValue),
       name = adminCopy<String>(
         name,
         null,
         'UpdateWorkloadIdentityFederationRuleRequest.name',
       ),
       hasDescription = !identical(description, unsetCopyWithValue),
       description = adminCopy<String>(
         description,
         null,
         'UpdateWorkloadIdentityFederationRuleRequest.description',
       ),
       attributeMatchers = attributeMatchers == null
           ? null
           : workloadIdentityMatchers(attributeMatchers) {
    validate();
  }

  /// Replacement display name.
  final String? name;

  /// Whether to write [name], including an explicit null.
  final bool hasName;

  /// Replacement human-readable description.
  final String? description;

  /// Whether to write [description], including an explicit null.
  final bool hasDescription;

  /// Replacement attribute matchers.
  final Map<String, Object>? attributeMatchers;

  /// Replacement permissions for issued credentials.
  final WorkloadIdentityPermissions? permissions;

  /// Replacement enabled state.
  final bool? enabled;

  /// Parses a rule update without synthesizing omitted fields.
  factory UpdateWorkloadIdentityFederationRuleRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'UpdateWorkloadIdentityFederationRuleRequest';
    return UpdateWorkloadIdentityFederationRuleRequest(
      name: json.containsKey('name') ? json['name'] : unsetCopyWithValue,
      description: json.containsKey('description')
          ? json['description']
          : unsetCopyWithValue,
      attributeMatchers: json.containsKey('attribute_matchers')
          ? workloadIdentityMatchers(json['attribute_matchers'])
          : null,
      permissions: adminOptional(
        json,
        'permissions',
        '$context.permissions',
        _parsePermissions,
      ),
      enabled: adminOptional(json, 'enabled', '$context.enabled', adminBool),
    );
  }

  @override
  void validate() => permissions?.validate();

  @override
  Map<String, dynamic> toJson() => {
    if (hasName) 'name': name,
    if (hasDescription) 'description': description,
    if (attributeMatchers != null) 'attribute_matchers': attributeMatchers,
    if (permissions != null) 'permissions': permissions!.toJson(),
    if (enabled != null) 'enabled': enabled,
  };
}

WorkloadIdentityPermissions _parsePermissions(Object? value, String context) =>
    WorkloadIdentityPermissions.fromJson(adminObject(value, context));
