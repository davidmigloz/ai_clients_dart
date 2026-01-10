/// Builds URLs and headers for HTTP requests.
///
/// This class handles:
/// - Constructing full URLs from base URL and path
/// - Merging query parameters
/// - Merging headers with last-write-wins precedence
///
/// Example:
/// ```dart
/// final builder = RequestBuilder(
///   baseUrl: 'http://localhost:8000',
///   defaultHeaders: {'User-Agent': 'chromadb-dart/1.0.0'},
/// );
///
/// final url = builder.buildUrl('/api/v2/collections');
/// final headers = builder.buildHeaders({'X-Custom': 'value'});
/// ```
class RequestBuilder {
  /// The base URL for all requests.
  final String baseUrl;

  /// Default headers to include in all requests.
  final Map<String, String> defaultHeaders;

  /// Default query parameters to include in all requests.
  final Map<String, String> defaultQueryParameters;

  /// Creates a request builder.
  RequestBuilder({
    required this.baseUrl,
    Map<String, String>? defaultHeaders,
    Map<String, String>? defaultQueryParameters,
  }) : defaultHeaders = defaultHeaders ?? {},
       defaultQueryParameters = defaultQueryParameters ?? {};

  /// Builds a complete URL from a path and optional query parameters.
  ///
  /// The [path] should start with a `/` and will be appended to the base URL.
  /// Query parameters are merged with defaults using last-write-wins.
  Uri buildUrl(String path, {Map<String, String>? queryParameters}) {
    final baseUri = Uri.parse(baseUrl);

    // Merge query parameters (request params override defaults)
    final mergedParams = <String, String>{
      ...defaultQueryParameters,
      if (queryParameters != null) ...queryParameters,
    };

    // Handle path properly - avoid double slashes
    String fullPath;
    if (baseUri.path.isEmpty || baseUri.path == '/') {
      fullPath = path;
    } else if (path.startsWith('/')) {
      fullPath = '${baseUri.path}$path';
    } else {
      fullPath = '${baseUri.path}/$path';
    }

    return baseUri.replace(
      path: fullPath,
      queryParameters: mergedParams.isEmpty ? null : mergedParams,
    );
  }

  /// Builds headers by merging defaults with request-specific headers.
  ///
  /// Request headers override default headers (last-write-wins).
  Map<String, String> buildHeaders(Map<String, String>? requestHeaders) {
    return <String, String>{
      ...defaultHeaders,
      if (requestHeaders != null) ...requestHeaders,
    };
  }
}
