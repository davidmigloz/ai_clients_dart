import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Data residency locations accepted for external key writes.
enum ExternalKeyGeo {
  /// United States.
  us,
}

/// Coordinates of a key in a supported external key management service.
///
/// Supports [AwsExternalKeyConfig], [GcpExternalKeyConfig],
/// [AzureExternalKeyConfig], and [UnknownExternalKeyProviderConfig].
@immutable
sealed class ExternalKeyProviderConfig {
  const ExternalKeyProviderConfig._();

  /// Configures an AWS KMS key.
  const factory ExternalKeyProviderConfig.aws({
    required String kmsArn,
    String? region,
    String? roleArn,
  }) = AwsExternalKeyConfig;

  /// Configures a Google Cloud KMS key.
  const factory ExternalKeyProviderConfig.gcp({required String keyName}) =
      GcpExternalKeyConfig;

  /// Configures an Azure Key Vault or Managed HSM key.
  const factory ExternalKeyProviderConfig.azure({
    required String vaultUri,
    required String tenantId,
    required String keyName,
    String? clientId,
  }) = AzureExternalKeyConfig;

  /// Decodes a known or future provider.
  factory ExternalKeyProviderConfig.fromJson(Map<String, dynamic> json) =>
      switch (_required<String>(json, 'type')) {
        'aws' => AwsExternalKeyConfig.fromJson(json),
        'gcp' => GcpExternalKeyConfig.fromJson(json),
        'azure' => AzureExternalKeyConfig.fromJson(json),
        _ => UnknownExternalKeyProviderConfig(json),
      };

  /// The provider discriminator.
  String get type;

  /// Encodes the provider's coordinates.
  Map<String, dynamic> toJson();

  /// Encodes coordinates accepted on create and update.
  Map<String, dynamic> toRequestJson() => toJson();

  @override
  bool operator ==(Object other) =>
      other is ExternalKeyProviderConfig &&
      other.runtimeType == runtimeType &&
      mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() => 'ExternalKeyProviderConfig(type: $type)';
}

/// AWS KMS key coordinates.
final class AwsExternalKeyConfig extends ExternalKeyProviderConfig {
  /// Creates AWS coordinates.
  const AwsExternalKeyConfig({required this.kmsArn, this.region, this.roleArn})
    : super._();

  /// The full KMS key ARN.
  final String kmsArn;

  /// The AWS region, when set separately.
  final String? region;

  /// Historical role ARN. The server ignores it on writes.
  final String? roleArn;

  @override
  String get type => 'aws';

  /// Decodes AWS coordinates.
  factory AwsExternalKeyConfig.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'aws');
    return AwsExternalKeyConfig(
      kmsArn: _required<String>(json, 'kms_arn'),
      region: _optional<String>(json, 'region'),
      roleArn: _optional<String>(json, 'role_arn'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'kms_arn': kmsArn,
    'region': ?region,
    'role_arn': ?roleArn,
  };

  @override
  Map<String, dynamic> toRequestJson() => {
    'type': type,
    'kms_arn': kmsArn,
    'region': ?region,
  };

  /// Copies the coordinates and allows nullable values to be cleared.
  AwsExternalKeyConfig copyWith({
    String? kmsArn,
    Object? region = unsetCopyWithValue,
    Object? roleArn = unsetCopyWithValue,
  }) => AwsExternalKeyConfig(
    kmsArn: kmsArn ?? this.kmsArn,
    region: identical(region, unsetCopyWithValue)
        ? this.region
        : region as String?,
    roleArn: identical(roleArn, unsetCopyWithValue)
        ? this.roleArn
        : roleArn as String?,
  );
}

/// Google Cloud KMS key coordinates.
final class GcpExternalKeyConfig extends ExternalKeyProviderConfig {
  /// Creates Google Cloud coordinates.
  const GcpExternalKeyConfig({required this.keyName}) : super._();

  /// The full Cloud KMS key resource name.
  final String keyName;

  @override
  String get type => 'gcp';

  /// Decodes Google Cloud coordinates.
  factory GcpExternalKeyConfig.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'gcp');
    return GcpExternalKeyConfig(keyName: _required<String>(json, 'key_name'));
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'key_name': keyName};

  /// Copies the coordinates with a replacement key name.
  GcpExternalKeyConfig copyWith({String? keyName}) =>
      GcpExternalKeyConfig(keyName: keyName ?? this.keyName);
}

/// Azure Key Vault or Managed HSM key coordinates.
final class AzureExternalKeyConfig extends ExternalKeyProviderConfig {
  /// Creates Azure coordinates.
  const AzureExternalKeyConfig({
    required this.vaultUri,
    required this.tenantId,
    required this.keyName,
    this.clientId,
  }) : super._();

  /// URI of the vault's data plane.
  final String vaultUri;

