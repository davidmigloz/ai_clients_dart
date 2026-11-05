import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/account/_account_helpers.dart';
import '../models/account/balance_response.dart';
import 'base_resource.dart';

/// Read-only reporting of included and purchased account balances.
///
/// Uses the configured base URL. The local Ollama server proxies requests with
/// its signed-in account; direct `https://ollama.com` requests require bearer
/// authentication. Caller credentials do not select the account reported by
/// the local server. Team members share the team's balances.
class BalanceResource extends ResourceBase {
  /// Creates a balance resource using the client's shared transport.
  BalanceResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets remaining included and purchased credits or legacy plan limits.
  ///
  /// This endpoint has no query parameters. [abortTrigger] cancels the request
  /// through the normal transport. The service rate limit is shared per user.
  Future<BalanceResponse> get({Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final request = http.Request('GET', requestBuilder.buildUrl('/api/balance'))
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return BalanceResponse.fromJson(
      accountObject(jsonDecode(response.body), 'BalanceResponse'),
    );
  }
}
