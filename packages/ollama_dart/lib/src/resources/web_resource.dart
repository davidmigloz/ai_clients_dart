import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/web/web_fetch_request.dart';
import '../models/web/web_fetch_response.dart';
import '../models/web/web_search_request.dart';
import '../models/web/web_search_response.dart';
import 'base_resource.dart';

/// Hosted web search and page fetching.
///
/// Uses the client's configured base URL. Configure `https://ollama.com` and
/// bearer authentication for the hosted API, or your own compatible proxy.
/// The default local Ollama server does not expose these stable endpoints.
class WebResource extends ResourceBase {
  /// Creates a [WebResource].
  WebResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Searches the web for [request]'s query.
  ///
  /// Omitting `maxResults` leaves the server default (currently five results).
  /// The hosted API supports at most ten results. Validation remains server-side.
  Future<WebSearchResponse> search({
    required WebSearchRequest request,
    Future<void>? abortTrigger,
  }) async {
    final response = await _post(
      '/api/web_search',
      request.toJson(),
      abortTrigger,
    );
    return WebSearchResponse.fromJson(response);
  }

  /// Fetches one page's title, content, and links.
  ///
  /// The hosted API also accepts scheme-less URL strings, such as `ollama.com`.
  Future<WebFetchResponse> fetch({
    required WebFetchRequest request,
    Future<void>? abortTrigger,
  }) async {
    final response = await _post(
      '/api/web_fetch',
      request.toJson(),
      abortTrigger,
    );
    return WebFetchResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
    Future<void>? abortTrigger,
  ) async {
    final request = http.Request('POST', requestBuilder.buildUrl(path))
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        ),
      )
      ..body = jsonEncode(body);
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
