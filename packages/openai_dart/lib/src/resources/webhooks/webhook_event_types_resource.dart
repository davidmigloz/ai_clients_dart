import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/webhooks/webhook_endpoint.dart';
import '../base_resource.dart';

/// Discovers webhook event types available to the authenticated project.
class WebhookEventTypesResource extends ResourceBase {
  /// Creates the event-type discovery resource using shared HTTP infrastructure.
  WebhookEventTypesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists all available event types without pagination.
  ///
  /// Discovery returns open strings, including future server values. Endpoint
  /// subscription requests use the separate [WebhookEventType] writable enum.
  Future<WebhookEventTypeList> list({Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final request = http.Request(
      'GET',
      requestBuilder.buildUrl('/webhook_event_types'),
    )..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    try {
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      return WebhookEventTypeList.fromJson(json);
    } on FormatException {
      throw const FormatException('Invalid WebhookEventTypeList response.');
    } on TypeError {
      throw const FormatException('Invalid WebhookEventTypeList response.');
    } on ArgumentError {
      throw const FormatException('Invalid WebhookEventTypeList response.');
    }
  }
}
