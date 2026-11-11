import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Ordering by timestamp on Compliance lists and transcripts.
enum ComplianceOrder {
  /// Oldest first.
  asc,

  /// Newest first.
  desc,
}

/// RFC 3339 time bounds for a Compliance list filter.
///
/// Bounds are sent as dotted query keys such as `created_at.gte`.
@immutable
final class ComplianceTimeRange {
  /// The timestamp must be strictly later.
  final DateTime? gt;

  /// The timestamp must be equal or later.
  final DateTime? gte;

  /// The timestamp must be strictly earlier.
  final DateTime? lt;

  /// The timestamp must be equal or earlier.
  final DateTime? lte;

  /// Creates optional lower and upper bounds.
  const ComplianceTimeRange({this.gt, this.gte, this.lt, this.lte});

  /// Encodes the bounds under the named date field.
  Map<String, String> toQueryParameters(String field) => {
    if (gt case final time?) '$field.gt': time.toUtc().toIso8601String(),
    if (gte case final time?) '$field.gte': time.toUtc().toIso8601String(),
    if (lt case final time?) '$field.lt': time.toUtc().toIso8601String(),
    if (lte case final time?) '$field.lte': time.toUtc().toIso8601String(),
  };
}

/// A read-only Compliance payload with the complete original wire fields.
///
/// Typed accessors expose common fields. Use [raw] for additional fields and
/// newly added variants. These payloads may contain organization or user data.
@immutable
abstract class ComplianceRecord {
  /// The original JSON, including fields added by newer server versions.
  final Map<String, dynamic> raw;

  ComplianceRecord._(Map<String, dynamic> json) : raw = _freezeObject(json);

  /// Encodes the original JSON without dropping unknown fields.
  Map<String, dynamic> toJson() => raw;

  T _required<T>(String key) {
    final value = raw[key];
    if (value is T) return value;
    throw FormatException('Expected $T in Compliance field "$key"');
  }

  T? _optional<T>(String key) {
    if (raw[key] == null) return null;
    return _required<T>(key);
  }

  DateTime _date(String key) => DateTime.parse(_required<String>(key));

  DateTime? _optionalDate(String key) {
    final value = _optional<String>(key);
    return value == null ? null : DateTime.parse(value);
  }

  List<T> _list<T>(String key) =>
      List<T>.unmodifiable(_required<List<dynamic>>(key).cast<T>());

  List<T> _records<T>(
    String key,
    T Function(Map<String, dynamic>) decode, {
    bool allowMissing = false,
  }) {
    if (allowMissing && !raw.containsKey(key)) return List<T>.empty();
    return List<T>.unmodifiable(
      _required<List<dynamic>>(key).map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException('Expected objects in Compliance field "$key"');
        }
        return decode(item);
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ComplianceRecord &&
      other.runtimeType == runtimeType &&
      mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(raw));

  @override
  String toString() => '$runtimeType(${raw.length} fields)';
}

Map<String, dynamic> _freezeObject(Map<String, dynamic> json) =>
    Map<String, dynamic>.unmodifiable(
      json.map((key, value) => MapEntry(key, _freezeValue(value))),
    );

Object? _freezeValue(Object? value) => switch (value) {
  final Map<String, dynamic> map => _freezeObject(map),
  final List<dynamic> list => List<Object?>.unmodifiable(
    list.map(_freezeValue),
  ),
  _ => value,
};

/// A page whose opaque token is supplied as `page` on the next request.
final class ComplianceCursorPage<T extends ComplianceRecord>
    extends ComplianceRecord {
  /// Records in response order.
  late final List<T> data;

  /// The next opaque cursor, even when this page is empty.
  String? get nextPage => _optional<String>('next_page');

  /// Whether a next page is available.
  bool get hasMore => _optional<bool>('has_more') ?? nextPage != null;

  /// Decodes a cursor page and its records.
  ComplianceCursorPage.fromJson(
    super.json,
    T Function(Map<String, dynamic>) decode,
  ) : super._() {
    data = _records('data', decode);
  }

  /// Decodes a directory page and requires usable continuation metadata.
  ComplianceCursorPage.directoryFromJson(
    super.json,
    T Function(Map<String, dynamic>) decode, {
    bool allowMissingTerminalCursor = false,
  }) : super._() {
    final hasMore = _required<bool>('has_more');
    final cursor = nextPage;
    if (!raw.containsKey('next_page') &&
        !(allowMissingTerminalCursor && !hasMore)) {
      throw const FormatException('Missing Compliance field "next_page"');
    }
    if (hasMore && (cursor == null || cursor.isEmpty)) {
      throw const FormatException('Missing Compliance continuation token');
    }
    data = _records('data', decode);
  }
}

