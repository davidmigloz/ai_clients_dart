import 'dart:async'
    show Completer, StreamController, ZoneSpecification, runZoned;
import 'dart:convert';
import 'dart:typed_data';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class _UploadClient extends http.BaseClient {
  _UploadClient(this._handle);

  final Future<http.StreamedResponse> Function(http.BaseRequest) _handle;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _handle(request);
}

class _PendingAuth implements AuthProvider {
  final requested = Completer<void>();
  final credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    requested.complete();
    return credentials.future;
  }
}

http.StreamedResponse _response(
  int status, {
  Map<String, String> headers = const {},
  String body = '',
}) => http.StreamedResponse(
  Stream.value(utf8.encode(body)),
  status,
  headers: headers,
);

void main() {
  const chunkSize = 8 * 1024 * 1024;
  const session = 'https://upload.example.com/path?upload_id=s%2B1&w=a&w=b';

  test('authenticates the start and uploads unauthenticated chunks', () async {
    final data = Uint8List(chunkSize + 2)
      ..[0] = 4
      ..[chunkSize - 1] = 9
      ..[chunkSize] = 128
      ..[chunkSize + 1] = 255;
    var call = 0;
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        baseUrl: 'https://example.com/gateway?route=one&route=two',
        authProvider: ApiKeyProvider('configured-key'),
        defaultHeaders: {
          'Authorization': 'Bearer gateway',
          'X-Goog-API-Key': 'gateway-key',
          'Cookie': 'gateway-cookie',
          'Content-Type': 'application/json',
        },
        defaultQueryParams: {'tenant': 'configured-tenant'},
      ),
      httpClient: _UploadClient((request) async {
        expect(request.followRedirects, isFalse);
        switch (call++) {
          case 0:
            expect(request.method, 'PUT');
            expect(request.url.pathSegments, [
              'gateway',
              'upload',
              'v1beta',
              'environments',
              'env/1',
              'files',
              'uploads',
              'a #b',
              '',
            ]);
            expect(request.url.queryParametersAll, {
              'route': ['one', 'two'],
              'tenant': ['configured-tenant'],
              'extract': ['true'],
              'overwrite': ['false'],
              'key': ['configured-key'],
            });
            expect(request.headers['authorization'], 'Bearer gateway');
            expect(request.headers['x-goog-api-key'], 'gateway-key');
            expect(request.headers['api-revision'], '2026-05-20');
            expect(request.headers['x-goog-upload-command'], 'start');
            expect(request.headers['x-goog-upload-protocol'], 'resumable');
            expect(
              request.headers['x-goog-upload-header-content-length'],
              '${data.length}',
            );
            expect(
              request.headers['x-goog-upload-header-content-type'],
              'application/x-tar',
            );
            expect(request.headers, isNot(contains('content-type')));
            expect(await request.finalize().toBytes(), isEmpty);
            data[0] = 1;
            return _response(200, headers: {'x-goog-upload-url': session});
          case 1:
            expect(request.method, 'POST');
            expect(request.url.toString(), session);
            expect(request.headers, {
              'x-goog-upload-offset': '0',
              'x-goog-upload-command': 'upload',
            });
            expect(request.contentLength, chunkSize);
            final body = await request.finalize().toBytes();
            expect(body.length, chunkSize);
            expect(body.first, 4);
            expect(body.last, 9);
            return _response(200, headers: {'x-goog-upload-status': 'active'});
          case 2:
            expect(request.method, 'POST');
            expect(request.url.toString(), session);
            expect(request.headers, {
              'x-goog-upload-offset': '$chunkSize',
              'x-goog-upload-command': 'upload, finalize',
            });
            expect(await request.finalize().toBytes(), [128, 255]);
            return _response(
              200,
              headers: {'x-goog-upload-status': 'final'},
              body:
                  '{"files":[{"path":"uploads/résumé.txt","size_bytes":"12"}]}',
            );
          default:
            fail('Unexpected upload attempt.');
        }
      }),
    );
    addTearDown(client.close);

    final result = await client.environments.files.upload(
      environment: 'environments/env/1',
      path: '/uploads/a #b/',
      bytes: data,
      mimeType: 'application/x-tar',
      extract: true,
      overwrite: false,
    );
    expect(call, 3);
    expect(result.files?.single.path, 'uploads/résumé.txt');
    expect(result.files?.single.sizeBytes, '12');
  });

  test(
    'finalizes an empty file with one request and accepts a file wrapper',
    () async {
      var call = 0;
      final client = GoogleAIClient(
        config: const GoogleAIConfig(
          authProvider: ApiKeyProvider(
            'header-key',
            placement: AuthPlacement.header,
          ),
        ),
        httpClient: _UploadClient((request) async {
          if (call++ == 0) {
            expect(
              request.url.path,
              '/upload/v1beta/environments/env/files/empty',
            );
            expect(request.url.queryParameters, isEmpty);
            expect(request.headers['x-goog-api-key'], 'header-key');
            expect(request.headers['x-goog-upload-header-content-length'], '0');
            expect(
              request.headers['x-goog-upload-header-content-type'],
              'application/octet-stream',
            );
            return _response(200, headers: {'x-goog-upload-url': session});
          }
          expect(request.url.toString(), session);
          expect(request.headers, {
            'x-goog-upload-offset': '0',
            'x-goog-upload-command': 'upload, finalize',
          });
          expect(await request.finalize().toBytes(), isEmpty);
          return _response(
            200,
            body: '{"file":{"name":"empty","size_bytes":"0"}}',
          );
        }),
      );
      addTearDown(client.close);

      final result = await client.environments.files.upload(
        environment: 'env',
        path: 'empty',
        bytes: const [],
      );
      expect(result.files?.single.name, 'empty');
      expect(result.files?.single.sizeBytes, '0');
      expect(call, 2);
    },
  );

  for (final invalid in [
    null,
    'http://untrusted.example.com/path?upload_id=secret',
    'https://user:secret@upload.example.com/path',
  ]) {
    test('rejects a missing or unsafe session URL ($invalid)', () async {
      var call = 0;
      final client = GoogleAIClient(
        httpClient: _UploadClient((request) async {
          expect(call++, 0);
          expect(request.method, 'PUT');
          return _response(200, headers: {'x-goog-upload-url': ?invalid});
        }),
      );
      addTearDown(client.close);

      await expectLater(
        client.environments.files.upload(
          environment: 'env',
          path: 'new.txt',
          bytes: const [1],
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', contains('session URL'))
              .having(
                (e) => e.toString(),
                'diagnostic',
                isNot(contains('secret')),
              ),
        ),
      );
      expect(call, 1);
    });
  }

  test(
    'does not replay transport failures or expose the session URL',
    () async {
      var call = 0;
      final client = GoogleAIClient(
        httpClient: _UploadClient((request) async {
          if (call++ == 0) {
            return _response(200, headers: {'x-goog-upload-url': session});
          }
          throw http.ClientException('Network error', request.url);
        }),
      );
      addTearDown(client.close);

      await expectLater(
        client.environments.files.upload(
          environment: 'env',
          path: 'new.txt',
          bytes: const [1],
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 0)
              .having(
                (e) => e.toString(),
                'diagnostic',
                isNot(contains('upload_id')),
              ),
        ),
      );
      expect(call, 2);
    },
  );

  test('does not report success when the last chunk stays active', () async {
    var call = 0;
    final client = GoogleAIClient(
      httpClient: _UploadClient((request) async {
        if (call++ == 0) {
          return _response(200, headers: {'x-goog-upload-url': session});
        }
        return _response(200, headers: {'x-goog-upload-status': 'active'});
      }),
    );
    addTearDown(client.close);

    await expectLater(
      client.environments.files.upload(
        environment: 'env',
        path: 'new.txt',
        bytes: const [1],
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('session status'),
        ),
      ),
    );
    expect(call, 2);
  });

  test(
    'aborts a timed-out transfer and sends no additional requests',
    () async {
      const timeout = Duration(milliseconds: 50);
      final abortSeen = Completer<void>();
      var call = 0;
      final client = GoogleAIClient(
        config: const GoogleAIConfig(timeout: timeout),
        httpClient: _UploadClient((request) async {
          if (call++ == 0) {
            return _response(200, headers: {'x-goog-upload-url': session});
          }
          await (request as http.Abortable).abortTrigger;
          abortSeen.complete();
          return _response(200, headers: {'x-goog-upload-status': 'final'});
        }),
      );
      addTearDown(client.close);

      await expectLater(
        client.environments.files.upload(
          environment: 'env',
          path: 'new.txt',
          bytes: const [1],
        ),
        throwsA(
          isA<TimeoutException>()
              .having((e) => e.timeout, 'timeout', timeout)
              .having(
                (e) => e.toString(),
                'diagnostic',
                isNot(contains('upload_id')),
              ),
        ),
      );
      await expectLater(abortSeen.future, completes);
      expect(call, 2);
    },
  );

  test(
    'cancels pending authentication without starting a late request',
    () async {
      final auth = _PendingAuth();
      final abort = Completer<void>();
      var requests = 0;
      final client = GoogleAIClient(
        config: GoogleAIConfig(authProvider: auth),
        httpClient: _UploadClient((request) async {
          requests++;
          return _response(200, headers: {'x-goog-upload-url': session});
        }),
      );
      addTearDown(client.close);

      final result = expectLater(
        client.environments.files.upload(
          environment: 'env',
          path: 'new.txt',
          bytes: const [1],
          abortTrigger: abort.future,
        ),
        throwsA(
          isA<AbortedException>()
              .having((e) => e.stage, 'stage', AbortionStage.beforeRequest)
              .having((e) => e.reason, 'reason', isNull),
        ),
      );
      await auth.requested.future;
      abort.complete();
      await result;
      auth.credentials.complete(const NoAuthCredentials());
      await Future<void>.delayed(Duration.zero);
      expect(requests, 0);
    },
  );

  test('applies the upload deadline while authentication is pending', () async {
    final auth = _PendingAuth();
    final client = GoogleAIClient(
      config: GoogleAIConfig(
        authProvider: auth,
        timeout: const Duration(milliseconds: 50),
      ),
      httpClient: _UploadClient((request) async => fail('Unexpected request.')),
    );
    addTearDown(client.close);

    final result = expectLater(
      client.environments.files.upload(
        environment: 'env',
        path: 'new.txt',
        bytes: const [1],
      ),
      throwsA(isA<TimeoutException>()),
    );
    await auth.requested.future;
    await result;
    auth.credentials.completeError(StateError('Late authentication error'));
    await Future<void>.delayed(Duration.zero);
  });

  test('uses the same deadline for auth and reading transfer bytes', () async {
    const timeout = Duration(seconds: 20);
    final auth = _PendingAuth();
    final transferListening = Completer<void>();
    final transferReaderCancelled = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: transferListening.complete,
      onCancel: transferReaderCancelled.complete,
    );
    addTearDown(body.close);
    void Function()? expire;
    var deadlines = 0;
    var requests = 0;
    final client = GoogleAIClient(
      config: GoogleAIConfig(authProvider: auth, timeout: timeout),
      httpClient: _UploadClient((request) async {
        if (requests++ == 0) {
          return _response(200, headers: {'x-goog-upload-url': session});
        }
        return http.StreamedResponse(body.stream, 200);
      }),
    );
    addTearDown(client.close);

    final result = expectLater(
      runZoned(
        () => client.environments.files.upload(
          environment: 'env',
          path: 'new.txt',
          bytes: const [1],
        ),
        zoneSpecification: ZoneSpecification(
          createTimer: (self, parent, zone, duration, callback) {
            if (duration == timeout) {
              deadlines++;
              expire = callback;
            }
            return parent.createTimer(zone, duration, callback);
          },
        ),
      ),
      throwsA(isA<TimeoutException>()),
    );
    await auth.requested.future;
    expect(deadlines, 1);
    final expireDuringAuth = expire!;
    auth.credentials.complete(const NoAuthCredentials());
    await transferListening.future;
    expect(deadlines, 1);
    expect(expire, same(expireDuringAuth));
    expireDuringAuth();
    await result;
    await transferReaderCancelled.future;
    expect(requests, 2);
  });

  test('does not dispatch another chunk after cancellation', () async {
    final abort = Completer<void>();
    var requests = 0;
    final client = GoogleAIClient(
      httpClient: _UploadClient((request) async {
        switch (requests++) {
          case 0:
            return _response(200, headers: {'x-goog-upload-url': session});
          case 1:
            expect(request.headers['x-goog-upload-command'], 'upload');
            return http.StreamedResponse(
              Stream<List<int>>.multi((controller) {
                controller.addSync(const []);
                abort.complete();
                controller.closeSync();
              }),
              200,
              headers: {'x-goog-upload-status': 'active'},
            );
          default:
            fail('Dispatched a chunk after cancellation.');
        }
      }),
    );
    addTearDown(client.close);

    await expectLater(
      client.environments.files.upload(
        environment: 'env',
        path: 'new.txt',
        bytes: Uint8List(chunkSize + 1),
        abortTrigger: abort.future,
      ),
      throwsA(isA<AbortedException>()),
    );
    expect(requests, 2);
  });

  test('removes the signed session URL from transport abort reasons', () async {
    var requests = 0;
    final client = GoogleAIClient(
      httpClient: _UploadClient((request) async {
        if (requests++ == 0) {
          return _response(200, headers: {'x-goog-upload-url': session});
        }
        throw http.RequestAbortedException(request.url);
      }),
    );
    addTearDown(client.close);

    await expectLater(
      client.environments.files.upload(
        environment: 'env',
        path: 'new.txt',
        bytes: const [1],
      ),
      throwsA(
        isA<AbortedException>()
            .having((e) => e.reason, 'reason', isNull)
            .having((e) => e.cause, 'cause', isNull)
            .having(
              (e) => e.toString(),
              'diagnostic',
              isNot(contains('upload_id')),
            ),
      ),
    );
    expect(requests, 2);
  });

  test('requires a workspace-relative destination path', () async {
    final client = GoogleAIClient(
      httpClient: _UploadClient((request) async => fail('Unexpected request.')),
    );
    addTearDown(client.close);

    await expectLater(
      client.environments.files.upload(
        environment: 'env',
        path: '/',
        bytes: const [1],
      ),
      throwsArgumentError,
    );
  });
}
