import 'admin_enums.dart';
import 'admin_json.dart';

/// Native variants: [AwsExternalKeyParams], [AzureExternalKeyParams], [GcpExternalKeyParams] and [UnknownExternalKeyParams].
sealed class ExternalKeyParams extends AdminJsonValue {
  const ExternalKeyParams();

  /// Exact provider discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Parses known fields or retains an immutable future variant.
  factory ExternalKeyParams.fromJson(Map<String, dynamic> json) =>
      switch (adminString(json['type'], 'ExternalKeyParams.type')) {
        'aws' => AwsExternalKeyParams.fromJson(json),
        'azure' => AzureExternalKeyParams.fromJson(json),
        'gcp' => GcpExternalKeyParams.fromJson(json),
        _ => UnknownExternalKeyParams.fromJson(json),
      };
}

/// Immutable future provider data, unavailable for writes.
final class UnknownExternalKeyParams extends ExternalKeyParams {
  const UnknownExternalKeyParams._(this.rawJson);

  /// Captures finite future JSON without printing it.
  factory UnknownExternalKeyParams.fromJson(Map<String, dynamic> json) {
    final type = adminString(json['type'], 'UnknownExternalKeyParams.type');
    if (['aws', 'azure', 'gcp'].contains(type)) {
      throw const FormatException(
        'UnknownExternalKeyParams: expected a future type',
      );
    }
    return UnknownExternalKeyParams._(
      adminSnapshot(json, 'UnknownExternalKeyParams'),
    );
  }

  /// Detached finite future JSON.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies opaque data without giving it writable authority.
  UnknownExternalKeyParams copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownExternalKeyParams.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownExternalKeyParams: unsupported request provider',
  );
}

/// AwsExternalKeyParams
final class AwsExternalKeyParams extends ExternalKeyParams {
  /// Captures typed fields and immutable permitted overflow JSON.
  AwsExternalKeyParams({
    required this.name,
    required this.roleArn,
    required this.kmsArn,
    required this.externalId,
    this.purpose,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'name',
         'type',
         'role_arn',
         'kms_arn',
         'external_id',
         'purpose',
       }, 'AwsExternalKeyParams') {
    validate();
  }

  /// Exact `name` wire value.
  final String name;

  /// Exact `role_arn` wire value.
  final String roleArn;

  /// Exact `kms_arn` wire value.
  final String kmsArn;

  /// Exact `external_id` wire value.
  final String externalId;

  /// Exact `purpose` wire value.
  final ExternalKeyPurpose? purpose;

