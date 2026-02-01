import 'dart:convert';

import '../client/openai_client.dart';

/// Base class for all API resources.
///
/// Provides common functionality for making API requests
/// and handling responses.
///
/// Error handling is performed by the [ErrorInterceptor] in the
/// interceptor chain, so these helper methods don't need to check
/// for error status codes.
abstract class BaseResource {
  /// Creates a [BaseResource] with the given client.
  const BaseResource(this.client);

  /// The client used to make API requests.
  final OpenAIClient client;

  // ============================================================
  // HTTP Helper Methods
  // ============================================================

  /// Makes a GET request and returns the decoded JSON response.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
  }) async {
    final response = await client.get(
      endpoint,
      queryParameters: queryParameters,
      abortTrigger: abortTrigger,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Makes a POST request with JSON body and returns the decoded JSON response.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Map<String, dynamic>> postJson(
    String endpoint, {
    required Map<String, dynamic> body,
    Future<void>? abortTrigger,
  }) async {
    final response = await client.post(
      endpoint,
      body: jsonEncode(body),
      abortTrigger: abortTrigger,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Makes a DELETE request and returns the decoded JSON response.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Map<String, dynamic>> deleteJson(
    String endpoint, {
    Future<void>? abortTrigger,
  }) async {
    final response = await client.delete(endpoint, abortTrigger: abortTrigger);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Makes a GET request with support for repeated query parameters.
  ///
  /// Use this for endpoints that require array parameters like `include[]`.
  /// The optional [abortTrigger] allows canceling the request.
  Future<Map<String, dynamic>> getJsonWithRepeatedParams(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, List<String>>? queryParametersAll,
    Future<void>? abortTrigger,
  }) async {
    final response = await client.getWithRepeatedParams(
      endpoint,
      queryParameters: queryParameters,
      queryParametersAll: queryParametersAll,
      abortTrigger: abortTrigger,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
