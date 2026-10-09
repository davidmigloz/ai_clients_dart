import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../utils/speech_redaction.dart';
import 'interceptor.dart';

/// Interceptor that adds authentication headers to requests.
///
/// This interceptor retrieves authentication headers from the configured
/// [AuthProvider] and adds them to every outgoing request.
///
/// Note: Organization and project headers are added in the base headers
/// of the client, not here, so they work regardless of auth mechanism.
///
/// ## Example
///
/// ```dart
/// final interceptor = AuthInterceptor(
///   authProvider: ApiKeyProvider('sk-...'),
/// );
/// ```
class AuthInterceptor implements Interceptor {
  /// Creates an [AuthInterceptor] with the given auth provider.
  const AuthInterceptor({required this.authProvider});

  /// The authentication provider for obtaining credentials.
  final AuthProvider authProvider;

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) {
    // Get auth headers from provider
    final providerHeaders = authProvider.getHeaders();

    // Private resources select their required media headers at the boundary.
    // Keep those request-level values when refreshing provider credentials.
    // Filter before copying the body: a conflicting charset could otherwise
    // change its encoding before a later header correction.
    final authHeaders = isPrivateAudioRequest(context.request)
        ? {
            for (final entry in providerHeaders.entries)
              if (entry.key.toLowerCase() != 'accept' &&
                  entry.key.toLowerCase() != 'content-type' &&
                  (!isSavedAgentRequest(context.request) ||
                      entry.key.toLowerCase() != 'openai-beta'))
                entry.key: entry.value,
          }
        : providerHeaders;

    // Create a new request with auth headers
    final request = _cloneRequestWithHeaders(context.request, authHeaders);

    // Continue with the updated request
    return next(context.copyWith(request: request));
  }

  /// Clones a request and adds additional headers.
  http.BaseRequest _cloneRequestWithHeaders(
    http.BaseRequest original,
    Map<String, String> additionalHeaders,
  ) {
    final http.Request request;

    if (original is http.Request) {
      request = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..headers.addAll(additionalHeaders)
        ..body = original.body
        ..encoding = original.encoding
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;
      // Copying an empty body can synthesize text/plain. A bodyless private
      // operation deliberately selected no Content-Type at its boundary.
      if (isPrivateAudioRequest(original) &&
          !original.headers.containsKey('content-type')) {
        request.headers.remove('content-type');
      }
    } else if (original is http.MultipartRequest) {
      final multipart = http.MultipartRequest(original.method, original.url)
        ..headers.addAll(original.headers)
        ..headers.addAll(additionalHeaders)
        ..fields.addAll(original.fields)
        ..files.addAll(original.files)
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;
      return multipart;
    } else {
      // For other request types, just add headers to the original
      original.headers.addAll(additionalHeaders);
      return original;
    }

    return request;
  }
}
