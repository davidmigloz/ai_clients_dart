import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/audio/voice_create_request.dart';
import '../../models/audio/voice_list_response.dart';
import '../../models/audio/voice_response.dart';
import '../../models/audio/voice_update_request.dart';
import '../base_resource.dart';

/// Resource for voice management operations.
///
/// Provides CRUD operations for custom voices used in speech synthesis.
///
/// Example usage:
/// ```dart
/// // List all voices
/// final voices = await client.audio.voices.list();
/// for (final voice in voices.items) {
///   print('${voice.name}: ${voice.id}');
/// }
///
/// // Create a custom voice
/// final voice = await client.audio.voices.create(
///   request: VoiceCreateRequest(
///     name: 'My Voice',
///     sampleAudio: base64EncodedAudio,
///   ),
/// );
/// print(voice.id);
/// ```
class VoicesResource extends ResourceBase {
  /// Creates a [VoicesResource].
  VoicesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists all voices.
  ///
  /// Returns a paginated [VoiceListResponse] of available voices.
  Future<VoiceListResponse> list({int? limit, int? offset}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final url = requestBuilder.buildUrl(
      '/v1/audio/voices',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return VoiceListResponse.fromJson(responseBody);
  }

  /// Creates a custom voice.
  ///
  /// The [request] contains the voice name, audio sample, and metadata.
  ///
  /// Returns the created [VoiceResponse].
  Future<VoiceResponse> create({required VoiceCreateRequest request}) async {
    final url = requestBuilder.buildUrl('/v1/audio/voices');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return VoiceResponse.fromJson(responseBody);
  }

  /// Retrieves a voice by ID.
  ///
  /// Returns the [VoiceResponse] for the given [voiceId].
  Future<VoiceResponse> retrieve({required String voiceId}) async {
    final url = requestBuilder.buildUrl('/v1/audio/voices/$voiceId');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return VoiceResponse.fromJson(responseBody);
  }

  /// Updates a voice's metadata.
  ///
  /// The [request] contains the fields to update.
  ///
  /// Returns the updated [VoiceResponse].
  Future<VoiceResponse> update({
    required String voiceId,
    required VoiceUpdateRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/audio/voices/$voiceId');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return VoiceResponse.fromJson(responseBody);
  }

  /// Deletes a voice.
  ///
  /// Returns the deleted [VoiceResponse].
  Future<VoiceResponse> delete({required String voiceId}) async {
    final url = requestBuilder.buildUrl('/v1/audio/voices/$voiceId');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return VoiceResponse.fromJson(responseBody);
  }
}
