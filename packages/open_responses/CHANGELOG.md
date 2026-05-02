## 0.4.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

Tracks [OpenResponses spec v2.3.0](https://www.openresponses.org/) ([openresponses#68](https://github.com/openresponses/openresponses/pull/68)) by adding response compaction, the assistant message phase, and broader output-item coverage. Adds `POST /responses/compact` via `ResponsesResource.compact()` along with new `CompactResource`, `CompactResponseRequest`, `CompactionItem` (input variant), and `CompactionOutputItem` (output variant) models. Adds `MessagePhase` (`commentary`/`final_answer`) with a new optional `phase` field on `AssistantMessageItem` and `MessageOutputItem` — required for follow-up requests on `gpt-5.3-codex` and similar models. Also adds `FunctionCallOutputResponseItem` so `OutputItem` covers all members of the spec's `ItemField` union, and supports `input_*` content parts in `MessageOutputItem.content` so echoed-back user messages in stored or compacted history parse correctly. **Breaking:** `MessageOutputItem.content` is retyped from `List<OutputContent>` to `List<MessageContentPart>` — type guards on leaf classes still narrow correctly, but callers that declare the intermediate list type must migrate.

- **BREAKING** **FEAT**: Add response compaction and assistant phase ([#214](https://github.com/davidmigloz/ai_clients_dart/issues/214)). ([af4bd2fe](https://github.com/davidmigloz/ai_clients_dart/commit/af4bd2fe1d177ce8705297e8be4fd6201c146435))

## 0.3.2

Adds support for [WebSocket mode](https://developers.openai.com/api/docs/guides/websocket-mode) in the Responses API via new `WebSocketResponseCreateEvent` and `WebSocketErrorEvent` types. The request wrapper composes an existing `CreateResponseRequest` with the required `response.create` discriminator and automatically strips the three HTTP-only fields (`background`, `stream`, `stream_options`) that must not be sent over WebSocket. Promotes the bundled OpenResponses spec to v2.3.0 ([openresponses#71](https://github.com/openresponses/openresponses/pull/71)).

- **FEAT**: Add WebSocket mode support ([#199](https://github.com/davidmigloz/ai_clients_dart/issues/199)). ([cb10f1d0](https://github.com/davidmigloz/ai_clients_dart/commit/cb10f1d0ad4a25d5b32e3139f80f171f58010e80))

## 0.3.1

Annotates `llms.txt` with per-link token counts and per-package totals so coding agents can budget context before fetching documentation, examples, or changelogs — inspired by Addy Osmani's [Agentic Engine Optimization](https://addyosmani.com/blog/agentic-engine-optimization/) article.

- **FEAT**: Annotate llms.txt with token counts and tighten agent-facing docs ([#181](https://github.com/davidmigloz/ai_clients_dart/issues/181)). ([a1e82aca](https://github.com/davidmigloz/ai_clients_dart/commit/a1e82acad8b713afc5d6d67d6e8d34937ac3f6a8))

## 0.3.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

The `InputFileContent.data()` factory now requires a `mediaType` parameter and constructs proper data URL format instead of passing raw base64 (which was rejected by the API). Also adds the missing `ReasoningItemParam` manifest entry and `copyWith` method to `ReasoningInputItem`.

- **BREAKING** **FEAT**: Require `mediaType` in `InputFileContent.data()` for data URL construction ([#152](https://github.com/davidmigloz/ai_clients_dart/issues/152)). ([821eea60](https://github.com/davidmigloz/ai_clients_dart/commit/821eea60a630daf17c14df3cf4c04ade8fe296b9))
- **FIX**: Add missing ReasoningItemParam manifest entry and copyWith ([#160](https://github.com/davidmigloz/ai_clients_dart/issues/160)). ([0752275b](https://github.com/davidmigloz/ai_clients_dart/commit/0752275b852ee2cb9efb345bf390f20bb1c4b1ad))
- **DOCS**: Overhaul root README and add semver bullet to all packages ([#151](https://github.com/davidmigloz/ai_clients_dart/issues/151)). ([e6af33dd](https://github.com/davidmigloz/ai_clients_dart/commit/e6af33dd9eee225777f9007b2da571da075c19d3))

## 0.2.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

Replaces the `ServiceTier` enum with an extensible class to preserve provider-specific tier values on round-trip serialization, aligning with the [provider-agnostic OpenResponses specification](https://github.com/openresponses/openresponses/issues/51). Also standardizes equality helper locations, overhauls README documentation with [llms.txt](llms.txt) ecosystem files, and aligns compliance tests with the official OpenResponses CLI test runner.

- **BREAKING** **FEAT**: Improve spec compliance for ServiceTier and ResponseError ([#133](https://github.com/davidmigloz/ai_clients_dart/issues/133)). ([487231d2](https://github.com/davidmigloz/ai_clients_dart/commit/487231d27677866f077ce7324d7003e8494e7261))
- **REFACTOR**: Standardize equality helpers location across packages ([#123](https://github.com/davidmigloz/ai_clients_dart/issues/123)). ([34086102](https://github.com/davidmigloz/ai_clients_dart/commit/340861028e0958a50bb142519046f26a8a569b7c))
- **DOCS**: Overhaul READMEs and add llms.txt ecosystem ([#149](https://github.com/davidmigloz/ai_clients_dart/issues/149)). ([98f11483](https://github.com/davidmigloz/ai_clients_dart/commit/98f114832f18f236ee4ab526ba2c34d53ad3d093))
- **TEST**: Align compliance tests with official CLI test runner ([#134](https://github.com/davidmigloz/ai_clients_dart/issues/134)). ([f7919790](https://github.com/davidmigloz/ai_clients_dart/commit/f79197903518800357d096d8fe3fd7e13ff53037))

## 0.1.5

Added `StreamingEventAccumulator` for assembling streamed response events into a complete response, convenience factories on `Item` for creating common message types (`userMessage`, `assistantMessage`, `functionCall`, etc.), and type-safe `ResponseInput` for building request input with compile-time safety. Also added `copyWith` methods to streaming events and several model classes.

- **FEAT**: Add streaming accumulator, convenience factories, and type-safe input ([#109](https://github.com/davidmigloz/ai_clients_dart/issues/109)). ([61ffa87c](https://github.com/davidmigloz/ai_clients_dart/commit/61ffa87cfda05bd884d41c230f6f9e276cc053dd))

## 0.1.4

This release adds inline streaming error detection for improved reliability when handling streamed responses.

- **FEAT**: Detect inline streaming errors ([#91](https://github.com/davidmigloz/ai_clients_dart/issues/91)). ([9f0eaf37](https://github.com/davidmigloz/ai_clients_dart/commit/9f0eaf37dfa2e1ce7d05c4d0ae1b00af2d8f78f6))
- **DOCS**: Improve READMEs with badges, sponsor section, and vertex_ai deprecation ([#90](https://github.com/davidmigloz/ai_clients_dart/issues/90)). ([5741f2f3](https://github.com/davidmigloz/ai_clients_dart/commit/5741f2f3bcecdc947235aa10e9a7534baef95741))

## 0.1.3

Internal improvements to build tooling and package publishing configuration.

- **REFACTOR**: Migrate API skills to the shared api-toolkit CLI ([#74](https://github.com/davidmigloz/ai_clients_dart/issues/74)). ([923cc83e](https://github.com/davidmigloz/ai_clients_dart/commit/923cc83e9d72be370b2af8580a41970604df0787))
- **CHORE**: Add .pubignore to exclude .agents/ and specs/ from publishing ([#78](https://github.com/davidmigloz/ai_clients_dart/issues/78)). ([0ff199bf](https://github.com/davidmigloz/ai_clients_dart/commit/0ff199bf9c7b4cc090cde73b994cca5ae5d3eaf9))

## 0.1.2

Added `baseUrl` and `defaultHeaders` parameters to `withApiKey` constructors and unified equality helpers across packages.

- **FEAT**: Add baseUrl and defaultHeaders to withApiKey constructors ([#57](https://github.com/davidmigloz/ai_clients_dart/issues/57)). ([f0dd0caa](https://github.com/davidmigloz/ai_clients_dart/commit/f0dd0caac1247e065e4add236d7a6dca38ceea56))
- **REFACTOR**: Unify equality_helpers.dart across packages ([#67](https://github.com/davidmigloz/ai_clients_dart/issues/67)). ([ec2897f8](https://github.com/davidmigloz/ai_clients_dart/commit/ec2897f8e5b5370a78e8b95832fde503cfaa5dd7))

## 0.1.1

Added `withApiKey` convenience constructor for simplified client initialization.

- **FEAT**: Add withApiKey convenience constructors ([#56](https://github.com/davidmigloz/ai_clients_dart/issues/56)). ([b06e3df3](https://github.com/davidmigloz/ai_clients_dart/commit/b06e3df31cea2228489525b68b7d0055f678fecc))
- **CHORE**: Bump googleapis from 15.0.0 to 16.0.0 and Dart SDK to 3.9.0 ([#52](https://github.com/davidmigloz/ai_clients_dart/issues/52)). ([eae130b7](https://github.com/davidmigloz/ai_clients_dart/commit/eae130b785d38074e85d460eefa9210f4acdf215))

## 0.1.0

Initial release of the OpenResponses Dart client.

### Features

- **Core Client**: `OpenResponsesClient` with configurable base URL and authentication
- **Response Creation**: `responses.create()` for non-streaming requests
- **Streaming**: `responses.createStream()` and `responses.stream()` with builder pattern
- **Multi-provider Support**: Works with OpenAI, Ollama, Hugging Face, OpenRouter, and LM Studio

### Request Features

- String or message item list input
- System instructions via `instructions` parameter
- Multi-turn conversations with `previousResponseId`
- Temperature and max output tokens control
- Service tier selection

### Tools

- `FunctionTool`: Define custom functions with JSON Schema parameters
- `McpTool`: Remote Model Context Protocol server tools
- Tool choice configuration (auto, required, specific function)

### Structured Output

- `TextConfig` with format options
- `JsonSchemaFormat` for structured JSON responses with strict mode
- `TextResponseFormat` and `JsonObjectFormat`

### Reasoning Models

- `ReasoningConfig` with effort levels (low, medium, high)
- Reasoning summary modes (concise, detailed, auto)
- Access to reasoning items via `response.reasoningItems`

### Streaming Events

- Full SSE event parsing with 25+ event types
- Response lifecycle events (created, queued, in_progress, completed, failed)
- Output item and content part events
- Text delta and done events
- Function call argument streaming
- Reasoning delta and summary events
- Error events

### Content Types

- `InputTextContent`: Text input
- `InputImageContent`: Image URLs with detail level
- `InputFileContent`: File references
- `OutputTextContent`: Text output with annotations
- `RefusalContent`: Model refusal messages

### Message Items

- `MessageItem` with role (user, assistant, system, developer)
- Convenience factories: `userText()`, `systemText()`, `assistantText()`
- `FunctionCallItem` and `FunctionCallOutputItem`
- `ItemReference` for referencing previous items

### DX Extensions

- `response.outputText`: Concatenated text from output
- `response.functionCalls`: All function call items
- `response.reasoningItems`: All reasoning items
- `response.hasToolCalls`, `response.isCompleted`, `response.isFailed`
- `event.textDelta`, `event.isFinal`
- `stream.text`, `stream.finalResponse`

### Error Handling

- `OpenResponsesException` sealed class hierarchy
- `ApiException` with error code and details
- `AuthenticationException` for auth failures
- `RateLimitException` with retry-after duration
- `ValidationException` for invalid requests
- `TimeoutException` and `AbortedException`

### Authentication

- `BearerTokenProvider` for API key authentication
- `NoAuthProvider` for local providers (Ollama, LM Studio)
- Extensible `AuthProvider` interface

### Configuration

- `OpenResponsesConfig` with base URL, auth, headers, timeout
- `RetryPolicy` with exponential backoff and jitter
- Custom HTTP client support

### Commits

- **FEAT**: Initial implementation of OpenResponses Dart client ([#10](https://github.com/davidmigloz/ai_clients_dart/issues/10)). ([4fac8fa6](https://github.com/davidmigloz/ai_clients_dart/commit/4fac8fa684be13fea30c96a9481c415c3a1a5f66))
- **FEAT**: Comprehensive model improvements with new features ([#16](https://github.com/davidmigloz/ai_clients_dart/issues/16)). ([6b6450a7](https://github.com/davidmigloz/ai_clients_dart/commit/6b6450a7a23987dd7ba67aacef16ad8f67d6898d))
- **FEAT**: Add SummaryTextContent for reasoning models ([#23](https://github.com/davidmigloz/ai_clients_dart/issues/23)). ([93ce0a00](https://github.com/davidmigloz/ai_clients_dart/commit/93ce0a008c8c8d065c7c4ba475d55d96756e5e54))
- **FEAT**: Add ReasoningInputItem, UnknownEvent, and provider aliases ([#28](https://github.com/davidmigloz/ai_clients_dart/issues/28)). ([e1fa0afe](https://github.com/davidmigloz/ai_clients_dart/commit/e1fa0afe20fc8c45a5ded1c360a1507a7fa0fa2c))
- **REFACTOR**: Align client package architecture across SDK packages ([#37](https://github.com/davidmigloz/ai_clients_dart/issues/37)). ([cf741ee1](https://github.com/davidmigloz/ai_clients_dart/commit/cf741ee12ac45667b86fe166b33dad37d85962b2))
- **REFACTOR**: Align API surface across all SDK packages ([#36](https://github.com/davidmigloz/ai_clients_dart/issues/36)). ([ed969cc7](https://github.com/davidmigloz/ai_clients_dart/commit/ed969cc7ad964da60702f2c97c14851ebe9aa992))
