import 'admin_json.dart';

/// How the OpenAI service verifies tokens from an OIDC identity provider.
sealed class WorkloadIdentityVerification extends AdminJsonValue {
  const WorkloadIdentityVerification();

  /// Uses the issuer's discovery document. Null selects its standard URL.
  const factory WorkloadIdentityVerification.discovery({String? discoveryUrl}) =
      WorkloadIdentityDiscoveryVerification;

  /// Uses a supplied JSON Web Key Set.
  factory WorkloadIdentityVerification.uploadedJwks(Map<String, dynamic> jwks) =
      WorkloadIdentityUploadedJwksVerification;

  /// Parses a verification configuration.
  factory WorkloadIdentityVerification.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'discovery' => WorkloadIdentityVerification.discovery(
          discoveryUrl: adminRequired(
            json,
            'discovery_url',
            'WorkloadIdentityVerification.discoveryUrl',
            adminString,
            nullable: true,
          ),
        ),
        'uploaded_jwks' => WorkloadIdentityVerification.uploadedJwks(
          adminObject(json['jwks'], 'WorkloadIdentityVerification.jwks'),
        ),
        _ => throw const FormatException(
          'Unknown workload identity verification type',
        ),
      };

  @override
  Map<String, dynamic> toJson();
}

/// Verification using an OIDC discovery document.
final class WorkloadIdentityDiscoveryVerification
    extends WorkloadIdentityVerification {
  /// Creates discovery verification.
  const WorkloadIdentityDiscoveryVerification({this.discoveryUrl});

  /// Overrides where discovery metadata is read. Null uses the standard URL.
  final String? discoveryUrl;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'discovery',
    'discovery_url': discoveryUrl,
  };
}

/// Verification against an uploaded set of public keys.
final class WorkloadIdentityUploadedJwksVerification
    extends WorkloadIdentityVerification {
  /// Captures a detached, immutable JWKS object.
  WorkloadIdentityUploadedJwksVerification(Map<String, dynamic> jwks)
    : jwks = adminSnapshot(jwks, 'WorkloadIdentityVerification.jwks');

  /// The key set used for verification.
  final Map<String, dynamic> jwks;

  @override
  Map<String, dynamic> toJson() => {'type': 'uploaded_jwks', 'jwks': jwks};
}

/// An expression that derives an attribute from an identity assertion.
final class WorkloadIdentityTransformation extends AdminJsonValue {
  /// Creates an attribute transformation.
  const WorkloadIdentityTransformation({
    required this.attribute,
    required this.expression,
  });

  /// The name of the derived attribute.
  final String attribute;

  /// The service-side transformation expression.
  final String expression;

  /// Parses a transformation received from the service.
  factory WorkloadIdentityTransformation.fromJson(Map<String, dynamic> json) =>
      WorkloadIdentityTransformation(
        attribute: adminString(
          json['attribute'],
          'WorkloadIdentityTransformation.attribute',
        ),
        expression: adminString(
          json['expression'],
          'WorkloadIdentityTransformation.expression',
        ),
      );

  @override
  void validate() {
    adminLength(
      attribute,
      'WorkloadIdentityTransformation.attribute',
      min: 1,
      max: 256,
    );
    adminLength(
      expression,
      'WorkloadIdentityTransformation.expression',
      min: 1,
      max: 4096,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'attribute': attribute,
    'expression': expression,
  };
}

/// The permissions available to credentials issued through a federation rule.
sealed class WorkloadIdentityPermissions extends AdminJsonValue {
  const WorkloadIdentityPermissions();

  /// Uses the service account's effective default permissions.
  const factory WorkloadIdentityPermissions.serviceAccountDefault() =
      WorkloadIdentityDefaultPermissions;

  /// Limits the issued credentials to the selected scopes.
  factory WorkloadIdentityPermissions.restricted(Iterable<String> scopes) =
      WorkloadIdentityRestrictedPermissions;

  /// Parses a permissions configuration.
  factory WorkloadIdentityPermissions.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'service_account_default' =>
          const WorkloadIdentityPermissions.serviceAccountDefault(),
        'restricted' => WorkloadIdentityPermissions.restricted([
          for (final value in adminList(
            json['scopes'],
            'WorkloadIdentityPermissions.scopes',
          ))
            adminString(value, 'WorkloadIdentityPermissions.scope'),
        ]),
        _ => throw const FormatException(
          'Unknown workload identity permissions type',
        ),
      };

