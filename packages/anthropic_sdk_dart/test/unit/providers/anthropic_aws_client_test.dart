import 'dart:async' hide TimeoutException;
import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/providers/aws_signing.dart';
import 'package:anthropic_sdk_dart/src/providers/provider_transport.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _iam = ClaudeAwsCredentials(
  accessKeyId: 'AKIDEXAMPLE',
  secretAccessKey: 'fixture_secret',
  sessionToken: 'fixture_session',
);
const _key = 'aws-bearer-fixture';
const _workspace = 'wrkspc_fixture';
final _message = MessageCreateRequest(
  model: 'claude-fixture',
  maxTokens: 32,
  messages: [InputMessage.user('héllo')],
);

void main() {
  _sseRequestIdTests();
  test(
    'worker poll uses the resolved workspace and AWS authentication',
    () async {
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: _workspace,
        credentials: () => _iam,
        httpClient: MockClient((request) async {
          expect(request.url.path, '/v1/environments/env_fixture/work/poll');
          expect(request.headers['anthropic-workspace-id'], _workspace);
          expect(
            request.headers['authorization'],
            startsWith('AWS4-HMAC-SHA256 '),
          );
          expect(request.headers['x-amz-security-token'], _iam.sessionToken);
          return http.Response('null', 200);
        }),
      );
      addTearDown(client.close);
      expect(await client.environments.work('env_fixture').poll(), isNull);
    },
  );

  test(
    'resolved workspace overrides defaults and keeps call overrides',
    () async {
      final workspaces = <String?>[];
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: _workspace,
        apiKey: _key,
        config: const AnthropicConfig(
          defaultHeaders: {'Anthropic-Workspace-ID': 'wrkspc_old_default'},
        ),
        httpClient: MockClient((request) async {
          workspaces.add(request.headers['anthropic-workspace-id']);
          return _messageResponse();
        }),
      );
      addTearDown(client.close);
      await client.messages.create(_message);
      await client.messages.create(_message, workspaceId: 'wrkspc_override');
      expect(workspaces, [_workspace, 'wrkspc_override']);
    },
  );

  test(
    'action URLs and untrusted absolute request URLs fail before send',
    () async {
      final transport = _Borrowed();
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: _workspace,
        apiKey: _key,
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        client.userProfiles.current.createActionUrl(
          'uprof_fixture',
          action: UserProfileAction.enrollEndUser,
        ),
        throwsUnsupportedError,
      );
      await expectLater(
        client.interceptorChain.execute(
          http.Request('GET', Uri.https('untrusted.invalid', '/v1/models')),
        ),
        throwsArgumentError,
      );
      expect(transport.requests, isEmpty);
    },
  );

  test('skipAuth keeps explicit gateway authentication', () async {
    final client = AnthropicAwsClient(
      baseUrl: 'https://gateway.invalid/proxy',
      skipAuth: true,
      config: const AnthropicConfig(
        defaultHeaders: {'X-Api-Key': 'gateway-fixture'},
      ),
      httpClient: MockClient((request) async {
        expect(request.headers['x-api-key'], 'gateway-fixture');
        expect(request.headers['authorization'], isNull);
        return _messageResponse();
      }),
    );
    addTearDown(client.close);
    expect((await client.messages.create(_message)).id, 'msg_fixture');
  });

  test('SigV4 signs the final body, escaped path and repeated query', () {
    // Expected signature produced by AWS botocore SigV4Auth 1.41.5.
    final request = ProviderRequest(
      method: 'POST',
      uri: Uri.parse(
        'https://aws-external-anthropic.us-west-2.api.aws'
        '/proxy/v1/files/id%2Ftest?types%5B%5D=b&types%5B%5D=a&tag=a+b&tag=a%2Bb',
      ),
      headers: {
        'content-type': 'application/json',
        'anthropic-version': '2026-10-21',
        'anthropic-workspace-id': _workspace,
      },
      body: Uint8List.fromList(utf8.encode('{"input":"héllo"}')),
    );
    signAwsRequest(
      request,
      credentials: _iam,
      region: 'us-west-2',
      service: 'aws-external-anthropic',
      now: DateTime.utc(2026, 11, 12, 0, 0, 1),
    );
    final signed = [
      'anthropic-version',
      'anthropic-workspace-id',
      'content-type',
      'host',
      'x-amz-content-sha256',
      'x-amz-date',
      'x-amz-security-token',
    ].join(';');
    const scope =
        'AKIDEXAMPLE/20261112/us-west-2/aws-external-anthropic/aws4_request';
    expect(
      request.headers['authorization'],
      'AWS4-HMAC-SHA256 Credential=$scope, SignedHeaders=$signed, '
      'Signature=c90c8bba6118a8dc3bc5fdc7787a931a124b14d28735b6949b61cb5e1448a18b',
    );
    expect(request.uri.query, contains('tag=a%20b&tag=a%2Bb'));
    expect(request.headers['x-amz-date'], '20261112T000001Z');
    expect(request.headers['x-amz-security-token'], _iam.sessionToken);
    expect(_iam.toString(), isNot(contains(_iam.secretAccessKey)));
  });

  test(
    'AWS key uses regional Claude routes and no first-party API key',
    () async {
      final requests = <http.Request>[];
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: _workspace,
        apiKey: _key,
        config: const AnthropicConfig(defaultHeaders: {'X-API-Key': 'discard'}),
        httpClient: MockClient((request) async {
          requests.add(request);
          if ((jsonDecode(request.body) as Map<String, dynamic>)['stream'] ==
              true) {
            return http.Response(
              'data: {"type":"message_stop"}\n\n',
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          }
          return _messageResponse();
        }),
      );
      addTearDown(client.close);
      expect((await client.messages.create(_message)).id, 'msg_fixture');
      expect(
        await client.messages.createStream(_message).single,
        isA<MessageStopEvent>(),
      );
      expect(requests, hasLength(2));
      for (final request in requests) {
        expect(request.url.host, 'aws-external-anthropic.us-west-2.api.aws');
        expect(request.url.path, '/v1/messages');
        expect(request.headers['anthropic-workspace-id'], _workspace);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['authorization'], 'Bearer $_key');
        expect(request.headers['x-api-key'], isNull);
        expect(request.followRedirects, isFalse);
      }
    },
  );

  test(
    'IAM credentials resolve after routing and never leak on late abort',
    () async {
      final entered = Completer<void>();
      final credential = Completer<ClaudeAwsCredentials>();
      final abort = Completer<void>();
      final transport = _Borrowed();
      final client = AnthropicAwsClient(
        region: 'us-east-1',
        workspaceId: _workspace,
        baseUrl: 'https://fixture.invalid/proxy/?tag=a+b&tag=a%2Bb',
        credentials: () {
          if (!entered.isCompleted) entered.complete();
          return credential.future;
        },
        httpClient: transport,
      );
      addTearDown(client.close);
      final canceled = expectLater(
        client.messages
            .create(_message, abortTrigger: abort.future)
            .timeout(const Duration(seconds: 2)),
        throwsA(isA<AbortedException>()),
      );
      await entered.future;
      abort.complete();
      await canceled;
      expect(transport.requests, isEmpty);
      credential.complete(_iam);
      await Future<void>.delayed(Duration.zero);
      expect(transport.requests, isEmpty);

      expect((await client.messages.create(_message)).id, 'msg_fixture');
      final request = transport.requests.single;
      expect(request.url.path, '/proxy/v1/messages');
      expect(request.url.query, 'tag=a%20b&tag=a%2Bb');
      expect(
        request.headers['authorization'],
        contains('/us-east-1/aws-external-anthropic/aws4_request'),
      );
      expect(request.headers['x-amz-security-token'], _iam.sessionToken);
      expect(request.headers['x-api-key'], isNull);
      client.close();
      expect(transport.closes, 0);
    },
  );

  for (final (name, send)
      in <(String, Future<Object?> Function(AnthropicAwsClient))>[
        ('buffered', (client) => client.messages.create(_message)),
        (
          'streaming',
          (client) => client.messages.createStream(_message).single,
        ),
        (
          'multipart',
          (client) => client.files.uploadBytes(
            bytes: Uint8List.fromList([0, 128, 255]),
            fileName: 'fixture.bin',
          ),
        ),
      ]) {
    test(
      '$name deadline covers credentials and prevents a late send',
      () async {
        final started = Completer<void>();
        final credentials = Completer<ClaudeAwsCredentials>();
        final transport = _Borrowed();
        var calls = 0;
        final client = AnthropicAwsClient(
          region: 'us-east-1',
          workspaceId: _workspace,
          credentials: () {
            if (++calls > 1) return _iam;
            started.complete();
            return credentials.future;
          },
          config: const AnthropicConfig(
            timeout: Duration(milliseconds: 100),
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        final timedOut = expectLater(
          send(client),
          throwsA(isA<TimeoutException>()),
        );
        await started.future;
        await timedOut;
        expect(transport.requests, isEmpty);

        expect((await client.messages.create(_message)).id, 'msg_fixture');
        credentials.complete(_iam);
        await _flushPreparation();
        expect(transport.requests, hasLength(1));
        client.close();
        expect(transport.closes, 0);
      },
    );
  }

  test(
    'closing ends pending credential admission without waiting for it',
    () async {
      final started = Completer<void>();
      final credentials = Completer<ClaudeAwsCredentials>();
      final transport = _Borrowed();
      final client = AnthropicAwsClient(
        region: 'us-east-1',
        workspaceId: _workspace,
        credentials: () {
          started.complete();
          return credentials.future;
        },
        httpClient: transport,
      );
      addTearDown(client.close);

      final closed = expectLater(
        client.messages.create(_message),
        throwsA(isA<StateError>()),
      );
      await started.future;
      try {
        client.close();
        await closed.timeout(const Duration(seconds: 1));
        expect(transport.requests, isEmpty);
        expect(transport.closes, 0);
      } finally {
        credentials.complete(_iam);
        await _flushPreparation();
      }
      expect(transport.requests, isEmpty);

      final sibling = AnthropicAwsClient(
        region: 'us-east-1',
        workspaceId: _workspace,
        credentials: () => _iam,
        httpClient: transport,
      );
      addTearDown(sibling.close);
      expect((await sibling.messages.create(_message)).id, 'msg_fixture');
      expect(transport.requests, hasLength(1));
    },
  );

  test('canceling the stream discards credentials without sending', () async {
    final started = Completer<void>();
    final credentials = Completer<ClaudeAwsCredentials>();
    final transport = _Borrowed();
    final client = AnthropicAwsClient(
      region: 'us-east-1',
      workspaceId: _workspace,
      credentials: () {
        started.complete();
        return credentials.future;
      },
      httpClient: transport,
    );
    addTearDown(client.close);
    final subscription = client.messages
        .createStream(_message)
        .listen(
          (_) => fail('Unexpected stream event'),
          onError: (Object error) => fail('Unexpected stream error: $error'),
        );
    await started.future;
    await subscription.cancel();
    credentials.complete(_iam);
    await _flushPreparation();
    expect(transport.requests, isEmpty);
    expect(transport.closes, 0);
  });

  test('native AWS signs the finalized multipart body and boundary', () async {
    final client = AnthropicAwsClient(
      region: 'us-east-1',
      workspaceId: _workspace,
      credentials: () => _iam,
      httpClient: MockClient((request) async {
        expect(request.url.path, '/v1/files');
        final contentType = request.headers['content-type']!;
        expect(contentType, startsWith('multipart/form-data; boundary='));
        final boundary = contentType.split('boundary=').last;
        expect(request.body, contains('--$boundary\r\n'));
        expect(request.body, contains('filename="fixture.txt"'));
        expect(request.body, contains('multipart payload'));
        expect(
          request.headers['x-amz-content-sha256'],
          sha256.convert(request.bodyBytes).toString(),
        );
        expect(request.headers['authorization'], contains('content-type;host'));
        return http.Response(
          '{"id":"file_fixture","filename":"fixture.txt","mime_type":"text/plain",'
          '"size_bytes":17,"created_at":"2026-11-11T00:00:00Z"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.close);
    final response = await client.files.uploadBytes(
      bytes: Uint8List.fromList(utf8.encode('multipart payload')),
      fileName: 'fixture.txt',
    );
    expect(response.id, 'file_fixture');
  });

  test('workspace routing differs between inference and Compliance', () async {
    final requests = <http.Request>[];
    final client = AnthropicAwsClient(
      region: 'us-east-1',
      workspaceId: _workspace,
      credentials: () => _iam,
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(
          '{"data":[],"has_more":false,"first_id":null,"last_id":null}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.close);
    expect((await client.compliance.listActivities()).data, isEmpty);
    expect(requests.single.url.path, '/v1/compliance/activities');
    expect(requests.single.headers['anthropic-workspace-id'], isNull);
    expect(
      requests.single.headers['authorization'],
      contains('AWS4-HMAC-SHA256'),
    );
  });

  test('AWS request ID is available on an SSE handshake error', () async {
    final client = AnthropicAwsClient(
      baseUrl: 'https://fixture.invalid/proxy',
      workspaceId: _workspace,
      apiKey: _key,
      httpClient: MockClient(
        (_) async => http.Response(
          '{"message":"Unavailable"}',
          503,
          headers: {
            'content-type': 'application/json',
            'x-amzn-requestid': 'aws_trace',
          },
        ),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.messages.createStream(_message).drain<void>(),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 503)
            .having((error) => error.requestId, 'request ID', 'aws_trace')
            .having(
              (error) => error.responseMetadata!.headers['x-amzn-requestid'],
              'AWS trace ID',
              'aws_trace',
            ),
      ),
    );
  });

  test('an explicit Claude request ID wins over the AWS trace ID', () async {
    final client = AnthropicAwsClient(
      baseUrl: 'https://fixture.invalid/proxy',
      workspaceId: _workspace,
      apiKey: _key,
      config: const AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
      httpClient: MockClient(
        (_) async => http.Response(
          '{"message":"Unavailable"}',
          503,
          headers: {
            'content-type': 'application/json',
            'request-id': 'req_claude',
            'x-amzn-requestid': 'aws_trace',
          },
        ),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.models.list(),
      throwsA(
        isA<ApiException>()
            .having(
              (error) => error.requestId,
              'Claude request ID',
              'req_claude',
            )
            .having(
              (error) => error.responseMetadata!.headers['x-amzn-requestid'],
              'AWS trace ID',
              'aws_trace',
            ),
      ),
    );
  });
}

void _sseRequestIdTests() {
  for (final (header, body, expected) in <(String?, String?, String)>[
    ('req_claude', 'req_body', 'req_claude'),
    (null, 'req_body', 'req_body'),
    (null, null, 'aws_trace'),
  ]) {
    test('AWS SSE request ID precedence ($expected)', () async {
      final transport = MockClient((_) async {
        final event = jsonEncode({
          'type': 'error',
          'error': {'type': 'overloaded_error', 'message': 'Fixture'},
          'request_id': ?body,
        });
        return http.Response(
          'event: error\ndata: $event\n\n',
          200,
          headers: {
            'content-type': 'text/event-stream',
            'request-id': ?header,
            'x-amzn-requestid': 'aws_trace',
          },
        );
      });
      addTearDown(transport.close);
      final client = AnthropicAwsClient(
        region: 'us-east-1',
        workspaceId: _workspace,
        apiKey: _key,
        httpClient: transport,
      );
      addTearDown(client.close);
      final error =
          await client.messages.createStream(_message).single as ErrorEvent;
      expect(error.requestId, expected);
      expect(error.responseMetadata?.bodyRequestId, body);
      expect(error.responseMetadata?.headers['x-amzn-requestid'], 'aws_trace');
    });
  }
}

Future<void> _flushPreparation() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

http.Response _messageResponse() => http.Response(
  '{"id":"msg_fixture","type":"message","role":"assistant",'
  '"model":"claude-fixture","content":[],"stop_reason":"end_turn",'
  '"stop_sequence":null,"usage":{"input_tokens":2,"output_tokens":1}}',
  200,
  headers: {'content-type': 'application/json'},
);

class _Borrowed extends http.BaseClient {
  final requests = <http.Request>[];
  int closes = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      MockClient((r) async {
        requests.add(r);
        return _messageResponse();
      }).send(request);

  @override
  void close() => closes++;
}