  /// The Azure AD tenant ID.
  final String tenantId;

  /// The name of the key within the vault.
  final String keyName;

  /// Optional Azure AD application client ID.
  final String? clientId;

  @override
  String get type => 'azure';

  /// Decodes Azure coordinates.
  factory AzureExternalKeyConfig.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'azure');
    return AzureExternalKeyConfig(
      vaultUri: _required<String>(json, 'vault_uri'),
      tenantId: _required<String>(json, 'tenant_id'),
      keyName: _required<String>(json, 'key_name'),
      clientId: _optional<String>(json, 'client_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'vault_uri': vaultUri,
    'tenant_id': tenantId,
    'key_name': keyName,
    'client_id': ?clientId,
  };

  /// Copies the coordinates, clearing the optional client ID with null.
  AzureExternalKeyConfig copyWith({
    String? vaultUri,
    String? tenantId,
    String? keyName,
    Object? clientId = unsetCopyWithValue,
  }) => AzureExternalKeyConfig(
    vaultUri: vaultUri ?? this.vaultUri,
    tenantId: tenantId ?? this.tenantId,
    keyName: keyName ?? this.keyName,
    clientId: identical(clientId, unsetCopyWithValue)
        ? this.clientId
        : clientId as String?,
  );
}

/// An unrecognized key provider, preserved without losing new fields.
final class UnknownExternalKeyProviderConfig extends ExternalKeyProviderConfig {
  /// Creates a fallback from the raw provider object.
  UnknownExternalKeyProviderConfig(Map<String, dynamic> json)
    : raw = deepUnmodifiableMap(json),
      super._();

  /// The original provider payload.
  final Map<String, dynamic> raw;

  @override
  String get type => _required<String>(raw, 'type');

  @override
  Map<String, dynamic> toJson() => raw;
}

/// Whether a registered key is attached to any workspace.
///
/// Supports [ExternalKeyAttached], [ExternalKeyUnattached], and
/// [UnknownExternalKeyAttachment].
@immutable
sealed class ExternalKeyAttachment {
  const ExternalKeyAttachment._();

  /// The key is in use.
  const factory ExternalKeyAttachment.attached() = ExternalKeyAttached;

  /// The key is not attached to a workspace.
  const factory ExternalKeyAttachment.unattached() = ExternalKeyUnattached;

  /// Decodes the attachment discriminator.
  factory ExternalKeyAttachment.fromJson(Map<String, dynamic> json) =>
      switch (_required<String>(json, 'type')) {
        'attached' => const ExternalKeyAttached(),
        'unattached' => const ExternalKeyUnattached(),
        _ => UnknownExternalKeyAttachment(json),
      };

  /// The attachment discriminator.
  String get type;

  /// Encodes attachment status.
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      other is ExternalKeyAttachment &&
      other.runtimeType == runtimeType &&
      mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() => 'ExternalKeyAttachment(type: $type)';
}

/// The external key is attached to a workspace.
final class ExternalKeyAttached extends ExternalKeyAttachment {
  /// Creates the attached status.
  const ExternalKeyAttached() : super._();

  @override
  String get type => 'attached';

  @override
  Map<String, dynamic> toJson() => {'type': type};
}

/// The external key is not attached to a workspace.
final class ExternalKeyUnattached extends ExternalKeyAttachment {
  /// Creates the unattached status.
  const ExternalKeyUnattached() : super._();

  @override
  String get type => 'unattached';

  @override
  Map<String, dynamic> toJson() => {'type': type};
}

/// A future attachment status.
final class UnknownExternalKeyAttachment extends ExternalKeyAttachment {
  /// Creates an unknown status from its raw JSON.
  UnknownExternalKeyAttachment(Map<String, dynamic> json)
    : raw = deepUnmodifiableMap(json),
      super._();

  /// The original attachment payload.
  final Map<String, dynamic> raw;

  @override
  String get type => _required<String>(raw, 'type');

  @override
  Map<String, dynamic> toJson() => raw;
}

/// An organization’s external encryption key configuration.
@immutable
final class ExternalKey {
  /// Creates this Admin API record.
  const ExternalKey({
    required this.id,
    required this.displayName,
    required this.geo,
    required this.providerConfig,
    required this.attachment,
    required this.userProfileId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The registered key ID, which can be an ARN on Claude Platform on AWS.
  final String id;

  /// The display name, when set.
  final String? displayName;

  /// The storage geography reported by the service.
  final String geo;

  /// The key management service coordinates.
  final ExternalKeyProviderConfig providerConfig;

  /// Whether the key is attached to a workspace.
  final ExternalKeyAttachment attachment;

  /// The user profile this key is scoped to, if any.
  final String? userProfileId;

  /// When the key configuration was registered.
  final DateTime createdAt;

  /// When the key configuration was last changed.
  final DateTime updatedAt;

  /// The wire discriminator.
  String get type => 'external_key';

  /// Decodes this Admin API record.
  factory ExternalKey.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'external_key');
    return ExternalKey(
      id: _required<String>(json, 'id'),
      displayName: _required<String?>(json, 'display_name'),
      geo: _required<String>(json, 'geo'),
      providerConfig: ExternalKeyProviderConfig.fromJson(
        _required<Map<String, dynamic>>(json, 'provider_config'),
      ),
      attachment: ExternalKeyAttachment.fromJson(
        _required<Map<String, dynamic>>(json, 'attachment'),
      ),
      userProfileId: _required<String?>(json, 'user_profile_id'),
      createdAt: DateTime.parse(_required<String>(json, 'created_at')),
      updatedAt: DateTime.parse(_required<String>(json, 'updated_at')),
    );
  }

