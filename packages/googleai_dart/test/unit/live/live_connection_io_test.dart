@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

class _CountingProvider implements AuthProvider {
  final AuthCredentials credentials;
  int calls = 0;

  _CountingProvider(this.credentials);

  @override
  Future<AuthCredentials> getCredentials() async {
    calls++;
    return credentials;
  }
}

class _Handshake {
  final Uri uri;
  final String? authorization;
  final String? apiKeyHeader;
  final Map<String, dynamic> firstMessage;

  _Handshake({
    required this.uri,
    required this.authorization,
    required this.apiKeyHeader,
    required this.firstMessage,
  });
}

class _Server {
  final HttpServer http;
  final handshake = Completer<_Handshake>();
  int upgrades = 0;

  _Server(this.http, {required bool reject}) {
    http.listen((request) async {
      if (reject) {
        request.response.statusCode = HttpStatus.unauthorized;
        await request.response.close();
        return;
      }
      upgrades++;
      final uri = request.uri;
      final authorization = request.headers.value('authorization');
      final apiKeyHeader = request.headers.value('x-goog-api-key');
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen((data) {
        if (handshake.isCompleted) return;
        handshake.complete(
          _Handshake(
            uri: uri,
            authorization: authorization,
            apiKeyHeader: apiKeyHeader,
            firstMessage: jsonDecode(data as String) as Map<String, dynamic>,
          ),
        );
        socket.add(utf8.encode('{"setupComplete":{"sessionId":"loopback"}}'));
      });
    });
  }

  String get baseUrl => 'http://127.0.0.1:${http.port}';

  static Future<_Server> start({bool reject = false}) async {
    final server = _Server(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
      reject: reject,
    );
    addTearDown(() => server.http.close(force: true));
    return server;
  }
}

LiveClient _createLive(GoogleAIConfig config) {
  final client = GoogleAIClient(config: config);
  final live = client.createLiveClient();
  addTearDown(client.close);
  addTearDown(live.close);
  return live;
}

const _developerPath =
    '/ws/google.ai.generativelanguage.v1beta.'
    'GenerativeService.BidiGenerateContentConstrained';
const _model = 'gemini-3.8-live';
const _deadline = Duration(seconds: 4);

