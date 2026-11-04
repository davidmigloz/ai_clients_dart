import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/audio/custom_voice.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';

/// Encoding of a voice creation request, separate from its creation method.
///
/// Omission on create chooses JSON for prompts and multipart for samples.
enum VoiceCreateEncoding {
  /// JSON, supported only by prompt requests.
  json,

  /// Multipart form data, supported by both creation methods.
  multipart,
}

/// Creates saved voices from prompts or consented samples and deletes them.
///
/// Access this cached resource through `client.audio.voices`. Every creation
/// request is sent once to avoid creating duplicate saved voices after uncertain
/// delivery. Authentication, cancellation and errors use the shared HTTP policy.
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

  /// Creates a saved voice from a description or an existing consent/sample.
  ///
  /// [PromptVoiceCreateRequest] uses JSON by default and also supports explicit
  /// multipart [encoding]. Prompt voices work only in Live and have no preview
  /// audio. The service generates a script/model default for omitted fields.
  ///
  /// [CustomVoiceCreateRequest] always uses multipart; explicitly selecting JSON
  /// is rejected before authentication. Original sample bytes, filename and
  /// normalized base MIME type are preserved. Omitted sample type stays omitted.
  /// Consent/sample eligibility and speech content are validated by the service.
  Future<CustomVoice> create(
    VoiceCreateRequest request, {
    VoiceCreateEncoding? encoding,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    if (request is CustomVoiceCreateRequest &&
        encoding == VoiceCreateEncoding.json) {
      throw ArgumentError('Audio-sample voices require multipart encoding.');
    }
    final url = requestBuilder.buildUrl(_endpoint);
    await checkPrivateAudioAbort(abortTrigger, 'Custom voice');
    ensureNotClosed?.call();

    final http.BaseRequest httpRequest;
    switch (request) {
      case PromptVoiceCreateRequest():
        if (encoding == VoiceCreateEncoding.multipart) {
          httpRequest = http.MultipartRequest('POST', url)
            ..fields.addAll(request.toJson().cast<String, String>());
          _multipartHeaders(httpRequest);
        } else {
          httpRequest = http.Request('POST', url)
            ..headers.addAll(_jsonHeaders())
            ..body = jsonEncode(request.toJson());
        }
      case CustomVoiceCreateRequest():
        httpRequest = http.MultipartRequest('POST', url)
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
              contentType: MediaType.parse(
                request.effectiveAudioSampleContentType,
              ),
            ),
          );
        _multipartHeaders(httpRequest);
    }
    final response = await sendPrivateAudioRequest(
      httpRequest,
      interceptorChain: interceptorChain,
      context: 'Custom voice',
      abortTrigger: abortTrigger,
      allowRetries: false,
    );
    return parsePrivateAudioResponse(
      response,
      CustomVoice.fromJson,
      'custom voice create',
    );
  }

  /// Deletes the explicitly selected saved voice, retaining its consent.
  ///
  /// Repeated deletion returns the service's 404. This method never searches
  /// for voices or schedules cleanup automatically.
  Future<CustomVoiceDeleted> delete(
    String voiceId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (voiceId.isEmpty || voiceId == '.' || voiceId == '..') {
      throw ArgumentError('Voice ID must be a nonempty path segment.');
    }
    final String encoded;
    try {
      encoded = Uri.encodeComponent(voiceId);
      if (Uri.decodeComponent(encoded) != voiceId) {
        throw ArgumentError('Voice ID must be encodable as a path segment.');
      }
    } on ArgumentError {
      throw ArgumentError('Voice ID must be encodable as a path segment.');
    }
    final url = requestBuilder.buildUrl('$_endpoint/$encoded');
    await checkPrivateAudioAbort(abortTrigger, 'Custom voice');
    ensureNotClosed?.call();
    final request = http.Request('DELETE', url)..headers.addAll(_jsonHeaders());
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Custom voice',
      abortTrigger: abortTrigger,
    );
    return parsePrivateAudioResponse(
      response,
      CustomVoiceDeleted.fromJson,
      'custom voice delete',
    );
  }

  Map<String, String> _jsonHeaders() =>
      requestBuilder.buildHeaders(
          additionalHeaders: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )
        ..['Accept'] = 'application/json'
        ..['Content-Type'] = 'application/json';

  void _multipartHeaders(http.BaseRequest request) {
    request.headers
      ..addAll(
        requestBuilder.buildMultipartHeaders(
          additionalHeaders: {'Accept': 'application/json'},
        ),
      )
      // The encoder supplies its boundary, regardless of configured media headers.
      ..remove('content-type')
      ..['Accept'] = 'application/json';
  }
}
