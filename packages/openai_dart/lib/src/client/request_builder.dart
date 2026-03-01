import '../utils/request_id.dart';
import 'config.dart';

/// Builds API request URLs and headers with proper precedence.
///
/// Headers are merged in this order (later values override earlier):
/// 1. `Content-Type: application/json` (for non-multipart requests)
/// 2. [OpenAIConfig.defaultHeaders] (global headers)
/// 3. [AuthProvider.getHeaders] (authentication headers)
/// 4. `OpenAI-Organization` / `OpenAI-Project` / `OpenAI-Version` (from config)
/// 5. `additionalHeaders` (request-specific headers)
///
/// This means request-level headers can override organization/project/version,
/// which can override auth headers, which can override global defaults.
///
/// Note: [buildStreamingHeaders] and [buildBetaHeaders] enforce their
/// required headers (`Accept` and `OpenAI-Beta`) by placing them last,
/// preventing overrides from earlier merge stages.
///
/// ## Example
///
/// ```dart
/// final builder = RequestBuilder(config: config);
///
/// final url = builder.buildUrl('/chat/completions');
/// final headers = builder.buildHeaders();
/// ```
class RequestBuilder {
  /// Creates a [RequestBuilder] with the given configuration.
  const RequestBuilder({required this.config});

  /// The configuration for building requests.
  final OpenAIConfig config;

  /// Builds a URL for an API endpoint.
  ///
  /// The [path] should start with a `/`, e.g., `/chat/completions`.
  /// Optional [queryParams] are merged with any query parameters in the
  /// base URL (request-level params override base-level on key conflicts).
  ///
  /// This correctly handles base URLs with existing query parameters,
  /// such as Azure OpenAI endpoints with `api-version`.
  Uri buildUrl(String path, {Map<String, String>? queryParams}) {
    // Parse baseUrl as a Uri to correctly handle existing paths and query params
    final baseUri = Uri.parse(config.baseUrl);

    // Normalize base path and requested path to avoid double slashes
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final combinedPath = '$basePath$normalizedPath';

    // Merge query params: base URL params + request params (request wins on conflict)
    final mergedQueryParams = <String, String>{
      ...baseUri.queryParameters,
      if (queryParams != null) ...queryParams,
    };

    return baseUri.replace(
      path: combinedPath,
      queryParameters: mergedQueryParams.isEmpty ? null : mergedQueryParams,
    );
  }

