import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import 'interceptor.dart';

/// Interceptor that adds authentication credentials to requests.
///
/// Adds Authorization for bearer auth or x-api-key for dashboard auth.
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
    final request = _cloneRequest(
      context.request,
      credentials,
      authInApiKeyHeader: context.authInApiKeyHeader,
    );

    return next(context.copyWith(request: request));
  }

  /// Clones a request and adds authentication headers/params.
  http.BaseRequest _cloneRequest(
    http.BaseRequest original,
    AuthCredentials credentials, {
    required bool authInApiKeyHeader,
  }) {
    switch (credentials) {
      case BearerTokenCredentials(:final token):
        final header = authInApiKeyHeader ? 'x-api-key' : 'Authorization';
        if (original.headers.containsKey(header)) return original;
        return _copyRequest(original)
          ..headers[header] = authInApiKeyHeader ? token : 'Bearer $token';

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
