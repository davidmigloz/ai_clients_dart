import 'dart:async' show Completer;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import '../../client/retry_wrapper.dart';
import '../../errors/exceptions.dart';
import '../../interceptors/error_interceptor.dart';
import '../../interceptors/interceptor.dart';
import '../../interceptors/logging_interceptor.dart';

/// Shared HTTP transport for the standalone Mistral Admin client.
class AdminTransport {
  /// Creates an isolated transport for Admin operations.
  AdminTransport({
    required String apiKey,
    required String baseUrl,
    required Duration timeout,
    required Level logLevel,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client(),
       _ownsClient = httpClient == null,
       _timeout = timeout {
    if (apiKey.trim().isEmpty) {
      throw ArgumentError('A dedicated Mistral Admin API key is required.');
    }
    final config = MistralConfig(
      baseUrl: baseUrl,
      timeout: timeout,
      logLevel: logLevel,
      retryPolicy: const RetryPolicy(maxRetries: 0),
      defaultHeaders: {'x-api-key': apiKey},
    );
    _builder = RequestBuilder(config: config);
    _chain = _buildChain(config, apiKey);
    _secretChain = _buildChain(config, apiKey, secretResponse: true);
  }

  InterceptorChain _buildChain(
    MistralConfig config,
    String apiKey, {
    bool secretResponse = false,
  }) => InterceptorChain(
    httpClient: _client,
    interceptors: [
      LoggingInterceptor(
        logLevel: config.logLevel,
        redactionList: config.redactionList,
        sendRequestIdHeader: config.sendRequestIdHeader,
      ),
      const ErrorInterceptor(),
      _AdminErrorSanitizer(apiKey, secretResponse: secretResponse),
    ],
    retryWrapper: RetryWrapper(config: config),
    ensureNotClosed: _ensureNotClosed,
  );

  final http.Client _client;
  final bool _ownsClient;
  final Duration _timeout;
  late final RequestBuilder _builder;
  late final InterceptorChain _chain;
  late final InterceptorChain _secretChain;
  bool _closed = false;

  /// Sends an Admin operation with an object response.
  ///
  /// Set [secretResponse] when the body may carry newly issued credentials.
  Future<T> json<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? query,
    Object? body,
    bool secretResponse = false,
  }) async {
    final response = await _send(
      method,
      path,
      query: query,
      body: body,
      secretResponse: secretResponse,
    );
    try {
      return decode(jsonDecode(response.body) as Map<String, dynamic>);
    } on FormatException {
      if (secretResponse) {
        throw const FormatException('Invalid Admin API key response.');
      }
      rethrow;
    }
  }

  /// Sends an Admin operation with an array response.
  Future<List<T>> list<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final response = await _send(method, path, query: query, body: body);
    return (jsonDecode(response.body) as List)
        .cast<Map<String, dynamic>>()
        .map(decode)
        .toList();
  }

  /// Sends an Admin operation with no response body.
  Future<void> empty(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    await _send(method, path, query: query, body: body);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool secretResponse = false,
  }) async {
    final request =
        http.Request(method, _builder.buildUrl(path, queryParams: query))
          ..followRedirects = false
          ..headers.addAll(
            _builder.buildHeaders(
              additionalHeaders: {
                'Accept': 'application/json',
                if (body != null) 'Content-Type': 'application/json',
              },
            ),
          );
    if (body != null) request.body = jsonEncode(body);
    final chain = secretResponse ? _secretChain : _chain;
    final abort = Completer<void>();
    final watch = Stopwatch()..start();
    final response = await chain
        .execute(request, abortTrigger: abort.future)
        .timeout(
          _timeout,
          onTimeout: () {
            abort.complete();
            throw TimeoutException(
              message: 'Mistral Admin request timed out.',
              timeout: _timeout,
              elapsed: watch.elapsed,
            );
          },
        );
    if (response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected redirect from the Mistral Admin API.',
      );
    }
    return response;
  }

  void _ensureNotClosed() {
    if (_closed) throw StateError('The Mistral Admin client is closed.');
  }

  /// Closes the Admin transport and its owned HTTP client.
  void close() {
    if (_closed) return;
    _closed = true;
    if (_ownsClient) _client.close();
  }
}

class _AdminErrorSanitizer implements Interceptor {
  const _AdminErrorSanitizer(this._credential, {required this.secretResponse});

  final bool secretResponse;

  final String _credential;
  static const _redacted = '[REDACTED]';

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final http.Response response;
    try {
      response = await next(context);
    } on MistralException {
      rethrow;
    } catch (error) {
      // A supplied transport can include the request headers in an exception.
      // Keep those credentials out of both the public exception and the log.
      if (secretResponse || error.toString().contains(_credential)) {
        throw http.ClientException('Mistral Admin transport failed.');
      }
      rethrow;
    }
    if (response.statusCode < 400) return response;
    if (secretResponse) {
      return http.Response(
        '{"message":"The Admin API rejected the key operation."}',
        response.statusCode,
      );
    }

    String cleanBody;
    try {
      cleanBody = jsonEncode(_redactJson(jsonDecode(response.body)));
    } on FormatException {
      cleanBody = _redactText(response.body);
    }
    return http.Response(
      cleanBody,
      response.statusCode,
      headers: {
        for (final entry in response.headers.entries)
          _redactText(entry.key): _isCredentialField(entry.key)
              ? _redacted
              : _redactText(entry.value),
      },
    );
  }

  Object? _redactJson(Object? value) => switch (value) {
    final String text => _redactText(text),
    final List<Object?> items => items.map(_redactJson).toList(),
    final Map<String, dynamic> fields => {
      for (final entry in fields.entries)
        _redactText(
          entry.key,
        ): _isCredentialField(entry.key) && entry.value != null
            ? _redacted
            : _redactJson(entry.value),
    },
    _ => value,
  };

  String _redactText(String value) => value.replaceAll(_credential, _redacted);

  static bool _isCredentialField(String name) =>
      switch (name.toLowerCase().replaceAll('-', '_')) {
        'api_key' ||
        'x_api_key' ||
        'authorization' ||
        'key' ||
        'hidden_key' ||
        'token' ||
        'client_secret' ||
        'secret' ||
        'set_cookie' => true,
        _ => false,
      };
}
