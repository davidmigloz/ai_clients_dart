# Migration Guide

This guide covers breaking changes between major versions of `anthropic_sdk_dart`.

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).

---

## Migrating from v7.x to v8.0.0

v8.0.0 syncs the client to the Anthropic OpenAPI spec of September 2026 (Claude Fable 5.1). Most of the release is additive, but the spec removed the `mid_conv_system` block, promoted the Files and Skills APIs to GA with new shapes, replaced the user-profile `relationship` field, and turned several loosely-typed request fields and Managed Agents structures into typed unions. New request variants also make exhaustive `switch` statements over a few exported sealed unions non-exhaustive.

### 1) `mid_conv_system` content block removed

The spec dropped `RequestMidConvSystemBlock`; system instructions inside `messages` are now plain `role: "system"` messages, which the client already supported. `MidConversationSystemInputBlock` and `InputContentBlock.midConversationSystem` are gone, and `{"type": "mid_conv_system"}` parses as `UnknownInputContentBlock`.

```dart
// Before
InputMessage.userBlocks([
  InputContentBlock.midConversationSystem(content: [TextInputBlock('Answer in French.')]),
])

// After — a system message in the messages array
InputMessage.system('Answer in French.')

// New: turn-scoped reminder (beta `mid-conversation-system-clear-at-2026-08-21`)
InputMessage.system('Check your inbox first.', clearAt: SystemMessageClearAt.nextUserMessage)

// New: per-message effort (beta `mid-conversation-output-config-2026-07-01`)
InputMessage.systemEffort(EffortLevel.low)
```

### 2) `MessageCreateRequest.fallbacks` and `container` are typed unions

`fallbacks` changed from `List<FallbackConfigV2>?` to `FallbacksParam?` so the server-recommended `"default"` chain can be requested, and `container` changed from `String?` to `ContainerParam?` so skills can be loaded into a container. `ContainerParams` now models the real spec shape (`id`, `skills`); its former `memoryMb`/`timeoutSeconds` fields and `CodeExecutionTool.container` never existed in the API and were removed.

```dart
// Before
MessageCreateRequest(
  container: 'container_123',
  fallbacks: [FallbackConfigV2(model: 'claude-opus-5')],
)

// After
MessageCreateRequest(
  container: ContainerParam.id('container_123'),
  fallbacks: FallbacksParam.list([FallbackConfigV2(model: 'claude-opus-5')]),
)

// New options
MessageCreateRequest(
  fallbacks: FallbacksParam.defaultMode(),
  container: ContainerParam.config(
    ContainerParams(
      skills: [ContainerSkillParams(type: ContainerSkillType.anthropic, skillId: 'pdf')],
    ),
  ),
)
```

### 3) Files API is GA: cursor pagination and expiration

`client.files` no longer sends the `files-api-2025-04-14` beta header. `list()` takes `page` (the opaque cursor from `FileListResponse.nextPage`) and `ids` instead of `beforeId`/`afterId`, and `FileListResponse` is `{data, nextPage}` (no `hasMore`/`firstId`/`lastId`). Uploads accept `expiresInSeconds`, and `FileMetadata` gained `expiresAt`.

```dart
// Before
var page = await client.files.list(limit: 50);
while (page.hasMore && page.lastId != null) {
  page = await client.files.list(limit: 50, afterId: page.lastId);
}

// After
var page = await client.files.list(limit: 50);
while (page.nextPage != null) {
  page = await client.files.list(limit: 50, page: page.nextPage);
}
```

### 4) Skills API is GA: new model shapes and multi-file uploads

`client.skills` no longer sends the `skills-2025-10-02` beta header. `Skill` now has `displayName`, `latestVersionId` and an object `source` (`SkillSource.type` is a `SkillSourceType`, which also gained `anthropicExample` and `plugin`) instead of `displayTitle`/`latestVersion`/an enum source; `SkillVersion` lost `version` and `directory` (use `id`); list responses lost `hasMore`; `list(source:)` takes a `SkillSourceType`; `deleteSkill`/`deleteVersion` return `DeletedSkill`/`DeletedSkillVersion`; and `create`/`createVersion` upload the skill's files individually instead of a zip.

```dart
// Before
final skill = await client.skills.create(skillBytes: zipBytes, displayTitle: 'My Skill');
print(skill.displayTitle);

// After — one SkillFile per file, all under the same top-level directory
final skill = await client.skills.create(
  files: [SkillFile(path: 'my-skill/SKILL.md', bytes: skillMd)],
  displayName: 'My Skill',
);
print('${skill.displayName} (${skill.source.type}) latest=${skill.latestVersionId}');
final deleted = await client.skills.deleteSkill(skillId: skill.id); // DeletedSkill
```

### 5) User profiles: `relationship` replaced by `accessType`

