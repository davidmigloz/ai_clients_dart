import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../errors/exceptions.dart';
import '../models/audio/voice_consent.dart';
import '../platform/http_utils.dart';
import '../utils/http_error_response.dart';
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
    await _checkAbort(abortTrigger);
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
    await _checkAbort(abortTrigger);
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
  }) async {
    try {
      final response = await interceptorChain.execute(
        request,
        abortTrigger: abortTrigger,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw parseHttpErrorResponse(response, request: request);
      }
      return response;
    } on AbortedException catch (error) {
      throw AbortedException(
        message: error.message,
        stage: error.stage,
        correlationId: error.correlationId,
        timestamp: error.timestamp,
        cause: error.cause ?? error,
        redactDiagnostics: true,
      );
    } on http.ClientException catch (error) {
      throw ConnectionException(
        message: error.message,
        url: error.uri?.toString() ?? request.url.toString(),
        cause: error,
        redactDiagnostics: true,
      );
    } catch (error) {
      if (isSocketException(error)) {
        throw ConnectionException(
          message: 'Voice consent connection failed',
          url: request.url.toString(),
          cause: error,
          redactDiagnostics: true,
        );
      }
      rethrow;
    }
  }

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
  ) {
    final responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      json = decoded;
    } on FormatException {
      throw ParseException(
        message:
            'Invalid voice consent $operation response: '
            'expected a UTF-8 JSON object.',
        responseBody: responseBody,
        cause: const FormatException('Expected a UTF-8 JSON object.'),
      );
    }

    try {
      return parse(json);
    } on FormatException catch (error) {
      // Model parsers report field context without including received values.
      // Strip any source attached to a FormatException before retaining it.
      throw ParseException(
        message: 'Invalid voice consent $operation response: ${error.message}',
        responseBody: responseBody,
        cause: FormatException(error.message),
      );
    } on TypeError {
      throw ParseException(
        message:
            'Invalid voice consent $operation response: '
            'a known field has an invalid type.',
        responseBody: responseBody,
        cause: const FormatException('A known field has an invalid type.'),
      );
    } on ArgumentError {
      throw ParseException(
        message:
            'Invalid voice consent $operation response: '
            'a known field is invalid.',
        responseBody: responseBody,
        cause: const FormatException('A known field is invalid.'),
      );
    }
  }
}

Future<void> _checkAbort(Future<void>? abortTrigger) async {
  if (abortTrigger == null) return;
  var aborted = false;
  unawaited(
    abortTrigger.then<void>(
      (_) => aborted = true,
      onError: (Object _, StackTrace _) => aborted = true,
    ),
  );
  await Future<void>.value();
  if (aborted) {
    throw const AbortedException(
      message: 'Voice consent request aborted before dispatch',
      stage: AbortionStage.beforeRequest,
    );
  }
}
