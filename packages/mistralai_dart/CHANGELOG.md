## 3.0.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

Syncs with the 2026-04-22 Mistral AI spec: 9 endpoints and 20 schemas were removed upstream with no additions. **Breaking:** the entire OCR confidence-score surface has been removed server-side, so `OcrConfidenceScore`, `OcrPageConfidenceScores`, `OcrConfidenceScoresGranularity`, and the related fields on `OcrRequest`, `OcrPage`, and `OcrTable` are gone from the client. The orphan `WorkflowListResponse` model is also deleted along with its retired `GET /v1/workflows` endpoint. This release also adds missing `copyWith` methods on `ObservabilityError` and `ObservabilityErrorDetail`.

- **BREAKING** **FEAT**: Sync with 2026-04-22 spec; drop OCR confidence ([#201](https://github.com/davidmigloz/ai_clients_dart/issues/201)). ([f255b63b](https://github.com/davidmigloz/ai_clients_dart/commit/f255b63b5840f940897b5fc3d888e5a9fec77c22))
- **FIX**: Add missing copyWith to ObservabilityError models ([#202](https://github.com/davidmigloz/ai_clients_dart/issues/202)). ([5d0ecfb5](https://github.com/davidmigloz/ai_clients_dart/commit/5d0ecfb5472b670a515212b1cbf82dd787a50c7d))

## 2.3.0

Adds support for OCR confidence scores with a new `confidenceScoresGranularity` request parameter (`page` or `word`) and per-page/per-word score response types. Also fills pre-existing spec gaps on `OcrPage` (tables, header, footer, hyperlinks) and `OcrRequest` (tableFormat, extractHeader, extractFooter, annotation formats).

- **FEAT**: Update OpenAPI spec with OCR confidence scores ([#188](https://github.com/davidmigloz/ai_clients_dart/issues/188)). ([443d3318](https://github.com/davidmigloz/ai_clients_dart/commit/443d3318f758a9a583f8470e3548ff6f24f94473))
- **FEAT**: Annotate llms.txt with token counts and tighten agent-facing docs ([#181](https://github.com/davidmigloz/ai_clients_dart/issues/181)). ([a1e82aca](https://github.com/davidmigloz/ai_clients_dart/commit/a1e82acad8b713afc5d6d67d6e8d34937ac3f6a8))

## 2.2.0

Adds two new beta API domains — Observability (41 endpoints for campaigns, datasets, judges, and chat completion monitoring) and Workflows (34 endpoints for workflow execution, scheduling, deployments, and tracing). Refreshes the OpenAPI spec with 75 new endpoints and 126 new schemas.

- **FEAT**: Add Observability and Workflows beta APIs ([#179](https://github.com/davidmigloz/ai_clients_dart/issues/179)). ([1895a02b](https://github.com/davidmigloz/ai_clients_dart/commit/1895a02ba756e38d849f6e0e12a2b4aa9d0dd812))

## 2.1.1

Adds an `extra` overflow field to `SpeechRequest` for passing additional properties to the Mistral speech API, and aligns the README layout with other packages.

- **FIX**: Add extra field to SpeechRequest for additionalProperties ([#170](https://github.com/davidmigloz/ai_clients_dart/issues/170)). ([6f2c4d4c](https://github.com/davidmigloz/ai_clients_dart/commit/6f2c4d4c7216430799ea4ac9da294112dcb967d5))
- **DOCS**: Align README TIP position with other packages ([#172](https://github.com/davidmigloz/ai_clients_dart/issues/172)). ([a6562b99](https://github.com/davidmigloz/ai_clients_dart/commit/a6562b994889d1b4f310a78a09d1d3a99955873e))

## 2.1.0

Adds `ToolFileContentPart` and `ToolReferenceContentPart` sealed variants to `ContentPart` for built-in tool output content (code interpreter files, web search references). Also adds `unknown` fallback values to `ReasoningEffort` and `SpeechOutputFormat` enums for forward compatibility.

- **FEAT**: Add tool content parts and enum fallbacks ([#158](https://github.com/davidmigloz/ai_clients_dart/issues/158)). ([248a7051](https://github.com/davidmigloz/ai_clients_dart/commit/248a7051b7b92d1a623c5ef339075dd6893e318b))
- **DOCS**: Overhaul root README and add semver bullet to all packages ([#151](https://github.com/davidmigloz/ai_clients_dart/issues/151)). ([e6af33dd](https://github.com/davidmigloz/ai_clients_dart/commit/e6af33dd9eee225777f9007b2da571da075c19d3))

## 2.0.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

Major update to the latest Mistral AI spec. Renames `ModerationLLMV1Action` to `ModerationLLMAction`, adds Moderation V2 with 11 categories, guardrails on chat requests, `CustomConnectorTool`, 5 new `ContentPart` variants, and `UnknownContentPart` for forward compatibility. Replaces untyped `Object` fields with sealed union types (`MessageContent`, `EmbedInput`) for type safety across all `ChatMessage` variants. Adds [text-to-speech synthesis](https://mistral.ai/news/voxtral-tts) with streaming support, voice management with CRUD operations, `reasoningEffort` parameter, and [llms.txt](llms.txt) ecosystem files.

- **BREAKING** **FEAT**: Update to latest Mistral AI OpenAPI spec ([#130](https://github.com/davidmigloz/ai_clients_dart/issues/130)). ([ac07542b](https://github.com/davidmigloz/ai_clients_dart/commit/ac07542b073875bc111f74577846d6d35484e64a))
- **BREAKING** **REFACTOR**: Replace Object fields with sealed union types ([#119](https://github.com/davidmigloz/ai_clients_dart/issues/119)). ([014cc1dc](https://github.com/davidmigloz/ai_clients_dart/commit/014cc1dcf9cc5a29017caf9e050586d0bbc89e3f))
- **BREAKING** **FEAT**: Add TTS, voice management, and reasoning effort support ([#140](https://github.com/davidmigloz/ai_clients_dart/issues/140)). ([8c99bd48](https://github.com/davidmigloz/ai_clients_dart/commit/8c99bd480b3b96e75c910fcf0d9bc7a936ca66a5))
- **REFACTOR**: Standardize equality helpers location across packages ([#123](https://github.com/davidmigloz/ai_clients_dart/issues/123)). ([34086102](https://github.com/davidmigloz/ai_clients_dart/commit/340861028e0958a50bb142519046f26a8a569b7c))
- **DOCS**: Overhaul READMEs and add llms.txt ecosystem ([#149](https://github.com/davidmigloz/ai_clients_dart/issues/149)). ([98f11483](https://github.com/davidmigloz/ai_clients_dart/commit/98f114832f18f236ee4ab526ba2c34d53ad3d093))
- **TEST**: Add TTS and voice integration tests ([#148](https://github.com/davidmigloz/ai_clients_dart/issues/148)). ([f0ec0879](https://github.com/davidmigloz/ai_clients_dart/commit/f0ec08799fc81a6546b0bbf49df87530faea1f95))
- **CHORE**: Clean up documentation.json configs and lift fineTuningModels exclusion ([#117](https://github.com/davidmigloz/ai_clients_dart/issues/117)). ([fdd03bf2](https://github.com/davidmigloz/ai_clients_dart/commit/fdd03bf2ec41b116fb0cb25eb1bf994a4e1c4100))

## 1.3.0

This release adds inline streaming error detection and updates the API spec to the latest version with new models and capabilities including agent aliases, guardrail configuration, tool call confirmations, and batch request types.

- **FEAT**: Detect inline streaming errors ([#91](https://github.com/davidmigloz/ai_clients_dart/issues/91)). ([9f0eaf37](https://github.com/davidmigloz/ai_clients_dart/commit/9f0eaf37dfa2e1ce7d05c4d0ae1b00af2d8f78f6))
- **FEAT**: Update OpenAPI spec with new models (`AgentAliasResponse`, `BatchRequest`, `GuardrailConfig`, `ToolCallConfirmation`, `ToolConfiguration`), add agent alias CRUD methods, and update existing models with new fields ([#89](https://github.com/davidmigloz/ai_clients_dart/issues/89)). ([4aa455e7](https://github.com/davidmigloz/ai_clients_dart/commit/4aa455e736f0a33352c9984bd44e7a61924f7cc6))
- **DOCS**: Improve READMEs with badges, sponsor section, and vertex_ai deprecation ([#90](https://github.com/davidmigloz/ai_clients_dart/issues/90)). ([5741f2f3](https://github.com/davidmigloz/ai_clients_dart/commit/5741f2f3bcecdc947235aa10e9a7534baef95741))

## 1.2.1

Internal improvements to build tooling and package publishing configuration.

- **REFACTOR**: Migrate API skills to the shared api-toolkit CLI ([#74](https://github.com/davidmigloz/ai_clients_dart/issues/74)). ([923cc83e](https://github.com/davidmigloz/ai_clients_dart/commit/923cc83e9d72be370b2af8580a41970604df0787))
- **CHORE**: Add .pubignore to exclude .agents/ and specs/ from publishing ([#78](https://github.com/davidmigloz/ai_clients_dart/issues/78)). ([0ff199bf](https://github.com/davidmigloz/ai_clients_dart/commit/0ff199bf9c7b4cc090cde73b994cca5ae5d3eaf9))

## 1.2.0

Added `baseUrl` and `defaultHeaders` parameters to `withApiKey` constructors and unified equality helpers across packages.

- **FEAT**: Add baseUrl and defaultHeaders to withApiKey constructors ([#57](https://github.com/davidmigloz/ai_clients_dart/issues/57)). ([f0dd0caa](https://github.com/davidmigloz/ai_clients_dart/commit/f0dd0caac1247e065e4add236d7a6dca38ceea56))
- **REFACTOR**: Unify equality_helpers.dart across packages ([#67](https://github.com/davidmigloz/ai_clients_dart/issues/67)). ([ec2897f8](https://github.com/davidmigloz/ai_clients_dart/commit/ec2897f8e5b5370a78e8b95832fde503cfaa5dd7))

## 1.1.0

Added `withApiKey` convenience constructor and replaced `Object? stop` with a type-safe `StopSequence` sealed class for improved API safety.

- **FEAT**: Add withApiKey convenience constructors ([#56](https://github.com/davidmigloz/ai_clients_dart/issues/56)). ([b06e3df3](https://github.com/davidmigloz/ai_clients_dart/commit/b06e3df31cea2228489525b68b7d0055f678fecc))
- **REFACTOR**: Replace `Object? stop` with `StopSequence` sealed class ([#53](https://github.com/davidmigloz/ai_clients_dart/issues/53)). ([b6313f54](https://github.com/davidmigloz/ai_clients_dart/commit/b6313f541b28625cdabec3b9fbe7d90db37ecf24))
- **CHORE**: Bump googleapis from 15.0.0 to 16.0.0 and Dart SDK to 3.9.0 ([#52](https://github.com/davidmigloz/ai_clients_dart/issues/52)). ([eae130b7](https://github.com/davidmigloz/ai_clients_dart/commit/eae130b785d38074e85d460eefa9210f4acdf215))
- **CI**: Add GitHub Actions test workflow ([#50](https://github.com/davidmigloz/ai_clients_dart/issues/50)). ([6c5f079a](https://github.com/davidmigloz/ai_clients_dart/commit/6c5f079ac94e78cad66071ad9eb8ad51db974695))

## 1.0.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

**TL;DR**: Complete reimplementation with a new architecture, minimal dependencies, resource-based API, and improved developer experience. Hand-crafted models (no code generation), interceptor-driven architecture, comprehensive error handling, and full Mistral AI API coverage including stable and beta endpoints.

### What's new

- **Resource-based API organization**:
  - `client.chat` — Chat completions (streaming, tool calling, multimodal, JSON mode)
  - `client.embeddings` — Text embeddings for semantic search and clustering
  - `client.models` — Model listing and retrieval
  - `client.fim` — Fill-in-the-Middle code completions (Codestral)
  - `client.files` — File upload and management
  - `client.fineTuning` — Fine-tuning jobs and model management
  - `client.batch` — Asynchronous large-scale batch processing
  - `client.moderations` — Content moderation for safety
  - `client.classifications` — Text classification (spam, topic, sentiment)
  - `client.ocr` — OCR for documents and images
  - `client.audio` — Speech-to-text transcription with streaming
  - `client.agents` — Pre-configured AI assistants (beta)
  - `client.conversations` — Stateful multi-turn conversations (beta)
  - `client.libraries` — Document storage and retrieval for RAG (beta)
- **Architecture**:
  - Interceptor chain (Auth → Logging → Error → Transport with Retry wrapper).
  - **Authentication**: API key or custom via `AuthProvider` interface.
  - **Retry** with exponential backoff + jitter (only for idempotent methods on 429, 5xx, timeouts).
  - **Abortable** requests via `abortTrigger` parameter.
  - **SSE** streaming parser for real-time responses with `[DONE]` marker handling.
  - Central `MistralConfig` (timeouts, retry policy, log level, baseUrl, auth).
- **Hand-crafted models**:
  - No code generation dependencies (no freezed, json_serializable).
  - Minimal runtime dependencies (`http`, `logging` only).
  - Immutable models with `copyWith` using sentinel pattern for nullable fields.
  - Full type safety with sealed exception hierarchy.
  - Sealed classes for polymorphic types (`ChatMessage`, `ContentPart`, `ToolChoice`, `ResponseFormat`, `Tool`, `OcrDocument`).
- **Improved DX**:
  - Named constructors for common patterns (e.g., `ChatMessage.user()`, `ChatMessage.system()`, `Tool.function()`, `Tool.webSearch()`).
  - Explicit streaming methods (`createStream()` vs `create()`).
  - Extension methods for convenient response access (`response.text`, `response.toolCalls`, `response.hasToolCalls`).
  - Rich logging with field redaction for sensitive data.
  - Pagination utilities (`Paginator`) and job polling helpers (`FineTuningJobPoller`, `BatchJobPoller`).
- **Full API coverage**:
  - Chat completions with tool calling, multimodal inputs, and JSON schema validation.
  - Fill-in-the-Middle (FIM) code completions with streaming.
  - Text embeddings with dimension control and quantization options.
  - File management (upload, download, signed URLs).
  - Fine-tuning with hyperparameter control and W&B integration.
  - Batch processing for large-scale async operations.
  - Content moderation and text classification.
  - OCR for PDFs and images with markdown output.
  - Audio transcription with word-level timestamps.
  - Agents with built-in tools (web search, code interpreter, image generation).
  - Stateful conversations with context management.
  - Document libraries for RAG workflows.

See **[MIGRATION.md](MIGRATION.md)** for step-by-step examples and mapping tables.

### Commits

- **BREAKING** **FEAT**: Complete v1.0.0 reimplementation ([#8](https://github.com/davidmigloz/ai_clients_dart/issues/8)). ([e18581e5](https://github.com/davidmigloz/ai_clients_dart/commit/e18581e574e42a97fe7139a8c9cf6c573c51b487))
- **FEAT**: Update README and add classification/moderation examples ([#15](https://github.com/davidmigloz/ai_clients_dart/issues/15)). ([88b2064c](https://github.com/davidmigloz/ai_clients_dart/commit/88b2064c6002ad489ed7536d55a7ec8d659661c7))
- **FIX**: Pre-release documentation and code fixes ([#44](https://github.com/davidmigloz/ai_clients_dart/issues/44)). ([93c78871](https://github.com/davidmigloz/ai_clients_dart/commit/93c78871a9826eb6f7c8146d643d46cbfee5bc9b))
- **REFACTOR**: Align client package architecture across SDK packages ([#37](https://github.com/davidmigloz/ai_clients_dart/issues/37)). ([cf741ee1](https://github.com/davidmigloz/ai_clients_dart/commit/cf741ee12ac45667b86fe166b33dad37d85962b2))
- **REFACTOR**: Align API surface across all SDK packages ([#36](https://github.com/davidmigloz/ai_clients_dart/issues/36)). ([ed969cc7](https://github.com/davidmigloz/ai_clients_dart/commit/ed969cc7ad964da60702f2c97c14851ebe9aa992))
- **DOCS**: Refactors repository URLs to new location. ([76835268](https://github.com/davidmigloz/ai_clients_dart/commit/768352686cdc91529fd7d37a288d69a28cc825f9))

## 0.1.1+1

- **FIX**: Fix streaming tool calls deserialization error ([#913](https://github.com/davidmigloz/langchain_dart/issues/913)) ([#914](https://github.com/davidmigloz/langchain_dart/issues/914)). ([ec4d20bf](https://github.com/davidmigloz/langchain_dart/commit/ec4d20bfd966a6c04ab44d47fd9baa175343a990))

## 0.1.1

- **FEAT**: Align Chat API with latest Mistral spec ([#887](https://github.com/davidmigloz/langchain_dart/issues/887)). ([b5a12301](https://github.com/davidmigloz/langchain_dart/commit/b5a1230184e79df5cef1256527eebd352d1a3f6a))
- **FEAT**: Align embeddings API with latest Mistral spec ([#886](https://github.com/davidmigloz/langchain_dart/issues/886)). ([769edc49](https://github.com/davidmigloz/langchain_dart/commit/769edc4937ac611b9c8d4b65421e403012f565a1))

## 0.1.0+1

- **REFACTOR**: Fix pub format warnings ([#809](https://github.com/davidmigloz/langchain_dart/issues/809)). ([640cdefb](https://github.com/davidmigloz/langchain_dart/commit/640cdefbede9c0a0182fb6bb4005a20aa6f35635))

## 0.1.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

- **FIX**: Add missing usage field to ChatCompletionStreamResponse in mistralai_dart ([#795](https://github.com/davidmigloz/langchain_dart/issues/795)). ([4da75561](https://github.com/davidmigloz/langchain_dart/commit/4da75561b173313479f50441bf318bd4b948032d))
- **FIX**: Handle optional space after colon in SSE parser in mistralai_dart ([#791](https://github.com/davidmigloz/langchain_dart/issues/791)). ([cefb1d2f](https://github.com/davidmigloz/langchain_dart/commit/cefb1d2f124ba64da60e3f33ec16672542cae28c))
- **FEAT**: Upgrade to http v1.5.0 ([#785](https://github.com/davidmigloz/langchain_dart/issues/785)). ([f7c87790](https://github.com/davidmigloz/langchain_dart/commit/f7c8779011015b5a4a7f3a07dca32bde1bb2ea88))
- **BREAKING** **BUILD**: Require Dart >=3.8.0 ([#792](https://github.com/davidmigloz/langchain_dart/issues/792)). ([b887f5c6](https://github.com/davidmigloz/langchain_dart/commit/b887f5c62e307b3a510c5049e3d1fbe7b7b4f4c9))

## 0.0.6

- **FEAT**: Migrate to Freezed v3 ([#773](https://github.com/davidmigloz/langchain_dart/issues/773)). ([f87c8c03](https://github.com/davidmigloz/langchain_dart/commit/f87c8c03711ef382d2c9de19d378bee92e7631c1))

## 0.0.5

- **BUILD**: Update dependencies ([#751](https://github.com/davidmigloz/langchain_dart/issues/751)). ([250a3c6](https://github.com/davidmigloz/langchain_dart/commit/250a3c6a6c1815703a61a142ba839c0392a31015))

## 0.0.4

- **FEAT**: Update dependencies (requires Dart 3.6.0) ([#709](https://github.com/davidmigloz/langchain_dart/issues/709)). ([9e3467f7](https://github.com/davidmigloz/langchain_dart/commit/9e3467f7caabe051a43c0eb3c1110bc4a9b77b81))
- **REFACTOR**: Remove fetch_client dependency in favor of http v1.3.0 ([#659](https://github.com/davidmigloz/langchain_dart/issues/659)). ([0e0a685c](https://github.com/davidmigloz/langchain_dart/commit/0e0a685c376895425dbddb0f9b83758c700bb0c7))
- **FIX**: Fix linter issues ([#656](https://github.com/davidmigloz/langchain_dart/issues/656)). ([88a79c65](https://github.com/davidmigloz/langchain_dart/commit/88a79c65aad23bcf5859e58a7375a4b686cf02ef))

## 0.0.3+4

- **REFACTOR**: Add new lint rules and fix issues ([#621](https://github.com/davidmigloz/langchain_dart/issues/621)). ([60b10e00](https://github.com/davidmigloz/langchain_dart/commit/60b10e008acf55ebab90789ad08d2449a44b69d8))
- **REFACTOR**: Upgrade api clients generator version ([#610](https://github.com/davidmigloz/langchain_dart/issues/610)). ([0c8750e8](https://github.com/davidmigloz/langchain_dart/commit/0c8750e85b34764f99b6e34cc531776ffe8fba7c))

## 0.0.3+3

- **REFACTOR**: Migrate conditional imports to js_interop ([#453](https://github.com/davidmigloz/langchain_dart/issues/453)). ([a6a78cfe](https://github.com/davidmigloz/langchain_dart/commit/a6a78cfe05fb8ce68e683e1ad4395ca86197a6c5))

## 0.0.3+2

- **FIX**: Fix deserialization of sealed classes ([#435](https://github.com/davidmigloz/langchain_dart/issues/435)). ([7b9cf223](https://github.com/davidmigloz/langchain_dart/commit/7b9cf223e42eae8496f864ad7ef2f8d0dca45678))

## 0.0.3+1

- **FIX**: Have the == implementation use Object instead of dynamic ([#334](https://github.com/davidmigloz/langchain_dart/issues/334)). ([89f7b0b9](https://github.com/davidmigloz/langchain_dart/commit/89f7b0b94144c216de19ec7244c48f3c34c2c635))

## 0.0.3

- **FEAT**: Update meta and test dependencies ([#331](https://github.com/davidmigloz/langchain_dart/issues/331)). ([912370ee](https://github.com/davidmigloz/langchain_dart/commit/912370ee0ba667ee9153303395a457e6caf5c72d))
- **DOCS**: Update pubspecs. ([d23ed89a](https://github.com/davidmigloz/langchain_dart/commit/d23ed89adf95a34a78024e2f621dc0af07292f44))

## 0.0.2+3

- **DOCS**: Update CHANGELOG.md. ([d0d46534](https://github.com/davidmigloz/langchain_dart/commit/d0d46534565d6f52d819d62329e8917e00bc7030))

## 0.0.2+2

- **REFACTOR**: Update safe_mode and max temperature in Mistral chat ([#300](https://github.com/davidmigloz/langchain_dart/issues/300)). ([1a4ccd1e](https://github.com/davidmigloz/langchain_dart/commit/1a4ccd1e7d1907e340ce609cc6ba8d0543ee3421))

## 0.0.2+1

- **REFACTOR**: Make all LLM options fields nullable and add copyWith ([#284](https://github.com/davidmigloz/langchain_dart/issues/284)). ([57eceb9b](https://github.com/davidmigloz/langchain_dart/commit/57eceb9b47da42cf19f64ddd88bfbd2c9676fd5e))

## 0.0.2

 - Update a dependency to the latest release.

## 0.0.1+1

- **FIX**: Fetch web requests with big payloads dropping connection ([#273](https://github.com/davidmigloz/langchain_dart/issues/273)). ([425889dc](https://github.com/davidmigloz/langchain_dart/commit/425889dc24a74790a7072c75f0bdb0d19ab40cf6))

## 0.0.1

- **FEAT**: Implement Dart client for Mistral AI API ([#261](https://github.com/davidmigloz/langchain_dart/issues/261)). ([f4954c59](https://github.com/davidmigloz/langchain_dart/commit/f4954c59f17c6427d554db7b380073302fb08175))

## 0.0.1-dev.1

- Bootstrap project.
