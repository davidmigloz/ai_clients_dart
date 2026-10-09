import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_environment_wire_fixtures.dart';

Map<String, dynamic> wire(String name) => Map<String, dynamic>.from(
  environmentWireFixtures.singleWhere((f) => f.schema == name).full! as Map,
);
const operations = [
  'createEnvironment',
  'listEnvironments',
  'retrieveEnvironment',
  'createTemplate',
  'listTemplates',
  'retrieveTemplate',
  'updateTemplate',
  'deleteTemplate',
];
String responseSchema(String op) => switch (op) {
  'listEnvironments' => 'AgentEnvironmentListResource',
  'listTemplates' => 'EnvironmentTemplateListResource',
  'deleteTemplate' => 'DeletedEnvironmentTemplateResource',
  _ =>
    op.contains('Template')
        ? 'EnvironmentTemplateResource'
        : 'PublicEnvironmentResource',
};
Future<AgentJsonModel> call(
  OpenAIClient client,
  String op, {
  Map<String, String>? headers,
  Future<void>? abort,
  String? key,
}) {
  final e = client.agents.environments;
  final t = e.templates;
  const id = 'opaque/%2F?🚀';
  return switch (op) {
    'createEnvironment' => e.create(
      CreateAgentEnvironmentRequest.fromJson(
        wire('CreateAgentEnvironmentParams'),
      ),
      idempotencyKey: key,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'listEnvironments' => e.list(
      limit: 100,
      order: AgentListOrder.asc,
      after: id,
      type: AgentEnvironmentType.openaiHosted,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'retrieveEnvironment' => e.retrieve(
      id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'createTemplate' => t.create(
      CreateAgentEnvironmentTemplateRequest.fromJson(
        wire('CreateEnvironmentTemplateParams'),
      ),
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'listTemplates' => t.list(
      limit: 100,
      order: AgentListOrder.asc,
      after: id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'retrieveTemplate' => t.retrieve(
      id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'updateTemplate' => t.update(
      id,
      UpdateAgentEnvironmentTemplateRequest.fromJson(
        wire('UpdateEnvironmentTemplateParams'),
      ),
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'deleteTemplate' => t.delete(
      id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    _ => throw StateError('Unknown operation'),
  };
}

void main() {
  final previous = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = previous);
  for (final op in operations) {
    test(
      '$op: exported client path/body/auth/header/query and ownership',
      () async {
        final capture = <http.Request>[];
        final expected = wire(responseSchema(op));
        final spy = Spy(
          MockClient((r) async {
            capture.add(r);
            return http.Response.bytes(
              utf8.encode(jsonEncode(expected)),
              op.startsWith('create') ? 201 : 200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        );
        addTearDown(spy.inner.close);
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/custom/v1',
            authProvider: FixtureAuth(),
            organization: 'org',
            project: 'project',
            defaultHeaders: const {
              'OpenAI-Beta': 'wrong',
              'Accept': 'wrong',
              'Idempotency-Key': 'default',
            },
          ),
          httpClient: spy,
        );
        final headers = {
          'X-Caller': 'original',
          'oPeNaI-bEtA': 'wrong',
          'ACCEPT': 'wrong',
          'Content-Type': 'text/plain; charset=latin1',
          'iDeMpOtEnCy-kEy': 'caller',
        };
        final pending = call(
          client,
          op,
          headers: headers,
          key: op == 'createEnvironment' ? '🚀' * 256 : null,
        );
        headers.clear();
        final result = await pending;
        expect(result.toJson(), expected);
        expect(result.toString(), isNot(contains('PRIVATE')));
        final r = capture.single;
        final templ = op.contains('Template');
        final list = op.startsWith('list');
        final body = op.startsWith('create') || op == 'updateTemplate';
        expect(
          r.method,
          op == 'deleteTemplate'
              ? 'DELETE'
              : body
              ? 'POST'
              : 'GET',
        );
        expect(r.url.pathSegments.take(4).toList(), [
          'custom',
          'v1',
          'agents',
          'environments',
        ]);
        if (templ) expect(r.url.pathSegments[4], 'templates');
        if (op.startsWith('retrieve') ||
            op.startsWith('update') ||
            op.startsWith('delete')) {
          expect(r.url.pathSegments.last, 'opaque/%2F?🚀');
        }
        expect(r.headers['authorization'], 'Bearer synthetic');
        expect(r.headers['openai-project'], 'project');
        expect(r.headers['openai-organization'], 'org');
        expect(r.headers['openai-beta'], 'agents=v1');
        expect(r.headers['accept'], 'application/json');
        expect(r.headers['x-caller'], 'original');
        if (op == 'createEnvironment') {
          expect(r.headers['idempotency-key'], '🚀' * 256);
        }
        expect(
          r.url.queryParameters,
          list
              ? {
                  'limit': '100',
                  'order': 'asc',
                  'after': 'opaque/%2F?🚀',
                  if (!templ) 'type': 'openai_hosted',
                }
              : <String, String>{},
        );
        if (body) {
          expect(r.headers['content-type'], 'application/json; charset=utf-8');
          expect(
            jsonDecode(utf8.decode(r.bodyBytes)),
            wire(
              op == 'createEnvironment'
                  ? 'CreateAgentEnvironmentParams'
                  : op == 'createTemplate'
                  ? 'CreateEnvironmentTemplateParams'
                  : 'UpdateEnvironmentTemplateParams',
            ),
          );
        } else {
          expect(r.bodyBytes, isEmpty);
          expect(r.headers.containsKey('content-type'), isFalse);
        }
        expect(
          identical(client.agents.environments, client.agents.environments),
          isTrue,
        );
        expect(
          identical(
            client.agents.environments.templates,
            client.agents.environments.templates,
          ),
          isTrue,
        );
        client.close();
        expect(spy.closes, 0);
        expect(() => client.agents.environments, throwsStateError);
      },
    );
    test('$op: abort before transport', () async {
      var sends = 0;
      final transport = MockClient((r) async {
        sends++;
        return http.Response('{}', 200);
      });
      final c = OpenAIClient.withApiKey('synthetic', httpClient: transport);
      addTearDown(() {
        c.close();
        transport.close();
      });
      await expectLater(
        call(c, op, abort: Future<void>.value()),
        throwsA(isA<AbortedException>()),
      );
      expect(sends, 0);
    });
  }
  test(
    'create keys: omission/caller/default/explicit precedence and bounds',
    () async {
      final requests = <http.Request>[];
      final tr = MockClient((r) async {
        requests.add(r);
        return http.Response.bytes(
          utf8.encode(jsonEncode(wire('PublicEnvironmentResource'))),
          201,
        );
      });
      final c = OpenAIClient(
        config: OpenAIConfig(authProvider: FixtureAuth()),
        httpClient: tr,
      );
      addTearDown(() {
        c.close();
        tr.close();
      });
      final req = CreateAgentEnvironmentRequest(
        environment: AgentPrewarmEnvironment.openaiHosted(),
      );
      await c.agents.environments.create(req);
      expect(requests.last.headers['idempotency-key'], 'provider');
      await c.agents.environments.create(
        req,
        additionalHeaders: {'Idempotency-Key': 'caller'},
      );
      expect(requests.last.headers['idempotency-key'], 'caller');
      for (final key in ['', '🚀' * 257]) {
        await expectLater(
          c.agents.environments.create(req, idempotencyKey: key),
          throwsFormatException,
        );
        await expectLater(
          c.agents.environments.create(
            req,
            additionalHeaders: {'Idempotency-Key': key},
          ),
          throwsFormatException,
        );
      }
      expect(requests.length, 2);
    },
  );
  test(
    'create retries carry identical body/key; conflicts surface HTTP409 without local dedup',
    () async {
      final requests = <http.Request>[];
      final tr = MockClient((r) async {
        requests.add(r);
        if (requests.length == 1) {
          return http.Response(
            '{"error":{"message":"busy","type":"server_error"}}',
            429,
          );
        }
        if (requests.length == 3) {
          return http.Response(
            '{"error":{"message":"conflict","type":"invalid_request_error"}}',
            409,
          );
        }
        return http.Response.bytes(
          utf8.encode(jsonEncode(wire('PublicEnvironmentResource'))),
          201,
        );
      });
      final c = OpenAIClient(
        config: OpenAIConfig(
          authProvider: FixtureAuth(),
          retryPolicy: const RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
          ),
        ),
        httpClient: tr,
      );
      addTearDown(() {
        c.close();
        tr.close();
      });
      final req = CreateAgentEnvironmentRequest(
        environment: AgentPrewarmEnvironment.openaiHosted(),
      );
      await c.agents.environments.create(req, idempotencyKey: 'same');
      await expectLater(
        c.agents.environments.create(req, idempotencyKey: 'same'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 409)),
      );
      expect(requests.length, 3);
      expect(requests[0].bodyBytes, requests[1].bodyBytes);
      for (final r in requests) {
        expect(r.headers['idempotency-key'], 'same');
      }
    },
  );
  test(
    'private logging omits URLs/correlation/headers/body and returned secrets',
    () async {
      final records = <LogRecord>[];
      final logger = Logger('environment-fixture')..level = Level.ALL;
      final sub = logger.onRecord.listen(records.add);
      addTearDown(sub.cancel);
      final tr = MockClient(
        (r) async => http.Response.bytes(
          utf8.encode(jsonEncode(wire('PublicEnvironmentResource'))),
          201,
          headers: {'x-request-id': 'PRIVATE-correlation'},
        ),
      );
      final c = OpenAIClient(
        config: OpenAIConfig(
          authProvider: FixtureAuth(),
          logLevel: Level.ALL,
          baseUrl: 'https://fixture.invalid/PRIVATE-base',
        ),
        httpClient: tr,
      );
      c.interceptorChain.interceptors.add(LoggingInterceptor(logger: logger));
      addTearDown(() {
        c.close();
        tr.close();
      });
      await c.agents.environments.create(
        CreateAgentEnvironmentRequest(
          environment: AgentPrewarmEnvironment.openaiHosted(
            env: const {'SECRET': 'PRIVATE-value'},
          ),
        ),
        idempotencyKey: 'PRIVATE-key',
      );
      expect(records, isNotEmpty);
      expect(
        records.map((r) => '${r.message} ${r.error}').join('\n'),
        isNot(contains('PRIVATE')),
      );
    },
  );
  test('list filters and opaque path local guards reject before transport', () {
    var sends = 0;
    final tr = MockClient((r) async {
      sends++;
      return http.Response('{}', 200);
    });
    final c = OpenAIClient.withApiKey('synthetic', httpClient: tr);
    addTearDown(() {
      c.close();
      tr.close();
    });
    for (final id in ['', '.', '..']) {
      expect(() => c.agents.environments.retrieve(id), throwsFormatException);
      expect(
        () => c.agents.environments.templates.retrieve(id),
        throwsFormatException,
      );
    }
    expect(() => c.agents.environments.list(limit: 101), throwsFormatException);
    expect(
      () => c.agents.environments.templates.list(limit: 0),
      throwsFormatException,
    );
    expect(
      () => c.agents.environments.list(
        type: AgentEnvironmentType.fromJson('self_hosted'),
      ),
      throwsFormatException,
    );
    expect(sends, 0);
  });
}

class FixtureAuth implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer synthetic',
    'OpenAI-Beta': 'wrong',
    'Accept': 'wrong',
    'Content-Type': 'text/plain',
    'IDEMPOTENCY-KEY': 'provider',
  };
}

class Spy extends http.BaseClient {
  Spy(this.inner);
  final http.Client inner;
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) => inner.send(r);
  @override
  void close() {
    closes++;
    inner.close();
  }
}
