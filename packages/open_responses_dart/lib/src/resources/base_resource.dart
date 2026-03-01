import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../client/interceptor_chain.dart';
import '../client/request_builder.dart';

/// Base class for API resources.
///
/// Provides the five canonical fields shared by every resource:
/// [config], [httpClient], [interceptorChain], [requestBuilder],
/// and [ensureNotClosed]. Resources build [http.Request] objects inline
/// and call [interceptorChain.execute] directly — no HTTP dispatch helpers
/// live on this class.
abstract class ResourceBase {
  /// Client configuration.
  final OpenResponsesConfig config;

  /// HTTP client for requests.
  final http.Client httpClient;

  /// The interceptor chain for executing requests.
  final InterceptorChain interceptorChain;

  /// The request builder for constructing URLs and headers.
  final RequestBuilder requestBuilder;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Creates a [ResourceBase].
  ResourceBase({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
  });
}
