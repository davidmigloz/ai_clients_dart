import 'package:http/http.dart' as http;

import '../models/metadata/heartbeat_response.dart';
import '../models/metadata/version_response.dart';
import 'base_resource.dart';

/// Resource for health and status endpoints.
///
/// This resource provides methods for checking the health and status
/// of the ChromaDB server.
///
/// Example:
/// ```dart
/// final client = ChromaClient();
///
/// // Check if server is alive
/// final heartbeat = await client.health.heartbeat();
/// print('Server time: ${heartbeat.nanosecondHeartbeat}');
///
/// // Get server version
/// final version = await client.health.version();
/// print('Version: ${version.version}');
/// ```
class HealthResource extends ResourceBase {
  /// Creates a health resource.
  HealthResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Checks if the server is alive.
  ///
  /// Returns the server's current timestamp in nanoseconds.
  ///
  /// Endpoint: `GET /api/v2/heartbeat`
  Future<HeartbeatResponse> heartbeat() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/api/v2/heartbeat');
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return HeartbeatResponse.fromJson(parseJson(response));
  }

  /// Gets the server version.
  ///
  /// Returns version information about the ChromaDB server.
  ///
  /// Endpoint: `GET /api/v2/version`
  Future<VersionResponse> version() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/api/v2/version');
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    // The version endpoint returns a plain string, not JSON
    return VersionResponse(version: response.body.replaceAll('"', ''));
  }

  /// Runs pre-flight checks.
  ///
  /// Verifies that the server is properly configured and ready to accept
  /// requests. Returns a map of check results.
  ///
  /// Endpoint: `GET /api/v2/pre-flight-checks`
  Future<Map<String, dynamic>> preFlightChecks() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/api/v2/pre-flight-checks');
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return parseJson(response);
  }

  /// Performs a comprehensive health check.
  ///
  /// Returns detailed health status including database connectivity,
  /// memory usage, and other system metrics.
  ///
  /// Endpoint: `GET /api/v2/healthcheck`
  Future<Map<String, dynamic>> healthcheck() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/api/v2/healthcheck');
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return parseJson(response);
  }

  /// Resets the database (admin only).
  ///
  /// **WARNING**: This deletes all data in the database. Use with caution.
  ///
  /// This endpoint is typically only available in development mode or
  /// when the server is configured to allow resets.
  ///
  /// Endpoint: `POST /api/v2/reset`
  Future<bool> reset() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/api/v2/reset');
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('POST', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      isIdempotent: true,
    );
    return response.statusCode == 200;
  }
}