  /// Builds a URL for an API endpoint with support for repeated query
  /// parameters.
  ///
  /// This method handles arrays in query parameters using
  /// `queryParametersAll`, which is necessary for OpenAI's API where array
  /// params must be sent as repeated keys (e.g., `?include[]=a&include[]=b`).
  ///
  /// Use this instead of [buildUrl] when you need to pass array-valued query
  /// parameters. Single-value params can be passed directly in
  /// [queryParameters], while repeated params go in [queryParametersAll].
  Uri buildUrlWithQueryAll(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, List<String>>? queryParametersAll,
  }) {
    // Parse baseUrl as a Uri to correctly handle existing paths and query params
    final baseUri = Uri.parse(config.baseUrl);

    // Normalize base path and requested path to avoid double slashes
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final combinedPath = '$basePath$normalizedPath';

    // Merge query params: base URL params + single params + repeated params
    // Convert everything to List<String> format for queryParametersAll
    final mergedQueryParamsAll = <String, List<String>>{
      // Add base URL params
      for (final entry in baseUri.queryParametersAll.entries)
        entry.key: entry.value,
      // Add single-value params (converted to list)
      if (queryParameters != null)
        for (final entry in queryParameters.entries) entry.key: [entry.value],
      // Add repeated params (these override single-value params with same key)
      if (queryParametersAll != null) ...queryParametersAll,
    };

    // Build the URI with queryParametersAll.
    // Note: Dart's Uri constructor accepts Map<String, List<String>> for the
    // queryParameters parameter, treating each list as repeated query
    // parameters (e.g., include[]=a&include[]=b).
    //
    // We preserve all URI components from the base URL:
    // - userInfo: credentials in URL (user:pass@host)
    // - fragment: hash section (#section)
    // - port: explicit port (even standard ports like 80/443 if specified)
    return Uri(
      scheme: baseUri.scheme,
      userInfo: baseUri.userInfo.isEmpty ? null : baseUri.userInfo,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: combinedPath,
      queryParameters: mergedQueryParamsAll.isEmpty
          ? null
          : mergedQueryParamsAll,
      fragment: baseUri.fragment.isEmpty ? null : baseUri.fragment,
    );
  }

  /// Builds headers for a request.
  ///
  /// Merges headers in order: Default → Global → Request.
  /// Later values override earlier ones (last-write-wins).
  ///
  /// Automatically includes:
  /// - `Content-Type: application/json`
  /// - Authentication headers from the [AuthProvider]
  /// - `OpenAI-Organization` if configured
  /// - `OpenAI-Project` if configured
  /// - `OpenAI-Version` if configured
  Map<String, String> buildHeaders({Map<String, String>? additionalHeaders}) {
    return _buildBaseHeaders(
      includeContentType: true,
      additionalHeaders: additionalHeaders,
    );
  }

  /// Builds headers for a multipart form request.
  ///
  /// Similar to [buildHeaders] but omits `Content-Type` since
  /// the http package will set it with the multipart boundary.
  Map<String, String> buildMultipartHeaders({
    Map<String, String>? additionalHeaders,
  }) {
    return _buildBaseHeaders(
      includeContentType: false,
      additionalHeaders: additionalHeaders,
    );
  }

  /// Shared header building logic.
  ///
  /// The [includeContentType] flag controls whether to add
  /// `Content-Type: application/json` (omitted for multipart requests).
  Map<String, String> _buildBaseHeaders({
    required bool includeContentType,
    Map<String, String>? additionalHeaders,
  }) {
    final headers = <String, String>{
      if (includeContentType) 'Content-Type': 'application/json',
      ...config.defaultHeaders,
    };

    // Add auth headers
    if (config.authProvider case final authProvider?) {
      headers.addAll(authProvider.getHeaders());
    }

    // Add organization header if configured
    if (config.organization case final org?) {
      headers['OpenAI-Organization'] = org;
    }

    // Add project header if configured
    if (config.project case final proj?) {
      headers['OpenAI-Project'] = proj;
    }

    // Add API version if configured
    if (config.apiVersion case final version?) {
      headers['OpenAI-Version'] = version;
    }

    // Add request ID for tracing
    headers['X-Request-ID'] = generateRequestId();

    // Add any additional request-specific headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Builds headers for a streaming request.
  ///
  /// Includes all standard headers plus `Accept: text/event-stream`
  /// for Server-Sent Events (SSE) streaming.
  ///
  /// The `Accept` header is always set to `text/event-stream` and cannot
  /// be overridden by [additionalHeaders] to ensure SSE streaming works.
  Map<String, String> buildStreamingHeaders({
    Map<String, String>? additionalHeaders,
  }) {
    return buildHeaders(
      additionalHeaders: {...?additionalHeaders, 'Accept': 'text/event-stream'},
    );
  }

  /// Builds headers for a beta API request.
  ///
  /// Includes the `OpenAI-Beta` header for accessing beta features
  /// like the Assistants API.
  ///
  /// The `OpenAI-Beta` header is set to the specified [betaFeature] and
  /// cannot be overridden by [additionalHeaders] to ensure beta routing works.
  Map<String, String> buildBetaHeaders({
    required String betaFeature,
    Map<String, String>? additionalHeaders,
  }) {
    return buildHeaders(
      additionalHeaders: {...?additionalHeaders, 'OpenAI-Beta': betaFeature},
    );
  }
}
