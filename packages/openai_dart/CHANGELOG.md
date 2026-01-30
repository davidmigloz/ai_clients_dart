# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

#### Responses API - Built-in Tool Output Types
- `WebSearchCallOutputItem` - Output item for web search tool calls
- `FileSearchCallOutputItem` - Output item for file search tool calls
- `CodeInterpreterCallOutputItem` - Output item for code interpreter tool calls
- `ImageGenerationCallOutputItem` - Output item for image generation tool calls
- `McpCallOutputItem` - Output item for MCP (Model Context Protocol) tool calls
- `AssistantTextContent` - Content type for assistant messages (serializes as `output_text`)
- Convenience getters on `Response`: `webSearchCalls`, `fileSearchCalls`, `codeInterpreterCalls`, `imageGenerationCalls`, `mcpCalls`
- `copyWith` method on `FunctionCallOutputItem`

#### Videos API (Sora)
- `client.videos.list()` for listing video generation jobs
- `client.videos.create()` for creating video generation jobs
- `client.videos.retrieve()` for retrieving video status
- `client.videos.delete()` for deleting videos
- `client.videos.retrieveContent()` for downloading video content, thumbnails, and spritesheets
- `client.videos.remix()` for creating remixes of existing videos
- Full model support: `Video`, `VideoList`, `VideoStatus`, `VideoSize`, `VideoSeconds`, `VideoContentVariant`
- Helper properties: `isCompleted`, `isFailed`, `isRemix`, `createdAtDateTime`, `completedAtDateTime`

#### Conversations API
- `client.conversations.create()` for creating conversations
- `client.conversations.retrieve()` for retrieving conversations
- `client.conversations.update()` for updating conversation metadata
- `client.conversations.delete()` for deleting conversations
- `client.conversations.items.create()` for adding items to conversations
- `client.conversations.items.list()` for listing conversation items with pagination
- `client.conversations.items.retrieve()` for retrieving specific items
- `client.conversations.items.delete()` for deleting items from conversations
- Full model support: `Conversation`, `ConversationItem`, `ConversationContent`, `ConversationRole`
- Support for all item types: message, function_call, reasoning, web_search_call, file_search_call, etc.

#### Containers API
- `client.containers.list()` for listing containers
- `client.containers.create()` for creating isolated execution environments
- `client.containers.retrieve()` for retrieving container details
- `client.containers.delete()` for deleting containers
- `client.containers.files.list()` for listing files in a container
- `client.containers.files.create()` for uploading files to containers
- `client.containers.files.retrieve()` for retrieving file metadata
- `client.containers.files.delete()` for deleting files from containers
- `client.containers.files.retrieveContent()` for downloading file content
- Full model support: `Container`, `ContainerFile`, `ContainerExpiration`

#### ChatKit API (Beta)
- `client.chatkit.sessions.create()` for creating sessions with client secrets
- `client.chatkit.sessions.cancel()` for cancelling active sessions
- `client.chatkit.threads.list()` for listing threads
- `client.chatkit.threads.retrieve()` for retrieving thread details
- `client.chatkit.threads.delete()` for deleting threads
- `client.chatkit.threads.items.list()` for listing thread items
- Full model support: `ChatSession`, `ChatkitThread`, `ThreadItem`, `ThreadStatus`
- Configuration options: workflow, rate limits, file upload, history, automatic titling

### Fixed

- `MessageItem.assistantText()` now uses `AssistantTextContent` which serializes as `output_text` (required by API for assistant messages)
- Added documentation for `ResponsesResource.list()` session key requirement
- Added documentation for `maxOutputTokens` minimum value (16)

## 1.0.0 - 2026-01-24

### Added

#### Core
- Hand-crafted OpenAI client with resource-based API design
- `OpenAIClient` with lazy-initialized resources
- `OpenAIConfig` for flexible client configuration
- Multiple authentication providers: `ApiKeyProvider`, `OrganizationApiKeyProvider`, `AzureApiKeyProvider`
- Comprehensive exception hierarchy with `createApiException` factory
- Interceptor-driven architecture for request/response processing
- Automatic retry with exponential backoff

