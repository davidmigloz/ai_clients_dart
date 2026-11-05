import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/account/_account_helpers.dart';
import '../models/account/usage_response.dart';
import '../models/account/usage_selectors.dart';
import 'base_resource.dart';

/// Read-only cloud inference, web search, and web fetch usage reporting.
///
/// Uses the configured base URL. The local Ollama server proxies requests with
/// its signed-in account; direct `https://ollama.com` requests require bearer
/// authentication. Caller credentials do not select the account reported by
/// the local server. Recorded usage may take time to appear.
class UsageResource extends ResourceBase {
  /// Creates a usage resource using the client's shared transport.
  UsageResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets usage totals and chronological UTC buckets.
  ///
  /// Unset selectors are omitted, preserving service defaults of seven days
  /// and the authenticated user's usage. Team scope requires a team admin.
  /// Bucket granularity follows the range automatically; custom date ranges
  /// and grouping by API key or team member are not supported.
  Future<UsageResponse> get({
    UsageRange? range,
    UsageScope? scope,
    UsageGroupBy? groupBy,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (range == UsageRange.unknown) {
      throw ArgumentError.value(range, 'range', 'Unknown usage range');
    }
    if (scope == UsageScope.unknown) {
      throw ArgumentError.value(scope, 'scope', 'Unknown usage scope');
    }
    if (groupBy == UsageGroupBy.unknown) {
      throw ArgumentError.value(groupBy, 'groupBy', 'Unknown usage grouping');
    }
    final request = http.Request(
      'GET',
      requestBuilder.buildUrl(
        '/api/usage',
        queryParams: {
          if (range != null) 'range': range.toJson(),
          if (scope != null) 'scope': scope.toJson(),
          if (groupBy != null) 'group_by': groupBy.toJson(),
        },
      ),
    )..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return UsageResponse.fromJson(
      accountObject(jsonDecode(response.body), 'UsageResponse'),
    );
  }
}
