import 'dart:convert';

import 'package:anthropic_sdk_dart/src/client/utf8_response_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

/// Builds a client that always replies with [body], labelled [contentType].
Utf8ResponseClient clientReplying(List<int> body, String? contentType) {
  return Utf8ResponseClient(
    MockClient(
      (_) async => http.Response.bytes(
        body,
        200,
        headers: {'content-type': ?contentType},
      ),
    ),
  );
}

void main() {
  group('Utf8ResponseClient', () {
    // The API replies `application/json` with no charset. Without a charset,
    // package:http decodes Response.body as latin-1, which mangles every
    // non-ASCII character before jsonDecode ever sees it.
    test('decodes JSON responses without a charset as UTF-8', () async {
      final client = clientReplying(
        utf8.encode('{"city":"Marcq-en-Barœul"}'),
        'application/json',
      );

      final response = await client.get(Uri.parse('https://example.com'));

      expect(jsonDecode(response.body), {'city': 'Marcq-en-Barœul'});
    });

    test('leaves an explicit charset untouched', () async {
      final client = clientReplying(
        utf8.encode('{"city":"Marcq-en-Barœul"}'),
        'application/json; charset=utf-8',
      );

      final response = await client.get(Uri.parse('https://example.com'));

      expect(response.headers['content-type'], 'application/json; charset=utf-8');
      expect(jsonDecode(response.body), {'city': 'Marcq-en-Barœul'});
    });

    test('leaves non-JSON responses untouched', () async {
      final client = clientReplying(utf8.encode('plain'), 'text/plain');

      final response = await client.get(Uri.parse('https://example.com'));

      expect(response.headers['content-type'], 'text/plain');
    });

    test('leaves responses without a content-type untouched', () async {
      final client = clientReplying(utf8.encode('{}'), null);

      final response = await client.get(Uri.parse('https://example.com'));

      expect(response.headers.containsKey('content-type'), isFalse);
    });

    test('preserves status code and reason phrase', () async {
      final client = Utf8ResponseClient(
        MockClient(
          (_) async => http.Response(
            '{"error":"nope"}',
            429,
            headers: {'content-type': 'application/json'},
            reasonPhrase: 'Too Many Requests',
          ),
        ),
      );

      final response = await client.get(Uri.parse('https://example.com'));

      expect(response.statusCode, 429);
      expect(response.reasonPhrase, 'Too Many Requests');
    });

    test('closes the inner client', () {
      var closed = false;
      Utf8ResponseClient(_ClosableClient(() => closed = true)).close();

      expect(closed, isTrue);
    });
  });
}

class _ClosableClient extends http.BaseClient {
  _ClosableClient(this.onClose);

  final void Function() onClose;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnimplementedError();

  @override
  void close() => onClose();
}
