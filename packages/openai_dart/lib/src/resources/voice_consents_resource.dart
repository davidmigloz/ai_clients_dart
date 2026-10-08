import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/audio/voice_consent.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';

/// Resource for managing voice consent recordings.
///
/// Access this resource through `client.audio.voiceConsents`. Operations use
/// the client's shared authentication, cancellation, error and retry handling.
/// Multipart creation is sent once because an upload cannot be safely replayed.
class VoiceConsentsResource extends ResourceBase {
  /// Creates a [VoiceConsentsResource].
  VoiceConsentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/audio/voice_consents';

  /// Uploads a voice consent recording.
  ///
  /// Sends the original recording bytes with their filename and normalized base
  /// MIME type. The caller must obtain the current consent phrase and record
  /// consent explicitly before constructing [request].
  Future<VoiceConsent> create(
    VoiceConsentCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    final contentType = MediaType.parse(request.effectiveRecordingContentType);
    final url = requestBuilder.buildUrl(_endpoint);
    await checkPrivateAudioAbort(abortTrigger, 'Voice consent');
    ensureNotClosed?.call();

    final httpRequest = http.MultipartRequest('POST', url)
      ..fields.addAll({'name': request.name, 'language': request.language})
      ..files.add(
        http.MultipartFile.fromBytes(
          'recording',
          request.recording,
          filename: request.filename,
          contentType: contentType,
        ),
      )
      ..headers.addAll(
        requestBuilder.buildMultipartHeaders(
          additionalHeaders: {'Accept': 'application/json'},
        ),
      );
    // The multipart encoder supplies the boundary. Configured/provider media
    // headers must not replace it with a different content type.
    httpRequest.headers
      ..remove('content-type')
      ..['Accept'] = 'application/json';

    final response = await _send(httpRequest, abortTrigger: abortTrigger);
    return _parseResponse(response, VoiceConsent.fromJson, 'create');
  }

  /// Lists one page of voice consent recordings.
  ///
  /// [after] is a caller-selected cursor. [limit] must be between 1 and 100.
  /// Omitting [limit] lets the service apply its default of 20. This method does
  /// not infer cursors or fetch additional pages.
  Future<VoiceConsentList> list({
    String? after,
    int? limit,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (limit != null && (limit < 1 || limit > 100)) {
      throw ArgumentError(
        'Voice consent list limit must be between 1 and 100.',
      );
    }
    final response = await _execute(
      'GET',
      _endpoint,
      query: {'after': ?after, if (limit != null) 'limit': limit.toString()},
      abortTrigger: abortTrigger,
    );
    return _parseResponse(response, VoiceConsentList.fromJson, 'list');
  }

  /// Retrieves a voice consent recording by its opaque [consentId].
  Future<VoiceConsent> retrieve(
    String consentId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final response = await _execute(
      'GET',
      _consentPath(consentId),
      abortTrigger: abortTrigger,
    );
    return _parseResponse(response, VoiceConsent.fromJson, 'retrieve');
  }

  /// Renames a voice consent recording by its opaque [consentId].
  ///
  /// Sends the required name as a JSON POST. Recording bytes and other consent
  /// metadata cannot be changed through this operation.
  Future<VoiceConsent> update(
    String consentId,
    VoiceConsentUpdateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = _consentPath(consentId);
    final body = request.toJson();
    final response = await _execute(
      'POST',
      path,
      body: body,
      abortTrigger: abortTrigger,
    );
    return _parseResponse(response, VoiceConsent.fromJson, 'update');
  }

  /// Deletes a voice consent recording by its opaque [consentId].
  ///
  /// The caller explicitly selects the consent to delete. No operation in this
  /// resource schedules or performs deletion automatically.
  Future<VoiceConsentDeleted> delete(
    String consentId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final response = await _execute(
      'DELETE',
      _consentPath(consentId),
      abortTrigger: abortTrigger,
    );
    return _parseResponse(response, VoiceConsentDeleted.fromJson, 'delete');
  }

  Future<http.Response> _execute(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    Future<void>? abortTrigger,
  }) async {
    final url = requestBuilder.buildUrl(path, queryParams: query);
    final encodedBody = body == null ? null : jsonEncode(body);
    await checkPrivateAudioAbort(abortTrigger, 'Voice consent');
    ensureNotClosed?.call();
    final request = http.Request(method, url)
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      )
      ..headers['Accept'] = 'application/json'
      ..headers['Content-Type'] = 'application/json';
    if (encodedBody != null) request.body = encodedBody;
    return _send(request, abortTrigger: abortTrigger);
  }

  Future<http.Response> _send(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
  }) => sendPrivateAudioRequest(
    request,
    interceptorChain: interceptorChain,
    context: 'Voice consent',
    abortTrigger: abortTrigger,
  );

  String _consentPath(String consentId) {
    // Dart Uri normalizes literal and escaped dot segments. Reject only these
    // unsendable segments; every other identifier is encoded exactly once.
    if (consentId.isEmpty || consentId == '.' || consentId == '..') {
      throw ArgumentError('Voice consent ID must be a nonempty path segment.');
    }
    try {
      return '$_endpoint/${Uri.encodeComponent(consentId)}';
    } on ArgumentError {
      throw ArgumentError(
        'Voice consent ID must be encodable as a path segment.',
      );
    }
  }

  T _parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parse,
    String operation,
  ) => parsePrivateAudioResponse(response, parse, 'voice consent $operation');
}
