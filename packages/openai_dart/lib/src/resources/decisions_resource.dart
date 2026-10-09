import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/decisions/decisions.dart';
import 'base_resource.dart';

/// Resource for typed classification and scoring with the Decisions API.
///
/// Access through `OpenAIClient.decisions`. The API accepts text and data URL or publicly
/// accessible HTTP(S) images and returns ordered predicate, choice, score, or refusal answers.
class DecisionsResource extends ResourceBase {
  /// Creates a [DecisionsResource].
  DecisionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Evaluates ordered questions against shared text or image input.
  ///
  /// Currently supports `gpt-6-luna`. There is no model-event streaming mode.
  /// A refusal is represented by an answer variant in the returned response.
  ///
  /// ```dart
  /// final decision = await client.decisions.create(
  ///   DecisionRequest(
  ///     model: 'gpt-6-luna',
  ///     input: DecisionInput.text('The screen arrived broken.'),
  ///     questions: [
  ///       DecisionQuestion.predicate(
  ///         name: 'damaged',
  ///         instructions: 'Does the customer report a damaged item?',
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<DecisionResponse> create(
    DecisionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final httpRequest =
        http.Request('POST', requestBuilder.buildUrl('/decisions'))
          ..headers.addAll(requestBuilder.buildHeaders())
          ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return DecisionResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
