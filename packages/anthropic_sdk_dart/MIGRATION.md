# Migration Guide

This guide covers breaking changes between major versions of `anthropic_sdk_dart`.

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).

---

## Claude Platform on AWS

Use `AnthropicAwsClient` for the native regional Claude endpoint. Use the workspace's AWS region and ID, and supply an AWS-issued key or an IAM credential provider. A first-party Claude API key is replaced by the AWS credential when you change clients.

```dart
final client = AnthropicAwsClient(
  region: 'us-east-1',
  workspaceId: workspaceId,
  credentials: loadAwsCredentials,
);
```

Messages and streaming use the same Dart request types and Claude API version. AWS IAM determines available Admin and Compliance operations. [Claude Platform on AWS](https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws)


## Bedrock model API versions

Bedrock uses `2026-10-21` by default for Claude models that accept it. For Claude 4.6 and earlier, retain the version your deployed model already uses. Runtime moves that value into `anthropic_version` in the JSON request. Mantle sends it in the `anthropic-version` header.

```dart
final runtime = AnthropicBedrockClient(
  region: 'us-east-1',
  config: const AnthropicConfig(apiVersion: 'bedrock-2023-05-31'),
);
final mantle = AnthropicBedrockMantleClient(
  region: 'us-east-1',
  config: const AnthropicConfig(apiVersion: AnthropicConfig.legacyApiVersion),
);
```

