import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/request_auth.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import '../../errors/response_error.dart';
import '../../utils/path_segment.dart';

/// Shared transport for organization-scoped Admin calls.
final class OrganizationTransport {
  /// Creates an Admin transport backed by the client pipeline.
  const OrganizationTransport({
    required this.requestBuilder,
    required this.interceptorChain,
    required this.ensureNotClosed,
  });

  /// Builds API URLs and headers.
  final RequestBuilder requestBuilder;

  /// Authenticated request pipeline.
  final InterceptorChain interceptorChain;

  /// Checks that the parent client remains usable.
  final void Function()? ensureNotClosed;

  /// Sends an organization-scoped request and decodes its JSON body.
  /// [diagnosticField] identifies an in-band error message to sanitize.
  /// Set [sensitiveResponse] if a successful body contains a new secret.
  Future<T> send<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    String? beta,
    String? requiredBeta,
    String? diagnosticField,
    bool sensitiveResponse = false,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/organizations$path',
      queryParams: query,
    );
    final headers = requestBuilder.buildHeaders(
      includeWorkspace: false,
      additionalHeaders: {'anthropic-beta': ?beta},
    )..remove('anthropic-workspace-id');
    if (requiredBeta != null) {
      final configured = headers['anthropic-beta']?.split(',');
      headers['anthropic-beta'] = {
        for (final value in configured ?? const <String>[])
          if (value.trim().isNotEmpty) value.trim(),
        requiredBeta,
      }.join(',');
    }
    final request = http.Request(method, url)
      ..followRedirects = false
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final credentials = diagnosticField == null ? null : <String>{};
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
      redirectErrorMessage: 'Unexpected redirect from the Admin API',
      onTransportRequest: credentials == null
          ? null
          : (headers) => credentials.addAll(requestCredentialValues(headers)),
    );
    final sentHeaders = response.request?.headers;
    if (credentials != null && sentHeaders != null) {
      credentials.addAll(requestCredentialValues(sentHeaders));
    }
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected a JSON object from the Admin API',
        );
      }
      if (json[diagnosticField] case final String value
          when diagnosticField != null && credentials != null) {
        json[diagnosticField] = redactDiagnosticText(value, credentials);
      }
      return decode(json);
    } on FormatException catch (error, stackTrace) {
      if (sensitiveResponse) {
        Error.throwWithStackTrace(
          const FormatException('Invalid sensitive Admin API response'),
          stackTrace,
        );
      }
      if (credentials == null) rethrow;
      Error.throwWithStackTrace(
        redactApiFormatException(error, credentials),
        stackTrace,
      );
    }
  }
}

/// Escapes one user-supplied path segment before composing an Admin URI.
String organizationIdSegment(String id, String parameter) =>
    encodePathSegment(id, parameter);

/// Produces the before/after-ID pagination filters shared by Admin lists.
Map<String, dynamic> organizationPageQuery(
  String? beforeId,
  String? afterId,
  int? limit,
) => {
  'before_id': ?beforeId,
  'after_id': ?afterId,
  'limit': ?limit?.toString(),
};

/// Produces opaque-cursor paging parameters for Admin lists.
Map<String, dynamic> organizationCursorQuery(String? page, int? limit) => {
  'page': ?page,
  'limit': ?limit?.toString(),
};
