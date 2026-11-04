import 'admin_enums.dart';
import 'admin_json.dart';

/// Native variants: [AwsExternalStorageProviderParams], [AzureExternalStorageProviderParams], [GcpExternalStorageProviderParams], [OciExternalStorageProviderParams] and [UnknownExternalStorageProviderParams].
sealed class ExternalStorageProviderParams extends AdminJsonValue {
  const ExternalStorageProviderParams();

  /// Exact provider discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Parses known fields or retains an immutable future variant.
  factory ExternalStorageProviderParams.fromJson(Map<String, dynamic> json) =>
      switch (adminString(json['type'], 'ExternalStorageProviderParams.type')) {
        'aws' => AwsExternalStorageProviderParams.fromJson(json),
        'azure' => AzureExternalStorageProviderParams.fromJson(json),
        'gcp' => GcpExternalStorageProviderParams.fromJson(json),
        'oci' => OciExternalStorageProviderParams.fromJson(json),
        _ => UnknownExternalStorageProviderParams.fromJson(json),
      };
}

/// Immutable future provider data, unavailable for writes.
final class UnknownExternalStorageProviderParams
    extends ExternalStorageProviderParams {
  const UnknownExternalStorageProviderParams._(this.rawJson);

  /// Captures finite future JSON without printing it.
  factory UnknownExternalStorageProviderParams.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = adminString(
      json['type'],
      'UnknownExternalStorageProviderParams.type',
    );
    if (['aws', 'azure', 'gcp', 'oci'].contains(type)) {
      throw const FormatException(
        'UnknownExternalStorageProviderParams: expected a future type',
      );
    }
    return UnknownExternalStorageProviderParams._(
      adminSnapshot(json, 'UnknownExternalStorageProviderParams'),
    );
  }

  /// Detached finite future JSON.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies opaque data without giving it writable authority.
  UnknownExternalStorageProviderParams copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownExternalStorageProviderParams.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownExternalStorageProviderParams: unsupported request provider',
  );
}

/// Native variants: [AwsExternalStorageProviderResponse], [AzureExternalStorageProviderResponse], [GcpExternalStorageProviderResponse], [OciExternalStorageProviderResponse] and [UnknownExternalStorageProvider].
sealed class ExternalStorageProvider extends AdminJsonValue {
  const ExternalStorageProvider();

  /// Exact provider discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Parses known fields or retains an immutable future variant.
  factory ExternalStorageProvider.fromJson(Map<String, dynamic> json) =>
      switch (adminString(json['type'], 'ExternalStorageProvider.type')) {
        'aws' => AwsExternalStorageProviderResponse.fromJson(json),
        'azure' => AzureExternalStorageProviderResponse.fromJson(json),
        'gcp' => GcpExternalStorageProviderResponse.fromJson(json),
        'oci' => OciExternalStorageProviderResponse.fromJson(json),
        _ => UnknownExternalStorageProvider.fromJson(json),
      };
}

/// Immutable future provider data.
final class UnknownExternalStorageProvider extends ExternalStorageProvider {
  const UnknownExternalStorageProvider._(this.rawJson);

  /// Captures finite future JSON without printing it.
  factory UnknownExternalStorageProvider.fromJson(Map<String, dynamic> json) {
    final type = adminString(
      json['type'],
      'UnknownExternalStorageProvider.type',
    );
    if (['aws', 'azure', 'gcp', 'oci'].contains(type)) {
      throw const FormatException(
        'UnknownExternalStorageProvider: expected a future type',
      );
    }
    return UnknownExternalStorageProvider._(
      adminSnapshot(json, 'UnknownExternalStorageProvider'),
    );
  }

  /// Detached finite future JSON.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies opaque data without giving it writable authority.
  UnknownExternalStorageProvider copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownExternalStorageProvider.fromJson(rawJson ?? this.rawJson);
}

