import '../../models/common/copy_with_sentinel.dart';
import '../../models/organization/external_key.dart';
import '../../models/organization/organization_page.dart';
import 'organization_transport.dart';

/// Registers and manages customer-managed encryption keys.
///
/// Enable CMEK in your organization. Claude Platform on AWS accepts KMS ARNs
/// as identifiers and validates keys when attaching them to workspaces.
final class OrganizationExternalKeysResource {
  /// Creates the external keys resource.
  const OrganizationExternalKeysResource(this._transport);
  final OrganizationTransport _transport;

  static const _path = '/external_keys';

  /// Lists registered external keys.
  Future<OrganizationCursorPage<ExternalKey>> list({
    String? page,
    int? limit,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _path,
    (json) => OrganizationCursorPage.fromJson(json, ExternalKey.fromJson),
    query: {'page': ?page, 'limit': ?limit?.toString()},
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Registers an external key without attaching it to a workspace.
  ///
  /// For a customer's key, supply that customer's [userProfileId] so it can
  /// only attach to workspaces for the same profile. The binding is immutable.
  Future<ExternalKey> create({
    required ExternalKeyProviderConfig providerConfig,
    String? displayName,
    ExternalKeyGeo? geo,
    String? userProfileId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _path,
    ExternalKey.fromJson,
    body: {
      'provider_config': providerConfig.toRequestJson(),
      'display_name': ?displayName,
      'geo': ?geo?.name,
      'user_profile_id': ?userProfileId,
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Retrieves a registered external key.
  Future<ExternalKey> retrieve(
    String externalKeyId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _keyPath(externalKeyId),
    ExternalKey.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Updates supplied fields. Null values are sent when explicitly supplied.
  ///
  /// Pass a [String] for [displayName], [ExternalKeyGeo] for [geo], or an
  /// [ExternalKeyProviderConfig] for [providerConfig]. The service enforces
  /// restrictions on keys that are already attached or in workspace policy.
  Future<ExternalKey> update(
    String externalKeyId, {
    Object? displayName = unsetCopyWithValue,
    Object? geo = unsetCopyWithValue,
    Object? providerConfig = unsetCopyWithValue,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _keyPath(externalKeyId),
    ExternalKey.fromJson,
    body: {
      if (!identical(displayName, unsetCopyWithValue))
        'display_name': displayName as String?,
      if (!identical(geo, unsetCopyWithValue))
        'geo': (geo as ExternalKeyGeo?)?.name,
      if (!identical(providerConfig, unsetCopyWithValue))
        'provider_config': (providerConfig as ExternalKeyProviderConfig?)
            ?.toRequestJson(),
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Deletes a registered external key that is eligible for removal.
  Future<DeletedExternalKey> delete(
    String externalKeyId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _keyPath(externalKeyId),
    DeletedExternalKey.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Runs the encrypt/decrypt round trip on supported Claude Platform accounts.
  ///
  /// Claude Platform on AWS validates at attachment and omits this endpoint.
  Future<ExternalKeyValidation> validate(
    String externalKeyId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_keyPath(externalKeyId)}/validate',
    ExternalKeyValidation.fromJson,
    diagnosticField: 'error',
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  static String _keyPath(String id) =>
      '$_path/${organizationIdSegment(id, 'externalKeyId')}';

  static String? _beta(List<String> values) =>
      values.isEmpty ? null : values.join(',');
}
