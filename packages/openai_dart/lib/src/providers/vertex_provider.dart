import 'dart:async';

import '../platform/environment.dart';

/// Resolves a Google access token before each Vertex HTTP attempt.
///
/// The application owns expiry, refresh and caching. Return a nonempty printable
/// ASCII bearer token without whitespace. This callback must not block the event
/// loop. A timed-out/aborted result is discarded; the callback itself cannot be
/// forcibly cancelled, so it should bound any credential-network work it starts.
typedef VertexTokenProvider = FutureOr<String> Function();

/// Immutable routing and injected authentication for Vertex Responses.
///
/// Uses the pinned official SDK API-root format. A complete [baseUrl] takes
/// precedence over [project] and [location]. Otherwise both are required.
/// Project/location are routing identifiers, never OpenAI project/org headers.
/// No API key, ambient OpenAI configuration or native Google dependency is used.
/// Only the documented HTTP/SSE Responses lifecycle is supported.
final class VertexProvider {
  /// Creates an explicit, portable Vertex provider.
  factory VertexProvider({
    required VertexTokenProvider tokenProvider,
    String? project,
    String? location,
    String? baseUrl,
  }) {
    var apiRoot = baseUrl;
    if (apiRoot == null) {
      if (project == null ||
          RegExp(
                r'[a-zA-Z0-9_-][a-zA-Z0-9_.:-]*',
              ).matchAsPrefix(project)?.end !=
              project.length) {
        throw ArgumentError('Vertex requires a valid Google project ID.');
      }
      if (location == null ||
          RegExp(r'[a-z0-9-]+').matchAsPrefix(location)?.end !=
              location.length) {
        throw ArgumentError('Vertex requires a valid Google location.');
      }
      final host = location == 'global'
          ? 'aiplatform.googleapis.com'
          : '$location-aiplatform.googleapis.com';
      apiRoot =
          'https://$host/v1/projects/$project/locations/$location/publishers/openai/v1';
    }
    final Uri root;
    try {
      root = Uri.parse(apiRoot);
    } on FormatException {
      throw ArgumentError('Vertex requires a valid HTTP(S) API root.');
    }
    if ((root.scheme != 'http' && root.scheme != 'https') ||
        root.host.isEmpty ||
        root.userInfo.isNotEmpty ||
        root.hasQuery ||
        root.hasFragment) {
      throw ArgumentError(
        'Vertex API root must use HTTP(S), without credentials, query or fragment.',
      );
    }
    final hostname = root.host.toLowerCase().replaceFirst(RegExp(r'\.$'), '');
    if (root.scheme != 'https' &&
        (hostname == 'googleapis.com' ||
            hostname.endsWith('.googleapis.com'))) {
      throw ArgumentError('Google Vertex endpoints require HTTPS.');
    }
    // Resource paths append to this exact root, with one separator.
    final normalized = root.replace(
      path: root.path.replaceFirst(RegExp(r'/+$'), ''),
    );
    return VertexProvider._(normalized, tokenProvider);
  }

  const VertexProvider._(this.root, this.tokenProvider);

  /// Reads only GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_LOCATION on native Dart.
  ///
  /// Token acquisition remains explicitly injected. Environment access is not
  /// available in browsers/Wasm; use the regular explicit constructor there.
  factory VertexProvider.fromEnvironment({
    required VertexTokenProvider tokenProvider,
  }) => VertexProvider(
    project: getEnvironmentVariable('GOOGLE_CLOUD_PROJECT'),
    location: getEnvironmentVariable('GOOGLE_CLOUD_LOCATION'),
    tokenProvider: tokenProvider,
  );

  /// Validated complete API root before `/responses`.
  final Uri root;

  /// Request-local token callback, retained by configuration snapshots.
  final VertexTokenProvider tokenProvider;

  /// String representation of the complete API root.
  String get baseUrl => root.toString();

  @override
  String toString() => 'VertexProvider([configured])';
}

/// A request-local Google token callback failed or returned an invalid token.
///
/// Contains no callback error/cause: credential-library failures may include
/// private keys or token material. This local failure performs no HTTP request
/// and is not treated as an HTTP 401 or automatically retried.
final class VertexAuthenticationException implements Exception {
  /// Creates a sanitized local authentication failure.
  const VertexAuthenticationException();

  @override
  String toString() =>
      'VertexAuthenticationException: Google token acquisition failed; '
      'check the injected token provider and credential expiry.';
}