/// A page addressed by the first and last records' opaque cursors.
final class ComplianceIdPage<T extends ComplianceRecord>
    extends ComplianceRecord {
  /// Records in response order.
  late final List<T> data;

  /// Cursor to use as `before_id` where backward paging is supported.
  String? get firstId => _optional<String>('first_id');

  /// Cursor to use as `after_id` for forward paging.
  String? get lastId => _optional<String>('last_id');

  /// Whether further records are available in the chosen order.
  bool get hasMore => _optional<bool>('has_more') ?? false;

  /// Decodes a page of records. The Activity Feed may omit `data`.
  ComplianceIdPage.fromJson(
    super.json,
    T Function(Map<String, dynamic>) decode, {
    bool allowMissingData = false,
  }) : super._() {
    data = _records('data', decode, allowMissing: allowMissingData);
  }
}

/// An Activity Feed entry, including unrecognized activity types.
final class ComplianceActivity extends ComplianceRecord {
  /// The activity identifier used for deduplication.
  String get id => _required<String>('id');

  /// The activity discriminator as sent by the server.
  String get type => _required<String>('type');

  /// When the activity occurred.
  DateTime get createdAt => _date('created_at');

  /// The tagged organization identifier, when present.
  String? get organizationId => _optional<String>('organization_id');

  /// The organization UUID, when present.
  String? get organizationUuid => _optional<String>('organization_uuid');

  /// The actor that performed the activity, when present.
  ComplianceActor? get actor {
    final json = _optional<Map<String, dynamic>>('actor');
    return json == null ? null : ComplianceActor.fromJson(json);
  }

  /// Decodes an activity without dropping variant-specific fields.
  ComplianceActivity.fromJson(super.json) : super._();
}

/// The actor of a Compliance activity, including future actor types.
final class ComplianceActor extends ComplianceRecord {
  /// The actor discriminator as sent by the server.
  String get type => _required<String>('type');

  /// The user's tagged ID, when the actor is a user.
  String? get userId => _optional<String>('user_id');

  /// The actor's email address, when disclosed.
  String? get emailAddress => _optional<String>('email_address');

  /// The API key ID, when the activity was performed with one.
  String? get apiKeyId => _optional<String>('api_key_id');

  /// Decodes the actor and preserves all original fields.
  ComplianceActor.fromJson(super.json) : super._();
}

/// An organization listed under the caller's parent organization.
final class ComplianceOrganization extends ComplianceRecord {
  /// The organization UUID.
  String get uuid => _required<String>('uuid');

  /// The display name.
  String get name => _required<String>('name');

  /// When the organization was created.
  DateTime get createdAt => _date('created_at');

  /// Decodes an organization.
  ComplianceOrganization.fromJson(super.json) : super._();
}

/// A member of a linked organization.
final class ComplianceOrganizationUser extends ComplianceRecord {
  /// The user's tagged ID.
  String get id => _required<String>('id');

  /// The user's email address, if disclosed.
  String? get email => _optional<String>('email');

  /// The member's full name, if available.
  String? get fullName => _optional<String>('full_name');

  /// The member's organization role.
  String? get organizationRole => _optional<String>('organization_role');

  /// When the membership was created, if known.
  DateTime? get createdAt => _optionalDate('created_at');

  /// Decodes an organization member.
  ComplianceOrganizationUser.fromJson(super.json) : super._();
}

/// A user reference in a Compliance result.
final class ComplianceUserReference extends ComplianceRecord {
  /// The user's tagged ID.
  String get id => _required<String>('id');

  /// The user's email address, if disclosed.
  String? get emailAddress => _optional<String>('email_address');

  /// Decodes a user reference.
  ComplianceUserReference.fromJson(super.json) : super._();
}

/// Personal Claude and Cowork instructions for a member.
final class ComplianceUserPreferences extends ComplianceRecord {
  /// The user who set these instructions.
  ComplianceUserReference get user =>
      ComplianceUserReference.fromJson(_required('user'));

  /// Instructions for Claude saved in Claude.ai, if set.
  String? get conversationPreferences =>
      _optional<String>('conversation_preferences');

  /// Global instructions saved in Cowork, if set.
  String? get coworkGlobalInstructions =>
      _optional<String>('cowork_global_instructions');

  /// Decodes a member's preferences.
  ComplianceUserPreferences.fromJson(super.json) : super._();
}

/// A role assigned within a linked organization.
final class ComplianceRole extends ComplianceRecord {
  /// The role ID.
  String get id => _required<String>('id');

  /// The role name.
  String get name => _required<String>('name');

  /// The role description.
  String get description => _required<String>('description');

  /// Creation time, when present.
  DateTime? get createdAt => _optionalDate('created_at');

