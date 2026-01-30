/// Models for the OpenAI Responses API.
///
/// The Responses API is OpenAI's next-generation interface that unifies
/// chat completions, reasoning, and tool use into a single API with
/// support for multi-turn conversations, built-in tools, and background
/// processing.
///
/// ## Key Classes
///
/// - [CreateResponseRequest] - Request to create a response
/// - [Response] - The response from the API
/// - [ResponseStreamEvent] - Streaming events during response generation
/// - [ResponseStreamAccumulator] - Helper to accumulate streaming events
///
/// ## Tools
///
/// The API supports various tool types:
/// - [FunctionTool] - Custom function definitions
/// - [WebSearchTool] - Built-in web search
/// - [FileSearchTool] - Search vector stores
/// - [CodeInterpreterTool] - Execute code
/// - [ComputerUseTool] - Control a computer
/// - [ImageGenerationTool] - Generate images
/// - [McpTool] - Model Context Protocol tools
///
/// ## Output Item Types
///
/// Responses can contain various output item types:
/// - [MessageOutputItem] - Text messages from the assistant
/// - [FunctionCallOutputItemResponse] - Custom function calls
/// - [ReasoningItem] - Reasoning content from reasoning models
/// - [WebSearchCallOutputItem] - Web search tool calls
/// - [FileSearchCallOutputItem] - File search tool calls
/// - [CodeInterpreterCallOutputItem] - Code interpreter tool calls
/// - [ImageGenerationCallOutputItem] - Image generation tool calls
/// - [McpCallOutputItem] - MCP tool calls
///
/// ## Example
///
/// ```dart
/// // Create a simple response
/// final response = await client.responses.create(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: 'Hello, how are you?',
///   ),
/// );
/// print(response.outputText);
///
/// // Streaming response
/// final stream = client.responses.createStream(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: 'Tell me a story',
///   ),
/// );
///
/// await for (final event in stream) {
///   if (event is OutputTextDeltaEvent) {
///     stdout.write(event.delta);
///   }
/// }
/// ```
library;

export 'config/config.dart';
export 'content/content.dart';
export 'create_response_request.dart';
export 'incomplete_details.dart';
export 'input_token_count.dart';
export 'items/items.dart';
export 'response.dart';
export 'response_error.dart';
export 'response_usage.dart';
export 'streaming/streaming.dart';
export 'tools/tools.dart';
