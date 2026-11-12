import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// A plugin file or a single plugin/marketplace archive to upload.
@immutable
final class PluginUploadFile {
  /// Creates an upload part. [path] is the plugin-relative file path or the
  /// archive filename. Keep the `.claude-plugin/plugin.json` path for manifests.
  PluginUploadFile({
    required this.path,
    required List<int> bytes,
    this.mimeType,
  }) : bytes = Uint8List.fromList(bytes).asUnmodifiableView();

  /// Filename sent to the server, including its plugin-relative path.
  final String path;

  /// Unmodified binary contents.
  final Uint8List bytes;

  /// Optional content type for this part.
  final String? mimeType;
}

/// Installation preference for an organization or an RBAC group.
enum PluginInstallationPreference {
  /// Install this plugin unless the user chooses to remove it.
  autoInstall('auto_install'),

  /// Allow users to install this plugin.
  available('available'),

  /// Make the plugin unavailable to this target.
  notAvailable('not_available'),

  /// Require the plugin to be installed.
  required('required');

  const PluginInstallationPreference(this.value);

  /// Provider value used on the wire.
  final String value;
}

/// A writable target for an organization plugin installation setting.
@immutable
final class PluginInstallationTarget {
  /// Applies a setting to the entire organization.
  const PluginInstallationTarget.organization()
    : id = 'organization',
      isOrganization = true;

  /// Applies a setting to the named `rbac_group_...` group.
  ///
  /// The resource validates the group ID before sending a request.
  const PluginInstallationTarget.rbacGroup(this.id) : isOrganization = false;

  /// Target identifier as used by the API path.
  final String id;

  /// Whether this target applies to the whole organization.
  final bool isOrganization;
}

@immutable
abstract base class _PluginRecord {
  _PluginRecord(Map<String, dynamic> json) : _json = deepUnmodifiableMap(json);

  final Map<String, dynamic> _json;

  T _field<T>(String key) =>
      requiredOrganizationField<T>(_json, key, runtimeType.toString());

  DateTime? _optionalDate(String key) => switch (_field<String?>(key)) {
    final value? => DateTime.parse(value),
    null => null,
  };

  T? _object<T>(String key, T Function(Map<String, dynamic>) decode) =>
      switch (_field<Map<String, dynamic>?>(key)) {
        final value? => decode(value),
        null => null,
      };

  List<T> _array<T>(String key, T Function(Map<String, dynamic>) decode) =>
      List.unmodifiable(
        _field<List<Object?>>(key).cast<Map<String, dynamic>>().map(decode),
      );

  List<T>? _nullableArray<T>(
    String key,
    T Function(Map<String, dynamic>) decode,
  ) => switch (_field<List<Object?>?>(key)) {
    final values? => List.unmodifiable(
      values.cast<Map<String, dynamic>>().map(decode),
    ),
    null => null,
  };

  /// Serializes the provider's data with unknown and explicit null fields intact.
  Map<String, dynamic> toJson() => Map.of(_json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PluginRecord &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_json, other._json);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_json));
}

/// The organization or member that owns a plugin or marketplace.
final class OrganizationPluginOwner extends _PluginRecord {
  /// Parses an owner without narrowing future wire values.
  OrganizationPluginOwner.fromJson(super.json);

  /// Owner type in the provider's spelling.
  String get type => _field<String>('type');

  /// Member ID for a user owner.
  String? get userId => _json['user_id'] as String?;
}

/// Member or API key that published a plugin or version.
final class OrganizationPluginActor extends _PluginRecord {
  /// Parses an actor without narrowing future wire values.
  OrganizationPluginActor.fromJson(super.json);

  /// Actor type in the provider's spelling.
  String get type => _field<String>('type');

  /// Member ID for a user actor.
  String? get userId => _json['user_id'] as String?;

  /// Email address, if available for a user actor.
  String? get emailAddress => _json['email_address'] as String?;

  /// Identifier for an API key actor.
  String? get apiKeyId => _json['api_key_id'] as String?;
}

