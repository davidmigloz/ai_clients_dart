import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/get_log_field_options.dart';
import '../../models/observability/get_log_fields.dart';
import '../../models/observability/get_logs.dart';
import '../../models/observability/logs_request.dart';
import '../base_resource.dart';

/// Resource for observability log operations (beta).
///
/// Logs are the structured log records emitted during agent and workflow
/// runs. This resource lets you search logs and discover the filterable
/// fields available for log queries.
///
/// Example usage:
/// ```dart
/// // Search logs
/// final logs = await client.observability.logs.search(
///   request: const LogsRequest(searchExpression: 'severity_text = "ERROR"'),
/// );
///
/// // List available fields
/// final fields = await client.observability.logs.getFields();
/// ```
class LogsResource extends ResourceBase {
  /// Creates a [LogsResource].
  LogsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Searches for logs.
  ///
  /// - [from]/[to] bound the time range (ISO 8601 / RFC 3339).
  /// - [pageSize] limits the number of results per page.
  /// - [cursor] continues a previous page.
  Future<GetLogs> search({
    LogsRequest? request,
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (cursor != null) queryParams['cursor'] = cursor;

    final url = requestBuilder.buildUrl(
      '/v1/observability/logs/search',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode((request ?? const LogsRequest()).toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetLogs.fromJson(responseBody);
  }

  /// Lists the available log fields.
  Future<GetLogFields> getFields() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/logs/fields');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetLogFields.fromJson(responseBody);
  }

  /// Fetches the available options for a specific log field.
  ///
  /// - [from]/[to] bound the time range used to compute the options.
  Future<GetLogFieldOptions> fetchFieldOptions({
    required String fieldName,
    String? from,
    String? to,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    final url = requestBuilder.buildUrl(
      '/v1/observability/logs/fields/$fieldName/options',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetLogFieldOptions.fromJson(responseBody);
  }
}
