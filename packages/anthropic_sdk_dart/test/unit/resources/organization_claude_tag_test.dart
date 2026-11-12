import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _slackWorkspace = 'T01ABCD2EFG';
const _slackChannel = 'C05HJKL6MNP';
const _channel = 'slch_fixture';
const _workspace = 'slws_fixture';
const _bundle = 'capp_fixture';
const _target = 'btgt_fixture';
const _timestamp = '2026-11-10T20:00:00Z';

const Map<String, Object?> _settings = {
  'enabled': false,
  'instructions': 'Inherited and channel instructions',
  'model': null,
  'environment_id': null,
  'guest_policy': {'type': 'channel_only'},
  'reply_mode': {'type': 'always_awake'},
};
const Map<String, Object?> _sources = {
  'enabled': {'type': 'slack_workspace', 'slack_workspace_id': _workspace},
  'instructions': [
    {'type': 'slack_default'},
    {'type': 'slack_parent_channel', 'slack_channel_id': 'slch_parent'},
    {
      'type': 'slack_grid_channel',
      'slack': {'workspace_id': 'E010ABC', 'channel_id': _slackChannel},
    },
  ],
  'model': {'type': 'default'},
  'environment_id': null,
  'guest_policy': {'type': 'slack_channel', 'slack_channel_id': _channel},
  'reply_mode': {'type': 'future_source', 'arbitrary': true},
};
const Map<String, Object?> _channelJson = {
  'type': 'slack_channel',
  'id': _channel,
  'slack': {'workspace_id': _slackWorkspace, 'channel_id': _slackChannel},
  'settings': _settings,
  'sources': _sources,
  'created_at': _timestamp,
  'updated_at': _timestamp,
};
const Map<String, Object?> _workspaceJson = {
  'type': 'slack_workspace',
  'id': _workspace,
  'slack': {'workspace_id': _slackWorkspace},
  'settings': _settings,
  'sources': _sources,
  'created_at': _timestamp,
  'updated_at': _timestamp,
};
const Map<String, Object?> _bundleJson = {
  'type': 'bundle',
  'id': _bundle,
  'display_name': 'Fixture bundle',
  'description': null,
  'created_at': _timestamp,
  'updated_at': _timestamp,
};
const Map<String, Object> _channelTarget = {
  'type': 'slack_channel',
  'id': _target,
  'slack_channel_id': _channel,
  'created_at': _timestamp,
};
const Map<String, Object> _workspaceTarget = {
  'type': 'slack_workspace',
  'id': _target,
  'slack_workspace_id': _workspace,
  'created_at': _timestamp,
};

