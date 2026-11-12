import 'package:http/http.dart' as http;

import '../client/buffered_http_attempt.dart';
import '../errors/response_error.dart';
import '../utils/request_id.dart';

/// Sends an already authenticated multipart or binary request without changing
/// its retry behavior, retaining safe metadata when the response is an error.
Future<http.Response> sendResourceRequest(
  http.Client client,
  http.BaseRequest request, {
  required Duration timeout,
}) async {
  final stopwatch = Stopwatch()..start();
  final response = await sendBufferedHttpAttempt(
    send: (abortTrigger) async {
      final streamedResponse = await client.send(
        _abortable(request, abortTrigger),
      );
      stopwatch.stop();
      return streamedResponse;
    },
    timeout: timeout,
    abortTrigger: null,
    correlationId: request.headers['x-request-id'] ?? generateRequestId(),
  );
  if (response.statusCode >= 400) {
    final body = decodeApiErrorResponse(response);
    throw createResourceException(
      response.statusCode,
      body,
      createSafeResponseMetadata(
        statusCode: response.statusCode,
        headers: response.headers,
        latency: stopwatch.elapsed,
        bodyRequestId: parseApiErrorBody(body).requestId,
      ),
    );
  }
  return response;
}

http.BaseRequest _abortable(
  http.BaseRequest request,
  Future<void> abortTrigger,
) {
  final copy = switch (request) {
    http.MultipartRequest() =>
      http.AbortableMultipartRequest(
          request.method,
          request.url,
          abortTrigger: abortTrigger,
        )
        ..fields.addAll(request.fields)
        ..files.addAll(request.files),
    http.Request() => http.AbortableRequest(
      request.method,
      request.url,
      abortTrigger: abortTrigger,
    )..bodyBytes = request.bodyBytes,
    _ => throw ArgumentError('Expected a buffered or multipart HTTP request'),
  };
  return copy
    ..headers.addAll(request.headers)
    ..followRedirects = request.followRedirects
    ..maxRedirects = request.maxRedirects
    ..persistentConnection = request.persistentConnection;
}
