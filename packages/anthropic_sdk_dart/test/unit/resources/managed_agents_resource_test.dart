import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

/// Fixture helpers for managed agents API responses.
class ManagedAgentsFixtures {
  ManagedAgentsFixtures._();

  static Map<String, dynamic> agent({
    String id = 'agent_test123',
    int version = 1,
    String name = 'Test Agent',
  }) {
    return {
      'id': id,
      'type': 'agent',
      'version': version,
      'name': name,
      'description': 'A test agent',
      'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
      'system': 'You are a helpful assistant.',
      'tools': <Map<String, dynamic>>[],
      'mcp_servers': <Map<String, dynamic>>[],
      'skills': <Map<String, dynamic>>[],
      'metadata': <String, String>{},
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
    };
  }

  static Map<String, dynamic> session({
    String id = 'session_test123',
    String status = 'idle',
    String agentId = 'agent_test123',
  }) {
    return {
      'id': id,
      'type': 'session',
      'status': status,
      'agent': {
        'id': agentId,
        'type': 'agent',
        'version': 1,
        'name': 'Test Agent',
        'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
        'mcp_servers': <Map<String, dynamic>>[],
        'skills': <Map<String, dynamic>>[],
        'tools': <Map<String, dynamic>>[],
      },
      'environment_id': 'env_test123',
      'title': null,
      'metadata': <String, String>{},
      'resources': <Map<String, dynamic>>[],
      'vault_ids': <String>[],
      'stats': {'active_seconds': 0, 'duration_seconds': 0},
      'usage': {
        'input_tokens': 0,
        'output_tokens': 0,
        'cache_read_input_tokens': 0,
        'cache_creation_input_tokens': 0,
      },
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
    };
  }

  static Map<String, dynamic> vault({
    String id = 'vault_test123',
    String displayName = 'Test Vault',
  }) {
    return {
      'id': id,
      'type': 'vault',
      'display_name': displayName,
      'metadata': <String, String>{},
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
    };
  }

  static Map<String, dynamic> credential({
    String id = 'cred_test123',
    String vaultId = 'vault_test123',
  }) {
    return {
      'id': id,
      'type': 'vault_credential',
      'vault_id': vaultId,
      'display_name': 'Test Credential',
      'auth': {
        'type': 'static_bearer',
        'mcp_server_url': 'https://mcp.example.com',
        'token_hint': '****abcd',
      },
      'metadata': <String, String>{},
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
    };
  }

  static Map<String, dynamic> credentialValidation({
    String credentialId = 'cred_test123',
    String vaultId = 'vault_test123',
    String status = 'valid',
  }) {
    return {
      'type': 'vault_credential_validation',
      'credential_id': credentialId,
      'vault_id': vaultId,
      'status': status,
      'validated_at': '2026-04-01T00:00:00Z',
      'has_refresh_token': true,
      'mcp_probe': {
        'method': 'initialize',
        'http_response': {
          'status_code': 200,
          'content_type': 'application/json',
          'body': '{}',
          'body_truncated': false,
        },
      },
      'refresh': null,
    };
  }

  static Map<String, dynamic> sessionEvent({
    String type = 'user.message',
    String id = 'event_test123',
  }) {
    return {
      'type': type,
      'id': id,
      'content': [
        {'type': 'text', 'text': 'Hello'},
      ],
      'processed_at': '2026-04-01T00:00:00Z',
    };
  }

  static Map<String, dynamic> sessionThread({
    String id = 'sthr_test123',
    String sessionId = 'session_test123',
    String status = 'running',
  }) {
    return {
      'id': id,
      'type': 'session_thread',
      'session_id': sessionId,
      'status': status,
      'agent': {
        'id': 'agent_test123',
        'type': 'agent',
        'version': 1,
        'name': 'Test Agent',
        'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
        'mcp_servers': <Map<String, dynamic>>[],
        'skills': <Map<String, dynamic>>[],
        'tools': <Map<String, dynamic>>[],
      },
      'parent_thread_id': null,
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
      'usage': null,
      'stats': null,
    };
  }

