import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../errors/response_error.dart';
import '../../models/organization/organization_page.dart';
import '../../models/organization/organization_plugin.dart';
import '../media_type.dart';
import 'organization_transport.dart';

const _plugins = '/plugins';
const _marketplaces = '/plugin_marketplaces';
const _pluginsBeta = 'ce-plugins-2026-09-01';

/// Inventories and manages Claude Enterprise plugins (beta).
///
/// Use a Claude Enterprise organization without HIPAA readiness. Read access
/// requires `read:plugins`, `read:org_audit`, or `read:compliance_org_data`.
/// Writes require `write:plugins` and cannot select a child organization.
final class OrganizationPluginsResource {
  /// Creates the plugin resource on the organization transport.
  OrganizationPluginsResource(OrganizationTransport transport)
    : _transport = transport,
      versions = OrganizationPluginVersionsResource(transport),
      installationSettings = OrganizationPluginInstallationSettingsResource(
        transport,
      );

  final OrganizationTransport _transport;

  /// Version uploads, inspection and archive downloads.
  final OrganizationPluginVersionsResource versions;

  /// Organization-owned plugin settings for the organization and RBAC groups.
  final OrganizationPluginInstallationSettingsResource installationSettings;

  /// Lists plugins in the organization or in a permitted linked organization.
  Future<OrganizationCursorPage<OrganizationPlugin>> list({
    String? ownerType,
    String? ownerUserId,
    String? marketplaceId,
    DateTime? createdAtGte,
    DateTime? createdAtGt,
    DateTime? createdAtLte,
    DateTime? createdAtLt,
    String? organizationId,
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _pluginList(
    _transport,
    _plugins,
    OrganizationPlugin.fromJson,
    query: {
      'owner_type': ?ownerType,
      'owner_user_id': ?ownerUserId,
      'marketplace_id': ?marketplaceId,
      'created_at[gte]': ?createdAtGte?.toUtc().toIso8601String(),
      'created_at[gt]': ?createdAtGt?.toUtc().toIso8601String(),
      'created_at[lte]': ?createdAtLte?.toUtc().toIso8601String(),
      'created_at[lt]': ?createdAtLt?.toUtc().toIso8601String(),
    },
    organizationId: organizationId,
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Publishes a plugin and its first version in an organization marketplace.
  ///
  /// Supply files with relative paths including `.claude-plugin/plugin.json`,
  /// or one archive containing the complete plugin. An explicit marketplace
  /// must be organization-owned and use manual uploads.
  Future<OrganizationPlugin> create({
    required List<PluginUploadFile> files,
    String? marketplaceId,
    String? releaseNotes,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.sendMultipart(
    _plugins,
    OrganizationPlugin.fromJson,
    files: _pluginFiles(files),
    fields: {'marketplace_id': ?marketplaceId, 'release_notes': ?releaseNotes},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Reads a plugin's metadata and current served version.
  Future<OrganizationPlugin> retrieve(
    String pluginId, {
    String? organizationId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _plugin(pluginId),
    OrganizationPlugin.fromJson,
    query: {'organization_id': ?organizationId},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Pins the plugin's served version to an existing `pluginver_...` ID.
  Future<OrganizationPlugin> update(
    String pluginId, {
    required String servedVersionId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _plugin(pluginId),
    OrganizationPlugin.fromJson,
    body: {
      'served_version_id': _explicitVersion(servedVersionId, 'servedVersionId'),
    },
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Permanently deletes the plugin and all of its stored versions.
  Future<DeletedOrganizationPlugin> delete(
    String pluginId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _plugin(pluginId),
    DeletedOrganizationPlugin.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Lists the member-owned plugin's shares, newest first.
  Future<OrganizationCursorPage<OrganizationPluginShare>> listShares(
    String pluginId, {
    String? targetType,
    String? organizationId,
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _pluginList(
    _transport,
    '${_plugin(pluginId)}/shares',
    OrganizationPluginShare.fromJson,
    query: {'target_type': ?targetType},
    organizationId: organizationId,
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );
}

/// Manages versions and downloads exact archives for a Claude Enterprise plugin.
final class OrganizationPluginVersionsResource {
  /// Creates the version resource.
  const OrganizationPluginVersionsResource(this._transport);

  final OrganizationTransport _transport;

  /// Uploads a new version of an organization-owned plugin.
  Future<OrganizationPluginVersion> create(
    String pluginId, {
    required List<PluginUploadFile> files,
    String? releaseNotes,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.sendMultipart(
    '${_plugin(pluginId)}/versions',
    OrganizationPluginVersion.fromJson,
    files: _pluginFiles(files),
    fields: {'release_notes': ?releaseNotes},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Lists stored versions, newest first.
  Future<OrganizationCursorPage<OrganizationPluginVersion>> list(
    String pluginId, {
    String? organizationId,
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _pluginList(
    _transport,
    '${_plugin(pluginId)}/versions',
    OrganizationPluginVersion.fromJson,
    organizationId: organizationId,
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Reads a stored version by ID, or the newest using `latest`.
  Future<OrganizationPluginVersion> retrieve(
    String pluginId,
    String version, {
    String? organizationId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _version(pluginId, version),
    OrganizationPluginVersion.fromJson,
    query: {'organization_id': ?organizationId},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Downloads the ZIP archive of a specific version as bytes.
  ///
  /// Downloads of member-owned plugin files are recorded in the Compliance
  /// Activity Feed. Use a version ID here, because `latest` only works when
  /// retrieving version metadata.
  Future<Uint8List> download(
    String pluginId,
    String versionId, {
    String? organizationId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.sendBytes(
    '${_version(pluginId, _explicitVersion(versionId, 'versionId'))}/content',
    query: {'organization_id': ?organizationId},
    accept: 'application/binary',
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  static String _version(String pluginId, String version) =>
      '${_plugin(pluginId)}/versions/${organizationIdSegment(version, 'version')}';
}

/// Installation preferences for organization-owned plugins.
final class OrganizationPluginInstallationSettingsResource {
  /// Creates the installation settings resource.
  const OrganizationPluginInstallationSettingsResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists settings on the plugin. Filter by `organization` or `rbac_group`.
  Future<OrganizationCursorPage<OrganizationPluginInstallationSetting>> list(
    String pluginId, {
    String? targetType,
    String? organizationId,
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _pluginList(
    _transport,
    '${_plugin(pluginId)}/installation_settings',
    OrganizationPluginInstallationSetting.fromJson,
    query: {'target_type': ?targetType},
    organizationId: organizationId,
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Sets the installation preference for the whole organization or one group.
  Future<OrganizationPluginInstallationSetting> set(
    String pluginId,
    PluginInstallationTarget target, {
    required PluginInstallationPreference preference,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _setting(pluginId, target),
    OrganizationPluginInstallationSetting.fromJson,
    body: {'installation_preference': preference.value},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Removes an override and lets the applicable default take effect.
  Future<DeletedOrganizationPluginInstallationSetting> remove(
    String pluginId,
    PluginInstallationTarget target, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _setting(pluginId, target),
    DeletedOrganizationPluginInstallationSetting.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  static String _setting(String pluginId, PluginInstallationTarget target) {
    final id = target.id;
    if (!target.isOrganization &&
        _rbacGroupId.firstMatch(id)?.end != id.length) {
      throw ArgumentError(
        'Expected an RBAC group ID beginning with rbac_group_',
        'target',
      );
    }
    return '${_plugin(pluginId)}/installation_settings/${organizationIdSegment(id, 'target')}';
  }

  static final _rbacGroupId = RegExp(r'^rbac_group_[a-zA-Z0-9_-]+');
}

/// Reads, validates and configures Claude Enterprise plugin marketplaces (beta).
final class OrganizationPluginMarketplacesResource {
  /// Creates the marketplace resource on the organization transport.
  const OrganizationPluginMarketplacesResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists marketplaces by owner type and source.
  Future<OrganizationCursorPage<OrganizationPluginMarketplace>> list({
    String? ownerType,
    String? source,
    String? organizationId,
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _pluginList(
    _transport,
    _marketplaces,
    OrganizationPluginMarketplace.fromJson,
    query: {'owner_type': ?ownerType, 'source': ?source},
    organizationId: organizationId,
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Reads a marketplace, optionally from a permitted linked organization.
  Future<OrganizationPluginMarketplace> retrieve(
    String marketplaceId, {
    String? organizationId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _marketplace(marketplaceId),
    OrganizationPluginMarketplace.fromJson,
    query: {'organization_id': ?organizationId},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Sets the default installation preference for an organization's marketplace.
  Future<OrganizationPluginMarketplace> update(
    String marketplaceId, {
    required PluginInstallationPreference defaultPreference,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _marketplace(marketplaceId),
    OrganizationPluginMarketplace.fromJson,
    body: {'default_installation_preference': defaultPreference.value},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Checks a public GitHub marketplace at an optional branch or commit.
  ///
  /// Marketplace validation accepts `read:plugins` or `write:plugins`.
  Future<PluginMarketplaceValidationReport> validateRepository({
    required String repositoryUrl,
    String? ref,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '$_marketplaces/validate_repository',
    PluginMarketplaceValidationReport.fromJson,
    sanitizeResponseDiagnostics: _redactValidationDiagnostics,
    body: {'repository_url': repositoryUrl, 'ref': ?ref},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  /// Checks a ZIP archive without connecting or storing the marketplace.
  Future<PluginMarketplaceValidationReport> validateArchive(
    PluginUploadFile archive, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.sendMultipart(
    '$_marketplaces/validate_archive',
    PluginMarketplaceValidationReport.fromJson,
    sanitizeResponseDiagnostics: _redactValidationDiagnostics,
    files: [_file('archive', archive)],
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _pluginsBeta,
    abortTrigger: abortTrigger,
  );

  static String _marketplace(String id) =>
      '$_marketplaces/${organizationIdSegment(id, 'marketplaceId')}';
}

void _redactValidationDiagnostics(
  Map<String, dynamic> json,
  Set<String> credentials,
) {
  if (credentials.isEmpty) return;
  _redactFields(json, ['manifest_error', 'manifest_error_code'], credentials);
  for (final error in _diagnosticRecords(json['plugin_errors'])) {
    _redactFields(error, ['name', 'error', 'error_code'], credentials);
  }
  for (final group in _diagnosticRecords(json['plugin_warnings'])) {
    _redactFields(group, ['name'], credentials);
    for (final warning in _diagnosticRecords(group['warnings'])) {
      _redactFields(warning, ['message', 'error_code'], credentials);
    }
  }
}

Iterable<Map<String, dynamic>> _diagnosticRecords(Object? value) =>
    value is List<Object?> ? value.whereType<Map<String, dynamic>>() : const [];

void _redactFields(
  Map<String, dynamic> json,
  List<String> fields,
  Set<String> credentials,
) {
  for (final field in fields) {
    if (json[field] case final String value) {
      json[field] = redactDiagnosticText(value, credentials);
    }
  }
}

String _plugin(String id) =>
    '$_plugins/${organizationIdSegment(id, 'pluginId')}';

String _explicitVersion(String value, String parameter) {
  if (value == 'latest') {
    throw ArgumentError.value(
      value,
      parameter,
      'Use an explicit plugin version ID',
    );
  }
  return value;
}

Future<OrganizationCursorPage<T>> _pluginList<T>(
  OrganizationTransport transport,
  String path,
  T Function(Map<String, dynamic>) decode, {
  Map<String, dynamic> query = const {},
  String? organizationId,
  int? limit,
  String? page,
  required List<String> betas,
  Future<void>? abortTrigger,
}) => transport.send(
  'GET',
  path,
  (json) => OrganizationCursorPage.fromJson(json, decode),
  query: {
    ...organizationCursorQuery(page, limit),
    ...query,
    'organization_id': ?organizationId,
  },
  beta: betas.isEmpty ? null : betas.join(','),
  requiredBeta: _pluginsBeta,
  abortTrigger: abortTrigger,
);

List<http.MultipartFile> _pluginFiles(List<PluginUploadFile> files) {
  if (files.isEmpty) throw ArgumentError('Provide at least one plugin file');
  return [for (final file in files) _file('files[]', file)];
}

http.MultipartFile _file(String field, PluginUploadFile file) {
  if (file.path.isEmpty) {
    throw ArgumentError('A plugin upload needs a filename');
  }
  return http.MultipartFile.fromBytes(
    field,
    file.bytes,
    filename: file.path,
    contentType: file.mimeType == null
        ? null
        : parseMediaTypeOrOctetStream(file.mimeType!),
  );
}
