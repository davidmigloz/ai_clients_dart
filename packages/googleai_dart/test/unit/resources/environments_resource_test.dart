import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/environments_resource.dart';
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
  late EnvironmentsResource resource;
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
    resource = EnvironmentsResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: const RequestBuilder(config: config),
    );
  });

  group('EnvironmentsResource', () {
    test('list() GETs /environments with pagination query params', () async {
      stubJsonResponse({
        'environments': [
          {'id': 'env_1'},
        ],
        'next_page_token': 'tok',
      });

      final result = await resource.list(pageSize: 5, pageToken: 'p');

      final req = capturedRequests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/v1beta/environments');
      expect(req.headers['Api-Revision'], '2026-05-20');
      expect(req.url.queryParameters['page_size'], '5');
      expect(req.url.queryParameters['page_token'], 'p');
      expect(result.environments, hasLength(1));
      expect(result.nextPageToken, 'tok');
    });

    test(
      'create() POSTs the environment and sends the Api-Revision header',
      () async {
        stubJsonResponse({'id': 'env_1'});

        final result = await resource.create(
          environment: const CreateEnvironmentRequest(
            network: EnvironmentNetworkDisabled(),
          ),
        );

        final req = capturedRequests.single;
        expect(req.method, 'POST');
        expect(req.url.path, '/v1beta/environments');
        expect(req.headers['Api-Revision'], '2026-05-20');
        final body =
            jsonDecode(utf8.decode(capturedBodies.single!))
                as Map<String, dynamic>;
        expect(body['network'], 'disabled');
        expect(result.id, 'env_1');
      },
    );

    test('get() GETs /environments/{id}', () async {
      stubJsonResponse({'id': 'env_1'});

      final result = await resource.get('env_1');

      final req = capturedRequests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/v1beta/environments/env_1');
      expect(req.headers['Api-Revision'], '2026-05-20');
      expect(result.id, 'env_1');
    });

    test('delete() DELETEs /environments/{id}', () async {
      stubJsonResponse(<String, dynamic>{});

      await resource.delete('env_1');

      final req = capturedRequests.single;
      expect(req.method, 'DELETE');
      expect(req.url.path, '/v1beta/environments/env_1');
      expect(req.headers['Api-Revision'], '2026-05-20');
    });
  });
}