  static Map<String, dynamic> sessionThreadCreatedEvent({
    String id = 'event_test_thread',
    String sessionThreadId = 'sthr_test123',
    String agentName = 'Test Agent',
  }) {
    return {
      'type': 'session.thread_created',
      'id': id,
      'agent_name': agentName,
      'session_thread_id': sessionThreadId,
      'processed_at': '2026-04-01T00:00:00Z',
    };
  }
}

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  test(
    'agent create copies untyped empty collections into its request',
    () async {
      const original = CreateAgentParams(
        name: 'Agent',
        model: ModelParamsId(id: 'claude-sonnet-5'),
        tools: [AgentToolset20260401Params()],
        metadata: {'key': 'value'},
      );
      expect(original.copyWith().toJson(), original.toJson());
      expect(original.copyWith(tools: null).toJson(), isNot(contains('tools')));

      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.agent());
      await client.agents.create(
        original.copyWith(tools: [], mcpServers: [], skills: [], metadata: {}),
      );
      final request = mockHttpClient.lastRequest!;
      final body =
          jsonDecode((request as dynamic).body as String)
              as Map<String, dynamic>;
      expect(body['tools'], isEmpty);
      expect(body['mcp_servers'], isEmpty);
      expect(body['skills'], isEmpty);
      expect(body['metadata'], isEmpty);
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    },
  );

  group('Current Managed Agents configuration', () {
    const beta = 'managed-agents-2026-04-01';
    const arn = 'arn:aws:iam::123456789012:role/AgentRunner';
    const identity = {'type': 'aws_role', 'role_arn': arn};

    test(
      'agent create and update send execution identity and reset explicitly',
      () async {
        mockHttpClient
          ..queueJsonResponse({
            ...ManagedAgentsFixtures.agent(),
            'execution_identity': identity,
          })
          ..queueJsonResponse({
            ...ManagedAgentsFixtures.agent(version: 2),
            'execution_identity': {'type': 'service_account'},
          });
        final agent = await client.agents.create(
          const CreateAgentParams(
            name: 'AWS agent',
            model: ModelParamsId(id: 'claude-sonnet-5-5'),
            executionIdentity: AgentExecutionIdentity.awsRole(arn),
          ),
        );
        expect(agent.executionIdentity?.roleArn, arn);
        expect(agent.toJson()['execution_identity'], identity);
        expect(
          agent.copyWith(executionIdentity: null).executionIdentity,
          isNull,
        );
        final reset = await client.agents.update(
          agent.id,
          const UpdateAgentParams(executionIdentity: null),
        );
        expect(
          reset.executionIdentity,
          const AgentExecutionIdentity.serviceAccount(),
        );
        expect(
          const UpdateAgentParams().toJson(),
          isNot(contains('execution_identity')),
        );
        final create = mockHttpClient.requests.first;
        final update = mockHttpClient.requests.last;
        expect(create.url.path, '/v1/agents');
        expect(update.url.path, '/v1/agents/${agent.id}');
        expect(create.headers['anthropic-beta'], beta);
        expect(update.headers['anthropic-beta'], beta);
        expect(
          (jsonDecode((create as dynamic).body as String)
              as Map<String, dynamic>)['execution_identity'],
          identity,
        );
        expect(jsonDecode((update as dynamic).body as String), {
          'execution_identity': null,
        });
        final unchanged = UpdateAgentParams.fromJson(const {});
        final cleared = UpdateAgentParams.fromJson(const {
          'execution_identity': null,
        });
        expect(unchanged, isNot(cleared));
        expect(cleared.copyWith().toJson(), {'execution_identity': null});
      },
    );

    test(
      'session and thread snapshots carry identity and thread status filters',
      () async {
        final session = ManagedAgentsFixtures.session();
        final sessionAgent = Map<String, dynamic>.of(
          session['agent'] as Map<String, dynamic>,
        );
        session['agent'] = sessionAgent..['execution_identity'] = identity;
        final thread = ManagedAgentsFixtures.sessionThread(
          status: 'future_status',
        );
        final threadAgent = Map<String, dynamic>.of(
          thread['agent'] as Map<String, dynamic>,
        );
        thread['agent'] = threadAgent..['execution_identity'] = identity;
        mockHttpClient
          ..queueJsonResponse(session)
          ..queueJsonResponse({
            'data': [thread],
            'next_page': 'page_next',
          })
          ..queueJsonResponse({
            'data': <Map<String, dynamic>>[],
            'next_page': null,
          });
        final loaded = await client.sessions.retrieve('session_test123');
        final threads = client.sessions.threads(loaded.id);
        const statuses = [SessionStatus.idle, SessionStatus.running];
        final first = await threads.list(limit: 1, statuses: statuses);
        final next = await threads.list(
          limit: 1,
          statuses: statuses,
          page: first.nextPage,
        );

        expect(loaded.agent.executionIdentity?.roleArn, arn);
        expect(
          (first.data.single.agent as SessionThreadAgent)
              .executionIdentity
              ?.roleArn,
          arn,
        );
        expect(first.data.single.status, SessionStatus.unknown);
        expect(first.data.single.toJson()['status'], 'future_status');
        expect(
          first.data.single.copyWith().toJson()['status'],
          'future_status',
        );
        expect(next.data, isEmpty);
        final firstRequest = mockHttpClient.requests[1];
        final nextRequest = mockHttpClient.requests[2];
        expect(firstRequest.url.path, '/v1/sessions/session_test123/threads');
        expect(firstRequest.url.queryParametersAll['statuses[]'], [
          'idle',
          'running',
        ]);
        expect(nextRequest.url.queryParametersAll['statuses[]'], [
          'idle',
          'running',
        ]);
        expect(nextRequest.url.queryParameters['page'], 'page_next');
        for (final request in mockHttpClient.requests) {
          expect(request.headers['anthropic-beta'], beta);
        }
      },
    );

    test(
      'auto permission and web fetch URL sources reach the toolset wire shape',
      () async {
        const sources = ManagedWebFetchUrlSources(
          userInput: ManagedWebFetchUrlSourceFilter.none(shorthand: true),
          clientToolResults: ManagedWebFetchUrlSourceFilter.all(),
          serverToolResults: ManagedWebFetchUrlSourceFilter.only([
            'web_search',
          ]),
        );
        final response = ManagedAgentsFixtures.agent()
          ..['tools'] = [
            {
              'type': 'agent_toolset_20260401',
              'default_config': {
                'type': 'default',
                'enabled': true,
                'permission_policy': {'type': 'always_allow'},
              },
              'configs': [
                {
                  'type': 'web_fetch',
                  'name': 'web_fetch',
                  'enabled': true,
                  'permission_policy': {'type': 'auto'},
                  'url_sources': {
                    ...sources.toJson(),
                    'user_input': {'type': 'none'},
                  },
                },
              ],
            },
          ];
        mockHttpClient.queueJsonResponse(response);
        final agent = await client.agents.create(
          const CreateAgentParams(
            name: 'Restricted fetch',
            model: ModelParamsId(id: 'claude-sonnet-5-5'),
            tools: [
              AgentToolset20260401Params(
                configs: [
                  WebFetchToolConfigParams(
                    permissionPolicy: AutoPolicy(),
                    urlSources: sources,
                  ),
                ],
              ),
            ],
          ),
        );
        final tools = agent.tools.single as AgentToolset20260401;
        final fetch = tools.configs.single as WebFetchToolConfig;
        expect(fetch.permissionPolicy, const AutoPolicy());
        expect(fetch.urlSources!.userInput!.toJson(), {'type': 'none'});
        expect(fetch.urlSources!.serverToolResults!.tools, ['web_search']);
        final request = mockHttpClient.lastRequest!;
        expect(request.headers['anthropic-beta'], beta);
        final body =
            jsonDecode((request as dynamic).body as String)
                as Map<String, dynamic>;
        final tool = (body['tools'] as List).single as Map<String, dynamic>;
        final config = (tool['configs'] as List).single as Map<String, dynamic>;
        expect(config['permission_policy'], {'type': 'auto'});
        expect(config['url_sources'], {
          'user_input': 'none',
          'client_tool_results': {'type': 'all'},
          'server_tool_results': {
            'type': 'only',
            'tools': [
              {'type': 'tool_reference', 'name': 'web_search'},
            ],
          },
        });
      },
    );

    test(
      'web fetch response preserves explicit null and omitted fields',
      () async {
        const nested = {
          'user_input': null,
          'client_tool_results': null,
          'server_tool_results': {'type': 'all'},
        };
        for (final fields in <Map<String, dynamic>>[
          {},
          {'url_sources': null},
          {'url_sources': nested},
        ]) {
          mockHttpClient.queueJsonResponse({
            ...ManagedAgentsFixtures.agent(),
            'tools': [
              {
                'type': 'agent_toolset_20260401',
                'default_config': {
                  'type': 'default',
                  'enabled': true,
                  'permission_policy': {'type': 'always_allow'},
                },
                'configs': [
                  {
                    'type': 'web_fetch',
                    'name': 'web_fetch',
                    'enabled': true,
                    'permission_policy': {'type': 'auto'},
                    ...fields,
                  },
                ],
              },
            ],
          });
        }

        final configs = <WebFetchToolConfig>[];
        for (var index = 0; index < 3; index++) {
          final agent = await client.agents.retrieve('agent_test123');
          final tools = agent.tools.single as AgentToolset20260401;
          configs.add(tools.configs.single as WebFetchToolConfig);
          expect(mockHttpClient.lastRequest?.headers['anthropic-beta'], beta);
        }

        expect(configs[0].copyWith().toJson(), isNot(contains('url_sources')));
        expect(
          configs[1].copyWith().toJson(),
          containsPair('url_sources', null),
        );
        final resolved = configs[2].urlSources!;
        expect(resolved.copyWith().toJson(), nested);
        expect(
          configs[2].copyWith(urlSources: null).toJson(),
          containsPair('url_sources', null),
        );

        mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.agent());
        await client.agents.create(
          CreateAgentParams(
            name: 'Replay only the configured URL sources',
            model: const ModelParamsId(id: 'claude-sonnet-5'),
            tools: [
              AgentToolset20260401Params(
                configs: [WebFetchToolConfigParams(urlSources: resolved)],
              ),
            ],
          ),
        );
        final body =
            jsonDecode((mockHttpClient.lastRequest as dynamic).body as String)
                as Map<String, dynamic>;
        final tool = (body['tools'] as List).single as Map<String, dynamic>;
        final config = (tool['configs'] as List).single as Map<String, dynamic>;
        expect(config['url_sources'], {
          'server_tool_results': {'type': 'all'},
        });
      },
    );

    test('invalid URL source filters fail before agent creation', () async {
      const none = ManagedWebFetchUrlSourceFilter.none();
      final invalid = [
        const ManagedWebFetchUrlSources(
          userInput: ManagedWebFetchUrlSourceFilter.only(['fetcher']),
        ),
        const ManagedWebFetchUrlSources(
          clientToolResults: ManagedWebFetchUrlSourceFilter.except([]),
        ),
        const ManagedWebFetchUrlSources(
          clientToolResults: ManagedWebFetchUrlSourceFilter.only([
            'read',
            'read',
          ]),
        ),
        const ManagedWebFetchUrlSources(
          clientToolResults: ManagedWebFetchUrlSourceFilter.only(['']),
        ),
        ManagedWebFetchUrlSources(
          clientToolResults: ManagedWebFetchUrlSourceFilter.only(
            List.generate(129, (index) => 'tool_$index'),
          ),
        ),
        const ManagedWebFetchUrlSources(
          serverToolResults: ManagedWebFetchUrlSourceFilter.except(['read']),
        ),
        const ManagedWebFetchUrlSources(
          userInput: none,
          clientToolResults: none,
          serverToolResults: none,
        ),
      ];
      for (final sources in invalid) {
        await expectLater(
          client.agents.create(
            CreateAgentParams(
              name: 'Invalid source',
              model: const ModelParamsId(id: 'claude-sonnet-5'),
              tools: [
                AgentToolset20260401Params(
                  configs: [WebFetchToolConfigParams(urlSources: sources)],
                ),
              ],
            ),
          ),
          throwsArgumentError,
        );
      }
      expect(mockHttpClient.requests, isEmpty);
    });

    test('unknown session status is rejected as a thread filter', () async {
      await expectLater(
        client.sessions
            .threads('session_test123')
            .list(statuses: [SessionStatus.idle, SessionStatus.unknown]),
        throwsArgumentError,
      );
      expect(mockHttpClient.requests, isEmpty);
    });

    test('tool evaluation parses on event listing and thread SSE', () async {
      const auto = {
        'type': 'auto',
        'evaluated_permission': {'type': 'ask', 'reason_code': 'unknown_risk'},
      };
      const tool = {
        'type': 'agent.tool_use',
        'id': 'evt_tool',
        'processed_at': '2026-11-10T00:00:00.000Z',
        'name': 'web_fetch',
        'input': {'url': 'https://example.com'},
        'evaluated_permission': 'ask',
        'evaluation': auto,
      };
      final mcp = {
        ...tool,
        'type': 'agent.mcp_tool_use',
        'id': 'evt_mcp',
        'mcp_server_name': 'example',
        'evaluated_permission': 'future_permission',
        'evaluation': {
          'type': 'future_policy',
          'detail': {
            'nested': [1],
          },
        },
      };
      mockHttpClient
        ..queueJsonResponse({
          'data': [tool],
          'next_page': null,
        })
        ..queueStreamingResponse([mcp]);
      final listed = await client.sessions.events('session_test123').list();
      final builtIn = listed.data.single as AgentToolUseEvent;
      final streamed =
          await client.sessions
                  .threads('session_test123')
                  .events('sthr_test123')
                  .stream()
                  .single
              as AgentMcpToolUseEvent;
      expect(
        builtIn.evaluation?.autoDecision?.permission,
        AgentEvaluatedPermission.ask,
      );
      expect(builtIn.evaluation?.autoDecision?.reasonCode, 'unknown_risk');
      expect(builtIn.toJson(), tool);
      expect(streamed.evaluatedPermission, AgentEvaluatedPermission.unknown);
      expect(streamed.copyWith().toJson(), mcp);
      expect(streamed.copyWith(evaluation: null).evaluation, isNull);
      expect(
        mockHttpClient.requests.first.url.path,
        '/v1/sessions/session_test123/events',
      );
      expect(
        mockHttpClient.requests.last.url.path,
        '/v1/sessions/session_test123/threads/sthr_test123/stream',
      );
      for (final request in mockHttpClient.requests) {
        expect(request.headers['anthropic-beta'], beta);
      }
    });
  });

  group('Managed Agents v20261001 configuration', () {
    const beta = 'managed-agents-2026-04-01';
    const resolved = {
      'type': 'multiagent_20261001',
      'workflows': {
        'type': 'enabled',
        'inline_agents': {'type': 'enabled'},
        'predefined_agents': [
          {'type': 'agent', 'id': 'agent_worker', 'version': 2},
          {'type': 'agent', 'id': 'agent_pinned', 'version': 1},
          {'type': 'agent', 'id': 'agent_test123', 'version': 1},
        ],
      },
      'subagents': {'type': 'disabled'},
      'advisor': {'type': 'enabled', 'model': 'claude-opus-5-5'},
    };

    test('create resolves workflows, workers, and advisor settings', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.agent(),
        'multiagent': resolved,
      });
      const config = Multiagent20261001Params(
        workflows: MultiagentWorkersParams.enabled(
          inlineAgents: MultiagentInlineAgents.enabled(),
          predefinedAgents: <MultiagentRosterEntryParams>[
            MultiagentRosterEntryAgent(
              agent: AgentParamsId(id: 'agent_worker'),
            ),
            MultiagentRosterEntryAgent(
              agent: AgentParamsObject(id: 'agent_pinned', version: 1),
            ),
            MultiagentSelfParams(),
          ],
        ),
        subagents: MultiagentWorkersParams.disabled(),
        advisor: MultiagentAdvisorSettings.enabled('claude-opus-5-5'),
      );
      final response = await client.agents.create(
        const CreateAgentParams(
          name: 'Coordinator',
          model: ModelParamsId(id: 'claude-sonnet-5-5'),
          multiagent: config,
        ),
      );

      final multiagent = response.multiagent! as Multiagent20261001;
      expect(multiagent.workflows.predefinedAgents!.first.version, 2);
      expect(multiagent.workflows.inlineAgents?.type, 'enabled');
      expect(multiagent.subagents.type, 'disabled');
      expect(multiagent.advisor.model, 'claude-opus-5-5');
      expect(multiagent.toJson(), resolved);
      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents');
      expect(request.headers['anthropic-beta'], beta);
      final body =
          jsonDecode((request as dynamic).body as String)
              as Map<String, dynamic>;
      expect(body['multiagent'], {
        'type': 'multiagent_20261001',
        'workflows': {
          'type': 'enabled',
          'inline_agents': {'type': 'enabled'},
          'predefined_agents': [
            'agent_worker',
            {'type': 'agent', 'id': 'agent_pinned', 'version': 1},
            {'type': 'self'},
          ],
        },
        'subagents': {'type': 'disabled'},
        'advisor': {'type': 'enabled', 'model': 'claude-opus-5-5'},
      });
      final parsed = MultiagentParams.fromJson(config.toJson());
      expect(parsed, config);
      expect(parsed.hashCode, config.hashCode);
    });

    test(
      'update distinguishes omission, null reset and empty roster',
      () async {
        mockHttpClient.queueJsonResponse({
          ...ManagedAgentsFixtures.agent(),
          'multiagent': {
            ...resolved,
            'workflows': {
              'type': 'enabled',
              'inline_agents': {'type': 'enabled'},
              'predefined_agents': <Map<String, dynamic>>[],
            },
            'subagents': {
              'type': 'enabled',
              'inline_agents': {'type': 'enabled'},
              'predefined_agents': <Map<String, dynamic>>[],
            },
          },
        });
        const config = Multiagent20261001Params(
          workflows: null,
          subagents: MultiagentWorkersParams.enabled(
            inlineAgents: null,
            predefinedAgents: <MultiagentRosterEntryParams>[],
          ),
        );
        final response = await client.agents.update(
          'agent_test123',
          const UpdateAgentParams(multiagent: config),
        );
        expect(
          (response.multiagent! as Multiagent20261001)
              .subagents
              .predefinedAgents,
          isEmpty,
        );
        expect(config, MultiagentParams.fromJson(config.toJson()));
        expect(config, config.copyWith());
        final request = mockHttpClient.lastRequest!;
        expect(request.url.path, '/v1/agents/agent_test123');
        expect(request.method, 'POST');
        expect(request.headers['anthropic-beta'], beta);
        expect(jsonDecode((request as dynamic).body as String), {
          'multiagent': {
            'type': 'multiagent_20261001',
            'workflows': null,
            'subagents': {
              'type': 'enabled',
              'inline_agents': null,
              'predefined_agents': <Object>[],
            },
          },
        });
      },
    );

    test(
      'session retrieval decodes resolved worker snapshots and future modes',
      () async {
        final session = ManagedAgentsFixtures.session();
        final mainAgent = session['agent'] as Map<String, dynamic>;
        final worker = Map<String, dynamic>.of(mainAgent)
          ..['id'] = 'agent_worker'
          ..['execution_identity'] = {'type': 'service_account'};
        session['agent'] = {
          ...mainAgent,
          'multiagent': {
            'type': 'multiagent_20261001',
            'workflows': {
              'type': 'enabled',
              'inline_agents': {'type': 'enabled'},
              'predefined_agents': [worker],
            },
            'subagents': {
              'type': 'future_worker_policy',
              'detail': {
                'nested': [1],
              },
            },
            'advisor': {'type': 'disabled'},
          },
        };
        mockHttpClient.queueJsonResponse(session);

        final response = await client.sessions.retrieve('session_test123');

        final multiagent =
            response.agent.multiagent! as SessionMultiagent20261001;
        final workerSnapshot = multiagent.workflows.predefinedAgents!.single;
        expect(workerSnapshot.id, 'agent_worker');
        expect(
          workerSnapshot.executionIdentity,
          const AgentExecutionIdentity.serviceAccount(),
        );
        expect(multiagent.subagents.toJson(), {
          'type': 'future_worker_policy',
          'detail': {
            'nested': [1],
          },
        });
        expect(mockHttpClient.lastRequest!.headers['anthropic-beta'], beta);
        expect(
          mockHttpClient.lastRequest!.url.path,
          '/v1/sessions/session_test123',
        );
      },
    );
  });

  group('AgentsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        ManagedAgentsFixtures.agent(name: 'My Agent'),
      );

      final agent = await client.agents.create(
        const CreateAgentParams(
          name: 'My Agent',
          model: ModelParamsId(id: 'claude-sonnet-4-5'),
        ),
      );

      expect(agent.id, 'agent_test123');
      expect(agent.name, 'My Agent');
      expect(agent.version, 1);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      expect(request.headers['x-api-key'], 'test-api-key');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['name'], 'My Agent');
      expect(body['model'], 'claude-sonnet-4-5');
    });

    test('list sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.agent()],
        'next_page': null,
      });

      final response = await client.agents.list(limit: 5);

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'agent_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['limit'], '5');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.agent());

      final agent = await client.agents.retrieve('agent_test123');

      expect(agent.id, 'agent_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123');
      expect(request.method, 'GET');
    });

    test('retrieve with version sends query parameter', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.agent(version: 3));

      final agent = await client.agents.retrieve('agent_test123', version: 3);

      expect(agent.version, 3);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.queryParameters['version'], '3');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        ManagedAgentsFixtures.agent(name: 'Updated Agent', version: 2),
      );

      final agent = await client.agents.update(
        'agent_test123',
        const UpdateAgentParams(version: 1, name: 'Updated Agent'),
      );

      expect(agent.name, 'Updated Agent');
      expect(agent.version, 2);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123');
      expect(request.method, 'POST');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.agent(),
        'archived_at': '2026-04-01T12:00:00Z',
      });

      final agent = await client.agents.archive('agent_test123');

      expect(agent.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123/archive');
      expect(request.method, 'POST');
    });

    test('listVersions sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [
          ManagedAgentsFixtures.agent(version: 1),
          ManagedAgentsFixtures.agent(version: 2),
        ],
        'next_page': null,
      });

      final response = await client.agents.listVersions('agent_test123');

      expect(response.data, hasLength(2));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123/versions');
      expect(request.method, 'GET');
    });
  });

  group('SessionsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.session());

      final session = await client.sessions.create(
        const CreateSessionParams(
          agent: AgentParamsId(id: 'agent_test123'),
          environmentId: 'env_123',
        ),
      );

      expect(session.id, 'session_test123');
      expect(session.status, SessionStatus.idle);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list sends correct request with query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.session()],
      });

      final response = await client.sessions.list(
        agentId: 'agent_test123',
        limit: 10,
      );

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions');
      expect(request.url.queryParameters['agent_id'], 'agent_test123');
      expect(request.url.queryParameters['limit'], '10');
    });

    test('list passes memory_store_id and statuses[] filters', () async {
      mockHttpClient.queueJsonResponse({'data': <Map<String, dynamic>>[]});

      await client.sessions.list(
        memoryStoreId: 'memstore_abc',
        statuses: const [SessionStatus.running, SessionStatus.idle],
      );

      final params = mockHttpClient.lastRequest!.url.queryParametersAll;
      expect(params['memory_store_id'], ['memstore_abc']);
      expect(params['statuses[]'], ['running', 'idle']);
    });

    test('list passes deployment_id filter and sets beta header', () async {
      mockHttpClient.queueJsonResponse({'data': <Map<String, dynamic>>[]});

      await client.sessions.list(deploymentId: 'dpl_123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions');
      expect(request.url.queryParameters['deployment_id'], 'dpl_123');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.session());

      final session = await client.sessions.retrieve('session_test123');

      expect(session.id, 'session_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123');
      expect(request.method, 'GET');
    });

    test('update sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.session(),
        'title': 'Updated Title',
      });

      final session = await client.sessions.update(
        'session_test123',
        const UpdateSessionParams(title: 'Updated Title'),
      );

      expect(session.id, 'session_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123');
      expect(request.method, 'POST');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'session_test123',
        'type': 'session_deleted',
      });

      final deleted = await client.sessions.delete('session_test123');

      expect(deleted.id, 'session_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123');
      expect(request.method, 'DELETE');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.session(),
        'archived_at': '2026-04-01T12:00:00Z',
      });

      final session = await client.sessions.archive('session_test123');

      expect(session.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/archive');
      expect(request.method, 'POST');
    });
  });

  group('SessionEventsResource', () {
    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.sessionEvent()],
      });

      final response = await client.sessions
          .events('session_test123')
          .list(limit: 20);

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list passes created_at[*] and types[] filters', () async {
      mockHttpClient.queueJsonResponse({'data': <Map<String, dynamic>>[]});

      await client.sessions
          .events('session_test123')
          .list(
            createdAtGt: '2026-04-01T00:00:00Z',
            createdAtLte: '2026-04-30T23:59:59Z',
            types: const ['agent.message', 'user.interrupt'],
          );

      final params = mockHttpClient.lastRequest!.url.queryParametersAll;
      expect(params['created_at[gt]'], ['2026-04-01T00:00:00Z']);
      expect(params['created_at[lte]'], ['2026-04-30T23:59:59Z']);
      expect(params['types[]'], ['agent.message', 'user.interrupt']);
    });

    test('send sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [
          {
            'type': 'user.message',
            'id': 'event_123',
            'content': [
              {'type': 'text', 'text': 'Hello'},
            ],
            'processed_at': '2026-04-01T00:00:00Z',
          },
        ],
      });

      final response = await client.sessions
          .events('session_test123')
          .send(
            const SendSessionEventsParams(
              events: [
                UserMessageEventParams(
                  content: [
                    {'type': 'text', 'text': 'Hello'},
                  ],
                ),
              ],
            ),
          );

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events');
      expect(request.method, 'POST');
    });

    test('stream sends correct request and parses SSE events', () async {
      mockHttpClient.queueStreamingResponse([
        {
          'type': 'user.message',
          'id': 'event_001',
          'content': [
            {'type': 'text', 'text': 'Hello'},
          ],
          'processed_at': '2026-04-01T00:00:00Z',
        },
        {
          'type': 'agent.message',
          'id': 'event_002',
          'content': [
            {'type': 'text', 'text': 'Hi there!'},
          ],
          'processed_at': '2026-04-01T00:00:01Z',
        },
      ]);

      final events = await client.sessions
          .events('session_test123')
          .stream()
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<UserMessageEvent>());
      expect((events[0] as UserMessageEvent).id, 'event_001');
      expect(events[1], isA<AgentMessageEvent>());
      expect((events[1] as AgentMessageEvent).id, 'event_002');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events/stream');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('stream sends event_deltas[] and parses preview events', () async {
      mockHttpClient.queueStreamingResponse([
        {
          'type': 'event_start',
          'event': {'type': 'agent.message', 'id': 'event_010'},
        },
        {
          'type': 'event_delta',
          'event_id': 'event_010',
          'delta': {
            'type': 'content_delta',
            'content': {'type': 'text', 'text': 'Hi'},
            'index': 0,
          },
        },
      ]);

      final events = await client.sessions
          .events('session_test123')
          .stream(eventDeltas: ['agent.message', 'agent.thinking'])
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<EventStartEvent>());
      expect(events[1], isA<EventDeltaEvent>());
      expect((events[1] as EventDeltaEvent).eventId, 'event_010');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events/stream');
      expect(request.url.queryParametersAll['event_deltas[]'], [
        'agent.message',
        'agent.thinking',
      ]);
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });
  });

  group('Managed Agents workflow run events', () {
    const beta = 'managed-agents-2026-04-01';
    const timestamp = '2026-10-21T00:00:00Z';
    const workflowError = {
      'type': 'program_error',
      'message': 'A workflow worker failed.',
    };

    Map<String, dynamic> workflowEvent(
      String type,
      Map<String, dynamic> fields,
    ) => {
      'type': 'workflow_run.$type',
      'id': 'event_$type',
      'processed_at': timestamp,
      'workflow_run_id': 'run_01',
      ...fields,
    };

    test(
      'thread retrieval exposes an inline agent without an id or version',
      () async {
        const inline = {
          'type': 'inline',
          'name': 'workflow-reviewer',
          'description': null,
          'model': {'id': 'claude-sonnet-5', 'speed': 'standard'},
          'system': 'Review the supplied draft.',
          'tools': <Map<String, Object?>>[],
          'mcp_servers': <Map<String, Object?>>[],
          'skills': <Map<String, Object?>>[],
          'execution_identity': {'type': 'service_account'},
        };
        mockHttpClient.queueJsonResponse({
          ...ManagedAgentsFixtures.sessionThread(),
          'agent': inline,
          'workflow_run_id': 'run_01',
        });

        final thread = await client.sessions
            .threads('session_test123')
            .retrieve('sthr_test123');
        final agent = thread.agent as SessionInlineAgent;
        expect(agent.name, 'workflow-reviewer');
        expect(agent.model.id, 'claude-sonnet-5');
        expect(
          agent.executionIdentity,
          const AgentExecutionIdentity.serviceAccount(),
        );
        expect(thread.toJson()['agent'], inline);
        expect(agent.copyWith(system: null).system, isNull);
        expect(
          mockHttpClient.lastRequest?.url.path,
          '/v1/sessions/session_test123/threads/sthr_test123',
        );
        expect(mockHttpClient.lastRequest?.headers['anthropic-beta'], beta);
      },
    );

    test(
      'session SSE exposes retrying repository errors and future kinds',
      () async {
        const errors = [
          {
            'type': 'repository_checkout_error',
            'message': 'Could not check out the requested ref.',
            'retry_status': {'type': 'retrying'},
            'repository_url': 'https://github.com/example/test',
          },
          {
            'type': 'compaction_limit_reached_error',
            'message': 'Reached the compaction limit.',
            'retry_status': {'type': 'exhausted'},
          },
          {
            'type': 'future_error',
            'message': 'A new error.',
            'retry_status': {'type': 'new_status', 'backoff_ms': 1000},
            'additional': [1, 2],
          },
        ];
        mockHttpClient.queueStreamingResponse([
          for (final (index, error) in errors.indexed)
            {
              'type': 'session.error',
              'id': 'event_error_$index',
              'processed_at': timestamp,
              'error': error,
            },
        ]);

        final events = await client.sessions
            .events('session_test123')
            .stream()
            .cast<SessionErrorEvent>()
            .toList();
        expect(events.map((event) => event.error), errors);
        final checkout = events[0].errorDetails;
        expect(checkout.kind, SessionErrorKind.repositoryCheckout);
        expect(checkout.repositoryUrl, 'https://github.com/example/test');
        expect(checkout.retryStatus, const RetryStatusRetrying());
        expect(
          events[1].errorDetails.kind,
          SessionErrorKind.compactionLimitReached,
        );
        expect(
          events[1].errorDetails.retryStatus,
          const RetryStatusExhausted(),
        );
        final future = events[2].errorDetails;
        expect(future.type, 'future_error');
        expect(future.kind, SessionErrorKind.unrecognized);
        expect(future.retryStatus, isA<UnknownRetryStatus>());
        expect(future.toJson(), errors.last);
        expect(mockHttpClient.lastRequest?.headers['anthropic-beta'], beta);
      },
    );

    test('session event list decodes the workflow lifecycle', () async {
      final wireEvents = [
        workflowEvent('created', {
          'name': 'Review',
          'description': null,
          'phases': [
            {'id': 'phase_01', 'name': 'Draft', 'description': null},
          ],
        }),
        workflowEvent('status_running', {}),
        workflowEvent('phase_started', {'workflow_run_phase_id': 'phase_01'}),
        workflowEvent('phase_ended', {
          'workflow_run_phase_id': 'phase_01',
          'phase_started_id': 'event_phase_started',
        }),
        workflowEvent('status_idle', {}),
        workflowEvent('status_ended', {
          'result': {'type': 'completed'},
        }),
      ];
      mockHttpClient.queueJsonResponse({
        'data': wireEvents,
        'next_page': 'page_next',
      });

      final response = await client.sessions
          .events('session_test123')
          .list(
            page: 'page_current',
            types: [
              'workflow_run.created',
              'workflow_run.status_running',
              'workflow_run.phase_started',
              'workflow_run.phase_ended',
              'workflow_run.status_idle',
              'workflow_run.status_ended',
            ],
          );
      final events = response.data.cast<WorkflowRunEvent>();
      expect(events.map((event) => event.kind), [
        WorkflowRunEventKind.created,
        WorkflowRunEventKind.running,
        WorkflowRunEventKind.phaseStarted,
        WorkflowRunEventKind.phaseEnded,
        WorkflowRunEventKind.idle,
        WorkflowRunEventKind.ended,
      ]);
      expect(events.first.name, 'Review');
      expect(events.first.workflowRunId, 'run_01');
      expect(events.first.phases?.single.name, 'Draft');
      expect(events[2].workflowRunPhaseId, 'phase_01');
      expect(events[3].phaseStartedId, events[2].id);
      expect(events.last.result?.type, 'completed');
      expect(events.map((event) => event.toJson()), wireEvents);
      expect(response.nextPage, 'page_next');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events');
      expect(request.headers['anthropic-beta'], beta);
      expect(request.url.queryParameters['page'], 'page_current');
      expect(request.url.queryParametersAll['types[]'], [
        'workflow_run.created',
        'workflow_run.status_running',
        'workflow_run.phase_started',
        'workflow_run.phase_ended',
        'workflow_run.status_idle',
        'workflow_run.status_ended',
      ]);
    });

    test('session SSE distinguishes failed starts and ended runs', () async {
      final wireEvents = [
        workflowEvent('error', {
          'workflow_run_id': null,
          'id': 'event_failed_start',
          'error': {
            'type': 'max_workflow_runs_error',
            'message': 'Run limit reached.',
          },
        }),
        workflowEvent('error', {'error': workflowError}),
        workflowEvent('status_ended', {
          'result': {'type': 'error', 'error': workflowError},
        }),
        workflowEvent('status_ended', {
          'workflow_run_id': 'run_future',
          'id': 'event_future_terminal',
          'result': {'type': 'new_terminal_result', 'future_detail': 7},
        }),
        workflowEvent('future_event', {'extra': 'preserved'}),
      ];
      mockHttpClient.queueStreamingResponse(wireEvents);

      final events = await client.sessions
          .events('session_test123')
          .stream()
          .toList();
      expect(events, hasLength(5));
      final first = events[0] as WorkflowRunEvent;
      expect(first.workflowRunId, isNull);
      expect(first.error?.type, 'max_workflow_runs_error');
      expect((events[1] as WorkflowRunEvent).workflowRunId, 'run_01');
      final ended = events[2] as WorkflowRunEvent;
      expect(ended.kind, WorkflowRunEventKind.ended);
      expect(ended.result?.error?.message, 'A workflow worker failed.');
      expect(
        (events[3] as WorkflowRunEvent).result?.type,
        'new_terminal_result',
      );
      expect(events.last, isA<UnknownSessionEvent>());
      expect(events.take(4).map((event) => event.toJson()), wireEvents.take(4));
      expect(events.last.toJson()['extra'], 'preserved');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events/stream');
      expect(request.headers['anthropic-beta'], beta);
    });

    test(
      'thread response and creation event link the owning workflow',
      () async {
        mockHttpClient
          ..queueJsonResponse({
            ...ManagedAgentsFixtures.sessionThread(),
            'workflow_run_id': 'run_01',
          })
          ..queueJsonResponse({
            'data': [
              {
                ...ManagedAgentsFixtures.sessionThreadCreatedEvent(),
                'workflow_run_id': 'run_01',
              },
            ],
            'next_page': null,
          });

        final thread = await client.sessions
            .threads('session_test123')
            .retrieve('sthr_test123');
        expect(thread.workflowRunId, 'run_01');
        expect(thread.toJson()['workflow_run_id'], 'run_01');
        expect(thread.copyWith(workflowRunId: null).workflowRunId, isNull);
        expect(mockHttpClient.lastRequest?.headers['anthropic-beta'], beta);
        final response = await client.sessions.events('session_test123').list();
        final created = response.data.single as SessionThreadCreatedEvent;
        expect(created.workflowRunId, 'run_01');
        expect(created.toJson()['workflow_run_id'], 'run_01');
        expect(created.copyWith(workflowRunId: null).workflowRunId, isNull);
      },
    );

    test('session and thread idle events retain refusal details', () async {
      const details = {
        'type': 'refusal',
        'category': 'future_category',
        'explanation': null,
      };
      mockHttpClient
        ..queueJsonResponse({
          'data': [
            {
              'type': 'session.status_idle',
              'id': 'event_session_idle',
              'processed_at': timestamp,
              'stop_reason': {'type': 'refusal'},
              'stop_details': details,
            },
          ],
          'next_page': null,
        })
        ..queueStreamingResponse([
          {
            'type': 'session.thread_status_idle',
            'id': 'event_thread_idle',
            'processed_at': timestamp,
            'session_thread_id': 'sthr_test123',
            'agent_name': 'Test Agent',
            'stop_reason': {'type': 'refusal'},
            'stop_details': details,
          },
        ]);

      final response = await client.sessions.events('session_test123').list();
      final idle = response.data.single as SessionStatusIdleEvent;
      expect(idle.stopReason, const SessionRefusal());
      expect(idle.stopDetails?.category, 'future_category');
      expect(idle.stopDetails?.explanation, isNull);
      expect(idle.toJson()['stop_details'], details);
      expect(idle.copyWith(stopDetails: null).stopDetails, isNull);

      final events = await client.sessions
          .threads('session_test123')
          .events('sthr_test123')
          .stream()
          .toList();
      final threadIdle = events.single as SessionThreadStatusIdleEvent;
      expect(threadIdle.stopReason, const SessionRefusal());
      expect(threadIdle.stopDetails?.category, 'future_category');
      expect(threadIdle.toJson()['stop_details'], details);
      expect(mockHttpClient.lastRequest?.headers['anthropic-beta'], beta);
    });
  });

  group('SessionThreadsResource', () {
    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.sessionThread());

      final thread = await client.sessions
          .threads('session_test123')
          .retrieve('sthr_test123');

      expect(thread.id, 'sthr_test123');
      expect(thread.sessionId, 'session_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/threads/sthr_test123',
      );
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list sends correct request with query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.sessionThread()],
        'next_page': null,
      });

      final response = await client.sessions
          .threads('session_test123')
          .list(limit: 10, page: 'page_abc');

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/threads');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['limit'], '10');
      expect(request.url.queryParameters['page'], 'page_abc');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('archive sends correct request and parses archived_at', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.sessionThread(),
        'archived_at': '2026-04-01T12:00:00Z',
      });

      final thread = await client.sessions
          .threads('session_test123')
          .archive('sthr_test123');

      expect(thread.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/threads/sthr_test123/archive',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });
  });

  group('SessionThreadEventsResource', () {
    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.sessionThreadCreatedEvent()],
        'next_page': null,
      });

      final response = await client.sessions
          .threads('session_test123')
          .events('sthr_test123')
          .list(limit: 20);

      expect(response.data, hasLength(1));
      expect(response.data.first, isA<SessionThreadCreatedEvent>());

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/threads/sthr_test123/events',
      );
      expect(request.method, 'GET');
      expect(request.url.queryParameters['limit'], '20');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('stream sends correct request and parses SSE events', () async {
      mockHttpClient.queueStreamingResponse([
        ManagedAgentsFixtures.sessionThreadCreatedEvent(),
        {
          'type': 'session.thread_status_running',
          'id': 'event_running',
          'agent_name': 'Test Agent',
          'session_thread_id': 'sthr_test123',
          'processed_at': '2026-04-01T00:00:01Z',
        },
      ]);

      final events = await client.sessions
          .threads('session_test123')
          .events('sthr_test123')
          .stream()
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<SessionThreadCreatedEvent>());
      expect(events[1], isA<SessionThreadStatusRunningEvent>());

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/threads/sthr_test123/stream',
      );
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('stream sends event_deltas[] and parses preview events', () async {
      mockHttpClient.queueStreamingResponse([
        {
          'type': 'event_start',
          'event': {'type': 'agent.message', 'id': 'event_010'},
        },
        {
          'type': 'event_delta',
          'event_id': 'event_010',
          'delta': {
            'type': 'content_delta',
            'content': {'type': 'text', 'text': 'Hi'},
            'index': 0,
          },
        },
      ]);

      final events = await client.sessions
          .threads('session_test123')
          .events('sthr_test123')
          .stream(eventDeltas: ['agent.message', 'agent.thinking'])
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<EventStartEvent>());
      expect(events[1], isA<EventDeltaEvent>());
      expect((events[1] as EventDeltaEvent).eventId, 'event_010');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/threads/sthr_test123/stream',
      );
      expect(request.url.queryParametersAll['event_deltas[]'], [
        'agent.message',
        'agent.thinking',
      ]);
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });
  });

  group('SessionResourcesResource', () {
    test('create sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'file',
        'id': 'res_123',
        'file_id': 'file_abc',
        'mount_path': '/workspace/data.csv',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      });

      final resource = await client.sessions
          .resources('session_test123')
          .create(const FileResourceParams(fileId: 'file_abc'));

      expect(resource, isA<FileResource>());
      expect((resource as FileResource).fileId, 'file_abc');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/resources');
      expect(request.method, 'POST');
    });

    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [
          {
            'type': 'file',
            'id': 'res_123',
            'file_id': 'file_abc',
            'mount_path': '/workspace/data.csv',
            'created_at': '2026-04-01T00:00:00Z',
            'updated_at': '2026-04-01T00:00:00Z',
          },
        ],
      });

      final response = await client.sessions
          .resources('session_test123')
          .list();

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/resources');
      expect(request.method, 'GET');
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'file',
        'id': 'res_123',
        'file_id': 'file_abc',
        'mount_path': '/workspace/data.csv',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      });

      final resource = await client.sessions
          .resources('session_test123')
          .retrieve('res_123');

      expect(resource, isA<FileResource>());
      expect((resource as FileResource).id, 'res_123');
      expect(resource.fileId, 'file_abc');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/resources/res_123',
      );
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'github_repository',
        'id': 'res_456',
        'url': 'https://github.com/example/repo',
        'mount_path': '/workspace/repo',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      });

      final resource = await client.sessions
          .resources('session_test123')
          .update(
            'res_456',
            const UpdateSessionResourceParams(authorizationToken: 'new-token'),
          );

      expect(resource, isA<GitHubRepositoryResource>());
      expect((resource as GitHubRepositoryResource).id, 'res_456');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/resources/res_456',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['authorization_token'], 'new-token');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'res_123',
        'type': 'session_resource_deleted',
      });

      final deleted = await client.sessions
          .resources('session_test123')
          .delete('res_123');

      expect(deleted.id, 'res_123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/resources/res_123',
      );
      expect(request.method, 'DELETE');
    });
  });

  group('VaultsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.vault());

      final vault = await client.vaults.create(
        const CreateVaultParams(displayName: 'Test Vault'),
      );

      expect(vault.id, 'vault_test123');
      expect(vault.displayName, 'Test Vault');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.vault()],
      });

      final response = await client.vaults.list(limit: 10);

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults');
      expect(request.url.queryParameters['limit'], '10');
    });

    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.vault());

      final vault = await client.vaults.retrieve('vault_test123');

      expect(vault.id, 'vault_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        ManagedAgentsFixtures.vault(displayName: 'Updated Vault'),
      );

      final vault = await client.vaults.update(
        'vault_test123',
        const UpdateVaultParams(displayName: 'Updated Vault'),
      );

      expect(vault.id, 'vault_test123');
      expect(vault.displayName, 'Updated Vault');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['display_name'], 'Updated Vault');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'vault_test123',
        'type': 'vault_deleted',
      });

      final deleted = await client.vaults.delete('vault_test123');

      expect(deleted.id, 'vault_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123');
      expect(request.method, 'DELETE');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.vault(),
        'archived_at': '2026-04-01T12:00:00Z',
      });

      final vault = await client.vaults.archive('vault_test123');

      expect(vault.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123/archive');
      expect(request.method, 'POST');
    });
  });

  group('VaultCredentialsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      final credential = await client.vaults
          .credentials('vault_test123')
          .create(
            const CreateCredentialParams(
              auth: StaticBearerCreateParams(
                token: 'secret-token',
                mcpServerUrl: 'https://mcp.example.com',
              ),
            ),
          );

      expect(credential.id, 'cred_test123');
      expect(credential.vaultId, 'vault_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123/credentials');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.credential()],
      });

      final response = await client.vaults.credentials('vault_test123').list();

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123/credentials');
      expect(request.method, 'GET');
    });

    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      final credential = await client.vaults
          .credentials('vault_test123')
          .retrieve('cred_test123');

      expect(credential.id, 'cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123',
      );
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      final credential = await client.vaults
          .credentials('vault_test123')
          .update(
            'cred_test123',
            const UpdateCredentialParams(displayName: 'Updated Credential'),
          );

      expect(credential.id, 'cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['display_name'], 'Updated Credential');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'cred_test123',
        'type': 'vault_credential_deleted',
      });

      final deleted = await client.vaults
          .credentials('vault_test123')
          .delete('cred_test123');

      expect(deleted.id, 'cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123',
      );
      expect(request.method, 'DELETE');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      await client.vaults.credentials('vault_test123').archive('cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123/archive',
      );
      expect(request.method, 'POST');
    });

    test(
      'validateCredential sends correct request and parses response',
      () async {
        mockHttpClient.queueJsonResponse(
          ManagedAgentsFixtures.credentialValidation(),
        );

        final validation = await client.vaults
            .credentials('vault_test123')
            .validateCredential('cred_test123');

        // Parses the typed result.
        expect(validation.credentialId, 'cred_test123');
        expect(validation.vaultId, 'vault_test123');
        expect(validation.status, CredentialValidationStatus.valid);
        expect(validation.mcpProbe, isA<McpProbe>());

        // The unit test is the real gate for this endpoint (verify is blind to
        // it): assert path, method, beta header, and empty body.
        final request = mockHttpClient.lastRequest!;
        expect(
          request.url.path,
          '/v1/vaults/vault_test123/credentials/cred_test123/mcp_oauth_validate',
        );
        expect(request.method, 'POST');
        expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
        final body =
            jsonDecode((request as dynamic).body) as Map<String, dynamic>;
        expect(body, isEmpty);
      },
    );
  });

  group('UnknownManagedAgentError', () {
    test('fromJson parses type, message, and retryStatus', () {
      final json = {
        'type': 'unknown_error',
        'message': 'Something went wrong',
        'retry_status': {
          'type': 'retrying',
          'retry_at': '2026-04-01T00:01:00Z',
        },
      };

      final error = UnknownManagedAgentError.fromJson(json);

      expect(error.type, 'unknown_error');
      expect(error.message, 'Something went wrong');
      expect(error.retryStatus, isA<RetryStatusRetrying>());
      expect(error.rawJson, json);
    });

    test('toJson round-trips correctly', () {
      final json = {
        'type': 'unknown_error',
        'message': 'Something went wrong',
        'retry_status': {
          'type': 'retrying',
          'retry_at': '2026-04-01T00:01:00Z',
        },
      };

      final error = UnknownManagedAgentError.fromJson(json);
      final output = error.toJson();

      expect(output['type'], 'unknown_error');
      expect(output['message'], 'Something went wrong');
      expect(output['retry_status'], isA<Map<String, dynamic>>());
    });

    test('toJson preserves retry_status fields like retry_at', () {
      final json = {
        'type': 'unknown_error',
        'message': 'Retrying',
        'retry_status': {
          'type': 'retrying',
          'retry_at': '2026-04-01T00:01:00Z',
        },
      };

      final error = UnknownManagedAgentError.fromJson(json);
      final output = error.toJson();

      // retry_status must preserve retry_at — the parsed RetryStatusRetrying
      // only stores 'type', so rawJson is used verbatim.
      final retryStatus = output['retry_status'] as Map<String, dynamic>;
      expect(retryStatus['type'], 'retrying');
      expect(retryStatus['retry_at'], '2026-04-01T00:01:00Z');
    });

    test('toJson reflects copyWith retryStatus while preserving retry_at', () {
      final json = {
        'type': 'unknown_error',
        'message': 'Retrying',
        'retry_status': {
          'type': 'retrying',
          'retry_at': '2026-04-01T00:01:00Z',
        },
      };

      final error = UnknownManagedAgentError.fromJson(json);
      final modified = error.copyWith(retryStatus: const RetryStatusTerminal());
      final output = modified.toJson();

      // The merged retry_status should reflect the new type from copyWith
      // while preserving retry_at from the original rawJson.
      final retryStatus = output['retry_status'] as Map<String, dynamic>;
      expect(retryStatus['type'], 'terminal');
      expect(retryStatus['retry_at'], '2026-04-01T00:01:00Z');
    });

    test('toJson preserves unknown fields from rawJson', () {
      final json = {
        'type': 'unknown_error',
        'message': 'Error',
        'retry_status': {'type': 'terminal'},
        'extra_field': 'preserved',
      };

      final error = UnknownManagedAgentError.fromJson(json);
      final output = error.toJson();

      expect(output['extra_field'], 'preserved');
    });

    test('copyWith creates modified copy', () {
      final error = UnknownManagedAgentError(
        message: 'original',
        retryStatus: const RetryStatusTerminal(),
      );
      final modified = error.copyWith(message: 'updated');

      expect(modified.message, 'updated');
      expect(modified.retryStatus, isA<RetryStatusTerminal>());
      expect(error.message, 'original');
    });

    test('equality includes type and retryStatus', () {
      final a = UnknownManagedAgentError(
        message: 'error',
        retryStatus: const RetryStatusTerminal(),
      );
      final b = UnknownManagedAgentError(
        message: 'error',
        retryStatus: const RetryStatusTerminal(),
      );
      final c = UnknownManagedAgentError(
        message: 'different',
        retryStatus: const RetryStatusTerminal(),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