/// Organization, member, or RBAC group in a share or installation setting.
final class OrganizationPluginTarget extends _PluginRecord {
  /// Parses a target without narrowing future wire values.
  OrganizationPluginTarget.fromJson(super.json);

  /// Target type in the provider's spelling.
  String get type => _field<String>('type');

  /// User ID for an organization-member target.
  String? get userId => _json['user_id'] as String?;

  /// Group ID for an RBAC group target.
  String? get rbacGroupId => _json['rbac_group_id'] as String?;
}

/// A plugin in a Claude Enterprise marketplace.
final class OrganizationPlugin extends _PluginRecord {
  /// Parses a provider response.
  OrganizationPlugin.fromJson(Map<String, dynamic> json) : super(json) {
    checkOrganizationType(json, type);
  }

  /// Manifest components, when available.
  List<OrganizationPluginComponent>? get components =>
      _nullableArray('components', OrganizationPluginComponent.fromJson);

  /// Content scan results, when reported.
  OrganizationPluginContentScan? get contentScan =>
      _object('content_scan', OrganizationPluginContentScan.fromJson);

  /// When this record was created.
  DateTime get createdAt => DateTime.parse(_field('created_at'));

  /// Principal that created this record, when available.
  OrganizationPluginActor? get createdBy =>
      _object('created_by', OrganizationPluginActor.fromJson);

  /// Optional description.
  String? get description => _field<String?>('description');

  /// Human-readable display name, when provided.
  String? get displayName => _field<String?>('display_name');

  /// Resource identifier.
  String get id => _field<String>('id');

  /// Most recently stored version ID.
  String get latestVersionId => _field<String>('latest_version_id');

  /// Version label declared in the manifest.
  String? get manifestVersion => _field<String?>('manifest_version');

  /// Marketplace containing this plugin.
  String get marketplaceId => _field<String>('marketplace_id');

  /// Name reported by the marketplace.
  String get name => _field<String>('name');

  /// Effective organization installation preference, if present.
  String? get organizationInstallationPreference =>
      _field<String?>('organization_installation_preference');

  /// Whether the effective preference came from the marketplace default.
  bool? get organizationInstallationPreferenceInherited =>
      _field<bool?>('organization_installation_preference_inherited');

  /// Owner of this plugin or marketplace.
  OrganizationPluginOwner get owner =>
      OrganizationPluginOwner.fromJson(_field('owner'));

  /// Reported plugin reach classification.
  String? get reach => _field<String?>('reach');

  /// Version currently served to members.
  String get servedVersionId => _field<String>('served_version_id');

  /// Whether the served version is pinned.
  bool get servedVersionPinned => _field<bool>('served_version_pinned');

  /// Resource discriminator.
  String get type => 'plugin';

  /// When this record was last updated.
  DateTime get updatedAt => DateTime.parse(_field('updated_at'));
}

/// An immutable version of an organization plugin.
final class OrganizationPluginVersion extends _PluginRecord {
  /// Parses a provider response.
  OrganizationPluginVersion.fromJson(Map<String, dynamic> json) : super(json) {
    checkOrganizationType(json, type);
  }

  /// Manifest components, when available.
  List<OrganizationPluginComponent>? get components =>
      _nullableArray('components', OrganizationPluginComponent.fromJson);

  /// Content scan results, when reported.
  OrganizationPluginContentScan? get contentScan =>
      _object('content_scan', OrganizationPluginContentScan.fromJson);

  /// When this record was created.
  DateTime get createdAt => DateTime.parse(_field('created_at'));

  /// Principal that created this record, when available.
  OrganizationPluginActor? get createdBy =>
      _object('created_by', OrganizationPluginActor.fromJson);

  /// Optional description.
  String? get description => _field<String?>('description');

  /// Human-readable display name, when provided.
  String? get displayName => _field<String?>('display_name');

  /// Resource identifier.
  String get id => _field<String>('id');

  /// Version label declared in the manifest.
  String? get manifestVersion => _field<String?>('manifest_version');

