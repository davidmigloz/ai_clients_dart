import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/realtime/realtime_client_session.dart';
import '../base_resource.dart';

/// The client-session token endpoints for realtime audio.
final class RealtimeResource extends ResourceBase {
  /// Creates the realtime resources.
  RealtimeResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates ephemeral credentials for browser connections.
  late final RealtimeSessionsResource sessions = RealtimeSessionsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );
}

/// Creates short-lived credentials for realtime transcription.
final class RealtimeSessionsResource extends ResourceBase {
  /// Creates the client sessions resource.
  RealtimeSessionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Mints a credential scoped to the requested model.
  ///
  /// Call this from your backend with your workspace API key. Return
  /// [RealtimeClientSession.clientSecret] to your authenticated browser
  /// client so it can establish a WebSocket connection.
  Future<RealtimeClientSession> create({
    required CreateRealtimeClientSessionRequest request,
  }) async {
    ensureNotClosed?.call();
    if (request.model.trim().isEmpty) {
      throw ArgumentError('The realtime model must be non-empty.');
    }
    if (request.ttlSeconds case final ttl? when ttl <= 0) {
      throw ArgumentError.value(ttl, 'ttlSeconds', 'Must be positive.');
    }
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    final httpRequest =
        http.Request('POST', requestBuilder.buildUrl('/v1/client/sessions'))
          ..headers.addAll(headers)
          ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    return RealtimeClientSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
