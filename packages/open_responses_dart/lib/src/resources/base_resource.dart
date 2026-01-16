import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/interceptor_chain.dart';
import '../client/request_builder.dart';

/// Base class for API resources.
///
/// Provides common functionality for making HTTP requests
/// through the interceptor chain.
abstract class ResourceBase {
  /// The interceptor chain for executing requests.
  final InterceptorChain _chain;

  /// The request builder for constructing URLs and headers.
  final RequestBuilder requestBuilder;

  /// Creates a [ResourceBase].
  const ResourceBase({
    required InterceptorChain chain,
    required this.requestBuilder,
  }) : _chain = chain;

  /// Protected access to the interceptor chain for subclasses.
  InterceptorChain get chain => _chain;

  /// Makes a GET request.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) async {
    final uri = requestBuilder.buildUrl(path, queryParams: queryParams);
    final request = http.Request('GET', uri)
      ..headers.addAll(requestBuilder.buildHeaders(additionalHeaders: headers));

    final response = await _chain.execute(request, abortTrigger: abortTrigger);
    return _parseResponse(response);
  }

  /// Makes a POST request with JSON body.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) async {
    final uri = requestBuilder.buildUrl(path, queryParams: queryParams);
    final request = http.Request('POST', uri)
      ..headers.addAll(requestBuilder.buildHeaders(additionalHeaders: headers))
      ..body = jsonEncode(body);

    final response = await _chain.execute(request, abortTrigger: abortTrigger);
    return _parseResponse(response);
  }

  /// Makes a DELETE request.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) async {
    final uri = requestBuilder.buildUrl(path, queryParams: queryParams);
    final request = http.Request('DELETE', uri)
      ..headers.addAll(requestBuilder.buildHeaders(additionalHeaders: headers));

    final response = await _chain.execute(request, abortTrigger: abortTrigger);
    return _parseResponse(response);
  }

  /// Parses the HTTP response body as JSON.
  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
