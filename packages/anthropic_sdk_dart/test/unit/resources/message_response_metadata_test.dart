import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

final _request = MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 16,
  messages: [InputMessage.user('Hello')],
  stream: true,
);

void main() {
  for (final signed in [false, true]) {
    test(
      'malformed success redacts the effective credential (signed=$signed)',
      () async {
        const token = 'fixture-credential+/=opaque';
        final echo = signed ? Uri.encodeComponent(token) : token;
        final transport = MockClient((request) async {
          final credential =
              request.headers[signed ? 'x-amz-security-token' : 'x-api-key'];
          expect(credential, token);
          return http.Response(
            '{"malformed":"Bearer $echo',
            200,
            headers: {
              'content-type': 'application/json',
              'request-id': 'req_safe',
            },
          );
        });
        final client = signed
            ? AnthropicAwsClient(
                region: 'us-west-2',
                workspaceId: 'wrkspc_fixture',
                credentials: () => const ClaudeAwsCredentials(
                  accessKeyId: 'AKIDFIXTURE',
                  secretAccessKey: 'fixture-only-signing-secret',
                  sessionToken: token,
                ),
                httpClient: transport,
              )
            : AnthropicClient.withApiKey(token, httpClient: transport);
        addTearDown(client.close);
        await expectLater(
          client.messages.createWithResponse(_request),
          throwsA(
            isA<FormatException>()
                .having((error) => error.source, 'decoder source', isNull)
                .having(
                  (error) => error.toString(),
                  'diagnostic',
                  isNot(contains(echo)),
                ),
          ),
        );
      },
    );
  }

  test(
    'typed message decoder diagnostics redact the effective bearer',
    () async {
      const token = 'fixture-message-bearer+/=';
      final transport = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer $token');
        return _response(body: MockResponses.message()..['role'] = token);
      });
      final client = AnthropicClient.withAuthToken(
        token,
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        client.messages.createWithResponse(_request),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'diagnostic',
            isNot(contains(token)),
          ),
        ),
      );
    },
  );

  test('create and createWithResponse share the request and message', () async {
    final requests = <http.Request>[];
    final transport = MockClient((request) async {
      requests.add(request);
      return _response(
        status: 201,
        headers: {
          'Request-ID': 'req_from_provider',
          'Anthropic-Workspace-Id': 'wrkspc_from_provider',
        },
        body: MockResponses.message()
          ..['request_id'] = 'req_in_body'
          ..['workspace_id'] = 'wrkspc_in_body',
      );
    });
    addTearDown(transport.close);
    final client = AnthropicClient.withAuthToken(
      'fixture-oauth',
      config: const AnthropicConfig(
        baseUrl: 'https://fixture.invalid/proxy',
        workspaceId: 'wrkspc_default',
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
    final result = await client.messages.createWithResponse(
      _request,
      betas: ['caller-beta'],
      userProfileId: 'uprof_caller',
      workspaceId: 'wrkspc_caller',
    );
    expect(requests, hasLength(1));
    expect(result.statusCode, 201);
    expect(result.requestId, 'req_from_provider');
    expect(result.workspaceId, 'wrkspc_from_provider');
    final message = await client.messages.create(
      _request,
      betas: ['caller-beta'],
      userProfileId: 'uprof_caller',
      workspaceId: 'wrkspc_caller',
    );
    expect(requests, hasLength(2));
    expect(result.message, message);
    expect(result.message.toJson(), message.toJson());
    expect(result.message.toJson(), isNot(contains('request_id')));
    expect(result.message.toJson(), isNot(contains('workspace_id')));

    final request = requests.first;
    expect(request.method, 'POST');
    expect(request.url.toString(), 'https://fixture.invalid/proxy/v1/messages');
    expect(request.headers, containsPair('anthropic-version', '2026-10-21'));
    expect(
      request.headers,
      containsPair('anthropic-workspace-id', 'wrkspc_caller'),
    );
    expect(
      request.headers,
      containsPair('anthropic-user-profile-id', 'uprof_caller'),
    );
    expect(
      request.headers,
      containsPair('anthropic-beta', 'caller-beta,oauth-2025-04-20'),
    );
    expect(
      request.headers,
      containsPair('authorization', 'Bearer fixture-oauth'),
    );
    expect(request.body, requests.last.body);
    expect(jsonDecode(request.body), isNot(contains('stream')));
  });

  test(
    'omitted and blank headers do not reuse body or request values',
    () async {
      var calls = 0;
      final transport = MockClient((request) async {
        expect(request.headers['anthropic-workspace-id'], 'wrkspc_caller');
        expect(request.headers['x-request-id'], 'req_client');
        return _response(
          headers: calls++ == 0
              ? const {}
              : {'request-id': '   ', 'anthropic-workspace-id': ''},
          body: MockResponses.message()..['request_id'] = 'req_in_body',
        );
      });
      addTearDown(transport.close);
      final client = AnthropicClient(
        config: const AnthropicConfig(
          workspaceId: 'wrkspc_caller',
          defaultHeaders: {'X-Request-ID': 'req_client'},
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      for (var i = 0; i < 2; i++) {
        final result = await client.messages.createWithResponse(_request);
        expect(result.requestId, isNull);
        expect(result.workspaceId, isNull);
      }
      expect(calls, 2);
    },
  );

  for (final (provider, credentialHeader, credentialValue, echo) in [
    (
      const ApiKeyProvider('fixture-secret-key'),
      'x-api-key',
      'fixture-secret-key',
      'fixture-secret-key',
    ),
    (
      const BearerTokenProvider('fixture-secret-token'),
      'authorization',
      'Bearer fixture-secret-token',
      'fixture-secret-token',
    ),
  ]) {
    test('requestless response filters effective $credentialHeader', () async {
      final transport = MockClient((request) async {
        expect(request.headers[credentialHeader], credentialValue);
        return _response(
          headers: {
            'request-id': 'req_proxy_echo_$echo',
            'anthropic-workspace-id': credentialValue,
          },
        );
      });
      addTearDown(transport.close);
      final client = AnthropicClient(
        config: AnthropicConfig(authProvider: provider),
        httpClient: transport,
      );
      addTearDown(client.close);

      final result = await client.messages.createWithResponse(_request);
      expect(result.requestId, isNull);
      expect(result.workspaceId, isNull);
      expect(result.message.id, 'msg_test123');
    });
  }

  test(
    'transport-added authentication also filters echoed identifiers',
    () async {
      final transport = MockClient((request) async {
        final sent = http.Request(request.method, request.url)
          ..headers['authorization'] = 'Bearer fixture-transport-token';
        return _response(
          headers: {
            'request-id': 'req_safe',
            'anthropic-workspace-id': 'fixture-transport-token',
          },
          request: sent,
        );
      });
      addTearDown(transport.close);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final result = await client.messages.createWithResponse(_request);
      expect(result.requestId, 'req_safe');
      expect(result.workspaceId, isNull);
    },
  );

  test(
    'AWS metadata uses the provider ID after filtering escaped tokens',
    () async {
      const token = 'fixture-signing-token+/=';
      final transport = MockClient((request) async {
        expect(request.headers['x-amz-security-token'], token);
        return _response(
          headers: {
            'request-id': Uri.encodeComponent(token),
            'anthropic-workspace-id': 'prefix-${Uri.encodeComponent(token)}',
            'x-amzn-requestid': 'aws_request_fixture',
          },
        );
      });
      addTearDown(transport.close);
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: 'wrkspc_fixture',
        credentials: () => const ClaudeAwsCredentials(
          accessKeyId: 'AKIDFIXTURE',
          secretAccessKey: 'fixture-only-signing-secret',
          sessionToken: token,
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      final result = await client.messages.createWithResponse(_request);
      expect(result.requestId, 'aws_request_fixture');
      expect(result.awsRequestId, 'aws_request_fixture');
      expect(result.azureRequestId, isNull);
      expect(result.workspaceId, isNull);
      expect(result.message.id, 'msg_test123');
    },
  );

  for (final aws in [false, true]) {
    test('success keeps Claude and platform tracing IDs (aws=$aws)', () async {
      const token = 'fixture-platform-key+/=';
      final transport = MockClient((request) async {
        expect(
          request.headers[aws ? 'authorization' : 'x-api-key'],
          aws ? 'Bearer $token' : token,
        );
        return _response(
          headers: {
            'request-id': 'req_claude',
            'x-amzn-requestid': aws
                ? 'req_cloudtrail'
                : Uri.encodeComponent(token),
            'apim-request-id': aws ? Uri.encodeComponent(token) : 'req_azure',
          },
        );
      });
      final client = aws
          ? AnthropicAwsClient(
              region: 'us-west-2',
              workspaceId: 'wrkspc_fixture',
              apiKey: token,
              httpClient: transport,
            )
          : AnthropicFoundryClient(
              resource: 'fixture-resource',
              apiKey: token,
              httpClient: transport,
            );
      addTearDown(client.close);

      final result = await client.messages.createWithResponse(_request);
      expect(result.requestId, 'req_claude');
      expect(result.awsRequestId, aws ? 'req_cloudtrail' : isNull);
      expect(result.azureRequestId, aws ? isNull : 'req_azure');
    });
  }

  test(
    'AWS compatibility headers supply the platform ID when available',
    () async {
      final client = AnthropicClient(
        httpClient: MockClient(
          (_) async => _response(
            headers: {
              'x-amzn-requestid': ' ',
              'X-Amzn-Request-Id': 'req_aws_alias',
              'x-amz-request-id': 'req_aws_fallback',
            },
          ),
        ),
      );
      addTearDown(client.close);
      final result = await client.messages.createWithResponse(_request);
      expect(result.awsRequestId, 'req_aws_alias');
      expect(result.requestId, 'req_aws_alias');
    },
  );

  test('error keeps its type and diagnostics with one request', () async {
    var calls = 0;
    final transport = MockClient((request) async {
      calls++;
      return _response(
        status: 400,
        headers: {'request-id': 'req_failure'},
        body: {
          'type': 'error',
          'error': {
            'type': 'invalid_request_error',
            'message': 'Fixture invalid input',
            'details': {'error_code': 'fixture_code'},
          },
        },
      );
    });
    addTearDown(transport.close);
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    for (final create in [
      client.messages.create,
      client.messages.createWithResponse,
    ]) {
      await expectLater(
        create(_request),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 400)
              .having((e) => e.requestId, 'request ID', 'req_failure')
              .having((e) => e.errorCode, 'error code', 'fixture_code'),
        ),
      );
    }
    expect(calls, 2);
  });

  test('metadata belongs to the successful retry response', () async {
    var calls = 0;
    final transport = MockClient((request) async {
      if (calls++ == 0) {
        return _response(
          status: 429,
          headers: {'request-id': 'req_first'},
          body: {
            'type': 'error',
            'error': {'type': 'rate_limit_error', 'message': 'Retry'},
          },
        );
      }
      return _response(headers: {'request-id': 'req_success'});
    });
    addTearDown(transport.close);
    final client = AnthropicClient(
      config: const AnthropicConfig(
        retryPolicy: RetryPolicy(
          maxRetries: 1,
          initialDelay: Duration.zero,
          maxDelay: Duration.zero,
          jitter: 0,
        ),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
    final result = await client.messages.createWithResponse(_request);
    expect(result.requestId, 'req_success');
    expect(calls, 2);
  });

  test(
    'success metadata filters credentials from an earlier cloud attempt',
    () async {
      const oldToken = 'fixture-old-cloud-session+/=';
      const newToken = 'fixture-new-cloud-session+/=';
      var calls = 0;
      var authCalls = 0;
      final transport = MockClient((request) async {
        calls++;
        expect(
          request.headers['x-amz-security-token'],
          calls == 1 ? oldToken : newToken,
        );
        if (calls == 1) return _response(status: 429);
        return _response(
          headers: {
            'request-id': Uri.encodeComponent(oldToken),
            'x-amzn-requestid': 'req_safe_fallback',
            'anthropic-workspace-id': newToken,
          },
        );
      });
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: 'wrkspc_fixture',
        credentials: () => ClaudeAwsCredentials(
          accessKeyId: 'AKIDFIXTURE',
          secretAccessKey: 'fixture-only-signing-secret',
          sessionToken: ++authCalls == 1 ? oldToken : newToken,
        ),
        config: const AnthropicConfig(
          retryPolicy: RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
            jitter: 0,
          ),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);

      final result = await client.messages.createWithResponse(_request);
      expect(result.requestId, 'req_safe_fallback');
      expect(result.workspaceId, isNull);
      expect(calls, 2);
    },
  );

  test('concurrent requests filter their own post-auth credentials', () async {
    final firstSent = Completer<void>();
    final finishFirst = Completer<void>();
    var calls = 0;
    final transport = MockClient((request) async {
      switch (calls++) {
        case 0:
          expect(request.headers['authorization'], 'Bearer fixture-token-0');
          firstSent.complete();
          await finishFirst.future;
          return _response(headers: {'request-id': 'fixture-token-0'});
        case 1:
          expect(request.headers['authorization'], 'Bearer fixture-token-1');
          return _response(
            headers: {
              'request-id': 'req_second',
              'anthropic-workspace-id': 'fixture-token-1',
            },
            request: http.Request(request.method, request.url)
              ..headers['authorization'] =
                  'Bearer fixture-wrong-response-request',
          );
        default:
          fail('Unexpected transport call');
      }
    });
    addTearDown(transport.close);
    final client = AnthropicClient(
      config: AnthropicConfig(authProvider: _ChangingBearer()),
      httpClient: transport,
    );
    addTearDown(client.close);

    final first = client.messages.createWithResponse(_request);
    await firstSent.future;
    final second = await client.messages.createWithResponse(_request);
    finishFirst.complete();
    expect((await first).requestId, isNull);
    expect(second.requestId, 'req_second');
    expect(second.workspaceId, isNull);
    expect(calls, 2);
  });

  test('abort during authentication suppresses late dispatch', () async {
    final provider = _GatedBearer();
    final abort = Completer<void>();
    var calls = 0;
    final transport = MockClient((request) async {
      calls++;
      return _response(headers: {'request-id': 'req_sibling'});
    });
    addTearDown(transport.close);
    final client = AnthropicClient(
      config: AnthropicConfig(authProvider: provider),
      httpClient: transport,
    );
    addTearDown(client.close);

    final operation = client.messages.createWithResponse(
      _request,
      abortTrigger: abort.future,
    );
    final failure = expectLater(operation, throwsA(isA<AbortedException>()));
    await provider.entered.future;
    abort.complete();
    await failure;
    provider.credentials.complete(
      const BearerTokenCredentials('fixture-token'),
    );
    final sibling = await client.messages.createWithResponse(_request);
    expect(sibling.requestId, 'req_sibling');
    expect(calls, 1);
  });

  test(
    'canceling a successful response body releases borrowed transport',
    () async {
      final abort = Completer<void>();
      final started = Completer<void>();
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(
        onListen: started.complete,
        onCancel: canceled.complete,
      );
      addTearDown(() => unawaited(body.close()));
      var calls = 0;
      final transport = MockClient.streaming((request, _) async {
        if (calls++ == 0) {
          return http.StreamedResponse(
            body.stream,
            200,
            headers: {'request-id': 'req_unfinished'},
          );
        }
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode(MockResponses.message()))),
          200,
          headers: {'request-id': 'req_after_abort'},
        );
      });
      addTearDown(transport.close);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final operation = client.messages.createWithResponse(
        _request,
        abortTrigger: abort.future,
      );
      final failure = expectLater(operation, throwsA(isA<AbortedException>()));
      await started.future;
      abort.complete();
      await failure;
      await canceled.future.timeout(const Duration(seconds: 2));
      expect(calls, 1);
      final next = await client.messages.createWithResponse(_request);
      expect(next.requestId, 'req_after_abort');
      expect(calls, 2);
    },
  );
}

http.Response _response({
  int status = 200,
  Map<String, String> headers = const {},
  Map<String, Object?>? body,
  http.BaseRequest? request,
}) => http.Response(
  jsonEncode(body ?? MockResponses.message()),
  status,
  headers: {'content-type': 'application/json', ...headers},
  request: request,
);

final class _ChangingBearer implements AuthProvider {
  int _calls = 0;

  @override
  Future<AuthCredentials> getCredentials() async =>
      BearerTokenCredentials('fixture-token-${_calls++}');
}

final class _GatedBearer implements AuthProvider {
  final entered = Completer<void>();
  final credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    if (!entered.isCompleted) entered.complete();
    return credentials.future;
  }
}
