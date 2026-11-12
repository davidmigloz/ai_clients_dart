@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _body =
    '{"type":"error","error":{"type":"fixture_error","message":"fixture"}}';
const _headers = {
  'ReQuEsT-Id': 'server-request',
  'Retry-After': '17',
  'Set-Cookie': 'private-cookie',
  'X-Secret': 'private-response',
};
const _deadline = Duration(seconds: 5);

enum _Operation {
  batchResults,
  fileUploadBytes,
  fileDownload,
  skillCreate,
  skillCreateVersion,
}

Future<Object?> _invoke(_Operation operation, AnthropicClient client) =>
    switch (operation) {
      _Operation.batchResults =>
        client.messages.batches.results('batch_fixture').toList(),
      _Operation.fileUploadBytes => client.files.uploadBytes(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'fixture.txt',
      ),
      _Operation.fileDownload => client.files.download(fileId: 'file_fixture'),
      _Operation.skillCreate => client.skills.create(files: [_skillFile()]),
      _Operation.skillCreateVersion => client.skills.createVersion(
        skillId: 'skill_fixture',
        files: [_skillFile()],
      ),
    };

SkillFile _skillFile() => SkillFile(
  path: 'fixture/SKILL.md',
  bytes: Uint8List.fromList([35, 32, 70, 105, 120, 116, 117, 114, 101]),
);

({AnthropicClient client, List<http.Request> requests}) _harness(
  int status, {
  String body = _body,
  Map<String, String> headers = _headers,
}) {
  final requests = <http.Request>[];
  final transport = MockClient((request) async {
    requests.add(request);
    return http.Response(body, status, headers: headers);
  });
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider('fixture-key'),
      retryPolicy: RetryPolicy(maxRetries: 0),
      defaultHeaders: {'X-Request-ID': 'client-correlation'},
    ),
    httpClient: transport,
  );
  addTearDown(client.close);
  addTearDown(transport.close);
  return (client: client, requests: requests);
}

Future<AnthropicException> _failure(Future<Object?> Function() action) async {
  try {
    await action().timeout(_deadline);
  } on AnthropicException catch (error) {
    return error;
  }
  throw TestFailure('Expected an AnthropicException');
}

ResponseMetadata? _metadata(AnthropicException error) => switch (error) {
  ApiException(:final responseMetadata) => responseMetadata,
  ValidationException(:final responseMetadata) => responseMetadata,
  _ => null,
};

String? _requestId(AnthropicException error) => switch (error) {
  ApiException(:final requestId) => requestId,
  ValidationException(:final requestId) => requestId,
  _ => null,
};

void _expectTypeAndStatus(AnthropicException error, int status) {
  expect(error.runtimeType, switch (status) {
    400 => ValidationException,
    401 => AuthenticationException,
    429 => RateLimitException,
    _ => ApiException,
  });
  if (error is ApiException) {
    expect(error.statusCode, status);
    expect(error.requestMetadata, isNull);
  }
  if (error is ValidationException) {
    expect(error.fieldErrors, isEmpty);
  }
}

void _expectSafeMetadata(
  AnthropicException error,
  int status, {
  String? requestId = 'server-request',
  String? retryAfter = '17',
}) {
  expect(_requestId(error), requestId);
  expect(_metadata(error), isNotNull);
  final metadata = _metadata(error)!;
  expect(metadata.statusCode, status);
  expect(metadata.headers, {
    'request-id': ?requestId,
    'retry-after': ?retryAfter,
  });
  expect(metadata.bodyExcerpt, isEmpty);
  expect(metadata.latency, greaterThanOrEqualTo(Duration.zero));
}

void _expectRequest(_Operation operation, List<http.Request> requests) {
  expect(requests, hasLength(1));
  final request = requests.single;
  expect(request.headers['x-request-id'], 'client-correlation');
  expect(request.headers['x-api-key'], 'fixture-key');
  expect(request.method, switch (operation) {
    _Operation.batchResults || _Operation.fileDownload => 'GET',
    _ => 'POST',
  });
  expect(request.url.path, switch (operation) {
    _Operation.batchResults => '/v1/messages/batches/batch_fixture/results',
    _Operation.fileUploadBytes => '/v1/files',
    _Operation.fileDownload => '/v1/files/file_fixture/content',
    _Operation.skillCreate => '/v1/skills',
    _Operation.skillCreateVersion => '/v1/skills/skill_fixture/versions',
  });
}

const Map<String, Object> _echoedError = {
  'type': 'error',
  'request_id': 'req_real_body',
  'error': {
    'type': 'fixture_error',
    'message': 'Rejected fixture-key',
    'details': {
      'error_code': 'real_code',
      'nested': [
        {'field': 'prefix fixture-key suffix', 'fixture-key': true},
        {'number': 17},
      ],
    },
  },
};

