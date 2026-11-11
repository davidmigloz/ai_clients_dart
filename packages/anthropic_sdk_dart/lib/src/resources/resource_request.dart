import 'package:http/http.dart' as http;

import '../errors/response_error.dart';

/// Sends an already authenticated multipart or binary request without changing
/// its retry behavior, retaining safe metadata when the response is an error.
Future<http.Response> sendResourceRequest(
  http.Client client,
  http.BaseRequest request,
) async {
  final stopwatch = Stopwatch()..start();
  final streamedResponse = await client.send(request);
  stopwatch.stop();
  final response = await http.Response.fromStream(streamedResponse);
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
