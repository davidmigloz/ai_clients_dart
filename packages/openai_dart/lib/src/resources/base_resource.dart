import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../client/interceptor_chain.dart';
import '../client/request_builder.dart';

/// Base class for all API resources.
///
/// Provides shared infrastructure (config, HTTP client, interceptors, request
/// builder) to all resource implementations. Resources delegate actual
/// HTTP execution to the interceptor chain to maintain consistent auth, retry,
/// logging, and error handling behavior.
abstract class ResourceBase {
  /// Client configuration.
  final OpenAIConfig config;

  /// HTTP client for making requests.
  final http.Client httpClient;

  /// Interceptor chain for request/response processing.
  final InterceptorChain interceptorChain;

  /// Request builder for constructing HTTP requests.
  final RequestBuilder requestBuilder;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Factory for creating dedicated HTTP clients for streaming requests.
  final http.Client Function()? streamClientFactory;

  /// Creates a [ResourceBase].
  ResourceBase({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
    this.streamClientFactory,
  });
}

/// Extracts a human-readable error message from a JSON error response.
///
/// Handles both flat `{message: "..."}` (custom proxies) and nested
/// `{error: {message: "..."}}` (OpenAI-style) shapes.
String extractErrorMessage(Map<String, dynamic> json) {
  final message = json['message'];
  if (message != null) return message.toString();
  final error = json['error'];
  if (error is Map) return (error['message'] ?? error).toString();
  if (error != null) return error.toString();
  return 'unknown error';
}
