import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../models/decisions/create_decision_request.dart';
import '../models/decisions/create_decision_response.dart';
import '../models/decisions/decision_input.dart';
import '../models/decisions/decision_question.dart';
import 'base_resource.dart';

/// Evaluates structured questions against shared multimodal input.
///
/// Available on the Gemini Developer API with [ApiVersion.v1beta].
class DecisionsResource extends ResourceBase {
  /// Creates the Decisions API resource.
  DecisionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Evaluates binary, multiple-choice, or rubric questions in one request.
  ///
  /// Use `gemini-decision-1` as the [model]. The response keys match the
  /// identifiers you provide in [questions]. Use [abortTrigger] to cancel
  /// the HTTP request.
  Future<CreateDecisionResponse> create({
    required String model,
    required DecisionInput input,
    required Map<String, DecisionQuestion> questions,
    Future<void>? abortTrigger,
  }) async {
    if (config.apiMode != ApiMode.googleAI ||
        config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError(
        'The Decisions API requires the Gemini Developer API with '
        'ApiVersion.v1beta.',
      );
    }

    final requestBody = CreateDecisionRequest(
      model: model,
      input: input,
      questions: questions,
    );
    final url = requestBuilder.buildUrl('/{version}/decisions');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestBody.toJson());

    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return CreateDecisionResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }
}
