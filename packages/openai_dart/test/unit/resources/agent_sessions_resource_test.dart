import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_wire_fixtures.dart';

Map<String, dynamic> _wire(String name, {bool minimal = false}) {
  final fixture = agentSessionWireFixtures.singleWhere((f) => f.schema == name);
  return jsonDecode(jsonEncode(minimal ? fixture.minimal : fixture.full))
      as Map<String, dynamic>;
}

CreateAgentSessionRequest _create() => CreateAgentSessionRequest(
  agent: AgentSessionAgentConfig(model: 'literal-model'),
  environment: AgentSessionEnvironment.none(),
  input: AgentSessionInitialInput.text('PRIVATE café🚀'),
);
http.Response _json(Object? body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test(
    'All seven operations through exported client, exact paths, media and bodies',
    () async {
      final transport = _FixtureTransport();
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/v1',
          authProvider: ApiKeyProvider('synthetic'),
          organization: 'org-fixture',
          project: 'proj-fixture',
        ),
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final sessions = client.agents.sessions;
      expect(identical(sessions, client.agents.sessions), isTrue);
      final headers = {'X-Captured': 'at-call', 'oPeNaI-bEtA': 'wrong'};
      final pending = sessions.create(_create(), additionalHeaders: headers);
      headers.clear();
      final created = await pending;
      expect(created.toJson(), _wire('SessionResource'));
      expect(transport.requests.single.headers['x-captured'], 'at-call');
      expect(
        jsonDecode(utf8.decode(transport.requests.single.bodyBytes)),
        _create().toJson(),
      );
      const id = 'session/%2F?🚀';
      final streamed = await sessions.createStream(_create()).toList();
      final observed = await sessions.events.stream(id).toList();
      expect(streamed, hasLength(33));
      expect(observed, hasLength(33));
      expect(observed.map((e) => e.type).toSet(), hasLength(33));
      final before = transport.requests.length;
      await sessions.events.stream(id).take(2).toList();
      expect(transport.requests, hasLength(before + 1));
      expect(transport.requests.where((r) => r.method == 'DELETE'), isEmpty);
      for (final name in [
        'SessionInputParamAgentSessionInputMessage',
        'SessionInputParamAgentSessionInputToolResult',
        'SessionInputParamAgentSessionInputComputerUseApprovalRequestResult',
        'SessionInputParamAgentSessionInputCancel',
      ]) {
        final input = AgentSessionInput.fromJson(_wire(name));
        await sessions.events.create(
          id,
          CreateAgentSessionEventsRequest(events: [input]),
          idempotencyKey: 'input-🚀-$name',
        );
        expect(jsonDecode(utf8.decode(transport.requests.last.bodyBytes)), {
          'events': [input.toJson()],
        });
      }
      for (final response in <AgentSessionComputerUseApprovalResponse>[
        AgentSessionBrowserAuthenticationResponse.cancel(),
        AgentSessionBrowserAuthenticationResponse.submit(
          fields: [
            AgentSessionBrowserAuthenticationFieldValue(
              fieldId: 'field',
              value: 'PRIVATE',
            ),
          ],
          selectedOption: 'option',
        ),
        AgentSessionComputerUseApprovalResponse.browserOriginAccess(
          decision: AgentSessionBrowserOriginAccessDecision.approve,
        ),
      ]) {
        await sessions.events.create(
          id,
          CreateAgentSessionEventsRequest(
            events: [
              AgentSessionInput.computerUseApprovalRequestResult(
                requestId: 'request',
                response: response,
              ),
            ],
          ),
        );
      }
      final page = await sessions.list(
        limit: 100,
        order: AgentListOrder.asc,
        after: 'after/🚀',
        agentId: 'agent/🚀',
      );
      expect(page.toJson(), _wire('SessionListResource'));
      expect(transport.requests.last.url.queryParameters, {
        'limit': '100',
        'order': 'asc',
        'after': 'after/🚀',
        'agent_id': 'agent/🚀',
      });
      await sessions.retrieve(id);
      for (final request in [
        UpdateAgentSessionRequest(),
        UpdateAgentSessionRequest(clearSpendControl: true, clearMetadata: true),
        UpdateAgentSessionRequest(
          spendControl: AgentSessionSpendControlConfig(limit: null),
        ),
        UpdateAgentSessionRequest(
          spendControl: AgentSessionSpendControlConfig(limit: 4503599627370495),
        ),
      ]) {
        await sessions.update(id, request);
        expect(
          jsonDecode(utf8.decode(transport.requests.last.bodyBytes)),
          request.toJson(),
        );
      }
      await sessions.delete(id);
      for (final request in transport.requests) {
        expect(request.headers['openai-beta'], 'agents=v1');
        expect(request.headers['authorization'], 'Bearer synthetic');
        expect(request.headers['openai-project'], 'proj-fixture');
        expect(request.headers['openai-organization'], 'org-fixture');
        if (request.url.path.endsWith('/events')) {
          expect(
            request.url.pathSegments[request.url.pathSegments.length - 2],
            id,
          );
          expect(request.url.queryParameters, isEmpty);
        }
        if (request.bodyBytes.isNotEmpty) {
          expect(request.headers['content-type'], contains('utf-8'));
        }
      }
      expect(transport.closed, 0);
      expect(transport.streamsCancelled, 3);
    },
  );

  test(
    'JSON/stream creation conflicting flags and invalid IDs fail before dispatch',
    () {
      final transport = _FixtureTransport();
      final client = OpenAIClient.withApiKey(
        'synthetic',
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      expect(
        () => client.agents.sessions.create(_create().copyWith(stream: true)),
        throwsFormatException,
      );
      expect(
        () => client.agents.sessions.createStream(
          CreateAgentSessionRequest(
            agentId: 'saved',
            environment: AgentSessionEnvironment.openaiHosted(),
          ),
        ),
        throwsFormatException,
      );
      for (final id in ['', '.', '..']) {
        expect(
          () => client.agents.sessions.retrieve(id),
          throwsFormatException,
        );
      }
      expect(
        () => client.agents.sessions.list(limit: 0),
        throwsFormatException,
      );
      expect(transport.requests, isEmpty);
      client.close();
      expect(() => client.agents.sessions, throwsStateError);
    },
  );

  test(
    'Forced beta/UTF-8 and actual caller idempotency precedence across auth refresh',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((r) async {
        requests.add(r);
        return http.Response('', 202);
      });
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: _ConflictingAuth(),
          defaultHeaders: const {
            'oPeNaI-bEtA': 'wrong',
            'IDEMPOTENCY-KEY': 'default',
            'Content-Type': 'text/plain; charset=iso-8859-1',
          },
        ),
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final request = CreateAgentSessionEventsRequest(
        events: [
          AgentSessionInput.message(
            input: [
              AgentSessionInputMessage(
                content: [AgentSessionInputContent.inputText(text: 'café🚀')],
              ),
            ],
          ),
        ],
      );
      final headers = {
        'Idempotency-Key': 'caller',
        'oPeNaI-bEtA': 'wrong',
        'ACCEPT': 'wrong',
      };
      final pending = client.agents.sessions.events.create(
        'events',
        request,
        additionalHeaders: headers,
      );
      headers.clear();
      await pending;
      await client.agents.sessions.events.create(
        'events',
        request,
        idempotencyKey: 'typed-🚀',
        additionalHeaders: {'idempotency-key': 'caller'},
      );
      expect(requests[0].headers['idempotency-key'], 'caller');
      expect(requests[1].headers['idempotency-key'], 'typed-🚀');
      for (final r in requests) {
        expect(r.headers['openai-beta'], 'agents=v1');
        expect(r.headers['accept'], 'application/json');
        expect(r.headers['content-type'], contains('utf-8'));
        expect(jsonDecode(utf8.decode(r.bodyBytes)), request.toJson());
      }
      for (final key in ['', '🚀' * 257]) {
        expect(
          () => client.agents.sessions.events.create(
            'session',
            request,
            idempotencyKey: key,
          ),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'Authentication values never retry physically or appear in default errors/logs',
    () async {
      final previous = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      final records = <String>[];
      final logging = Logger.root.onRecord.listen(
        (r) => records.add('${r.message} ${r.error ?? ''}'),
      );
      addTearDown(() async {
        await logging.cancel();
        hierarchicalLoggingEnabled = previous;
      });
      var physical = 0;
      final retry = _Repeat();
      final transport = MockClient((r) async {
        physical++;
        return _json({
          'error': {
            'message': 'PRIVATE',
            'type': 'PRIVATE',
            'code': 'PRIVATE',
            'param': 'PRIVATE',
          },
        }, 503);
      });
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/v1?token=PRIVATE',
          authProvider: ApiKeyProvider('PRIVATE'),
          logLevel: Level.ALL,
          retryPolicy: RetryPolicy(
            maxRetries: 3,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
          ),
        ),
        httpClient: transport,
      );
      client.interceptorChain.interceptors.insert(0, retry);
      addTearDown(() {
        client.close();
        transport.close();
      });
      final request = CreateAgentSessionEventsRequest(
        events: [
          AgentSessionInput.computerUseApprovalRequestResult(
            requestId: 'PRIVATE',
            response: AgentSessionBrowserAuthenticationResponse.submit(
              fields: [
                AgentSessionBrowserAuthenticationFieldValue(
                  fieldId: 'PRIVATE',
                  value: 'PRIVATE',
                ),
              ],
            ),
          ),
        ],
      );
      await expectLater(
        client.agents.sessions.events.create(
          'PRIVATE',
          request,
          additionalHeaders: {
            'X-Request-ID': 'PRIVATE',
            'X-Private': 'PRIVATE',
          },
        ),
        throwsA(
          isA<OpenAIException>().having(
            (e) => e.toString(),
            'private error',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
      expect(physical, 1);
      expect(retry.attempts, 4);
      expect(records, isNotEmpty);
      expect(records.join('\n'), isNot(contains('PRIVATE')));
      expect(request.toString(), isNot(contains('PRIVATE')));
    },
  );
}

class _FixtureTransport extends http.BaseClient {
  final requests = <http.Request>[];
  int streamsCancelled = 0;
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = await request.finalize().toBytes();
    requests.add(
      http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = bytes,
    );
    if (request.headers['accept'] == 'text/event-stream') {
      return http.StreamedResponse(
        _events(),
        request.method == 'POST' ? 201 : 200,
        headers: {'content-type': 'text/event-stream'},
        request: request,
      );
    }
    if (request.url.path.endsWith('/events')) {
      return http.StreamedResponse(
        Stream.value(<int>[]),
        202,
        request: request,
      );
    }
    final body = request.method == 'DELETE'
        ? _wire('DeletedSessionResource')
        : request.method == 'GET' && request.url.path.endsWith('/sessions')
        ? _wire('SessionListResource')
        : _wire('SessionResource');
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      request.method == 'POST' && request.url.path.endsWith('/sessions')
          ? 201
          : 200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }

  Stream<List<int>> _events() async* {
    try {
      final events = agentSessionWireFixtures.where(
        (f) =>
            f.schema.startsWith('SessionEvent') &&
            f.schema != 'SessionEvent' &&
            f.full is Map,
      );
      for (final fixture in events) {
        final event = {...(fixture.full! as Map<String, dynamic>)};
        if (event.containsKey('event_id')) event['event_id'] = 'event café🚀';
        final bytes = utf8.encode(
          'event: ignored-frame-name\r\ndata: ${jsonEncode(event)}\r\n\r\n',
        );
        for (var i = 0; i < bytes.length; i++) {
          yield [bytes[i]];
        }
      }
    } finally {
      streamsCancelled++;
    }
  }

  @override
  void close() {
    closed++;
  }
}

class _Repeat implements Interceptor {
  int attempts = 0;
  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    Object? last;
    for (var i = 0; i < 4; i++) {
      attempts++;
      try {
        return await next(context);
      } catch (e) {
        last = e;
      }
    }
    if (last is Exception) throw last;
    if (last is Error) throw last;
    throw StateError('Unexpected retry test failure');
  }
}

class _ConflictingAuth implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer synthetic',
    'oPeNaI-bEtA': 'provider-wrong',
    'AcCePt': 'provider-wrong',
    'Idempotency-Key': 'provider',
    'Content-Type': 'text/plain; charset=iso-8859-1',
  };
}
