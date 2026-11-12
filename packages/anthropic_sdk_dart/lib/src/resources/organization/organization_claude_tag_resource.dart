import '../../models/organization/claude_tag.dart';
import '../../models/organization/organization_page.dart';
import 'organization_transport.dart';

const _claudeTag = '/claude_tag';
const _claudeTagBeta = 'experimental-claude-tag-2026-10-21';
const _channels = '$_claudeTag/slack_channels';
const _workspaces = '$_claudeTag/slack_workspaces';
const _bundles = '$_claudeTag/bundles';

/// Slack settings and access bundles for Claude Tag (Enterprise beta).
///
/// Use an organization-level Claude Enterprise Admin API key. Reads need
/// `read:claude_tag`, writes need `write:claude_tag` and separate enablement.
final class OrganizationClaudeTagResource {
  /// Creates the Claude Tag resource on the organization transport.
  OrganizationClaudeTagResource(OrganizationTransport transport)
    : slackChannels = ClaudeTagSlackChannelsResource(transport),
      slackWorkspaces = ClaudeTagSlackWorkspacesResource(transport),
      bundles = ClaudeTagBundlesResource(transport);

  /// Claude Tag Slack channel settings.
  final ClaudeTagSlackChannelsResource slackChannels;

  /// Claude Tag Slack workspace settings.
  final ClaudeTagSlackWorkspacesResource slackWorkspaces;

  /// Read and attach access bundles.
  final ClaudeTagBundlesResource bundles;
}

/// Manages Slack channels set up with Claude Tag.
final class ClaudeTagSlackChannelsResource {
  /// Creates the channel resource.
  const ClaudeTagSlackChannelsResource(this._transport);

  final OrganizationTransport _transport;