The spec removed the `relationship` concept. `UserProfile`, `CreateUserProfileRequest` and `UpdateUserProfileRequest` now carry `accessType` (`UserProfileAccessType.application` / `.passthrough`) and `externalUserOnboardedAt` instead; the `BetaUserProfileRelationship` enum is gone. `list()` gained `orderBy`, and the resource sends the `user-profiles-2026-08-18` beta header.

```dart
// Before
CreateUserProfileRequest(externalId: 'user-1', relationship: BetaUserProfileRelationship.external)

// After
CreateUserProfileRequest(
  externalId: 'user-1',
  accessType: UserProfileAccessType.application,
  externalUserOnboardedAt: DateTime.utc(2024, 11, 2, 8, 15),
)
```

### 6) Managed Agents: per-tool configs, roster entries and typed message content

- `AgentToolConfig` / `AgentToolConfigParams` are sealed unions with one variant per tool (`bash`, `edit`, `read`, `write`, `glob`, `grep`, `web_fetch`, `web_search`); the web variants add `allowedDomains`/`blockedDomains`, `maxContentTokens` (web_fetch) and `userLocation` (web_search).
- `MultiagentCoordinator.agents` is `List<MultiagentRosterEntry>` (`AgentReference` or the new `Advisor`), `MultiagentRosterEntryParams` gained `.advisor(model)`, `SessionMultiagentCoordinator.agents` is `List<SessionRosterEntry>`, and `SessionThread.agent` is a `SessionRosterEntry` (`SessionThreadAgent`, which never carried `multiagent`).
- `AgentMessageEvent.content` is `List<AgentMessageContentBlock>` (`ManagedAgentsTextBlock` / `ManagedAgentsRedactedBlock`) instead of raw maps, and `Dream.outputBehavior` is a required field.

```dart
// Before
AgentToolset20260401Params(
  configs: [AgentToolConfigParams(name: AgentToolName.webSearch, enabled: true)],
)
for (final ref in coordinator.agents) { print(ref.id); }

// After
AgentToolset20260401Params(
  configs: [AgentToolConfigParams.webSearch(enabled: true, allowedDomains: ['docs.example.com'])],
)
for (final entry in coordinator.agents) {
  switch (entry) {
    case AgentReference(:final id): print(id);
    case Advisor(:final model): print('advisor: $model');
    case UnknownMultiagentRosterEntry(): break;
  }
}
```

### 7) New variants on exported sealed unions

Exhaustive `switch` statements without a wildcard or `Unknown*` branch need new cases. `InputContentBlock` gained `ThinkingInputBlock` and `RedactedThinkingInputBlock` (and `InputContentBlock.fromJson` now returns them for `thinking`/`redacted_thinking` JSON instead of `UnknownInputContentBlock`); `ToolResultContent` gained `document`, `search_result`, `tool_reference` and `browser_state` variants plus `UnknownToolResultContent` (it no longer throws on unknown types); `BuiltInTool` gained `ComputerToolset`/`BrowserToolset`; and `SessionEvent`, `SessionStopReason`, `WebhookEventData` and `ManagedAgentActor` gained budget/service-account variants. Pure-deserialization consumers are unaffected. To replay an assistant turn that contains thinking, prefer `response.toInputMessage()` over hand-picking blocks.

---

## Migrating from v6.x to v7.0.0

v7.0.0's breaking surface is limited to one field: fallback credit tokens now support a redemption `mode`, so the plain `String?` field became a typed union. Everything else in this release (the Dreams API, mid-conversation tool changes, managed-agent effort levels, and the `agent-memory-2026-07-22` beta header switch) is additive.

### 1) `MessageCreateRequest.fallbackCreditToken` changed from `String?` to `FallbackCreditTokenParam?`

To support the new `strict`/`best_effort` redemption mode (requires the `fallback-credit-2026-07-01` beta header), `fallbackCreditToken` is now a sealed union instead of a plain string. Use `FallbackCreditTokenParam.token(...)` for the previous bare-token behavior (equivalent to `strict` mode), or `FallbackCreditTokenParam.config(...)` to pass an explicit `mode`.

```dart
// Before
MessageCreateRequest(fallbackCreditToken: 'fct_...')

// After — bare token (same behavior as before, implicitly strict)
MessageCreateRequest(
  fallbackCreditToken: FallbackCreditTokenParam.token('fct_...'),
);

// After — explicit best-effort redemption mode
MessageCreateRequest(
  fallbackCreditToken: FallbackCreditTokenParam.config(
    token: refusal.fallbackCreditToken!,
    mode: FallbackCreditMode.bestEffort,
  ),
);
```

The redemption outcome is now reported on the response via the new `fallbackCredit` field:

```dart
final status = response.usage.fallbackCredit?.status; // redeemed / notApplied
```

