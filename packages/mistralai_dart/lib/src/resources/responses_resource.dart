import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/responses/response.dart';
import '../models/responses/response_stream_event.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Mistral's stateless Responses API.
///
/// Supply prior output and tool results as input for a follow-up request. The
/// service does not keep response history or run in the background.
class ResponsesResource extends ResourceBase with StreamingResource {
  /// Creates the Responses resource.
  ResponsesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/v1/responses';

  /// Creates a response and waits for the full result.
  Future<MistralResponse> create({
    required CreateResponseRequest request,
  }) async {
    ensureNotClosed?.call();
    final response = await interceptorChain.execute(
      _request(
        _endpoint,
        request.copyWith(stream: false).toJson(),
        accept: 'application/json',
      ),
    );
    return MistralResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a response and reads its server-sent events.
  ///
  /// API error events are part of the typed stream. HTTP errors are thrown
  /// before the stream opens. Cancel through [abortTrigger] or by cancelling
  /// the subscription.
  Stream<ResponseStreamEvent> createStream({
    required CreateResponseRequest request,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return streamRequest(
      () => _request(
        _endpoint,
        request.copyWith(stream: true).toJson(),
        accept: 'text/event-stream',
      ),
      _decodeEvent,
      checkInlineErrors: false,
      abortTrigger: abortTrigger,
    );
  }

  /// Counts tokens for a prospective request without generating output.
  Future<ResponseInputTokenCount> countInputTokens({
    required CountResponseInputTokensRequest request,
  }) async {
    ensureNotClosed?.call();
    final response = await interceptorChain.execute(
      _request(
        '$_endpoint/input_tokens',
        request.toJson(),
        accept: 'application/json',
      ),
    );
    return ResponseInputTokenCount.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  http.Request _request(
    String path,
    Map<String, dynamic> payload, {
    required String accept,
  }) {
    _checkStatelessOptions(payload);
    return http.Request('POST', requestBuilder.buildUrl(path))
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {
            'Accept': accept,
            'Content-Type': 'application/json',
          },
        ),
      )
      ..body = jsonEncode(payload);
  }

  static void _checkStatelessOptions(Map<String, dynamic> payload) {
    for (final name in [
      'conversation',
      'previous_response_id',
      'prompt',
      'moderation',
    ]) {
      if (payload[name] != null) {
        throw ArgumentError('Mistral Responses does not support $name');
      }
    }
    if (payload['store'] != null && payload['store'] != false) {
      throw ArgumentError('Mistral Responses does not store responses');
    }
    if (payload['top_logprobs'] != null && payload['top_logprobs'] != 0) {
      throw ArgumentError('Mistral Responses does not accept top logprobs');
    }
  }

  ResponseStreamEvent _decodeEvent(Map<String, dynamic> frame) {
    final payload = Map<String, dynamic>.of(frame);
    final eventName = payload.remove('_event');
    payload.remove('_rawData');
    if (eventName is String && eventName != 'message') {
      final type = payload['type'];
      if (type != null && type != eventName) {
        throw FormatException('Conflicting Responses event type: $eventName');
      }
      payload['type'] = eventName;
    }
    final error = payload['error'];
    if (error != null ||
        (eventName == 'error' && payload['sequence_number'] is! int)) {
      throwInlineStreamError(
        frame,
        eventName as String?,
        error ?? payload['message'],
      );
    }
    return ResponseStreamEvent.fromJson(payload);
  }
}
