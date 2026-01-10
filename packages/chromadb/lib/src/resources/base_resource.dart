import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../client/interceptor_chain.dart';
import '../client/request_builder.dart';
import '../client/retry_wrapper.dart';
import '../interceptors/interceptor.dart';

/// Base class for all API resources.
///
/// This abstract class provides shared infrastructure for making HTTP requests
/// including the interceptor chain, request builder, and retry logic.
///
/// Subclasses should use the [get], [post], [put], [patch], and [delete]
/// helper methods to make requests.
abstract class ResourceBase {
  /// The client configuration.
  final ChromaConfig config;

  /// The HTTP client for making requests.
  final http.Client httpClient;

  /// The interceptor chain for processing requests.
  final InterceptorChain interceptorChain;

  /// The request builder for constructing URLs.
  final RequestBuilder requestBuilder;

  /// The retry wrapper for automatic retries.
  final RetryWrapper retryWrapper;

  /// Creates a resource with the given infrastructure.
  ResourceBase({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    required this.retryWrapper,
  });

  // ===========================================================================
  // HTTP Helper Methods
  // ===========================================================================

  /// Makes a GET request.
  ///
  /// [path] - The URL path (will be appended to base URL)
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional additional headers
  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      isIdempotent: true,
    );
  }

  /// Makes a POST request.
  ///
  /// [path] - The URL path (will be appended to base URL)
  /// [body] - Optional request body (will be JSON encoded if not a String)
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional additional headers
  /// [isIdempotent] - Whether the request is idempotent (affects retry)
  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool isIdempotent = false,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      isIdempotent: isIdempotent,
    );
  }

  /// Makes a PUT request.
  ///
  /// [path] - The URL path (will be appended to base URL)
  /// [body] - Optional request body (will be JSON encoded if not a String)
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional additional headers
  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      isIdempotent: true,
    );
  }

  /// Makes a PATCH request.
  ///
  /// [path] - The URL path (will be appended to base URL)
  /// [body] - Optional request body (will be JSON encoded if not a String)
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional additional headers
  Future<http.Response> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      isIdempotent: false,
    );
  }

  /// Makes a DELETE request.
  ///
  /// [path] - The URL path (will be appended to base URL)
  /// [body] - Optional request body (will be JSON encoded if not a String)
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional additional headers
  Future<http.Response> delete(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      isIdempotent: true,
    );
  }

  /// Internal method to send requests through the retry wrapper.
  Future<http.Response> _send({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    required bool isIdempotent,
  }) {
    // Build full URL for metadata tracking
    final fullUrl = requestBuilder.buildUrl(
      path,
      queryParameters: queryParameters,
    );

    final context = RequestContext(
      method: method,
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      fullUrl: fullUrl,
    );

    return retryWrapper.send(context, isIdempotent: isIdempotent);
  }

  // ===========================================================================
  // Response Parsing Helpers
  // ===========================================================================

  /// Parses a JSON response body into a Map.
  Map<String, dynamic> parseJson(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Parses a JSON array response body into a List of Maps.
  List<Map<String, dynamic>> parseJsonList(http.Response response) {
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// Parses a JSON response body that contains just an integer.
  int parseInt(http.Response response) {
    return jsonDecode(response.body) as int;
  }
}