/// AwsExternalStorageProviderParams
final class AwsExternalStorageProviderParams
    extends ExternalStorageProviderParams {
  /// Captures typed fields and immutable permitted overflow JSON.
  AwsExternalStorageProviderParams({
    required this.bucket,
    required this.roleArn,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'bucket',
         'role_arn',
       }, 'AwsExternalStorageProviderParams') {
    validate();
  }

  /// Exact `bucket` wire value.
  final String bucket;

  /// Exact `role_arn` wire value.
  final String roleArn;

  /// Fixed native discriminator.
  @override
  String get type => 'aws';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory AwsExternalStorageProviderParams.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'type', 'aws', 'AwsExternalStorageProviderParams');
    return AwsExternalStorageProviderParams(
      bucket: adminRequired<String>(
        json,
        'bucket',
        'AwsExternalStorageProviderParams.bucket',
        adminString,
        nullable: false,
      )!,
      roleArn: adminRequired<String>(
        json,
        'role_arn',
        'AwsExternalStorageProviderParams.roleArn',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'bucket': bucket,
    'role_arn': roleArn,
  };

  /// Copies every field; clear flags omit optional nullable members.
  AwsExternalStorageProviderParams copyWith({
    String? bucket,
    String? roleArn,
    Map<String, dynamic>? rawJson,
  }) => AwsExternalStorageProviderParams(
    bucket: bucket ?? this.bucket,
    roleArn: roleArn ?? this.roleArn,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AzureExternalStorageProviderParams
final class AzureExternalStorageProviderParams
    extends ExternalStorageProviderParams {
  /// Captures typed fields and immutable permitted overflow JSON.
  AzureExternalStorageProviderParams({
    required this.tenantId,
    required this.subscriptionId,
    required this.resourceGroup,
    required this.accountName,
    required this.container,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'tenant_id',
         'subscription_id',
         'resource_group',
         'account_name',
         'container',
       }, 'AzureExternalStorageProviderParams') {
    validate();
  }

  /// Exact `tenant_id` wire value.
  final String tenantId;

  /// Exact `subscription_id` wire value.
  final String subscriptionId;

  /// Exact `resource_group` wire value.
  final String resourceGroup;

  /// Exact `account_name` wire value.
  final String accountName;

  /// Exact `container` wire value.
  final String container;

  /// Fixed native discriminator.
  @override
  String get type => 'azure';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory AzureExternalStorageProviderParams.fromJson(
    Map<String, dynamic> json,
  ) {
    adminTag(json, 'type', 'azure', 'AzureExternalStorageProviderParams');
    return AzureExternalStorageProviderParams(
      tenantId: adminRequired<String>(
        json,
        'tenant_id',
        'AzureExternalStorageProviderParams.tenantId',
        adminString,
        nullable: false,
      )!,
      subscriptionId: adminRequired<String>(
        json,
        'subscription_id',
        'AzureExternalStorageProviderParams.subscriptionId',
        adminString,
        nullable: false,
      )!,
      resourceGroup: adminRequired<String>(
        json,
        'resource_group',
        'AzureExternalStorageProviderParams.resourceGroup',
        adminString,
        nullable: false,
      )!,
      accountName: adminRequired<String>(
        json,
        'account_name',
        'AzureExternalStorageProviderParams.accountName',
        adminString,
        nullable: false,
      )!,
      container: adminRequired<String>(
        json,
        'container',
        'AzureExternalStorageProviderParams.container',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'tenant_id': tenantId,
    'subscription_id': subscriptionId,
    'resource_group': resourceGroup,
    'account_name': accountName,
    'container': container,
  };

  /// Copies every field; clear flags omit optional nullable members.
  AzureExternalStorageProviderParams copyWith({
    String? tenantId,
    String? subscriptionId,
    String? resourceGroup,
    String? accountName,
    String? container,
    Map<String, dynamic>? rawJson,
  }) => AzureExternalStorageProviderParams(
    tenantId: tenantId ?? this.tenantId,
    subscriptionId: subscriptionId ?? this.subscriptionId,
    resourceGroup: resourceGroup ?? this.resourceGroup,
    accountName: accountName ?? this.accountName,
    container: container ?? this.container,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// GcpExternalStorageProviderParams
final class GcpExternalStorageProviderParams
    extends ExternalStorageProviderParams {
  /// Captures typed fields and immutable permitted overflow JSON.
  GcpExternalStorageProviderParams({
    required this.bucket,
    required this.workloadIdentityProjectNumber,
    required this.workloadIdentityPoolId,
    required this.workloadIdentityProviderId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'bucket',
         'workload_identity_project_number',
         'workload_identity_pool_id',
         'workload_identity_provider_id',
       }, 'GcpExternalStorageProviderParams') {
    validate();
  }

  /// Exact `bucket` wire value.
  final String bucket;

  /// Exact `workload_identity_project_number` wire value.
  final String workloadIdentityProjectNumber;

  /// Exact `workload_identity_pool_id` wire value.
  final String workloadIdentityPoolId;

  /// Exact `workload_identity_provider_id` wire value.
  final String workloadIdentityProviderId;

  /// Fixed native discriminator.
  @override
  String get type => 'gcp';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory GcpExternalStorageProviderParams.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'type', 'gcp', 'GcpExternalStorageProviderParams');
    return GcpExternalStorageProviderParams(
      bucket: adminRequired<String>(
        json,
        'bucket',
        'GcpExternalStorageProviderParams.bucket',
        adminString,
        nullable: false,
      )!,
      workloadIdentityProjectNumber: adminRequired<String>(
        json,
        'workload_identity_project_number',
        'GcpExternalStorageProviderParams.workloadIdentityProjectNumber',
        adminString,
        nullable: false,
      )!,
      workloadIdentityPoolId: adminRequired<String>(
        json,
        'workload_identity_pool_id',
        'GcpExternalStorageProviderParams.workloadIdentityPoolId',
        adminString,
        nullable: false,
      )!,
      workloadIdentityProviderId: adminRequired<String>(
        json,
        'workload_identity_provider_id',
        'GcpExternalStorageProviderParams.workloadIdentityProviderId',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'bucket': bucket,
    'workload_identity_project_number': workloadIdentityProjectNumber,
    'workload_identity_pool_id': workloadIdentityPoolId,
    'workload_identity_provider_id': workloadIdentityProviderId,
  };

  /// Copies every field; clear flags omit optional nullable members.
  GcpExternalStorageProviderParams copyWith({
    String? bucket,
    String? workloadIdentityProjectNumber,
    String? workloadIdentityPoolId,
    String? workloadIdentityProviderId,
    Map<String, dynamic>? rawJson,
  }) => GcpExternalStorageProviderParams(
    bucket: bucket ?? this.bucket,
    workloadIdentityProjectNumber:
        workloadIdentityProjectNumber ?? this.workloadIdentityProjectNumber,
    workloadIdentityPoolId:
        workloadIdentityPoolId ?? this.workloadIdentityPoolId,
    workloadIdentityProviderId:
        workloadIdentityProviderId ?? this.workloadIdentityProviderId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// OciExternalStorageProviderParams
final class OciExternalStorageProviderParams
    extends ExternalStorageProviderParams {
  /// Captures typed fields and immutable permitted overflow JSON.
  OciExternalStorageProviderParams({
    required this.tenancyOcid,
    required this.region,
    required this.bucket,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'tenancy_ocid',
         'region',
         'bucket',
       }, 'OciExternalStorageProviderParams') {
    validate();
  }

  /// Exact `tenancy_ocid` wire value.
  final String tenancyOcid;

  /// Exact `region` wire value.
  final String region;

  /// Exact `bucket` wire value.
  final String bucket;

  /// Fixed native discriminator.
  @override
  String get type => 'oci';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory OciExternalStorageProviderParams.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'type', 'oci', 'OciExternalStorageProviderParams');
    return OciExternalStorageProviderParams(
      tenancyOcid: adminRequired<String>(
        json,
        'tenancy_ocid',
        'OciExternalStorageProviderParams.tenancyOcid',
        adminString,
        nullable: false,
      )!,
      region: adminRequired<String>(
        json,
        'region',
        'OciExternalStorageProviderParams.region',
        adminString,
        nullable: false,
      )!,
      bucket: adminRequired<String>(
        json,
        'bucket',
        'OciExternalStorageProviderParams.bucket',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'tenancy_ocid': tenancyOcid,
    'region': region,
    'bucket': bucket,
  };

  /// Copies every field; clear flags omit optional nullable members.
  OciExternalStorageProviderParams copyWith({
    String? tenancyOcid,
    String? region,
    String? bucket,
    Map<String, dynamic>? rawJson,
  }) => OciExternalStorageProviderParams(
    tenancyOcid: tenancyOcid ?? this.tenancyOcid,
    region: region ?? this.region,
    bucket: bucket ?? this.bucket,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AwsExternalStorageProviderResponse
final class AwsExternalStorageProviderResponse extends ExternalStorageProvider {
  /// Captures typed fields and immutable permitted overflow JSON.
  AwsExternalStorageProviderResponse({
    required this.accountId,
    required this.region,
    required this.bucket,
    required this.roleArn,
    required this.externalId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'account_id',
         'region',
         'bucket',
         'role_arn',
         'external_id',
       }, 'AwsExternalStorageProviderResponse') {
    validate();
  }

  /// Exact `account_id` wire value.
  final String accountId;

  /// Exact `region` wire value.
  final String region;

  /// Exact `bucket` wire value.
  final String bucket;

  /// Exact `role_arn` wire value.
  final String roleArn;

  /// Exact `external_id` wire value.
  final String externalId;

  /// Fixed native discriminator.
  @override
  String get type => 'aws';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory AwsExternalStorageProviderResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    adminTag(json, 'type', 'aws', 'AwsExternalStorageProviderResponse');
    return AwsExternalStorageProviderResponse(
      accountId: adminRequired<String>(
        json,
        'account_id',
        'AwsExternalStorageProviderResponse.accountId',
        adminString,
        nullable: false,
      )!,
      region: adminRequired<String>(
        json,
        'region',
        'AwsExternalStorageProviderResponse.region',
        adminString,
        nullable: false,
      )!,
      bucket: adminRequired<String>(
        json,
        'bucket',
        'AwsExternalStorageProviderResponse.bucket',
        adminString,
        nullable: false,
      )!,
      roleArn: adminRequired<String>(
        json,
        'role_arn',
        'AwsExternalStorageProviderResponse.roleArn',
        adminString,
        nullable: false,
      )!,
      externalId: adminRequired<String>(
        json,
        'external_id',
        'AwsExternalStorageProviderResponse.externalId',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'account_id': accountId,
    'region': region,
    'bucket': bucket,
    'role_arn': roleArn,
    'external_id': externalId,
  };

  /// Copies every field; clear flags omit optional nullable members.
  AwsExternalStorageProviderResponse copyWith({
    String? accountId,
    String? region,
    String? bucket,
    String? roleArn,
    String? externalId,
    Map<String, dynamic>? rawJson,
  }) => AwsExternalStorageProviderResponse(
    accountId: accountId ?? this.accountId,
    region: region ?? this.region,
    bucket: bucket ?? this.bucket,
    roleArn: roleArn ?? this.roleArn,
    externalId: externalId ?? this.externalId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AzureExternalStorageProviderResponse
final class AzureExternalStorageProviderResponse
    extends ExternalStorageProvider {
  /// Captures typed fields and immutable permitted overflow JSON.
  AzureExternalStorageProviderResponse({
    required this.tenantId,
    required this.subscriptionId,
    required this.resourceGroup,
    required this.accountName,
    required this.container,
    required this.region,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'tenant_id',
         'subscription_id',
         'resource_group',
         'account_name',
         'container',
         'region',
       }, 'AzureExternalStorageProviderResponse') {
    validate();
  }

  /// Exact `tenant_id` wire value.
  final String tenantId;

  /// Exact `subscription_id` wire value.
  final String subscriptionId;

  /// Exact `resource_group` wire value.
  final String resourceGroup;

  /// Exact `account_name` wire value.
  final String accountName;

  /// Exact `container` wire value.
  final String container;

  /// Exact `region` wire value.
  final String region;

  /// Fixed native discriminator.
  @override
  String get type => 'azure';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory AzureExternalStorageProviderResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    adminTag(json, 'type', 'azure', 'AzureExternalStorageProviderResponse');
    return AzureExternalStorageProviderResponse(
      tenantId: adminRequired<String>(
        json,
        'tenant_id',
        'AzureExternalStorageProviderResponse.tenantId',
        adminString,
        nullable: false,
      )!,
      subscriptionId: adminRequired<String>(
        json,
        'subscription_id',
        'AzureExternalStorageProviderResponse.subscriptionId',
        adminString,
        nullable: false,
      )!,
      resourceGroup: adminRequired<String>(
        json,
        'resource_group',
        'AzureExternalStorageProviderResponse.resourceGroup',
        adminString,
        nullable: false,
      )!,
      accountName: adminRequired<String>(
        json,
        'account_name',
        'AzureExternalStorageProviderResponse.accountName',
        adminString,
        nullable: false,
      )!,
      container: adminRequired<String>(
        json,
        'container',
        'AzureExternalStorageProviderResponse.container',
        adminString,
        nullable: false,
      )!,
      region: adminRequired<String>(
        json,
        'region',
        'AzureExternalStorageProviderResponse.region',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'tenant_id': tenantId,
    'subscription_id': subscriptionId,
    'resource_group': resourceGroup,
    'account_name': accountName,
    'container': container,
    'region': region,
  };

  /// Copies every field; clear flags omit optional nullable members.
  AzureExternalStorageProviderResponse copyWith({
    String? tenantId,
    String? subscriptionId,
    String? resourceGroup,
    String? accountName,
    String? container,
    String? region,
    Map<String, dynamic>? rawJson,
  }) => AzureExternalStorageProviderResponse(
    tenantId: tenantId ?? this.tenantId,
    subscriptionId: subscriptionId ?? this.subscriptionId,
    resourceGroup: resourceGroup ?? this.resourceGroup,
    accountName: accountName ?? this.accountName,
    container: container ?? this.container,
    region: region ?? this.region,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// GcpExternalStorageProviderResponse
final class GcpExternalStorageProviderResponse extends ExternalStorageProvider {
  /// Captures typed fields and immutable permitted overflow JSON.
  GcpExternalStorageProviderResponse({
    required this.bucket,
    required this.workloadIdentityProjectNumber,
    required this.workloadIdentityPoolId,
    required this.workloadIdentityProviderId,
    required this.region,
    required this.audience,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'bucket',
         'workload_identity_project_number',
         'workload_identity_pool_id',
         'workload_identity_provider_id',
         'region',
         'audience',
       }, 'GcpExternalStorageProviderResponse') {
    validate();
  }

  /// Exact `bucket` wire value.
  final String bucket;

  /// Exact `workload_identity_project_number` wire value.
  final String workloadIdentityProjectNumber;

  /// Exact `workload_identity_pool_id` wire value.
  final String workloadIdentityPoolId;

  /// Exact `workload_identity_provider_id` wire value.
  final String workloadIdentityProviderId;

  /// Exact `region` wire value.
  final String region;

  /// Exact `audience` wire value.
  final String audience;

  /// Fixed native discriminator.
  @override
  String get type => 'gcp';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory GcpExternalStorageProviderResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    adminTag(json, 'type', 'gcp', 'GcpExternalStorageProviderResponse');
    return GcpExternalStorageProviderResponse(
      bucket: adminRequired<String>(
        json,
        'bucket',
        'GcpExternalStorageProviderResponse.bucket',
        adminString,
        nullable: false,
      )!,
      workloadIdentityProjectNumber: adminRequired<String>(
        json,
        'workload_identity_project_number',
        'GcpExternalStorageProviderResponse.workloadIdentityProjectNumber',
        adminString,
        nullable: false,
      )!,
      workloadIdentityPoolId: adminRequired<String>(
        json,
        'workload_identity_pool_id',
        'GcpExternalStorageProviderResponse.workloadIdentityPoolId',
        adminString,
        nullable: false,
      )!,
      workloadIdentityProviderId: adminRequired<String>(
        json,
        'workload_identity_provider_id',
        'GcpExternalStorageProviderResponse.workloadIdentityProviderId',
        adminString,
        nullable: false,
      )!,
      region: adminRequired<String>(
        json,
        'region',
        'GcpExternalStorageProviderResponse.region',
        adminString,
        nullable: false,
      )!,
      audience: adminRequired<String>(
        json,
        'audience',
        'GcpExternalStorageProviderResponse.audience',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'bucket': bucket,
    'workload_identity_project_number': workloadIdentityProjectNumber,
    'workload_identity_pool_id': workloadIdentityPoolId,
    'workload_identity_provider_id': workloadIdentityProviderId,
    'region': region,
    'audience': audience,
  };

  /// Copies every field; clear flags omit optional nullable members.
  GcpExternalStorageProviderResponse copyWith({
    String? bucket,
    String? workloadIdentityProjectNumber,
    String? workloadIdentityPoolId,
    String? workloadIdentityProviderId,
    String? region,
    String? audience,
    Map<String, dynamic>? rawJson,
  }) => GcpExternalStorageProviderResponse(
    bucket: bucket ?? this.bucket,
    workloadIdentityProjectNumber:
        workloadIdentityProjectNumber ?? this.workloadIdentityProjectNumber,
    workloadIdentityPoolId:
        workloadIdentityPoolId ?? this.workloadIdentityPoolId,
    workloadIdentityProviderId:
        workloadIdentityProviderId ?? this.workloadIdentityProviderId,
    region: region ?? this.region,
    audience: audience ?? this.audience,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// OciExternalStorageProviderResponse
final class OciExternalStorageProviderResponse extends ExternalStorageProvider {
  /// Captures typed fields and immutable permitted overflow JSON.
  OciExternalStorageProviderResponse({
    required this.tenancyOcid,
    required this.region,
    required this.bucket,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'tenancy_ocid',
         'region',
         'bucket',
       }, 'OciExternalStorageProviderResponse') {
    validate();
  }

  /// Exact `tenancy_ocid` wire value.
  final String tenancyOcid;

  /// Exact `region` wire value.
  final String region;

  /// Exact `bucket` wire value.
  final String bucket;

  /// Fixed native discriminator.
  @override
  String get type => 'oci';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory OciExternalStorageProviderResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    adminTag(json, 'type', 'oci', 'OciExternalStorageProviderResponse');
    return OciExternalStorageProviderResponse(
      tenancyOcid: adminRequired<String>(
        json,
        'tenancy_ocid',
        'OciExternalStorageProviderResponse.tenancyOcid',
        adminString,
        nullable: false,
      )!,
      region: adminRequired<String>(
        json,
        'region',
        'OciExternalStorageProviderResponse.region',
        adminString,
        nullable: false,
      )!,
      bucket: adminRequired<String>(
        json,
        'bucket',
        'OciExternalStorageProviderResponse.bucket',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'type': type,
    'tenancy_ocid': tenancyOcid,
    'region': region,
    'bucket': bucket,
  };

  /// Copies every field; clear flags omit optional nullable members.
  OciExternalStorageProviderResponse copyWith({
    String? tenancyOcid,
    String? region,
    String? bucket,
    Map<String, dynamic>? rawJson,
  }) => OciExternalStorageProviderResponse(
    tenancyOcid: tenancyOcid ?? this.tenancyOcid,
    region: region ?? this.region,
    bucket: bucket ?? this.bucket,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// CreateExternalStorageRequest
final class CreateExternalStorageRequest extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  CreateExternalStorageRequest({
    required this.projectId,
    required this.provider,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'project_id',
         'provider',
       }, 'CreateExternalStorageRequest') {
    validate();
  }

  /// Exact `project_id` wire value.
  final String projectId;

  /// Exact `provider` wire value.
  final ExternalStorageProviderParams provider;

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory CreateExternalStorageRequest.fromJson(Map<String, dynamic> json) {
    return CreateExternalStorageRequest(
      projectId: adminRequired<String>(
        json,
        'project_id',
        'CreateExternalStorageRequest.projectId',
        adminString,
        nullable: false,
      )!,
      provider: adminRequired<ExternalStorageProviderParams>(
        json,
        'provider',
        'CreateExternalStorageRequest.provider',
        (value, context) =>
            ExternalStorageProviderParams.fromJson(adminObject(value, context)),
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    provider.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'project_id': projectId,
    'provider': provider.toJson(),
  };

  /// Copies every field; clear flags omit optional nullable members.
  CreateExternalStorageRequest copyWith({
    String? projectId,
    ExternalStorageProviderParams? provider,
    Map<String, dynamic>? rawJson,
  }) => CreateExternalStorageRequest(
    projectId: projectId ?? this.projectId,
    provider: provider ?? this.provider,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// ExternalStorage
final class ExternalStorage extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ExternalStorage({
    required this.id,
    required this.projectId,
    required this.provider,
    required this.geography,
    required this.status,
    required this.createdAt,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'object',
         'id',
         'project_id',
         'provider',
         'geography',
         'status',
         'created_at',
       }, 'ExternalStorage') {
    validate();
  }

  /// Exact `id` wire value.
  final String id;

  /// Exact `project_id` wire value.
  final String projectId;

  /// Exact `provider` wire value.
  final ExternalStorageProvider provider;

  /// Exact `geography` wire value.
  final String geography;

  /// Exact `status` wire value.
  final ExternalStorageStatus status;

  /// Exact `created_at` wire value.
  final int createdAt;

  /// Fixed native discriminator.
  String get object => 'organization.external_storage';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ExternalStorage.fromJson(Map<String, dynamic> json) {
    adminTag(
      json,
      'object',
      'organization.external_storage',
      'ExternalStorage',
    );
    return ExternalStorage(
      id: adminRequired<String>(
        json,
        'id',
        'ExternalStorage.id',
        adminString,
        nullable: false,
      )!,
      projectId: adminRequired<String>(
        json,
        'project_id',
        'ExternalStorage.projectId',
        adminString,
        nullable: false,
      )!,
      provider: adminRequired<ExternalStorageProvider>(
        json,
        'provider',
        'ExternalStorage.provider',
        (value, context) =>
            ExternalStorageProvider.fromJson(adminObject(value, context)),
        nullable: false,
      )!,
      geography: adminRequired<String>(
        json,
        'geography',
        'ExternalStorage.geography',
        adminString,
        nullable: false,
      )!,
      status: adminRequired<ExternalStorageStatus>(
        json,
        'status',
        'ExternalStorage.status',
        (value, context) => ExternalStorageStatus.fromJson(value),
        nullable: false,
      )!,
      createdAt: adminRequired<int>(
        json,
        'created_at',
        'ExternalStorage.createdAt',
        adminInt,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    provider.validate();
    status.validate();
    adminInt(createdAt, 'ExternalStorage.createdAt');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'id': id,
    'project_id': projectId,
    'provider': provider.toJson(),
    'geography': geography,
    'status': status.toJson(),
    'created_at': createdAt,
  };

  /// Copies every field; clear flags omit optional nullable members.
  ExternalStorage copyWith({
    String? id,
    String? projectId,
    ExternalStorageProvider? provider,
    String? geography,
    ExternalStorageStatus? status,
    int? createdAt,
    Map<String, dynamic>? rawJson,
  }) => ExternalStorage(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    provider: provider ?? this.provider,
    geography: geography ?? this.geography,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// ExternalStorageList
final class ExternalStorageList extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ExternalStorageList({
    required List<ExternalStorage> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List<ExternalStorage>.unmodifiable(data),
       rawJson = adminExtras(rawJson, {
         'object',
         'data',
         'first_id',
         'last_id',
         'has_more',
       }, 'ExternalStorageList') {
    validate();
  }

  /// Exact `data` wire value.
  final List<ExternalStorage> data;

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
  factory ExternalStorageList.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'object', 'list', 'ExternalStorageList');
    return ExternalStorageList(
      data: adminRequired<List<ExternalStorage>>(
        json,
        'data',
        'ExternalStorageList.data',
        (value, context) => [
          for (final item in adminList(value, context))
            ExternalStorage.fromJson(adminObject(item, context)),
        ],
        nullable: false,
      )!,
      firstId: adminRequired<String>(
        json,
        'first_id',
        'ExternalStorageList.firstId',
        adminString,
        nullable: true,
      ),
      lastId: adminRequired<String>(
        json,
        'last_id',
        'ExternalStorageList.lastId',
        adminString,
        nullable: true,
      ),
      hasMore: adminRequired<bool>(
        json,
        'has_more',
        'ExternalStorageList.hasMore',
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
  ExternalStorageList copyWith({
    List<ExternalStorage>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => ExternalStorageList(
    data: data ?? this.data,
    firstId: adminCopy<String>(
      firstId,
      this.firstId,
      'ExternalStorageList.firstId',
    ),
    lastId: adminCopy<String>(
      lastId,
      this.lastId,
      'ExternalStorageList.lastId',
    ),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// DeletedExternalStorage
final class DeletedExternalStorage extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  DeletedExternalStorage({
    required this.id,
    required this.deleted,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'object',
         'id',
         'deleted',
       }, 'DeletedExternalStorage') {
    validate();
  }

  /// Exact `id` wire value.
  final String id;

  /// Exact `deleted` wire value.
  final bool deleted;

  /// Fixed native discriminator.
  String get object => 'organization.external_storage.deleted';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory DeletedExternalStorage.fromJson(Map<String, dynamic> json) {
    adminTag(
      json,
      'object',
      'organization.external_storage.deleted',
      'DeletedExternalStorage',
    );
    return DeletedExternalStorage(
      id: adminRequired<String>(
        json,
        'id',
        'DeletedExternalStorage.id',
        adminString,
        nullable: false,
      )!,
      deleted: adminRequired<bool>(
        json,
        'deleted',
        'DeletedExternalStorage.deleted',
        adminBool,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'id': id,
    'deleted': deleted,
  };

  /// Copies every field; clear flags omit optional nullable members.
  DeletedExternalStorage copyWith({
    String? id,
    bool? deleted,
    Map<String, dynamic>? rawJson,
  }) => DeletedExternalStorage(
    id: id ?? this.id,
    deleted: deleted ?? this.deleted,
    rawJson: rawJson ?? this.rawJson,
  );
}
