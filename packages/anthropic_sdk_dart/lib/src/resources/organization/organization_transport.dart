import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';

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
  Future<T> send<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    String? beta,
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
    final request = http.Request(method, url)
      ..followRedirects = false
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object from the Admin API');
    }
    return decode(json);
  }
}

/// Escapes one user-supplied path segment before composing an Admin URI.
String organizationIdSegment(String id, String parameter) {
  if (id.isEmpty || id == '.' || id == '..') {
    throw ArgumentError.value(id, parameter, 'Expected a non-empty identifier');
  }
  return Uri.encodeComponent(id);
}

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