  /// Encodes this record using its wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'display_name': displayName,
    'geo': geo,
    'provider_config': providerConfig.toJson(),
    'attachment': attachment.toJson(),
    'user_profile_id': userProfileId,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  /// Copies this record with selected fields replaced.
  ExternalKey copyWith({
    String? id,
    Object? displayName = unsetCopyWithValue,
    String? geo,
    ExternalKeyProviderConfig? providerConfig,
    ExternalKeyAttachment? attachment,
    Object? userProfileId = unsetCopyWithValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExternalKey(
    id: id ?? this.id,
    displayName: identical(displayName, unsetCopyWithValue)
        ? this.displayName
        : displayName as String?,
    geo: geo ?? this.geo,
    providerConfig: providerConfig ?? this.providerConfig,
    attachment: attachment ?? this.attachment,
    userProfileId: identical(userProfileId, unsetCopyWithValue)
        ? this.userProfileId
        : userProfileId as String?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is ExternalKey &&
      id == other.id &&
      displayName == other.displayName &&
      geo == other.geo &&
      providerConfig == other.providerConfig &&
      attachment == other.attachment &&
      userProfileId == other.userProfileId &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    geo,
    providerConfig,
    attachment,
    userProfileId,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'ExternalKey(id: ${id.length} chars, displayName: ${_redactedLength(displayName)}, geo: $geo, '
      'providerConfig: $providerConfig, attachment: $attachment, userProfileId: ${_redactedLength(userProfileId)}, '
      'createdAt: $createdAt, updatedAt: $updatedAt)';
}

/// Result of testing the key with an encryption and decryption round trip.
@immutable
final class ExternalKeyValidation {
  /// Creates this Admin API record.
  const ExternalKeyValidation({required this.status, required this.error});

  /// The validation status as sent by the API.
  final String status;

  /// The provider’s diagnostic message when validation fails.
  final String? error;

  /// The wire discriminator.
  String get type => 'external_key_validation';

  /// Whether the provider reported a successful validation.
  bool get succeeded => status == 'success';

  /// Decodes this Admin API record.
  factory ExternalKeyValidation.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'external_key_validation');
    return ExternalKeyValidation(
      status: _required<String>(json, 'status'),
      error: _required<String?>(json, 'error'),
    );
  }

  /// Encodes this record using its wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'status': status,
    'error': error,
  };

  /// Copies this record with selected fields replaced.
  ExternalKeyValidation copyWith({
    String? status,
    Object? error = unsetCopyWithValue,
  }) => ExternalKeyValidation(
    status: status ?? this.status,
    error: identical(error, unsetCopyWithValue) ? this.error : error as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is ExternalKeyValidation &&
      status == other.status &&
      error == other.error;

  @override
  int get hashCode => Object.hash(status, error);

  @override
  String toString() =>
      'ExternalKeyValidation(status: $status, error: ${_redactedLength(error)})';
}

/// Confirmation that the external key configuration was deleted.
@immutable
final class DeletedExternalKey {
  /// Creates this Admin API record.
  const DeletedExternalKey({required this.id});

  /// The registered key ID.
  final String id;

  /// The wire discriminator.
  String get type => 'external_key_deleted';

  /// Decodes this Admin API record.
  factory DeletedExternalKey.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'external_key_deleted');
    return DeletedExternalKey(id: _required<String>(json, 'id'));
  }

  /// Encodes this record using its wire keys.
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Copies this record with selected fields replaced.
  DeletedExternalKey copyWith({String? id}) =>
      DeletedExternalKey(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      other is DeletedExternalKey && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeletedExternalKey(id: ${id.length} chars)';
}

T _required<T>(Map<String, dynamic> json, String key) =>
    requiredOrganizationField<T>(json, key, 'External key');

T? _optional<T>(Map<String, dynamic> json, String key) =>
    json.containsKey(key) ? _required<T?>(json, key) : null;

String? _redactedLength(String? value) =>
    value == null ? null : '${value.length} chars';
