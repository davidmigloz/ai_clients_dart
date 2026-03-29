import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/responses/input_token_count.dart';
import '../models/responses/response_input.dart';
import '../models/responses/tools/response_tool.dart';
import '../models/responses/tools/response_tool_choice.dart';
import 'base_resource.dart';

/// Resource for input tokens counting operations.
///
/// This resource allows you to calculate token usage before actually sending
/// a request to the Responses API.
///
/// ## Example
///
/// ```dart
/// final tokenCount = await client.responses.inputTokens.count(
///   model: 'gpt-4o',
///   input: ResponseInput.text('Hello, how are you?'),
/// );
/// print('Input tokens: ${tokenCount.inputTokens}');
/// ```
class InputTokensResource extends ResourceBase {
  /// Creates an [InputTokensResource].
  InputTokensResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets input token counts for a potential response request.
  ///
  /// This allows you to calculate token usage before actually sending a request.
  ///
  /// ## Parameters
  ///
  /// - [model] - The model to use for token counting.
  /// - [input] - The input to count tokens for. Use [ResponseInput.text] for
  ///   a simple string or [ResponseInput.items] for a list of items.
  /// - [instructions] - System instructions to include in the count.
  /// - [tools] - Tools that would be available in the request.
  /// - [previousResponseId] - ID of a previous response to continue from.
  /// - [conversation] - Conversation configuration.
  /// - [reasoning] - Reasoning configuration.
  /// - [text] - Text format configuration.
  /// - [toolChoice] - Tool choice configuration.
  /// - [parallelToolCalls] - Whether parallel tool calls would be enabled.
  /// - [truncation] - Truncation strategy ('auto' or 'disabled').
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// An [InputTokenCountResponse] containing the token count.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Simple text input
  /// final tokenCount = await client.responses.inputTokens.count(
  ///   model: 'gpt-4o',
  ///   input: ResponseInput.text('Hello, how are you?'),
  /// );
  /// print('Input tokens: ${tokenCount.inputTokens}');
  ///
  /// // With tools
  /// final countWithTools = await client.responses.inputTokens.count(
  ///   model: 'gpt-4o',
  ///   input: ResponseInput.text('What is the weather in Paris?'),
  ///   tools: [
  ///     ResponseTool.function(
  ///       name: 'get_weather',
  ///       description: 'Get the current weather',
  ///       parameters: {'type': 'object'},
  ///     ),
  ///   ],
  /// );
  /// ```
  Future<InputTokenCountResponse> count({
    String? model,
    ResponseInput? input,
    String? instructions,
    List<ResponseTool>? tools,
    String? previousResponseId,
    Map<String, dynamic>? conversation,
    Map<String, dynamic>? reasoning,
    Map<String, dynamic>? text,
    ResponseToolChoice? toolChoice,
    bool? parallelToolCalls,
    String? truncation,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final body = <String, dynamic>{};

    if (model != null) body['model'] = model;
    if (input != null) body['input'] = input.toJson();

    if (instructions != null) body['instructions'] = instructions;

    if (tools != null) {
      body['tools'] = tools.map((t) => t.toJson()).toList();
    }

    if (previousResponseId != null) {
      body['previous_response_id'] = previousResponseId;
    }

    if (conversation != null) body['conversation'] = conversation;
    if (reasoning != null) body['reasoning'] = reasoning;
    if (text != null) body['text'] = text;

    if (toolChoice != null) {
      body['tool_choice'] = toolChoice.toJson();
    }

    if (parallelToolCalls != null) {
      body['parallel_tool_calls'] = parallelToolCalls;
    }

    if (truncation != null) body['truncation'] = truncation;

    final url = requestBuilder.buildUrl('/responses/input_tokens');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return InputTokenCountResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
