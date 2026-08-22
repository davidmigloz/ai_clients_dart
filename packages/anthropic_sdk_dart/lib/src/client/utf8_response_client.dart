import 'package:http/http.dart' as http;

/// An [http.Client] wrapper that labels JSON responses as UTF-8.
///
/// The API returns `content-type: application/json` without a charset
/// parameter. When the charset is absent, `package:http` falls back to
/// latin-1 in [http.Response.body], so any non-ASCII character in a
/// response is mangled before it reaches `jsonDecode`: `Barœul` is read as
/// `BarÅul`, `Müller` as `MÃ¼ller`.
///
/// JSON is always UTF-8 (RFC 8259 §8.1), so labelling the response is safe
/// and does not alter the bytes. Only the `content-type` header is
/// rewritten, and only when it announces JSON without a charset.
///
/// Streaming responses are unaffected: the SSE parser already decodes bytes
/// with `utf8.decoder`.
class Utf8ResponseClient extends http.BaseClient {
  /// Creates a client that delegates to [_inner].
  Utf8ResponseClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    final contentType = response.headers['content-type'];
    if (contentType == null ||
        !contentType.contains('json') ||
        contentType.contains('charset')) {
      return response;
    }
    return http.StreamedResponse(
      response.stream,
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: {
        ...response.headers,
        'content-type': '$contentType; charset=utf-8',
      },
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}
