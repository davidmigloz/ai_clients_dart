import 'config.dart';

/// Builds API request URLs and headers with proper precedence.
///
/// Implements last-write-wins merge per spec:
/// - Headers: Global → Endpoint → Request (highest)
/// - Query Params: Global → Endpoint → Request (highest)
class RequestBuilder {
  /// Configuration.
  final AnthropicConfig config;

  /// Creates a [RequestBuilder].
  const RequestBuilder({required this.config});

  /// Builds a URL for an API endpoint.
  ///
  /// The [path] is a URL path (e.g. `/v1/messages`); pass query parameters via
  /// [queryParams] rather than embedding them in [path].
  ///
  /// Merges query parameters in order: Global → Request.
  /// Later values override earlier ones (last-write-wins).
  Uri buildUrl(String path, {Map<String, dynamic>? queryParams}) {
    // Parse the base URL so any existing path/query components are handled
    // correctly. Mirrors openai_dart's builder.
    final baseUri = Uri.parse(config.baseUrl);

    // Normalize the base path and requested path to avoid a double slash when
    // the configured base URL ends with a slash (e.g. a custom proxy or an
    // `ANTHROPIC_BASE_URL` with a trailing `/`).
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // Merge query params (last-write-wins), preserving any carried by the base
    // URL: base URL → configured defaults → per-request.
    final mergedParams = <String, dynamic>{
      ...baseUri.queryParameters,
      ...config.defaultQueryParams,
      ...?queryParams,
    };

    return baseUri.replace(
      path: '$basePath$normalizedPath',
      queryParameters: mergedParams.isEmpty ? null : mergedParams,
    );
  }

  /// Builds headers for a request.
  ///
  /// Merges headers in order: Global → Request.
  /// Later values override earlier ones (last-write-wins).
  ///
  /// Automatically adds:
  /// - `anthropic-version` header with configured API version
  /// - `content-type: application/json`
  Map<String, String> buildHeaders({Map<String, String>? additionalHeaders}) {
    return {
      'anthropic-version': config.apiVersion,
      'content-type': 'application/json',
      ...config.defaultHeaders,
      ...?additionalHeaders,
    };
  }
}
