import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../errors/exceptions.dart';
import '../models/voices/voice.dart';
import '../utils/redactor.dart';
import 'base_resource.dart';

/// Custom voice management and voice catalog for Gemini Developer API v1beta.
class VoicesResource extends ResourceBase {
  /// Creates a [VoicesResource].
  VoicesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a voice from a text prompt or a speaker's source and consent audio.
  ///
  /// Prompted voices must be stored. When [store] is false, a replicated voice
  /// returns an expiring client-managed key rather than a stored voice ID.
  Future<Voice> create({
    required Voice voice,
    bool? store,
    Future<void>? abortTrigger,
  }) async {
    final shouldStore =
        store ?? (voice.type == VoiceType.prompted ? true : null);
    final replication = voice.replicated;
    final valid = switch (voice.type) {
      VoiceType.prompted =>
        voice.prompted != null && replication == null && shouldStore == true,
      VoiceType.replicated => replication != null && voice.prompted == null,
      _ => false,
    };
    if (!valid) {
      throw const ValidationException(
        message:
            'Voice creation requires a stored prompt or source and consent audio.',
        fieldErrors: {
          'voice': ['Supply the required input for the voice type.'],
        },
      );
    }
    final response = await _request(
      'POST',
      '/{version}/voices',
      body: {'voice': voice.toCreateJson(), 'store': ?shouldStore},
      redactor: Redactor(
        sensitiveValues: [
          if (replication != null) ...[
            replication.sourceAudio.data,
            replication.consentAudio.data,
          ],
        ],
        redactionList: _diagnosticFields,
      ),
      abortTrigger: abortTrigger,
    );
    return _decode(response, Voice.fromJson);
  }

  /// Lists stored custom and prebuilt voices that match the optional filters.
  ///
  /// Keep the same filters when following [pageToken].
  Future<ListVoicesResponse> list({
    int? pageSize,
    String? pageToken,
    List<String>? accents,
    List<String>? contexts,
    List<String>? genders,
    List<String>? languageCodes,
    List<String>? personas,
    List<VoicePitch>? pitches,
    List<String>? regionCodes,
    List<VoiceType>? types,
    String? search,
    Future<void>? abortTrigger,
  }) async {
    final response = await _request(
      'GET',
      '/{version}/voices',
      query: {
        'page_size': ?pageSize?.toString(),
        'page_token': ?pageToken,
        'accent': ?accents,
        'context': ?contexts,
        'gender': ?genders,
        'language_code': ?languageCodes,
        'persona': ?personas,
        if (pitches != null)
          'pitch': pitches.map((pitch) => pitch.value).toList(),
        'region_code': ?regionCodes,
        if (types != null) 'type': types.map((type) => type.value).toList(),
        'search': ?search,
      },
      abortTrigger: abortTrigger,
    );
    return _decode(response, ListVoicesResponse.fromJson);
  }

  /// Retrieves a stored voice by its ID or `voices/{id}` resource name.
  Future<Voice> get(String name, {Future<void>? abortTrigger}) async {
    final response = await _request(
      'GET',
      '/{version}/voices/${_voiceId(name)}',
      abortTrigger: abortTrigger,
    );
    return _decode(response, Voice.fromJson);
  }

  /// Deletes a stored voice by its ID or `voices/{id}` resource name.
  Future<void> delete(String name, {Future<void>? abortTrigger}) async {
    await _request(
      'DELETE',
      '/{version}/voices/${_voiceId(name)}',
      abortTrigger: abortTrigger,
    );
  }

  static const _diagnosticFields = [
    'key',
    'source_audio',
    'consent_audio',
    'sample_audio',
  ];

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Redactor? redactor,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    if (config.apiMode != ApiMode.googleAI ||
        config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError(
        'Voices requires the Gemini Developer API v1beta.',
      );
    }
    final request =
        http.Request(method, requestBuilder.buildUrl(path, queryParams: query))
          ..headers.addAll(
            requestBuilder.buildHeaders(
              additionalHeaders: {
                'Api-Revision': '2026-05-20',
                'Accept': 'application/json',
                if (body != null) 'Content-Type': 'application/json',
              },
            ),
          );
    if (body != null) request.body = jsonEncode(body);
    return interceptorChain.execute(
      request,
      diagnosticRedactor:
          redactor ?? const Redactor(redactionList: _diagnosticFields),
      abortTrigger: abortTrigger,
    );
  }

  static String _voiceId(String name) {
    final id = name.startsWith('voices/') ? name.substring(7) : name;
    if (id.isEmpty || id.contains('/') || id == '.' || id == '..') {
      throw const ValidationException(
        message: 'Supply a stored voice ID or voices/{id}.',
        fieldErrors: {
          'name': ['Expected one stored voice identifier.'],
        },
      );
    }
    return Uri.encodeComponent(id);
  }

  static T _decode<T>(
    http.Response response,
    T Function(Map<String, dynamic>) decode,
  ) {
    try {
      return decode(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      // The original parse error can contain a client-managed voice key.
    } on TypeError {
      // A successful response must match the requested Voices payload structure.
    }
    throw const FormatException('Invalid Gemini Voices response.');
  }
}
