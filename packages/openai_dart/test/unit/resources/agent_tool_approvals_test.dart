import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_resource_fixtures.dart';
import '../fixtures/agent_session_wire_fixtures.dart';

const _function = <String, dynamic>{
  'type': 'function',
  'name': 'fixture',
  'description': 'Local fixture function',
  'parameters': {'type': 'object'},
};

void main() {
  test(
    'function policies preserve false, true and omission on all wire owners',
    () {
      final functions = <AgentJsonModel Function(Map<String, dynamic>)>[
        AgentFunctionTool.fromJson,
        AgentFunctionToolResource.fromJson,
        AgentSessionFunctionTool.fromJson,
        AgentSessionFunctionToolResource.fromJson,
      ];
      for (var i = 0; i < functions.length; i++) {
        final parse = functions[i];
        final wire = {..._function, if (i.isOdd) 'defer_loading': false};
        expect(parse(wire).toJson(), wire);
        for (final enabled in [false, true]) {
          final json = {...wire, 'async': enabled};
          final value = parse(json);
          expect(value.toJson(), json);
          expect(parse(json).hashCode, value.hashCode);
          expect(value, isNot(parse(wire)));
          final cleared = switch (value) {
            final AgentFunctionTool tool => tool.copyWith(async: null),
            final AgentFunctionToolResource tool => tool.copyWith(async: null),
            final AgentSessionFunctionTool tool => tool.copyWith(async: null),
            final AgentSessionFunctionToolResource tool => tool.copyWith(
              async: null,
            ),
            _ => fail('Unexpected fixture result'),
          };
          expect(cleared.toJson(), wire);
        }
        for (final bad in [null, 'true', 1]) {
          expect(() => parse({...wire, 'async': bad}), throwsFormatException);
        }
      }
    },
  );

  test(
    'saved and inline Agent endpoints send and decode asynchronous tools',
    () async {
      final bodies = <Map<String, dynamic>>[];
      final client = _client((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        bodies.add(body);
        final isSession = request.url.pathSegments.contains('sessions');
        final owner = isSession ? body['agent'] as Map<String, dynamic> : body;
        final tool =
            (owner['tools'] as List<dynamic>).single as Map<String, dynamic>;
        final resolvedTool = {...tool, 'defer_loading': false};
        final created = request.url.path.endsWith(
          isSession ? '/sessions' : '/agents',
        );
        if (isSession) {
          final session = _session();
          (session['agent'] as Map<String, dynamic>)['tools'] = [resolvedTool];
          return _json(session, created ? 201 : 200);
        }
        return _json({
          ...savedAgentWire(),
          'tools': [resolvedTool],
        }, created ? 201 : 200);
      });
      final agents = client.agents;
      final savedTool = AgentTool.function(
        async: true,
        name: 'fixture',
        description: 'Local fixture function',
        parameters: const {'type': 'object'},
      );
      final saved = await agents.create(
        CreateAgentRequest(model: 'fixture', tools: [savedTool]),
      );
      expect((saved.tools.single as AgentFunctionToolResource).async, isTrue);
      final savedUpdated = await agents.update(
        saved.id,
        UpdateAgentRequest(tools: [savedTool]),
      );
      expect(
        (savedUpdated.tools.single as AgentFunctionToolResource).async,
        isTrue,
      );

      final inlineTool = AgentSessionTool.function(
        async: false,
        name: 'fixture',
        description: 'Local fixture function',
        parameters: const {'type': 'object'},
      );
      final session = await agents.sessions.create(
        _create().copyWith(
          agent: AgentSessionAgentConfig(model: 'fixture', tools: [inlineTool]),
        ),
      );
      expect(
        (session.agent.tools.single as AgentSessionFunctionToolResource).async,
        isFalse,
      );
      final sessionUpdated = await agents.sessions.update(
        session.id,
        UpdateAgentSessionRequest(
          agent: AgentSessionAgentUpdate(tools: [inlineTool]),
        ),
      );
      expect(
        (sessionUpdated.agent.tools.single as AgentSessionFunctionToolResource)
            .async,
        isFalse,
      );
      expect((bodies.first['tools'] as List<dynamic>).single, {
        ..._function,
        'async': true,
      });
      expect(
        ((bodies.last['agent'] as Map<String, dynamic>)['tools']
                as List<dynamic>)
            .single,
        {..._function, 'async': false},
      );
    },
  );

  test(
    'new-session automation targets preserve the async tool field',
    () async {
      final client = _client((request) async {
        expect(request.url.path, '/v1/agents/automations');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final targets = body['target'] as Map<String, dynamic>;
        final agent = targets['agent'] as Map<String, dynamic>;
        final tool =
            (agent['tools'] as List<dynamic>).single as Map<String, dynamic>;
        expect(tool, {..._function, 'async': true});
        final resolvedAgent = savedAgentWire()
          ..remove('id')
          ..remove('object')
          ..remove('created_at')
          ..remove('updated_at')
          ..remove('metadata')
          ..['tools'] = [
            {...tool, 'defer_loading': false},
          ];
        return _json({
          ...body,
          'id': 'automation',
          'object': 'agent.automation',
          'created_at': 1,
          'created_by': {'type': 'developer'},
          'metadata': <String, String>{},
          'status': 'active',
          'target': {
            ...targets,
            'agent_id': null,
            'agent': resolvedAgent,
            'vault_ids': <String>[],
            'metadata': <String, String>{},
          },
        }, 201);
      });
      final schedule = await client.agents.automations.create(
        CreateAgentAutomationRequest.once(
          name: 'fixture',
          runAt: 2000000000,
          target: AgentAutomationNewSessionTarget(
            agent: AgentSessionAgentConfig(
              model: 'fixture',
              tools: [
                AgentSessionFunctionTool.fromJson(const {
                  ..._function,
                  'async': true,
                }),
              ],
            ),
            environment: AgentSessionEnvironment.none(),
            input: const [],
          ),
        ),
      );
      final target = schedule.target as AgentAutomationNewSessionTargetResource;
      final tool =
          target.agent!.tools.single as AgentSessionFunctionToolResource;
      expect(tool.async, isTrue);
    },
  );

  test(
    'MCP approval payloads keep required nullable JSON and detached extras',
    () {
      final args = <String, dynamic>{
        'fixture': ['value'],
      };
      final wire = _approvalRequest(args);
      final request = AgentSessionMcpApprovalRequest.fromJson(wire);
      (args['fixture']! as List<String>).clear();
      expect(request.name, isNull);
      expect(request.arguments, {
        'fixture': ['value'],
      });
      expect(
        () => (request.arguments! as Map<String, dynamic>)['new'] = false,
        throwsUnsupportedError,
      );
      final nil = request.copyWith(arguments: null);
      expect(nil.toJson(), containsPair('arguments', null));
      expect(nil.toJson(), containsPair('name', null));
      expect(nil.rawJson, containsPair('future', true));
      expect(AgentSessionMcpApprovalRequest.fromJson(nil.toJson()), nil);
      expect(
        AgentSessionMcpApprovalRequest.fromJson(nil.toJson()).hashCode,
        nil.hashCode,
      );
      for (final field in ['name', 'arguments']) {
        expect(
          () => AgentSessionMcpApprovalRequest.fromJson(
            Map<String, dynamic>.of(wire)..remove(field),
          ),
          throwsFormatException,
        );
      }
      expect(request.toString(), isNot(contains('Fixture details')));
      expect(
        () => AgentSessionMcpApprovalResponse.fromJson(const {
          'type': 'mcp_tool_call',
          'decision': 'future',
        }),
        throwsFormatException,
      );
    },
  );

  test('raw session observation and POST use explicit MCP approvals', () async {
    final client = _client((request) async {
      expect(request.url.path, '/v1/agents/sessions/session/events');
      if (request.method == 'GET') return _sse([_requiresAction()]);
      final decision = request.headers['idempotency-key'];
      expect(jsonDecode(request.body), {
        'events': [
          {
            'type': 'agent.session.input.mcp_approval_request_result',
            'request_id': 'approval',
            'response': {'type': 'mcp_tool_call', 'decision': decision},
          },
        ],
      });
      return http.Response('', 202);
    });
    final events = client.agents.sessions.events;
    final notification =
        await events.stream('session').single
            as AgentSessionRequiresActionEvent;
    final action =
        notification.session.requiredActions.single
            as AgentSessionMcpApprovalRequiredAction;
    expect(action.request.name, isNull);
    expect(action.request.arguments, isNull);
    expect(action.turnId, 'turn');
    expect(action.copyWith(), action);
    for (final decision in AgentSessionMcpApprovalDecision.values) {
      final result = AgentSessionInput.mcpApprovalRequestResult(
        requestId: action.requestId,
        response: AgentSessionMcpApprovalResponse(decision: decision),
      );
      expect(AgentSessionInput.fromJson(result.toJson()), result);
      expect(
        AgentSessionInput.fromJson(result.toJson()).hashCode,
        result.hashCode,
      );
      await events.create(
        'session',
        CreateAgentSessionEventsRequest(events: [result]),
        idempotencyKey: decision.toJson(),
      );
    }
  });

  test('managed run reports MCP approval for application handling', () async {
    var calls = 0;
    var callbacks = 0;
    final client = _client((request) async {
      expect(++calls, 1);
      expect(request.url.path, '/v1/agents/sessions');
      return _sse([
        {
          'type': 'agent.session.created',
          'event_id': 'created',
          'session': _session(),
        },
        _requiresAction(),
      ], 201);
    });
    final run = client.agents.sessions.createRun(
      _create(),
      toolHandlers: {
        'fixture': (_) {
          callbacks++;
          return null;
        },
      },
    );
    await expectLater(
      run.finalResult(),
      throwsA(
        isA<AgentSessionRunResultException>()
            .having(
              (e) => e.reason,
              'reason',
              AgentSessionRunResultReason.requiresAction,
            )
            .having(
              (e) => e.requiredActions.single,
              'action',
              isA<AgentSessionMcpApprovalRequiredAction>(),
            ),
      ),
    );
    expect(callbacks, 0);
    expect(calls, 1);
  });

  test(
    'signed action webhook leads to session retrieval for approval details',
    () async {
      const wire = <String, dynamic>{
        'id': 'event',
        'object': 'event',
        'created_at': 1,
        'type': 'agent.session.action_required',
        'data': {
          'id': 'session',
          'required_action': {'type': 'mcp_approval_request'},
        },
      };
      final client = _client((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/agents/sessions/session');
        expect(request.headers['openai-beta'], 'agents=v1');
        return _json(_requiresAction()['session'] as Map<String, dynamic>);
      });
      final body = jsonEncode(wire);
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final key = utf8.encode('local fixture signing key');
      final signature = base64.encode(
        Hmac(
          sha256,
          key,
        ).convert(utf8.encode('delivery.$timestamp.$body')).bytes,
      );
      final event =
          client.webhooks.unwrap(body, {
                'webhook-id': 'delivery',
                'webhook-timestamp': '$timestamp',
                'webhook-signature': 'v1,$signature',
              }, secret: 'whsec_${base64.encode(key)}')
              as AgentSessionActionRequiredWebhookEvent;
      expect(event.data.id, 'session');
      expect(
        event.data.requiredAction.type,
        AgentSessionRequiredActionTypeResource.mcpApprovalRequest,
      );
      expect(event.toJson(), wire);
      final session = await client.agents.sessions.retrieve(event.data.id);
      final action =
          session.requiredActions.single
              as AgentSessionMcpApprovalRequiredAction;
      expect(action.requestId, 'approval');
      expect(action.request.serverLabel, 'fixture');
      expect(action.request.message, 'Fixture details');
      expect(
        AgentSessionRequiredActionTypeResource.computerUseApprovalRequest.index,
        0,
      );
      expect(AgentSessionRequiredActionTypeResource.functionCall.index, 1);
      expect(
        AgentSessionRequiredActionTypeResource.environmentConnection.index,
        2,
      );
    },
  );
}

