## 2.6.1

Maintenance release with no functional changes: the only commit touching this package since 2.6.0 reformatted its integration tests as part of a cross-package formatter update. No library code, API, or dependency changed.

- **FIX**: Serialize Gemini embedding config ([#298](https://github.com/davidmigloz/ai_clients_dart/issues/298)). ([d5b710b4](https://github.com/davidmigloz/ai_clients_dart/commit/d5b710b488dc8d6a47eda8660dafc7a15e3400a2))

## 2.6.0

Adds the official `thinking` field to `ChatMessage`, so a model's reasoning trace can be replayed in the follow-up assistant message. Ollama's tool-calling guidance requires accumulated thinking, content, and tool calls to be sent back together, but the thinking trace was previously dropped from chat history. Set it via `ChatMessage.assistant(content, thinking: ...)`; it round-trips through JSON and is covered by `==`, `hashCode`, and `toString`.

- **FIX**: Support assistant thinking replay ([#296](https://github.com/davidmigloz/ai_clients_dart/issues/296)). ([b10c8fdd](https://github.com/davidmigloz/ai_clients_dart/commit/b10c8fdd18011a249f63f0fcf231b885d45a3184))

## 2.5.0

Adds `renderer` and `parser` to `CreateRequest`, matching the upstream OpenAPI spec's new tool-calling prompt renderer (e.g. `qwen3.5`) and output parser (e.g. `harmony`) fields. Also adds client-ahead fields for full [`api/types.go`](https://github.com/ollama/ollama/blob/main/api/types.go) parity that the spec still omits — `files`/`adapters` (filename → SHA256 digest maps, per the [Create a Model docs](https://github.com/ollama/ollama/blob/main/docs/api.md#create-a-model)) for creating models from GGUF/Safetensors and LoRA adapters, plus `draftQuantize`/`draftFiles`, `remoteHost`, `requires`, and `info`. Also fixes `CreateRequest`'s `==`/`hashCode`/`toString` contract, which previously only compared `model`, to cover all 18 fields with content-based map/list equality.

- **FEAT**: CreateRequest renderer/parser and files/adapters ([#285](https://github.com/davidmigloz/ai_clients_dart/issues/285)). ([c8a61de9](https://github.com/davidmigloz/ai_clients_dart/commit/c8a61de97e41e44663786f946a8a9a259e71e435))

## 2.4.0

Adds the new `max` thinking level (`ThinkLevel.max`), matching Ollama's spec update that added `"max"` to the `think` enum on `ChatRequest` and `GenerateRequest` — use `ChatRequest(..., think: ThinkWithLevel(ThinkLevel.max))` to request the highest thinking level on supported reasoning models. Also fixes `buildUrl` producing a double slash (`//api/...`) when `OllamaConfig.baseUrl` (or `OLLAMA_HOST`) has a trailing slash, and preserves base-URL query params (including repeated keys) that were previously dropped — proxy setups with tokens in the base URL now work correctly.

- **FEAT**: Add "max" thinking level ([#267](https://github.com/davidmigloz/ai_clients_dart/issues/267)). ([8061f857](https://github.com/davidmigloz/ai_clients_dart/commit/8061f857587bb37506da0514b1e0b6376f6c950b))
- **FIX**: Avoid double slash and preserve base URL query params in buildUrl ([#273](https://github.com/davidmigloz/ai_clients_dart/issues/273)). ([7686e397](https://github.com/davidmigloz/ai_clients_dart/commit/7686e397bc0c30b6dd6df50862273416ffda54a7))

## 2.3.0

Adds experimental image generation to the `/api/generate` endpoint: `GenerateRequest` gains `width`/`height`/`steps`, and `GenerateResponse` and the streaming `GenerateStreamEvent` gain `image` (base64), `completed`, and `total` for diffusion progress. These fields are implemented client-side ahead of the upstream spec, which keeps them out of `openapi.yaml` while they remain experimental. Also adds the `draftNumPredict` model option to `ModelOptions` and completes the previously-partial `==`/`hashCode`/`toString` contracts on `GenerateStreamEvent` and `ChatStreamEvent`, which had compared only a subset of fields.

- **FEAT**: Add experimental image generation and draft_num_predict option ([#254](https://github.com/davidmigloz/ai_clients_dart/issues/254)). ([04b901a3](https://github.com/davidmigloz/ai_clients_dart/commit/04b901a3d02e615ad13f549ce03bb9955660ee5c))

## 2.2.0

Fixes browser usage (Flutter Web / dart2wasm) by no longer sending the non-CORS-safelisted `X-Request-ID` header by default — Ollama's `Access-Control-Allow-Headers` list excludes it, so the preflight previously failed and blocked all browser requests against a real Ollama server. A request ID is still generated internally for logging, error correlation, and retry/abort tracing; the new `OllamaConfig(sendRequestIdHeader: true)` opt-in restores the wire header for callers behind a proxy configured to accept it, and an `X-Request-ID` set explicitly via `defaultHeaders` is always sent.

- **FEAT**: Make X-Request-ID header opt-in to fix browser CORS ([#228](https://github.com/davidmigloz/ai_clients_dart/issues/228)). ([f497a722](https://github.com/davidmigloz/ai_clients_dart/commit/f497a7226a2e11fb7ab9dd55f22202f9136d9ab8))

## 2.1.0

Annotates `llms.txt` with per-link token counts and per-package totals so coding agents can budget context before fetching documentation, examples, or changelogs — inspired by Addy Osmani's [Agentic Engine Optimization](https://addyosmani.com/blog/agentic-engine-optimization/) article.

- **FEAT**: Annotate llms.txt with token counts and tighten agent-facing docs ([#181](https://github.com/davidmigloz/ai_clients_dart/issues/181)). ([a1e82aca](https://github.com/davidmigloz/ai_clients_dart/commit/a1e82acad8b713afc5d6d67d6e8d34937ac3f6a8))

## 2.0.1

Adds a strict semver bullet to the package README.

- **DOCS**: Overhaul root README and add semver bullet to all packages ([#151](https://github.com/davidmigloz/ai_clients_dart/issues/151)). ([e6af33dd](https://github.com/davidmigloz/ai_clients_dart/commit/e6af33dd9eee225777f9007b2da571da075c19d3))

## 2.0.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

Replaces untyped `Object`/`Object?` fields with sealed union types (`KeepAlive`, `EmbedInput`, `StopSequence`) for improved type safety across request models. Also adds a `name` field to `RunningModel` from the upstream Ollama API update and overhauls README documentation with [llms.txt](llms.txt) ecosystem files.

- **BREAKING** **REFACTOR**: Replace Object fields with sealed union types ([#120](https://github.com/davidmigloz/ai_clients_dart/issues/120)). ([5d7a4f24](https://github.com/davidmigloz/ai_clients_dart/commit/5d7a4f245f9c229bcb3df51c71fdd05658cdacfc))
- **FEAT**: Add name field to RunningModel and update spec ([#142](https://github.com/davidmigloz/ai_clients_dart/issues/142)). ([4fc2e1bb](https://github.com/davidmigloz/ai_clients_dart/commit/4fc2e1bb74a21339efb014cb9ce35e2296a13fcc))
- **DOCS**: Overhaul READMEs and add llms.txt ecosystem ([#149](https://github.com/davidmigloz/ai_clients_dart/issues/149)). ([98f11483](https://github.com/davidmigloz/ai_clients_dart/commit/98f114832f18f236ee4ab526ba2c34d53ad3d093))

## 1.4.1

Fixed verification warnings in generated model classes.

- **FIX**: Resolve verification warnings ([#98](https://github.com/davidmigloz/ai_clients_dart/issues/98)). ([da231740](https://github.com/davidmigloz/ai_clients_dart/commit/da23174033da808336b35be4a00638b9666e3d43))

## 1.4.0

This release adds inline streaming error detection for improved reliability when handling streamed responses.

- **FEAT**: Detect inline streaming errors ([#91](https://github.com/davidmigloz/ai_clients_dart/issues/91)). ([9f0eaf37](https://github.com/davidmigloz/ai_clients_dart/commit/9f0eaf37dfa2e1ce7d05c4d0ae1b00af2d8f78f6))
- **DOCS**: Improve READMEs with badges, sponsor section, and vertex_ai deprecation ([#90](https://github.com/davidmigloz/ai_clients_dart/issues/90)). ([5741f2f3](https://github.com/davidmigloz/ai_clients_dart/commit/5741f2f3bcecdc947235aa10e9a7534baef95741))

## 1.3.0

Added missing fields to chat, completion, and model response models.

- **FEAT**: Add missing fields to response models ([#80](https://github.com/davidmigloz/ai_clients_dart/issues/80)). ([73e44241](https://github.com/davidmigloz/ai_clients_dart/commit/73e442418dcf67b01324225ce826e285b4028c48))

## 1.2.1

Internal improvements to build tooling and package publishing configuration.

- **REFACTOR**: Migrate API skills to the shared api-toolkit CLI ([#74](https://github.com/davidmigloz/ai_clients_dart/issues/74)). ([923cc83e](https://github.com/davidmigloz/ai_clients_dart/commit/923cc83e9d72be370b2af8580a41970604df0787))
- **CHORE**: Add .pubignore to exclude .agents/ and specs/ from publishing ([#78](https://github.com/davidmigloz/ai_clients_dart/issues/78)). ([0ff199bf](https://github.com/davidmigloz/ai_clients_dart/commit/0ff199bf9c7b4cc090cde73b994cca5ae5d3eaf9))

## 1.2.0

Added `baseUrl` and `defaultHeaders` parameters to `withApiKey` constructors, fixed `hashCode` for list fields, and unified equality helpers.

- **FEAT**: Add baseUrl and defaultHeaders to withApiKey constructors ([#57](https://github.com/davidmigloz/ai_clients_dart/issues/57)). ([f0dd0caa](https://github.com/davidmigloz/ai_clients_dart/commit/f0dd0caac1247e065e4add236d7a6dca38ceea56))
- **FIX**: Use Object.hashAll() for list fields in hashCode ([#65](https://github.com/davidmigloz/ai_clients_dart/issues/65)). ([4b19abd9](https://github.com/davidmigloz/ai_clients_dart/commit/4b19abd99904d4409fd729a631ff510a02f2c3bc))
- **REFACTOR**: Unify equality_helpers.dart across packages ([#67](https://github.com/davidmigloz/ai_clients_dart/issues/67)). ([ec2897f8](https://github.com/davidmigloz/ai_clients_dart/commit/ec2897f8e5b5370a78e8b95832fde503cfaa5dd7))

## 1.1.0

Added `withApiKey` convenience constructor for simplified client initialization.

- **FEAT**: Add withApiKey convenience constructors ([#56](https://github.com/davidmigloz/ai_clients_dart/issues/56)). ([b06e3df3](https://github.com/davidmigloz/ai_clients_dart/commit/b06e3df31cea2228489525b68b7d0055f678fecc))
- **CHORE**: Bump googleapis from 15.0.0 to 16.0.0 and Dart SDK to 3.9.0 ([#52](https://github.com/davidmigloz/ai_clients_dart/issues/52)). ([eae130b7](https://github.com/davidmigloz/ai_clients_dart/commit/eae130b785d38074e85d460eefa9210f4acdf215))
- **CI**: Add GitHub Actions test workflow ([#50](https://github.com/davidmigloz/ai_clients_dart/issues/50)). ([6c5f079a](https://github.com/davidmigloz/ai_clients_dart/commit/6c5f079ac94e78cad66071ad9eb8ad51db974695))

## 1.0.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

**TL;DR**: Complete reimplementation with a new architecture, minimal dependencies, resource-based API, and improved developer experience. Hand-crafted models (no code generation), interceptor-driven architecture, comprehensive error handling, and full Ollama API coverage.

### What's new

- **Resource-based API organization**:
  - `client.chat` — Chat completions (multi-turn conversations)
  - `client.completions` — Text generation (single-turn)
  - `client.embeddings` — Generate text embeddings
  - `client.models` — Model management (list, show, pull, push, copy, delete, create, ps)
  - `client.version` — Server version info
- **Architecture**:
  - Interceptor chain (Auth → Logging → Error → Transport with Retry wrapper).
  - **Authentication**: Bearer token or custom via `AuthProvider` interface.
  - **Retry** with exponential backoff + jitter (only for idempotent methods on 429, 5xx, timeouts).
  - **Abortable** requests via `abortTrigger` parameter.
  - **NDJSON** streaming parser for real-time responses.
  - Central `OllamaConfig` (timeouts, retry policy, log level, baseUrl, auth).
- **Hand-crafted models**:
  - No code generation dependencies (no freezed, json_serializable).
  - Minimal runtime dependencies (`http`, `logging` only).
  - Immutable models with `copyWith` using sentinel pattern.
  - Full type safety with sealed exception hierarchy.
- **Type-safe enums and sealed classes**:
  - `DoneReason` enum for completion stop reasons (`stop`, `length`, `load`, `unload`).
  - `ThinkValue` sealed class for thinking mode (`ThinkEnabled`, `ThinkWithLevel`).
  - `ResponseFormat` sealed class for format options (`JsonFormat`, `SchemaFormat`).
  - `MessageRole` enum for message roles (`system`, `user`, `assistant`, `tool`).
- **Improved DX**:
  - Simplified model names (e.g., `ChatRequest` instead of `GenerateChatCompletionRequest`).
  - Named constructors for common patterns (e.g., `ChatMessage.user()`, `ChatMessage.system()`).
  - Explicit streaming methods (`createStream()` vs `create()`).
  - Rich logging with field redaction for sensitive data.
- **Full API coverage**:
  - Chat completions with tool calling support.
  - Text completions with thinking mode.
  - Embeddings generation.
  - Model management (list, show, create, copy, delete, pull, push, ps).
  - Server version info.

### Breaking Changes

- **Resource-based API**: Methods reorganized under strongly-typed resources:
  - `client.generateChatCompletion()` → `client.chat.create()`
  - `client.generateChatCompletionStream()` → `client.chat.createStream()`
  - `client.generateCompletion()` → `client.completions.generate()`
  - `client.generateCompletionStream()` → `client.completions.generateStream()`
  - `client.generateEmbedding()` → `client.embeddings.create()`
  - `client.listModels()` → `client.models.list()`
  - `client.showModelInfo()` → `client.models.show()`
  - `client.listRunningModels()` → `client.models.ps()`
  - `client.getVersion()` → `client.version.get()`
- **Model class renames**:
  - `GenerateChatCompletionRequest` → `ChatRequest`
  - `GenerateChatCompletionResponse` → `ChatResponse`
  - `GenerateCompletionRequest` → `GenerateRequest`
  - `GenerateCompletionResponse` → `GenerateResponse`
  - `GenerateEmbeddingRequest` → `EmbedRequest`
  - `GenerateEmbeddingResponse` → `EmbedResponse`
  - `Message` → `ChatMessage`
  - `Tool` → `ToolDefinition`
  - `RequestOptions` → `ModelOptions`
- **Configuration**: New `OllamaConfig` with `AuthProvider` pattern.
- **Exceptions**: Replaced `OllamaClientException` with typed hierarchy:
  - `ApiException`, `ValidationException`, `RateLimitException`, `TimeoutException`, `AbortedException`.
- **Dependencies**: Removed `freezed`, `json_serializable`; now minimal (`http`, `logging`).
- **Base URL**: No longer needs `/api` suffix — just use `http://localhost:11434`.

See **[MIGRATION.md](MIGRATION.md)** for step-by-step examples and mapping tables.

### Commits

- **BREAKING** **FEAT**: Complete v1.0.0 reimplementation ([#1](https://github.com/davidmigloz/ai_clients_dart/issues/1)). ([0ff41032](https://github.com/davidmigloz/ai_clients_dart/commit/0ff410326a005f86cc32682d75ae8163cb0bbd2f))
- **FEAT**: Add type-safe enums and sealed classes ([#22](https://github.com/davidmigloz/ai_clients_dart/issues/22)). ([73372581](https://github.com/davidmigloz/ai_clients_dart/commit/733725817cc7c7ce68de135af84e5e2d7f042e62))
- **FIX**: Pre-release documentation and code fixes ([#45](https://github.com/davidmigloz/ai_clients_dart/issues/45)). ([b33ae6d5](https://github.com/davidmigloz/ai_clients_dart/commit/b33ae6d5239892e3c2aed4d457667919cccd7796))
- **REFACTOR**: Align client package architecture across SDK packages ([#37](https://github.com/davidmigloz/ai_clients_dart/issues/37)). ([cf741ee1](https://github.com/davidmigloz/ai_clients_dart/commit/cf741ee12ac45667b86fe166b33dad37d85962b2))
- **REFACTOR**: Align API surface across all SDK packages ([#36](https://github.com/davidmigloz/ai_clients_dart/issues/36)). ([ed969cc7](https://github.com/davidmigloz/ai_clients_dart/commit/ed969cc7ad964da60702f2c97c14851ebe9aa992))
- **REFACTOR**: Extract streaming helpers to StreamingResource mixin ([#2](https://github.com/davidmigloz/ai_clients_dart/issues/2)). ([0b6f0ed9](https://github.com/davidmigloz/ai_clients_dart/commit/0b6f0ed9cea3f2b9e4c06e9b0f494cb582646d0b))
- **DOCS**: Refactors repository URLs to new location. ([76835268](https://github.com/davidmigloz/ai_clients_dart/commit/768352686cdc91529fd7d37a288d69a28cc825f9))

## 0.3.0+1

- **REFACTOR**: Fix pub format warnings ([#809](https://github.com/davidmigloz/langchain_dart/issues/809)). ([640cdefb](https://github.com/davidmigloz/langchain_dart/commit/640cdefbede9c0a0182fb6bb4005a20aa6f35635))

## 0.3.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

- **FEAT**: Enhance CreateModelRequest with new fields ([#802](https://github.com/davidmigloz/langchain_dart/issues/802)). ([c5c73549](https://github.com/davidmigloz/langchain_dart/commit/c5c73549c51354996b2ca6bbce9d4c4c721fc159))
- **FEAT**: Add tool_name and index support ([#800](https://github.com/davidmigloz/langchain_dart/issues/800)). ([f0f77286](https://github.com/davidmigloz/langchain_dart/commit/f0f77286c02c64ea7b75a011761e677fc168ffff))
- **FEAT**: Add remote_model and remote_host support ([#799](https://github.com/davidmigloz/langchain_dart/issues/799)). ([36b9d5f2](https://github.com/davidmigloz/langchain_dart/commit/36b9d5f2ba26df6dd79f7105903cdbdd25711ebe))
- **FEAT**: Add truncate and shift support ([#798](https://github.com/davidmigloz/langchain_dart/issues/798)). ([098a0815](https://github.com/davidmigloz/langchain_dart/commit/098a08150f2607bf283bb5d2aef82593c91cf221))
- **FEAT**: Support high, medium, low for think ([#797](https://github.com/davidmigloz/langchain_dart/issues/797)). ([1cbe3fcf](https://github.com/davidmigloz/langchain_dart/commit/1cbe3fcf96926eb2e81b9f9a7aec8f37797c76d3))
- **FEAT**: Support JSON schema in ResponseFormat ([#796](https://github.com/davidmigloz/langchain_dart/issues/796)). ([2f399465](https://github.com/davidmigloz/langchain_dart/commit/2f3994656c32f32a79bb0b613bf38b9fd2e83b3d))
- **FEAT**: Upgrade to http v1.5.0 ([#785](https://github.com/davidmigloz/langchain_dart/issues/785)). ([f7c87790](https://github.com/davidmigloz/langchain_dart/commit/f7c8779011015b5a4a7f3a07dca32bde1bb2ea88))
- **BREAKING** **REFACTOR**: Improve factory names ([#806](https://github.com/davidmigloz/langchain_dart/issues/806)). ([fbfa7acb](https://github.com/davidmigloz/langchain_dart/commit/fbfa7acb071a8c2271a6cfb6506e9f6d8b863ca4))
- **BREAKING** **BUILD**: Require Dart >=3.8.0 ([#792](https://github.com/davidmigloz/langchain_dart/issues/792)). ([b887f5c6](https://github.com/davidmigloz/langchain_dart/commit/b887f5c62e307b3a510c5049e3d1fbe7b7b4f4c9))

## 0.2.5

- **FEAT**: Migrate to Freezed v3 ([#773](https://github.com/davidmigloz/langchain_dart/issues/773)). ([f87c8c03](https://github.com/davidmigloz/langchain_dart/commit/f87c8c03711ef382d2c9de19d378bee92e7631c1))

## 0.2.4

- **BUILD**: Update dependencies ([#751](https://github.com/davidmigloz/langchain_dart/issues/751)). ([250a3c6](https://github.com/davidmigloz/langchain_dart/commit/250a3c6a6c1815703a61a142ba839c0392a31015))

## 0.2.3

- **FEAT**: Add think/thinking params to ollama_dart ([#721](https://github.com/davidmigloz/langchain_dart/issues/721)). ([701d7968](https://github.com/davidmigloz/langchain_dart/commit/701d7968baaa07f5612a25d74a1d19c2c24e7077))
- **FEAT**: Add capabilities, projector_info, tensors and modified_at to Ollama's ModelInfo ([#690](https://github.com/davidmigloz/langchain_dart/issues/690)). ([c5e247db](https://github.com/davidmigloz/langchain_dart/commit/c5e247db6aadedaa6ec668652e416477a6c03b51))
- **FEAT**: Update dependencies (requires Dart 3.6.0) ([#709](https://github.com/davidmigloz/langchain_dart/issues/709)). ([9e3467f7](https://github.com/davidmigloz/langchain_dart/commit/9e3467f7caabe051a43c0eb3c1110bc4a9b77b81))
- **REFACTOR**: Remove fetch_client dependency in favor of http v1.3.0 ([#659](https://github.com/davidmigloz/langchain_dart/issues/659)). ([0e0a685c](https://github.com/davidmigloz/langchain_dart/commit/0e0a685c376895425dbddb0f9b83758c700bb0c7))
- **FIX**: Fix linter issues ([#656](https://github.com/davidmigloz/langchain_dart/issues/656)). ([88a79c65](https://github.com/davidmigloz/langchain_dart/commit/88a79c65aad23bcf5859e58a7375a4b686cf02ef))

## 0.2.2+1

- **REFACTOR**: Add new lint rules and fix issues ([#621](https://github.com/davidmigloz/langchain_dart/issues/621)). ([60b10e00](https://github.com/davidmigloz/langchain_dart/commit/60b10e008acf55ebab90789ad08d2449a44b69d8))
- **REFACTOR**: Upgrade api clients generator version ([#610](https://github.com/davidmigloz/langchain_dart/issues/610)). ([0c8750e8](https://github.com/davidmigloz/langchain_dart/commit/0c8750e85b34764f99b6e34cc531776ffe8fba7c))

## 0.2.2

- **FEAT**: Update Ollama default model to llama-3.2 ([#554](https://github.com/davidmigloz/langchain_dart/issues/554)). ([f42ed0f0](https://github.com/davidmigloz/langchain_dart/commit/f42ed0f04136021b30556787cfdea13a14ca5768))

## 0.2.1

- **FEAT**: Add support for min_p in Ollama ([#512](https://github.com/davidmigloz/langchain_dart/issues/512)). ([e40d54b2](https://github.com/davidmigloz/langchain_dart/commit/e40d54b2e729d8fb6bf14bb4ea97820121bc85c7))

## 0.2.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

- **FEAT**: Add tool calling support ([#504](https://github.com/davidmigloz/langchain_dart/issues/504)). ([1ffdb41b](https://github.com/davidmigloz/langchain_dart/commit/1ffdb41b8f19941336c1cd911c73f0b3d46af975))
- **BREAKING** **FEAT**: Update Ollama default model to llama-3.1 ([#506](https://github.com/davidmigloz/langchain_dart/issues/506)). ([b1134bf1](https://github.com/davidmigloz/langchain_dart/commit/b1134bf1163cdcea26a9f1e65fee5c515be3857c))
- **FEAT**: Add support for Ollama version and model info ([#488](https://github.com/davidmigloz/langchain_dart/issues/488)). ([a110ecb7](https://github.com/davidmigloz/langchain_dart/commit/a110ecb7f10e7975bd2416aa65add98984c6efb8))
- **FEAT**: Add suffix support in Ollama completions API ([#503](https://github.com/davidmigloz/langchain_dart/issues/503)). ([30d05a69](https://github.com/davidmigloz/langchain_dart/commit/30d05a69b07f88f803b9abfdf2fded9348a73490))
- **BREAKING** **REFACTOR**: Change Ollama push model status type from enum to String ([#489](https://github.com/davidmigloz/langchain_dart/issues/489)). ([90c9ccd9](https://github.com/davidmigloz/langchain_dart/commit/90c9ccd986c7b679ed30225d2380120e17dfec41))
- **DOCS**: Update Ollama request options default values in API docs ([#479](https://github.com/davidmigloz/langchain_dart/issues/479)). ([e1f93366](https://github.com/davidmigloz/langchain_dart/commit/e1f9336619ee12624a7b045ca18a3118ead0158f))

## 0.1.2

- **FEAT**: Add support for listing running Ollama models ([#451](https://github.com/davidmigloz/langchain_dart/issues/451)). ([cfaa31fb](https://github.com/davidmigloz/langchain_dart/commit/cfaa31fb8ce1dc128570c95d403809f71e0199d9))
- **REFACTOR**: Migrate conditional imports to js_interop ([#453](https://github.com/davidmigloz/langchain_dart/issues/453)). ([a6a78cfe](https://github.com/davidmigloz/langchain_dart/commit/a6a78cfe05fb8ce68e683e1ad4395ca86197a6c5))

## 0.1.1

- **FEAT**: Support buffered stream responses ([#445](https://github.com/davidmigloz/langchain_dart/issues/445)). ([ce2ef30c](https://github.com/davidmigloz/langchain_dart/commit/ce2ef30c9a9a0dfe8f3059988b7007c94c45b9bd))
- **FIX**: Fix deserialization of sealed classes ([#435](https://github.com/davidmigloz/langchain_dart/issues/435)). ([7b9cf223](https://github.com/davidmigloz/langchain_dart/commit/7b9cf223e42eae8496f864ad7ef2f8d0dca45678))

## 0.1.0+1

- **FIX**: digest path param in Ollama blob endpoints ([#430](https://github.com/davidmigloz/langchain_dart/issues/430)). ([2e9e935a](https://github.com/davidmigloz/langchain_dart/commit/2e9e935aefd74e5e9e09a23188a6c77ce535661d))

## 0.1.0

> [!CAUTION]
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

- **BREAKING** **FEAT**: Align Ollama client to the Ollama v0.1.36 API  ([#411](https://github.com/davidmigloz/langchain_dart/issues/411)). ([326212ce](https://github.com/davidmigloz/langchain_dart/commit/326212ce4e4b035f7b29f4c810f447d5cf1731c4))
- **FEAT**: Update Ollama default model from llama2 to llama3 ([#417](https://github.com/davidmigloz/langchain_dart/issues/417)). ([9d30b1a1](https://github.com/davidmigloz/langchain_dart/commit/9d30b1a1c811d73cfa27110b8c3c10b10da1801e))
- **FEAT**: Add support for done reason ([#413](https://github.com/davidmigloz/langchain_dart/issues/413)). ([cc5b1b02](https://github.com/davidmigloz/langchain_dart/commit/cc5b1b021636379f32f215546b78547ace87d150))

## 0.0.3+1

- **FIX**: Have the == implementation use Object instead of dynamic ([#334](https://github.com/davidmigloz/langchain_dart/issues/334)). ([89f7b0b9](https://github.com/davidmigloz/langchain_dart/commit/89f7b0b94144c216de19ec7244c48f3c34c2c635))

## 0.0.3

- **FEAT**: Add Ollama keep_alive param to control how long models stay loaded ([#319](https://github.com/davidmigloz/langchain_dart/issues/319)). ([3b86e227](https://github.com/davidmigloz/langchain_dart/commit/3b86e22788eb8df9c09b034c5acc98fdaa6b32c6))
- **FEAT**: Update meta and test dependencies ([#331](https://github.com/davidmigloz/langchain_dart/issues/331)). ([912370ee](https://github.com/davidmigloz/langchain_dart/commit/912370ee0ba667ee9153303395a457e6caf5c72d))
- **DOCS**: Update pubspecs. ([d23ed89a](https://github.com/davidmigloz/langchain_dart/commit/d23ed89adf95a34a78024e2f621dc0af07292f44))

## 0.0.2+1

- **DOCS**: Update CHANGELOG.md. ([d0d46534](https://github.com/davidmigloz/langchain_dart/commit/d0d46534565d6f52d819d62329e8917e00bc7030))

## 0.0.2

- **FEAT**: Add support for chat API and multi-modal LLMs ([#274](https://github.com/davidmigloz/langchain_dart/issues/274)). ([76e1a294](https://github.com/davidmigloz/langchain_dart/commit/76e1a2946fbbf5c4802c4e66addeb9adf5900b17))

## 0.0.1+2

- **FIX**: Fetch web requests with big payloads dropping connection ([#273](https://github.com/davidmigloz/langchain_dart/issues/273)). ([425889dc](https://github.com/davidmigloz/langchain_dart/commit/425889dc24a74790a7072c75f0bdb0d19ab40cf6))

## 0.0.1+1

- **DOCS**: Update README.me. ([be20dbaf](https://github.com/davidmigloz/langchain_dart/commit/be20dbaf4568c773aca88f1339a489092b3a5551))

## 0.0.1

- **FEAT**: Implement ollama_dart, a Dart client for Ollama API ([#238](https://github.com/davidmigloz/langchain_dart/issues/238)). ([d213aa9c](https://github.com/davidmigloz/langchain_dart/commit/d213aa9c5dec0aea11d656b5f16ddf3174f5b789))

## 0.0.1-dev.1

- Bootstrap project.

