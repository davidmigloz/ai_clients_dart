import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import 'interceptor.dart';

/// Interceptor that adds authentication headers to requests.
///
/// This interceptor calls the [AuthProvider] before each request to get
/// fresh credentials, allowing for dynamic credential refresh if needed.
///
/// Supported credential types:
/// - [NoAuthCredentials]: No header added
/// - [ApiKeyCredentials]: `x-chroma-token: <api-key>`
/// - [BearerTokenCredentials]: `Authorization: Bearer <token>`
class AuthInterceptor implements Interceptor {
  /// The authentication provider to use.
  final AuthProvider authProvider;

  /// Creates an auth interceptor with the given [authProvider].
  const AuthInterceptor({required this.authProvider});

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final credentials = await authProvider.getCredentials();

    switch (credentials) {
      case NoAuthCredentials():
        // No auth header needed
        break;
      case ApiKeyCredentials(:final apiKey):
        context.headers['x-chroma-token'] = apiKey;
      case BearerTokenCredentials(:final token):
        context.headers['Authorization'] = 'Bearer $token';
    }

    return next(context);
  }
}
