import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/auth/request_auth.dart';
import 'package:anthropic_sdk_dart/src/client/interceptor_chain.dart';
import 'package:anthropic_sdk_dart/src/client/request_redirects.dart';
import 'package:anthropic_sdk_dart/src/errors/response_error.dart';
import 'package:anthropic_sdk_dart/src/interceptors/auth_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test(
    'requestless multipart response retains metadata and one stream owner',
    () async {
      const payload = [0x00, 0x80, 0xff];
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('https://example.invalid/v1/organizations/plugins'),
            )
            ..followRedirects = false
            ..headers['x-api-key'] = 'fixture-only-api-key'
            ..files.add(
              http.MultipartFile.fromBytes(
                'archive',
                payload,
                filename: 'fixture.zip',
              ),
            );
      var bodyListens = 0;
      final responseBytes = utf8.encode('{"ok":true}');
      final transport = _Transport((sent) async {
        expect(sent, same(request));
        expect(sent.headers['x-api-key'], 'fixture-only-api-key');
        final body = await sent.finalize().toBytes();
        expect(
          sent.headers['content-type'],
          startsWith('multipart/form-data; boundary='),
        );
        expect(
          latin1.decode(body),
          contains('name="archive"; filename="fixture.zip"'),
        );
        expect(latin1.decode(body), contains(latin1.decode(payload)));
        late StreamController<List<int>> bodyController;
        bodyController = StreamController<List<int>>(
          onListen: () {
            bodyListens++;
            bodyController.add(responseBytes);
            unawaited(bodyController.close());
          },
        );
        return http.StreamedResponse(
          bodyController.stream,
          201,
          contentLength: responseBytes.length,
          headers: {'request-id': 'req_safe'},
          isRedirect: false,
          persistentConnection: false,
          reasonPhrase: 'Fixture created',
        );
      });

      final response = await sendApiRequest(
        transport,
        request,
        ensureNotClosed: null,
        redirectErrorMessage: 'Unexpected redirect from the Admin API',
      );
      expect(response.request, same(request));
      expect(response.statusCode, 201);
      expect(response.contentLength, responseBytes.length);
      expect(response.headers, {'request-id': 'req_safe'});
      expect(response.isRedirect, isFalse);
      expect(response.persistentConnection, isFalse);
      expect(response.reasonPhrase, 'Fixture created');
      expect(bodyListens, 0);
      expect(await response.stream.toBytes(), responseBytes);
      expect(bodyListens, 1);
    },
  );

  test('existing provider response request stays authoritative', () async {
    final url = Uri.parse('https://example.invalid/v1/models');
    final outgoing = http.Request('GET', url)..followRedirects = false;
    final actual = http.Request('GET', url)
      ..headers['authorization'] = 'Bearer fixture-late-provider-credential';
    final raw = http.StreamedResponse(Stream.value([0]), 200, request: actual);
    final response = await sendApiRequest(
      _Transport((_) async => raw),
      outgoing,
      ensureNotClosed: null,
    );
    expect(response, same(raw));
    expect(response.request, same(actual));
    expect(await response.stream.toBytes(), [0]);
  });

  test(
    'responses isolate credentials when reusing a metadata request',
    () async {
      final url = Uri.parse('https://example.invalid/v1/models');
      final metadata = http.Request('GET', url)
        ..headers['x-request-id'] = 'req_shared';
      final transport = _Transport(
        (_) async => http.StreamedResponse(
          Stream.value(utf8.encode('{}')),
          200,
          request: metadata,
        ),
      );
      final chain = InterceptorChain(
        httpClient: transport,
        interceptors: const [],
      );
      final responses = await Future.wait([
        for (final key in ['first-fixture', 'second-fixture'])
          chain.execute(
            http.Request('GET', url)
              ..followRedirects = false
              ..headers['x-api-key'] = key,
          ),
      ]);
      expect(responses.map((response) => response.request), [
        metadata,
        metadata,
      ]);
      expect(responseCredentialValues(responses.first), {'first-fixture'});
      expect(responseCredentialValues(responses.last), {'second-fixture'});
      expect(requestDiagnosticCredentials(metadata), isEmpty);
    },
  );

  test(
    'buffered multipart diagnostics use the effective request after auth',
    () async {
      const token = 'fixture-only-multipart-token+/=';
      final encoded = Uri.encodeComponent(token);
      final malformed = '{"invalid":"$encoded';
      late final int? offset;
      try {
        jsonDecode(malformed);
        fail('Expected invalid fixture JSON to throw');
      } on FormatException catch (error) {
        offset = error.offset;
      }
      final transport = _Transport((sent) async {
        expect(sent.headers['authorization'], 'Bearer $token');
        expect(sent.headers['content-type'], isNull);
        final body = await sent.finalize().toBytes();
        expect(
          sent.headers['content-type'],
          startsWith('multipart/form-data; boundary='),
        );
        expect(
          utf8.decode(body),
          contains('name="files[]"; filename="fixture.txt"'),
        );
        return http.StreamedResponse(
          Stream.value(utf8.encode(malformed)),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('https://example.invalid/v1/organizations/plugins'),
            )
            ..followRedirects = false
            ..files.add(
              http.MultipartFile.fromString(
                'files[]',
                'fixture',
                filename: 'fixture.txt',
              ),
            );
      final chain = InterceptorChain(
        httpClient: transport,
        interceptors: const [
          AuthInterceptor(authProvider: BearerTokenProvider(token)),
        ],
        timeout: const Duration(seconds: 3),
      );
      final response = await chain.execute(
        request,
        redirectErrorMessage: 'Unexpected redirect from the Admin API',
      );
      expect(response.request!.headers['authorization'], 'Bearer $token');
      expect(
        () => decodeApiJsonResponse(response, (json) => json),
        throwsA(
          isA<FormatException>()
              .having((error) => error.offset, 'offset', offset)
              .having((error) => error.source, 'source', isNull)
              .having(
                (error) => error.toString(),
                'description',
                isNot(contains(encoded)),
              ),
        ),
      );
    },
  );
}

final class _Transport extends http.BaseClient {
  _Transport(this.callback);

  final Future<http.StreamedResponse> Function(http.BaseRequest) callback;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      callback(request);
}
