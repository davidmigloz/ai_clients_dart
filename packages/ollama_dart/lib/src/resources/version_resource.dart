import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/metadata/version_response.dart';
import 'base_resource.dart';

/// Resource for the Version API.
///
/// Provides Ollama server version information.
class VersionResource extends ResourceBase {
  /// Creates a [VersionResource].
  VersionResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Gets the Ollama server version.
  ///
  /// Returns a [VersionResponse] containing the version string.
  Future<VersionResponse> get() async {
    final url = requestBuilder.buildUrl('/api/version');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return VersionResponse.fromJson(responseBody);
  }
}
