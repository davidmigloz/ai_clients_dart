import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/moderations/moderations.dart';
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

  /// Classifies if text or images are potentially harmful.
  ///
  /// The moderation endpoint checks for content that falls into
  /// categories like hate, harassment, self-harm, sexual content,
  /// and violence.
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
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ModerationResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
