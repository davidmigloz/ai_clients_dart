import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Claude Tag policy for a Slack channel that contains a guest.
enum ClaudeTagGuestPolicy {
  /// Claude can respond normally.
  allow('allow'),

  /// Claude does not respond.
  restrict('restrict'),

  /// Claude can use access bundles attached to this channel.
  channelOnly('channel_only');

  const ClaudeTagGuestPolicy(this.value);

  /// Provider discriminator.
  final String value;
}

/// How Claude Tag replies in a Slack channel.
enum ClaudeTagReplyMode {
  /// Claude chooses when to respond.
  automatic('automatic'),

  /// Claude responds to a mention.
  mentionOnly('mention_only'),

  /// Claude follows the channel conversation without requiring a mention.
  alwaysAwake('always_awake'),

  /// Claude responds in its Slack threads.
  thread('thread');

  const ClaudeTagReplyMode(this.value);

  /// Provider discriminator.
  final String value;
}

/// Optional settings to apply to a Claude Tag Slack workspace or channel.
@immutable
final class ClaudeTagSettingsUpdate {
  /// Omit a field to leave it unchanged. Set a field other than `replyMode`
  /// to null to inherit its value.
  ///
  /// Only channels store a reply mode. A null `replyMode` leaves an unset
  /// mode unchanged. For a channel with a stored mode, use
  /// [ClaudeTagReplyMode.automatic] to restore default behavior.
  const ClaudeTagSettingsUpdate({
    this._enabled = unsetCopyWithValue,
    this._instructions = unsetCopyWithValue,
    this._model = unsetCopyWithValue,
    this._environmentId = unsetCopyWithValue,
    this._guestPolicy = unsetCopyWithValue,
    this._replyMode = unsetCopyWithValue,
  });

  final Object? _enabled;
  final Object? _instructions;
  final Object? _model;
  final Object? _environmentId;
  final Object? _guestPolicy;
  final Object? _replyMode;

  /// Converts changed fields, retaining explicit nulls.
  Map<String, dynamic> toJson() => {
    if (_enabled != unsetCopyWithValue) 'enabled': _enabled as bool?,
    if (_instructions != unsetCopyWithValue)
      'instructions': _instructions as String?,
    if (_model != unsetCopyWithValue) 'model': _model as String?,
    if (_environmentId != unsetCopyWithValue)
      'environment_id': _environmentId as String?,
    if (_guestPolicy != unsetCopyWithValue)
      'guest_policy': switch (_guestPolicy as ClaudeTagGuestPolicy?) {
        final policy? => {'type': policy.value},
        null => null,
      },
    if (_replyMode != unsetCopyWithValue)
      'reply_mode': switch (_replyMode as ClaudeTagReplyMode?) {
        final mode? => {'type': mode.value},
        null => null,
      },
  };
}

/// Where to attach a Claude Tag access bundle.
@immutable
final class ClaudeTagBundleAttachment {
  /// Creates a target for the Claude Tag channel ID (`slch_...`).
  const ClaudeTagBundleAttachment.channel(this.id) : type = 'slack_channel';

  /// Creates a target for the Claude Tag workspace ID (`slws_...`).
  const ClaudeTagBundleAttachment.workspace(this.id) : type = 'slack_workspace';

  /// Provider discriminator for the target kind.
  final String type;

  /// The ID issued by Claude Tag for the Slack channel or workspace.
  final String id;

  /// Serializes the tagged attachment request.
  Map<String, dynamic> toJson() => {'type': type, '${type}_id': id};
}

@immutable
abstract base class _ClaudeTagRecord {
  _ClaudeTagRecord(Map<String, dynamic> json)
    : _json = deepUnmodifiableMap(json);

  final Map<String, dynamic> _json;

  T _field<T>(String key) =>
      requiredOrganizationField<T>(_json, key, runtimeType.toString());

  DateTime _timestamp(String key) => DateTime.parse(_field<String>(key));

  /// Converts the record to its provider representation.
  Map<String, dynamic> toJson() => Map.of(_json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ClaudeTagRecord &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_json, other._json);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_json));
}

