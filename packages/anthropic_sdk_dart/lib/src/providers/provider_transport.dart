import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
import '../client/anthropic_client.dart';
import '../client/config.dart';
import '../errors/response_error.dart';
import '../platform/environment.dart';

/// An Anthropic client backed by a provider-specific HTTP transport.
abstract base class ProviderAnthropicClient extends AnthropicClient {
  /// Creates a client that owns the provider transport.
  ProviderAnthropicClient(AnthropicConfig config, this._transport)
    : super(config: config, httpClient: _transport);

  final ProviderTransport _transport;

  @override
  void close() {
    super.close();
    _transport.close();
  }
}

/// The Claude request before provider-specific routing and authentication.
final class ProviderRequest {
  /// Creates the request data to adapt before sending.
  ProviderRequest({
    required this.method,
    required this.uri,
    required this.headers,
    required this.body,
  });

  /// HTTP method.
  final String method;

  /// Current provider URI.
  Uri uri;

  /// Lowercase HTTP headers.
  final Map<String, String> headers;

  /// Body bytes before or after provider transformation.
  Uint8List body;
}

/// Adapts a final HTTP request while retaining the caller's abort signal.
abstract base class ProviderTransport extends http.BaseClient {
  /// Wraps a borrowed transport or creates and owns one.
  ProviderTransport(http.Client? client)
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final _preparations = <Completer<ProviderRequest>>{};
  bool _closed = false;

  /// Applies provider routing and authentication.
  Future<void> prepare(ProviderRequest request);

  /// Adapts provider-specific headers or response framing.
  http.StreamedResponse adaptResponse(
    ProviderRequest request,
    http.StreamedResponse response,
  ) => response;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _ensureOpen();
    final abort = request is http.Abortable ? request.abortTrigger : null;
    final prepared = await _prepareRequest(request, abort);
    _ensureOpen();
    final outbound =
        http.AbortableRequest(
            prepared.method,
            prepared.uri,
            abortTrigger: abort,
          )
          ..followRedirects = false
          ..persistentConnection = request.persistentConnection
          ..headers.addAll(prepared.headers)
          ..bodyBytes = prepared.body;
    final http.StreamedResponse response;
    try {
      response = await _client.send(outbound);
    } on http.ClientException catch (error, stackTrace) {
      if (redactCredentialEcho(
            error.message,
            requestCredentialValues(outbound.headers),
          ) !=
          null) {
        rethrow;
      }
      Error.throwWithStackTrace(
        http.ClientException(
          'Provider transport error contained a redacted credential',
          outbound.url,
        ),
        stackTrace,
      );
    }
    final adapted = adaptResponse(prepared, response);
    // Borrowed transports may omit request metadata. Record the exact sent
    // request so response diagnostics can redact late-bound cloud credentials.
    return http.StreamedResponse(
      adapted.stream,
      adapted.statusCode,
      request: outbound,
      headers: adapted.headers,
      contentLength: adapted.contentLength,
      isRedirect: adapted.isRedirect,
      persistentConnection: adapted.persistentConnection,
      reasonPhrase: adapted.reasonPhrase,
    );
  }

  Future<ProviderRequest> _prepareRequest(
    http.BaseRequest request,
    Future<void>? abort,
  ) async {
    final result = Completer<ProviderRequest>();
    _preparations.add(result);
    final abortSubscription = abort?.asStream().listen((_) {
      if (!result.isCompleted) {
        result.completeError(http.RequestAbortedException(request.url));
      }
    }, onError: (Object _, StackTrace _) {});
    try {
      unawaited(Future<void>.microtask(() => _runPreparation(request, result)));
      return await result.future;
    } finally {
      _preparations.remove(result);
      unawaited(abortSubscription?.cancel());
    }
  }

  Future<void> _runPreparation(
    http.BaseRequest request,
    Completer<ProviderRequest> result,
  ) async {
    try {
      if (result.isCompleted) return;
      // Multipart requests publish their boundary when finalized.
      final bytes = await request.finalize().toBytes();
      if (result.isCompleted) return;
      final prepared = ProviderRequest(
        method: request.method,
        uri: request.url,
        headers: {
          for (final header in request.headers.entries)
            header.key.toLowerCase(): header.value,
        },
        body: bytes,
      );
      await prepare(prepared);
      // Let cancellation queued during credential acquisition win.
      await Future<void>.delayed(Duration.zero);
      if (!result.isCompleted) result.complete(prepared);
    } catch (error, stackTrace) {
      if (!result.isCompleted) result.completeError(error, stackTrace);
    }
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    for (final pending in _preparations) {
      if (!pending.isCompleted) pending.completeError(_closedError());
    }
    if (_ownsClient) _client.close();
  }

  void _ensureOpen() {
    if (_closed) throw _closedError();
  }

  StateError _closedError() => StateError('The provider client is closed');
}

/// Ensures the provider URL is safe to use with scoped credentials.
Uri validateProviderBase(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      (uri.scheme != 'https' && uri.scheme != 'http') ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasFragment) {
    throw ArgumentError(
      'Provider base URL must be an HTTP(S) URL without user info or fragment',
    );
  }
  return uri;
}

/// Returns logical API path segments after the configured proxy prefix.
List<String> providerPath(Uri uri, Uri base) {
  final prefix = base.pathSegments;
  final offset = prefix.isNotEmpty && prefix.last.isEmpty
      ? prefix.length - 1
      : prefix.length;
  return uri.pathSegments.skip(offset).toList();
}

/// Reads optional provider defaults on platforms with an environment.
String? providerEnvironmentValue(String name) {
  try {
    return getEnvironmentVariable(name);
  } on UnsupportedError {
    return null;
  }
}

/// Returns a non-default base URL supplied through a Claude config.
String? configuredProviderBase(String value) =>
    value == 'https://api.anthropic.com' ? null : value;