  /// Last update time, when present.
  DateTime? get updatedAt => _optionalDate('updated_at');

  /// Decodes a role.
  ComplianceRole.fromJson(super.json) : super._();
}

/// A permission associated with a Compliance role.
final class ComplianceRolePermission extends ComplianceRecord {
  /// The permitted action.
  String get action => _required<String>('action');

  /// The permission's resource type.
  String get resourceType => _required<String>('resource_type');

  /// The resource ID, when the permission targets a specific instance.
  String? get resourceId => _optional<String>('resource_id');

  /// Decodes a permission.
  ComplianceRolePermission.fromJson(super.json) : super._();
}

/// Effective settings and API-key metadata for a linked organization.
final class ComplianceOrganizationSettings extends ComplianceRecord {
  /// The organization ID.
  String get organizationId => _required<String>('organization_id');

  /// Effective settings, including unrecognized setting types.
  List<ComplianceSetting> get settings =>
      _records('settings', ComplianceSetting.fromJson);

  /// API-key metadata. The credential itself is not returned.
  List<ComplianceApiKeyMetadata> get apiKeys =>
      _records('api_keys', ComplianceApiKeyMetadata.fromJson);

  /// Decodes effective settings.
  ComplianceOrganizationSettings.fromJson(super.json) : super._();
}

/// A setting whose value shape is identified by its wire type.
final class ComplianceSetting extends ComplianceRecord {
  /// The setting's wire discriminator.
  String? get type => _optional<String>('type');

  /// The setting's current value as returned by the server.
  Object? get value => raw['value'];

  /// Decodes a setting and retains its source information.
  ComplianceSetting.fromJson(super.json) : super._();
}

/// Metadata about an organization's API key.
final class ComplianceApiKeyMetadata extends ComplianceRecord {
  /// The API key's tagged ID.
  String get id => _required<String>('id');

  /// The key's display name.
  String get name => _required<String>('name');

  /// Whether the key is currently active.
  bool get isActive => _required<bool>('is_active');

  /// The scopes attached to the key.
  List<String> get scopes => _list<String>('scopes');

  /// Expiry time when the key expires.
  DateTime? get expiresAt => _optionalDate('expires_at');

  /// Decodes API-key metadata.
  ComplianceApiKeyMetadata.fromJson(super.json) : super._();
}

/// The current security controls evaluated for an organization.
final class ComplianceSecurityPosture extends ComplianceRecord {
  /// The organization ID.
  String get organizationId => _required<String>('organization_id');

  /// When the controls were evaluated.
  DateTime get evaluatedAt => _date('evaluated_at');

  /// The raw availability state of attestation comments.
  String get commentsStatus => _required<String>('comments_status');

  /// Controls returned by the service. A missing control is not a pass.
  List<ComplianceSecurityControl> get controls =>
      _records('controls', ComplianceSecurityControl.fromJson);

  /// Decodes the Security Posture report.
  ComplianceSecurityPosture.fromJson(super.json) : super._();
}

/// One security control and its current evaluation result.
final class ComplianceSecurityControl extends ComplianceRecord {
  /// The control identifier.
  String get id => _required<String>('id');

  /// The human-readable control name.
  String get displayName => _required<String>('display_name');

  /// The raw evaluation status.
  String get status => _required<String>('status');

  /// The control's raw rating.
  String get rating => _required<String>('rating');

  /// Attestation details, when available.
  Map<String, dynamic>? get attestation =>
      _optional<Map<String, dynamic>>('attestation');

  /// Decodes a security control.
  ComplianceSecurityControl.fromJson(super.json) : super._();
}

/// A directory group in the caller's Enterprise tenant.
final class ComplianceGroup extends ComplianceRecord {
  /// The group ID.
  String get id => _required<String>('id');

  /// The group name.
  String get name => _required<String>('name');

  /// The group description.
  String get description => _required<String>('description');

  /// The group's source type as sent by the server.
  String get sourceType => _required<String>('source_type');

  /// Role IDs assigned to the group, if the service returns them.
  List<String>? get roles => raw['roles'] == null ? null : _list('roles');

  /// Decodes a group.
  ComplianceGroup.fromJson(super.json) : super._();
}

/// A member of a Compliance directory group.
final class ComplianceGroupMember extends ComplianceRecord {
  /// The user's tagged ID.
  String get userId => _required<String>('user_id');

  /// The member's email address, if disclosed.
  String? get email => _optional<String>('email');

  /// When the membership was created, if known.
  DateTime? get createdAt => _optionalDate('created_at');

  /// When the membership was last changed, if known.
  DateTime? get updatedAt => _optionalDate('updated_at');

  /// Decodes a group member.
  ComplianceGroupMember.fromJson(super.json) : super._();
}
