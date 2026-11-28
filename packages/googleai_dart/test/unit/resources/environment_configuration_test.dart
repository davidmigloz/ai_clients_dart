import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const _agent = 'antigravity-preview-09-2026';
const _environmentKey = 'fixture-environment-key';
const _variables = EnvironmentVariables.map({
  'APP_MODE': EnvVar.literal('production'),
  'LOG_LEVEL': EnvVar(value: 'info'),
  'SERVICE_TOKEN': EnvVar(credential: 'service-token'),
});
const Map<String, Object> _variableWire = {
  'APP_MODE': 'production',
  'LOG_LEVEL': {'value': 'info'},
  'SERVICE_TOKEN': {'credential': 'service-token'},
};

GoogleAIClient _client(
  Future<http.Response> Function(http.Request) send, {
  GoogleAIConfig config = const GoogleAIConfig(),
}) {
  final transport = MockClient(send);
  final client = GoogleAIClient(config: config, httpClient: transport);
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

http.Response _jsonResponse(
  Object body, {
  int status = 200,
  Map<String, String> headers = const {},
}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json', ...headers},
);

void main() {
  test('creates a hosted environment and forks both source ID forms', () async {
    final bodies = <Map<String, dynamic>>[];
    final client = _client((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/v1beta/environments');
      expect(request.headers['api-revision'], '2026-05-20');
      bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
      return _jsonResponse({'id': 'env_new', 'mode': 'on_demand'});
    }, config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1));

    final created = await client.environments.create(
      environment: const CreateEnvironmentRequest(
        mode: EnvironmentMode.onDemand,
        env: _variables,
        network: EnvironmentNetworkDisabled(),
      ),
    );
    expect(created.mode, EnvironmentMode.onDemand);
    for (final id in ['env_source', 'environments/env_source']) {
      final forked = await client.environments.create(
        environment: CreateEnvironmentRequest(fromEnvironment: id),
      );
      expect(forked.id, 'env_new');
    }
    expect(bodies, [
      {'mode': 'on_demand', 'env': _variableWire, 'network': 'disabled'},
      {'from_environment': 'env_source'},
      {'from_environment': 'environments/env_source'},
    ]);
  });

  test(
    'exposes the self-hosted key once without logging or exporting it',
    () async {
      final level = Logger.root.level;
      Logger.root.level = Level.FINE;
      addTearDown(() => Logger.root.level = level);
      final logs = <LogRecord>[];
      final listener = Logger.root.onRecord.listen(logs.add);
      addTearDown(listener.cancel);

      const customConfig = {
        'runtime': {
          'memory_mb': 2048,
          'features': ['renderer', false],
        },
      };
      const metadata = {
        'id': 'env_hosted_here',
        'mode': 'self_hosted',
        'status': 'expired',
        'last_accessed': '2026-11-10T08:00:00Z',
        'file_count': '0',
        'size_bytes': '0',
        'custom_config': customConfig,
      };
      final client = _client((request) async {
        expect(request.headers['api-revision'], '2026-05-20');
        if (request.method == 'POST') {
          expect(request.url.path, '/v1beta/environments');
          expect(jsonDecode(request.body), {
            'mode': 'self_hosted',
            'custom_config': customConfig,
            'system_instruction': 'Summarize reports in plain language.',
          });
          return _jsonResponse(
            {
              ...metadata,
              'status': 'active',
              'environment_key': _environmentKey,
              'unstructured_note': 'Provider diagnostic $_environmentKey',
            },
            headers: const {'x-provider-echo': _environmentKey},
          );
        }
        expect(request.method, 'GET');
        final fixture = {...metadata, 'environment_key': _environmentKey};
        if (request.url.pathSegments.last == 'env_hosted_here') {
          return _jsonResponse(fixture);
        }
        expect(request.url.path, '/v1beta/environments');
        expect(request.url.queryParameters, {'mode': 'self_hosted'});
        return _jsonResponse({
          'environments': [fixture],
        });
      });
      final created = await client.environments.create(
        environment: const CreateEnvironmentRequest(
          mode: EnvironmentMode.selfHosted,
          customConfig: customConfig,
          systemInstruction: 'Summarize reports in plain language.',
        ),
      );
      expect(created.mode, EnvironmentMode.selfHosted);
      expect(created.customConfig, customConfig);
      expect(created.status, EnvironmentStatus.active);
      expect(created.environmentKey, _environmentKey);
      expect(created.toJson(), isNot(contains('environment_key')));
      expect(
        Environment.fromJson({
          'id': 'env_hosted_here',
          'environment_key': _environmentKey,
        }).environmentKey,
        _environmentKey,
      );
      expect(created.copyWith(environmentKey: null).environmentKey, isNull);

      final reopened = await client.environments.get(created.id);
      final page = await client.environments.list(
        mode: EnvironmentMode.selfHosted,
      );
      expect(reopened.status, EnvironmentStatus.expired);
      expect(reopened.lastAccessed, DateTime.utc(2026, 11, 10, 8));
      expect(reopened.fileCount, '0');
      expect(reopened.sizeBytes, '0');
      expect(reopened.environmentKey, isNull);
      expect(page.environments?.single.environmentKey, isNull);
      expect(page.environments?.single.mode, EnvironmentMode.selfHosted);
      expect(page.toJson().toString(), isNot(contains(_environmentKey)));
      expect(logs.any((log) => log.message.startsWith('Body:')), isTrue);
      expect(
        logs.map((log) => '${log.message} ${log.error}'),
        everyElement(isNot(contains(_environmentKey))),
      );
    },
  );

  test(
    'sends inline options and existing references on agent requests',
    () async {
      final bodies = <Map<String, dynamic>>[];
      final client = _client((request) async {
        expect(request.method, 'POST');
        expect(request.headers['api-revision'], '2026-05-20');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        bodies.add(body);
        if (request.url.path == '/v1beta/agents') {
          return _jsonResponse({'id': 'agent_new', ...body});
        }
        expect(request.url.path, '/v1beta/interactions');
        return _jsonResponse({
          'id': 'int_new',
          'status': 'completed',
          'environment': body['environment'],
        });
      });

      const config = EnvironmentConfigOrId.config(
        EnvironmentConfig(mode: EnvironmentMode.onDemand, env: _variables),
      );
      final agent = await client.agents.create(
        agent: const Agent(baseAgent: _agent, baseEnvironment: config),
      );
      expect(agent.baseEnvironment?.toJson(), config.toJson());
      final interaction = await client.interactions.createWithAgent(
        agent: _agent,
        environment: config,
      );
      expect(interaction.environment?.toJson(), config.toJson());
      for (final reference in ['remote', 'env_existing']) {
        final result = await client.interactions.createWithAgent(
          agent: _agent,
          environment: EnvironmentConfigOrId.id(reference),
        );
        expect(result.environment?.toJson(), reference);
      }
      const inlineWire = {
        'type': 'remote',
        'mode': 'on_demand',
        'env': _variableWire,
      };
      expect(bodies, [
        {'base_agent': _agent, 'base_environment': inlineWire},
        {'agent': _agent, 'environment': inlineWire},
        {'agent': _agent, 'environment': 'remote'},
        {'agent': _agent, 'environment': 'env_existing'},
      ]);
    },
  );

  test('preserves complete env strings and nested wire forms', () {
    const inline = {
      'type': 'remote',
      'environment_id': 'env_existing',
      'mode': 'self_hosted',
      'custom_config': {'memory_mb': 2048},
    };
    final config = EnvironmentConfig.fromJson(inline);
    expect(config.toJson(), inline);
    expect(config.copyWith(customConfig: null, mode: null).toJson(), {
      'type': 'remote',
      'environment_id': 'env_existing',
    });
    final parsed = CreateEnvironmentRequest.fromJson({
      'env': 'fixture-env-specification',
    });
    expect(parsed.env, isA<EnvironmentVariablesText>());
    expect(parsed.toJson(), {'env': 'fixture-env-specification'});
    expect(parsed.copyWith(env: null).toJson(), isEmpty);
    expect(
      EnvironmentVariables.fromJson(_variableWire).toJson(),
      _variableWire,
    );
    expect(
      () => EnvironmentVariables.fromJson({'APP_MODE': 7}),
      throwsFormatException,
    );
    final future = Environment.fromJson({
      'id': 'env_new',
      'mode': 'future_mode',
    });
    expect(future.mode, isNull);
    expect(future.copyWith().toJson()['mode'], 'future_mode');
  });

  test(
    'rejects preview-only creation fields outside the Developer beta',
    () async {
      final transport = _client(
        (_) async => fail('Unexpected transport request'),
        config: const GoogleAIConfig(apiVersion: ApiVersion.v1),
      );
      await expectLater(
        transport.environments.create(
          environment: const CreateEnvironmentRequest(
            mode: EnvironmentMode.selfHosted,
          ),
        ),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'reports malformed create responses without including the key',
    () async {
      final client = _client(
        (_) async => http.Response('malformed $_environmentKey', 200),
      );
      await expectLater(
        client.environments.create(
          environment: const CreateEnvironmentRequest(
            mode: EnvironmentMode.selfHosted,
          ),
        ),
        throwsA(
          isA<FormatException>()
              .having((error) => error.source, 'source', isNull)
              .having(
                (error) => error.toString(),
                'rendering',
                isNot(contains(_environmentKey)),
              ),
        ),
      );
    },
  );

  test('omits provider-controlled diagnostics from creation errors', () async {
    final previousLevel = Logger.root.level;
    Logger.root.level = Level.FINE;
    addTearDown(() => Logger.root.level = previousLevel);
    final logs = <LogRecord>[];
    final listener = Logger.root.onRecord.listen(logs.add);
    addTearDown(listener.cancel);

    final escaped = jsonEncode({
      'environment_key': _environmentKey,
    }).replaceAll('"', r'\"');
    final client = _client(
      (_) async => _jsonResponse(
        {
          'error': {
            'message': 'Rejected $escaped',
            'details': [
              {
                'environment_key': _environmentKey,
                'echo': 'Provider echoed $_environmentKey',
              },
            ],
          },
        },
        status: 400,
        headers: const {'x-provider-echo': _environmentKey},
      ),
    );

    await expectLater(
      client.environments.create(
        environment: const CreateEnvironmentRequest(
          mode: EnvironmentMode.selfHosted,
        ),
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 400)
            .having((error) => error.message, 'message', 'HTTP 400 error')
            .having((error) => error.details, 'details', isEmpty)
            .having(
              (error) => error.responseMetadata?.headers,
              'response headers',
              isEmpty,
            )
            .having(
              (error) => error.responseMetadata?.bodyExcerpt,
              'body excerpt',
              isEmpty,
            ),
      ),
    );
    expect(logs.any((log) => log.error is ApiException), isTrue);
    expect(
      logs.map((log) => '${log.message} ${log.error}'),
      everyElement(isNot(contains(_environmentKey))),
    );
  });
}