  /// Sets up a channel using Slack's own workspace and channel IDs.
  ///
  /// If the channel is already set up, the API applies the supplied settings
  /// to the existing channel.
  ///
  /// If setup succeeds and applying settings fails, the channel remains set
  /// up with its settings unset. Read `slack_channel_id` from the API
  /// exception's `errorDetails` to identify the channel.
  Future<ClaudeTagSlackChannel> create({
    required String slackWorkspaceId,
    required String slackChannelId,
    ClaudeTagSettingsUpdate? settings,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _channels,
    ClaudeTagSlackChannel.fromJson,
    body: {
      'slack': {'workspace_id': slackWorkspaceId, 'channel_id': slackChannelId},
      'settings': ?settings?.toJson(),
    },
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  /// Lists set-up channels in the given Slack workspace or Enterprise Grid.
  ///
  /// Both filters use Slack IDs. Set [includeInherited] to get the effective
  /// settings and their sources.
  Future<OrganizationCursorPage<ClaudeTagSlackChannel>> list({
    required String slackWorkspaceId,
    String? slackChannelId,
    bool? includeInherited,
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _tagList(
    _transport,
    _channels,
    ClaudeTagSlackChannel.fromJson,
    query: {
      'slack_workspace_id': slackWorkspaceId,
      'slack_channel_id': ?slackChannelId,
      'include_inherited': ?includeInherited?.toString(),
    },
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Retrieves a channel by its Claude Tag `slch_...` ID.
  Future<ClaudeTagSlackChannel> retrieve(
    String id, {
    bool? includeInherited,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _channel(id),
    ClaudeTagSlackChannel.fromJson,
    query: {'include_inherited': ?includeInherited?.toString()},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  /// Updates the channel's stored settings.
  ///
  /// A null setting inherits its value except for `replyMode`. Use
  /// [ClaudeTagReplyMode.automatic] to restore a stored reply mode to default.
  Future<ClaudeTagSlackChannel> update(
    String id, {
    required ClaudeTagSettingsUpdate settings,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _channel(id),
    ClaudeTagSlackChannel.fromJson,
    body: {'settings': settings.toJson()},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  /// Removes the channel from Claude Tag along with its settings and bundle
  /// targets. Its Claude Tag sessions and transcripts are deleted asynchronously.
  Future<DeletedClaudeTagRecord> delete(
    String id, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _channel(id),
    (json) =>
        DeletedClaudeTagRecord.fromJson(json, type: 'slack_channel_deleted'),
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  static String _channel(String id) =>
      '$_channels/${organizationIdSegment(id, 'id')}';
}

/// Manages Claude Tag settings for connected Slack workspaces.
final class ClaudeTagSlackWorkspacesResource {
  /// Creates the workspace resource.
  const ClaudeTagSlackWorkspacesResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists connected workspaces, or looks up a workspace by Slack's own ID.
  Future<OrganizationCursorPage<ClaudeTagSlackWorkspace>> list({
    String? slackWorkspaceId,
    bool? includeInherited,
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _tagList(
    _transport,
    _workspaces,
    ClaudeTagSlackWorkspace.fromJson,
    query: {
      'slack_workspace_id': ?slackWorkspaceId,
      'include_inherited': ?includeInherited?.toString(),
    },
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Retrieves a workspace by its Claude Tag `slws_...` ID.
  Future<ClaudeTagSlackWorkspace> retrieve(
    String id, {
    bool? includeInherited,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _workspace(id),
    ClaudeTagSlackWorkspace.fromJson,
    query: {'include_inherited': ?includeInherited?.toString()},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  /// Updates the workspace's stored settings.
  ///
  /// Omit `replyMode` or pass null. Only channel settings accept a reply mode.
  Future<ClaudeTagSlackWorkspace> update(
    String id, {
    required ClaudeTagSettingsUpdate settings,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _workspace(id),
    ClaudeTagSlackWorkspace.fromJson,
    body: {'settings': settings.toJson()},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  static String _workspace(String id) =>
      '$_workspaces/${organizationIdSegment(id, 'id')}';
}

/// Read-only access bundle metadata and its attachment operations.
final class ClaudeTagBundlesResource {
  /// Creates the access bundle resource.
  ClaudeTagBundlesResource(OrganizationTransport transport)
    : _transport = transport,
      targets = ClaudeTagBundleTargetsResource(transport);

  final OrganizationTransport _transport;

  /// Attachments of bundles to Slack channels and workspaces.
  final ClaudeTagBundleTargetsResource targets;

  /// Lists the organization's access bundles, newest first.
  Future<OrganizationCursorPage<ClaudeTagBundle>> list({
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _tagList(
    _transport,
    _bundles,
    ClaudeTagBundle.fromJson,
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Retrieves bundle metadata without exposing what the bundle grants.
  Future<ClaudeTagBundle> retrieve(
    String bundleId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _bundle(bundleId),
    ClaudeTagBundle.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );
}

/// Reads and changes Slack attachments of an access bundle.
final class ClaudeTagBundleTargetsResource {
  /// Creates the attachment resource.
  const ClaudeTagBundleTargetsResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists Slack channels and workspaces that use a bundle.
  Future<OrganizationCursorPage<ClaudeTagBundleTarget>> list(
    String bundleId, {
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _tagList(
    _transport,
    '${_bundle(bundleId)}/targets',
    ClaudeTagBundleTarget.fromJson,
    limit: limit,
    page: page,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Attaches a bundle to a channel or workspace already set up in Claude Tag.
  Future<ClaudeTagBundleTarget> attach(
    String bundleId,
    ClaudeTagBundleAttachment target, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_bundle(bundleId)}/targets',
    ClaudeTagBundleTarget.fromJson,
    body: target.toJson(),
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  /// Retrieves one attachment of the specified bundle.
  Future<ClaudeTagBundleTarget> retrieve(
    String bundleId,
    String targetId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _target(bundleId, targetId),
    ClaudeTagBundleTarget.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  /// Detaches an access bundle. The API returns 404 on a repeated detach.
  Future<DeletedClaudeTagRecord> detach(
    String bundleId,
    String targetId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _target(bundleId, targetId),
    (json) =>
        DeletedClaudeTagRecord.fromJson(json, type: 'bundle_target_deleted'),
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _claudeTagBeta,
    abortTrigger: abortTrigger,
  );

  static String _target(String bundleId, String targetId) =>
      '${_bundle(bundleId)}/targets/${organizationIdSegment(targetId, 'targetId')}';
}

String _bundle(String bundleId) =>
    '$_bundles/${organizationIdSegment(bundleId, 'bundleId')}';

Future<OrganizationCursorPage<T>> _tagList<T>(
  OrganizationTransport transport,
  String path,
  T Function(Map<String, dynamic>) decode, {
  Map<String, String> query = const {},
  int? limit,
  String? page,
  required List<String> betas,
  Future<void>? abortTrigger,
}) => transport.send(
  'GET',
  path,
  (json) => OrganizationCursorPage.fromJson(json, decode),
  query: {...query, 'limit': ?limit?.toString(), 'page': ?page},
  beta: betas.isEmpty ? null : betas.join(','),
  requiredBeta: _claudeTagBeta,
  abortTrigger: abortTrigger,
);
