import 'config.dart';

/// Builds API request URLs and headers with proper precedence.
///
/// Implements last-write-wins merge per spec:
/// - Headers: Global → Endpoint → Request (highest)
/// - Query Params: Global → Endpoint → Request (highest)
class RequestBuilder {
  /// Configuration.
  final OpenResponsesConfig config;

  /// Creates a [RequestBuilder].
  const RequestBuilder({required this.config});

  /// Builds a URL for an API endpoint.
  ///
  /// The [path] is a URL path (e.g. `/responses`); pass query parameters via
  /// [queryParams] rather than embedding them in [path]. Values may be a
  /// `String` or an `Iterable<String>` (rendered as repeated keys, e.g.
  /// `?include=a&include=b`).
  ///
  /// Merges query parameters in order: base URL → config defaults → request.
  /// Later sources override earlier ones by key (last-write-wins; the whole
  /// value list for that key is replaced). Repeated keys carried by the base
  /// URL (e.g. `?k=a&k=b`) are preserved.
  Uri buildUrl(String path, {Map<String, dynamic>? queryParams}) {
    // Parse the base URL so existing path/query components are handled
    // correctly (e.g. the default `/v1` sub-path or an `?api-version=` param).
    final baseUri = Uri.parse(config.baseUrl);

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
      ...config.defaultQueryParams,
      ...?queryParams,
    };

    // `replace` keeps scheme, userInfo, host, port, and fragment from the
    // base URL; only path and query are rebuilt.
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
  /// - `content-type: application/json`
  Map<String, String> buildHeaders({Map<String, String>? additionalHeaders}) {
    return {
      'content-type': 'application/json',
      ...config.defaultHeaders,
      ...?additionalHeaders,
    };
  }
}
