import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/agents_resource.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

http.StreamedResponse _jsonResponse(Object? body, {int status = 200}) {
  final encoded = utf8.encode(jsonEncode(body));
  return http.StreamedResponse(
    Stream.value(encoded),
    status,
    headers: {
      'content-type': 'application/json',
      'content-length': '${encoded.length}',
    },
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  late _MockHttpClient mockHttpClient;
  late AgentsResource resource;
  late List<http.BaseRequest> capturedRequests;
  late List<List<int>?> capturedBodies;

  void stubJsonResponse(Object? body, {int status = 200}) {
    when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
      final req = invocation.positionalArguments.first as http.BaseRequest;
      capturedRequests.add(req);
      capturedBodies.add(req is http.Request ? req.bodyBytes : null);
      return _jsonResponse(body, status: status);
    });
  }

  setUp(() {
    mockHttpClient = _MockHttpClient();
    capturedRequests = <http.BaseRequest>[];
    capturedBodies = <List<int>?>[];

    const config = GoogleAIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com',
      authProvider: ApiKeyProvider('test-key'),
    );
    resource = AgentsResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: const RequestBuilder(config: config),
    );
  });

  group('AgentsResource', () {
    test(
      'create() POSTs the agent and sends the Api-Revision header',
      () async {
        stubJsonResponse({'id': 'agent_1', 'base_agent': 'deep-research'});

        final result = await resource.create(
          agent: const Agent(
            baseAgent: 'deep-research',
            systemInstruction: 'Be precise.',
          ),
        );

        final req = capturedRequests.single;
        expect(req.method, 'POST');
        expect(req.url.path, '/v1beta/agents');
        expect(req.headers['Api-Revision'], '2026-05-20');
        final body =
            jsonDecode(utf8.decode(capturedBodies.single!))
                as Map<String, dynamic>;
        expect(body['base_agent'], 'deep-research');
        expect(body['system_instruction'], 'Be precise.');
        expect(result.id, 'agent_1');
      },
    );

    test('list() GETs /agents with pagination query params', () async {
      stubJsonResponse({
        'agents': [
          {'id': 'a1'},
        ],
        'nextPageToken': 'tok',
      });

      final result = await resource.list(pageSize: 5, pageToken: 'p');

      final req = capturedRequests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/v1beta/agents');
      expect(req.url.queryParameters['pageSize'], '5');
      expect(req.url.queryParameters['pageToken'], 'p');
      expect(result.agents, hasLength(1));
      expect(result.nextPageToken, 'tok');
    });

    test('get() GETs /agents/{id}', () async {
      stubJsonResponse({'id': 'agent_9'});

      final result = await resource.get('agent_9');

      final req = capturedRequests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/v1beta/agents/agent_9');
      expect(result.id, 'agent_9');
    });

    test('delete() DELETEs /agents/{id}', () async {
      stubJsonResponse(<String, dynamic>{});

      await resource.delete('agent_9');

      final req = capturedRequests.single;
      expect(req.method, 'DELETE');
      expect(req.url.path, '/v1beta/agents/agent_9');
    });
  });
}