The Bedrock clients expose Messages inference. Mantle uses the Claude count-tokens request and Runtime uses `countInvokeTokens` with the original InvokeModel body. Runtime stream exceptions surface as typed Claude error events. [Claude API version migration](https://platform.claude.com/docs/en/api/migration-2026-10-21) · [AWS token counting](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html)


## Claude API version 2026-10-21

The default API version changes from `2023-06-01` to `2026-10-21`. Every
request uses the configured version. A case-insensitive `anthropic-version`
entry in `defaultHeaders` takes precedence over `apiVersion`.

### Use the current Messages contract

Remove `temperature`, `topP` and `topK` from message creation and batch
parameters, including parameters set to their defaults.

```dart
// Before
final previous = MessageCreateRequest(
  model: 'claude-sonnet-4-6',
  maxTokens: 512,
  messages: [InputMessage.user('Give a short explanation of SSE.')],
  temperature: 0.2,
);

// After
final current = MessageCreateRequest(
  model: 'claude-sonnet-4-6',
  maxTokens: 512,
  messages: [InputMessage.user('Give a short explanation of SSE.')],
);
```

Move direct `document` blocks from assistant turns to user turns. Remove
nonempty citations from user text blocks, including text in search results, tool
results and structured document sources.
Assistant text citations, nested documents in tool results, and the
`citations: {enabled: true}` setting on a document or search result are still
supported. The Dart client raises `ValidationException` before sending these
incompatible inputs in Messages create, streaming, token count where applicable,
and batch create.

### Keep the legacy behavior when required

Select the legacy version explicitly if your application still needs the
previous sampling controls. The following example uses the first-party Claude
API. Separately configured Bedrock transports must keep their previous API
version for models older than Claude 4.7.

```dart
final client = AnthropicClient(
  config: AnthropicConfig.fromEnvironment().copyWith(
    apiVersion: AnthropicConfig.legacyApiVersion,
  ),
);
```

`ApiKeyProvider` continues to send the API key in `x-api-key`, which the Claude
API accepts. The pinned official SDKs send keys as Bearer by default.

The server migration also renames Admin and Enterprise Analytics response fields. [Claude API migration guide](https://platform.claude.com/docs/en/api/migration-2026-10-21) · [Runnable version example](example/api_version_example.dart)

---

## Move structured output to output_config.format

JSON deserialization for Messages creation, token counting, and batch items
accepts the deprecated beta `output_format` field. It converts that field to
`output_config.format` on the wire. When both fields contain a format, parsing
throws a `FormatException`.

```dart
// Before, a stored request could contain both format keys.
final duplicateFormat = {
  ...request.toJson(),
  'output_format': format.toJson(),
};

// After, keep the canonical format and remove the duplicate field.
final current = MessageCreateRequest.fromJson(
  Map<String, dynamic>.of(duplicateFormat)..remove('output_format'),
);
```

```dart
final format = JsonOutputFormat(schema: schema);
final request = MessageCreateRequest(
  model: 'claude-sonnet-5',
  maxTokens: 128,
  messages: [InputMessage.user('What is 2 + 2?')],
  outputConfig: OutputConfig(format: format, effort: EffortLevel.low),
);
```

For `client.messages.parse` and `parseStream`, provide the schema through
`StructuredOutput<T>` and leave the request's format unset. The helpers retain
the request's effort and task budget. Task budgets require a supported model
and `task-budgets-2026-03-13` in the call's beta flags.

---

## Handle automatic Managed Agents permissions

The Managed Agents beta adds `AutoPolicy` to the sealed `PermissionPolicy` type.
Handle it in exhaustive switches. This policy asks the server to evaluate
each tool call.

Before

```dart
String policyLabel(PermissionPolicy policy) => switch (policy) {
  AlwaysAllowPolicy() => 'Allow',
  AlwaysAskPolicy() => 'Ask',
  UnknownPermissionPolicy() => 'Other',
};
```

After

```dart
String policyLabel(PermissionPolicy policy) => switch (policy) {
  AlwaysAllowPolicy() => 'Allow',
  AlwaysAskPolicy() => 'Ask',
  AutoPolicy() => 'Evaluate each tool call',
  UnknownPermissionPolicy() => 'Other',
};
```

---

## Handle Managed Agents workflow variants

Existing coordinator configuration is still accepted. Use
`Multiagent20261001Params` to configure dynamic workflows and subagents.
Switches over the following sealed types need the new cases.

| Sealed type | New case |
| --- | --- |
| `MultiagentParams` | `Multiagent20261001Params` |
| `Multiagent` | `Multiagent20261001` |
| `SessionMultiagent` | `SessionMultiagent20261001` |
| `SessionEvent` | `WorkflowRunEvent` |
| `SessionStopReason` | `SessionRefusal` |

```dart
// Before
final mode = switch (config) {
  MultiagentCoordinatorParams() => 'Coordinator',
  UnknownMultiagentParams() => 'Unknown',
};

// After
final mode = switch (config) {
  MultiagentCoordinatorParams() => 'Coordinator',
  Multiagent20261001Params() => 'Dynamic workflows and subagents',
  UnknownMultiagentParams() => 'Unknown',
};
```

A session keeps the topology copied at creation. Create a new session to use
changes to the saved agent. Thread snapshots may contain `SessionInlineAgent`
without a saved ID or version. `SessionErrorEvent.errorDetails` adds typed access
while retaining the raw `error` object. Read paginated event history after a
disconnect. The Managed Agents stream delivers live events.
[Managed Agents workflow example](example/managed_agents_workflow_example.dart)

---

## Generally available User Profiles

Existing `client.userProfiles` calls use the legacy beta contract. Use
`client.userProfiles.current` to adopt the generally available contract.

```dart
// Legacy beta
final legacy = await client.userProfiles.create(
  const CreateUserProfileRequest(externalId: 'customer_123'),
);

// Generally available
final profile = await client.userProfiles.current.create(
  const CreateCurrentUserProfileRequest(
    externalUserDetails: UserProfileExternalUserDetails(referenceId: 'customer_123'),
  ),
);
```

When an existing profile already has an ID, retrieve that ID through the new
resource. The create endpoint creates a distinct profile on each successful
call. Under the current contract `referenceId` and `onboardedAt` are part of
`externalUserDetails`. Omit an external detail on update to keep it.
`programs` reports program status and `enforcementStatus` reports Anthropic's
overall enforcement state.

Use `createActionUrl(profile.id, action: UserProfileAction.enrollEndUser)` for
a current enrollment action. The URL is short-lived and grants access to the
recipient until expiration. Keep it out of application logs. Access to GA action
URLs is organization-gated. A 404 can indicate that the organization has no
access. On Claude Platform on AWS, use the legacy `createEnrollmentUrl` route.
[Verification Portal guide](https://platform.claude.com/docs/en/manage-claude/user-profiles-verification-portal#create-the-link)
[User Profiles reference](https://platform.claude.com/docs/en/api/user_profiles)

---

## Handle the between-tools thinking variant

The exported `ThinkingConfig` sealed type now includes `ThinkingBetweenTools`. Add a case to exhaustive switches over `ThinkingConfig`.

Before

```dart
String describeThinking(ThinkingConfig config) => switch (config) {
  ThinkingEnabled() => 'Manual budget',
  ThinkingDisabled() => 'Disabled',
  ThinkingAdaptive() => 'Adaptive',
};
```

After

```dart
String describeThinking(ThinkingConfig config) => switch (config) {
  ThinkingEnabled() => 'Manual budget',
  ThinkingDisabled() => 'Disabled',
  ThinkingAdaptive() => 'Adaptive',
  ThinkingBetweenTools() => 'Between tools',
};
```

Use `ThinkingConfig.betweenTools()` when the model accepts this setting. Check `model.capabilities?.thinking.types.betweenTools?.supported` and the model's effort restrictions before requesting it. [Claude Sonnet 5.5 migration guide](https://platform.claude.com/docs/en/models/sonnet-5-5/migration-guide)

---

## Handle thinking binding reports

`InputTransformation` now includes `ThinkingMismatchAllowedInputTransformation`. It reports a block that reached the model after a binding check failed. Add a case to exhaustive switches.

Before

```dart
String describeReport(InputTransformation report) => switch (report) {
  ThinkingDroppedInputTransformation(:final path) => 'Dropped $path',
  UnknownInputTransformation() => 'Unknown transformation',
};
```

After

```dart
String describeReport(InputTransformation report) => switch (report) {
  ThinkingDroppedInputTransformation(:final path) => 'Dropped $path',
  ThinkingMismatchAllowedInputTransformation(:final path) => 'Allowed $path',
  UnknownInputTransformation() => 'Unknown transformation',
};
```

For legacy auto-compaction, the latest `compaction_delta` replaces the earlier summary. A null summary marks a failed compaction. When a delta omits encrypted content, the accumulator retains the earlier payload. On-demand signed compaction arrives as a complete block at `content_block_start`. Use `finalMessage()` when replay depends on reaching `message_stop`.

---

## Read Admin scope and rate-limit groups

The current API version returns an API key's `scope`, including a real
`workspace_id` for a key scoped to the Default Workspace. The older
`workspace_id: null` shape can represent a Default Workspace key or an
organization-wide key. Read `scope?.type` to distinguish those cases in
current responses. For rate limits, use `groupType` to read both the current
`group.type` and the older top-level `group_type` response shape.

```dart
final key = await client.organization.apiKeys.retrieve(apiKeyId);
final scope = key.scope;
if (scope?.type == 'workspace') {
  final workspaceId = scope?.workspaceId;
  print(workspaceId);
}
```

[Claude Admin version migration](https://platform.claude.com/docs/en/api/migration-2026-10-21)

---

## Use the current Messages MCP connector

Declare each server in `MessageCreateRequest.mcpServers`, and reference its
name from a `McpConnectorToolset` in `tools`. Move enablement and allowlists
into the toolset's default and per-tool configs.

```dart
// Before
final oldRequest = request.copyWith(
  tools: [
    ToolDefinition.builtIn(BuiltInTool.mcp(
      serverDefinition: McpServerUrlDefinition(url: serverUrl),
    )),
  ],
);

// After
final currentRequest = request.copyWith(
  mcpServers: [McpConnectorServer(name: 'remote-tools', url: serverUrl)],
  tools: [
    ToolDefinition.builtIn(BuiltInTool.mcpConnector(serverName: 'remote-tools')),
  ],
);
final reply = await client.messages.create(
  currentRequest,
  betas: const ['mcp-client-2026-09-15'],
);
```

Handle `McpConnectorToolset` in exhaustive `BuiltInTool` switches and
`McpToolListingBlock` and `McpToolListingInputBlock` in exhaustive content
switches. `Message.toInputMessage()` converts the listing for replay.
[Runnable MCP example](example/mcp_example.dart)

---

## Handle OAuth bearer credentials

`AuthCredentials` adds the sealed `BearerTokenCredentials` case. Include
it in exhaustive switches. Avoid logging any credential value.

Before

```dart
String authKind(AuthCredentials credentials) => switch (credentials) {
  ApiKeyCredentials() => 'API key',
  NoAuthCredentials() => 'None',
};
```

After

```dart
String authKind(AuthCredentials credentials) => switch (credentials) {
  ApiKeyCredentials() => 'API key',
  BearerTokenCredentials() => 'OAuth',
  NoAuthCredentials() => 'None',
};
```

---

## Use current Files and Skills responses

Use `page` and `nextPage` for current Files and Skills pagination. Current
Files and Skills calls omit the historical beta headers by default, including
the official SDKs’ beta aliases. Pass beta names per call when using a current
beta capability. Scoped Files listing adds the Managed Agents beta header.

```dart
// Historical Files paging while explicitly opting into the old response.
const legacyFiles = ['files-api-2025-04-14'];
final previous = await client.files.list(betas: legacyFiles);
if (previous.hasMore == true) {
  await client.files.list(betas: legacyFiles, afterId: previous.lastId);
}

// Current Files paging.
final current = await client.files.list();
if (current.nextPage case final nextPage?) {
  await client.files.list(page: nextPage);
}
```

The historical `skills-2025-10-02` header returns a different Skill shape.
Remove it when using the current Dart Skill models. They use
`displayName`, `latestVersionId`, and `source.type`. To resolve the newest
version, pass `version: 'latest'` to `retrieveVersion` and use its returned
`id`. Deleting a skill on the current API deletes its versions too.
[Files migration](https://platform.claude.com/docs/en/build-with-claude/files#migrate-from-files-api-2025-04-14) · [Skills migration](https://platform.claude.com/docs/en/build-with-claude/skills-guide#migrate-from-skills-2025-10-02)

---

## Handle future stream events and batch results

`MessageStreamEvent` and `BatchResult` each gain a sealed case. Include the new
case in exhaustive switches. Use `toJson()` to retain the original payload
when forwarding an unfamiliar event or result.

```dart
// Before
switch (event) {
  case MessageStartEvent() || MessageDeltaEvent() || MessageStopEvent() ||
      ContentBlockStartEvent() || ContentBlockDeltaEvent() || ContentBlockStopEvent() ||
      PingEvent():
    updateView(event);
  case ErrorEvent():
    recordFailure(event.message);
}

// After
switch (event) {
  case MessageStartEvent() || MessageDeltaEvent() || MessageStopEvent() ||
      ContentBlockStartEvent() || ContentBlockDeltaEvent() || ContentBlockStopEvent() ||
      PingEvent():
    updateView(event);
  case ErrorEvent():
    recordFailure(event.message);
  case UnknownMessageStreamEvent():
    recordUnknownType(event.type);
}
```

```dart
// Before
final outcome = switch (batchItem.result) {
  BatchResultSucceeded() => 'succeeded',
  BatchResultErrored() => 'errored',
  BatchResultCanceled() => 'canceled',
  BatchResultExpired() => 'expired',
};

// After
final outcome = switch (batchItem.result) {
  BatchResultSucceeded() => 'succeeded',
  BatchResultErrored() => 'errored',
  BatchResultCanceled() => 'canceled',
  BatchResultExpired() => 'expired',
  UnknownBatchResult(:final type) => type,
};
```

`finalMessage()`, `collectText()`, the delta helpers, and `stopReason` report
in-band API failures as `MessageStreamFailure`. The exception extends
`StateError` and exposes the provider event, request ID and structured error
code. Use raw events or `accumulate()` to inspect partial output and the
terminal `ErrorEvent`.

---

## Handle unfamiliar stop reasons

`StopReason` adds `unknown`. Add that case to exhaustive switches. Read
`Message.stopReasonValue` or `MessageDelta.stopReasonValue` for the original
wire string. Completed Messages, streams and batch results preserve it.
`MessageDelta.hasStopReason`, `hasStopDetails`, and `hasStopSequence` distinguish
omitted stop fields from explicit nulls that clear their values. Use
`message.copyWith(stopReasonValue: null)` to clear the typed and original reason
in a copied message.

```dart
// Before
String stopStatus(StopReason? reason) => switch (reason) {
  null => 'pending',
  StopReason.endTurn => 'complete',
  StopReason.maxTokens || StopReason.stopSequence || StopReason.toolUse ||
      StopReason.pauseTurn || StopReason.compaction ||
      StopReason.modelContextWindowExceeded || StopReason.refusal => 'stopped',
};

// After
String stopStatus(StopReason? reason) => switch (reason) {
  null => 'pending',
  StopReason.endTurn => 'complete',
  StopReason.maxTokens || StopReason.stopSequence || StopReason.toolUse ||
      StopReason.pauseTurn || StopReason.compaction ||
      StopReason.modelContextWindowExceeded || StopReason.refusal => 'stopped',
  StopReason.unknown => 'unfamiliar provider stop',
};
```

---

## Handle inline tool definitions

`ToolChangeReference` adds `ToolChangeInlineDefinition`. Add a case to
exhaustive switches. `definition` exposes a known tool declaration, and
`toJson()` retains the original declaration including future variants.

```dart
// Before
final kind = switch (tool) {
  ToolChangeToolReference() => 'tool',
  ToolChangeMCPToolReference() => 'MCP tool',
  ToolChangeMCPToolsetReference() => 'MCP toolset',
  UnknownToolChangeReference() => 'unknown',
};

// After
final kind = switch (tool) {
  ToolChangeToolReference() => 'tool',
  ToolChangeMCPToolReference() => 'MCP tool',
  ToolChangeMCPToolsetReference() => 'MCP toolset',
  ToolChangeInlineDefinition() => 'inline definition',
  UnknownToolChangeReference() => 'unknown',
};
```

## Preserve nullable response citation fields

Copies of current document citations serialize `file_id` and `document_title`
as null when you clear either field. To export the historical omitted-key
shape, remove the cleared key explicitly. Use `message.toInputMessage()` to
replay the response as a request.

```dart
// Before
final legacy = citation.copyWith(fileId: null).toJson();

// After, when exporting the historical shape
final legacy = Map<String, dynamic>.of(
  citation.copyWith(fileId: null).toJson(),
)..remove('file_id');
```

---

## Handle custom document and uploaded image sources

Exhaustive switches over `DocumentSource` now include
`ContentBlockDocumentSource`. Exhaustive switches over `ImageSource` now
include `FileImageSource`.

```dart
// Before, image sources covered inline data and URLs.
final imageKind = switch (source) {
  Base64ImageSource() => 'inline',
  UrlImageSource() => 'url',
};

// After, handle an uploaded image reference as well.
final imageKind = switch (source) {
  Base64ImageSource() => 'inline',
  UrlImageSource() => 'url',
  FileImageSource() => 'uploaded',
};
```

```dart
// Before
final documentKind = switch (document) {
  Base64PdfSource() || UrlPdfSource() => 'pdf',
  PlainTextSource() => 'text',
  FileDocumentSource() => 'uploaded',
};

// After
final documentKind = switch (document) {
  Base64PdfSource() || UrlPdfSource() => 'pdf',
  PlainTextSource() => 'text',
  FileDocumentSource() => 'uploaded',
  ContentBlockDocumentSource(:final blocks) =>
    blocks == null ? 'custom text' : 'custom blocks',
};
```

[Claude Files API](https://platform.claude.com/docs/en/build-with-claude/files) · [Claude citations](https://platform.claude.com/docs/en/build-with-claude/citations)

---

## Preserve future Managed Agents event values

Construct typed events with their public typed arguments. To preserve a
future provider permission value, decode its wire event with `fromJson`.
Decode and copy provider data to retain unknown session and thread statuses
and omitted or explicit null `workflow_run_id`, `stop_details`, and
`url_sources` fields.

```dart
// Before, Dart exposed the parser-only constructor argument.
final event = AgentToolUseEvent(
  id: 'toolu_example',
  name: 'search',
  input: const {},
  rawEvaluatedPermission: 'future_permission',
  processedAt: DateTime.utc(2026, 11, 11),
);

// After, decode a provider event to retain its original permission value.
final event = AgentToolUseEvent.fromJson({
  'type': 'agent.tool_use',
  'id': 'toolu_example',
  'name': 'search',
  'input': <String, dynamic>{},
  'evaluated_permission': 'future_permission',
  'processed_at': '2026-11-11T00:00:00Z',
});
```

---

## Handle organization webhook event data

Exhaustive switches over `WebhookEventData` now include
`WebhookUserProfileEventData`. Its `event` identifies opened and resolved
profile enforcement actions and program-status updates. The first two event
types include `enforcementActionId`.

```dart
// Before, user-profile events reached the unknown payload case.
case UnknownWebhookEventData(:final rawJson):
  handleUnknown(rawJson);

// After, handle user-profile events with typed fields before the fallback.
case WebhookUserProfileEventData(:final event, :final id):
  handleProfileEvent(event, id);
case UnknownWebhookEventData(:final rawJson):
  handleUnknown(rawJson);
```

[Claude organization webhooks](https://platform.claude.com/docs/en/manage-claude/organization-webhooks)

---

## Move usage and cost reports to dimensioned analytics

The legacy Console and Enterprise reports remain available. Use
`client.organization.analytics.usage` or `cost` for dimensioned rows,
including reports grouped by actor or child organization. They add the
`analytics-usage-cost-2026-08-24` beta header.

```dart
// Legacy Console report with nested time buckets.
final legacy = await client.organization.analytics.messagesUsageReport(
  startingAt: start,
  endingAt: end,
  bucketWidth: AnalyticsBucketWidth.day,
  groupBy: const ['model'],
);
for (final bucket in legacy.data) {
  for (final row in bucket.results) {
    print('${bucket.startingAt} ${row.group.model}: ${row.usage.outputTokens}');
  }
}

// Dimensioned report with one row per bucket and dimension combination.
final current = await client.organization.analytics.usage(
  UsageCostAnalyticsQuery(
    startingAt: start,
    endingAt: end,
    timeBucketWidth: AnalyticsBucketWidth.day,
    groupBy: const ['model'],
    orderBy: 'time',
    order: 'asc',
  ),
);
for (final row in current.data) {
  print('${row.startingAt} ${row.group.model}: ${row.usage.outputTokens}');
}
```

Fill missing time buckets when comparing a dimensioned time series with a
legacy bucketed report. Use `AnalyticsFilter.actorId` in place of legacy
account or user ID filters. To reproduce an Enterprise per-user report, group
by `actor` and filter `AnalyticsFilter.actorType` to `user_actor`. Read
`row.group.actor?.emailAddress` for either the older `email` or the current
`email_address` field. Cost values retain their original decimal strings.
[Usage and cost migration guide](https://platform.claude.com/docs/en/manage-claude/usage-cost-analytics-api#migrate-from-the-usage-and-cost-api)

---

## Migrating from v9.x to v10.0.0

v10.0.0 adds document sources that reference uploaded files. `DocumentSource` is sealed, so exhaustive switches must handle the new `FileDocumentSource` variant.

### 1) Handle uploaded-file document sources

Add a `FileDocumentSource` case to switches over `DocumentSource`, or use a wildcard branch if your application does not need to distinguish source variants.

Before:

```dart
String describeSource(DocumentSource source) => switch (source) {
  Base64PdfSource() => 'Base64 PDF',
  PlainTextSource() => 'Plain text',
  UrlPdfSource(:final url) => url,
};
```

After:

```dart
String describeSource(DocumentSource source) => switch (source) {
  Base64PdfSource() => 'Base64 PDF',
  PlainTextSource() => 'Plain text',
  UrlPdfSource(:final url) => url,
  FileDocumentSource(:final fileId) => 'Uploaded file: $fileId',
};
```

To reference an uploaded file in a document block, use the new factory:

```dart
final document = InputContentBlock.document(
  DocumentSource.file('file_123'),
);
```

The source serializes as `{"type": "file", "file_id": "file_123"}`. Existing base64, text, and URL constructors keep their signatures.

---

## Migrating from v8.x to v9.0.0

v9.0.0 raises the minimum Dart SDK from 3.9 to 3.12. Applications and packages using Dart 3.9–3.11 must upgrade their toolchain before adopting this release.

### 1) Upgrade the Dart or Flutter SDK

Use Dart 3.12 or later. For Flutter projects, use a Flutter SDK that bundles Dart 3.12 or later; check the bundled version with `flutter --version`.

### 2) Update your pubspec

Before:

```yaml
environment:
  sdk: ">=3.9.0 <4.0.0"

dependencies:
  anthropic_sdk_dart: ^8.0.0
```

After:

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  anthropic_sdk_dart: ^9.0.0
```

Run `dart pub get` and your tests after updating. Flutter projects should use `flutter pub get` and `flutter test`.

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
