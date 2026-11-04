import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _name = 'fixture-private-selected-name.bin';
const _id = 'fixture-private-upload-id';
const _url = 'https://fixture-private-origin.invalid/private-route/v1';

Map<String, Object?> _file() => {
  'id': _id,
  'object': 'file',
  'bytes': 4,
  'created_at': 1,
  'filename': _name,
  'purpose': 'user_data',
  'status': 'processed',
};

void main() {
  late bool previousHierarchy;
  late Level previousLevel;
  late StreamSubscription<LogRecord> subscription;
  final records = <LogRecord>[];
  setUp(() {
    previousHierarchy = hierarchicalLoggingEnabled;
    previousLevel = Logger.root.level;
    hierarchicalLoggingEnabled = true;
    Logger.root.level = Level.ALL;
    records.clear();
    subscription = Logger.root.onRecord.listen(records.add);
  });
  tearDown(() async {
    await subscription.cancel();
    Logger.root.level = previousLevel;
    hierarchicalLoggingEnabled = previousHierarchy;
  });

  OpenAIClient client(
    http.Client transport, {
    RetryPolicy? retryPolicy,
    AuthProvider? auth,
  }) => OpenAIClient(
    config: OpenAIConfig(
      baseUrl: _url,
      authProvider: auth,
      logLevel: Level.FINEST,
      retryPolicy: retryPolicy ?? const RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );

  test(
    'private flag survives context copies without entering headers or metadata',
    () {
      final request = http.Request('GET', Uri.parse('$_url/files'));
      final plain = RequestContext(request: request);
      final private = plain.copyWith(redactDiagnostics: true);
      expect(plain.redactDiagnostics, isFalse);
      expect(
        private.copyWith(metadata: {'application': true}).redactDiagnostics,
        isTrue,
      );
      expect(
        private.copyWith(redactDiagnostics: false).redactDiagnostics,
        isFalse,
      );
      expect(request.headers, isEmpty);
      expect(private.metadata.containsKey('redactDiagnostics'), isFalse);
    },
  );

  test(
    'private upload keeps returned metadata exact and redacts package logs only when opted in',
    () async {
      final requests = <http.Request>[];
      final sdk = client(
        MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(_file()), 200);
        }),
      );
      final result = await sdk.files.upload(
        bytes: [0, 255, 13, 254],
        filename: _name,
        purpose: FilePurpose.userData,
        redactDiagnostics: true,
      );
      expect(result.id, _id);
      expect(result.filename, _name);
      expect(
        requests.single.headers.keys.any(
          (h) => h.toLowerCase().contains('redact'),
        ),
        isFalse,
      );
      final body = latin1.decode(requests.single.bodyBytes);
      expect(body, contains('name="purpose"\r\n\r\nuser_data\r\n'));
      await Future<void>.delayed(Duration.zero);
      final privateLogs = records.map((r) => r.message).join('\n');
      for (final secret in [
        _name,
        _id,
        'private-route',
        'fixture-private-origin',
      ]) {
        expect(privateLogs, isNot(contains(secret)));
      }
      expect(privateLogs, contains('[REDACTED]'));
      records.clear();
      await sdk.files.upload(
        bytes: [1],
        filename: _name,
        purpose: FilePurpose.userData,
      );
      await Future<void>.delayed(Duration.zero);
      final ordinaryLogs = records.map((r) => r.message).join('\n');
      expect(ordinaryLogs, contains(_name));
      expect(ordinaryLogs, contains(_id));
      sdk.close();
    },
  );

  for (final status in [400, 401, 403, 404, 409, 422, 429, 503, 418]) {
    test(
      'private HTTP $status preserves concrete class and explicit response fields',
      () async {
        final payload = {
          'error': {
            'message': _name,
            'type': _name,
            'code': _id,
            'param': _name,
          },
        };
        final sdk = client(
          MockClient(
            (_) async => http.Response(
              jsonEncode(payload),
              status,
              headers: {'x-request-id': _id, 'retry-after': '0.01'},
            ),
          ),
        );
        try {
          await sdk.files.upload(
            bytes: [1],
            filename: _name,
            purpose: FilePurpose.userData,
            redactDiagnostics: true,
          );
          fail('expected HTTP failure');
        } on ApiException catch (error) {
          expect(
            error.runtimeType,
            createApiException(statusCode: status, message: '').runtimeType,
          );
          expect(error.statusCode, status);
          expect(error.message, _name);
          expect(error.code, _id);
          expect(error.requestId, _id);
          expect(error.body, payload);
          expect(error.cause, isA<http.Response>());
          expect((error.cause! as http.Response).body, jsonEncode(payload));
          expect(error.toString(), isNot(contains(_name)));
          expect(error.toString(), isNot(contains(_id)));
          if (error is RateLimitException) {
            expect(error.retryAfter, const Duration(milliseconds: 10));
          }
        }
        await Future<void>.delayed(Duration.zero);
        expect(
          records.map((r) => r.message).join('\n'),
          isNot(contains(_name)),
        );
        sdk.close();
      },
    );
  }

  test(
    'private URL preparation retains its malformed cause without printing the URL',
    () async {
      const invalid = 'https://[private-origin';
      var sends = 0;
      final sdk = OpenAIClient(
        config: const OpenAIConfig(baseUrl: invalid),
        httpClient: MockClient((_) async {
          sends++;
          return http.Response('{}', 200);
        }),
      );
      try {
        await sdk.files.upload(
          bytes: [1],
          filename: _name,
          purpose: FilePurpose.userData,
          redactDiagnostics: true,
        );
        fail('expected malformed URL');
      } on ConnectionException catch (error) {
        expect(error.cause, isA<FormatException>());
        expect(error.toString(), isNot(contains('private-origin')));
      }
      await expectLater(
        sdk.files.upload(
          bytes: [1],
          filename: _name,
          purpose: FilePurpose.userData,
        ),
        throwsFormatException,
      );
      expect(sends, 0);
      sdk.close();
    },
  );

  test(
    'private transport network retries retain native idempotent classification',
    () async {
      var sends = 0;
      final sdk = client(
        MockClient((_) async {
          sends++;
          if (sends == 1) {
            throw http.ClientException(_name, Uri.parse('$_url/files'));
          }
          return http.Response('{}', 200);
        }),
        retryPolicy: const RetryPolicy(
          maxRetries: 1,
          initialDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
          jitter: 0,
        ),
      );
      await sdk.interceptorChain.execute(
        http.Request('GET', Uri.parse('$_url/files')),
        redactDiagnostics: true,
      );
      expect(sends, 2);
      expect(records.map((r) => r.message).join('\n'), isNot(contains(_name)));
      sdk.close();
    },
  );

  test(
    'private HTTP retries and middleware error logging see redacted final errors',
    () async {
      var sends = 0;
      final observed = <String>[];
      final sdk = client(
        MockClient((_) async {
          sends++;
          return http.Response(
            jsonEncode({
              'error': {'message': _name},
            }),
            503,
          );
        }),
        retryPolicy: const RetryPolicy(
          maxRetries: 1,
          initialDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
          jitter: 0,
        ),
      );
      sdk.interceptorChain.interceptors.insert(
        1,
        _Callback((context, next) async {
          try {
            return await next(context);
          } catch (error) {
            observed.add(error.toString());
            rethrow;
          }
        }),
      );
      await expectLater(
        sdk.interceptorChain.execute(
          http.Request('GET', Uri.parse('$_url/files')),
          redactDiagnostics: true,
        ),
        throwsA(isA<InternalServerException>()),
      );
      expect(sends, 2);
      expect(observed, hasLength(1));
      expect(observed.single, isNot(contains(_name)));
      expect(records.map((r) => r.message).join('\n'), isNot(contains(_name)));
      sdk.close();
    },
  );

  test(
    'custom HTTP errors keep identity and sticky diagnostics before outer loggers',
    () async {
      const original = BadRequestException(message: _name, code: _id);
      final observed = <Object>[];
      final sdk = client(MockClient((_) async => http.Response('{}', 200)));
      sdk.interceptorChain.interceptors.add(
        _Callback((context, next) async {
          await next(context);
          throw original;
        }),
      );
      sdk.interceptorChain.interceptors.insert(
        1,
        _Callback((context, next) async {
          try {
            return await next(context);
          } catch (error) {
            observed.add(error);
            expect(error.toString(), isNot(contains(_name)));
            rethrow;
          }
        }),
      );
      try {
        await sdk.interceptorChain.execute(
          http.Request('GET', Uri.parse('$_url/files')),
          redactDiagnostics: true,
        );
        fail('expected custom HTTP error');
      } on BadRequestException catch (error) {
        expect(error, same(original));
        expect(error.message, _name);
        expect(error.code, _id);
      }
      expect(observed.single, same(original));
      expect(original.toString(), isNot(contains(_name)));
      expect(records.map((r) => r.message).join('\n'), isNot(contains(_name)));
      sdk.close();
    },
  );

  test(
    'unknown custom middleware failures keep an explicit private cause',
    () async {
      final original = StateError(_name);
      final sdk = client(MockClient((_) async => http.Response('{}', 200)));
      sdk.interceptorChain.interceptors.add(
        _Callback((context, next) => Future.error(original)),
      );
      try {
        await sdk.interceptorChain.execute(
          http.Request('GET', Uri.parse('$_url/files')),
          redactDiagnostics: true,
        );
        fail('expected callback failure');
      } on ConnectionException catch (error) {
        expect(error.cause, same(original));
        expect(error.toString(), isNot(contains(_name)));
      }
      expect(records.map((r) => r.message).join('\n'), isNot(contains(_name)));
      sdk.close();
    },
  );

  test(
    'provider errors are classified at origin and never become replayable HTTP errors',
    () async {
      for (final failAt in [1, 2]) {
        const original = BadRequestException(message: _name);
        final auth = _Provider(failAt, original);
        var sends = 0;
        final sdk = client(
          MockClient((_) async {
            sends++;
            return http.Response('{}', 200);
          }),
          auth: auth,
          retryPolicy: RetryPolicy.defaultPolicy,
        );
        try {
          await sdk.files.upload(
            bytes: [1],
            filename: _name,
            purpose: FilePurpose.userData,
            redactDiagnostics: true,
          );
          fail('expected provider failure');
        } on ConnectionException catch (error) {
          expect(error.cause, same(original));
          expect(error.toString(), isNot(contains(_name)));
          expect(error, isNot(isA<http.ClientException>()));
        }
        expect(auth.calls, failAt);
        expect(sends, 0);
        sdk.close();
      }
    },
  );

  test(
    'transport-origin forged HTTP errors remain typed connection failures with their cause',
    () async {
      const original = BadRequestException(message: _name);
      var sends = 0;
      final sdk = client(
        MockClient((_) {
          sends++;
          return Future.error(original);
        }),
      );
      try {
        await sdk.files.upload(
          bytes: [1],
          filename: _name,
          purpose: FilePurpose.userData,
          redactDiagnostics: true,
        );
        fail('expected transport failure');
      } on ConnectionException catch (error) {
        expect(error.cause, same(original));
        expect(error, isNot(isA<http.ClientException>()));
        expect(error.toString(), isNot(contains(_name)));
      }
      expect(sends, 1);
      sdk.close();
    },
  );

  test(
    'private policy preserves safe Vertex authentication failures without retry',
    () async {
      var tokens = 0;
      var sends = 0;
      final sdk = OpenAIClient(
        config: OpenAIConfig.vertex(
          provider: VertexProvider(
            baseUrl: 'https://vertex.invalid/projects/p/locations/l/openai/v1',
            tokenProvider: () {
              tokens++;
              throw StateError('private credential material');
            },
          ),
          retryPolicy: const RetryPolicy(maxRetries: 2),
          logLevel: Level.FINEST,
        ),
        httpClient: MockClient((_) async {
          sends++;
          return http.Response('{}', 200);
        }),
      );
      await expectLater(
        sdk.interceptorChain.execute(
          http.Request(
            'GET',
            Uri.parse('${sdk.config.baseUrl}/responses/fixture'),
          ),
          redactDiagnostics: true,
        ),
        throwsA(isA<VertexAuthenticationException>()),
      );
      expect(tokens, 1);
      expect(sends, 0);
      expect(
        records.map((record) => record.message).join(),
        isNot(contains('private credential material')),
      );
      sdk.close();
    },
  );

  test(
    'private GET does not make arbitrary or forged origin failures replayable',
    () async {
      for (final original in <Object>[
        StateError(_name),
        const FormatException(_name),
        const BadRequestException(message: _name),
      ]) {
        var sends = 0;
        final sdk = client(
          MockClient((_) {
            sends++;
            return Future.error(original);
          }),
          retryPolicy: const RetryPolicy(
            maxRetries: 3,
            initialDelay: Duration(milliseconds: 1),
            maxDelay: Duration(milliseconds: 1),
            jitter: 0,
          ),
        );
        try {
          await sdk.interceptorChain.execute(
            http.Request('GET', Uri.parse('$_url/files')),
            redactDiagnostics: true,
          );
          fail('expected origin failure');
        } on ConnectionException catch (error) {
          expect(error.cause, same(original));
          expect(error, isNot(isA<http.ClientException>()));
          expect(error.toString(), isNot(contains(_name)));
        }
        expect(sends, 1);
        sdk.close();
      }
    },
  );

  test(
    'private transport retains abort and timeout control outcomes',
    () async {
      for (final control in <OpenAIException>[
        const AbortedException(message: _name),
        const RequestTimeoutException(message: _name),
      ]) {
        var sends = 0;
        final sdk = client(
          MockClient((_) {
            sends++;
            return Future.error(control);
          }),
          retryPolicy: const RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration(milliseconds: 1),
            maxDelay: Duration(milliseconds: 1),
            jitter: 0,
          ),
        );
        try {
          await sdk.interceptorChain.execute(
            http.Request('GET', Uri.parse('$_url/files')),
            redactDiagnostics: true,
          );
          fail('expected control failure');
        } on OpenAIException catch (error) {
          expect(error, same(control));
          expect(error.message, _name);
          expect(error.toString(), isNot(contains(_name)));
        }
        expect(sends, control is AbortedException ? 1 : 2);
        sdk.close();
      }
    },
  );

  test(
    'malformed UTF8 and known FileObject fields expose raw data only explicitly',
    () async {
      for (final payload in [
        utf8.encode('private malformed $_name'),
        [...utf8.encode(_name), 255],
        utf8.encode(jsonEncode({..._file(), 'bytes': _name})),
      ]) {
        final sdk = client(
          MockClient(
            (_) async => http.Response.bytes(
              payload,
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );
        try {
          await sdk.files.upload(
            bytes: [1],
            filename: _name,
            purpose: FilePurpose.userData,
            redactDiagnostics: true,
          );
          fail('expected malformed response');
        } on ParseException catch (error) {
          expect(error.toString(), isNot(contains(_name)));
          expect(error.responseBody, contains(_name));
        }
        expect(
          records.map((r) => r.message).join('\n'),
          isNot(contains(_name)),
        );
        sdk.close();
      }
    },
  );

  test(
    'timeout and abort retain concrete classes and private caller diagnostics',
    () async {
      final abort = Completer<void>();
      final transport = _AbortClient();
      final sdk = client(transport);
      final pending = sdk.files.upload(
        bytes: [1],
        filename: _name,
        purpose: FilePurpose.userData,
        abortTrigger: abort.future,
        redactDiagnostics: true,
        additionalHeaders: {'X-Request-ID': _id},
      );
      final assertion = expectLater(
        pending,
        throwsA(
          isA<AbortedException>().having(
            (error) => error.toString(),
            'private diagnostics',
            isNot(contains(_id)),
          ),
        ),
      );
      await transport.started.future;
      abort.complete();
      await assertion;
      const timeout = RequestTimeoutException(
        message: _name,
        timeout: Duration(seconds: 1),
      );
      sdk.interceptorChain.interceptors.insert(
        0,
        _Callback((context, next) => Future.error(timeout)),
      );
      try {
        await sdk.interceptorChain.execute(
          http.Request('GET', Uri.parse('$_url/files')),
          redactDiagnostics: true,
        );
        fail('expected timeout');
      } on RequestTimeoutException catch (error) {
        expect(error, same(timeout));
        expect(error.message, _name);
        expect(error.toString(), isNot(contains(_name)));
      }
      sdk.close();
    },
  );
}

class _Callback implements Interceptor {
  _Callback(this.callback);
  final InterceptorNext Function(RequestContext, InterceptorNext)? unused =
      null;
  final Future<http.Response> Function(RequestContext, InterceptorNext)
  callback;
  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) => callback(context, next);
}

class _Provider implements AuthProvider {
  _Provider(this.failAt, this.error);
  final int failAt;
  final Object error;
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    // This fixture deliberately accepts provider failures from either family.
    if (calls == failAt) Error.throwWithStackTrace(error, StackTrace.current);
    return {'Authorization': 'Bearer fixture-auth'};
  }
}

class _AbortClient extends http.BaseClient {
  final started = Completer<void>();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await request.finalize().drain<void>();
    started.complete();
    if (request is http.Abortable) await request.abortTrigger;
    throw http.RequestAbortedException(request.url);
  }

  @override
  void close() {}
}
