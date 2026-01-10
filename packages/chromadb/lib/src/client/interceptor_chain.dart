import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../interceptors/interceptor.dart';
import 'request_builder.dart';

/// A chain of interceptors that process requests before they are sent.
///
/// The chain builds a pipeline where each interceptor can:
/// - Modify the request context (headers, query params, etc.)
/// - Short-circuit the chain by returning a response directly
/// - Process the response before returning it
///
/// Example:
/// ```dart
/// final chain = InterceptorChain(
///   interceptors: [AuthInterceptor(), LoggingInterceptor()],
///   httpClient: http.Client(),
///   requestBuilder: RequestBuilder(baseUrl: 'http://localhost:8000'),
/// );
///
/// final response = await chain.send(context);
/// ```
class InterceptorChain {
  final List<Interceptor> _interceptors;
  final http.Client _httpClient;
  final RequestBuilder _requestBuilder;

  /// A trigger that can be used to abort in-flight requests.
  ///
  /// When triggered, any pending requests will throw an [AbortedException].
  Completer<void>? abortTrigger;

  /// Creates an interceptor chain.
  InterceptorChain({
    required List<Interceptor> interceptors,
    required http.Client httpClient,
    required RequestBuilder requestBuilder,
  }) : _interceptors = interceptors,
       _httpClient = httpClient,
       _requestBuilder = requestBuilder;

  /// Sends a request through the interceptor chain.
  ///
  /// The request passes through each interceptor in order, then the final
  /// HTTP request is made. Responses pass back through the interceptors
  /// in reverse order.
  Future<http.Response> send(RequestContext context) {
    return _buildChain(0)(context);
  }

  /// Builds the interceptor chain recursively.
  InterceptorNext _buildChain(int index) {
    if (index >= _interceptors.length) {
      // End of chain - make the actual HTTP request
      return _makeRequest;
    }

    final interceptor = _interceptors[index];
    final next = _buildChain(index + 1);

    return (context) => interceptor.intercept(context, next);
  }

  /// Makes the actual HTTP request.
  Future<http.Response> _makeRequest(RequestContext context) async {
    final url = _requestBuilder.buildUrl(
      context.path,
      queryParameters: context.queryParameters,
    );

    final headers = _requestBuilder.buildHeaders(context.headers);

    final request = http.Request(context.method, url)..headers.addAll(headers);

    final body = context.body;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
        request.headers['Content-Type'] = 'application/json';
      }
    }

    // Wrap in abortable request if we have a trigger
    final trigger = abortTrigger;
    if (trigger != null) {
      return _AbortableRequestWrapper(
        httpClient: _httpClient,
        abortTrigger: trigger,
      ).send(request);
    }

    final streamedResponse = await _httpClient.send(request);
    return http.Response.fromStream(streamedResponse);
  }
}

/// Wrapper that makes HTTP requests abortable.
class _AbortableRequestWrapper {
  final http.Client _httpClient;
  final Completer<void> _abortTrigger;

  _AbortableRequestWrapper({
    required http.Client httpClient,
    required Completer<void> abortTrigger,
  }) : _httpClient = httpClient,
       _abortTrigger = abortTrigger;

  Future<http.Response> send(http.Request request) {
    final responseCompleter = Completer<http.Response>();

    // Start the actual request
    unawaited(
      _httpClient
          .send(request)
          .then((streamedResponse) async {
            if (!responseCompleter.isCompleted) {
              final response = await http.Response.fromStream(streamedResponse);
              responseCompleter.complete(response);
            }
          })
          .catchError((Object error) {
            if (!responseCompleter.isCompleted) {
              responseCompleter.completeError(error);
            }
          }),
    );

    // Race against abort trigger
    unawaited(
      _abortTrigger.future.then((_) {
        if (!responseCompleter.isCompleted) {
          responseCompleter.completeError(
            AbortedException(message: 'Request was aborted'),
          );
        }
      }),
    );

    return responseCompleter.future;
  }
}
