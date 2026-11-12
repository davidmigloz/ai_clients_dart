import 'dart:async';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
import '../errors/exceptions.dart';
import '../errors/response_error.dart';

const _usesDartIo = bool.fromEnvironment('dart.library.io');
const _crossOriginHeaders = {
  'authorization',
  'www-authenticate',
  'proxy-authorization',
  'proxy-authenticate',
  'cookie',
  'cookie2',
  'host',
  'x-api-key',
};

/// Sends a request without forwarding credentials to a different origin.
///
/// Browser Fetch already strips Authorization on cross-origin redirects. It
/// can forward x-api-key and does not expose redirect targets, so BrowserClient
/// rejects redirects when a request uses that header. Native redirects are
/// inspected to protect both credential styles on supported Dart versions.
Future<http.StreamedResponse> sendApiRequest(
  http.Client client,
  http.BaseRequest request, {
  required void Function()? ensureNotClosed,
  String? redirectErrorMessage,
}) {
  if (!request.followRedirects && redirectErrorMessage != null) {
    return _sendWithoutRedirect(client, request, redirectErrorMessage);
  }
  final hasApiKey = request.headers['x-api-key']?.isNotEmpty == true;
  final nativeAuthorization =
      _usesDartIo && request.headers['authorization']?.isNotEmpty == true;
  if (!request.followRedirects || !(hasApiKey || nativeAuthorization)) {
    return _sendWithRequest(client, request);
  }
  return _sendGuardedRequest(
    client,
    request,
    sameOriginOnly: hasApiKey,
    ensureNotClosed: ensureNotClosed,
  );
}

// A borrowed client may omit the request in its response. Retain the actual
// outgoing request so downstream diagnostics can filter effective credentials.
Future<http.StreamedResponse> _sendWithRequest(
  http.Client client,
  http.BaseRequest request,
) async {
  if (client is! DeferredCredentialHeaders) {
    validateRequestCredentialHeaders(request.headers);
  }
  final credentials = requestCredentialValues(request.headers)
    ..addAll(requestDiagnosticCredentials(request));
  requestCredentialObserver(request)?.call(credentials);
  final response = await client.send(request);
  return withResponseDiagnosticCredentials(
    response.request != null
        ? response
        : http.StreamedResponse(
            response.stream,
            response.statusCode,
            contentLength: response.contentLength,
            request: request,
            headers: response.headers,
            isRedirect: response.isRedirect,
            persistentConnection: response.persistentConnection,
            reasonPhrase: response.reasonPhrase,
          ),
    credentials,
  );
}

Future<http.StreamedResponse> _sendWithoutRedirect(
  http.Client client,
  http.BaseRequest request,
  String redirectErrorMessage,
) async {
  final credentials = requestCredentialValues(request.headers)
    ..addAll(requestDiagnosticCredentials(request));
  final watch = Stopwatch()..start();
  final response = await _sendWithRequest(client, request);
  if (response.statusCode >= 300 && response.statusCode < 400) {
    _releaseRedirectBody(response);
    throw _redirectException(
      response,
      redirectErrorMessage,
      credentials,
      watch,
    );
  }
  return response;
}

Future<http.StreamedResponse> _sendGuardedRequest(
  http.Client client,
  http.BaseRequest request, {
  required bool sameOriginOnly,
  required void Function()? ensureNotClosed,
}) async {
  var current = request..followRedirects = false;
  final followedTargets = <Uri>{};
  final credentials = requestCredentialValues(request.headers)
    ..addAll(requestDiagnosticCredentials(request));
  final watch = Stopwatch()..start();
  final abort = request is http.Abortable ? request.abortTrigger : null;
  var aborted = false;
  final subscription = abort?.asStream().listen(
    (_) => aborted = true,
    onError: (Object _, StackTrace _) {},
  );
  try {
    for (var redirects = 0; ; redirects++) {
      final response = await _sendWithRequest(client, current);
      final method = _redirectMethod(current.method, response.statusCode);
      if (method == null) {
        return withResponseDiagnosticCredentials(response, credentials);
      }
      _releaseRedirectBody(response);

      if (abort != null) {
        // A deadline or caller abort can complete alongside this response.
        await Future<void>.delayed(Duration.zero);
        if (aborted) throw http.RequestAbortedException(current.url);
      }
      final target = _redirectTarget(current.url, response.headers);
      final crossOrigin = target != null && !_sameOrigin(current.url, target);
      final error = switch (target) {
        null => 'HTTP redirect has no valid location',
        _ when sameOriginOnly && crossOrigin =>
          'Refusing to forward an API key to a different origin',
        _ when redirects >= request.maxRedirects =>
          'HTTP redirect limit reached',
        final Uri redirect when !followedTargets.add(redirect) =>
          'HTTP redirect loop detected',
        _ => null,
      };
      if (error != null) {
        throw _redirectException(response, error, credentials, watch);
      }
      ensureNotClosed?.call();
      current = http.AbortableRequest(method, target!, abortTrigger: abort)
        ..followRedirects = false
        ..persistentConnection = current.persistentConnection
        ..headers.addAll(current.headers)
        ..headers.remove('content-length')
        ..headers.remove('transfer-encoding');
      withRequestCredentialObserver(
        current,
        requestCredentialObserver(request),
      );
      if (crossOrigin) {
        current.headers.removeWhere(
          (name, _) => _crossOriginHeaders.contains(name.toLowerCase()),
        );
      }
    }
  } finally {
    unawaited(subscription?.cancel());
  }
}

void _releaseRedirectBody(http.StreamedResponse response) {
  response.stream
      .listen(null, onError: (Object _, StackTrace _) {})
      .cancel()
      .ignore();
}

ApiException _redirectException(
  http.StreamedResponse response,
  String message,
  Set<String> credentials,
  Stopwatch watch,
) => ApiException(
  statusCode: response.statusCode,
  message: message,
  responseMetadata: createSafeResponseMetadata(
    statusCode: response.statusCode,
    headers: response.headers,
    latency: watch.elapsed,
    credentials: {...credentials, ...responseCredentialValues(response)},
  ),
);

// Keep Dart IO's method handling. These redirect hops carry no body.
String? _redirectMethod(String method, int status) => switch ((
  method.toUpperCase(),
  status,
)) {
  (final verb && ('GET' || 'HEAD'), 301 || 302 || 303 || 307 || 308) => verb,
  ('POST', 303) => 'GET',
  _ => null,
};

Uri? _redirectTarget(Uri current, Map<String, String> headers) {
  for (final MapEntry(key: name, value: location) in headers.entries) {
    if (name.toLowerCase() != 'location' || location.trim().isEmpty) continue;
    final parsed = Uri.tryParse(location.trim());
    if (parsed == null) return null;
    final target = current.resolveUri(parsed);
    if (!(target.isScheme('http') || target.isScheme('https')) ||
        target.host.isEmpty ||
        target.userInfo.isNotEmpty) {
      return null;
    }
    return target;
  }
  return null;
}

bool _sameOrigin(Uri origin, Uri target) =>
    origin.scheme == target.scheme &&
    origin.host == target.host &&
    origin.port == target.port;