void main() {
  for (final operation in _Operation.values) {
    for (final status in [400, 401, 429, 503]) {
      test('${operation.name} preserves HTTP $status metadata', () async {
        final harness = _harness(status);
        final startedAt = DateTime.now();
        final error = await _failure(() => _invoke(operation, harness.client));
        final completedAt = DateTime.now();

        _expectTypeAndStatus(error, status);
        expect(error.message, 'fixture');
        _expectSafeMetadata(error, status);
        _expectRequest(operation, harness.requests);
        if (error is RateLimitException) {
          expect(error.retryAfter, isNotNull);
          // Bounds follow the observed operation duration; no fixed runtime
          // tolerance makes this assertion depend on test-runner load.
          const delay = Duration(seconds: 17);
          expect(
            error.retryAfter!.compareTo(startedAt.add(delay)),
            greaterThanOrEqualTo(0),
          );
          expect(
            error.retryAfter!.compareTo(completedAt.add(delay)),
            lessThanOrEqualTo(0),
          );
        }
      });
    }

    test(
      '${operation.name} redacts echoed credentials from requestless errors',
      () async {
        final status = switch (operation) {
          _Operation.fileDownload => 401,
          _Operation.skillCreate => 503,
          _Operation.skillCreateVersion => 429,
          _ => 400,
        };
        final harness = _harness(
          status,
          body: jsonEncode(_echoedError),
          headers: const {
            'request-id': 'header fixture-key',
            'retry-after': '17',
            'set-cookie': 'cookie fixture-key',
          },
        );
        final error = await _failure(() => _invoke(operation, harness.client));
        _expectTypeAndStatus(error, status);
        _expectRequest(operation, harness.requests);
        expect(error.message, 'Rejected [REDACTED]');
        expect(_requestId(error), 'req_real_body');
        expect(_metadata(error)!.headers, {'retry-after': '17'});
        expect(_metadata(error)!.bodyExcerpt, isEmpty);
        final (code, details) = switch (error) {
          ApiException(:final errorCode, :final errorDetails) ||
          ValidationException(
            :final errorCode,
            :final errorDetails,
          ) => (errorCode, errorDetails),
          _ => (null, null),
        };
        expect(code, 'real_code');
        expect(details, {
          'error_code': 'real_code',
          'nested': [
            {'field': 'prefix [REDACTED] suffix'},
            {'number': 17},
          ],
        });
        expect(() => details!['new'] = true, throwsUnsupportedError);
        expect(error.toString(), isNot(contains('fixture-key')));
      },
    );

    test(
      '${operation.name} does not substitute the client request ID',
      () async {
        final harness = _harness(
          503,
          headers: const {'X-Secret': 'private-response'},
        );
        final error = await _failure(() => _invoke(operation, harness.client));

        _expectTypeAndStatus(error, 503);
        _expectSafeMetadata(error, 503, requestId: null, retryAfter: null);
        _expectRequest(operation, harness.requests);
      },
    );

    test(
      '${operation.name} retains metadata for a malformed error body',
      () async {
        const body = 'not-json private-response-body';
        final harness = _harness(503, body: body);
        final error = await _failure(() => _invoke(operation, harness.client));

        _expectTypeAndStatus(error, 503);
        // The provider message is retained; the diagnostic body excerpt stays
        // empty so the raw body is not copied into separate metadata.
        expect(error.message, body);
        _expectSafeMetadata(error, 503);
        _expectRequest(operation, harness.requests);
      },
    );
  }

  const invalidHeaders = {
    _Operation.batchResults: 'invalid',
    _Operation.fileUploadBytes: '-1',
    _Operation.fileDownload: '9000000000000',
    _Operation.skillCreate: '9223372036854775807',
    _Operation.skillCreateVersion: '999999999999999999999999999999',
  };
  for (final entry in invalidHeaders.entries) {
    test('${entry.key.name} tolerates invalid retry-after', () async {
      final harness = _harness(
        429,
        headers: {'request-id': 'server-request', 'retry-after': entry.value},
      );
      final error = await _failure(
        () => _invoke(entry.key, harness.client).timeout(_deadline),
      );

      _expectTypeAndStatus(error, 429);
      expect(error.message, 'fixture');
      expect((error as RateLimitException).retryAfter, isNull);
      _expectSafeMetadata(error, 429, retryAfter: entry.value);
      _expectRequest(entry.key, harness.requests);
    });
  }

  test(
    'file path upload delegates without losing HTTP error metadata',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'anthropic_metadata_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = await File(
        '${directory.path}/fixture.txt',
      ).writeAsBytes([1, 2, 3]);
      final harness = _harness(429);

      final error = await _failure(
        () => harness.client.files.upload(filePath: file.path),
      );

      _expectTypeAndStatus(error, 429);
      expect((error as RateLimitException).retryAfter, isNotNull);
      _expectSafeMetadata(error, 429);
      _expectRequest(_Operation.fileUploadBytes, harness.requests);
    },
  );

  test(
    'custom JSONL error factories retain their exception identity',
    () async {
      final harness = _harness(429);
      const metadata = ResponseMetadata(
        statusCode: 429,
        headers: {
          'request-id': 'factory-request',
          'X-Private': 'factory-owned-metadata',
        },
        bodyExcerpt: 'factory-owned-excerpt',
        latency: Duration.zero,
      );
      const expected = ApiException(
        statusCode: 429,
        message: 'factory-owned-message',
        responseMetadata: metadata,
      );
      var factoryCalls = 0;

      final error = await _failure(
        () => harness.client.messages
            .getJsonlStream(
              '/fixture',
              errorFactory: (status, body) {
                factoryCalls++;
                expect(status, 429);
                expect(body, _body);
                return expected;
              },
            )
            .toList(),
      );

      expect(error, same(expected));
      expect((error as ApiException).responseMetadata, same(metadata));
      expect(error.requestId, 'factory-request');
      expect(factoryCalls, 1);
      expect(harness.requests, hasLength(1));
    },
  );

  test(
    'metadata-aware JSONL factories receive safe immutable metadata',
    () async {
      final harness = _harness(503);
      ApiException? expected;
      final error = await _failure(
        () => harness.client.messages
            .getJsonlStream(
              '/fixture',
              errorFactory: (_, _) =>
                  throw TestFailure('Legacy factory called'),
              errorFactoryWithMetadata: (status, body, metadata) {
                expect(status, 503);
                expect(body, _body);
                expected = ApiException(
                  statusCode: status,
                  message: 'factory-owned-message',
                  responseMetadata: metadata,
                );
                return expected!;
              },
            )
            .toList(),
      );

      expect(error, same(expected));
      _expectSafeMetadata(error, 503);
      expect(
        () => _metadata(error)!.headers['set-cookie'] = 'private-cookie',
        throwsUnsupportedError,
      );
      expect(harness.requests, hasLength(1));
    },
  );

  for (final useMetadata in [false, true]) {
    test(
      'JSONL factory receives sanitized body (metadata: $useMetadata)',
      () async {
        final harness = _harness(
          503,
          body: jsonEncode(_echoedError),
          headers: const {'request-id': 'fixture-key'},
        );
        const expected = ApiException(statusCode: 503, message: 'custom');
        var calls = 0;
        ApiException factory(String body) {
          calls++;
          expect(body, isNot(contains('fixture-key')));
          expect(jsonDecode(body), {
            'type': 'error',
            'request_id': 'req_real_body',
            'error': {
              'type': 'fixture_error',
              'message': 'Rejected [REDACTED]',
              'details': {
                'error_code': 'real_code',
                'nested': [
                  {'field': 'prefix [REDACTED] suffix'},
                  {'number': 17},
                ],
              },
            },
          });
          return expected;
        }

        final error = await _failure(
          () => harness.client.messages
              .getJsonlStream(
                '/fixture',
                errorFactory: useMetadata ? null : (_, body) => factory(body),
                errorFactoryWithMetadata: useMetadata
                    ? (status, body, metadata) {
                        expect(status, 503);
                        expect(metadata.headers, isEmpty);
                        expect(metadata.requestId, 'req_real_body');
                        return factory(body);
                      }
                    : null,
              )
              .toList(),
        );
        expect(error, same(expected));
        expect(calls, 1);
      },
    );
  }

  test('batch cancellation cancels a stalled HTTP 429 error body', () async {
    final transport = _PendingClient();
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    addTearDown(transport.close);
    final bodySubscribed = Completer<void>();
    final bodyCanceled = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: bodySubscribed.complete,
      onCancel: bodyCanceled.complete,
    );
    addTearDown(body.close);
    final errors = <Object>[];
    final subscription = client.messages.batches
        .results('batch_fixture')
        .listen((_) {}, onError: errors.add);
    final request = await transport.sent.future.timeout(_deadline);
    transport.response.complete(
      http.StreamedResponse(body.stream, 429, headers: _headers),
    );
    await bodySubscribed.future.timeout(_deadline);
    body.add([123, 34, 101, 114, 114, 111, 114, 34, 58]); // {"error":

    await subscription.cancel().timeout(_deadline);
    await bodyCanceled.future.timeout(_deadline);
    await (request as http.Abortable).abortTrigger!.timeout(_deadline);
    expect(body.hasListener, isFalse);
    expect(transport.closed, isFalse);
    expect(errors, isEmpty);

    await body.close();
    await Future<void>.delayed(Duration.zero);
    expect(errors, isEmpty);
  });
}

class _PendingClient extends http.BaseClient {
  final sent = Completer<http.BaseRequest>();
  final response = Completer<http.StreamedResponse>();
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    sent.complete(request);
    return response.future;
  }

  @override
  void close() {
    closed = true;
  }
}
