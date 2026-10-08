import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/audio/custom_voice.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';

/// Resource for creating custom voices from explicit consent and audio samples.
///
/// Access this cached resource through `client.audio.voices`. Creation uses the
/// client's shared authentication, cancellation and error handling. Multipart
/// uploads are sent once because their bodies cannot be safely replayed.
class VoicesResource extends ResourceBase {
  /// Creates a [VoicesResource].
  VoicesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/audio/voices';

  /// Creates a custom voice from an audio sample and an existing consent.
  ///
  /// Sends the original sample bytes with their filename and normalized base
  /// MIME type. Omitted [CustomVoiceCreateRequest.type] remains omitted so the
  /// service applies its `audio_sample` default. The caller must select a consent
  /// and sample from the same person and project; the service validates access,
  /// consent and speech content. The returned [CustomVoice] contains metadata
  /// whose ID the caller can supply in an appropriate custom voice reference.
  Future<CustomVoice> create(
    CustomVoiceCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    final contentType = MediaType.parse(
      request.effectiveAudioSampleContentType,
    );
    final url = requestBuilder.buildUrl(_endpoint);
    await checkPrivateAudioAbort(abortTrigger, 'Custom voice');
    ensureNotClosed?.call();

    final httpRequest = http.MultipartRequest('POST', url)
      ..fields.addAll({
        'name': request.name,
        'consent': request.consent,
        'type': ?request.type,
      })
      ..files.add(
        http.MultipartFile.fromBytes(
          'audio_sample',
          request.audioSample,
          filename: request.filename,
          contentType: contentType,
        ),
      )
      ..headers.addAll(
        requestBuilder.buildMultipartHeaders(
          additionalHeaders: {'Accept': 'application/json'},
        ),
      );
    // The multipart encoder owns the boundary; configured media headers cannot
    // replace the multipart content type selected during finalization.
    httpRequest.headers
      ..remove('content-type')
      ..['Accept'] = 'application/json';

    final response = await sendPrivateAudioRequest(
      httpRequest,
      interceptorChain: interceptorChain,
      context: 'Custom voice',
      abortTrigger: abortTrigger,
    );
    return parsePrivateAudioResponse(
      response,
      CustomVoice.fromJson,
      'custom voice create',
    );
  }
}