void main() {
  late AnthropicClient client;
  late MockHttpClient transport;
  late OrganizationClaudeTagResource tag;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-enterprise-key'),
        defaultHeaders: {'Anthropic-Beta': 'caller-beta'},
        workspaceId: 'wrkspc_ignored',
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    tag = client.organization.claudeTag;
    addTearDown(client.close);
  });

  test('keeps configured and explicit betas with the required gate', () async {
    final betaClient = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin-key'),
        defaultHeaders: {
          'Anthropic-Beta':
              'configured-beta,experimental-claude-tag-2026-10-21',
        },
      ),
      httpClient: transport,
    );
    addTearDown(betaClient.close);
    for (var index = 0; index < 2; index++) {
      transport.queueJsonResponse({
        'data': <Object>[],
        'has_more': false,
        'next_page': null,
      });
    }
    final resource = betaClient.organization.claudeTag.bundles;
    await resource.list();
    await resource.list(
      betas: ['explicit-beta', 'experimental-claude-tag-2026-10-21'],
    );
    expect(
      transport.requests.map((request) => request.headers['anthropic-beta']),
      [
        'configured-beta,experimental-claude-tag-2026-10-21',
        'explicit-beta,experimental-claude-tag-2026-10-21',
      ],
    );
  });

  void sent(
    String method,
    String suffix, {
    Map<String, String> query = const {},
    Map<String, Object?>? body,
  }) {
    final request = transport.lastRequest! as http.Request;
    expect(request.method, method);
    expect(request.url.path, '/v1/organizations/claude_tag$suffix');
    expect(request.url.queryParameters, query);
    expect(request.headers['x-api-key'], 'fixture-enterprise-key');
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(
      request.headers['anthropic-beta'],
      'caller-beta,experimental-claude-tag-2026-10-21',
    );
    expect(request.headers['anthropic-workspace-id'], isNull);
    if (body == null) {
      expect(request.body, isEmpty);
    } else {
      expect(jsonDecode(request.body), body);
    }
  }

  test(
    'creates and changes Slack channel settings with omitted and null fields',
    () async {
      transport
        ..queueJsonResponse(_channelJson)
        ..queueJsonResponse(_channelJson)
        ..queueJsonResponse({'type': 'slack_channel_deleted', 'id': _channel});
      final channels = tag.slackChannels;
      final result = await channels.create(
        slackWorkspaceId: _slackWorkspace,
        slackChannelId: _slackChannel,
        settings: const ClaudeTagSettingsUpdate(
          enabled: true,
          model: 'claude-sonnet-5-5',
          environmentId: 'env_fixture',
          guestPolicy: ClaudeTagGuestPolicy.channelOnly,
          replyMode: ClaudeTagReplyMode.alwaysAwake,
        ),
      );
      expect(result.id, _channel);
      expect(result.slack.workspaceId, _slackWorkspace);
      expect(result.slack.channelId, _slackChannel);
      expect(result.settings.guestPolicy, 'channel_only');
      expect(result.settings.replyMode, 'always_awake');
      sent(
        'POST',
        '/slack_channels',
        body: {
          'slack': {
            'workspace_id': _slackWorkspace,
            'channel_id': _slackChannel,
          },
          'settings': {
            'enabled': true,
            'model': 'claude-sonnet-5-5',
            'environment_id': 'env_fixture',
            'guest_policy': {'type': 'channel_only'},
            'reply_mode': {'type': 'always_awake'},
          },
        },
      );
      await channels.update(
        _channel,
        settings: const ClaudeTagSettingsUpdate(
          enabled: false,
          instructions: null,
          guestPolicy: null,
          replyMode: null,
        ),
      );
      sent(
        'POST',
        '/slack_channels/$_channel',
        body: {
          'settings': {
            'enabled': false,
            'instructions': null,
            'guest_policy': null,
            'reply_mode': null,
          },
        },
      );
      final removed = await channels.delete(_channel);
      expect(removed.id, _channel);
      expect(removed.type, 'slack_channel_deleted');
      sent('DELETE', '/slack_channels/$_channel');
    },
  );

  test(
    'lists channels by Slack IDs and retrieves by the distinct Claude Tag ID',
    () async {
      transport
        ..queueJsonResponse({'data': <Object>[], 'next_page': 'cursor+/='})
        ..queueJsonResponse({
          'data': [_channelJson],
          'next_page': null,
        })
        ..queueJsonResponse(_channelJson);
      final channels = tag.slackChannels;
      final first = await channels.list(
        slackWorkspaceId: _slackWorkspace,
        slackChannelId: _slackChannel,
        includeInherited: true,
        limit: 20,
      );
      expect(first.data, isEmpty);
      expect(first.nextPage, 'cursor+/=');
      sent(
        'GET',
        '/slack_channels',
        query: {
          'slack_workspace_id': _slackWorkspace,
          'slack_channel_id': _slackChannel,
          'include_inherited': 'true',
          'limit': '20',
        },
      );
      final page = await channels.list(
        slackWorkspaceId: _slackWorkspace,
        slackChannelId: _slackChannel,
        includeInherited: true,
        limit: 20,
        page: first.nextPage,
      );
      expect(page.data.single.toJson(), _channelJson);
      expect(page.nextPage, isNull);
      final channel = await channels.retrieve(
        _channel,
        includeInherited: false,
      );
      expect(channel.sources.enabled?.slackWorkspaceId, _workspace);
      expect(channel.sources.instructions.map((source) => source.type), [
        'slack_default',
        'slack_parent_channel',
        'slack_grid_channel',
      ]);
      expect(channel.sources.instructions.last.slack?.workspaceId, 'E010ABC');
      expect(channel.sources.replyMode?.toJson(), {
        'type': 'future_source',
        'arbitrary': true,
      });
      sent(
        'GET',
        '/slack_channels/$_channel',
        query: {'include_inherited': 'false'},
      );
    },
  );

  test(
    'lists, retrieves and updates workspaces and accepts older omitted reply mode',
    () async {
      final old = {
        ..._workspaceJson,
        'settings': {..._settings}..remove('reply_mode'),
        'sources': {..._sources}..remove('reply_mode'),
      };
      transport
        ..queueJsonResponse({
          'data': [old],
          'next_page': null,
        })
        ..queueJsonResponse(_workspaceJson)
        ..queueJsonResponse(_workspaceJson);
      final workspaces = tag.slackWorkspaces;
      final result = await workspaces.list(
        slackWorkspaceId: _slackWorkspace,
        includeInherited: true,
      );
      final workspace = result.data.single;
      expect(workspace.settings.replyMode, isNull);
      expect(workspace.slack.channelId, isNull);
      expect(workspace.toJson(), old);
      sent(
        'GET',
        '/slack_workspaces',
        query: {
          'slack_workspace_id': _slackWorkspace,
          'include_inherited': 'true',
        },
      );
      expect(
        (await workspaces.retrieve(_workspace)).slack.workspaceId,
        _slackWorkspace,
      );
      sent('GET', '/slack_workspaces/$_workspace');
      await workspaces.update(
        _workspace,
        settings: const ClaudeTagSettingsUpdate(environmentId: null),
      );
      sent(
        'POST',
        '/slack_workspaces/$_workspace',
        body: {
          'settings': {'environment_id': null},
        },
      );
    },
  );

  test(
    'lists and retrieves bundle metadata and operates on both target kinds',
    () async {
      transport
        ..queueJsonResponse({
          'data': [_bundleJson],
          'next_page': 'next_bundle',
        })
        ..queueJsonResponse(_bundleJson)
        ..queueJsonResponse({
          'data': [_channelTarget, _workspaceTarget],
          'next_page': 'next_target',
        })
        ..queueJsonResponse(_channelTarget)
        ..queueJsonResponse(_workspaceTarget)
        ..queueJsonResponse(_channelTarget)
        ..queueJsonResponse({'type': 'bundle_target_deleted', 'id': _target});
      final bundles = tag.bundles;
      final page = await bundles.list(limit: 5, page: 'bundle_page');
      expect(page.nextPage, 'next_bundle');
      expect(page.data.single.description, isNull);
      sent('GET', '/bundles', query: {'limit': '5', 'page': 'bundle_page'});
      expect((await bundles.retrieve(_bundle)).displayName, 'Fixture bundle');
      sent('GET', '/bundles/$_bundle');
      final targets = bundles.targets;
      final listing = await targets.list(_bundle, limit: 2);
      expect(listing.nextPage, 'next_target');
      expect(listing.data.first.slackChannelId, _channel);
      expect(listing.data.last.slackWorkspaceId, _workspace);
      sent('GET', '/bundles/$_bundle/targets', query: {'limit': '2'});
      await targets.attach(
        _bundle,
        const ClaudeTagBundleAttachment.channel(_channel),
      );
      sent(
        'POST',
        '/bundles/$_bundle/targets',
        body: {'type': 'slack_channel', 'slack_channel_id': _channel},
      );
      await targets.attach(
        _bundle,
        const ClaudeTagBundleAttachment.workspace(_workspace),
      );
      sent(
        'POST',
        '/bundles/$_bundle/targets',
        body: {'type': 'slack_workspace', 'slack_workspace_id': _workspace},
      );
      expect((await targets.retrieve(_bundle, _target)).id, _target);
      sent('GET', '/bundles/$_bundle/targets/$_target');
      expect(
        (await targets.detach(_bundle, _target)).type,
        'bundle_target_deleted',
      );
      sent('DELETE', '/bundles/$_bundle/targets/$_target');
    },
  );

  test(
    'retains the write-enable error code on the public update path',
    () async {
      transport.queueJsonResponse({
        'type': 'error',
        'error': {
          'type': 'permission_error',
          'message': 'Writes are disabled',
          'details': {'error_code': 'claude_tag_writes_not_enabled'},
        },
        'request_id': 'req_fixture',
      }, statusCode: 403);
      await expectLater(
        tag.slackChannels.update(
          _channel,
          settings: const ClaudeTagSettingsUpdate(enabled: false),
        ),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having(
                (error) => error.errorCode,
                'errorCode',
                'claude_tag_writes_not_enabled',
              ),
        ),
      );
      sent(
        'POST',
        '/slack_channels/$_channel',
        body: {
          'settings': {'enabled': false},
        },
      );
    },
  );

  test(
    'retains the channel identity when applying setup settings fails',
    () async {
      transport.queueJsonResponse({
        'type': 'error',
        'request_id': 'req_partial_setup',
        'error': {
          'type': 'invalid_request_error',
          'message': 'Invalid settings for fixture-enterprise-key',
          'details': {
            'slack_channel_id': _channel,
            'field': 'settings.reply_mode',
          },
        },
      }, statusCode: 400);

      await expectLater(
        tag.slackChannels.create(
          slackWorkspaceId: 'T_FIXTURE',
          slackChannelId: 'C_FIXTURE',
          settings: const ClaudeTagSettingsUpdate(replyMode: null),
        ),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.requestId,
                'request ID',
                'req_partial_setup',
              )
              .having(
                (error) => error.errorDetails?['slack_channel_id'],
                'channel',
                _channel,
              )
              .having(
                (error) => error.toString(),
                'diagnostic',
                isNot(contains('fixture-enterprise-key')),
              ),
        ),
      );
      expect(transport.requests, hasLength(1));
    },
  );
}