/// Slack's own workspace and, for a channel, channel identifiers.
final class ClaudeTagSlackIdentifiers extends _ClaudeTagRecord {
  /// Parses returned Slack identifiers.
  ClaudeTagSlackIdentifiers.fromJson(super.json);

  /// Slack's workspace ID, or an Enterprise Grid ID.
  String get workspaceId => _field<String>('workspace_id');

  /// Slack's channel ID, if this record represents a channel.
  String? get channelId => _json['channel_id'] as String?;
}

/// Stored or effective Claude Tag settings, depending on the read query.
final class ClaudeTagSettings extends _ClaudeTagRecord {
  /// Parses the returned settings, preserving unset and future values.
  ClaudeTagSettings.fromJson(super.json);

  /// Whether Claude is enabled at this level.
  bool? get enabled => _json['enabled'] as bool?;

  /// Standing instructions, if set.
  String? get instructions => _json['instructions'] as String?;

  /// Model for new sessions, if set.
  String? get model => _json['model'] as String?;

  /// Environment or self-hosted runner pool ID, if set.
  String? get environmentId => _json['environment_id'] as String?;

  /// Guest policy's original tag, if set.
  String? get guestPolicy => _tagType('guest_policy');

  /// Reply mode's original tag, if set or inherited.
  String? get replyMode => _tagType('reply_mode');

  String? _tagType(String key) =>
      (_json[key] as Map<String, dynamic>?)?['type'] as String?;
}

/// The level from which a Claude Tag setting is taken.
final class ClaudeTagSettingSource extends _ClaudeTagRecord {
  /// Parses a source, retaining future types and optional identifiers.
  ClaudeTagSettingSource.fromJson(super.json);

  /// Source kind in the provider's spelling.
  String get type => _field<String>('type');

  /// Claude Tag channel ID for a channel or its parent.
  String? get slackChannelId => _json['slack_channel_id'] as String?;

  /// Claude Tag workspace ID when the source is a Slack workspace.
  String? get slackWorkspaceId => _json['slack_workspace_id'] as String?;

  /// Slack identifiers when the source is an Enterprise Grid channel.
  ClaudeTagSlackIdentifiers? get slack => switch (_json['slack']) {
    final Map<String, dynamic> value => ClaudeTagSlackIdentifiers.fromJson(
      value,
    ),
    _ => null,
  };
}

/// Provenance of each setting returned on a Slack workspace or channel.
final class ClaudeTagSettingSources extends _ClaudeTagRecord {
  /// Parses nullable sources and ordered instruction sources.
  ClaudeTagSettingSources.fromJson(super.json);

  /// Where the enabled setting came from.
  ClaudeTagSettingSource? get enabled => _source('enabled');

  /// Levels contributing instructions, broadest first.
  List<ClaudeTagSettingSource> get instructions => List.unmodifiable(
    _field<List<Object?>>(
      'instructions',
    ).cast<Map<String, dynamic>>().map(ClaudeTagSettingSource.fromJson),
  );

  /// Where the model setting came from.
  ClaudeTagSettingSource? get model => _source('model');

  /// Where the environment or runner pool setting came from.
  ClaudeTagSettingSource? get environmentId => _source('environment_id');

  /// Where the guest policy setting came from.
  ClaudeTagSettingSource? get guestPolicy => _source('guest_policy');

  /// Where the reply mode setting came from.
  ClaudeTagSettingSource? get replyMode => _source('reply_mode');

  ClaudeTagSettingSource? _source(String key) => switch (_json[key]) {
    final Map<String, dynamic> value => ClaudeTagSettingSource.fromJson(value),
    _ => null,
  };
}

