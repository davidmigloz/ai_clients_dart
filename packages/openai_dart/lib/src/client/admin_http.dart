import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../errors/exceptions.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../platform/http_utils.dart';
import '../utils/private_audio_http.dart';
import 'admin_config.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'request_builder.dart';
import 'retry_wrapper.dart';

/// Shared implementation detail for the bounded, independently authenticated Admin namespace.
final class AdminHttp {
  /// Creates a private interceptor pipeline without reading any project credentials.
  AdminHttp(this.config, http.Client? client)
    : _ownsClient = client == null,
      _client = client ?? http.Client() {
    final internal = OpenAIConfig(
      baseUrl: config.baseUrl,
      organization: config.organization,
      defaultHeaders: config.defaultHeaders,
      timeout: config.timeout,
      retryPolicy: config.retryPolicy,
    );
    _builder = RequestBuilder(config: internal);
    _chain = InterceptorChain(
      interceptors: [
        _AdminAuth(config, ensureOpen),
        if (config.logLevel != null)
          LoggingInterceptor(
            logger: Logger('OpenAIAdminClient'),
            logRequestBody: config.logLevel == Level.FINEST,
            logResponseBody: config.logLevel == Level.FINEST,
          ),
        const ErrorInterceptor(),
      ],
      httpClient: _AdminTransport(_client),
      retryWrapper: config.retryPolicy.maxRetries > 0
          ? RetryWrapper(config: internal)
          : null,
      timeout: config.timeout,
      ensureNotClosed: ensureOpen,
    );
  }

  /// Explicit Admin configuration.
  final OpenAIAdminConfig config;
  final http.Client _client;
  final bool _ownsClient;
  late final RequestBuilder _builder;
  late final InterceptorChain _chain;
  bool _closed = false;

  /// Rejects access to a closed logical client.
  void ensureOpen() {
    if (_closed) throw StateError('OpenAIAdminClient is closed.');
  }

  /// Closes only the internally created transport, once.
  void close() {
    if (_closed) return;
    _closed = true;
    if (_ownsClient) _client.close();
  }

  /// Executes one page or operation through ordinary HTTP timeout/retry policy.
  Future<T> json<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, List<String>>? repeated,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    ensureOpen();
    final headers = Map<String, String>.of(additionalHeaders ?? const {});
    await checkPrivateAudioAbort(abortTrigger, 'Admin');
    ensureOpen();
    final request =
        http.Request(
            method,
            _builder.buildUrlWithQueryAll(
              path,
              queryParameters: query,
              queryParametersAll: repeated,
            ),
          )
          ..followRedirects = false
          ..headers.addAll(_builder.buildHeaders(additionalHeaders: headers))
          ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.bodyBytes = utf8.encode(jsonEncode(body));
    } else {
      request.headers.remove('Content-Type');
    }
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: _chain,
      context: 'Admin',
      abortTrigger: abortTrigger,
    );
    if (response.statusCode != 200) {
      throw ParseException(
        message: 'Invalid Admin response: expected HTTP 200.',
        responseBody: response.body,
      );
    }
    return parsePrivateAudioResponse(response, parse, 'Admin');
  }
}

final class _AdminAuth implements Interceptor {
  const _AdminAuth(this.config, this.ensureOpen);
  final OpenAIAdminConfig config;
  final void Function() ensureOpen;

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) {
    ensureOpen();
    final String token;
    try {
      final headers = config.authProvider.getHeaders();
      final auth = headers.entries
          .where((e) => e.key.toLowerCase() == 'authorization')
          .toList();
      if (auth.length != 1 ||
          !RegExp(
            r'^Bearer [^\s]+$',
            caseSensitive: false,
          ).hasMatch(auth.single.value)) {
        throw const FormatException(
          'Admin credentials require a Bearer token.',
        );
      }
      token = auth.single.value;
    } catch (error) {
      throw ConnectionException(
        message: 'Admin credential provider failed.',
        cause: error,
        redactDiagnostics: true,
      );
    }
    ensureOpen();
    // Only Authorization is consumed from providers. This prevents unrelated
    // provider headers from changing selected body encoding or request routing.
    context.request.headers['Authorization'] = token;
    context.request.followRedirects = false;
    return next(context);
  }
}

final class _AdminTransport extends http.BaseClient {
  _AdminTransport(this.inner);
  final http.Client inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      request.followRedirects = false;
      final response = await inner.send(request);
      return http.StreamedResponse(
        _privateStream(response.stream),
        response.statusCode,
        contentLength: response.contentLength,
        request: request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } on http.RequestAbortedException {
      rethrow;
    } catch (error) {
      // Preserve the existing retry classifier. The private logger never prints
      // native network failures; sendPrivateAudioRequest redacts the final one.
      if (error is http.ClientException || isSocketException(error)) rethrow;
      throw ConnectionException(
        message: 'Admin transport failed.',
        cause: error,
        redactDiagnostics: true,
      );
    }
  }

  Stream<List<int>> _privateStream(Stream<List<int>> stream) async* {
    try {
      await for (final bytes in stream) {
        yield bytes;
      }
    } on http.RequestAbortedException {
      rethrow;
    } catch (error) {
      if (error is http.ClientException || isSocketException(error)) rethrow;
      throw ConnectionException(
        message: 'Admin response stream failed.',
        cause: error,
        redactDiagnostics: true,
      );
    }
  }
}

/// Encodes an opaque identifier exactly once, rejecting URI normalization loss.
String adminPathId(String value, String context) {
  adminQueryString(value, context);
  if (value.isEmpty || value == '.' || value == '..') {
    throw FormatException('$context: invalid identifier.');
  }
  return Uri.encodeComponent(value);
}

/// Keeps exact cursor/filter values rather than silently replacing invalid UTF-16.
String adminQueryString(String value, String context) {
  if (Uri.decodeComponent(Uri.encodeComponent(value)) != value) {
    throw FormatException('$context: invalid Unicode.');
  }
  return value;
}
