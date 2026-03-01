import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import 'base_resource.dart';

/// Mixin providing streaming HTTP request capabilities.
///
/// Provides methods for preparing and sending streaming requests
/// that bypass the interceptor chain for unbuffered response handling.
mixin StreamingResource on ResourceBase {
  /// Prepares a streaming request by applying authentication.
  Future<http.Request> prepareStreamingRequest(http.Request request) async {
    await _applyAuthentication(request);
    return request;
  }

  /// Sends a streaming request and returns the streamed response.
  ///
  /// Throws appropriate exceptions for HTTP error responses.
  Future<http.StreamedResponse> sendStreamingRequest(
    http.Request request,
  ) async {
    final streamedResponse = await httpClient.send(request);
    if (streamedResponse.statusCode >= 400) {
      final body = await streamedResponse.stream.bytesToString();
      throw mapHttpErrorForStreaming(streamedResponse.statusCode, body);
    }
    return streamedResponse;
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = config.authProvider;
    if (authProvider == null) return;
    final credentials = await authProvider.getCredentials();
    switch (credentials) {
      case BearerTokenCredentials(:final token):
        if (!request.headers.containsKey('authorization') &&
            !request.headers.containsKey('Authorization')) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      case NoAuthCredentials():
        break;
    }
  }

  /// Maps an HTTP error status code to the appropriate exception.
  OpenResponsesException mapHttpErrorForStreaming(int statusCode, String body) {
    final message = _parseErrorMessage(body);
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          fieldErrors: _parseFieldErrors(body),
        );
      case 401:
        return AuthenticationException(message: message);
      case 429:
        return RateLimitException(statusCode: statusCode, message: message);
      default:
        return ApiException(statusCode: statusCode, message: message);
    }
  }

  String _parseErrorMessage(String body) {
    if (body.isEmpty) return 'Unknown error';
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          return error['message'] as String? ?? 'Unknown error';
        }
        return json['message'] as String? ?? body;
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  Map<String, List<String>> _parseFieldErrors(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          final param = error['param'] as String?;
          final message = error['message'] as String?;
          if (param != null && message != null) {
            return {
              param: [message],
            };
          }
        }
      }
    } catch (_) {}
    return {};
  }
}
