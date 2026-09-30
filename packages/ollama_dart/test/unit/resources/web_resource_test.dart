import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'search uses configured origin, auth, custom headers and response fields',
    () async {
      final client = OllamaClient.withApiKey(
        'test-key',
        baseUrl: 'https://example.com/proxy/?token=a&token=b',
        defaultHeaders: {'X-Custom': 'value'},
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.host, 'example.com');
          expect(request.url.path, '/proxy/api/web_search');
          expect(request.url.queryParametersAll['token'], ['a', 'b']);
          expect(request.headers['authorization'], 'Bearer test-key');
          expect(request.headers['x-custom'], 'value');
          expect(request.headers['content-type'], 'application/json');
          expect(jsonDecode(request.body), {'query': 'Dart'});
          return http.Response(
            '{"results":[{"title":"Dart","url":"https://dart.dev","content":"Language"}]}',
            200,
          );
        }),
      );
      addTearDown(client.close);
      final response = await client.web.search(
        request: const WebSearchRequest(query: 'Dart'),
      );
      expect(
        response.results?.single,
        const WebSearchResult(
          title: 'Dart',
          url: 'https://dart.dev',
          content: 'Language',
        ),
      );
    },
  );

  test(
    'search sends explicit max_results without changing local host',
    () async {
      final client = OllamaClient(
        httpClient: MockClient((request) async {
          expect(request.url.host, 'localhost');
          expect(jsonDecode(request.body), {
            'query': 'Ollama',
            'max_results': 10,
          });
          return http.Response('{"results":[]}', 200);
        }),
      );
      addTearDown(client.close);
      expect(
        (await client.web.search(
          request: const WebSearchRequest(query: 'Ollama', maxResults: 10),
        )).results,
        isEmpty,
      );
    },
  );

  test('fetch sends scheme-less URL and parses all response fields', () async {
    final client = OllamaClient.withApiKey(
      'test-key',
      baseUrl: 'https://ollama.com',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/web_fetch');
        expect(request.headers['authorization'], 'Bearer test-key');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {'url': 'ollama.com'});
        return http.Response(
          '{"title":"Ollama","content":"Models","links":["https://ollama.com/library"]}',
          200,
        );
      }),
    );
    addTearDown(client.close);
    expect(
      await client.web.fetch(request: const WebFetchRequest(url: 'ollama.com')),
      const WebFetchResponse(
        title: 'Ollama',
        content: 'Models',
        links: ['https://ollama.com/library'],
      ),
    );
  });

  test('web failures preserve typed exceptions', () async {
    final client = OllamaClient(
      config: const OllamaConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
      httpClient: MockClient(
        (_) async => http.Response('{"error":"unauthorized"}', 401),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.web.search(request: const WebSearchRequest(query: 'Dart')),
      throwsA(isA<AuthenticationException>()),
    );
    await expectLater(
      client.web.fetch(request: const WebFetchRequest(url: 'ollama.com')),
      throwsA(isA<AuthenticationException>()),
    );
  });

  test('closed client rejects both web operations without sending', () async {
    final client = OllamaClient(
      httpClient: MockClient((_) async => fail('Unexpected request')),
    )..close();
    await expectLater(
      client.web.search(request: const WebSearchRequest(query: 'Dart')),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      client.web.fetch(request: const WebFetchRequest(url: 'ollama.com')),
      throwsA(isA<StateError>()),
    );
  });
}
