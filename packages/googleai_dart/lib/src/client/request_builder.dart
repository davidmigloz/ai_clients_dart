import 'config.dart';
import 'endpoint_config.dart';

/// Builds API request URLs and headers with proper precedence.
///
/// Implements last-write-wins merge per spec:
/// - Headers: Global → Endpoint → Request (highest)
///   Note: Auth headers are added by AuthInterceptor ONLY if not present,
///   ensuring request-level headers always win.
/// - Query Params: Global → Endpoint → Request (highest)
///   Note: Auth query params (e.g., 'key') are added by AuthInterceptor
///   ONLY if not present, ensuring request-level params always win.
class RequestBuilder {
  /// Configuration.
  final GoogleAIConfig config;

  /// Creates a [RequestBuilder].
  const RequestBuilder({required this.config});

  /// Builds a URL for an API endpoint.
  ///
  /// Merges query parameters in order: base URL → Global → Endpoint → Request.
  /// Later sources override earlier ones by key (last-write-wins; the whole
  /// value list for that key is replaced). Repeated keys carried by the base
  /// URL (e.g. `?k=a&k=b`) are preserved.
  ///
  /// Transforms the path based on the API mode and version.
  /// Use the `{version}` placeholder in paths to insert [apiVersion] or the
  /// configured version.
  /// Set [vertexProjectScoped] for endpoints such as Vertex Interactions,
  /// which use a project and location without a publisher.
  /// Set [vertexPathIncludesProject] when the Vertex resource path already
  /// contains its project and location.
  /// - For Google AI: `/{version}/models/{model}:generateContent`
  /// - For Vertex AI: `/{version}/projects/{projectId}/locations/{location}/publishers/google/models/{model}:generateContent`
  Uri buildUrl(
    String path, {
    ApiVersion? apiVersion,
    bool vertexProjectScoped = false,
    bool vertexPathIncludesProject = false,
    EndpointConfig? endpointConfig,
    Map<String, dynamic>? queryParams,
  }) {
    final baseUri = Uri.parse(config.baseUrl);
    final combinedPath = _joinPaths(
      baseUri.path,
      _transformPath(
        path,
        apiVersion ?? config.apiVersion,
        vertexProjectScoped: vertexProjectScoped,
        vertexPathIncludesProject: vertexPathIncludesProject,
      ),
    );
    final mergedParams = <String, dynamic>{
      ...baseUri.queryParametersAll,
      ...config.defaultQueryParams,
      ...?endpointConfig?.queryParams,
      ...?queryParams,
    };

    // `replace` keeps scheme, userInfo, host, port, and fragment from the
    // base URL; only path and query are rebuilt.
    return baseUri.replace(
      path: combinedPath,
      queryParameters: mergedParams.isEmpty ? null : mergedParams,
    );
  }

  /// Builds a URL for resumable-upload endpoints (`/upload/{version}/...`).
  ///
  /// Upload endpoints sit outside the standard versioned API surface and are
  /// Google-AI-only, so Vertex path injection does not apply. Replaces the
  /// `{version}` placeholder and merges query params in order:
  /// base URL → Global → [queryParams] (last-write-wins by key).
  Uri buildUploadUrl(String path, {Map<String, String>? queryParams}) {
    final baseUri = Uri.parse(config.baseUrl);
    final transformedPath = path.replaceFirst(
      '{version}',
      config.apiVersion.value,
    );
    final combinedPath = _joinPaths(baseUri.path, transformedPath);
    final mergedParams = <String, dynamic>{
      ...baseUri.queryParametersAll,
      ...config.defaultQueryParams,
      ...?queryParams,
    };

    return baseUri.replace(
      path: combinedPath,
      queryParameters: mergedParams.isEmpty ? null : mergedParams,
    );
  }

  /// Joins the base URL path and an endpoint path, avoiding a double slash
  /// when the base URL has a trailing slash and preserving any base sub-path.
  static String _joinPaths(String basePath, String endpointPath) {
    final trimmedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final normalized = endpointPath.startsWith('/')
        ? endpointPath
        : '/$endpointPath';
    return '$trimmedBase$normalized';
  }

  /// Transforms the path based on API mode and version.
  ///
  /// Replaces `{version}` placeholder with the configured version,
  /// and for Vertex AI, injects project/location path segments.
  String _transformPath(
    String path,
    ApiVersion apiVersion, {
    required bool vertexProjectScoped,
    required bool vertexPathIncludesProject,
  }) {
    // Replace {version} placeholder with configured version
    var transformedPath = path.replaceFirst('{version}', apiVersion.value);

    // For Vertex AI, transform the path to include project and location
    if (config.apiMode == ApiMode.vertexAI && !vertexPathIncludesProject) {
      // Pattern: /{version}/models/{model}:action
      // Becomes: /{version}/projects/{projectId}/locations/{location}/publishers/google/models/{model}:action
      final versionPattern = '/${apiVersion.value}/';

      if (transformedPath.startsWith(versionPattern)) {
        final afterVersion = transformedPath.substring(versionPattern.length);
        final projectId = config.projectId;
        final location = config.location;
        if (vertexProjectScoped) {
          // Official SDKs omit the scope for projectless Vertex express mode.
          if (projectId == null && location == null) return transformedPath;
          if (projectId == null || location == null) {
            throw StateError(
              'Vertex Interactions requires both projectId and location for '
              'project-scoped requests.',
            );
          }
          return '$versionPattern'
              'projects/${Uri.encodeComponent(projectId)}/'
              'locations/${Uri.encodeComponent(location)}/'
              '$afterVersion';
        }

        // Insert project/location path
        transformedPath =
            '$versionPattern'
            'projects/$projectId/'
            'locations/$location/'
            'publishers/google/$afterVersion';
      }
    }

    return transformedPath;
  }

  /// Builds headers for a request.
  ///
  /// Merges headers in order: Global → Endpoint → Request.
  /// Later values override earlier ones (last-write-wins).
  /// Note: Auth interceptor runs separately and adds auth headers.
  Map<String, String> buildHeaders({
    EndpointConfig? endpointConfig,
    Map<String, String>? additionalHeaders,
  }) {
    return {
      ...config.defaultHeaders,
      ...?endpointConfig?.headers,
      ...?additionalHeaders,
    };
  }
}
