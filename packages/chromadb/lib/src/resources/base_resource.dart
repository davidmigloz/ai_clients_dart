import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../client/interceptor_chain.dart';
import '../client/request_builder.dart';

/// Base class for all API resources.
///
/// This abstract class provides shared infrastructure for making HTTP requests
/// including the interceptor chain and request builder.
///
/// Subclasses build `http.Request` objects inline and send them via
/// [interceptorChain.execute()].
abstract class ResourceBase {
  /// The client configuration.
  final ChromaConfig config;

  /// The HTTP client for making requests.
  final http.Client httpClient;

  /// The interceptor chain for processing requests.
  final InterceptorChain interceptorChain;

  /// The request builder for constructing URLs and headers.
  final RequestBuilder requestBuilder;

  /// Callback that throws if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Creates a resource with the given infrastructure.
  ResourceBase({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
  });

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
