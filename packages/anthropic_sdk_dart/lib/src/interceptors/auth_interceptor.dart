import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../auth/request_auth.dart';
import 'interceptor.dart';

/// Interceptor that adds authentication credentials to requests.
///
/// Supports API keys and OAuth bearer credentials. Explicit authentication
/// headers take precedence.
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
    final headers = await resolveCredentialHeaders(
      context.request.headers,
      authProvider,
    );
    if (headers.isEmpty) return next(context);
    final request = _copyRequest(context.request)..headers.addAll(headers);
    return next(context.copyWith(request: request));
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
