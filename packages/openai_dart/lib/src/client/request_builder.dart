import 'config.dart';

/// Builds API request URLs and headers with proper precedence.
///
/// This class implements last-write-wins merge semantics for headers:
/// - Headers: Default → Global → Request (later values override)
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
  /// Optional [queryParams] are appended to the URL.
  Uri buildUrl(String path, {Map<String, String>? queryParams}) {
    // Normalize baseUrl and path to avoid double slashes
    final baseUrl = config.baseUrl.endsWith('/')
        ? config.baseUrl.substring(0, config.baseUrl.length - 1)
        : config.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    final uri = Uri.parse('$baseUrl$normalizedPath');

    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: queryParams);
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