  /// Plugin identifier.
  String get pluginId => _field<String>('plugin_id');

  /// Reported plugin reach classification.
  String? get reach => _field<String?>('reach');

  /// Release notes supplied when this version was uploaded.
  String? get releaseNotes => _field<String?>('release_notes');

  /// Resource discriminator.
  String get type => 'plugin_version';
}

/// A skill, command, agent, hook, MCP server, or CLI included in a plugin.
final class OrganizationPluginComponent extends _PluginRecord {
  /// Parses a provider response.
  OrganizationPluginComponent.fromJson(super.json);

  /// Optional description.
  String? get description => _field<String?>('description');

  /// Name reported by the marketplace.
  String get name => _field<String>('name');

  /// Resource discriminator.
  String get type => _field<String>('type');
}

/// Content scanning status and assessment for a plugin.
final class OrganizationPluginContentScan extends _PluginRecord {
  /// Parses a provider response.
  OrganizationPluginContentScan.fromJson(super.json);

  /// Scan assessment, when available.
  String? get assessment => _field<String?>('assessment');

  /// Explanation provided with the assessment.
  String? get reason => _field<String?>('reason');

  /// Current scan status.
  String get status => _field<String>('status');
}

/// A Claude Enterprise plugin marketplace.
final class OrganizationPluginMarketplace extends _PluginRecord {
  /// Parses a provider response.
  OrganizationPluginMarketplace.fromJson(Map<String, dynamic> json)
    : super(json) {
    checkOrganizationType(json, type);
  }

  /// When this record was created.
  DateTime get createdAt => DateTime.parse(_field('created_at'));

  /// Installation preference inherited by plugins with no override.
  String? get defaultInstallationPreference =>
      _field<String?>('default_installation_preference');

  /// Resource identifier.
  String get id => _field<String>('id');

  /// When the last synchronization ended, when available.
  DateTime? get lastSyncEndedAt => _optionalDate('last_sync_ended_at');

  /// Commit read in the last synchronization, when available.
  String? get lastSyncReadSha => _field<String?>('last_sync_read_sha');

  /// Name reported by the marketplace.
  String get name => _field<String>('name');

  /// Owner of this plugin or marketplace.
  OrganizationPluginOwner get owner =>
      OrganizationPluginOwner.fromJson(_field('owner'));

  /// Marketplace source, such as `manual` or `github`.
  String get source => _field<String>('source');

  /// Synchronization status, when available.
  String? get syncStatus => _field<String?>('sync_status');

  /// Resource discriminator.
  String get type => 'plugin_marketplace';
}

/// The result of checking a repository or archive as a marketplace.
final class PluginMarketplaceValidationReport extends _PluginRecord {
  /// Parses a provider response.
  PluginMarketplaceValidationReport.fromJson(Map<String, dynamic> json)
    : super(json) {
    checkOrganizationType(json, type);
  }

  /// Commit validated when the input was a repository.
  String? get commitSha => _field<String?>('commit_sha');

  /// Marketplace manifest error, when present.
  String? get manifestError => _field<String?>('manifest_error');

  /// Machine-readable manifest error code, when present.
  String? get manifestErrorCode => _field<String?>('manifest_error_code');

  /// Plugin validation errors.
  List<PluginMarketplaceValidationError> get pluginErrors =>
      _array('plugin_errors', PluginMarketplaceValidationError.fromJson);

  /// Warnings grouped by plugin.
  List<PluginMarketplaceValidationWarnings> get pluginWarnings =>
      _array('plugin_warnings', PluginMarketplaceValidationWarnings.fromJson);

  /// Repository branch or commit requested, if applicable.
  String? get ref => _field<String?>('ref');

  /// Number of plugins in the marketplace manifest.
  int get totalPluginCount => _field<int>('total_plugin_count');

  /// Resource discriminator.
  String get type => 'plugin_marketplace_validation_report';

  /// Whether the marketplace passed validation.
  bool get valid => _field<bool>('valid');
}

