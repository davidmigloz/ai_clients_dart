import 'admin_json.dart';
import 'workload_identity.dart';

/// An OIDC workload identity provider registered with the organization.
final class WorkloadIdentityProvider extends AdminJsonValue {
  /// Creates a provider from service values.
  WorkloadIdentityProvider({
    required this.id,
    required this.name,
    required this.issuer,
    required this.audience,
    required this.verification,
    required this.description,
    required Iterable<WorkloadIdentityTransformation> attributeTransformations,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  }) : attributeTransformations = List.unmodifiable(attributeTransformations);

  /// The provider identifier.
  final String id;

  /// Display name.
  final String name;

  /// The expected assertion issuer.
  final String issuer;

  /// The expected assertion audience.
  final String audience;

  /// The resolved verification method.
  final WorkloadIdentityVerification verification;

  /// Optional human-readable description.
  final String? description;

  /// The configured attribute transformations.
  final List<WorkloadIdentityTransformation> attributeTransformations;

  /// Whether the provider is enabled.
  final bool enabled;

  /// Creation time, in Unix seconds.
  final int createdAt;

  /// Last update time, in Unix seconds.
  final int updatedAt;

  /// Fixed resource discriminator.
  String get object => 'organization.workload_identity_provider';

  /// Fixed provider type.
  String get type => 'oidc';

