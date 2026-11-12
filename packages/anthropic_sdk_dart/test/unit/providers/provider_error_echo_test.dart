import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

const _awsKey = 'fixture-aws-bearer-key';
const _sessionToken = 'fixture-aws-session-token';
const _config = AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0));
const _awsCredentials = ClaudeAwsCredentials(
  accessKeyId: 'AKIDEXAMPLE',
  secretAccessKey: 'fixture-iam-signing-secret',
  sessionToken: _sessionToken,
);
final _request = MessageCreateRequest(
  model: 'claude-fixture',
  maxTokens: 32,
  messages: [InputMessage.user('local credential echo test')],
);

void main() {
  _verifyProvider(
    'Claude AWS bearer',
    (transport) => AnthropicAwsClient(
      region: 'us-west-2',
      workspaceId: 'wrkspc_fixture',
      apiKey: _awsKey,
      config: _config,
      httpClient: transport,
    ),
    (request) => _bearerValues(request, _awsKey),
  );
  _verifyProvider(
    'Claude AWS signature and session',
    (transport) => AnthropicAwsClient(
      region: 'us-west-2',
      workspaceId: 'wrkspc_fixture',
      credentials: () => _awsCredentials,
      config: _config,
      httpClient: transport,
    ),
    _signedValues,
  );
  test('Admin redirects discard a cloud credential echoed as an ID', () async {
    var sends = 0;
    final transport = _Transport((request) {
      sends++;
      expect(request.followRedirects, isFalse);
      expect(request.headers['authorization'], 'Bearer $_awsKey');
      return http.StreamedResponse(
        const Stream<List<int>>.empty(),
        307,
        headers: {
          'location': 'https://unrelated.invalid/redirect',
          'x-amzn-requestid': _awsKey,
          'retry-after': '3',
        },
      );
    });
    final client = AnthropicAwsClient(
      region: 'us-west-2',
      apiKey: _awsKey,
      config: _config,
      httpClient: transport,
    );
    addTearDown(client.close);
    await expectLater(
      client.organization.externalKeys.list(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 307)
            .having((e) => e.requestId, 'provider ID', isNull)
            .having((e) => e.responseMetadata?.headers, 'headers', {
              'retry-after': '3',
            }),
      ),
    );
    expect(sends, 1);
  });

  test('external key validation redacts late-bound AWS credentials', () async {
    final transport = _Transport((request) {
      final credentials = _signedValues(request);
      expect(request.url.pathSegments.last, 'validate');
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode({
              'type': 'external_key_validation',
              'status': 'failure',
              'error': 'KMS denied ${credentials.join(' ')}',
            }),
          ),
        ),
        200,
      );
    });
    final client = AnthropicAwsClient(
      region: 'us-west-2',
      credentials: () => _awsCredentials,
      config: _config,
      httpClient: transport,
    );
    addTearDown(client.close);
    final result = await client.organization.externalKeys.validate(
      'key_fixture',
    );
    expect(result.succeeded, isFalse);
    expect(result.error, 'KMS denied [REDACTED] [REDACTED] [REDACTED]');
  });

  for (final (name, invoke)
      in <(String, Future<void> Function(AnthropicAwsClient))>[
        (
          'buffered',
          (client) async {
            await client.models.list();
          },
        ),
        (
          'SSE',
          (client) => client.messages.createStream(_request).drain<void>(),
        ),
        (
          'binary',
          (client) async {
            await client.files.download(fileId: 'file_fixture');
          },
        ),
      ]) {
    test(
      '$name rejects provider redirects before reading or following them',
      () async {
        var sends = 0;
        var cancels = 0;
        final body = StreamController<List<int>>(onCancel: () => cancels++);
        addTearDown(body.close);
        final transport = _Transport((request) {
          sends++;
          expect(request.url.host, 'source.invalid');
          expect(request.headers['authorization'], 'Bearer $_awsKey');
          return http.StreamedResponse(
            body.stream,
            302,
            headers: {
              'location': 'https://target.invalid/proxy/v1/models',
              'request-id': 'req_redirect',
              'x-amzn-requestid': _awsKey,
            },
          );
        });
        final client = AnthropicAwsClient(
          region: 'us-west-2',
          workspaceId: 'wrkspc_fixture',
          apiKey: _awsKey,
          baseUrl: 'https://source.invalid/proxy',
          config: const AnthropicConfig(
            defaultHeaders: {'Authorization': 'Bearer proxy-authorization'},
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        await expectLater(
          invoke(client).timeout(const Duration(seconds: 2)),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'status', 302)
                .having((e) => e.requestId, 'request ID', 'req_redirect')
                .having((e) => e.responseMetadata?.headers, 'headers', {
                  'request-id': 'req_redirect',
                }),
          ),
        );
        expect(sends, 1);
        expect(cancels, 1);
      },
    );

    test('$name protects borrowed transport errors after headers', () async {
      final transport = _Transport((request) {
        expect(request.headers['authorization'], 'Bearer $_awsKey');
        return http.StreamedResponse(
          Stream<List<int>>.error(
            http.ClientException(
              'connection interrupted',
              request.url.replace(queryParameters: {'echo': _awsKey}),
            ),
          ),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: 'wrkspc_fixture',
        apiKey: _awsKey,
        config: _config,
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        invoke(client),
        throwsA(
          isA<http.ClientException>().having(
            (e) => e.toString(),
            'safe error',
            isNot(contains(_awsKey)),
          ),
        ),
      );
    });
  }

  test('cloud transport exception cannot echo its own bearer', () async {
    final transport = _Transport((request) {
      expect(request.headers['authorization'], 'Bearer $_awsKey');
      throw http.ClientException('Transport echoed $_awsKey', request.url);
    });
    final client = AnthropicAwsClient(
      region: 'us-west-2',
      workspaceId: 'wrkspc_fixture',
      apiKey: _awsKey,
      config: _config,
      httpClient: transport,
    );
    addTearDown(client.close);
    await expectLater(
      client.messages.create(_request),
      throwsA(
        isA<http.ClientException>().having(
          (e) => e.message,
          'message',
          'Provider transport error contained a redacted credential',
        ),
      ),
    );
  });

  test('AWS direct Files error scrubs the effective credential', () async {
    final transport = _Transport((request) {
      expect(request.url.path, '/v1/files');
      expect(request.headers['authorization'], 'Bearer $_awsKey');
      final body = jsonEncode({
        'type': 'error',
        'error': {
          'type': 'invalid_request_error',
          'message': 'Rejected upload for $_awsKey',
          'details': {'error_code': 'upload_rejected', 'echo': _awsKey},
        },
        'request_id': 'req_file',
      });
      return http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        400,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = AnthropicAwsClient(
      region: 'us-west-2',
      workspaceId: 'wrkspc_fixture',
      apiKey: _awsKey,
      config: _config,
      httpClient: transport,
    );
    addTearDown(client.close);
    await expectLater(
      client.files.uploadBytes(
        bytes: Uint8List.fromList([0, 128, 255]),
        fileName: 'fixture.bin',
      ),
      throwsA(
        isA<ValidationException>()
            .having((e) => e.requestId, 'provider ID', 'req_file')
            .having((e) => e.errorCode, 'error code', 'upload_rejected')
            .having((e) => e.errorDetails?['echo'], 'redaction', '[REDACTED]')
            .having((e) => e.message, 'message', isNot(contains(_awsKey))),
      ),
    );
  });

  test(
    'effective response metadata leaves caller and response headers intact',
    () async {
      final transport = _Transport((request) {
        expect(request.headers['authorization'], 'Bearer $_awsKey');
        expect(request.headers['x-local-header'], 'caller-value');
        return http.StreamedResponse(
          const Stream<List<int>>.empty(),
          200,
          headers: {'x-provider-header': 'response-value'},
        );
      });
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: 'wrkspc_fixture',
        apiKey: _awsKey,
        config: _config,
        httpClient: transport,
      );
      addTearDown(client.close);
      final request =
          http.Request(
              'POST',
              Uri.parse(
                'https://aws-external-anthropic.us-west-2.api.aws/v1/messages',
              ),
            )
            ..headers['x-local-header'] = 'caller-value'
            ..headers['anthropic-workspace-id'] = 'wrkspc_fixture';
      final originalHeaders = Map<String, String>.of(request.headers);
      final result = await client.interceptorChain.execute(request);
      expect(request.headers, originalHeaders);
      expect(result.headers, {'x-provider-header': 'response-value'});
    },
  );
}

void _verifyProvider(
  String name,
  AnthropicClient Function(http.Client) connect,
  List<String> Function(http.BaseRequest) credentials,
) {
  for (final mode in ['buffered', 'handshake', 'SSE']) {
    test('$name redacts effective credentials in $mode errors', () async {
      final inBand = mode == 'SSE';
      late List<String> sentValues;
      final transport = _Transport((request) {
        expect(request.followRedirects, isFalse);
        sentValues = credentials(request);
        final body = jsonEncode({
          'type': 'error',
          'error': {
            'type': 'permission_error',
            'message': 'Denied with diagnostic echoes: ${sentValues.join(' ')}',
            'details': {'error_code': 'permission_scope', 'nested': sentValues},
          },
          'request_id': 'req_safe',
        });
        final wire = inBand ? 'event: error\ndata: $body\n\n' : body;
        return http.StreamedResponse(
          Stream.value(utf8.encode(wire)),
          inBand ? 200 : 403,
          headers: {
            'content-type': inBand ? 'text/event-stream' : 'application/json',
            'request-id': sentValues.last,
          },
        );
      });
      final client = connect(transport);
      addTearDown(client.close);
      if (inBand) {
        final event =
            await client.messages.createStream(_request).single as ErrorEvent;
        expect(event.requestId, 'req_safe');
        expect(event.errorCode, 'permission_scope');
        expect(event.details?['nested'], everyElement('[REDACTED]'));
        for (final value in sentValues) {
          expect(event.toJson().toString(), isNot(contains(value)));
        }
      } else {
        final request = mode == 'buffered'
            ? client.messages.create(_request)
            : client.messages.createStream(_request).drain<void>();
        try {
          await request;
          fail('Expected provider API error');
        } on ApiException catch (error) {
          expect(error.statusCode, 403);
          expect(error.requestId, 'req_safe');
          expect(error.errorCode, 'permission_scope');
          expect(error.errorDetails?['nested'], everyElement('[REDACTED]'));
          expect(error.responseMetadata?.bodyExcerpt, isEmpty);
          for (final value in sentValues) {
            expect(error.toString(), isNot(contains(value)));
          }
        }
      }
    });
  }
}

List<String> _bearerValues(http.BaseRequest request, String token) {
  expect(request.headers['authorization'], 'Bearer $token');
  return [token, 'Bearer $token'];
}

List<String> _signedValues(http.BaseRequest request) {
  final authorization = request.headers['authorization']!;
  expect(authorization, startsWith('AWS4-HMAC-SHA256 '));
  expect(request.headers['x-amz-security-token'], _sessionToken);
  final signature = authorization.split('Signature=').last;
  expect(signature, hasLength(64));
  return [authorization, _sessionToken, signature];
}

class _Transport extends http.BaseClient {
  _Transport(this.respond);

  final http.StreamedResponse Function(http.BaseRequest) respond;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await request.finalize().drain<void>();
    // Deliberately omit response.request as a borrowed transport may do.
    return respond(request);
  }
}
