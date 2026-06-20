import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/get_span_evaluation_field_options.dart';
import '../../models/observability/get_span_evaluation_fields.dart';
import '../../models/observability/get_span_evaluations.dart';
import '../../models/observability/get_span_field_options.dart';
import '../../models/observability/get_span_fields.dart';
import '../../models/observability/get_spans.dart';
import '../../models/observability/span_evaluations_request.dart';
import '../../models/observability/spans_request.dart';
import '../base_resource.dart';

/// Resource for observability span operations (beta).
///
/// Spans are the individual operations that make up a trace. This resource
/// lets you search spans and their evaluations, and discover the filterable
/// fields available for span and span-evaluation queries.
///
/// Example usage:
/// ```dart
/// // Search spans
/// final spans = await client.observability.spans.search(
///   request: const SpansRequest(searchExpression: 'span_kind = "llm"'),
/// );
///
/// // Search span evaluations
/// final evals = await client.observability.spans.searchEvaluations(
///   request: const SpanEvaluationsRequest(),
/// );
/// ```
class SpansResource extends ResourceBase {
  /// Creates a [SpansResource].
  SpansResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Searches for spans.
  ///
  /// - [from]/[to] bound the time range (ISO 8601 / RFC 3339).
  /// - [pageSize] limits the number of results per page.
  /// - [cursor] continues a previous page.
  Future<GetSpans> search({
    SpansRequest? request,
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) {
    return _searchSpans(
      '/v1/observability/spans/search',
      (request ?? const SpansRequest()).toJson(),
      from: from,
      to: to,
      pageSize: pageSize,
      cursor: cursor,
    );
  }

  /// Searches for span evaluations.
  ///
  /// - [from]/[to] bound the time range (ISO 8601 / RFC 3339).
  /// - [pageSize] limits the number of results per page.
  /// - [cursor] continues a previous page.
  Future<GetSpanEvaluations> searchEvaluations({
    SpanEvaluationsRequest? request,
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) {
    return _searchEvaluations(
      '/v1/observability/spans/evaluations/search',
      (request ?? const SpanEvaluationsRequest()).toJson(),
      from: from,
      to: to,
      pageSize: pageSize,
      cursor: cursor,
    );
  }

  /// Searches for the latest span evaluations.
  ///
  /// Like [searchEvaluations] but returns only the most recent evaluation per
  /// span.
  ///
  /// - [from]/[to] bound the time range (ISO 8601 / RFC 3339).
  /// - [pageSize] limits the number of results per page.
  /// - [cursor] continues a previous page.
  Future<GetSpanEvaluations> searchLatestEvaluations({
    SpanEvaluationsRequest? request,
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) {
    return _searchEvaluations(
      '/v1/observability/spans/evaluations/search/latest',
      (request ?? const SpanEvaluationsRequest()).toJson(),
      from: from,
      to: to,
      pageSize: pageSize,
      cursor: cursor,
    );
  }

  /// Lists the available span fields.
  Future<GetSpanFields> getFields() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/spans/fields');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpanFields.fromJson(responseBody);
  }

  /// Lists the available span-evaluation fields.
  Future<GetSpanEvaluationFields> getEvaluationFields() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/spans/evaluations/fields',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpanEvaluationFields.fromJson(responseBody);
  }

  /// Fetches the available options for a specific span field.
  ///
  /// - [from]/[to] bound the time range used to compute the options.
  Future<GetSpanFieldOptions> fetchFieldOptions({
    required String fieldName,
    String? from,
    String? to,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    final url = requestBuilder.buildUrl(
      '/v1/observability/spans/fields/$fieldName/options',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpanFieldOptions.fromJson(responseBody);
  }

  /// Fetches the available options for a specific span-evaluation field.
  ///
  /// - [from]/[to] bound the time range used to compute the options.
  Future<GetSpanEvaluationFieldOptions> fetchEvaluationFieldOptions({
    required String fieldName,
    String? from,
    String? to,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    final url = requestBuilder.buildUrl(
      '/v1/observability/spans/evaluations/fields/$fieldName/options',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpanEvaluationFieldOptions.fromJson(responseBody);
  }

  Future<GetSpans> _searchSpans(
    String path,
    Map<String, dynamic> body, {
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      path,
      queryParams: _pageQuery(from, to, pageSize, cursor),
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpans.fromJson(responseBody);
  }

  Future<GetSpanEvaluations> _searchEvaluations(
    String path,
    Map<String, dynamic> body, {
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      path,
      queryParams: _pageQuery(from, to, pageSize, cursor),
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpanEvaluations.fromJson(responseBody);
  }

  Map<String, String> _pageQuery(
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  ) {
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (cursor != null) queryParams['cursor'] = cursor;
    return queryParams;
  }
}