void main() {
  test(
    'an explicit token uses the constrained endpoint and suppresses old keys',
    () async {
      final server = await _Server.start();
      final provider = _CountingProvider(
        const ApiKeyCredentials('provider-key'),
      );
      final live = _createLive(
        GoogleAIConfig(
          apiVersion: ApiVersion.v1,
          authProvider: provider,
          baseUrl:
              '${server.baseUrl}/tenant/?key=base-key&access_token=old-token',
          defaultQueryParams: {
            'key': 'default-key',
            'access_token': 'default-token',
            'tenant': 'demo',
          },
        ),
      );

      final session = await live
          .connect(model: _model, accessToken: 'auth_tokens/explicit+token')
          .timeout(_deadline);
      final handshake = await server.handshake.future;
      expect(provider.calls, 0);
      expect(server.upgrades, 1);
      expect(handshake.uri.path, '/tenant$_developerPath');
      expect(handshake.uri.queryParameters, {
        'access_token': 'auth_tokens/explicit+token',
        'tenant': 'demo',
      });
      expect(handshake.authorization, isNull);
      expect(handshake.apiKeyHeader, isNull);
      expect(handshake.firstMessage, {
        'setup': {'model': 'models/$_model'},
      });
      expect(session.sessionId, 'loopback');
    },
  );

  test('ordinary Developer API keys keep the legacy query merge', () async {
    final server = await _Server.start();
    final provider = _CountingProvider(const ApiKeyCredentials('provider-key'));
    final live = _createLive(
      GoogleAIConfig(
        authProvider: provider,
        baseUrl: '${server.baseUrl}?key=base-key',
        defaultQueryParams: {'key': 'default-key', 'tenant': 'demo'},
      ),
    );

    await live.connect(model: _model).timeout(_deadline);
    final handshake = await server.handshake.future;
    expect(provider.calls, 1);
    expect(
      handshake.uri.path,
      '/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent',
    );
    expect(handshake.uri.queryParameters, {
      'key': 'default-key',
      'tenant': 'demo',
    });
    expect(handshake.authorization, isNull);
    expect(handshake.firstMessage, {
      'setup': {'model': 'models/$_model'},
    });
  });

  for (final placement in EphemeralTokenPlacement.values) {
    test(
      'a provider token uses the constrained endpoint with ${placement.name}',
      () async {
        final server = await _Server.start();
        final provider = _CountingProvider(
          EphemeralTokenCredentials(
            'auth_tokens/provider-token',
            placement: placement,
          ),
        );
        final live = _createLive(
          GoogleAIConfig(
            apiVersion: ApiVersion.v1,
            authProvider: provider,
            baseUrl: '${server.baseUrl}?key=old-key&access_token=old-token',
            defaultQueryParams: {
              'key': 'default-key',
              'access_token': 'default-token',
            },
          ),
        );

        await live.connect(model: 'models/$_model').timeout(_deadline);
        final handshake = await server.handshake.future;
        expect(provider.calls, 1);
        expect(handshake.uri.path, _developerPath);
        expect(
          handshake.uri.queryParameters,
          placement == EphemeralTokenPlacement.header
              ? isEmpty
              : {'access_token': 'auth_tokens/provider-token'},
        );
        expect(
          handshake.authorization,
          placement == EphemeralTokenPlacement.header
              ? 'Token auth_tokens/provider-token'
              : isNull,
        );
        expect(handshake.apiKeyHeader, isNull);
        expect(handshake.firstMessage, {
          'setup': {'model': 'models/$_model'},
        });
      },
    );
  }

  for (final (configuredModel, expectedModel, apiVersion, wireVersion) in [
    (
      _model,
      'projects/P/locations/eu/publishers/google/models/$_model',
      ApiVersion.v1,
      'v1',
    ),
    (
      'publishers/google/models/$_model',
      'projects/P/locations/eu/publishers/google/models/$_model',
      ApiVersion.v1beta,
      'v1beta1',
    ),
    (
      'projects/Q/locations/us/publishers/google/models/$_model',
      'projects/Q/locations/us/publishers/google/models/$_model',
      ApiVersion.v1,
      'v1',
    ),
  ]) {
    test(
      'Vertex $wireVersion sends native OAuth with model $configuredModel',
      () async {
        final server = await _Server.start();
        final provider = _CountingProvider(
          const BearerTokenCredentials('adc-fixture-token'),
        );
        final live = _createLive(
          GoogleAIConfig.vertexAI(
            projectId: 'P',
            location: 'eu',
            apiVersion: apiVersion,
            authProvider: provider,
            defaultQueryParams: {
              'access_token': 'old-access-token',
              'api-key': 'old-config-key',
              'regionHint': 'eu',
            },
          ).copyWith(
            baseUrl:
                '${server.baseUrl}/proxy?key=old-url-key&X-Goog-Api-Key=old',
          ),
        );

        await live.connect(model: configuredModel).timeout(_deadline);
        final handshake = await server.handshake.future;
        expect(provider.calls, 1);
        expect(
          handshake.uri.path,
          '/proxy/ws/google.cloud.aiplatform.$wireVersion.LlmBidiService/BidiGenerateContent',
        );
        expect(handshake.uri.queryParameters, {'regionHint': 'eu'});
        expect(handshake.authorization, 'Bearer adc-fixture-token');
        expect(handshake.apiKeyHeader, isNull);
        expect(handshake.firstMessage, {
          'setup': {'model': expectedModel},
        });
      },
    );
  }

  test('Vertex rejects API-key credentials before opening a socket', () async {
    final server = await _Server.start();
    final provider = _CountingProvider(
      const ApiKeyCredentials('developer-key'),
    );
    final live = _createLive(
      GoogleAIConfig.vertexAI(
        projectId: 'P',
        authProvider: provider,
      ).copyWith(baseUrl: server.baseUrl),
    );

    await expectLater(
      live.connect(model: _model).timeout(_deadline),
      throwsA(
        isA<LiveConnectionException>().having(
          (error) => error.message,
          'message',
          contains('requires OAuth credentials'),
        ),
      ),
    );
    expect(provider.calls, 1);
    expect(server.upgrades, 0);
  });

  test(
    'Vertex does not use an explicit Developer API ephemeral token',
    () async {
      final server = await _Server.start();
      final provider = _CountingProvider(const BearerTokenCredentials('adc'));
      final live = _createLive(
        GoogleAIConfig.vertexAI(
          projectId: 'P',
          authProvider: provider,
        ).copyWith(baseUrl: server.baseUrl),
      );

      await expectLater(
        live
            .connect(model: _model, accessToken: 'developer-only')
            .timeout(_deadline),
        throwsA(
          isA<LiveConnectionException>().having(
            (error) => error.message,
            'message',
            contains('Gemini Developer API'),
          ),
        ),
      );
      expect(provider.calls, 0);
      expect(server.upgrades, 0);
    },
  );

  test(
    'a failed upgrade redacts query credentials from diagnostic fields',
    () async {
      final server = await _Server.start(reject: true);
      final live = _createLive(
        GoogleAIConfig(baseUrl: '${server.baseUrl}?proxy_auth=extrasecret'),
      );

      await expectLater(
        live
            .connect(model: _model, accessToken: 'auth_tokens/secret+value')
            .timeout(_deadline),
        throwsA(
          isA<LiveConnectionException>()
              .having((error) => error.uri?.path, 'uri path', _developerPath)
              .having((error) => error.uri?.query, 'uri query', isEmpty)
              .having(
                (error) => '${error.message} ${error.cause}',
                'message and cause',
                allOf(
                  isNot(contains('secret+value')),
                  isNot(contains('secret%2Bvalue')),
                  isNot(contains('extrasecret')),
                ),
              ),
        ),
      );
    },
  );
}