/// A validation error for one plugin.
final class PluginMarketplaceValidationError extends _PluginRecord {
  /// Parses a provider response.
  PluginMarketplaceValidationError.fromJson(super.json);

  /// Provider validation error.
  String get error => _field<String>('error');

  /// Machine-readable diagnostic code.
  String get errorCode => _field<String>('error_code');

  /// Name reported by the marketplace.
  String get name => _field<String>('name');
}

/// One warning reported while validating a plugin.
final class PluginMarketplaceValidationWarning extends _PluginRecord {
  /// Parses a provider response.
  PluginMarketplaceValidationWarning.fromJson(super.json);

  /// Machine-readable diagnostic code.
  String get errorCode => _field<String>('error_code');

  /// Human-readable warning.
  String get message => _field<String>('message');
}

/// Warnings associated with a plugin in the validation report.
final class PluginMarketplaceValidationWarnings extends _PluginRecord {
  /// Parses a provider response.
  PluginMarketplaceValidationWarnings.fromJson(super.json);

  /// Name reported by the marketplace.
  String get name => _field<String>('name');

  /// Warnings associated with this plugin.
  List<PluginMarketplaceValidationWarning> get warnings =>
      _array('warnings', PluginMarketplaceValidationWarning.fromJson);
}

/// Installation preference applied to a plugin for one target.
final class OrganizationPluginInstallationSetting extends _PluginRecord {
  /// Parses a provider response.
  OrganizationPluginInstallationSetting.fromJson(Map<String, dynamic> json)
    : super(json) {
    checkOrganizationType(json, type);
  }

  /// When this record was created.
  DateTime get createdAt => DateTime.parse(_field('created_at'));

  /// Installation preference as reported by the provider.
  String get installationPreference =>
      _field<String>('installation_preference');

  /// Plugin identifier.
  String get pluginId => _field<String>('plugin_id');

  /// Organization, member, or group targeted by this record.
  OrganizationPluginTarget get target =>
      OrganizationPluginTarget.fromJson(_field('target'));

  /// Resource discriminator.
  String get type => 'plugin_installation_setting';

  /// When this record was last updated.
  DateTime get updatedAt => DateTime.parse(_field('updated_at'));
}

/// Receipt for removing one plugin installation preference.
final class DeletedOrganizationPluginInstallationSetting extends _PluginRecord {
  /// Parses a provider response.
  DeletedOrganizationPluginInstallationSetting.fromJson(
    Map<String, dynamic> json,
  ) : super(json) {
    checkOrganizationType(json, type);
  }

  /// Plugin identifier.
  String get pluginId => _field<String>('plugin_id');

  /// Organization, member, or group targeted by this record.
  OrganizationPluginTarget get target =>
      OrganizationPluginTarget.fromJson(_field('target'));

  /// Resource discriminator.
  String get type => 'plugin_installation_setting_deleted';
}

/// A target with which a member shared their plugin.
final class OrganizationPluginShare extends _PluginRecord {
  /// Parses a provider response.
  OrganizationPluginShare.fromJson(Map<String, dynamic> json) : super(json) {
    checkOrganizationType(json, type);
  }

  /// When the member granted access.
  DateTime get grantedAt => DateTime.parse(_field('granted_at'));

  /// Plugin identifier.
  String get pluginId => _field<String>('plugin_id');

  /// Organization, member, or group targeted by this record.
  OrganizationPluginTarget get target =>
      OrganizationPluginTarget.fromJson(_field('target'));

  /// Resource discriminator.
  String get type => 'plugin_share';
}

/// Receipt for deleting a plugin and its stored versions.
final class DeletedOrganizationPlugin extends _PluginRecord {
  /// Parses a provider response.
  DeletedOrganizationPlugin.fromJson(Map<String, dynamic> json) : super(json) {
    checkOrganizationType(json, type);
  }

  /// Resource identifier.
  String get id => _field<String>('id');

  /// Resource discriminator.
  String get type => 'plugin_deleted';
}
