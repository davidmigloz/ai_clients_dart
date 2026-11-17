import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/moderations/moderations.dart';
import '../utils/diagnostic_label.dart';
import '../utils/private_agent_inspection_http.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';

/// Resource for content moderation operations.
///
/// Classifies text and images for potentially harmful content.
///
/// Access this resource through [OpenAIClient.moderations].
///
/// ## Example
///
/// ```dart
/// final result = await client.moderations.create(
///   ModerationRequest(
///     input: ModerationInput.text('Check this text'),
///   ),
/// );
///
/// if (result.results.first.flagged) {
///   print('Content was flagged');
/// }
/// ```
class ModerationsResource extends ResourceBase {
  /// Creates a [ModerationsResource].
  ModerationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/moderations';
  static const _imageClassifierModel = 'omni-moderation-csam-latest';

  /// Classifies if text or images are potentially harmful.
  ///
  /// The moderation endpoint checks for content that falls into
  /// categories like hate, harassment, self-harm, sexual content,
  /// and violence. Use [classifyImage] for the gated image classifier.
  ///
  /// ## Parameters
  ///
  /// - [request] - The moderation request.
  ///
  /// ## Returns
  ///
  /// A [ModerationResponse] with the classification results.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.moderations.create(
  ///   ModerationRequest(
  ///     input: ModerationInput.text('Some text to check'),
  ///     model: 'text-moderation-latest',
  ///   ),
  /// );
  ///
  /// final categories = result.results.first.categories;
  /// if (categories.hate) {
  ///   print('Hate speech detected');
  /// }
  /// if (categories.violence) {
  ///   print('Violence detected');
  /// }
  /// ```
  Future<ModerationResponse> create(
    ModerationRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final body = request.toJson();
    if (body['model'] == _imageClassifierModel) {
      throw ArgumentError(
        'Use moderations.classifyImage for the image classifier.',
      );
    }
    final response = await _send(body, abortTrigger: abortTrigger);
    return ModerationResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Classifies one still image in an approved child-safety workflow.
  ///
  /// [imageUrl] is an HTTP(S) image URL or a base64 encoded image data URL.
  /// The organization must have access to `omni-moderation-csam-latest`.
  /// Follow the [classifier guide](https://developers.openai.com/api/docs/guides/csam-classifier)
  /// and your organization's approved input-handling process.
  /// Package diagnostics redact the request and result payloads.
  Future<ImageClassifierResponse> classifyImage(
    String imageUrl, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final request = ModerationRequest(
      model: _imageClassifierModel,
      input: ModerationInput.multiModal([
        ModerationInputItem.imageUrl(imageUrl),
      ]),
    );
    final response = await _send(
      request.toJson(),
      abortTrigger: abortTrigger,
      redactDiagnostics: true,
    );
    try {
      return parsePrivateAudioResponse<ImageClassifierResponse>(
        response,
        ImageClassifierResponse.fromJson,
        'image classifier',
      );
    } on ParseException catch (error) {
      markPrivateDiagnostics(error);
      rethrow;
    }
  }

  Future<http.Response> _send(
    Map<String, dynamic> body, {
    Future<void>? abortTrigger,
    bool redactDiagnostics = false,
  }) {
    final httpRequest = privateAgentInspectionExternal(
      null,
      () => http.Request('POST', requestBuilder.buildUrl(_endpoint))
        ..headers.addAll(requestBuilder.buildHeaders())
        ..body = jsonEncode(body),
      redactDiagnostics: redactDiagnostics,
    );
    return interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
      redactDiagnostics: redactDiagnostics,
    );
  }
}
