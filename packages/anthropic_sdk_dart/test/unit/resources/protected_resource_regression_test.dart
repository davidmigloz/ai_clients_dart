import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

const _token = 'fixture-scoped-credential';
const _requiredBeta = 'managed-agents-2026-04-01';

void main() {
  for (final (name, invoke)
      in <(String, Future<Object?> Function(AnthropicClient))>[
        (
          'tunnel',
          (client) =>
              client.tunnels.withToken(_token).revealToken('tun_fixture'),
        ),
        (
          'worker',
          (client) => client.environments
              .work('env_fixture', bearerToken: _token)
              .heartbeat('work_fixture'),
        ),
      ]) {
    test(
      '$name rejects redirect headers without waiting for its stalled body',
      () async {
        final canceled = Completer<void>();
        var cancelCount = 0;
        final body = StreamController<List<int>>(
          onCancel: () {
            cancelCount++;
            canceled.complete();
          },
        );
        addTearDown(body.close);
        final transport = _Transport((request) {
          expect(request.followRedirects, isFalse);
          expect(request.headers['authorization'], 'Bearer $_token');
          return http.StreamedResponse(
            body.stream,
            302,
            headers: {
              'Request-Id': 'req_redirect',
              'Location': 'https://untrusted.invalid/$_token',
              'Retry-After': _token,
            },
          );
        });
        final client = _client(transport);
        addTearDown(client.close);
        await expectLater(
          invoke(client),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'status', 302)
                .having(
                  (error) => error.requestId,
                  'provider request ID',
                  'req_redirect',
                )
                .having(
                  (error) => error.responseMetadata?.headers,
                  'safe headers',
                  {'request-id': 'req_redirect'},
                ),
          ),
        );
        await canceled.future.timeout(const Duration(seconds: 1));
        expect(cancelCount, 1);
        expect(transport.requests, hasLength(1));
      },
    );
  }

  test(
    'worker betas retain configured defaults and explicit precedence',
    () async {
      final transport = _Transport(
        (_) => http.StreamedResponse(
          Stream.value(utf8.encode('null')),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );
      final client = _client(transport);
      addTearDown(client.close);
      final work = client.environments.work('env_fixture', bearerToken: _token);
      expect(await work.poll(), isNull);
      expect(
        await work.poll(
          betas: ['explicit-preview', _requiredBeta, _requiredBeta],
        ),
        isNull,
      );
      expect(
        transport.requests.map((request) => request.headers['anthropic-beta']),
        [
          'configured-preview,$_requiredBeta',
          'explicit-preview,$_requiredBeta',
        ],
      );
    },
  );
}

AnthropicClient _client(_Transport transport) => AnthropicClient(
  config: const AnthropicConfig(
    defaultHeaders: {
      'Anthropic-Beta':
          ' configured-preview , $_requiredBeta, configured-preview',
    },
    timeout: Duration(milliseconds: 50),
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);

final class _Transport extends http.BaseClient {
  _Transport(this.handle);
  final http.StreamedResponse Function(http.BaseRequest) handle;
  final requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return handle(request);
  }
}