CreateAgentSessionRequest _create() => CreateAgentSessionRequest(
  agent: AgentSessionAgentConfig(model: 'fixture'),
  environment: AgentSessionEnvironment.none(),
  input: AgentSessionInitialInput.text('Local fixture'),
);

Map<String, dynamic> _session() {
  final fixture = agentSessionWireFixtures.singleWhere(
    (fixture) => fixture.schema == 'SessionResource',
  );
  return (jsonDecode(jsonEncode(fixture.minimal)) as Map<String, dynamic>)
    ..['id'] = 'session';
}

Map<String, dynamic> _approvalRequest(Object? arguments) => {
  'type': 'mcp_tool_call',
  'server_label': 'fixture',
  'name': null,
  'arguments': arguments,
  'message': 'Fixture details',
  'future': true,
};

Map<String, dynamic> _requiresAction() => {
  'type': 'agent.session.requires_action',
  'event_id': 'required-action',
  'session': {
    ..._session(),
    'status': 'requires_action',
    'required_actions': [
      {
        'type': 'mcp_approval_request',
        'request_id': 'approval',
        'turn_id': 'turn',
        'request': _approvalRequest(null),
      },
    ],
  },
};

http.Response _sse(List<Map<String, dynamic>> events, [int status = 200]) =>
    http.Response(
      events.map((event) => 'data: ${jsonEncode(event)}\n\n').join(),
      status,
      headers: const {'content-type': 'text/event-stream'},
    );

http.Response _json(Map<String, dynamic> json, [int status = 200]) =>
    http.Response(
      jsonEncode(json),
      status,
      headers: const {'content-type': 'application/json'},
    );

OpenAIClient _client(Future<http.Response> Function(http.Request) handle) {
  final transport = MockClient(handle);
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://fixture.invalid/v1',
      authProvider: ApiKeyProvider('fixture'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}
