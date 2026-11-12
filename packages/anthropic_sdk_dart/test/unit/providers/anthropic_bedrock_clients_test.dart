import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _arn =
    'arn:aws:bedrock:us-east-1:123:inference-profile/us.anthropic.claude-sonnet-5-5';
const _token = 'fixture-bedrock-key';
const _fixture =
    '{"id":"msg_fixture","type":"message","role":"assistant",'
    '"model":"fixture","content":[],"stop_reason":"end_turn",'
    '"stop_sequence":null,"usage":{"input_tokens":3,"output_tokens":1}}';
// Independent fixtures encoded by Python struct/zlib using the AWS frame spec.
const _stop =
    'AAAAhwAAAEuH6ivzDTptZXNzYWdlLXR5cGUHAAVldmVudAs6ZXZlbnQtdHlwZQcABWNodW5rDTpjb250ZW50LXR5cGUHABBhcHBsaWNhdGlvbi9qc29ueyJieXRlcyI6ImV5SjBlWEJsSWpvaWJXVnpjMkZuWlY5emRHOXdJbjA9In1YpN0u';
const _delta =
    'AAAA2wAAAEt6CQk5DTptZXNzYWdlLXR5cGUHAAVldmVudAs6ZXZlbnQtdHlwZQcABWNodW5rDTpjb250ZW50LXR5cGUHABBhcHBsaWNhdGlvbi9qc29ueyJieXRlcyI6ImV5SjBlWEJsSWpvaVkyOXVkR1Z1ZEY5aWJHOWphMTlrWld4MFlTSXNJbWx1WkdWNElqb3dMQ0prWld4MFlTSTZleUowZVhCbElqb2lkR1Y0ZEY5a1pXeDBZU0lzSW5SbGVIUWlPaUpvdzZsc2JHOGlmWDA9In314jsG';
const _keepAlive =
    'AAAAewAAAEsKLpavDTptZXNzYWdlLXR5cGUHAAVldmVudAs6ZXZlbnQtdHlwZQcABWNodW5rDTpjb250ZW50LXR5cGUHABBhcHBsaWNhdGlvbi9qc29ueyJieXRlcyI6ImV5SjFiblZ6WldRaU9uUnlkV1Y5In0WajL5';
const _error =
    'AAAAkAAAAGGOkam3DTptZXNzYWdlLXR5cGUHAAlleGNlcHRpb24POmV4Y2VwdGlvbi10eXBlBwATdGhyb3R0bGluZ0V4Y2VwdGlvbg06Y29udGVudC10eXBlBwAQYXBwbGljYXRpb24vanNvbnsibWVzc2FnZSI6ImZpeHR1cmUgdGhyb3R0bGVkIn0KF40f';
const _credentialError =
    'AAAAqAAAAGEfwFrwDTptZXNzYWdlLXR5cGUHAAlleGNlcHRpb24POmV4Y2VwdGlvbi10eXBlBwATdGhyb3R0bGluZ0V4Y2VwdGlvbg06Y29udGVudC10eXBlBwAQYXBwbGljYXRpb24vanNvbnsibWVzc2FnZSI6ImZpeHR1cmUgdGhyb3R0bGVkIGZvciBmaXh0dXJlLWJlZHJvY2sta2V5In2r17GP';

MessageCreateRequest _request([String model = _arn]) => MessageCreateRequest(
  model: model,
  maxTokens: 50,
  messages: [InputMessage.user('Hello')],
);

