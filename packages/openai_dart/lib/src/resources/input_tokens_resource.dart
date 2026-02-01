import '../models/responses/input_token_count.dart';
import '../models/responses/tools/response_tool.dart';
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
///   input: 'Hello, how are you?',
/// );
/// print('Input tokens: ${tokenCount.inputTokens}');
/// ```
class InputTokensResource extends BaseResource {
  /// Creates an [InputTokensResource] with the given client.
  InputTokensResource(super.client);

  /// Gets input token counts for a potential response request.
  ///
  /// This allows you to calculate token usage before actually sending a request.
  ///
  /// ## Parameters
  ///
  /// - [model] - The model to use for token counting.
  /// - [input] - The input to count tokens for. Can be a String or a List
  ///   of response input items.
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
  ///   input: 'Hello, how are you?',
  /// );
  /// print('Input tokens: ${tokenCount.inputTokens}');
  ///
  /// // With tools
  /// final countWithTools = await client.responses.inputTokens.count(
  ///   model: 'gpt-4o',
  ///   input: 'What is the weather in Paris?',
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
    Object? input,
    String? instructions,
    List<ResponseTool>? tools,
    String? previousResponseId,
    Map<String, dynamic>? conversation,
    Map<String, dynamic>? reasoning,
    Map<String, dynamic>? text,
    Object? toolChoice,
    bool? parallelToolCalls,
    String? truncation,
    Future<void>? abortTrigger,
  }) async {
    final body = <String, dynamic>{};

    if (model != null) body['model'] = model;

    // Handle input (can be String or List)
    if (input != null) {
      if (input is String) {
        body['input'] = input;
      } else if (input is List) {
        body['input'] = input.map((item) {
          if (item is Map<String, dynamic>) return item;
          // Handle items with toJson method
          try {
            // ignore: avoid_dynamic_calls
            return (item as dynamic).toJson() as Map<String, dynamic>;
          } catch (_) {
            return item;
          }
        }).toList();
      } else {
        body['input'] = input;
      }
    }

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

    // Handle toolChoice (can be String or object)
    if (toolChoice != null) {
      if (toolChoice is String) {
        body['tool_choice'] = toolChoice;
      } else {
        try {
          // ignore: avoid_dynamic_calls
          body['tool_choice'] =
              (toolChoice as dynamic).toJson() as Map<String, dynamic>;
        } catch (_) {
          body['tool_choice'] = toolChoice;
        }
      }
    }

    if (parallelToolCalls != null) {
      body['parallel_tool_calls'] = parallelToolCalls;
    }

    if (truncation != null) body['truncation'] = truncation;

    final json = await postJson(
      '/responses/input_tokens',
      body: body,
      abortTrigger: abortTrigger,
    );
    return InputTokenCountResponse.fromJson(json);
  }
}