#### Chat Completions
- `client.chat.completions.create()` for chat completions
- `client.chat.completions.createStream()` for streaming responses
- Support for system, user, assistant, tool, and developer messages
- Tool/function calling with `ToolChoice` options
- Vision support with image content parts
- `ChatStreamAccumulator` for collecting streaming chunks
- Extension methods: `collectText()`, `textDeltas()`, `accumulate()`

#### Embeddings
- `client.embeddings.create()` for text embeddings
- Support for single text, multiple texts, and token inputs
- Dimension control for text-embedding-3 models
- `firstEmbedding` convenience getter

#### Audio
- `client.audio.speech.create()` for text-to-speech
- `client.audio.transcriptions.create()` for speech-to-text
- `client.audio.transcriptions.createVerbose()` for detailed transcriptions
- `client.audio.translations.create()` for audio translation
- Multiple voices and response formats

#### Images
- `client.images.generate()` for DALL-E image generation
- `client.images.edit()` for image editing with masks
- `client.images.createVariation()` for image variations
- Support for DALL-E 2 and DALL-E 3 models
- Quality, size, and style options

#### Files & Uploads
- `client.files.upload()`, `list()`, `retrieve()`, `delete()`, `content()`
- `client.uploads.create()`, `addPart()`, `complete()`, `cancel()`
- Support for large file uploads via multipart

#### Batches
- `client.batches.create()`, `list()`, `retrieve()`, `cancel()`
- Batch processing for chat completions and embeddings

#### Models
- `client.models.list()` for listing available models
- `client.models.retrieve()` for model details
- `client.models.delete()` for deleting fine-tuned models

#### Moderations
- `client.moderations.create()` for content moderation
- Support for text and image moderation
- Detailed category scores

#### Fine-tuning
- `client.fineTuning.jobs.create()`, `list()`, `retrieve()`, `cancel()`
- `client.fineTuning.jobs.events()` for job events
- Checkpoint management

#### Assistants API (Beta)
- `client.beta.assistants.create()`, `list()`, `retrieve()`, `update()`, `delete()`
- Full CRUD operations for assistants
- Tool integration (code interpreter, file search)

#### Threads API (Beta)
- `client.beta.threads.create()`, `retrieve()`, `update()`, `delete()`
- Thread management for assistant conversations

#### Messages API (Beta)
- `client.beta.threads.messages.create()`, `list()`, `retrieve()`, `update()`, `delete()`
- Message content with text, images, and files

#### Runs API (Beta)
- `client.beta.threads.runs.create()`, `list()`, `retrieve()`, `update()`, `cancel()`
- `client.beta.threads.runs.submitToolOutputs()`
- Run step retrieval

#### Vector Stores (Beta)
- `client.beta.vectorStores.create()`, `list()`, `retrieve()`, `update()`, `delete()`
- File batch operations for vector stores

#### Realtime API
- `client.realtime.connect()` for WebSocket connections
- Server and client event handling
- Session configuration

#### Evals API
- `client.evals.create()`, `list()`, `retrieve()`, `update()`, `delete()`
- `client.evals.runs.create()`, `list()`, `retrieve()`, `delete()`, `cancel()`
- `client.evals.runs.outputItems.list()`, `retrieve()`
- Multiple grader types: `StringCheck`, `TextSimilarity`, `LabelModel`, `ScoreModel`, `Python`
- Data source configurations: `Custom`, `Logs`, `StoredCompletions`
- Run data sources: `JSONL`, `Completions`, `Responses`
- Status helpers: `isRunning`, `isCompleted`, `isFailed`, `passRate`

#### Completions (Legacy)
- `client.completions.create()` for legacy text completions
- Maintained for backward compatibility

### Notes

This is a complete rewrite of the openai_dart package with:
- Hand-crafted models (no code generation)
- Minimal dependencies (http, logging, meta, web_socket_channel)
- Type-safe sealed classes for unions
- Consistent patterns matching official OpenAI SDKs
- Full API coverage including beta features
