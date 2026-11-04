import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

http.Response _list() => http.Response(
  jsonEncode({
    'object': 'list',
    'data': <Object?>[],
    'first_id': null,
    'last_id': null,
    'has_more': false,
  }),
  200,
);

void main() {
  test(
    'retained and newly acquired resources use separate complete snapshots',
    () async {
      final sent = <http.Request>[];
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://a.invalid/root',
          authProvider: ApiKeyProvider('A'),
          organization: 'org-A',
          project: 'project-A',
        ),
        httpClient: MockClient((request) async {
          sent.add(request);
          return _list();
        }),
      );
      final models = client.models;
      final agents = client.agents;
      final headers = {'x-generation': 'B'};
      client.updateConfig(
        baseUrl: 'https://b.invalid/new',
        authProvider: const ApiKeyProvider('B'),
        organization: 'org-B',
        project: 'project-B',
        defaultHeaders: headers,
      );
      headers['x-generation'] = 'mutated';
      await models.list();
      await client.models.list();
      await agents.automations.list();
      await client.agents.automations.list();
      expect(sent.map((r) => r.url.host), [
        'a.invalid',
        'b.invalid',
        'a.invalid',
        'b.invalid',
      ]);
      expect(sent.map((r) => r.headers['authorization']), [
        'Bearer A',
        'Bearer B',
        'Bearer A',
        'Bearer B',
      ]);
      expect(sent[0].url.path, '/root/models');
      expect(sent[1].url.path, '/new/models');
      expect(sent[2].url.path, '/root/agents/automations');
      expect(sent[3].url.path, '/new/agents/automations');
      expect(sent[0].headers['openai-project'], 'project-A');
      expect(sent[1].headers['openai-project'], 'project-B');
      expect(sent[1].headers['x-generation'], 'B');
      expect(
        () => client.config.defaultHeaders.clear(),
        throwsUnsupportedError,
      );
      client.close();
    },
  );

  test(
    'every cached top-level resource is replaced while old handles retain config',
    () {
      final client = OpenAIClient(httpClient: MockClient((_) async => _list()));
      final getters = <ResourceBase Function()>[
        () => client.agents,
        () => client.vaults,
        () => client.chat,
        () => client.completions,
        () => client.embeddings,
        () => client.audio,
        () => client.live,
        () => client.images,
        () => client.files,
        () => client.uploads,
        () => client.batches,
        () => client.models,
        () => client.moderations,
        () => client.decisions,
        () => client.fineTuning,
        () => client.evals,
        () => client.beta,
        () => client.realtime,
        () => client.realtimeSessions,
        () => client.responses,
        () => client.skills,
        () => client.conversations,
        () => client.videos,
        () => client.containers,
        () => client.chatkit,
        () => client.contentProvenanceChecks,
        () => client.webhooks,
        () => client.safety,
      ];
      final old = [for (final getter in getters) getter()];
      client.updateConfig(baseUrl: 'https://next.invalid/v1');
      for (var index = 0; index < getters.length; index++) {
        expect(identical(old[index], getters[index]()), isFalse);
        expect(old[index].config.baseUrl, 'https://api.openai.com/v1');
        expect(getters[index]().config.baseUrl, 'https://next.invalid/v1');
      }
      client.close();
    },
  );

  test(
    'nullable clears, omission, settings and invalid updates are atomic',
    () {
      final previousHierarchy = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      addTearDown(() => hierarchicalLoggingEnabled = previousHierarchy);
      final initialHeaders = {'x-initial': 'stable'};
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: const ApiKeyProvider('A'),
          defaultHeaders: initialHeaders,
          apiVersion: 'version',
          organization: 'org',
          project: 'project',
          webhookSecret: 'PRIVATE',
          logLevel: Level.FINE,
        ),
        httpClient: MockClient((_) async => _list()),
      );
      initialHeaders.clear();
      expect(client.config.defaultHeaders, {'x-initial': 'stable'});
      const retry = RetryPolicy(
        maxRetries: 1,
        initialDelay: Duration(milliseconds: 1),
      );
      client.updateConfig(
        timeout: const Duration(seconds: 3),
        connectTimeout: const Duration(seconds: 2),
        retryPolicy: retry,
      );
      expect(client.config.authProvider, isA<ApiKeyProvider>());
      expect(client.config.timeout, const Duration(seconds: 3));
      expect(client.config.connectTimeout, const Duration(seconds: 2));
      expect(client.config.retryPolicy, retry);
      final config = client.config;
      final models = client.models;
      expect(
        () => client.updateConfig(authProvider: Object()),
        throwsArgumentError,
      );
      expect(
        () => client.updateConfig(authProvider: 'PRIVATE-key'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.toString(),
            'redacted invalid credential',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
      expect(identical(client.config, config), isTrue);
      expect(identical(client.models, models), isTrue);
      client.updateConfig(
        authProvider: null,
        logLevel: null,
        apiVersion: null,
        organization: null,
        project: null,
        webhookSecret: null,
        defaultHeaders: {},
      );
      expect(client.config.authProvider, isNull);
      expect(client.config.logLevel, isNull);
      expect(client.config.apiVersion, isNull);
      expect(client.config.organization, isNull);
      expect(client.config.project, isNull);
      expect(client.config.webhookSecret, isNull);
      expect(client.config.defaultHeaders, isEmpty);
      client.updateAuthProvider(const ApiKeyProvider('B'));
      expect((client.config.authProvider! as ApiKeyProvider).apiKey, 'B');
      client.close();
      expect(client.updateConfig, throwsStateError);
      expect(() => client.updateAuthProvider(null), throwsStateError);
    },
  );

  test(
    'pending concurrent auth results do not share bearer state across generations',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      final sharedHeaders = {'Authorization': 'Bearer A'};
      final sent = <http.Request>[];
      final client = OpenAIClient(
        config: OpenAIConfig(
          baseUrl: 'https://a.invalid/v1',
          authProvider: _HeaderProvider(sharedHeaders),
        ),
        httpClient: MockClient((r) async {
          sent.add(r);
          return _list();
        }),
      );
      final gate = _CallbackInterceptor((context, next) async {
        if (context.request.url.host == 'a.invalid') {
          entered.complete();
          await release.future;
        }
        return next(context);
      });
      client.interceptorChain.interceptors.add(gate);
      final old = client.models.list();
      await entered.future;
      sharedHeaders['Authorization'] = 'Bearer B';
      client.updateConfig(baseUrl: 'https://b.invalid/v1');
      await client.models.list();
      release.complete();
      await old;
      expect(sent.map((r) => r.url.host), ['b.invalid', 'a.invalid']);
      expect(sent.map((r) => r.headers['authorization']), [
        'Bearer B',
        'Bearer A',
      ]);
      expect(
        client.interceptorChain.interceptors
            .where((i) => identical(i, gate))
            .length,
        1,
      );
      client.close();
    },
  );

  test(
    'retry retains original route, timeout and policy after update',
    () async {
      final firstAttempt = Completer<void>();
      final release = Completer<void>();
      final sent = <http.Request>[];
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://a.invalid/v1',
          authProvider: ApiKeyProvider('A'),
          timeout: Duration(seconds: 3),
          retryPolicy: RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration(milliseconds: 1),
            jitter: 0,
          ),
        ),
        httpClient: MockClient((r) async {
          sent.add(r);
          if (r.url.host == 'a.invalid' &&
              sent.where((r) => r.url.host == 'a.invalid').length == 1) {
            firstAttempt.complete();
            await release.future;
            return http.Response('{"error":{"message":"retry"}}', 503);
          }
          return _list();
        }),
      );
      final oldModels = client.models;
      final old = oldModels.list();
      await firstAttempt.future;
      client.updateConfig(
        baseUrl: 'https://b.invalid/v1',
        authProvider: const ApiKeyProvider('B'),
        timeout: const Duration(milliseconds: 1),
        retryPolicy: const RetryPolicy(maxRetries: 0),
      );
      release.complete();
      await old;
      expect(sent.length, 2);
      expect(
        sent.every(
          (r) =>
              r.url.host == 'a.invalid' &&
              r.headers['authorization'] == 'Bearer A',
        ),
        isTrue,
      );
      expect(oldModels.interceptorChain.timeout, const Duration(seconds: 3));
      expect(
        client.models.interceptorChain.timeout,
        const Duration(milliseconds: 1),
      );
      expect(client.models.interceptorChain.retryWrapper, isNull);
      client.close();
    },
  );

  test(
    'managed interceptors refresh without changing custom order or old chain',
    () {
      final previousHierarchy = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      addTearDown(() => hierarchicalLoggingEnabled = previousHierarchy);
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('A'),
          logLevel: Level.FINE,
        ),
        httpClient: MockClient((_) async => _list()),
      );
      final before = _CallbackInterceptor((c, next) => next(c));
      final after = _CallbackInterceptor((c, next) => next(c));
      client.interceptorChain.interceptors.insert(0, before);
      client.interceptorChain.interceptors.add(after);
      final old = client.interceptorChain;
      final oldEntries = List<Interceptor>.of(old.interceptors);
      client.updateConfig(authProvider: null, logLevel: null);
      expect(old.interceptors, oldEntries);
      expect(client.interceptorChain.interceptors.first, same(before));
      expect(client.interceptorChain.interceptors.last, same(after));
      expect(
        client.interceptorChain.interceptors.whereType<AuthInterceptor>(),
        isEmpty,
      );
      expect(
        client.interceptorChain.interceptors.whereType<LoggingInterceptor>(),
        isEmpty,
      );
      expect(
        client.interceptorChain.interceptors.whereType<ErrorInterceptor>(),
        hasLength(1),
      );
      client.close();
    },
  );

  test('lazy and active SSE streams keep their originating resource', () async {
    final sent = <Uri>[];
    final oldBody = StreamController<List<int>>();
    final oldSent = Completer<void>();
    var oldRequests = 0;
    final transport = MockClient.streaming((request, body) async {
      sent.add(request.url);
      expect(
        request.headers['authorization'],
        request.url.host == 'a.invalid' ? 'Bearer A' : 'Bearer B',
      );
      if (request.url.host == 'a.invalid' && oldRequests++ == 0) {
        oldSent.complete();
        return http.StreamedResponse(oldBody.stream, 200);
      }
      return http.StreamedResponse(
        Stream.value(utf8.encode('data: [DONE]\n\n')),
        200,
      );
    });
    final client = OpenAIClient(
      config: const OpenAIConfig(
        baseUrl: 'https://a.invalid/v1',
        authProvider: ApiKeyProvider('A'),
      ),
      httpClient: transport,
    );
    final resource = client.chat.completions;
    final lazy = resource.createStream(
      ChatCompletionCreateRequest(
        model: 'm',
        messages: [ChatMessage.user('x')],
      ),
    );
    final active = resource
        .createStream(
          ChatCompletionCreateRequest(
            model: 'm',
            messages: [ChatMessage.user('x')],
          ),
        )
        .drain<void>();
    await oldSent.future;
    client.updateConfig(
      baseUrl: 'https://b.invalid/v1',
      authProvider: const ApiKeyProvider('B'),
    );
    oldBody.add(utf8.encode('data: [DONE]\n\n'));
    await oldBody.close();
    await active;
    await lazy.drain<void>();
    await client.chat.completions
        .createStream(
          ChatCompletionCreateRequest(
            model: 'm',
            messages: [ChatMessage.user('x')],
          ),
        )
        .drain<void>();
    expect(sent.map((uri) => uri.host), [
      'a.invalid',
      'a.invalid',
      'b.invalid',
    ]);
    client.close();
  });

  test(
    'pending WebSocket handshake and later old-handle dials retain settings',
    () async {
      final entered = Completer<void>();
      final opened = Completer<ws.WebSocket>();
      final dials = <Uri>[];
      final tokens = <String?>[];
      final sockets = <_Socket>[];
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://a.invalid/v1',
          authProvider: ApiKeyProvider('A'),
        ),
        httpClient: MockClient((_) async => _list()),
      );
      final old = client.responses;
      final connecting = old.connect(
        connector: (uri, {headers}) {
          dials.add(uri);
          tokens.add(headers?['authorization']);
          entered.complete();
          return opened.future;
        },
      );
      await entered.future;
      client.updateConfig(
        baseUrl: 'https://b.invalid/v1',
        authProvider: const ApiKeyProvider('B'),
      );
      final first = _Socket();
      sockets.add(first);
      opened.complete(first);
      final firstConnection = await connecting;
      firstConnection.create(
        const CreateResponseRequest(model: 'm', input: ResponseInput.text('x')),
      );
      expect(first.sent, hasLength(1));
      final oldConnection = await old.connect(
        connector: (uri, {headers}) async {
          dials.add(uri);
          tokens.add(headers?['authorization']);
          final socket = _Socket();
          sockets.add(socket);
          return socket;
        },
      );
      final newConnection = await client.responses.connect(
        connector: (uri, {headers}) async {
          dials.add(uri);
          tokens.add(headers?['authorization']);
          final socket = _Socket();
          sockets.add(socket);
          return socket;
        },
      );
      expect(dials.map((uri) => uri.host), [
        'a.invalid',
        'a.invalid',
        'b.invalid',
      ]);
      expect(tokens, ['Bearer A', 'Bearer A', 'Bearer B']);
      await firstConnection.close();
      await oldConnection.close();
      await newConnection.close();
      client.close();
      expect(sockets.every((s) => s.closed), isTrue);
    },
  );

  test(
    'established WebSocket recovery retains generation and refreshes its provider',
    () async {
      final oldHeaders = {'Authorization': 'Bearer A1'};
      final first = _Socket();
      final second = _Socket();
      final dials = <Uri>[];
      final tokens = <String?>[];
      final client = OpenAIClient(
        config: OpenAIConfig(
          baseUrl: 'https://a.invalid/v1',
          authProvider: _HeaderProvider(oldHeaders),
        ),
        httpClient: MockClient((_) async => _list()),
      );
      final connection = await client.responses.connect(
        reconnect: ResponsesReconnectOptions(
          onReconnecting: (_) =>
              const ResponsesReconnectDecision.continueWith(),
          initialDelay: Duration.zero,
          maxDelay: Duration.zero,
        ),
        connector: (uri, {headers}) async {
          dials.add(uri);
          tokens.add(headers?['authorization']);
          return dials.length == 1 ? first : second;
        },
      );
      try {
        client.updateConfig(
          baseUrl: 'https://b.invalid/v1',
          authProvider: const ApiKeyProvider('B'),
        );
        oldHeaders['Authorization'] = 'Bearer A2';
        first.controller.add(ws.CloseReceived(1006, 'synthetic disconnect'));
        await _until(
          () => connection.recovery!.lastEvent is ResponsesRecoveryReconnected,
        );
        expect(dials.map((uri) => uri.host), ['a.invalid', 'a.invalid']);
        expect(tokens, ['Bearer A1', 'Bearer A2']);
        connection.create(
          const CreateResponseRequest(
            model: 'm',
            input: ResponseInput.text('x'),
          ),
        );
        expect(second.sent, hasLength(1));
        expect(client.config.baseUrl, 'https://b.invalid/v1');
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'updates and close preserve borrowed HTTP and dedicated stream ownership',
    () async {
      final shared = _SpyClient();
      final dedicated = _SpyClient();
      var factoryCalls = 0;
      final client = OpenAIClient(
        httpClient: shared,
        streamClientFactory: () {
          factoryCalls++;
          return dedicated;
        },
      )..updateConfig(baseUrl: 'https://new.invalid/v1');
      final abort = Completer<void>();
      await client.chat.completions
          .createStream(
            ChatCompletionCreateRequest(
              model: 'm',
              messages: [ChatMessage.user('x')],
            ),
            abortTrigger: abort.future,
          )
          .drain<void>();
      expect(factoryCalls, 1);
      expect(dedicated.closed, isTrue);
      expect(shared.closed, isFalse);
      client
        ..updateConfig()
        ..close()
        ..close();
      expect(shared.closed, isFalse);
    },
  );
}

class _HeaderProvider implements AuthProvider {
  _HeaderProvider(this.headers);
  final Map<String, String> headers;
  @override
  Map<String, String> getHeaders() => headers;
}

class _CallbackInterceptor implements Interceptor {
  _CallbackInterceptor(this.callback);
  final Future<http.Response> Function(RequestContext, InterceptorNext)
  callback;
  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) => callback(context, next);
}

class _SpyClient extends http.BaseClient {
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(Stream.value(utf8.encode('data: [DONE]\n\n')), 200);
  @override
  void close() => closed = true;
}

class _Socket implements ws.WebSocket {
  final controller = StreamController<ws.WebSocketEvent>();
  final sent = <String>[];
  bool closed = false;
  @override
  Stream<ws.WebSocketEvent> get events => controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) => sent.add(text);
  @override
  void sendBytes(Uint8List bytes) {}
  @override
  Future<void> close([int? code, String? reason]) async {
    if (closed) return;
    closed = true;
    unawaited(controller.close());
  }
}

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 1000; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  throw StateError('Synthetic recovery did not settle');
}
