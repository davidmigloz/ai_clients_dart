import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../models/audio/voice_create_request.dart';
import '../../models/audio/voice_enums.dart';
import '../../models/audio/voice_list_page.dart';
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
/// // Find available preset voices
/// final voices = await client.audio.voices.search(type: 'preset');
/// for (final voice in voices.data) {
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

  /// Lists voices using legacy offset pagination.
  ///
  /// Mistral has scheduled this endpoint for retirement on March 31, 2027.
  /// Use [search] for cursor pagination.
  ///
  /// Use [type] to filter by voice type.
  ///
  /// Returns a paginated [VoiceListResponse] of available voices.
  @Deprecated('Use search. The offset endpoint retires on March 31, 2027.')
  Future<VoiceListResponse> list({
    int? limit,
    int? offset,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (type != null) queryParams['type'] = type;

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

  /// Searches voices using cursor pagination.
  ///
  /// Pass a returned `nextPageToken` as [pageToken] to fetch the next page
  /// with the same filters. [type] can be `all`, `preset` or `custom`.
  Future<VoiceListPage> search({
    int? pageSize,
    String? pageToken,
    String? type,
    List<VoiceGender>? gender,
    List<String>? language,
    String? query,
    VoiceKind? kind,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v2/audio/voices',
      queryParams: {
        if (pageSize != null) 'page_size': pageSize.toString(),
        'page_token': ?pageToken,
        'type': ?type,
        if (gender != null) 'gender': gender.map((value) => value.value),
        'language': ?language,
        'query': ?query,
        if (kind != null) 'kind': kind.value,
      },
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Accept': 'application/json'},
    );
    final request = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(request);
    return VoiceListPage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Downloads the voice's sample as WAV bytes.
  Future<Uint8List> getSampleAudio({required String voiceId}) async {
    final id = Uri.encodeComponent(voiceId);
    final url = requestBuilder.buildUrl('/v1/audio/voices/$id/sample');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Accept': 'audio/wav'},
    )..removeWhere((key, _) => key.toLowerCase() == 'content-type');
    final request = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(request);
    return response.bodyBytes;
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
    final url = requestBuilder.buildUrl(
      '/v1/audio/voices/${Uri.encodeComponent(voiceId)}',
    );

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
    final url = requestBuilder.buildUrl(
      '/v1/audio/voices/${Uri.encodeComponent(voiceId)}',
    );

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
    final url = requestBuilder.buildUrl(
      '/v1/audio/voices/${Uri.encodeComponent(voiceId)}',
    );

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return VoiceResponse.fromJson(responseBody);
  }
}
