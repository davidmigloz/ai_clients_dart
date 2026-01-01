import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import 'interceptor.dart';

/// Interceptor that adds authentication credentials to requests.
///
/// For Bearer token auth, adds the Authorization header.
/// Auth headers are only added if not already present (respects request-level override).
class AuthInterceptor implements Interceptor {
  /// Authentication provider.
  final AuthProvider authProvider;

  /// Creates an [AuthInterceptor].
  const AuthInterceptor({required this.authProvider});

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final credentials = await authProvider.getCredentials();

    // Clone the request to add auth headers
    final request = _cloneRequest(context.request, credentials);

    return next(context.copyWith(request: request));
  }

  /// Clones a request and adds authentication headers/params.
  http.BaseRequest _cloneRequest(
    http.BaseRequest original,
    AuthCredentials credentials,
  ) {
    switch (credentials) {
      case BearerTokenCredentials(:final token):
        // Only add Authorization header if not already set
        if (!original.headers.containsKey('Authorization')) {
          final newRequest = _copyRequest(original);
          newRequest.headers['Authorization'] = 'Bearer $token';
          return newRequest;
        }
        return original;

      case NoAuthCredentials():
        // No authentication needed
        return original;
    }
  }

  /// Creates a copy of a request.
  http.BaseRequest _copyRequest(http.BaseRequest original) {
    if (original is http.Request) {
      final copy = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;

      if (original.body.isNotEmpty) {
        copy.body = original.body;
      }

      return copy;
    }

    // For other request types, just return the original
    return original;
  }
}