/// A Slack channel or workspace registered with Claude Tag.
sealed class ClaudeTagSlackRecord extends _ClaudeTagRecord {
  ClaudeTagSlackRecord._(Map<String, dynamic> json, this.type) : super(json) {
    checkOrganizationType(json, type);
    slack = ClaudeTagSlackIdentifiers.fromJson(_field('slack'));
    settings = ClaudeTagSettings.fromJson(_field('settings'));
    sources = ClaudeTagSettingSources.fromJson(_field('sources'));
  }

  /// Provider discriminator.
  final String type;

  /// Resource ID issued by Claude Tag.
  String get id => _field<String>('id');

  /// Slack's own IDs for this record.
  late final ClaudeTagSlackIdentifiers slack;

  /// Stored or effective values, depending on the read query.
  late final ClaudeTagSettings settings;

  /// The levels that supplied each reported setting.
  late final ClaudeTagSettingSources sources;

  /// When this resource was registered.
  DateTime get createdAt => _timestamp('created_at');

  /// When this resource was last updated.
  DateTime get updatedAt => _timestamp('updated_at');
}

/// A Slack channel registered with Claude Tag.
final class ClaudeTagSlackChannel extends ClaudeTagSlackRecord {
  /// Parses a channel response.
  ClaudeTagSlackChannel.fromJson(Map<String, dynamic> json)
    : super._(json, 'slack_channel') {
    slack._field<String>('channel_id');
  }
}

/// A Slack workspace registered with Claude Tag.
final class ClaudeTagSlackWorkspace extends ClaudeTagSlackRecord {
  /// Parses a workspace response.
  ClaudeTagSlackWorkspace.fromJson(Map<String, dynamic> json)
    : super._(json, 'slack_workspace');
}

/// A Claude Tag access bundle, without its granted resources or credentials.
final class ClaudeTagBundle extends _ClaudeTagRecord {
  /// Parses bundle metadata.
  ClaudeTagBundle.fromJson(Map<String, dynamic> json) : super(json) {
    checkOrganizationType(json, type);
  }

  /// Provider discriminator.
  String get type => 'bundle';

  /// Bundle ID.
  String get id => _field<String>('id');

  /// Human-readable name.
  String get displayName => _field<String>('display_name');

  /// Optional description.
  String? get description => _field<String?>('description');

  /// When this bundle was created.
  DateTime get createdAt => _timestamp('created_at');

  /// When the bundle was last updated.
  DateTime get updatedAt => _timestamp('updated_at');
}

/// The Slack channel or workspace to which a Claude Tag bundle is attached.
final class ClaudeTagBundleTarget extends _ClaudeTagRecord {
  /// Parses a target, retaining future target kinds.
  ClaudeTagBundleTarget.fromJson(super.json) {
    switch (type) {
      case 'slack_channel':
        _field<String>('slack_channel_id');
      case 'slack_workspace':
        _field<String>('slack_workspace_id');
    }
  }

  /// Target discriminator in the provider's spelling.
  String get type => _field<String>('type');

  /// Bundle target ID.
  String get id => _field<String>('id');

  /// Claude Tag ID for an attached channel.
  String? get slackChannelId => _json['slack_channel_id'] as String?;

  /// Claude Tag ID for an attached workspace.
  String? get slackWorkspaceId => _json['slack_workspace_id'] as String?;

  /// When the bundle was attached.
  DateTime get createdAt => _timestamp('created_at');
}

/// Confirmation that a Slack channel or bundle target was removed.
final class DeletedClaudeTagRecord extends _ClaudeTagRecord {
  /// Parses a confirmation for the expected record type.
  DeletedClaudeTagRecord.fromJson(
    Map<String, dynamic> json, {
    required String type,
  }) : super(json) {
    checkOrganizationType(json, type);
  }

  /// Deleted record discriminator.
  String get type => _field<String>('type');

  /// ID of the removed record.
  String get id => _field<String>('id');
}
