import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/chat_completion_field_options.dart';
import '../../models/observability/chat_completion_fields.dart';
import '../../models/observability/field_option_counts.dart';
import '../../models/observability/field_option_counts_in_schema.dart';
import '../base_resource.dart';

/// Resource for chat completion field operations.
///
/// Provides access to field definitions and their options for filtering
/// chat completion events.
///
/// Example usage:
/// ```dart
/// // List available fields
/// final fields = await client.observability.chatCompletionFields.list();
///
/// // Get options for a field
/// final options = await client.observability.chatCompletionFields.getOptions(
///   fieldName: 'model',
/// );
/// ```
class ChatCompletionFieldsResource extends ResourceBase {
  /// Creates a [ChatCompletionFieldsResource].
  ChatCompletionFieldsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists all available chat completion fields.
  Future<ChatCompletionFields> list() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-fields',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatCompletionFields.fromJson(responseBody);
  }

  /// Gets the available options for a specific field.
  Future<ChatCompletionFieldOptions> getOptions({
    required String fieldName,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-fields/$fieldName/options',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatCompletionFieldOptions.fromJson(responseBody);
  }

  /// Gets counts for each option value of a field.
  Future<FieldOptionCounts> getOptionsCounts({
    required String fieldName,
    FieldOptionCountsInSchema? request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-fields/$fieldName/options-counts',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request?.toJson() ?? {});

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FieldOptionCounts.fromJson(responseBody);
  }
}
