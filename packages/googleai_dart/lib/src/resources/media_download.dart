import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/interceptor_chain.dart';
import '../errors/exceptions.dart';
import '../utils/redactor.dart';
import 'base_resource.dart';
import 'continuation_abort.dart';

const _diagnosticRedactor = Redactor(
  redactionList: [
    'authorization',
    'key',
    'api_key',
    'api-key',
    'x-goog-api-key',
    'access_token',
    'cookie',
  ],
);

/// Builds a media path segment from a bare ID or a resource name.
String mediaResourceName(
  ResourceBase resource,
  String collection,
  String name,
) {
  final prefix = '$collection/';
  final id = name.startsWith(prefix) ? name.substring(prefix.length) : name;
  if (id.isEmpty || id == '.' || id == '..' || id.contains('/')) {
    throw ArgumentError('Expected an ID or $collection/{id} name.', 'name');
  }
  return '$prefix${resource.encodeResourceId(id, name: 'name')}';
}

/// Downloads an authenticated Developer API media endpoint.
///
/// Redirected transfers use only the signed URL, never the caller's API
/// credentials or configured headers.
Future<Uint8List> downloadDeveloperMedia(
  ResourceBase resource,
  String path, {
  Future<void>? abortTrigger,
}) async {
  resource.ensureNotClosed?.call();
  final abort = ContinuationAbort(
    'Gemini media download',
    resource.config.timeout,
    abortTrigger,
  );
  try {
    await Future<void>.value();
    abort.check();
    var url = resource.requestBuilder.buildUrl(
      path,
      queryParams: const {'alt': 'media'},
    );
    final initial = http.Request('GET', url)
      ..followRedirects = false
      ..headers.addAll(resource.requestBuilder.buildHeaders())
      ..headers['Accept'] = '*/*';
    var response = await abort.race(
      resource.interceptorChain.execute(
        initial,
        abortTrigger: abort.future,
        checkActive: abort.check,
        diagnosticRedactor: _diagnosticRedactor,
        statusOnlyResponseDiagnostics: true,
      ),
    );
    const redirectCodes = {301, 302, 303, 307, 308};
    final transport = InterceptorChain(
      interceptors: const [],
      httpClient: resource.httpClient,
      ensureNotClosed: resource.ensureNotClosed,
    );
    for (
      var redirects = 0;
      redirectCodes.contains(response.statusCode);
      redirects++
    ) {
      abort.check();
      final location = response.headers['location'];
      final reference = location == null || location.isEmpty
          ? null
          : Uri.tryParse(location);
      final target = reference == null ? null : url.resolveUri(reference);
      if (redirects >= 5 ||
          target == null ||
          target.host.isEmpty ||
          target.userInfo.isNotEmpty ||
          target.hasFragment ||
          !(target.isScheme('https') ||
              (url.isScheme('http') && target.isScheme('http')))) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Gemini media download returned an invalid redirect.',
        );
      }
      url = target;
      final redirect = http.Request('GET', url)
        ..followRedirects = false
        ..headers['Accept'] = '*/*';
      response = await abort.race(
        transport.execute(
          redirect,
          abortTrigger: abort.future,
          checkActive: abort.check,
        ),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Gemini media download failed.',
      );
    }
    return response.bodyBytes;
  } on AbortedException catch (error) {
    final failure = abort.resolveFailure(error);
    if (failure is! AbortedException) throw failure;
    throw AbortedException(
      message: 'Gemini media download aborted.',
      correlationId: failure.correlationId,
      timestamp: failure.timestamp,
      stage: failure.stage,
    );
  } on http.ClientException {
    abort.check();
    // A signed transfer error can contain the original session URL.
    throw const ApiException(
      statusCode: 0,
      message: 'Gemini media download failed.',
    );
  } finally {
    abort.close();
  }
}