void main() {
  test('Mantle sends native Messages and token-counting routes', () async {
    final requests = <http.Request>[];
    final client = AnthropicBedrockMantleClient(
      region: 'us-west-2',
      apiKey: _token,
      config: const AnthropicConfig(workspaceId: 'unused-workspace'),
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/count_tokens')) {
          return _json('{"input_tokens":3}');
        }
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['stream'] == true) {
          return http.Response(
            'data: {"type":"message_stop"}\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        return _json(_fixture);
      }),
    );
    addTearDown(client.close);
    const mantleModel = 'anthropic.claude-sonnet-5-5';
    expect(
      (await client.messages.create(_request(mantleModel))).id,
      'msg_fixture',
    );
    expect(
      await client.messages.createStream(_request(mantleModel)).single,
      isA<MessageStopEvent>(),
    );
    final count = await client.messages.countTokens(
      TokenCountRequest(
        model: mantleModel,
        messages: [InputMessage.user('Hello')],
      ),
    );
    expect(count.inputTokens, 3);
    expect(requests.map((r) => r.url.path), [
      '/anthropic/v1/messages',
      '/anthropic/v1/messages',
      '/anthropic/v1/messages/count_tokens',
    ]);
    for (final r in requests) {
      expect(r.url.host, 'bedrock-mantle.us-west-2.api.aws');
      expect(r.headers['authorization'], 'Bearer $_token');
      expect(r.headers['x-api-key'], isNull);
      expect(r.headers['anthropic-workspace-id'], isNull);
      expect(r.headers['anthropic-version'], '2026-10-21');
      expect(jsonDecode(r.body), containsPair('model', mantleModel));
    }
    expect(
      (await client.messages.create(
        _request(mantleModel),
        userProfileId: 'uprof_fixture',
      )).id,
      'msg_fixture',
    );
    expect(
      jsonDecode(requests.last.body),
      containsPair('user_profile_id', 'uprof_fixture'),
    );
    expect(requests.last.headers, isNot(contains('anthropic-user-profile-id')));
    await expectLater(client.models.list(), throwsUnsupportedError);
    await expectLater(
      client.messages.create(
        _request(
          mantleModel,
        ).copyWith(fallbacks: const FallbacksParam.defaultMode()),
      ),
      throwsUnsupportedError,
    );
    expect(requests, hasLength(4));
  });

  test(
    'Runtime moves model, beta and legacy version into the wire shape',
    () async {
      final requests = <http.Request>[];
      final client = AnthropicBedrockClient(
        region: 'us-east-1',
        baseUrl: 'https://fixture.invalid/proxy/?beta=true&keep=a&keep=b',
        apiKey: _token,
        config: const AnthropicConfig(
          apiVersion: 'bedrock-2023-05-31',
          defaultHeaders: {'Anthropic-Beta': 'beta-a, beta-b'},
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          return _json(
            request.url.path.endsWith('/count-tokens')
                ? '{"inputTokens":7}'
                : _fixture,
          );
        }),
      );
      addTearDown(client.close);
      expect((await client.messages.create(_request())).id, 'msg_fixture');
      expect((await client.countInvokeTokens(_request())).inputTokens, 7);
      expect(requests.map((r) => r.url.pathSegments), [
        ['proxy', 'model', _arn, 'invoke'],
        ['proxy', 'model', _arn, 'count-tokens'],
      ]);
      for (final r in requests) {
        expect(r.url.path, contains('inference-profile%2Fus.anthropic'));
        expect(r.url.queryParametersAll, {
          'keep': ['a', 'b'],
        });
        expect(r.headers['authorization'], 'Bearer $_token');
        expect(r.headers['anthropic-version'], isNull);
      }
      final inferBody = jsonDecode(requests[0].body) as Map<String, dynamic>;
      final outer = jsonDecode(requests[1].body) as Map<String, dynamic>;
      final input = outer['input'] as Map<String, dynamic>;
      final invoke = input['invokeModel'] as Map<String, dynamic>;
      final countBody = jsonDecode(
        utf8.decode(base64Decode(invoke['body'] as String)),
      );
      expect(
        inferBody,
        containsPair('anthropic_version', 'bedrock-2023-05-31'),
      );
      expect(inferBody, containsPair('anthropic_beta', ['beta-a', 'beta-b']));
      expect(inferBody, containsPair('max_tokens', 50));
      expect(inferBody, isNot(contains('model')));
      expect(inferBody, isNot(contains('stream')));
      expect(countBody, inferBody);
      await expectLater(
        client.messages.create(_request('..;route')),
        throwsArgumentError,
      );
      await expectLater(
        client.messages.create(_request(), userProfileId: 'uprof_fixture'),
        throwsUnsupportedError,
      );
      expect(requests, hasLength(2));
    },
  );

  test('Runtime count uses the retry chain and signs every attempt', () async {
    final requests = <http.Request>[];
    var calls = 0;
    final client = AnthropicBedrockClient(
      region: 'us-east-1',
      credentials: () => ClaudeAwsCredentials(
        accessKeyId: 'fixture-${++calls}',
        secretAccessKey: 'fixture-secret',
      ),
      config: const AnthropicConfig(
        retryPolicy: RetryPolicy(
          maxRetries: 1,
          initialDelay: Duration.zero,
          jitter: 0,
        ),
      ),
      httpClient: MockClient((request) async {
        requests.add(request);
        if (requests.length == 1) {
          return http.Response('{"message":"Throttled"}', 429);
        }
        return _json('{"inputTokens":7}');
      }),
    );
    addTearDown(client.close);
    expect((await client.countInvokeTokens(_request())).inputTokens, 7);
    expect(requests, hasLength(2));
    expect(requests.first.body, requests.last.body);
    expect(
      requests.first.headers['authorization'],
      contains('Credential=fixture-1/'),
    );
    expect(
      requests.last.headers['authorization'],
      contains('Credential=fixture-2/'),
    );
    client.close();
    await expectLater(client.countInvokeTokens(_request()), throwsStateError);
    expect(calls, 2);
  });

  test(
    'Runtime decodes fragmented event frames and ignores keep-alives',
    () async {
      final transport = _FrameTransport([
        ...base64Decode(_keepAlive),
        ...base64Decode(_delta),
        ...base64Decode(_stop),
      ]);
      final client = AnthropicBedrockClient(
        region: 'us-east-1',
        apiKey: _token,
        httpClient: transport,
      );
      addTearDown(client.close);
      final events = await client.messages.createStream(_request()).toList();
      expect(events.map((event) => event.runtimeType), [
        ContentBlockDeltaEvent,
        MessageStopEvent,
      ]);
      expect(
        (events.first as ContentBlockDeltaEvent).delta.toJson()['text'],
        'héllo',
      );
      final r = transport.request!;
      expect(r.url.host, 'bedrock-runtime.us-east-1.amazonaws.com');
      expect(r.url.pathSegments, [
        'model',
        _arn,
        'invoke-with-response-stream',
      ]);
      expect(r.headers['x-amzn-bedrock-accept'], 'application/json');
      expect(r.headers['accept'], 'application/vnd.amazon.eventstream');
      final body = jsonDecode(transport.body!) as Map<String, dynamic>;
      expect(body['anthropic_version'], '2026-10-21');
      expect(body, isNot(contains('stream')));
      expect(body, isNot(contains('model')));
    },
  );

  test('Runtime only adapts the Bedrock EventStream media type', () async {
    var calls = 0;
    final client = AnthropicBedrockClient(
      region: 'us-east-1',
      apiKey: _token,
      httpClient: MockClient((request) async {
        expect(request.url.path, endsWith('/invoke-with-response-stream'));
        calls++;
        if (calls == 1) {
          return http.Response(
            'data: {"type":"message_stop"}\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        return _json('{"status":"gateway response"}');
      }),
    );
    addTearDown(client.close);
    expect(
      await client.messages.createStream(_request()).single,
      isA<MessageStopEvent>(),
    );
    expect(await client.messages.createStream(_request()).toList(), isEmpty);
    expect(calls, 2);
  });

  test(
    'Bedrock does not sign or send a request outside its base path',
    () async {
      var authCalls = 0;
      var requests = 0;
      final client = AnthropicBedrockMantleClient(
        region: 'us-east-1',
        baseUrl: 'https://gateway.example/scope/anthropic',
        credentials: () {
          authCalls++;
          return const ClaudeAwsCredentials(
            accessKeyId: 'test',
            secretAccessKey: 'test',
          );
        },
        httpClient: MockClient((request) async {
          requests++;
          return _json(_fixture);
        }),
      );
      addTearDown(client.close);

      final request = http.Request(
        'POST',
        Uri.parse('https://gateway.example/wrong/anthropic/v1/messages'),
      )..body = jsonEncode(_request().toJson());
      await expectLater(
        client.interceptorChain.execute(request),
        throwsArgumentError,
      );
      expect(authCalls, 0);
      expect(requests, 0);
    },
  );

  test('Runtime exception frames become one typed error event', () async {
    final transport = _FrameTransport([
      ...base64Decode(_error),
      ...base64Decode(_stop),
    ]);
    final client = AnthropicBedrockClient(
      region: 'us-east-1',
      apiKey: _token,
      httpClient: transport,
    );
    addTearDown(client.close);
    final event = await client.messages.createStream(_request()).single;
    expect(event, isA<ErrorEvent>());
    expect(
      event.toJson(),
      containsPair('error', {
        'type': 'throttlingException',
        'message': 'fixture throttled',
      }),
    );
  });

  test('Runtime stream errors redact a credential echoed by AWS', () async {
    final transport = _FrameTransport(base64Decode(_credentialError));
    final client = AnthropicBedrockClient(
      region: 'us-east-1',
      apiKey: _token,
      httpClient: transport,
    );
    addTearDown(client.close);
    final error =
        await client.messages.createStream(_request()).single as ErrorEvent;
    expect(error.requestId, 'aws_trace');
    expect(error.message, 'fixture throttled for [REDACTED]');
    expect(error.toJson().toString(), isNot(contains(_token)));
    expect(transport.request?.headers['authorization'], 'Bearer $_token');
  });

  test('Runtime rejects corrupted and truncated frame boundaries', () async {
    final bad = base64Decode(_stop);
    bad[bad.length - 1] ^= 1;
    for (final bytes in [bad, bad.sublist(0, bad.length - 1)]) {
      final client = AnthropicBedrockClient(
        region: 'us-east-1',
        apiKey: _token,
        httpClient: _FrameTransport(bytes),
      );
      try {
        await expectLater(
          client.messages.createStream(_request()).toList(),
          throwsFormatException,
        );
      } finally {
        client.close();
      }
    }
  });
}

http.Response _json(String body) =>
    http.Response(body, 200, headers: {'content-type': 'application/json'});

class _FrameTransport extends http.BaseClient {
  _FrameTransport(this.bytes);

  final List<int> bytes;
  http.BaseRequest? request;
  String? body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    body = utf8.decode(await request.finalize().toBytes());
    return http.StreamedResponse(
      Stream.fromIterable(bytes.map((byte) => [byte])),
      200,
      headers: {
        'content-type': 'application/vnd.amazon.eventstream',
        'x-amzn-requestid': 'aws_trace',
      },
    );
  }
}