  @override
  Map<String, dynamic> toJson();
}

/// The service account's effective default permissions.
final class WorkloadIdentityDefaultPermissions
    extends WorkloadIdentityPermissions {
  /// Uses the service account's effective permissions.
  const WorkloadIdentityDefaultPermissions();

  @override
  Map<String, dynamic> toJson() => {'type': 'service_account_default'};
}

/// Explicit scopes for credentials issued through a federation rule.
final class WorkloadIdentityRestrictedPermissions
    extends WorkloadIdentityPermissions {
  /// Captures a detached scope list.
  WorkloadIdentityRestrictedPermissions(Iterable<String> scopes)
    : scopes = List.unmodifiable(scopes);

  /// Exact scopes assigned to the issued credentials.
  final List<String> scopes;

  @override
  void validate() {
    if (scopes.isEmpty) {
      throw const FormatException(
        'Restricted workload identity permissions require at least one scope',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'restricted', 'scopes': scopes};
}

/// One cursor page of identity providers or federation rules.
final class WorkloadIdentityCursorPage<T extends AdminJsonValue>
    extends AdminJsonValue {
  /// Captures an immutable page.
  WorkloadIdentityCursorPage({
    required Iterable<T> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
  }) : data = List.unmodifiable(data);

  /// The resources in this page.
  final List<T> data;

  /// The first ID in the page, or null if empty.
  final String? firstId;

  /// The last ID in the page. Use it as the next cursor when [hasMore] is true.
  final String? lastId;

  /// Whether the service has another page.
  final bool hasMore;

  /// Parses a page with the specified item parser.
  factory WorkloadIdentityCursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    adminTag(json, 'object', 'list', 'WorkloadIdentityCursorPage');
    return WorkloadIdentityCursorPage(
      data: [
        for (final json in adminList(
          json['data'],
          'WorkloadIdentityCursorPage.data',
        ))
          parseItem(adminObject(json, 'WorkloadIdentityCursorPage.item')),
      ],
      firstId: adminRequired(
        json,
        'first_id',
        'WorkloadIdentityCursorPage.firstId',
        adminString,
        nullable: true,
      ),
      lastId: adminRequired(
        json,
        'last_id',
        'WorkloadIdentityCursorPage.lastId',
        adminString,
        nullable: true,
      ),
      hasMore: adminBool(
        json['has_more'],
        'WorkloadIdentityCursorPage.hasMore',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'object': 'list',
    'data': [for (final value in data) value.toJson()],
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };
}

/// The result of deleting a provider or federation rule.
final class WorkloadIdentityDeletion extends AdminJsonValue {
  /// Creates a deletion result.
  const WorkloadIdentityDeletion({
    required this.object,
    required this.id,
    required this.deleted,
  });

  /// The deletion object discriminator.
  final String object;

  /// ID of the resource.
  final String id;

  /// Whether the service reported deletion.
  final bool deleted;

  /// Parses the deletion response for the expected resource type.
  factory WorkloadIdentityDeletion.fromJson(
    Map<String, dynamic> json, {
    required String expectedObject,
  }) {
    adminTag(json, 'object', expectedObject, 'WorkloadIdentityDeletion');
    return WorkloadIdentityDeletion(
      object: expectedObject,
      id: adminString(json['id'], 'WorkloadIdentityDeletion.id'),
      deleted: adminBool(json['deleted'], 'WorkloadIdentityDeletion.deleted'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'object': object,
    'id': id,
    'deleted': deleted,
  };
}

/// Parses the exact scalar values accepted as federation attribute matchers.
Map<String, Object> workloadIdentityMatchers(Object? value) {
  final map = adminObject(
    value,
    'WorkloadIdentityFederationRule.attributeMatchers',
  );
  return Map.unmodifiable({
    for (final MapEntry(:key, :value) in map.entries)
      key: switch (value) {
        String() || bool() => value as Object,
        num() when value.isFinite => value,
        _ => throw const FormatException(
          'Workload identity matchers must be strings, booleans or finite numbers',
        ),
      },
  });
}