---

## Migrating from v5.x to v6.0.0

v6.0.0 syncs to the latest Anthropic spec. The breaking surface is small: the API relocated end-user attribution from the message request body to a request header, and two remaining closed-enum `String` fields are now typed enums. Everything else in this release (Claude Sonnet 5, the `web_search_20260318`/`web_fetch_20260318` tool versions, Managed Agents event-delta streaming, credential injection location, per-session agent overrides, backward pagination, and the new webhook events) is additive.

### 1) `user_profile_id` moved from the request body to a header

`user_profile_id` is no longer a message-creation body field: `MessageCreateRequest.userProfileId` is removed, and attribution now travels in the `anthropic-user-profile-id` header via a `userProfileId` method parameter on `messages.create`, `messages.createStream`, `messages.countTokens`, and `messageBatches.create`. The API relocated the parameter — it was not removed — and the User Profiles resource itself (`client.userProfiles`) is unchanged.

```dart
// Before — body field on the request
await client.messages.create(MessageCreateRequest(
  model: 'claude-opus-4-8',
  maxTokens: 256,
  userProfileId: profile.id,
  messages: [InputMessage.user('Hello!')],
));

// After — header via method parameter
await client.messages.create(
  MessageCreateRequest(
    model: 'claude-opus-4-8',
    maxTokens: 256,
    messages: [InputMessage.user('Hello!')],
  ),
  userProfileId: profile.id,
);
```

### 2) Two closed-enum `String` fields are now typed enums

- `SpanModelUsage.speed`: `String?` → `AgentSpeed?` (has an `unknown` fallback).
- `WebSearchResultError.errorCode`: was a plain `String`; now a derived `WebSearchToolResultErrorCode get errorCode`, with the raw wire value available on the new `rawErrorCode` field (mirrors `AdvisorToolResultError`).

```dart
// Before
final code = webSearchError.errorCode; // String

// After
final code = webSearchError.errorCode;   // WebSearchToolResultErrorCode
final raw = webSearchError.rawErrorCode; // String (round-trip fidelity)
```

Relatedly, the new `responseInclusion` field on `WebSearchTool`/`WebFetchTool` is typed as a `ResponseInclusion` enum (not a `String`) from the start.

---

## Migrating from v4.x to v5.0.0

**Most users will not need to make any changes.** v5.0.0 syncs to the latest Anthropic spec. `FallbackBlock` and `FallbackInputBlock` are normally consumed by deserializing API responses (`fromJson`), so pure-deserialization consumers are unaffected. The only behavioral change for typical callers is that code-execution tools constructed without an explicit `type` now default to the newer `code_execution_20260521` version. Everything else in this release (the `session.updated` webhook event, the typed refusal `trigger`) is additive.

### 1) `FallbackBlock` now requires a `trigger`

The response-side `FallbackBlock` gains a required `trigger` (a `FallbackRefusalTrigger`), mirroring the spec where `trigger` became required on the block. `FallbackBlock` is normally consumed via `fromJson`, so most callers are unaffected — only code that *constructs* a `FallbackBlock` directly needs to pass `trigger`.

```dart
// Before
const FallbackBlock(from: from, to: to);

// After
const FallbackBlock(
  from: from,
  to: to,
  trigger: FallbackRefusalTrigger(rawCategory: 'cyber'),
);
```

The typed category is derived via a getter, so unrecognized future categories round-trip verbatim instead of collapsing to `unknown`:

```dart
for (final block in response.content) {
  if (block is FallbackBlock) {
    print('${block.from.model} -> ${block.to.model} '
        '(${block.trigger.category?.value ?? 'uncategorized'})');
  }
}
```

### 2) `FallbackInputBlock` constructor is no longer `const`

The request-side `FallbackInputBlock` now stores its echoed `trigger` as a deeply-unmodifiable map, so its constructor can no longer be `const`. Drop the `const` keyword from any direct construction.

```dart
// Before
const block = FallbackInputBlock(/* ... */);

// After
final block = FallbackInputBlock(/* ... */);
```

### 3) Code-execution tools default to `code_execution_20260521`

Code-execution tools constructed **without an explicit `type`** now default to the new `code_execution_20260521` version:

- `BuiltInTool.codeExecution()` / `CodeExecutionBuiltInTool()`: `code_execution_20260120` → `code_execution_20260521`
- beta `CodeExecutionTool()`: `code_execution_20250825` → `code_execution_20260521`

Pin an older version by passing `type` explicitly:

```dart
// Keep the previous GA version
BuiltInTool.codeExecution(type: 'code_execution_20260120');
```

---

## Migrating from v3.x to v4.0.0

