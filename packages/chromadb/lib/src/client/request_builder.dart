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
///   defaultHeaders: {'User-Agent': 'chromadb-dart'},
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
  ///
  /// Merges query parameters in order: base URL → defaults → request.
  /// Later sources override earlier ones by key (last-write-wins; the whole
  /// value list for that key is replaced). Repeated keys carried by the base
  /// URL (e.g. `?k=a&k=b`) are preserved.
  Uri buildUrl(String path, {Map<String, String>? queryParameters}) {
    final baseUri = Uri.parse(baseUrl);

    // Normalize the base path and endpoint path to avoid a double slash when
    // the configured base URL ends with a trailing slash.
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // Merge query params (last-write-wins by key). `queryParametersAll`
    // preserves repeated base-URL keys; `Uri.replace` accepts both `String`
    // and `Iterable<String>` values.
    final mergedParams = <String, dynamic>{
      ...baseUri.queryParametersAll,
      ...defaultQueryParameters,
      ...?queryParameters,
    };

    // `replace` keeps scheme, userInfo, host, port, and fragment from the
    // base URL; only path and query are rebuilt.
    return baseUri.replace(
      path: '$basePath$normalizedPath',
      queryParameters: mergedParams.isEmpty ? null : mergedParams,
    );
  }

  /// Builds headers by merging defaults with request-specific headers.
  ///
  /// Request headers override default headers (last-write-wins).
  Map<String, String> buildHeaders(Map<String, String>? requestHeaders) {
    return <String, String>{...defaultHeaders, ...?requestHeaders};
  }
}
