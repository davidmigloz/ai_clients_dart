import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Containers transport (CONT-04/06/07)', () {
    test(
      'create sends complete configuration and retains partial response',
      () async {
        final requests = <http.Request>[];
        final client = _client(
          MockClient((request) async {
            requests.add(request);
            return http.Response(jsonEncode(_containerJson()), 200);
          }),
        );
        addTearDown(client.close);

        final container = await client.containers.create(
          CreateContainerRequest(
            name: 'fixture-container',
            fileIds: const ['file_fixture'],
            expiresAfter: const ContainerExpiration(
              anchor: 'last_active_at',
              minutes: 20,
            ),
            memoryLimit: ContainerMemoryLimit.gb4,
            networkPolicy: ContainerNetworkPolicy.allowlist(
              ['api.example.com'],
              domainSecrets: const [
                ContainerNetworkPolicyDomainSecret(
                  domain: 'api.example.com',
                  name: 'API_TOKEN',
                  value: 'fixture-secret',
                ),
              ],
            ),
            skills: const [
              ContainerSkillReference(skillId: 'skill_fixture', version: '7'),
              InlineContainerSkill(
                name: 'wire-fixture',
                description: 'Serialization fixture',
                source: Base64ContainerSkillSource(
                  data: 'UEsFBgAAAAAAAAAAAAAAAAAAAAAAAA==',
                ),
              ),
            ],
          ),
        );

        expect(requests, hasLength(1));
        final request = requests.single;
        expect(request.method, 'POST');
        expect(
          request.url,
          Uri.parse(
            'https://eu.api.openai.com/v1/containers?gateway=containers',
          ),
        );
        _expectHeaders(request);
        expect(jsonDecode(request.body), {
          'name': 'fixture-container',
          'file_ids': ['file_fixture'],
          'expires_after': {'anchor': 'last_active_at', 'minutes': 20},
          'memory_limit': '4g',
          'network_policy': {
            'type': 'allowlist',
            'allowed_domains': ['api.example.com'],
            'domain_secrets': [
              {
                'domain': 'api.example.com',
                'name': 'API_TOKEN',
                'value': 'fixture-secret',
              },
            ],
          },
          'skills': [
            {
              'type': 'skill_reference',
              'skill_id': 'skill_fixture',
              'version': '7',
            },
            {
              'type': 'inline',
              'name': 'wire-fixture',
              'description': 'Serialization fixture',
              'source': {
                'type': 'base64',
                'media_type': 'application/zip',
                'data': 'UEsFBgAAAAAAAAAAAAAAAAAAAAAAAA==',
              },
            },
          ],
        });
        expect(container.toJson(), _containerJson());
        expect(container.memoryLimit, ContainerMemoryLimit.gb4);
        expect(container.networkPolicy!.type, 'allowlist');
        expect(container.networkPolicy!.allowedDomains, isNull);
        expect(container.expiresAfter!.anchor, isNull);
        expect(container.expiresAfter!.minutes, isNull);
        expect(container.isActive, isTrue);
      },
    );

    test('minimal creation omits configuration defaults', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/v1/containers');
          expect(jsonDecode(request.body), {'name': 'fixture'});
          return http.Response(jsonEncode(_containerJson()), 200);
        }),
      );
      addTearDown(client.close);
      expect(
        (await client.containers.create(
          CreateContainerRequest(name: 'fixture'),
        )).id,
        'cntr_fixture',
      );
    });

    test('retrieve retains full configuration and unfamiliar memory', () async {
      final fixture = {
        ..._containerJson(),
        'memory_limit': '128g',
        'last_active_at': 0,
        'expires_after': {'anchor': 'last_active_at', 'minutes': 20},
        'network_policy': {
          'type': 'future_mode',
          'allowed_domains': ['api.example.com'],
        },
      };
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v1/containers/cntr_fixture');
          _expectHeaders(request);
          return http.Response(jsonEncode(fixture), 200);
        }),
      );
      addTearDown(client.close);

      final result = await client.containers.retrieve('cntr_fixture');
      expect(result.toJson(), fixture);
      expect(result.memoryLimit, const ContainerMemoryLimit('128g'));
      expect(result.networkPolicy!.type, 'future_mode');
      expect(result.expiresAfter!.minutes, 20);
      expect(result.lastActiveAtDateTime!.millisecondsSinceEpoch, 0);
    });

    test(
      'list transmits name and canonical pagination and retains settings',
      () async {
        final client = _client(
          MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.path, '/v1/containers');
            expect(request.url.queryParameters, {
              'gateway': 'containers',
              'name': 'fixture container',
              'after': 'cntr_previous',
              'limit': '2',
              'order': 'asc',
            });
            _expectHeaders(request);
            return http.Response(
              jsonEncode({
                'object': 'list',
                'data': [_containerJson()],
                'first_id': 'cntr_fixture',
                'last_id': 'cntr_fixture',
                'has_more': false,
              }),
              200,
            );
          }),
        );
        addTearDown(client.close);

        final result = await client.containers.list(
          name: 'fixture container',
          after: 'cntr_previous',
          limit: 2,
          order: 'asc',
        );
        expect(result.data.single.toJson(), _containerJson());
        expect(result.firstId, 'cntr_fixture');
        expect(result.lastId, 'cntr_fixture');
        expect(result.hasMore, isFalse);
      },
    );

    test('legacy before cursor remains transmitted', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.url.queryParameters['before'], 'cntr_next');
          return http.Response(
            jsonEncode({
              'object': 'list',
              'data': <Object>[],
              'has_more': false,
            }),
            200,
          );
        }),
      );
      addTearDown(client.close);
      final result = await client.containers.list(before: 'cntr_next');
      expect(result.isEmpty, isTrue);
    });
  });

  group('Responses container integration (CONT-01/07)', () {
    final limits = {
      ContainerMemoryLimit.gb1: '1g',
      ContainerMemoryLimit.gb4: '4g',
      ContainerMemoryLimit.gb16: '16g',
      ContainerMemoryLimit.gb64: '64g',
    };
    for (final entry in limits.entries) {
      test(
        'automatic container sends ${entry.value} and network secrets',
        () async {
          var calls = 0;
          final client = _client(
            MockClient((request) async {
              calls++;
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses');
              _expectHeaders(request);
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': 'run code',
                'tools': [
                  {
                    'type': 'code_interpreter',
                    'container': {
                      'type': 'auto',
                      'file_ids': ['file_fixture'],
                      'memory_limit': entry.value,
                      'network_policy': {
                        'type': 'allowlist',
                        'allowed_domains': ['api.example.com'],
                        'domain_secrets': [
                          {
                            'domain': 'api.example.com',
                            'name': 'API_TOKEN',
                            'value': 'fixture-secret',
                          },
                        ],
                      },
                    },
                  },
                ],
              });
              return http.Response(jsonEncode(_responseJson()), 200);
            }),
          );
          addTearDown(client.close);

          final result = await client.responses.create(
            CreateResponseRequest(
              model: 'fixture-model',
              input: const ResponseInput.text('run code'),
              tools: [
                ResponseTool.codeInterpreter(
                  container: CodeInterpreterContainer.auto(
                    fileIds: ['file_fixture'],
                    memoryLimit: entry.key,
                    networkPolicy: ContainerNetworkPolicy.allowlist(
                      ['api.example.com'],
                      domainSecrets: const [
                        ContainerNetworkPolicyDomainSecret(
                          domain: 'api.example.com',
                          name: 'API_TOKEN',
                          value: 'fixture-secret',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          expect(result.id, 'resp_fixture');
          expect(calls, 1);
        },
      );
    }

    test(
      'returned container ID is sent as the Responses container string',
      () async {
        final requests = <http.Request>[];
        final client = _client(
          MockClient((request) async {
            requests.add(request);
            if (request.url.path == '/v1/containers') {
              return http.Response(jsonEncode(_containerJson()), 200);
            }
            return http.Response(jsonEncode(_responseJson()), 200);
          }),
        );
        addTearDown(client.close);

        final container = await client.containers.create(
          CreateContainerRequest(name: 'fixture'),
        );
        final result = await client.responses.create(
          CreateResponseRequest(
            model: 'fixture-model',
            input: const ResponseInput.text('run code'),
            tools: [
              ResponseTool.codeInterpreter(
                container: CodeInterpreterContainer.id(container.id),
              ),
            ],
          ),
        );
        expect(requests, hasLength(2));
        expect(requests.last.method, 'POST');
        expect(requests.last.url.path, '/v1/responses');
        expect(jsonDecode(requests.last.body), {
          'model': 'fixture-model',
          'input': 'run code',
          'tools': [
            {'type': 'code_interpreter', 'container': 'cntr_fixture'},
          ],
        });
        expect(result.id, 'resp_fixture');
      },
    );
  });
}

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    authProvider: ApiKeyProvider('sk-fixture'),
    baseUrl: 'https://eu.api.openai.com/v1?gateway=containers',
    organization: 'org-fixture',
    project: 'proj-fixture',
    defaultHeaders: {'X-Trace-Label': 'containers-test'},
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);

void _expectHeaders(http.Request request) {
  expect(request.headers['authorization'], 'Bearer sk-fixture');
  expect(request.headers['openai-organization'], 'org-fixture');
  expect(request.headers['openai-project'], 'proj-fixture');
  expect(request.headers['x-trace-label'], 'containers-test');
  expect(request.headers['content-type'], contains('application/json'));
  expect(request.headers['x-request-id'], isNotEmpty);
}

Map<String, dynamic> _containerJson() => {
  'id': 'cntr_fixture',
  'object': 'container',
  'name': 'fixture-container',
  'created_at': 0,
  'status': 'running',
  'memory_limit': '4g',
  'expires_after': <String, dynamic>{},
  'network_policy': {'type': 'allowlist'},
};

Map<String, dynamic> _responseJson() => {
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 0,
  'status': 'completed',
  'model': 'fixture-model',
  'output': <Object>[],
};