**Most users will not need to make any changes.** v4.0.0 syncs to the latest Anthropic spec for the [Claude Opus 4.8](https://www.anthropic.com/news/claude-opus-4-8) release. The breaking surface is limited to two source-level additions — a new variant on the exported sealed union `InputContentBlock` and a new value on the `MessageRole` enum — which only affect code with *exhaustive* `switch` statements that lack a wildcard or `Unknown*`/`default` branch. Everything else in this release (mid-conversation system messages, `outputTokensDetails`, advisor `stopReason`) is purely additive. Pure-deserialization consumers — and anyone already using a wildcard / `Unknown*` / `default` branch — are unaffected.

### 1) New `MidConversationSystemInputBlock` variant on `InputContentBlock`

The `mid_conv_system` content block adds a `MidConversationSystemInputBlock` variant to the exported sealed `InputContentBlock` union. As in v3.0.0, this is breaking only for exhaustive `switch` statements over `InputContentBlock` that lack a wildcard or `UnknownInputContentBlock` branch.

```dart
// Before — exhaustive over the prior variant set (stops compiling on upgrade)
final label = switch (block) {
  TextInputBlock() => 'text',
  ImageInputBlock() => 'image',
  // ... all other variants
};

// After — handle the new variant, or add a wildcard `_` / UnknownInputContentBlock()
final label = switch (block) {
  TextInputBlock() => 'text',
  ImageInputBlock() => 'image',
  MidConversationSystemInputBlock() => 'mid_conv_system',
  UnknownInputContentBlock() => 'unknown',
};
```

### 2) New `system` value on the `MessageRole` enum

The spec adds `system` to the message `role` enum (enabling `role: "system"` entries in the `messages` array). `MessageRole` gains a `system` value, and `InputMessage` gains `system(...)` / `systemBlocks(...)` factories. This is breaking only for exhaustive `switch` statements over `MessageRole` that lack a `default` branch.

```dart
// Before — exhaustive over user/assistant (stops compiling on upgrade)
final s = switch (role) {
  MessageRole.user => 'user',
  MessageRole.assistant => 'assistant',
};

// After — add the system case (or a default branch)
final s = switch (role) {
  MessageRole.user => 'user',
  MessageRole.assistant => 'assistant',
  MessageRole.system => 'system',
};
```

All newly added *fields* in this release (`Usage.outputTokensDetails`, `MessageDeltaUsage.outputTokensDetails`, `AdvisorResult.stopReason`, `AdvisorRedactedResult.stopReason`) are optional and nullable, so they are non-breaking on their own.

---

## Migrating from v2.x to v3.0.0

v3.0.0 completes the four-part Anthropic spec refresh. The breaking surface is small and mostly about forward-compatibility: several **exported `sealed` unions gained new variants**, so only code that `switch`es over them *exhaustively* (without a wildcard or `Unknown*` branch) needs updating. There is one concrete API break — `UserProfile.relationship` is now a required constructor parameter. Pure-deserialization consumers (no exhaustive `switch` over these types) are unaffected.

### 1) `UserProfile.relationship` is now required

The spec marks `relationship` as required and non-nullable, so it is now a required constructor parameter. Only code that constructs `UserProfile` directly (tests, mocks, fixtures) is affected — `UserProfile.fromJson` is unchanged.

```dart
// Before (v2.x)
final profile = UserProfile(
  id: 'uprof_…',
  metadata: {},
  trustGrants: {},
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// After (v3.0.0) — relationship is now required
final profile = UserProfile(
  id: 'uprof_…',
  relationship: BetaUserProfileRelationship.external,
  metadata: {},
  trustGrants: {},
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### 2) New variants on exported `sealed` unions

Adding variants to a `sealed` type is source-breaking for downstream `switch` statements that were exhaustive over the previous variant set. The fix is the same in every case: handle the new variant(s), or add a wildcard / `Unknown*` catch-all so future additions stay non-breaking.

The affected unions and their new variants:

- **`Citation`** ([#233](https://github.com/davidmigloz/ai_clients_dart/issues/233)) — `SearchResultLocationCitation`, `UnknownCitation`. (Bonus: `Citation.fromJson` previously *threw* `FormatException` on unrecognized types; with `UnknownCitation` it is now forward-compatible.)
- **`InputContentBlock`** ([#235](https://github.com/davidmigloz/ai_clients_dart/issues/235)) — `SearchResultInputBlock`.
- **`SessionEvent`** ([#236](https://github.com/davidmigloz/ai_clients_dart/issues/236), [#230](https://github.com/davidmigloz/ai_clients_dart/issues/230), [#224](https://github.com/davidmigloz/ai_clients_dart/issues/224)) — `SessionUpdatedEvent`, `UserToolResultEvent`, `SpanOutcomeEvaluationStartEvent`, `SpanOutcomeEvaluationOngoingEvent`, `SpanOutcomeEvaluationEndEvent`, `UserDefineOutcomeEvent`, plus the session-thread lifecycle events.
- **`EventParams`** ([#236](https://github.com/davidmigloz/ai_clients_dart/issues/236), [#230](https://github.com/davidmigloz/ai_clients_dart/issues/230)) — `UserToolResultEventParams`, `UserDefineOutcomeEventParams`.

```dart
// Before — exhaustive over the prior variant set (stops compiling on upgrade)
final label = switch (citation) {
  CharLocationCitation() => 'char',
  PageLocationCitation() => 'page',
  ContentBlockLocationCitation() => 'block',
  WebSearchResultLocationCitation() => 'web',
};

// After — handle the new variant, and use UnknownCitation (or a wildcard `_`)
// so subsequent additions are non-breaking
final label = switch (citation) {
  CharLocationCitation() => 'char',
  PageLocationCitation() => 'page',
  ContentBlockLocationCitation() => 'block',
  WebSearchResultLocationCitation() => 'web',
  SearchResultLocationCitation() => 'search_result',
  UnknownCitation() => 'unknown',
};
```

The same pattern applies to `InputContentBlock`, `SessionEvent`, and `EventParams` — add the new branches, or a wildcard `_` (or the union's `Unknown*` variant) to stay forward-compatible.

All newly added *fields* in this release (`Message.diagnostics`, `MessageCreateRequest.diagnostics`, `ThinkingDelta.estimatedTokens`, `UpdateSessionParams.agent`, the new `DocumentInputBlock`/`TextInputBlock` citation fields, etc.) are optional and nullable, so they are non-breaking on their own.

---

## Migrating from v1.x to v2.0.0

v2.0.0 tightens `Session` field nullability to match the `BetaManagedAgentsSession` spec. Six fields that were previously nullable are now required non-nullable, so code constructing `Session` instances directly (for tests, mocks, or fixtures) must provide them.

### 1) Non-Nullable Required Fields on `Session`

Six fields on `Session` are no longer nullable and are required constructor parameters: `environmentId`, `metadata`, `resources`, `vaultIds`, `stats`, and `usage`. The `title` and `archivedAt` fields stay nullable (spec `nullable: true`) but are now `required` parameters in the constructor.

```dart
// Before (v1.x) — fields were optional and nullable
final session = Session(
  id: 'sess_1',
  type: 'session',
  agentId: 'agent_1',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// After (v2.0.0) — all required fields must be provided
final session = Session(
  id: 'sess_1',
  type: 'session',
  agentId: 'agent_1',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  title: null,
  archivedAt: null,
  environmentId: 'env_1',
  metadata: const {},
  resources: const [],
  vaultIds: const [],
  stats: SessionStats(...),
  usage: SessionUsage(...),
);
```

Deserialization from JSON (`Session.fromJson`) is unchanged — the API always returns these fields, so only direct construction is affected.

---

## Migrating from v0.1.x to v1.0.0

This guide helps you migrate from the old `anthropic_sdk_dart` client (v0.1.x) to the new **v1.0.0** (complete rewrite with resource-based organization and comprehensive API coverage).

## Overview of Changes

The new client mirrors the official REST structure with **resource-based APIs**. Instead of calling methods directly on the client, you now use resource objects:

* `client.messages` — Message creation, streaming, token counting
* `client.messages.batches` — Batch message processing
* `client.models` — Model listing and retrieval
* `client.files` — File upload/management (Beta)
* `client.skills` — Custom skills management (Beta)

## Quick Reference Table

| Operation             | Old API (v0.1.x)                                    | New API (v1.0.0)                                                              |
| --------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Initialize Client** | `AnthropicClient(apiKey: 'KEY')`                    | `AnthropicClient(config: AnthropicConfig(authProvider: ApiKeyProvider('KEY')))` |
| **Create Message**    | `client.createMessage(request: ...)`                | `client.messages.create(...)`                                                 |
| **Stream Message**    | `client.createMessageStream(request: ...)`          | `client.messages.createStream(...)`                                           |
| **Count Tokens**      | `client.countMessageTokens(request: ...)`           | `client.messages.countTokens(...)`                                            |
| **List Models**       | `client.listModels()`                               | `client.models.list()`                                                        |
| **Get Model**         | `client.retrieveModel(modelId: ...)`                | `client.models.retrieve(...)`                                                 |
| **List Batches**      | `client.listMessageBatches()`                       | `client.messages.batches.list()`                                              |
| **Create Batch**      | `client.createMessageBatch(request: ...)`           | `client.messages.batches.create(...)`                                         |
| **Upload File**       | ❌ Not available                                    | `client.files.upload(...)` *(Beta)*                                           |
| **Create Skill**      | ❌ Not available                                    | `client.skills.create(...)` *(Beta)*                                          |

## 1) Client Initialization

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

// Before
final old = AnthropicClient(
  apiKey: Platform.environment['ANTHROPIC_API_KEY'],
);
old.endSession();

// After
final client = AnthropicClient(
  config: AnthropicConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
  ),
);
// Or from environment variables (reads ANTHROPIC_API_KEY)
final client = AnthropicClient.fromEnvironment();
client.close();
```

## 2) Message Creation

```dart
// Before
final res = await client.createMessage(
  request: CreateMessageRequest(
    model: Model.model(Models.claude35Sonnet20241022),
    maxTokens: 1024,
    messages: [
      Message(
        role: MessageRole.user,
        content: MessageContent.text('Hello, Claude'),
      ),
    ],
  ),
);
print(res.content.text);

// After
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [InputMessage.user('Hello, Claude')],
  ),
);
print(response.text);
```

**Key changes:**

* Access under `client.messages`
* `Model.model(Models.xxx)` → String model ID
* `Message(role:, content:)` → `InputMessage.user()` / `InputMessage.assistant()`
* `response.content.text` → `response.text` helper property

## 3) System Prompts

```dart
// Before
CreateMessageRequest(
  system: CreateMessageRequestSystem.text('You are helpful'),
  // or with blocks
  system: CreateMessageRequestSystem.blocks([
    Block.text(text: 'instruction'),
  ]),
  ...
)

// After
MessageCreateRequest(
  system: SystemPrompt.text('You are helpful'),
  // or with blocks (now supports cache control)
  system: SystemPrompt.blocks([
    SystemTextBlock(
      text: 'instruction',
      cacheControl: CacheControlEphemeral(),
    ),
  ]),
  ...
)
```

## 4) Streaming

```dart
// Before
final stream = client.createMessageStream(
  request: CreateMessageRequest(
    model: Model.model(Models.claude35Sonnet20241022),
    maxTokens: 1024,
    messages: [
      Message(
        role: MessageRole.user,
        content: MessageContent.text('Hello'),
      ),
    ],
  ),
);
await for (final res in stream) {
  res.map(
    messageStart: (e) { /* ... */ },
    contentBlockDelta: (e) {
      stdout.write(e.delta.text);
    },
    messageStop: (e) { /* ... */ },
    ping: (e) { /* ... */ },
    error: (e) { /* ... */ },
    // ... other handlers
  );
}

// After
final stream = client.messages.createStream(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [InputMessage.user('Hello')],
  ),
);
await for (final event in stream) {
  switch (event) {
    case MessageStartEvent(:final message):
      print('Started: ${message.id}');
    case ContentBlockDeltaEvent(:final delta):
      if (delta is TextDelta) {
        stdout.write(delta.text);
      }
    case MessageDeltaEvent(:final delta):
      print('Stop reason: ${delta.stopReason}');
    case MessageStopEvent():
      print('Done');
    case PingEvent():
      break;
    case ErrorEvent(:final message):
      print('Error: $message');
    default:
      break;
  }
}
```

**Key changes:**

* `.map()` method → `switch/case` pattern matching
* `e.delta.text` → Type check with `if (delta is TextDelta)`
* More idiomatic Dart 3 patterns

## 5) Tool Use

```dart
// Before
const tool = Tool.custom(
  name: 'get_weather',
  description: 'Get weather for a location',
  inputSchema: {
    'type': 'object',
    'properties': {
      'location': {'type': 'string'},
    },
    'required': ['location'],
  },
);

final response = await client.createMessage(
  request: CreateMessageRequest(
    model: Model.model(Models.claude35Sonnet20241022),
    tools: [tool],
    toolChoice: ToolChoice(type: ToolChoiceType.auto),
    messages: [...],
    maxTokens: 1024,
  ),
);

final toolUse = response.content.blocks.firstOrNull;
if (toolUse is ToolUseBlock) {
  print('Tool: ${toolUse.name}');
  print('Input: ${toolUse.input}');
}

// After - Typed tools with ToolDefinition
final tool = Tool(
  name: 'get_weather',
  description: 'Get weather for a location',
  inputSchema: InputSchema(
    properties: {
      'location': {'type': 'string', 'description': 'City name'},
    },
    required: ['location'],
    extra: {'additionalProperties': false},
  ),
);

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    tools: [ToolDefinition.custom(tool)],
    toolChoice: ToolChoice.auto(),
    messages: [...],
    maxTokens: 1024,
  ),
);

// New helper properties
if (response.hasToolUse) {
  for (final toolUse in response.toolUseBlocks) {
    print('Tool: ${toolUse.name}');
    print('Input: ${toolUse.input}');
  }
}
```

**Key changes:**

* `Tool.custom()` → `ToolDefinition.custom(Tool(...))` - explicit wrapper
* `ToolChoice(type: ToolChoiceType.auto)` → `ToolChoice.auto()`
* Tools now use typed `List<ToolDefinition>` instead of `List<Map<String, dynamic>>`
* New helpers: `response.hasToolUse`, `response.toolUseBlocks`

### Built-in Tools

v1.0.0 adds support for Anthropic's built-in tools:

```dart
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 4096,
    tools: [
      // Web search tool
      ToolDefinition.builtIn(
        BuiltInTool.webSearch(
          maxUses: 5,
          allowedDomains: ['wikipedia.org', 'docs.anthropic.com'],
        ),
      ),
      // Bash tool (computer use)
      ToolDefinition.builtIn(BuiltInTool.bash()),
      // Text editor tool
      ToolDefinition.builtIn(
        BuiltInTool.textEditor(maxCharacters: 50000),
      ),
      // Mix with custom tools
      ToolDefinition.custom(myCustomTool),
    ],
    toolChoice: ToolChoice.auto(),
    messages: [InputMessage.user('Search for the latest Claude release')],
  ),
);
```

### Tool Choice Options

```dart
// Let Claude decide whether to use tools
toolChoice: ToolChoice.auto()

// Force Claude to use any available tool
toolChoice: ToolChoice.any()

// Force Claude to use a specific tool
toolChoice: ToolChoice.tool('get_weather')

// Prevent tool use entirely
toolChoice: ToolChoice.none()

// Disable parallel tool use (one tool at a time)
toolChoice: ToolChoice.auto(disableParallelToolUse: true)
```

## 6) Tool Results

```dart
// Before
Message(
  role: MessageRole.user,
  content: MessageContent.blocks([
    Block.toolResult(
      toolUseId: toolUse.id,
      content: ToolResultBlockContent.text(jsonEncode(result)),
    ),
  ]),
)

// After
InputMessage.userBlocks([
  InputContentBlock.toolResult(
    toolUseId: toolUse.id,
    content: [ToolResultContent.text(jsonEncode(result))],
  ),
])
```

## 7) Vision / Images

```dart
// Before: Not well documented in the old package

// After - From URL
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.userBlocks([
        InputContentBlock.image(
          ImageSource.url('https://example.com/image.jpg'),
        ),
        InputContentBlock.text('What is in this image?'),
      ]),
    ],
  ),
);

// After - From base64
InputMessage.userBlocks([
  InputContentBlock.image(
    ImageSource.base64(
      mediaType: ImageMediaType.jpeg,
      data: base64EncodedImageData,
    ),
  ),
  InputContentBlock.text('Describe this image'),
])

// After - Multiple images
InputMessage.userBlocks([
  InputContentBlock.image(ImageSource.url('https://example.com/cat.jpg')),
  InputContentBlock.image(ImageSource.url('https://example.com/dog.jpg')),
  InputContentBlock.text('Compare these two animals'),
])
```

## 8) Documents (New)

```dart
// Process PDFs and other documents
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 2048,
    messages: [
      InputMessage.userBlocks([
        InputContentBlock.document(
          DocumentSource.base64Pdf(base64PdfData),
          title: 'Research Paper',
        ),
        InputContentBlock.text('Summarize the key findings'),
      ]),
    ],
  ),
);
```

## 9) Extended Thinking (New)

```dart
// Enable Claude to think through complex problems
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 16000,
    thinking: ThinkingConfig.enabled(budgetTokens: 10000),
    messages: [
      InputMessage.user('Solve this complex math problem: ...'),
    ],
  ),
);

// Access the thinking process
if (response.hasThinking) {
  for (final block in response.thinkingBlocks) {
    print('Thinking: ${block.thinking}');
  }
}
print('Answer: ${response.text}');

// Streaming with thinking
await for (final event in client.messages.createStream(request)) {
  switch (event) {
    case ContentBlockDeltaEvent(:final delta):
      if (delta is ThinkingDelta) {
        print('Thinking: ${delta.thinking}');
      } else if (delta is TextDelta) {
        print('Response: ${delta.text}');
      }
    default:
      break;
  }
}
```

## 10) Token Counting (New)

```dart
// Count tokens before sending a request
final count = await client.messages.countTokens(
  TokenCountRequest(
    model: 'claude-sonnet-4-20250514',
    system: SystemPrompt.text('You are helpful.'),
    messages: [InputMessage.user('Hello, how are you?')],
  ),
);
print('Input tokens: ${count.inputTokens}');
```

## 11) Files API (New, Beta)

```dart
import 'dart:io' as io;

// Upload a file
final file = await client.files.upload(
  filePath: '/path/to/document.pdf',
  mimeType: 'application/pdf',
);
print('Uploaded: ${file.id}');

// List files
final files = await client.files.list(limit: 10);
for (final f in files.data) {
  print('${f.id}: ${f.filename}');
}

// Download a file
final bytes = await client.files.download(fileId: file.id);
await io.File('downloaded.pdf').writeAsBytes(bytes);

// Delete a file
await client.files.deleteFile(fileId: file.id);
```

## 12) Message Batches

```dart
// Before
final batch = await client.createMessageBatch(request: request);
final status = await client.retrieveMessageBatch(id: batch.id);
await client.cancelMessageBatch(id: batch.id);

// After - Now nested under messages
final batch = await client.messages.batches.create(
  MessageBatchCreateRequest(
    requests: [
      BatchRequestItem(
        customId: 'req-1',
        params: MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 512,
          messages: [InputMessage.user('Question 1')],
        ),
      ),
      BatchRequestItem(
        customId: 'req-2',
        params: MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 512,
          messages: [InputMessage.user('Question 2')],
        ),
      ),
    ],
  ),
);

// Check status
final status = await client.messages.batches.retrieve(batch.id);
print('Status: ${status.processingStatus}');

// Cancel if needed
await client.messages.batches.cancel(batch.id);

// Stream results (new!)
await for (final result in client.messages.batches.results(batch.id)) {
  print('${result.customId}: ${result.result}');
}
```

## 13) Exception Handling

```dart
// Before
try {
  await client.createMessage(request: request);
} on AnthropicClientException catch (e) {
  print('Error: ${e.message}');
}

// After - Specific exception types for targeted handling
try {
  await client.messages.create(request);
} on AuthenticationException catch (e) {
  print('Authentication failed: ${e.message}');
  // Check API key
} on RateLimitException catch (e) {
  print('Rate limited: ${e.message}');
  if (e.retryAfter != null) {
    final delay = e.retryAfter!.difference(DateTime.now());
    if (!delay.isNegative) {
      await Future.delayed(delay);
    }
    // Retry request
  }
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
  // Fix request parameters
} on ApiException catch (e) {
  print('API error (${e.statusCode}): ${e.message}');
  // Handle server errors
} on TimeoutException catch (e) {
  print('Request timed out after ${e.timeout}');
  // Retry or notify user
} on AbortedException catch (e) {
  print('Request was aborted');
  // Handle cancellation
}
```

## 14) Advanced Configuration

```dart
final client = AnthropicClient(
  config: AnthropicConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://custom-endpoint.example.com',
    timeout: Duration(minutes: 5),
    retryPolicy: RetryPolicy(
      maxRetries: 5,
      initialDelay: Duration(seconds: 2),
      maxDelay: Duration(minutes: 1),
    ),
    logLevel: Level.INFO,
    defaultHeaders: {'X-Custom-Header': 'value'},
    apiVersion: '2023-06-01',
  ),
);
```

## 15) Enum Type Changes

Some fields that were previously `String` are now typed enums for better type safety.

### Skill.source (String → SkillSource)

```dart
// Before
if (skill.source == 'anthropic') { ... }
final skills = await client.skills.list(source: 'anthropic');

// After
if (skill.source == SkillSource.anthropic) { ... }
final skills = await client.skills.list(source: SkillSource.anthropic);
```

### Message.role (String → MessageRole)

```dart
// Before
if (message.role == 'assistant') { ... }

// After
if (message.role == MessageRole.assistant) { ... }
```

## Common Pitfalls & Notes

* **Model IDs**: Now strings (`'claude-sonnet-4-20250514'`), not enum constants
* **Session cleanup**: `endSession()` → `close()`
* **Response helpers**: Use `.text`, `.hasToolUse`, `.toolUseBlocks`, `.thinkingBlocks`
* **Streaming**: Pattern matching with `switch/case` instead of `.map()`
* **Beta features**: Files and Skills APIs require specific beta headers (handled automatically)
* **Nested resources**: Batches are now at `client.messages.batches`, not `client.batches`

## Migration Checklist

- [ ] Update client initialization to use `AnthropicConfig` with `AuthProvider`
- [ ] Replace `client.createMessage()` with `client.messages.create()`
- [ ] Replace `client.createMessageStream()` with `client.messages.createStream()`
- [ ] Update model references from `Model.model(Models.xxx)` to string IDs
- [ ] Replace `Message(role:, content:)` with `InputMessage.user()` / `InputMessage.assistant()`
- [ ] Update content blocks from `Block.xxx()` to `InputContentBlock.xxx()`
- [ ] Update streaming handlers from `.map()` to `switch/case` pattern matching
- [ ] Replace `endSession()` with `close()`
- [ ] Update error handling to use specific exception types
- [ ] Use response helper properties (`.text`, `.toolUseBlocks`, etc.)
- [ ] Update batch operations to use `client.messages.batches`
