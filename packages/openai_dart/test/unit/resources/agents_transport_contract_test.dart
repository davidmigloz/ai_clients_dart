import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_resource_fixtures.dart';

void main() {
  final previousHierarchy = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = previousHierarchy);

  for (final operation in ['create', 'list', 'retrieve', 'update', 'delete']) {
    test(
      '$operation captures caller options before asynchronous suspension',
      () async {
        final requests = <http.Request>[];
        final transport = MockClient((request) async {
          requests.add(request);
          return _json(switch (operation) {
            'list' => emptyAgentPageWire(),
            'delete' => {
              'id': 'agent',
              'object': 'agent.deleted',
              'deleted': true,
            },
            _ => savedAgentWire(),
          }, operation == 'create' ? 201 : 200);
        });
        final client = OpenAIClient.withApiKey(
          'synthetic-agents-options',
          httpClient: transport,
        );
        addTearDown(() {
          client.close();
          transport.close();
        });
        final headers = {
          'X-Captured': 'at-call',
          'oPeNaI-bEtA': 'caller-invalid',
        };
        final pending = _call(client, operation, headers);
        headers['X-Captured'] = 'mutated-after-call';
        headers.clear();
        await pending;
        expect(requests.single.headers['x-captured'], 'at-call');
        expect(requests.single.headers['openai-beta'], 'agents=v1');
      },
    );
  }

  test(
    'Conflicting provider/default/caller headers preserve beta and Unicode UTF-8',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((request) async {
        requests.add(request);
        return _json(savedAgentWire(), 201);
      });
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: _ConflictingAuth(),
          defaultHeaders: const {
            'oPeNaI-bEtA': 'default-invalid',
            'Content-Type': 'text/plain; charset=iso-8859-1',
          },
        ),
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      const privateUnicode = 'PRIVATE instructions café 🚀';
      await client.agents.create(
        CreateAgentRequest(
          model: 'requested-model',
          instructions: privateUnicode,
        ),
        additionalHeaders: {
          'OpEnAi-BeTa': 'caller-invalid',
          'CONTENT-TYPE': 'application/json; charset=iso-8859-1',
          'ACCEPT': 'caller-invalid',
        },
      );
      final request = requests.single;
      expect(request.headers['openai-beta'], 'agents=v1');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['content-type'], contains('utf-8'));
      expect(
        (jsonDecode(utf8.decode(request.bodyBytes)) as Map)['instructions'],
        privateUnicode,
      );
    },
  );

  test(
    'DELETE opaque ID agents uses private errors, headers, IDs and URL logging',
    () async {
      const marker = 'PRIVATE-collision';
      final records = <String>[];
      final subscription = Logger.root.onRecord.listen(
        (record) => records.add('${record.message} ${record.error ?? ''}'),
      );
      addTearDown(subscription.cancel);
      final transport = MockClient(
        (request) async => _json({
          'error': {
            'message': marker,
            'code': marker,
            'type': marker,
            'param': marker,
          },
        }, 403),
      );
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/v1?token=$marker',
          authProvider: ApiKeyProvider('synthetic-agents-collision'),
          logLevel: Level.ALL,
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      await expectLater(
        client.agents.delete(
          'agents',
          additionalHeaders: {
            'X-Request-ID': marker,
            'X-Private-Header': marker,
          },
        ),
        throwsA(
          isA<PermissionDeniedException>().having(
            (error) => error.toString(),
            'private errors',
            isNot(contains(marker)),
          ),
        ),
      );
      expect(records, isNotEmpty);
      expect(records.join('\n'), isNot(contains(marker)));
      expect(records.join('\n'), isNot(contains('synthetic-agents-collision')));
    },
  );

  test(
    'Exported create/update sends all persisted tools and both MCP transports',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((request) async {
        requests.add(request);
        return _json(savedAgentWire(), requests.length == 1 ? 201 : 200);
      });
      final client = OpenAIClient.withApiKey(
        'synthetic-agents-full',
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final tools = <AgentTool>[
        AgentTool.function(
          name: 'lookup',
          description: 'description',
          parameters: const {'type': 'object'},
          deferLoading: false,
        ),
        const AgentTool.toolSearch(),
        AgentTool.programmaticToolCalling(enabled: false),
        AgentTool.computerUse(includeScreenshots: false),
        AgentTool.webSearch(
          mode: AgentWebSearchModeParam.cached,
          contextSize: AgentWebSearchContextSizeParam.low,
          location: AgentWebSearchLocation(country: 'US', timezone: 'UTC'),
          allowedDomains: const ['fixture.invalid'],
        ),
        AgentTool.mcp(
          serverLabel: 'http',
          transport: AgentMcpTransport.http(
            serverUrl: 'https://mcp.fixture.invalid',
            headers: const {'X-Application': 'test'},
          ),
          connectionOrigin: AgentMcpConnectionOriginParam.environment,
          requestMetadata: const {
            'nested': [false, null],
          },
          allowedTools: const ['lookup'],
          credentialId: 'credential-fixture',
          required: true,
        ),
        AgentTool.mcp(
          serverLabel: 'stdio',
          transport: AgentMcpTransport.stdio(
            command: 'synthetic-command',
            cwd: '/synthetic',
            args: const ['--fixture'],
            envVars: const ['SYNTHETIC_VAR'],
          ),
        ),
      ];
      await client.agents.create(
        CreateAgentRequest(
          model: 'requested-model',
          tools: tools,
          reasoning: AgentReasoningConfig(
            effort: AgentReasoningEffortParam.max,
            summary: AgentReasoningSummaryParam.detailed,
          ),
          serviceTier: AgentServiceTierParam.fast,
          text: AgentTextConfig(
            format: AgentTextFormat.jsonSchema(
              schema: const {'type': 'object'},
            ),
            verbosity: AgentVerbosityParam.high,
          ),
          multiAgent: AgentMultiAgentConfig(
            enabled: false,
            maxConcurrentSubagents: 6,
          ),
        ),
      );
      final created = jsonDecode(requests.single.body) as Map<String, dynamic>;
      final wireTools = created['tools'] as List<dynamic>;
      expect(wireTools.map((dynamic value) => (value as Map)['type']), [
        'function',
        'tool_search',
        'programmatic_tool_calling',
        'computer_use',
        'web_search',
        'mcp',
        'mcp',
      ]);
      expect((wireTools[5] as Map)['transport'], {
        'type': 'http',
        'server_url': 'https://mcp.fixture.invalid',
        'headers': {'X-Application': 'test'},
      });
      expect((wireTools[6] as Map)['transport'], {
        'type': 'stdio',
        'command': 'synthetic-command',
        'cwd': '/synthetic',
        'args': ['--fixture'],
        'env_vars': ['SYNTHETIC_VAR'],
      });
      expect(created['reasoning'], {'effort': 'max', 'summary': 'detailed'});
      expect(created['text'], {
        'format': {
          'type': 'json_schema',
          'schema': {'type': 'object'},
        },
        'verbosity': 'high',
      });
      expect(created['service_tier'], 'fast');
      await client.agents.update(
        'agent',
        UpdateAgentRequest(
          model: 'literal-updated-model',
          tools: tools,
          clearName: true,
          clearInstructions: true,
          clearMetadata: true,
          clearReasoning: true,
          clearText: true,
          clearServiceTier: true,
          clearMultiAgent: true,
        ),
      );
      final updated = jsonDecode(requests.last.body) as Map<String, dynamic>;
      expect(updated['tools'], wireTools);
      expect(updated['model'], 'literal-updated-model');
      for (final key in [
        'name',
        'instructions',
        'metadata',
        'reasoning',
        'text',
        'service_tier',
        'multi_agent',
      ]) {
        expect(updated.containsKey(key), true);
        expect(updated[key], null);
      }
    },
  );
}

Future<Object> _call(
  OpenAIClient client,
  String operation,
  Map<String, String> headers,
) => switch (operation) {
  'create' => client.agents.create(
    CreateAgentRequest(model: 'model'),
    additionalHeaders: headers,
  ),
  'list' => client.agents.list(additionalHeaders: headers),
  'retrieve' => client.agents.retrieve('agent', additionalHeaders: headers),
  'update' => client.agents.update(
    'agent',
    UpdateAgentRequest(clearName: true),
    additionalHeaders: headers,
  ),
  'delete' => client.agents.delete('agent', additionalHeaders: headers),
  _ => throw StateError('Unknown test operation'),
};

http.Response _json(Map<String, dynamic> body, [int status = 200]) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

class _ConflictingAuth implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer synthetic-agents-charset',
    'oPeNaI-bEtA': 'provider-invalid',
    'AcCePt': 'provider-invalid',
    'cOnTeNt-TyPe': 'text/plain; charset=iso-8859-1',
  };
}
