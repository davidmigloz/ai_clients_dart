import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../utils/request_id.dart';
import 'base_resource.dart';

/// Mixin providing streaming request capabilities for resources.
///
/// This mixin provides shared infrastructure for streaming HTTP requests,
/// including:
/// - Auth application (bypassing interceptor chain for streaming)
/// - Request ID generation and logging
/// - Error mapping for streaming responses
/// - Stream error logging
/// - Abort trigger monitoring
///
/// ## Why Streaming Bypasses the Interceptor Chain
///
/// The interceptor chain operates on buffered [http.Response]. Streaming
/// requires unbuffered [http.StreamedResponse] access. Resources with
/// streaming must:
/// 1. Apply auth/logging manually to the request
/// 2. Send via [httpClient.send] to get [StreamedResponse]
/// 3. Check status and map errors before consuming stream
///
/// ## Usage
///
/// ```dart
/// class ModelsResource extends ResourceBase with StreamingResource {
///   Stream<GenerateContentResponse> streamGenerateContent(...) async* {
///     var httpRequest = http.Request('POST', url)...;
///     httpRequest = await prepareStreamingRequest(httpRequest);
///     final response = await sendStreamingRequest(httpRequest);
///
///     final lineStream = bytesToLines(response.stream);
///     final jsonStream = parseSSE(lineStream);
///
///     await for (final json in jsonStream) {
///       yield GenerateContentResponse.fromJson(json);
///     }
///   }
/// }
/// ```
mixin StreamingResource on ResourceBase {
  /// Prepares a streaming request by applying auth and logging.
  ///
  /// This applies the same auth and logging that the interceptor chain would
  /// apply, but without buffering the response.
  Future<http.Request> prepareStreamingRequest(http.Request request) async {
    var req = request;

    // Apply auth
    final credentials = config.authProvider != null
        ? await config.authProvider!.getCredentials()
        : null;
    req = _applyAuthToRequestSync(req, credentials);

    // Apply logging
    req = _applyLoggingToRequest(req);

    return req;
  }

  /// Sends a streaming request with error handling.
  ///
  /// Returns the [StreamedResponse] if successful, or throws a
  /// [GoogleAIException] if the response indicates an error.
  Future<http.StreamedResponse> sendStreamingRequest(
    http.Request request,
  ) async {
    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await httpClient.send(request);

      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        throw mapHttpErrorForStreaming(response);
      }
    } catch (e) {
      _logStreamError(
        e,
        request.headers['X-Request-ID'] ?? generateRequestId(),
      );
      rethrow;
    }

    return streamedResponse;
  }

  /// Monitors an abort trigger while streaming.
  ///
  /// Returns a stream that yields items from [source] until [abortTrigger]
  /// completes, at which point it throws [AbortedException] and cancels the
  /// source stream.
  ///
  /// The [requestId] is used for logging and exception context.
  /// The [fromJson] function converts each JSON map to the desired type.
  Stream<T> streamWithAbortMonitoring<T>({
    required Stream<Map<String, dynamic>> source,
    required Future<void> abortTrigger,
    required String requestId,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    late StreamController<T> controller;
    late StreamSubscription<Map<String, dynamic>> subscription;
    var aborted = false;
    var controllerClosed = false;

    controller = StreamController<T>(
      onListen: () {
        // Initialize subscription FIRST (fixes race condition)
        subscription = source.listen(
          (json) {
            if (!aborted && !controllerClosed) {
              controller.add(fromJson(json));
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!aborted && !controllerClosed) {
              controller.addError(error, stackTrace);
            }
          },
          onDone: () {
            if (!aborted && !controllerClosed) {
              controllerClosed = true;
              unawaited(controller.close());
            }
          },
          cancelOnError: true,
        );

        // Then set up abort listener
        unawaited(
          abortTrigger.then((_) async {
            if (!aborted && !controllerClosed) {
              aborted = true;
              // Cancel subscription first
              await subscription.cancel();
              // Log the abortion
              if (config.logLevel.value <= Level.INFO.value) {
                Logger(
                  'GoogleAI.HTTP',
                ).info('REQUEST [$requestId] Aborted by user');
              }
              // Add error to controller
              if (!controllerClosed) {
                controller.addError(
                  AbortedException(
                    message: 'Request aborted by user',
                    correlationId: requestId,
                    timestamp: DateTime.now(),
                    stage: AbortionStage.duringStream,
                  ),
                );
                controllerClosed = true;
                unawaited(controller.close());
              }
            }
          }),
        );
      },
      onCancel: () {
        controllerClosed = true;
        return subscription.cancel();
      },
    );

    return controller.stream;
  }

  /// Applies authentication to a request (mirrors AuthInterceptor logic).
  http.Request _applyAuthToRequestSync(
    http.Request request,
    AuthCredentials? credentials,
  ) {
    if (credentials == null) return request;

    return switch (credentials) {
      ApiKeyCredentials(:final apiKey, :final placement) => _addApiKey(
        request,
        apiKey,
        placement,
      ),
      BearerTokenCredentials(:final token) => _addBearerToken(request, token),
      EphemeralTokenCredentials(:final token) => _addEphemeralToken(
        request,
        token,
      ),
      NoAuthCredentials() => request,
    };
  }

  /// Adds API key to request based on placement strategy.
  http.Request _addApiKey(
    http.Request request,
    String apiKey,
    AuthPlacement placement,
  ) {
    if (placement == AuthPlacement.header) {
      if (!request.headers.containsKey('X-Goog-Api-Key')) {
        return http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..headers['X-Goog-Api-Key'] = apiKey
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding;
      }
    } else {
      final uri = request.url;
      if (!uri.queryParameters.containsKey('key')) {
        final queryParams = Map<String, dynamic>.from(uri.queryParameters);
        queryParams['key'] = apiKey;
        final newUri = uri.replace(queryParameters: queryParams);

        return http.Request(request.method, newUri)
          ..headers.addAll(request.headers)
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding;
      }
    }

    return request;
  }

  /// Adds Bearer token to request headers.
  http.Request _addBearerToken(http.Request request, String bearerToken) {
    if (!request.headers.containsKey('Authorization')) {
      return http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['Authorization'] = 'Bearer $bearerToken'
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;
    }

    return request;
  }

  /// Adds ephemeral token to request as query parameter.
  http.Request _addEphemeralToken(http.Request request, String token) {
    final uri = request.url;
    if (uri.queryParameters.containsKey('access_token')) {
      return request;
    }
    final queryParams = Map<String, dynamic>.from(uri.queryParameters);
    queryParams['access_token'] = token;
    final newUri = uri.replace(queryParameters: queryParams);

    return http.Request(request.method, newUri)
      ..headers.addAll(request.headers)
      ..bodyBytes = request.bodyBytes
      ..encoding = request.encoding;
  }

  /// Applies logging to a request (mirrors LoggingInterceptor logic).
  http.Request _applyLoggingToRequest(http.Request request) {
    if (!request.headers.containsKey('X-Request-ID')) {
      final requestId = generateRequestId();
      final updatedRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['X-Request-ID'] = requestId
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;

      if (config.logLevel.value <= Level.INFO.value) {
        Logger(
          'GoogleAI.HTTP',
        ).info('REQUEST [$requestId] ${request.method} ${request.url}');
      }

      return updatedRequest;
    }

    return request;
  }

  /// Maps HTTP errors for streaming (mirrors ErrorInterceptor logic).
  GoogleAIException mapHttpErrorForStreaming(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    var message = 'HTTP $statusCode error';
    final details = <Object>[];

    try {
      final errorDetails = jsonDecode(body);
      if (errorDetails is Map<String, dynamic>) {
        final error = errorDetails['error'] as Map<String, dynamic>?;
        message = error?['message']?.toString() ?? message;
        if (error?['details'] != null) {
          final errorDetailsList = error!['details'];
          if (errorDetailsList is List) {
            details.addAll(errorDetailsList.cast<Object>());
          }
        }
      }
    } catch (_) {
      if (body.length < 200 && body.isNotEmpty) {
        message = body;
      }
    }

    if (statusCode == 429) {
      DateTime? retryAfter;
      final retryHeader = response.headers['retry-after'];
      if (retryHeader != null) {
        final seconds = int.tryParse(retryHeader);
        if (seconds != null) {
          retryAfter = DateTime.now().add(Duration(seconds: seconds));
        }
      }

      return RateLimitException(
        code: statusCode,
        message: message,
        details: details,
        retryAfter: retryAfter,
      );
    }

    return ApiException(code: statusCode, message: message, details: details);
  }

  /// Logs streaming errors.
  void _logStreamError(Object error, String requestId) {
    if (config.logLevel.value <= Level.SEVERE.value) {
      Logger('GoogleAI.HTTP').severe('STREAM ERROR [$requestId] $error', error);
    }
  }
}
