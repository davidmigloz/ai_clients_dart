import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/judge_conversation_request.dart';
import '../../models/observability/judge_output.dart';
import '../../models/observability/judge_preview.dart';
import '../../models/observability/judge_previews.dart';
import '../../models/observability/post_judge_in_schema.dart';
import '../../models/observability/put_judge_in_schema.dart';
import '../base_resource.dart';

/// Resource for observability judge operations.
///
/// Judges are used to evaluate conversations using an LLM. They can be
/// classification-based (categorize) or regression-based (score).
///
/// Example usage:
/// ```dart
/// // List judges
/// final judges = await client.observability.judges.list();
///
/// // Create a judge
/// final judge = await client.observability.judges.create(
///   request: PostJudgeInSchema(
///     name: 'Quality Judge',
///     description: 'Evaluates response quality',
///     modelName: 'mistral-large-latest',
///     output: JudgeOutputConfig.regression(
///       minDescription: 'Poor quality',
///       maxDescription: 'Excellent quality',
///     ),
///     instructions: 'Rate the quality of the assistant response.',
///     tools: [],
///   ),
/// );
///
/// // Run live judging
/// final output = await client.observability.judges.liveJudging(
///   judgeId: judge.id,
///   request: JudgeConversationRequest(
///     messages: [{'role': 'user', 'content': 'Hello'}],
///   ),
/// );
/// ```
class JudgesResource extends ResourceBase {
  /// Creates a [JudgesResource].
  JudgesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists all judges.
  Future<JudgePreviews> list() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/judges');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return JudgePreviews.fromJson(responseBody);
  }

  /// Creates a new judge.
  Future<JudgePreview> create({required PostJudgeInSchema request}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/judges');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return JudgePreview.fromJson(responseBody);
  }

  /// Gets a judge by ID.
  Future<JudgePreview> get({required String judgeId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/judges/$judgeId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return JudgePreview.fromJson(responseBody);
  }

  /// Updates a judge.
  Future<void> update({
    required String judgeId,
    required PutJudgeInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/judges/$judgeId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Deletes a judge.
  Future<void> delete({required String judgeId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/judges/$judgeId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Runs a saved judge on a conversation.
  Future<JudgeOutput> liveJudging({
    required String judgeId,
    required JudgeConversationRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/judges/$judgeId/live-judging',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return JudgeOutput.fromJson(responseBody);
  }
}
