import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  test('showManifests routes and parses all model variants', () async {
    final client = OllamaClient.withApiKey(
      'key',
      baseUrl: 'https://proxy.test/ollama?tenant=x',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/ollama/api/show');
        expect(request.headers['content-type'], 'application/json');
        expect(request.url.queryParameters, {'tenant': 'x'});
        expect(request.headers['authorization'], 'Bearer key');
        expect(jsonDecode(request.body), {
          'model': 'multi',
          'all_manifests': true,
          'verbose': false,
        });
        return http.Response(
          jsonEncode({
            'license': 'MIT',
            'manifests': [
              {
                'runner': 'mlx',
                'voices': ['Hugh'],
                'capabilities': ['speech'],
              },
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final response = await client.models.showManifests(
      request: const ShowRequest(
        model: 'multi',
        allManifests: false,
        verbose: false,
      ),
    );
    expect(response.manifests.single.runner, 'mlx');
    expect(response.manifests.single.details.voices, ['Hugh']);
  });

  test(
    'normal show rejects the incompatible all-manifests response shape',
    () async {
      final client = OllamaClient(
        httpClient: MockClient((_) async => fail('must not send')),
      );
      addTearDown(client.close);
      await expectLater(
        client.models.show(
          request: const ShowRequest(model: 'm', allManifests: true),
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'copy preserves status warnings and accepts older empty responses',
    () async {
      var count = 0;
      final client = OllamaClient(
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/copy');
          expect(jsonDecode(request.body), {'source': 'a', 'destination': 'b'});
          return http.Response(
            count++ == 0 ? '{"status":"warning: missing remote child"}' : '',
            200,
          );
        }),
      );
      addTearDown(client.close);
      final response = await client.models.copy(
        request: const CopyRequest(source: 'a', destination: 'b'),
      );
      expect(response.status, 'warning: missing remote child');
      expect(
        (await client.models.copy(
          request: const CopyRequest(source: 'a', destination: 'b'),
        )).status,
        isNull,
      );
    },
  );

  test(
    'heartbeat checks the configured server and propagates failures',
    () async {
      var count = 0;
      final client = OllamaClient.withApiKey(
        'key',
        baseUrl: 'https://proxy.test/ollama?tenant=x',
        httpClient: MockClient((request) async {
          expect(request.method, 'HEAD');
          expect(request.url.path, '/ollama/');
          expect(request.url.queryParameters, {'tenant': 'x'});
          expect(request.headers['authorization'], 'Bearer key');
          expect(request.bodyBytes, isEmpty);
          return http.Response('', count++ == 0 ? 200 : 401);
        }),
      );
      await client.heartbeat();
      await expectLater(
        client.heartbeat(),
        throwsA(isA<AuthenticationException>()),
      );
      client.close();
      await expectLater(client.heartbeat(), throwsStateError);
    },
  );

  test('runner selectors survive streaming request overrides', () async {
    final paths = <String>[];
    final client = OllamaClient(
      httpClient: MockClient((request) async {
        paths.add(request.url.path);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['runner'], 'mlx');
        expect(body['stream'], true);
        return http.Response(switch (request.url.path) {
          '/api/chat' =>
            '{"model":"m","created_at":"2026-11-05T00:00:00Z","message":{"role":"assistant","content":""},"done":true}\n',
          '/api/generate' =>
            '{"model":"m","created_at":"2026-11-05T00:00:00Z","response":"","done":true}\n',
          _ => '{"status":"success"}\n',
        }, 200);
      }),
    );
    addTearDown(client.close);
    await client.chat
        .createStream(
          request: const ChatRequest(model: 'm', messages: [], runner: 'mlx'),
        )
        .toList();
    await client.completions
        .generateStream(
          request: const GenerateRequest(model: 'm', runner: 'mlx'),
        )
        .toList();
    await client.models
        .pullStream(
          request: const PullRequest(model: 'm', runner: 'mlx'),
        )
        .toList();
    expect(paths, ['/api/chat', '/api/generate', '/api/pull']);
  });
}
