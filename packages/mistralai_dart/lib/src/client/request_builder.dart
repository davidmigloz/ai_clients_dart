import 'config.dart';

/// Builds API request URLs and headers with proper precedence.
///
/// Implements last-write-wins merge per spec:
/// - Headers: Global → Endpoint → Request (highest)
/// - Query Params: Global → Endpoint → Request (highest)
class RequestBuilder {
  /// Configuration.
  final MistralConfig config;

  /// Creates a [RequestBuilder].
  const RequestBuilder({required this.config});

  /// Builds a URL for an API endpoint.
  ///
  /// Merges query parameters in order: Global → Request.
  /// Later values override earlier ones (last-write-wins).
  Uri buildUrl(String path, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('${config.baseUrl}$path');
    final mergedParams = <String, dynamic>{
      ...config.defaultQueryParams,
      ...?queryParams,
    };

    if (mergedParams.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: mergedParams);
  }

  /// Builds headers for a request.
  ///
  /// Merges headers in order: Global → Request.
  /// Later values override earlier ones (last-write-wins).
  Map<String, String> buildHeaders({Map<String, String>? additionalHeaders}) {
    return {...config.defaultHeaders, ...?additionalHeaders};
  }
}