  /// Parses a provider response.
  factory WorkloadIdentityProvider.fromJson(Map<String, dynamic> json) {
    const context = 'WorkloadIdentityProvider';
    adminTag(
      json,
      'object',
      'organization.workload_identity_provider',
      context,
    );
    adminTag(json, 'type', 'oidc', context);
    return WorkloadIdentityProvider(
      id: adminString(json['id'], '$context.id'),
      name: adminString(json['name'], '$context.name'),
      issuer: adminString(json['issuer'], '$context.issuer'),
      audience: adminString(json['audience'], '$context.audience'),
      verification: _parseVerification(
        json['verification'],
        '$context.verification',
      ),
      description: adminRequired(
        json,
        'description',
        '$context.description',
        adminString,
        nullable: true,
      ),
      attributeTransformations: _parseTransformations(
        json['attribute_transformations'],
        '$context.attributeTransformations',
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
    'type': type,
    'name': name,
    'issuer': issuer,
    'audience': audience,
    'verification': verification.toJson(),
    'description': description,
    'attribute_transformations': [
      for (final transformation in attributeTransformations)
        transformation.toJson(),
    ],
    'enabled': enabled,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/// The inputs for registering an OIDC workload identity provider.
final class CreateWorkloadIdentityProviderRequest extends AdminJsonValue {
  /// Creates a provider registration request.
  CreateWorkloadIdentityProviderRequest({
    required this.name,
    required this.issuer,
    required this.audience,
    this.description,
    this.verification,
    Iterable<WorkloadIdentityTransformation>? attributeTransformations,
    this.enabled,
  }) : attributeTransformations = attributeTransformations == null
           ? null
           : List.unmodifiable(attributeTransformations) {
    validate();
  }

  /// Display name.
  final String name;

  /// The expected assertion issuer.
  final String issuer;

  /// The expected assertion audience.
  final String audience;

  /// Optional human-readable description.
  final String? description;

  /// Optional verification configuration.
  final WorkloadIdentityVerification? verification;

  /// Optional attribute transformations.
  final List<WorkloadIdentityTransformation>? attributeTransformations;

  /// Whether to enable the registration.
  final bool? enabled;

  /// Fixed provider type.
  String get type => 'oidc';

  /// Parses a provider registration request.
  factory CreateWorkloadIdentityProviderRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'CreateWorkloadIdentityProviderRequest';
    adminTag(json, 'type', 'oidc', context);
    return CreateWorkloadIdentityProviderRequest(
      name: adminString(json['name'], '$context.name'),
      issuer: adminString(json['issuer'], '$context.issuer'),
      audience: adminString(json['audience'], '$context.audience'),
      description: adminOptional(
        json,
        'description',
        '$context.description',
        adminString,
      ),
      verification: adminOptional(
        json,
        'verification',
        '$context.verification',
        _parseVerification,
      ),
      attributeTransformations: adminOptional(
        json,
        'attribute_transformations',
        '$context.attributeTransformations',
        _parseTransformations,
      ),
      enabled: adminOptional(json, 'enabled', '$context.enabled', adminBool),
    );
  }

  @override
  void validate() {
    adminLength(name, 'CreateWorkloadIdentityProviderRequest.name', min: 1);
    adminLength(issuer, 'CreateWorkloadIdentityProviderRequest.issuer', min: 1);
    adminLength(
      audience,
      'CreateWorkloadIdentityProviderRequest.audience',
      min: 1,
    );
    _validateTransformations(attributeTransformations);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'issuer': issuer,
    'audience': audience,
    if (description != null) 'description': description,
    if (verification != null) 'verification': verification!.toJson(),
    if (attributeTransformations case final transformations?)
      'attribute_transformations': [
        for (final value in transformations) value.toJson(),
      ],
    if (enabled != null) 'enabled': enabled,
  };
}

/// A partial update to an OIDC workload identity provider.
final class UpdateWorkloadIdentityProviderRequest extends AdminJsonValue {
  /// Creates an update. Omit [description] to retain it or pass null to clear it.
  UpdateWorkloadIdentityProviderRequest({
    this.name,
    this.issuer,
    this.audience,
    Object? description = unsetCopyWithValue,
    this.verification,
    Iterable<WorkloadIdentityTransformation>? attributeTransformations,
    this.enabled,
  }) : hasDescription = !identical(description, unsetCopyWithValue),
       description = adminCopy<String>(
         description,
         null,
         'UpdateWorkloadIdentityProviderRequest.description',
       ),
       attributeTransformations = attributeTransformations == null
           ? null
           : List.unmodifiable(attributeTransformations) {
    validate();
  }

  /// Replacement display name.
  final String? name;

  /// Replacement expected issuer.
  final String? issuer;

  /// Replacement expected audience.
  final String? audience;

  /// Replacement human-readable description.
  final String? description;

  /// Whether to write [description], including an explicit null.
  final bool hasDescription;

  /// Replacement verification method.
  final WorkloadIdentityVerification? verification;

  /// Replacement transformation list. An empty list clears transformations.
  final List<WorkloadIdentityTransformation>? attributeTransformations;

  /// Replacement enabled state.
  final bool? enabled;

  /// Parses a provider update without synthesizing omitted fields.
  factory UpdateWorkloadIdentityProviderRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'UpdateWorkloadIdentityProviderRequest';
    return UpdateWorkloadIdentityProviderRequest(
      name: adminOptional(json, 'name', '$context.name', adminString),
      issuer: adminOptional(json, 'issuer', '$context.issuer', adminString),
      audience: adminOptional(
        json,
        'audience',
        '$context.audience',
        adminString,
      ),
      description: json.containsKey('description')
          ? json['description']
          : unsetCopyWithValue,
      verification: adminOptional(
        json,
        'verification',
        '$context.verification',
        _parseVerification,
      ),
      attributeTransformations: adminOptional(
        json,
        'attribute_transformations',
        '$context.attributeTransformations',
        _parseTransformations,
      ),
      enabled: adminOptional(json, 'enabled', '$context.enabled', adminBool),
    );
  }

  @override
  void validate() {
    if (name case final name?) {
      adminLength(name, 'UpdateWorkloadIdentityProviderRequest.name', min: 1);
    }
    if (issuer case final issuer?) {
      adminLength(
        issuer,
        'UpdateWorkloadIdentityProviderRequest.issuer',
        min: 1,
      );
    }
    if (audience case final audience?) {
      adminLength(
        audience,
        'UpdateWorkloadIdentityProviderRequest.audience',
        min: 1,
      );
    }
    _validateTransformations(attributeTransformations);
  }

  @override
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (issuer != null) 'issuer': issuer,
    if (audience != null) 'audience': audience,
    if (hasDescription) 'description': description,
    if (verification != null) 'verification': verification!.toJson(),
    if (attributeTransformations case final transformations?)
      'attribute_transformations': [
        for (final value in transformations) value.toJson(),
      ],
    if (enabled != null) 'enabled': enabled,
  };
}

WorkloadIdentityVerification _parseVerification(
  Object? value,
  String context,
) => WorkloadIdentityVerification.fromJson(adminObject(value, context));

List<WorkloadIdentityTransformation> _parseTransformations(
  Object? value,
  String context,
) => [
  for (final item in adminList(value, context))
    WorkloadIdentityTransformation.fromJson(adminObject(item, context)),
];

void _validateTransformations(
  List<WorkloadIdentityTransformation>? transformations,
) {
  if (transformations == null) return;
  if (transformations.length > 20) {
    throw const FormatException(
      'Workload identity providers support up to 20 transformations',
    );
  }
  for (final transformation in transformations) {
    transformation.validate();
  }
}
