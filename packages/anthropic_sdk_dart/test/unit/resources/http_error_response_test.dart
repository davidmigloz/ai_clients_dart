@TestOn('vm')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final _request = MessageCreateRequest(
  model: 'claude-sonnet-4-6',
  maxTokens: 8,
  messages: [InputMessage.user('Hello')],
);

void main() {
  final requests = <String, Future<void> Function(AnthropicClient)>{
    'buffered Messages': (client) async {
      await client.messages.create(_request);
    },
    'SSE handshake': (client) async {
      await client.messages.createStream(_request).drain<void>();
    },
    'batch JSONL handshake': (client) async {
      await client.messages.batches.results('msgbatch_test').drain<void>();
    },
    'Files multipart upload': (client) async {
      await client.files.uploadBytes(
        bytes: Uint8List.fromList([1]),
        fileName: 'sample.txt',
      );
    },
    'Files binary download': (client) async {
      await client.files.download(fileId: 'file_test');
    },
    'Skills version multipart upload': (client) async {
      await client.skills.createVersion(
        skillId: 'skill_test',
        files: [
          SkillFile(path: 'demo/SKILL.md', bytes: Uint8List.fromList([1])),
        ],
      );
    },
    'Skills version ZIP download': (client) async {
      await client.skills.downloadVersion(
        skillId: 'skill_test',
        version: 'skillver_test',
      );
    },
  };

  for (final MapEntry(key: name, value: send) in requests.entries) {
    test('$name preserves a rate-limit error and retry-after-ms', () async {
      final client = _client(429, const {
        'Retry-After-Ms': '125.5',
        'Retry-After': '8',
      });
      addTearDown(client.close);
      const delay = Duration(microseconds: 125500);
      final start = DateTime.now();

      try {
        await send(client);
        fail('Expected a rate-limit exception');
      } on RateLimitException catch (error) {
        final end = DateTime.now();
        expect(error.statusCode, 429);
        expect(error.requestId, 'req_provider');
        expect(error.message, 'Bad \uFFFD body');
        expect(
          error.responseMetadata!.headers.entries
              .where((header) => header.key.toLowerCase() == 'retry-after-ms')
              .single
              .value,
          '125.5',
        );
        expect(error.retryAfter!.isBefore(start.add(delay)), isFalse);
        expect(error.retryAfter!.isAfter(end.add(delay)), isFalse);
      }
    });
  }

  test(
    'keeps the direct validation exception and provider request ID',
    () async {
      final client = _client(400);
      addTearDown(client.close);

      await expectLater(
        client.files.download(fileId: 'file_test'),
        throwsA(
          isA<ValidationException>()
              .having(
                (error) => error.responseMetadata?.statusCode,
                'status',
                400,
              )
              .having((error) => error.requestId, 'request ID', 'req_provider')
              .having((error) => error.message, 'message', 'Bad \uFFFD body'),
        ),
      );
    },
  );

  test(
    'keeps the buffered authentication subtype on malformed bytes',
    () async {
      final client = _client(401);
      addTearDown(client.close);

      await expectLater(
        client.messages.create(_request),
        throwsA(
          isA<AuthenticationException>()
              .having((error) => error.statusCode, 'status', 401)
              .having((error) => error.requestId, 'request ID', 'req_provider')
              .having((error) => error.message, 'message', 'Bad \uFFFD body'),
        ),
      );
    },
  );

  test('plain-text malformed errors keep the status and server ID', () async {
    final client = _client(503, const {}, [0x42, 0xff]);
    addTearDown(client.close);

    await expectLater(
      client.messages.createStream(_request).drain<void>(),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 503)
            .having((error) => error.requestId, 'request ID', 'req_provider')
            .having((error) => error.message, 'message', 'B\uFFFD'),
      ),
    );
  });
}

AnthropicClient _client(
  int status, [
  Map<String, String> headers = const {},
  List<int>? bytes,
]) => AnthropicClient(
  config: const AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
  httpClient: MockClient((_) async {
    return http.Response.bytes(
      bytes ??
          [
            ...utf8.encode('{"error":{"type":"test_error","message":"Bad '),
            0xff,
            ...utf8.encode(' body"}}'),
          ],
      status,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Request-Id': 'req_provider',
        ...headers,
      },
    );
  }),
);