  /// Fixed native discriminator.
  @override
  String get type => 'aws';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory AwsExternalKeyParams.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'type', 'aws', 'AwsExternalKeyParams');
    return AwsExternalKeyParams(
      name: adminRequired<String>(
        json,
        'name',
        'AwsExternalKeyParams.name',
        adminString,
        nullable: false,
      )!,
      roleArn: adminRequired<String>(
        json,
        'role_arn',
        'AwsExternalKeyParams.roleArn',
        adminString,
        nullable: false,
      )!,
      kmsArn: adminRequired<String>(
        json,
        'kms_arn',
        'AwsExternalKeyParams.kmsArn',
        adminString,
        nullable: false,
      )!,
      externalId: adminRequired<String>(
        json,
        'external_id',
        'AwsExternalKeyParams.externalId',
        adminString,
        nullable: false,
      )!,
      purpose: adminOptional<ExternalKeyPurpose>(
        json,
        'purpose',
        'AwsExternalKeyParams.purpose',
        (value, context) => ExternalKeyPurpose.fromJson(value),
        nullable: false,
      ),
      rawJson: json,
    );
  }
  @override
  void validate() {
    if (!RegExp(r'^arn:aws:iam::\d{12}:role/.+$').hasMatch(roleArn)) {
      throw const FormatException(
        'AwsExternalKeyParams.roleArn: invalid format',
      );
    }
    if (purpose != null) {
      purpose!.validate();
      if (!purpose!.isKnown) {
        throw const FormatException(
          'AwsExternalKeyParams.purpose: unsupported request value',
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'name': name,
    'role_arn': roleArn,
    'kms_arn': kmsArn,
    'external_id': externalId,
    if (purpose != null) 'purpose': purpose!.toJson(),
  };

  /// Copies every field; clear flags omit optional nullable members.
  AwsExternalKeyParams copyWith({
    String? name,
    String? roleArn,
    String? kmsArn,
    String? externalId,
    Object? purpose = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AwsExternalKeyParams(
    name: name ?? this.name,
    roleArn: roleArn ?? this.roleArn,
    kmsArn: kmsArn ?? this.kmsArn,
    externalId: externalId ?? this.externalId,
    purpose: adminCopy<ExternalKeyPurpose>(
      purpose,
      this.purpose,
      'AwsExternalKeyParams.purpose',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AzureExternalKeyParams
final class AzureExternalKeyParams extends ExternalKeyParams {
  /// Captures typed fields and immutable permitted overflow JSON.
  AzureExternalKeyParams({
    required this.name,
    required this.tenantId,
    required this.vaultUri,
    required this.keyName,
    this.purpose,
    this.keyVersion,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'name',
         'type',
         'tenant_id',
         'vault_uri',
         'key_name',
         'purpose',
         'key_version',
       }, 'AzureExternalKeyParams') {
    validate();
  }

  /// Exact `name` wire value.
  final String name;

  /// Exact `tenant_id` wire value.
  final String tenantId;

  /// Exact `vault_uri` wire value.
  final String vaultUri;

  /// Exact `key_name` wire value.
  final String keyName;

  /// Exact `purpose` wire value.
  final ExternalKeyPurpose? purpose;

  /// Exact `key_version` wire value.
  final String? keyVersion;

  /// Fixed native discriminator.
  @override
  String get type => 'azure';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory AzureExternalKeyParams.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'type', 'azure', 'AzureExternalKeyParams');
    return AzureExternalKeyParams(
      name: adminRequired<String>(
        json,
        'name',
        'AzureExternalKeyParams.name',
        adminString,
        nullable: false,
      )!,
      tenantId: adminRequired<String>(
        json,
        'tenant_id',
        'AzureExternalKeyParams.tenantId',
        adminString,
        nullable: false,
      )!,
      vaultUri: adminRequired<String>(
        json,
        'vault_uri',
        'AzureExternalKeyParams.vaultUri',
        adminString,
        nullable: false,
      )!,
      keyName: adminRequired<String>(
        json,
        'key_name',
        'AzureExternalKeyParams.keyName',
        adminString,
        nullable: false,
      )!,
      purpose: adminOptional<ExternalKeyPurpose>(
        json,
        'purpose',
        'AzureExternalKeyParams.purpose',
        (value, context) => ExternalKeyPurpose.fromJson(value),
        nullable: false,
      ),
      keyVersion: adminOptional<String>(
        json,
        'key_version',
        'AzureExternalKeyParams.keyVersion',
        adminString,
        nullable: false,
      ),
      rawJson: json,
    );
  }
  @override
  void validate() {
    if (!RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(tenantId)) {
      throw const FormatException(
        'AzureExternalKeyParams.tenantId: invalid format',
      );
    }
    if (!RegExp(r'^https://.+\.vault\.azure\.net/?$').hasMatch(vaultUri)) {
      throw const FormatException(
        'AzureExternalKeyParams.vaultUri: invalid format',
      );
    }
    adminLength(keyName, 'AzureExternalKeyParams.keyName', max: 127);
    if (!RegExp(r'^org-[0-9a-zA-Z-]*--[0-9a-zA-Z-]*$').hasMatch(keyName)) {
      throw const FormatException(
        'AzureExternalKeyParams.keyName: invalid format',
      );
    }
    if (purpose != null) {
      purpose!.validate();
      if (!purpose!.isKnown) {
        throw const FormatException(
          'AzureExternalKeyParams.purpose: unsupported request value',
        );
      }
    }
    if (keyVersion != null) {
      if (!RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(keyVersion!)) {
        throw const FormatException(
          'AzureExternalKeyParams.keyVersion: invalid format',
        );
      }
    }
    final selectedPurpose = purpose?.value ?? 'ekm';
    if ((selectedPurpose == 'psp_decryption') != (keyVersion != null)) {
      throw const FormatException(
        'AzureExternalKeyParams: keyVersion is required only for PSP decryption',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'name': name,
    'tenant_id': tenantId,
    'vault_uri': vaultUri,
    'key_name': keyName,
    if (purpose != null) 'purpose': purpose!.toJson(),
    if (keyVersion != null) 'key_version': keyVersion,
  };

  /// Copies every field; clear flags omit optional nullable members.
  AzureExternalKeyParams copyWith({
    String? name,
    String? tenantId,
    String? vaultUri,
    String? keyName,
    Object? purpose = unsetCopyWithValue,
    Object? keyVersion = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AzureExternalKeyParams(
    name: name ?? this.name,
    tenantId: tenantId ?? this.tenantId,
    vaultUri: vaultUri ?? this.vaultUri,
    keyName: keyName ?? this.keyName,
    purpose: adminCopy<ExternalKeyPurpose>(
      purpose,
      this.purpose,
      'AzureExternalKeyParams.purpose',
    ),
    keyVersion: adminCopy<String>(
      keyVersion,
      this.keyVersion,
      'AzureExternalKeyParams.keyVersion',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// GcpExternalKeyParams
final class GcpExternalKeyParams extends ExternalKeyParams {
  /// Captures typed fields and immutable permitted overflow JSON.
  GcpExternalKeyParams({
    required this.name,
    required this.workloadIdentityProjectNumber,
    required this.workloadIdentityPoolId,
    required this.workloadIdentityProviderId,
    required this.kmsProjectId,
    required this.kmsKeyRingName,
    required this.kmsKeyName,
    required this.kmsKeyLocation,
    required this.audience,
    this.purpose,
    this.kmsKeyVersion,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'name',
         'type',
         'workload_identity_project_number',
         'workload_identity_pool_id',
         'workload_identity_provider_id',
         'kms_project_id',
         'kms_key_ring_name',
         'kms_key_name',
         'kms_key_location',
         'audience',
         'purpose',
         'kms_key_version',
       }, 'GcpExternalKeyParams') {
    validate();
  }

  /// Exact `name` wire value.
  final String name;

  /// Exact `workload_identity_project_number` wire value.
  final String workloadIdentityProjectNumber;

  /// Exact `workload_identity_pool_id` wire value.
  final String workloadIdentityPoolId;

  /// Exact `workload_identity_provider_id` wire value.
  final String workloadIdentityProviderId;

  /// Exact `kms_project_id` wire value.
  final String kmsProjectId;

  /// Exact `kms_key_ring_name` wire value.
  final String kmsKeyRingName;

  /// Exact `kms_key_name` wire value.
  final String kmsKeyName;

  /// Exact `kms_key_location` wire value.
  final String kmsKeyLocation;

  /// Exact `audience` wire value.
  final String audience;

  /// Exact `purpose` wire value.
  final ExternalKeyPurpose? purpose;

  /// Exact `kms_key_version` wire value.
  final String? kmsKeyVersion;

  /// Fixed native discriminator.
  @override
  String get type => 'gcp';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory GcpExternalKeyParams.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'type', 'gcp', 'GcpExternalKeyParams');
    return GcpExternalKeyParams(
      name: adminRequired<String>(
        json,
        'name',
        'GcpExternalKeyParams.name',
        adminString,
        nullable: false,
      )!,
      workloadIdentityProjectNumber: adminRequired<String>(
        json,
        'workload_identity_project_number',
        'GcpExternalKeyParams.workloadIdentityProjectNumber',
        adminString,
        nullable: false,
      )!,
      workloadIdentityPoolId: adminRequired<String>(
        json,
        'workload_identity_pool_id',
        'GcpExternalKeyParams.workloadIdentityPoolId',
        adminString,
        nullable: false,
      )!,
      workloadIdentityProviderId: adminRequired<String>(
        json,
        'workload_identity_provider_id',
        'GcpExternalKeyParams.workloadIdentityProviderId',
        adminString,
        nullable: false,
      )!,
      kmsProjectId: adminRequired<String>(
        json,
        'kms_project_id',
        'GcpExternalKeyParams.kmsProjectId',
        adminString,
        nullable: false,
      )!,
      kmsKeyRingName: adminRequired<String>(
        json,
        'kms_key_ring_name',
        'GcpExternalKeyParams.kmsKeyRingName',
        adminString,
        nullable: false,
      )!,
      kmsKeyName: adminRequired<String>(
        json,
        'kms_key_name',
        'GcpExternalKeyParams.kmsKeyName',
        adminString,
        nullable: false,
      )!,
      kmsKeyLocation: adminRequired<String>(
        json,
        'kms_key_location',
        'GcpExternalKeyParams.kmsKeyLocation',
        adminString,
        nullable: false,
      )!,
      audience: adminRequired<String>(
        json,
        'audience',
        'GcpExternalKeyParams.audience',
        adminString,
        nullable: false,
      )!,
      purpose: adminOptional<ExternalKeyPurpose>(
        json,
        'purpose',
        'GcpExternalKeyParams.purpose',
        (value, context) => ExternalKeyPurpose.fromJson(value),
        nullable: false,
      ),
      kmsKeyVersion: adminOptional<String>(
        json,
        'kms_key_version',
        'GcpExternalKeyParams.kmsKeyVersion',
        adminString,
        nullable: false,
      ),
      rawJson: json,
    );
  }
  @override
  void validate() {
    if (!RegExp(r'^[0-9]{1,19}$').hasMatch(workloadIdentityProjectNumber)) {
      throw const FormatException(
        'GcpExternalKeyParams.workloadIdentityProjectNumber: invalid format',
      );
    }
    if (purpose != null) {
      purpose!.validate();
      if (!purpose!.isKnown) {
        throw const FormatException(
          'GcpExternalKeyParams.purpose: unsupported request value',
        );
      }
    }
    if (kmsKeyVersion != null) {
      if (!RegExp(r'^[1-9][0-9]*$').hasMatch(kmsKeyVersion!)) {
        throw const FormatException(
          'GcpExternalKeyParams.kmsKeyVersion: invalid format',
        );
      }
    }
    final selectedPurpose = purpose?.value ?? 'ekm';
    if ((selectedPurpose == 'psp_decryption') != (kmsKeyVersion != null)) {
      throw const FormatException(
        'GcpExternalKeyParams: kmsKeyVersion is required only for PSP decryption',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'name': name,
    'workload_identity_project_number': workloadIdentityProjectNumber,
    'workload_identity_pool_id': workloadIdentityPoolId,
    'workload_identity_provider_id': workloadIdentityProviderId,
    'kms_project_id': kmsProjectId,
    'kms_key_ring_name': kmsKeyRingName,
    'kms_key_name': kmsKeyName,
    'kms_key_location': kmsKeyLocation,
    'audience': audience,
    if (purpose != null) 'purpose': purpose!.toJson(),
    if (kmsKeyVersion != null) 'kms_key_version': kmsKeyVersion,
  };

  /// Copies every field; clear flags omit optional nullable members.
  GcpExternalKeyParams copyWith({
    String? name,
    String? workloadIdentityProjectNumber,
    String? workloadIdentityPoolId,
    String? workloadIdentityProviderId,
    String? kmsProjectId,
    String? kmsKeyRingName,
    String? kmsKeyName,
    String? kmsKeyLocation,
    String? audience,
    Object? purpose = unsetCopyWithValue,
    Object? kmsKeyVersion = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => GcpExternalKeyParams(
    name: name ?? this.name,
    workloadIdentityProjectNumber:
        workloadIdentityProjectNumber ?? this.workloadIdentityProjectNumber,
    workloadIdentityPoolId:
        workloadIdentityPoolId ?? this.workloadIdentityPoolId,
    workloadIdentityProviderId:
        workloadIdentityProviderId ?? this.workloadIdentityProviderId,
    kmsProjectId: kmsProjectId ?? this.kmsProjectId,
    kmsKeyRingName: kmsKeyRingName ?? this.kmsKeyRingName,
    kmsKeyName: kmsKeyName ?? this.kmsKeyName,
    kmsKeyLocation: kmsKeyLocation ?? this.kmsKeyLocation,
    audience: audience ?? this.audience,
    purpose: adminCopy<ExternalKeyPurpose>(
      purpose,
      this.purpose,
      'GcpExternalKeyParams.purpose',
    ),
    kmsKeyVersion: adminCopy<String>(
      kmsKeyVersion,
      this.kmsKeyVersion,
      'GcpExternalKeyParams.kmsKeyVersion',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// ExternalKey
final class ExternalKey extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ExternalKey({
    required this.object,
    required this.id,
    required this.type,
    this.purpose,
    required this.name,
    required List<String> apiProjectIds,
    required this.workspaceId,
    required this.createdAt,
    this.roleArn,
    this.externalId,
    this.kmsArn,
    this.workloadIdentityProjectNumber,
    this.workloadIdentityPoolId,
    this.workloadIdentityProviderId,
    this.audience,
    this.kmsProjectId,
    this.kmsKeyRingName,
    this.kmsKeyName,
    this.kmsKeyLocation,
    this.kmsKeyVersion,
    this.tenantId,
    this.vaultUri,
    this.keyName,
    this.keyVersion,
    Map<String, dynamic> rawJson = const {},
  }) : apiProjectIds = List<String>.unmodifiable(apiProjectIds),
       rawJson = adminExtras(rawJson, {
         'object',
         'id',
         'type',
         'purpose',
         'name',
         'api_project_ids',
         'workspace_id',
         'created_at',
         'role_arn',
         'external_id',
         'kms_arn',
         'workload_identity_project_number',
         'workload_identity_pool_id',
         'workload_identity_provider_id',
         'audience',
         'kms_project_id',
         'kms_key_ring_name',
         'kms_key_name',
         'kms_key_location',
         'kms_key_version',
         'tenant_id',
         'vault_uri',
         'key_name',
         'key_version',
       }, 'ExternalKey') {
    validate();
  }

  /// Exact `object` wire value.
  final String object;

  /// Exact `id` wire value.
  final String id;

  /// Exact `type` wire value.
  final String type;

  /// Exact `purpose` wire value.
  final ExternalKeyPurpose? purpose;

  /// Exact `name` wire value.
  final String name;

  /// Exact `api_project_ids` wire value.
  final List<String> apiProjectIds;

  /// Exact `workspace_id` wire value.
  final String workspaceId;

  /// Exact `created_at` wire value.
  final int createdAt;

  /// Exact `role_arn` wire value.
  final String? roleArn;

  /// Exact `external_id` wire value.
  final String? externalId;

  /// Exact `kms_arn` wire value.
  final String? kmsArn;

  /// Exact `workload_identity_project_number` wire value.
  final String? workloadIdentityProjectNumber;

  /// Exact `workload_identity_pool_id` wire value.
  final String? workloadIdentityPoolId;

  /// Exact `workload_identity_provider_id` wire value.
  final String? workloadIdentityProviderId;

  /// Exact `audience` wire value.
  final String? audience;

  /// Exact `kms_project_id` wire value.
  final String? kmsProjectId;

  /// Exact `kms_key_ring_name` wire value.
  final String? kmsKeyRingName;

  /// Exact `kms_key_name` wire value.
  final String? kmsKeyName;

  /// Exact `kms_key_location` wire value.
  final String? kmsKeyLocation;

  /// Exact `kms_key_version` wire value.
  final String? kmsKeyVersion;

  /// Exact `tenant_id` wire value.
  final String? tenantId;

  /// Exact `vault_uri` wire value.
  final String? vaultUri;

  /// Exact `key_name` wire value.
  final String? keyName;

  /// Exact `key_version` wire value.
  final String? keyVersion;

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ExternalKey.fromJson(Map<String, dynamic> json) {
    return ExternalKey(
      object: adminRequired<String>(
        json,
        'object',
        'ExternalKey.object',
        adminString,
        nullable: false,
      )!,
      id: adminRequired<String>(
        json,
        'id',
        'ExternalKey.id',
        adminString,
        nullable: false,
      )!,
      type: adminRequired<String>(
        json,
        'type',
        'ExternalKey.type',
        adminString,
        nullable: false,
      )!,
      purpose: adminOptional<ExternalKeyPurpose>(
        json,
        'purpose',
        'ExternalKey.purpose',
        (value, context) => ExternalKeyPurpose.fromJson(value),
        nullable: false,
      ),
      name: adminRequired<String>(
        json,
        'name',
        'ExternalKey.name',
        adminString,
        nullable: false,
      )!,
      apiProjectIds: adminRequired<List<String>>(
        json,
        'api_project_ids',
        'ExternalKey.apiProjectIds',
        (value, context) => [
          for (final item in adminList(value, context))
            adminString(item, context),
        ],
        nullable: false,
      )!,
      workspaceId: adminRequired<String>(
        json,
        'workspace_id',
        'ExternalKey.workspaceId',
        adminString,
        nullable: false,
      )!,
      createdAt: adminRequired<int>(
        json,
        'created_at',
        'ExternalKey.createdAt',
        adminInt,
        nullable: false,
      )!,
      roleArn: adminOptional<String>(
        json,
        'role_arn',
        'ExternalKey.roleArn',
        adminString,
        nullable: false,
      ),
      externalId: adminOptional<String>(
        json,
        'external_id',
        'ExternalKey.externalId',
        adminString,
        nullable: false,
      ),
      kmsArn: adminOptional<String>(
        json,
        'kms_arn',
        'ExternalKey.kmsArn',
        adminString,
        nullable: false,
      ),
      workloadIdentityProjectNumber: adminOptional<String>(
        json,
        'workload_identity_project_number',
        'ExternalKey.workloadIdentityProjectNumber',
        adminString,
        nullable: false,
      ),
      workloadIdentityPoolId: adminOptional<String>(
        json,
        'workload_identity_pool_id',
        'ExternalKey.workloadIdentityPoolId',
        adminString,
        nullable: false,
      ),
      workloadIdentityProviderId: adminOptional<String>(
        json,
        'workload_identity_provider_id',
        'ExternalKey.workloadIdentityProviderId',
        adminString,
        nullable: false,
      ),
      audience: adminOptional<String>(
        json,
        'audience',
        'ExternalKey.audience',
        adminString,
        nullable: false,
      ),
      kmsProjectId: adminOptional<String>(
        json,
        'kms_project_id',
        'ExternalKey.kmsProjectId',
        adminString,
        nullable: false,
      ),
      kmsKeyRingName: adminOptional<String>(
        json,
        'kms_key_ring_name',
        'ExternalKey.kmsKeyRingName',
        adminString,
        nullable: false,
      ),
      kmsKeyName: adminOptional<String>(
        json,
        'kms_key_name',
        'ExternalKey.kmsKeyName',
        adminString,
        nullable: false,
      ),
      kmsKeyLocation: adminOptional<String>(
        json,
        'kms_key_location',
        'ExternalKey.kmsKeyLocation',
        adminString,
        nullable: false,
      ),
      kmsKeyVersion: adminOptional<String>(
        json,
        'kms_key_version',
        'ExternalKey.kmsKeyVersion',
        adminString,
        nullable: false,
      ),
      tenantId: adminOptional<String>(
        json,
        'tenant_id',
        'ExternalKey.tenantId',
        adminString,
        nullable: false,
      ),
      vaultUri: adminOptional<String>(
        json,
        'vault_uri',
        'ExternalKey.vaultUri',
        adminString,
        nullable: false,
      ),
      keyName: adminOptional<String>(
        json,
        'key_name',
        'ExternalKey.keyName',
        adminString,
        nullable: false,
      ),
      keyVersion: adminOptional<String>(
        json,
        'key_version',
        'ExternalKey.keyVersion',
        adminString,
        nullable: false,
      ),
      rawJson: json,
    );
  }
  @override
  void validate() {
    if (purpose != null) {
      purpose!.validate();
    }
    adminInt(createdAt, 'ExternalKey.createdAt');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'id': id,
    'type': type,
    if (purpose != null) 'purpose': purpose!.toJson(),
    'name': name,
    'api_project_ids': apiProjectIds,
    'workspace_id': workspaceId,
    'created_at': createdAt,
    if (roleArn != null) 'role_arn': roleArn,
    if (externalId != null) 'external_id': externalId,
    if (kmsArn != null) 'kms_arn': kmsArn,
    if (workloadIdentityProjectNumber != null)
      'workload_identity_project_number': workloadIdentityProjectNumber,
    if (workloadIdentityPoolId != null)
      'workload_identity_pool_id': workloadIdentityPoolId,
    if (workloadIdentityProviderId != null)
      'workload_identity_provider_id': workloadIdentityProviderId,
    if (audience != null) 'audience': audience,
    if (kmsProjectId != null) 'kms_project_id': kmsProjectId,
    if (kmsKeyRingName != null) 'kms_key_ring_name': kmsKeyRingName,
    if (kmsKeyName != null) 'kms_key_name': kmsKeyName,
    if (kmsKeyLocation != null) 'kms_key_location': kmsKeyLocation,
    if (kmsKeyVersion != null) 'kms_key_version': kmsKeyVersion,
    if (tenantId != null) 'tenant_id': tenantId,
    if (vaultUri != null) 'vault_uri': vaultUri,
    if (keyName != null) 'key_name': keyName,
    if (keyVersion != null) 'key_version': keyVersion,
  };

  /// Copies every field; clear flags omit optional nullable members.
  ExternalKey copyWith({
    String? object,
    String? id,
    String? type,
    Object? purpose = unsetCopyWithValue,
    String? name,
    List<String>? apiProjectIds,
    String? workspaceId,
    int? createdAt,
    Object? roleArn = unsetCopyWithValue,
    Object? externalId = unsetCopyWithValue,
    Object? kmsArn = unsetCopyWithValue,
    Object? workloadIdentityProjectNumber = unsetCopyWithValue,
    Object? workloadIdentityPoolId = unsetCopyWithValue,
    Object? workloadIdentityProviderId = unsetCopyWithValue,
    Object? audience = unsetCopyWithValue,
    Object? kmsProjectId = unsetCopyWithValue,
    Object? kmsKeyRingName = unsetCopyWithValue,
    Object? kmsKeyName = unsetCopyWithValue,
    Object? kmsKeyLocation = unsetCopyWithValue,
    Object? kmsKeyVersion = unsetCopyWithValue,
    Object? tenantId = unsetCopyWithValue,
    Object? vaultUri = unsetCopyWithValue,
    Object? keyName = unsetCopyWithValue,
    Object? keyVersion = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ExternalKey(
    object: object ?? this.object,
    id: id ?? this.id,
    type: type ?? this.type,
    purpose: adminCopy<ExternalKeyPurpose>(
      purpose,
      this.purpose,
      'ExternalKey.purpose',
    ),
    name: name ?? this.name,
    apiProjectIds: apiProjectIds ?? this.apiProjectIds,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt ?? this.createdAt,
    roleArn: adminCopy<String>(roleArn, this.roleArn, 'ExternalKey.roleArn'),
    externalId: adminCopy<String>(
      externalId,
      this.externalId,
      'ExternalKey.externalId',
    ),
    kmsArn: adminCopy<String>(kmsArn, this.kmsArn, 'ExternalKey.kmsArn'),
    workloadIdentityProjectNumber: adminCopy<String>(
      workloadIdentityProjectNumber,
      this.workloadIdentityProjectNumber,
      'ExternalKey.workloadIdentityProjectNumber',
    ),
    workloadIdentityPoolId: adminCopy<String>(
      workloadIdentityPoolId,
      this.workloadIdentityPoolId,
      'ExternalKey.workloadIdentityPoolId',
    ),
    workloadIdentityProviderId: adminCopy<String>(
      workloadIdentityProviderId,
      this.workloadIdentityProviderId,
      'ExternalKey.workloadIdentityProviderId',
    ),
    audience: adminCopy<String>(
      audience,
      this.audience,
      'ExternalKey.audience',
    ),
    kmsProjectId: adminCopy<String>(
      kmsProjectId,
      this.kmsProjectId,
      'ExternalKey.kmsProjectId',
    ),
    kmsKeyRingName: adminCopy<String>(
      kmsKeyRingName,
      this.kmsKeyRingName,
      'ExternalKey.kmsKeyRingName',
    ),
    kmsKeyName: adminCopy<String>(
      kmsKeyName,
      this.kmsKeyName,
      'ExternalKey.kmsKeyName',
    ),
    kmsKeyLocation: adminCopy<String>(
      kmsKeyLocation,
      this.kmsKeyLocation,
      'ExternalKey.kmsKeyLocation',
    ),
    kmsKeyVersion: adminCopy<String>(
      kmsKeyVersion,
      this.kmsKeyVersion,
      'ExternalKey.kmsKeyVersion',
    ),
    tenantId: adminCopy<String>(
      tenantId,
      this.tenantId,
      'ExternalKey.tenantId',
    ),
    vaultUri: adminCopy<String>(
      vaultUri,
      this.vaultUri,
      'ExternalKey.vaultUri',
    ),
    keyName: adminCopy<String>(keyName, this.keyName, 'ExternalKey.keyName'),
    keyVersion: adminCopy<String>(
      keyVersion,
      this.keyVersion,
      'ExternalKey.keyVersion',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// ExternalKeyList
final class ExternalKeyList extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ExternalKeyList({
    required List<ExternalKey> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List<ExternalKey>.unmodifiable(data),
       rawJson = adminExtras(rawJson, {
         'object',
         'data',
         'first_id',
         'last_id',
         'has_more',
       }, 'ExternalKeyList') {
    validate();
  }

  /// Exact `data` wire value.
  final List<ExternalKey> data;

  /// Exact `first_id` wire value.
  final String? firstId;

  /// Exact `last_id` wire value.
  final String? lastId;

  /// Exact `has_more` wire value.
  final bool hasMore;

  /// Fixed native discriminator.
  String get object => 'list';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ExternalKeyList.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'object', 'list', 'ExternalKeyList');
    return ExternalKeyList(
      data: adminRequired<List<ExternalKey>>(
        json,
        'data',
        'ExternalKeyList.data',
        (value, context) => [
          for (final item in adminList(value, context))
            ExternalKey.fromJson(adminObject(item, context)),
        ],
        nullable: false,
      )!,
      firstId: adminRequired<String>(
        json,
        'first_id',
        'ExternalKeyList.firstId',
        adminString,
        nullable: true,
      ),
      lastId: adminRequired<String>(
        json,
        'last_id',
        'ExternalKeyList.lastId',
        adminString,
        nullable: true,
      ),
      hasMore: adminRequired<bool>(
        json,
        'has_more',
        'ExternalKeyList.hasMore',
        adminBool,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    for (final value in data) {
      value.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'data': data.map((value) => value.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  /// Copies every field; clear flags omit optional nullable members.
  ExternalKeyList copyWith({
    List<ExternalKey>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => ExternalKeyList(
    data: data ?? this.data,
    firstId: adminCopy<String>(
      firstId,
      this.firstId,
      'ExternalKeyList.firstId',
    ),
    lastId: adminCopy<String>(lastId, this.lastId, 'ExternalKeyList.lastId'),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// ExternalKeyValidation
final class ExternalKeyValidation extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ExternalKeyValidation({
    required this.status,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {'status'}, 'ExternalKeyValidation') {
    validate();
  }

  /// Exact `status` wire value.
  final String status;

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ExternalKeyValidation.fromJson(Map<String, dynamic> json) {
    return ExternalKeyValidation(
      status: adminRequired<String>(
        json,
        'status',
        'ExternalKeyValidation.status',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'status': status};

  /// Copies every field; clear flags omit optional nullable members.
  ExternalKeyValidation copyWith({
    String? status,
    Map<String, dynamic>? rawJson,
  }) => ExternalKeyValidation(
    status: status ?? this.status,
    rawJson: rawJson ?? this.rawJson,
  );
}
