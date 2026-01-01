import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/moderations/chat_moderation_request.dart';
import '../models/moderations/moderation_request.dart';
import '../models/moderations/moderation_response.dart';
import 'base_resource.dart';

/// Resource for the Moderations API.
///
/// Provides content moderation capabilities for text and chat messages.
///
/// Example usage:
/// ```dart
/// final response = await client.moderations.create(
///   request: ModerationRequest.single(
///     input: 'Some text to moderate',
///   ),
/// );
/// print('Flagged: ${response.flagged}');
/// ```
class ModerationsResource extends ResourceBase {
  /// Creates a [ModerationsResource].
  ModerationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Moderates text content.
  ///
  /// Returns a [ModerationResponse] with results for each input.
  Future<ModerationResponse> create({
    required ModerationRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/moderations');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ModerationResponse.fromJson(responseBody);
  }

  /// Moderates chat messages.
  ///
  /// Returns a [ModerationResponse] with results for the conversation.
  Future<ModerationResponse> createChat({
    required ChatModerationRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/chat/moderations');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ModerationResponse.fromJson(responseBody);
  }
}
