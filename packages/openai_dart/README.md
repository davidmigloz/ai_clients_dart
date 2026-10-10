# OpenAI Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[OpenAI API](https://platform.openai.com/docs/api-reference)** with Responses API, Decisions API, Chat Completions, images, videos, audio, custom tools, embeddings, evals, realtime, signed webhooks, safety detail retrieval, and more. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!TIP]
> Coding agents: start with [llms.txt](./llms.txt). It links to the package docs, examples, and optional references in a compact format.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Quickstart](#quickstart)
- [Why choose this client?](#why-choose-this-client)
- [Configuration](#configuration)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [Official Documentation](#official-documentation)
- [Sponsor](#sponsor)
- [License](#license)

</details>

## Features

### Generation and streaming

- Responses API with streaming, multi-turn conversations, structured output, background mode, cache prewarming, and typed cache diagnostics
- Decisions API for typed predicate, choice, and score answers from text or data URL/HTTP(S) images
- Chat Completions with tool calling, vision, structured output, detailed usage, audio completion/streaming, and obfuscation controls
- Images, videos, audio (TTS, transcription, translation), and embeddings
- Realtime API via WebSocket and WebRTC with audio streaming
- Live HTTP signaling, primary/sideband WebSockets, typed events and explicit call controls
- Input token counting via `inputTokens` for cost estimation

### Tools

- Web search, file search, code interpreter, computer use, and custom tools
- Async function/custom tools with faithful call replay and conversation metadata

### Operational APIs

- Saved agent CRUD with persisted function, MCP, web search and computer-use configuration through `client.agents`
- Durable sessions with JSON/SSE creation, persistent raw event observation, manual function/approval input and explicit cancellation through `client.agents.sessions`
- Root session/turn history and currently published OTLP trace pages through session items, turns and traces resources
- Vault CRUD and write-only credential creation/rotation with safe returned authentication metadata
- Owned hosted environment prewarming and reusable environment template CRUD with safe metadata views
- Files, uploads, batches, fine-tuning, moderations, evals, and model management
- Conversations, containers, content provenance checks, ChatKit, and skills
- Local signed webhook verification with 26 typed received event variants, plus project endpoint management/discovery
- Read-only project safety alerts and organization cases through `client.safety`
- Shared typed monitoring details on HTTP/failed Responses/WebSocket errors, with canonical flat SSE errors
- Assistants and vector stores (deprecated — use Responses API instead)

See [API Coverage](#api-coverage) for the full coverage table.

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `crypto`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Supports OpenAI generation, media, operational, and Realtime APIs; see the coverage table for remaining gaps.
- Resource-based API design matching official SDKs.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

Requires Dart 3.12 or later. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

```yaml
dependencies:
  openai_dart: ^10.0.1
```

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('What is the capital of France?'),
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}
```

### Import structure

The package provides multiple entry points for different APIs:

```dart
// Main entry point (recommended) — includes Chat Completions, Responses API,
// Embeddings, Images, Videos, Audio, Files, Batches, Fine-tuning, and more.
import 'package:openai_dart/openai_dart.dart';

// Assistants API (deprecated — use Responses API instead)
import 'package:openai_dart/openai_dart_assistants.dart' as assistants;

// Realtime API — WebSocket and WebRTC sessions
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
```

## Configuration

<details>
<summary><b>Configure auth, retries, and custom endpoints</b></summary>

Use `OpenAIClient.fromEnvironment()` for the default `OPENAI_API_KEY` workflow. Switch to `OpenAIConfig` when you need a proxy, custom timeout, or a non-default retry policy.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient(
  config: OpenAIConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://api.openai.com/v1', // Default
    timeout: Duration(minutes: 10),
    connectTimeout: Duration(seconds: 30),
    retryPolicy: RetryPolicy(maxRetries: 3),
    organization: 'org-xxx', // Optional
    project: 'proj-xxx', // Optional
  ),
);
```

**From environment variables:**

```dart
final client = OpenAIClient.fromEnvironment();
// Reads OPENAI_API_KEY, OPENAI_BASE_URL, OPENAI_ORG_ID, OPENAI_PROJECT_ID
// Also reads optional OPENAI_WEBHOOK_SECRET for local verification.
```

**With API key directly:**

```dart
final client = OpenAIClient.withApiKey('sk-...');
```

**Custom base URL (for proxies or Azure):**

```dart
final client = OpenAIClient(
  config: OpenAIConfig(
    baseUrl: 'https://my-resource.openai.azure.com/openai/deployments/my-deployment',
    authProvider: AzureApiKeyProvider('YOUR_AZURE_KEY'),
  ),
);
```

</details>

## Usage

### How do I save and update an agent configuration?

Use `client.agents` to create, list, retrieve, update and delete reusable agent
configuration. These five operations use your ordinary API key and project context,
and force `OpenAI-Beta: agents=v1` after caller headers. Creating an agent stores
configuration; it does not start a session, execute tools or run a model.

```dart
final agent = await client.agents.create(
  CreateAgentRequest(
    model: 'gpt-6-astra',
    name: 'Research assistant',
    reasoning: AgentReasoningConfig(summary: AgentReasoningSummaryParam.auto),
    serviceTier: AgentServiceTierParam.fast,
    tools: [
      AgentTool.function(
        name: 'lookup',
        description: 'Look up an application-provided reference.',
        parameters: {
          'type': 'object',
          'properties': {'query': {'type': 'string'}},
        },
      ),
    ],
  ),
);
final page = await client.agents.list(limit: 10, order: AgentListOrder.asc);
if (page.hasMore && page.lastId != null) {
  await client.agents.list(
    limit: 10,
    order: AgentListOrder.asc,
    after: page.lastId,
  );
}
final saved = await client.agents.retrieve(agent.id);
final reset = await client.agents.update(
  saved.id,
  UpdateAgentRequest(clearName: true, clearReasoning: true, metadata: {}),
);
assert(reset.name == null);
final deletion = await client.agents.delete(saved.id);
assert(deletion.deleted);
```

Update omission keeps a field unchanged. Supplied objects, lists and maps replace
the whole field. For example, `reasoning: AgentReasoningConfig(effort: ...)` replaces
the saved reasoning configuration, including its summary. `clearReasoning: true`
sends explicit JSON null to reset it; `clearName`, `clearTools` and `clearMetadata`
clear those fields. Copies distinguish omission from explicit null, and `clearX`
wins over a simultaneous value. An absent create field leaves the service default
in control. The requested model string is retained without normalization.

Saved-agent tools have separate request and received types. `AgentTool` supports
function, tool search, programmatic tool calling, MCP, web search and computer use.
Persisted MCP HTTP/stdio configuration is credential-free; an optional credential
ID refers to a vault credential rather than embedding a secret. `AgentTextConfig`
supports plain text or JSON Schema output, and `AgentMultiAgentConfig` configures
subagent availability without running subagents. Future received tool/transport
variants and enum strings are retained; unknown request variants are rejected.

Request limits are checked in release builds: names use at most 128 Unicode
characters, metadata at most 16 pairs with 64-character keys and 512-character
values, and tools at most 2,000 entries / 3 MiB of compact UTF-8 JSON. Returned
resources follow their separate limits. Page cursors may be null on empty pages;
keep the same order and limit when using `lastId` as `after`. Opaque path IDs are
encoded as one segment; empty and exact dot segments are rejected as local URI
safeguards. Configuration and HTTP diagnostics redact private payloads, while
explicit properties and `toJson()` remain available to the caller.

Injected HTTP clients remain caller-owned. Durable sessions, root/turn history
and published traces are available through `client.agents.sessions`; Vaults and
write-only credentials use `client.vaults`. Owned environments and templates use
`client.agents.environments` and `.templates`; live files use `.files` and
published artifacts use `client.agents.sessions.artifacts`. Subagent state and child item/turn history use `client.agents.sessions.subagents`. The runnable example exercises all six saved tool types,
pagination, replacement, clear/reset and deletion with seven mock requests and
explicit transport cleanup, without an API key or paid API call.

→ [Offline saved-agent example](example/saved_agents_example.dart)

### Durable agent sessions

`client.agents.sessions` creates sessions as HTTP 201 JSON or, through
`createStream`, HTTP 201 SSE. It also lists, retrieves, updates and deletes sessions.
`events.stream` observes HTTP 200 SSE, and `events.create` submits inputs with
HTTP 202 empty acceptance. The caller handles function results and browser approvals
explicitly; the client does not run callbacks or provision a self-hosted executor.

```dart
final session = await client.agents.sessions.create(CreateAgentSessionRequest(
  agent: AgentSessionAgentConfig(model: 'requested-model'),
  environment: AgentSessionEnvironment.none(),
  input: AgentSessionInitialInput.text('Hello'),
));
final observer = client.agents.sessions.events.stream(session.id).listen((event) {
  // Handle typed AgentSessionRequiresActionEvent and other raw events here.
});
await client.agents.sessions.events.create(session.id,
  CreateAgentSessionEventsRequest(events: [AgentSessionInput.cancel()]),
);
await observer.cancel();
```

Subscribe before submitting new work. Observation stays open through idle, required
actions, turn completion and typed error events. Cancelling an observer or reaching
HTTP EOF releases observation only; neither proves completion nor cancels or deletes
durable work. Cancel input has no target turn ID. Retrieve or observe cancellation
before the separate DELETE action. GET observation has no replay cursor and does
not reconnect automatically.

Inline agent configuration needs a model if no saved `agentId` is supplied.
Environment `none` needs initial input; streamed hosted creation also needs input.
Self-hosted creation may wait for executor connectivity. Saved agents, Vaults and
prewarmed environments are optional. An existing hosted `environmentId` excludes
all inline/template/container fields, including explicitly null desktop settings.
Supplied saved-agent overrides replace configuration fields.

Spending controls use whole USD cents up to `4503599627370495`. Create omission/null
is unlimited; update omission retains the cap, while `clearSpendControl: true` or
`AgentSessionSpendControlConfig(limit: null)` removes it without resetting spend.
This session cap is separate from organization usage tiers and rate limits.

Follow-up inputs and initial input/output schemas have a 4 MiB compact UTF-8 JSON
budget; service metadata adds overhead. Browser authentication values have a 120 KiB
JSON budget and are never automatically retried, even by configured interceptors.
After uncertain delivery, retrieve current required actions before deciding whether
to resubmit. No authentication values are saved to local history. Default logging
and diagnostics redact private session URLs, headers, tokens, commands and archives.
Use idempotency keys of 1–256 Unicode characters for logical event submissions;
this endpoint makes no 24-hour retention promise.

→ [Offline durable-session example](example/agent_sessions_example.dart) — inline
creation, persistent observation, manual function result, cap changes and explicit
cancellation followed by deletion; no live calls or API key ($0).


### Session history and traces

Read known session IDs without creating a session or resuming observation:

```dart
final sessions = client.agents.sessions;
final items = await sessions.items.list('session_id', limit: 20,
  order: AgentListOrder.asc);
final turns = await sessions.turns.list('session_id', order: AgentListOrder.asc);
final turn = await sessions.turns.retrieve('session_id', 'turn_id');
final turnItems = await sessions.turns.items.list('session_id', 'turn_id');
final traces = await sessions.traces.list('session_id', limit: 1,
  order: AgentListOrder.asc);
```

All four list methods accept `limit` (1–100), `order` and exclusive `after` IDs.
Use `lastId` with the same order/context for the next page; empty boundaries remain
null. Root history includes coordinator interactions with children; each child has
separate history. The 17 typed history branches include safe browser authentication
records without submitted form-value fields. Historical function/approval output
is inspection state and does not authorize replaying an action. Required-nullable
turn usage, errors and timestamps remain present; a terminal turn is distinct from
session idle or observer EOF, and recorded usage is not a final spending ledger.

`traces.list` returns finite, deeply owned arbitrary OTLP maps with private default
diagnostics. Trace IDs are root-turn pagination anchors. Pages contain only data
published when read, skip unpublished traces and never await late updates. A page
sequence therefore does not promise a complete historical export. The service limits
trace reads and JSON responses to 16 MiB per request; request fewer traces when it
reports that limit. API exceptions retain status and explicit caller-readable HTTP
context while default logging and messages redact private payloads.

Trace export must be enabled for the organization. The key must belong to the
session's project and have `api.traces.read` or `api.agents.read` permission.

→ [Offline session-history example](example/agent_session_history_example.dart) —
known-ID root/turn inspection and two trace pages, with no live calls or key ($0).


### Agent environments and templates

Reuse hosted configuration and prewarm an owned environment through
`client.agents.environments`:

```dart
final templates = client.agents.environments.templates;
final template = await templates.create(CreateAgentEnvironmentTemplateRequest(
  name: 'Reusable setup',
  network: AgentSessionNetworkPolicyConfig(
    access: AgentSessionNetworkAccessConfig.disabled),
));
await templates.retrieve(template.id);
await templates.list(limit: 20, order: AgentListOrder.desc);
await templates.update(template.id, UpdateAgentEnvironmentTemplateRequest(
  clearNetwork: true, clearDesktop: true, name: 'Updated setup'));
final environment = await client.agents.environments.create(
  CreateAgentEnvironmentRequest(environment: AgentPrewarmEnvironment.openaiHosted(
    environmentTemplateId: template.id)),
  idempotencyKey: 'my-application-prewarm-001',
);
await client.agents.environments.list(type: AgentEnvironmentType.openaiHosted);
await client.agents.environments.retrieve(environment.id);
await templates.delete(template.id);
```

Prewarming is beta and requires account eligibility. Its hosted-only configuration
has no `environmentId` or `containerSize`, and accepts at most ten vault IDs.
Sessions have a separate environment attachment contract. Shared hosted configuration
supports packages, desktop, network, variables, setup commands, capability directories,
file-ID or plain-base64 inline files, skill references or inline ZIP skills, and inline
ZIP plugins. These reuse the corresponding `AgentSession...Config` types because the
canonical contracts are identical. File destinations stay within `/workspace`;
capability and setup directories are absolute. Inline files allow 5 MiB decoded
bytes per file and 10 MiB total per submitted configuration. Template-inherited
combined limits and Files API sizes are checked by the service. The API validates
archive contents.

Templates apply before inline settings; network overrides cannot broaden their
policy. Omitted network defaults belong to the API version. On template update,
omission preserves a field, `clearNetwork: true` resets network policy, and
`clearDesktop: true` disables desktop. Maps and arrays replace complete fields.
Package installation and setup run before the runtime network policy takes effect.

Returned environments expose ID, hosting type, status and installed safe file/skill/plugin
metadata; templates also expose timestamps and safe configuration metadata. They never
recover confidential setup command bodies, environment values or inline contents from
request caches. Template file references and skill version selectors remain distinct
from installed environment metadata. Received future values retain their wire strings
with private diagnostics; malformed known resource values fail privately.

Environment creation keys have 1–256 Unicode characters. The service deduplicates for
24 hours within the authenticated organization/project/creator. Retry the same JSON
and key for current state; mismatched parameters or incomplete creation return HTTP
409. Retained deleted keys do not recreate environments. After retention expires the
key may create a fresh environment; without a key each call creates anew. The client
carries the header and surfaces service responses, with no local deduplication cache.

All seven statuses—pending, ready, connected, disconnected, suspended, expired and
failed—are represented. Session, environment, provider and artifact lifetimes are
independent. Status names do not imply environment suspend/resume/reset/delete methods;
template deletion does not promise cleanup of sessions, environments or artifacts.

→ [Offline environments example](example/agent_environments_example.dart) — all eight
operations with mock HTTP, no API key or paid prewarming ($0).

### Agent environment files and published artifacts

Live workspace files require a connected hosted environment. Copy an existing
Files API file ID or standard-base64 bytes into a hosted path:

```dart
final files = client.agents.environments.files;
await files.create(environmentId, AgentSessionHostedEnvironmentFileConfig.fileId(
  fileId: existingFileId, path: '/workspace/input.bin'));
await files.create(environmentId, AgentSessionHostedEnvironmentFileConfig.inline(
  data: base64Encode(inputBytes), path: '/workspace/another.bin'));
final page = await files.list(environmentId, path: '/workspace', limit: 20,
  order: AgentListOrder.asc);
if (page.next != null) {
  await files.list(environmentId, path: '/workspace', limit: 20,
    order: AgentListOrder.asc, page: page.next);
}
final artifacts = client.agents.sessions.artifacts;
final published = await artifacts.list(sessionId, environmentId: environmentId);
final artifact = await artifacts.retrieve(sessionId, published.data.first.id);
final bytes = await artifacts.download(sessionId, artifact.id);
await for (final chunk in artifacts.downloadStream(sessionId, artifact.id)) {
  // Consume exact binary chunks in the application.
}
await artifacts.delete(sessionId, artifact.id);
```

Import `dart:convert` for `base64Encode`. Inline files accept standard base64,
including empty data, and at most 5 MiB decoded per file; this field does not
accept a data URL. File destinations are absolute POSIX paths under `/workspace`.
The service checks existing destinations, symlinks, component lengths and the
50 MiB limit for Files API references. The client does not read a local path or
upload a local file automatically. After an uncertain copy, check the destination
before retrying; copying is a side effect and has no local deduplication cache.

Live pages use `object: page`, opaque `next`/`page` tokens and required nullable
`next`. Keep directory, limit and order consistent between pages. Artifact pages
instead use `firstId`/`lastId`, and advance with `after: page.lastId`, retaining
order and environment filter. Null query arguments are omitted. Empty pages keep
null boundary values. File metadata has environment/path/size; artifact metadata
also has immutable ID, session and completed-turn ownership, and publication time.

Outputs under `/workspace/outputs` are published as immutable artifacts when a
hosted turn completes. Published copies survive environment expiry; unpublished
outputs are not guaranteed to survive cancellation or session deletion. Download
anything to retain before deleting the session. Self-hosted files use the
provider's filesystem API. Service limits are 200 MiB per artifact and 500 MiB
per co-publication; metadata sizes have no client-imposed upper limit.

Downloads preserve arbitrary bytes, including NUL and non-UTF-8 data, with no
JSON/text decoding. `download` buffers in memory; `downloadStream` is incremental
and uses the existing private byte transport without replay or interceptors.
Both force Agents beta and octet-stream Accept, preserve auth/project context,
and apply header/active-read timeouts. Pause suspends the body idle deadline.
Abort or subscription cancellation releases this local download only; it does
not delete an artifact or cancel a turn. Injected HTTP clients remain borrowed;
a distinct `streamClientFactory` client is operation-owned. Hosted paths are never
chosen as local destinations. Deleting an artifact leaves the live file intact.

→ [Offline files and artifacts example](example/agent_files_artifacts_example.dart)
— stages input, pages live files and downloads exact bytes after mocked expiry,
with all six endpoints, no API key or paid execution ($0).

### Agent session subagents

Inspect service-owned children separately from the root coordinator's history:

```dart
final subagents = client.agents.sessions.subagents;
final children = await subagents.list(sessionId, limit: 20);
final child = await subagents.retrieve(sessionId, children.data.first.id);
final rootItems = await client.agents.sessions.items.list(sessionId);
final childItems = await subagents.items.list(sessionId, child.id,
  limit: 20, order: AgentListOrder.asc);
if (childItems.lastId != null) {
  await subagents.items.list(sessionId, child.id,
    limit: 20, order: AgentListOrder.asc, after: childItems.lastId);
}
final turns = await subagents.turns.list(sessionId, child.id,
  limit: 20, order: AgentListOrder.asc);
final turn = await subagents.turns.retrieve(sessionId, child.id, turns.data.first.id);
final turnItems = await subagents.turns.items.list(sessionId, child.id, turn.id);
```

All six methods are inspection GETs, using ordinary auth/project/HTTP policy and
forced `OpenAI-Beta: agents=v1`. Known IDs are independently callable: no new
coordinator turn or local worker process is required. The child list has a typed
`AgentSessionSubagentList` envelope for the actual inline response. Every list
uses exclusive ID `after` pagination with limit 1–100, order and required nullable
first/last boundaries. Keep the same order and parent IDs between pages; null
query arguments are omitted. Opaque IDs are encoded separately at every level;
empty and exact dot segments are rejected as local URI safeguards.

Child `name`, `instructions` and `closedAt` are required nullable received fields.
Instructions preserve output-text/encrypted-content branches; text may include
service-provided placeholders for image/audio previews. No missing content is
reconstructed. A closed child may later resume: its original `openedAt` remains
unchanged and `closedAt` becomes null. These are service-owned state transitions;
a GET does not trigger them. Child turns retain their own IDs, nullable
start/completion/error/usage, and canonical creation-time ordering.

Root coordinator interactions and child history are separate collections. Child
history reuses all 17 canonical item branches and the complete shared turn shape,
including browser-safe history and finite private future values. Reading a past
tool, approval or subagent-call item grants no permission to replay it. This
resource has no child create, resume, interrupt or close HTTP action, and does
not start independent workers/providers. Private instructions, content and
metadata stay out of default diagnostics; explicit fields and `toJson()` remain
caller-readable. Borrowed transport ownership and local request abort behavior
follow the ordinary client policy.

→ [Offline subagent inspection example](example/agent_subagents_example.dart) —
all six inspection routes, root versus child history, separate turn items and
received closed/resumed state using nine mock GETs, with no key or paid execution ($0).

### Vaults and write-only credentials

Manage Vaults independently of session creation through `client.vaults`:

```dart
final vault = await client.vaults.create(CreateVaultRequest(name: 'Example Vault'));
final credentials = client.vaults.credentials;
final credential = await credentials.create(vault.id,
  CreateVaultCredentialRequest(name: 'Hosted API credential',
    auth: CreateVaultEnvironmentVariableAuth(secretName: 'SERVICE_API_KEY',
      secretValue: 'application-supplied-secret',
      networking: VaultCredentialNetworking.limited(
        allowedHosts: ['api.example.com']))));
await client.vaults.retrieve(vault.id);
final vaultPage = await client.vaults.list(metadata: {'application': 'demo'},
  status: VaultStatusFilter.single(VaultStatus.active));
await client.vaults.update(vault.id, UpdateVaultRequest(metadata: {}));
final safe = await credentials.retrieve(vault.id, credential.id);
final credentialPage = await credentials.list(vault.id, limit: 20);
await credentials.rotate(vault.id, credential.id,
  RotateVaultCredentialRequest(auth: RotateVaultEnvironmentVariableAuth(
    secretValue: 'application-supplied-replacement'), metadata: {}));
await credentials.delete(vault.id, credential.id);
await client.vaults.delete(vault.id);
```

Read real secrets from application-owned secret storage; the snippet illustrates
transport fields. Creation supports `mcp_oauth`, `static_bearer` and
`environment_variable` through separate create, rotation and returned auth unions.
Returned auth has no token/access-token/refresh-token/client-secret/secret-value
readback fields. Known write-only fields in malformed returned auth are rejected;
other finite future fields remain privately owned. Default diagnostics redact
request bodies, metadata, URLs, headers and received values. Explicit exception
fields retain HTTP context for deliberate inspection.

Rotation needs `auth` or `metadata` and cannot change auth method, destination,
environment secret name or networking. Omitted OAuth expiry preserves it unless
a new access token is supplied; a new token without expiry or explicit-null expiry
clears it. Omitted/null refresh tokens and client secrets retain stored secrets;
omitted scope retains it and explicit null clears it. Nullable request fields use
`clearX: true` to emit JSON null; these flags express wire presence, whose storage
meaning follows the individual field. Metadata update/rotation is optional
nonnull: omission retains, `{}` clears, and JSON null is invalid.

Names retain their supplied spelling and must contain 1–256 UTF-8 bytes after
trimming. Vault creation metadata permits 1,024 pairs with 256-character keys and
1,048,576-character values and supports explicit null; vault updates, credential
creation/rotation and list filters use 16 pairs, 64-character keys and
512-character values. List metadata uses `metadata[key]=value` with AND matching
and eventual consistency. Scalar status uses `status`; arrays use repeated
`status[]`. Both active and archived are included by default; an empty status
array supplies no pairs. Lists accept limits 1–100 and exclusive `after` IDs;
reuse `lastId` with the same order/filters, and retain nullable empty-page boundaries.

Hosted environment-variable secrets supply placeholders to sandbox code, with
substitution only for allowed outgoing HTTPS requests on ports 443/8443. The
environment network policy must also permit the destination. Credential networking
`unrestricted` requires restricted environment network access with explicit
`allowed_domains`; it does not grant unrestricted sandbox networking. Limited
networking permits 1–16 distinct hostnames/IPv4 addresses after lowercase
normalization, without scheme/path/port/wildcard/IPv6. Request host spelling remains
intact for service normalization. Secret names use ASCII identifier syntax;
`CODEX_*` and managed proxy/certificate names are reserved. Known conventional
proxy/certificate names are rejected locally; additional managed names remain
service-owned. Secret values are nonempty and reject CR/LF/NUL.

Placeholders cannot supply secrets for local computation, self-hosted environments
or application function tools. Rotation affects values used by new sessions or
environments and does not promise immediate replacement inside an existing sandbox.
Provider OAuth consent/revocation stays caller-owned; deleting a stored credential
or Vault does not revoke provider tokens or cancel running work.

→ [Offline Vaults example](example/vaults_example.dart) — all ten operations,
synthetic write-only secrets and safe returned metadata, no live API or key ($0).


### How do I classify or score shared input?

The [Decisions API](https://developers.openai.com/api/reference/resources/decisions/methods/create) returns ordered typed answers to predicate, choice, and score questions. It currently supports `gpt-6-luna` and accepts text, inline data URLs and publicly accessible HTTP(S) images.

```dart
final decision = await client.decisions.create(
  DecisionRequest(
    model: 'gpt-6-luna',
    input: DecisionInput.text('The screen arrived broken.'),
    questions: [
      DecisionQuestion.predicate(
        name: 'damaged',
        instructions: 'Does the customer report a damaged item?',
      ),
    ],
  ),
);

for (final answer in decision.answers) {
  if (answer case PredicateDecisionAnswer(:final probability)) {
    print('Damage probability: $probability');
  } else if (answer case RefusalDecisionAnswer()) {
    print('The question was refused.');
  }
}
```

Use `DecisionInput.messages` with `DecisionContent.parts` for mixed text/image input. `DecisionInputPart.image(imageUrl: ...)` accepts a data URL or a publicly accessible HTTP(S) URL; `DecisionInputPart.imageBytes(bytes, mediaType: 'image/png')` builds the MIME/base64 data URL. File IDs, other roles, tools, and audio are unsupported. Unset image detail defaults to `auto` on the server.

```dart
final image = DecisionInputPart.image(
  imageUrl: 'https://images.example.com/product.png',
  detail: ImageDetail.original,
);
final inline = DecisionInputPart.imageBytes([1, 2, 3], mediaType: 'image/png');
```

Image constructors, parsers and copies admit the case-sensitive prefixes `data:`,
`http://` and `https://`, preserving the supplied string. OpenAI checks image
validity and public accessibility; the Dart client sends the reference without
downloading or normalizing it. The current HTTP reference and schema support
remote images; older guide and SDK descriptions may still say inline-only.
→ [Offline HTTP(S)/inline image example](example/decision_image_urls_example.dart)
verifies one mock POST, exact URL strings, mixed part order and image details at $0 cost.

Requests support 1–200 questions, 2–255 choices per choice question, 2–10 levels per score question, and up to 128 images across all messages. An optional `safetyIdentifier` is limited to 128 characters. Choice values preserve strings and booleans as distinct types; score answers can be fractional. Refusals can occur alongside successful answers. There is no model-event streaming mode.

→ [Full example](example/decisions_example.dart)

### How do I configure an execution container?

Create a standalone container with a memory tier and network policy, then pass its ID to Code Interpreter:

```dart
final container = await client.containers.create(
  CreateContainerRequest(
    name: 'my-container',
    memoryLimit: ContainerMemoryLimit.gb1,
    networkPolicy: ContainerNetworkPolicy.disabled,
  ),
);

final tool = ResponseTool.codeInterpreter(
  container: CodeInterpreterContainer.id(container.id),
);
// Use tool in a Responses request, then delete the container when finished.
await client.containers.delete(container.id);
```

The current memory tiers are `gb1`, `gb4`, `gb16`, and `gb64`, which emit `1g`, `4g`, `16g`, and `64g`. Automatic containers accept the same configuration through `CodeInterpreterContainer.auto(...)`. An allowlist uses `ContainerNetworkPolicy.allowlist(['api.example.com'], domainSecrets: [...])`, with typed `ContainerNetworkPolicyDomainSecret` entries. Secret values are redacted in model diagnostics.

Standalone creation also supports `ContainerSkill.reference(skillId: ..., version: 'latest')` and inline skills whose `ContainerSkillSource.base64(data: ...)` contains an already encoded ZIP bundle. Returned memory/network settings and expiration members can be absent; check them before use. Filter listing with `client.containers.list(name: 'my-container')`.

See the [migration guide](MIGRATION.md#upcoming-container-configuration-corrections) for changes to integer memory values, `allowedHosts`, required names, response expiration, and const construction.

→ [Full example](example/containers_example.dart)

### How do I create a response?

<details>
<summary><b>Show example</b></summary>

The Responses API is the recommended way to generate text. Pass a model and input, and access the result via `response.outputText`.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-5.5',
    input: ResponseInput.text('What is the capital of France?'),
  ),
);

print('Response: ${response.outputText}');
print('Usage: ${response.usage}');

client.close();
```

→ [Full example](example/responses_example.dart)

</details>

### How do I use persistent Responses WebSockets?

<details>
<summary><b>Show example</b></summary>

On native Dart/Flutter, open an authenticated connection through the existing
client configuration and read its lane-aware envelopes:

```dart
final connection = await client.responses.connect();
final latest = <String, String>{};
final bothLaneCompletions = Completer<void>();
final subscription = connection.events.listen(
  (message) {
    if (message case ResponsesStreamEvent(
      streamId: final lane?,
      event: ResponseCompletedEvent(:final response),
    )) {
      latest[lane] = response.id;
      if (latest.containsKey('planner') &&
          latest.containsKey('research') &&
          !bothLaneCompletions.isCompleted) {
        bothLaneCompletions.complete();
      }
    } else if (message is ResponsesErrorEvent) {
      // Inspect message.error.code and message.status to choose lane recovery.
      if (!bothLaneCompletions.isCompleted) {
        bothLaneCompletions.completeError(
          StateError('A lane request failed.'),
        );
      }
    }
  },
  onError: (Object error) {
    // Protocol/transport failures are identifiable, payload-redacted exceptions.
    if (!bothLaneCompletions.isCompleted) {
      bothLaneCompletions.completeError(error);
    }
  },
  onDone: () {
    if (!bothLaneCompletions.isCompleted) {
      bothLaneCompletions.completeError(
        StateError('Connection closed before both lanes completed.'),
      );
    }
  },
);
try {
  await Future.wait<void>([
    Future<void>.sync(
      () => connection
        ..create(
          const CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.text('Draft a plan.'),
          ),
          streamId: 'planner',
        )
        ..create(
          const CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.text('Research the risks.'),
          ),
          streamId: 'research',
        ),
    ),
    bothLaneCompletions.future,
  ], eagerError: true);
} finally {
  try {
    await connection.close();
    await connection.done;
  } finally {
    await subscription.cancel();
  }
}
```

`streamId` routes events and orders requests within a lane; `previousResponseId`
selects ancestry. Continue with the actual returned ID and only new input. A lane
reused without a parent starts a new response. `generate: false` warms state and
returns an ID for subsequent chaining. These are WebSocket-only fields;
`ResponsesCreateEvent` composes the normal request, omits `stream`/false
`background`, rejects `background: true`, and retains `streamOptions`.

Response completion and request-scoped server errors leave the connection open.
`ResponsesErrorEvent` retains full error metadata and absent-versus-null
`code`/`param`. Shared events use `ResponsesStreamEvent.event`; future events
retain raw JSON. One socket reader emits interleaved envelopes. The first listener
receives buffered early events, including events before an early close; the default
opening capacity is 1,024 and overflow fails explicitly. After the first listener,
only active subscribers receive broadcasts. Cancelling a listener removes that
listener; explicitly await connection cleanup. `done` completes independently of
event draining. By default, close code/reason expose observed transport facts;
with recovery enabled they describe final logical closure as detailed below.

Browser WebSockets cannot send custom headers. Any configured auth/default/org/
project/version headers reject before dialing with proxy guidance. Use an explicit
headerless client configuration and an authenticated backend WebSocket proxy.
`additionalHeaders` and configured header precedence apply on native platforms;
`beta: true` forces the multi-agent opt-in header. `connector` is an injectable
seam, and `connectionTimeout` defaults to the configured connect timeout.

The current [WebSocket guide](https://developers.openai.com/api/docs/guides/websocket-mode)
describes 16 in-flight responses, 32 named lanes plus default, and a 60-minute
connection limit. On disconnection, recover manually using a stored response ID
or replay full context with no parent. A `store: false` fork should reach
`response.in_progress` before the source lane advances. Standalone compaction
starts a new chain using the complete returned compacted window. Mid-turn steering
is described below. [Opt-in socket recovery](#how-do-i-recover-a-responses-websocket)
and [multi-agent tool-result injection](#how-do-i-inject-multi-agent-tool-results)
are available.

→ [Runnable offline example](example/responses_websocket_example.dart), with
warm-up, two lanes, incremental continuation and awaited cleanup for $0.

The shared annotation-added event accepts its required nullable annotation value.
See the [migration guide](MIGRATION.md#upcoming-nullable-streaming-annotations)
before dereferencing `OutputTextAnnotationAddedEvent.annotation`.

</details>

### How do I steer a running Responses request?

<details>
<summary><b>Show example</b></summary>

Send user input after the original `response.created`, then keep reading until
the successor completes:

```dart
final connection = await client.responses.connect();
final reader = StreamIterator(connection.events);
String? originalId;
String? successorId;
var completed = false;
try {
  connection.create(
    const CreateResponseRequest(
      model: 'gpt-6-sol',
      input: ResponseInput.text('Draft a project plan.'),
    ),
  );
  while (await reader.moveNext()) {
    final message = reader.current;
    if (message case ResponsesStreamEvent(
      event: ResponseCreatedEvent(:final response),
    )) {
      if (originalId == null) {
        originalId = response.id;
        connection.steer(
          previousResponseId: originalId,
          input: const ResponsesSteerInput.text('Keep the scope small.'),
        );
      } else {
        successorId = response.id; // The queued input is now committed.
      }
    } else if (message is ResponsesSteerAcceptedEvent) {
      // Save message.steer.id. Acceptance queues input; keep reading.
    } else if (message is ResponsesSteerPendingEvent) {
      // This minimal example has no tool runner. Return saved results through
      // one explicit create per parent on message.streamId; see the full example.
      throw StateError('The continuation needs saved tool results or approval.');
    } else if (message is ResponsesSteerFailedEvent ||
        message is ResponsesErrorEvent) {
      throw StateError('The request or steering failed.');
    } else if (message case ResponsesStreamEvent(event: ResponseFailedEvent())) {
      throw StateError('A response failed before the continuation completed.');
    } else if (message case ResponsesStreamEvent(
      event: ResponseIncompleteEvent(:final response),
    )) {
      if (response.id != originalId ||
          response.incompleteDetails?.reason != 'steered') {
        throw StateError('A response ended incomplete without successful steering.');
      }
    } else if (message case ResponsesStreamEvent(
      event: ResponseCompletedEvent(:final response),
    )) {
      if (successorId != null && response.id == successorId) {
        completed = true;
        break;
      }
    }
  }
  if (!completed) {
    throw StateError('Connection closed with an unknown steering outcome.');
  }
} finally {
  try {
    await connection.close();
    await connection.done;
  } finally {
    await reader.cancel();
  }
}
```

Steering supports the GPT-6 family in supported single-agent modes, without a
conversation binding or automatic compaction. Unsupported modes surface server
failures; the client does not maintain a model allowlist. `ResponsesSteerEvent`
contains only `type`, `previous_response_id` and `input`. `ResponsesSteerInput`
accepts text or a nonempty list of user messages containing text/image/file parts.
It excludes create settings, lane fields, message IDs/status and tool results.
`sendSteer` accepts an already-built event; `steer` is the convenience method.

`response.steer.accepted` queues the update; successor `response.created` commits
it. The original can end as incomplete with reason `steered` or complete normally
before that successor arrives. Steering does not rewrite emitted output, undo
actions or cancel tools already running.

For `waiting_for_required_input`, inspect `ResponsesSteerPendingEvent.requiredInput`.
Its seven typed stub kinds identify function, custom, computer, shell, apply-patch,
tool-search results or MCP approval; they are not complete result items. Use saved
results in one explicit `create` per parent on the original lane. That request uses
its own settings; the server prepends accepted steering. Several pending
submissions can share the same stubs, and a matching create can arrive before a
pending notification. Do not rerun tools or resend accepted input.

Pending reasons and failure codes remain open strings. A failure preserves the
original rejected raw input, optional allocated ID and lane, including future
metadata. A failure after acceptance retains the same steering ID. Correct invalid
input before deciding whether to submit it again. A missing acknowledgment or
disconnect leaves the outcome unknown; no frame is automatically replayed.

→ [Runnable offline steering example](example/responses_steering_example.dart)
demonstrates automatic continuation and two pending submissions sharing one saved
tool result, with exactly one continuation create and awaited cleanup for $0.
See [migration guidance](MIGRATION.md#upcoming-typed-steering-events) for exhaustive
WebSocket event switches and the [official steering guide](https://developers.openai.com/api/docs/guides/steering).

</details>

### How do I recover a Responses WebSocket?

<details>
<summary><b>Show example</b></summary>

Supply `reconnect` to opt in. The required preparation callback lets your
application reconcile history and update its authentication provider before a
replacement socket opens. Pass your normal application session loop to this
wrapper; submitted work is never replayed for you:

```dart
Future<void> runRecoverableSession(
  OpenAIClient client,
  Future<void> Function(ResponsesConnection) runSession,
) async {
  final connection = await client.responses.connect(
    reconnect: ResponsesReconnectOptions(
      onReconnecting: (context) {
        // Reconcile application state before continuing. Abort if it is unsafe.
        return const ResponsesReconnectDecision.continueWith();
      },
    ),
  );
  final recovery = connection.recovery!;
  final lifecycle = recovery.events.listen((change) {
    // Lifecycle diagnostics redact payloads, header/query values and reasons.
    print(change);
  });
  try {
    await runSession(connection);
  } finally {
    try {
      await connection.close();
      await connection.done;
      final report = await recovery.done;
      print('${report.unsentMessages.length} never-attempted frames remain.');
      // Inspect snapshots deliberately; decide whether/how to submit new work.
    } finally {
      await lifecycle.cancel();
    }
  }
}
```

Omitting `reconnect` keeps the default behavior. With recovery enabled, defaults
are five attempts, an initial 500 ms exponential delay capped at eight seconds,
and jitter between 0.75 and 1.0. Durations truncate to whole milliseconds before
jitter; the resulting delay rounds to the nearest millisecond. Only closes 1001, 1005, 1006, 1011, 1012, 1013 and
1015 admit recovery; clean, protocol, policy and unknown closes stop it.
Authentication is rebuilt for each dial. Initial handshake failures are not
retried. Explicit close stops logical recovery promptly during preparation,
waiting or dialing. User callbacks may finish later; late errors are consumed
and late sockets are disposed. A callback exception or abort ends recovery.

`ResponsesReconnectDecision.continueWith(queryParameters: ..., headers: ...)`
replaces the previous override maps for subsequent attempts. Null reuses them;
empty maps clear the overrides. The helper snapshots returned maps before its
delay. Fresh configured defaults/auth still apply, and beta opt-in is forced
last. Attempt context exposes timing and the triggering close, while your
application retains its own credential, query and conversation state.

Only new frames sent while recovery is in progress enter the FIFO queue. Its
strict default limit is 1 MiB (1,048,576 serialized UTF-8 bytes), including the
first frame. Bytes are captured at enqueue, so caller mutation cannot change the
message or accounting. Overflow throws `ResponsesSendQueueOverflowException`
and emits `ResponsesRecoveryQueueOverflow`; only the new frame is rejected and
recovery continues. Zero attempts disables retries, zero queue bytes disables queuing and rejects
every new frame, and zero delay/cap permits immediate attempts.

An attempted send or queued flush failure has unknown delivery. It emits
`ResponsesRecoveryDeliveryUnknown`, permanently closes the logical connection,
and never retries that frame. A direct send also throws
`ResponsesDeliveryUnknownException`. `recovery.done` and `unsentMessages` report
only the immutable never-attempted remainder; a rejected overflow frame is also
excluded. `ResponsesUnsentMessage.text` holds exact wire text, `byteLength` its
UTF-8 size, and `message` an immutable decoded JSON object when valid. These
payloads may contain sensitive input; do not log or replay them automatically.

The strict first-frame bound matches Python and differs from Node's oversized
first-frame exception. Never replaying a failed attempted write matches Python;
terminating on that failure is this Dart helper's explicit policy. Python logs
flush failures and Node may requeue an attempted failed frame. These choices do
not imply parity with other SDK output-parsing or application recovery helpers.

`recovery.events` reports reconnecting, reconnected, overflow, uncertain delivery,
transport error and final closure. `currentAttempt`, `lastEvent` and the final
report remain inspectable without an active listener. Cancelling a lifecycle
listener does not close the connection. `recovery.done` completes independently
of listener draining. With recovery enabled, `connection.closeCode`/`closeReason`
represent final logical closure, including caller-requested close values; they
are not necessarily a physical peer notification. `currentAttempt` retains the
triggering physical close context, and the final report's `cause` classifies why
recovery ended.

Opening a socket does not restore any lane's cache, conversation history or
accepted steering. Continue using a valid stored response ID when available,
or start a new chain with full retained input and no parent. Missing
acknowledgments remain unknown outcomes. Native connectors support headers;
browser connectors reject all custom headers, including returned overrides, so
use an authenticated backend proxy with a headerless browser configuration.
See the [official recovery guide](https://developers.openai.com/api/docs/guides/websocket-mode#reconnect-and-recover).

→ [Runnable offline recovery example](example/responses_recovery_example.dart)
proves original create/accepted-steer frames never replay, new frames flush FIFO,
overflow stays nonfatal, and final unsent snapshots remain immutable with awaited
cleanup and no API key or charges.

</details>

### How do I inject multi-agent tool results?

<details>
<summary><b>Show example</b></summary>

Open a native beta connection with `client.responses.connect(beta: true)` and
set `multiAgent: MultiAgentConfig(enabled: true)` on your create request. Choose
a model that supports the beta using the current model documentation; this client
does not impose a model allowlist. Return each developer-owned result as it becomes
available, using the response ID received from `response.created`. This helper
uses a caller-owned open connection and returns the completed ID, lane and raw
uncommitted input. Choose any continuation on that same socket, then await
`connection.close()` in your outer finally block:

```dart
Future<({String responseId, String streamId, List<Object?> uncommitted})>
runInjectedTurn(
  ResponsesConnection connection,
  CreateResponseRequest request,
  Future<String> Function(FunctionCallOutputItemResponse) executeTool,
) async {
  final reader = StreamIterator(connection.events);
  final savedCallIds = <String>{};
  final uncommitted = <Object?>[];
  String? responseId;
  var pending = 0;
  String? completedResponseId;
  try {
    connection.create(request, streamId: 'planner');
    while (await reader.moveNext()) {
      final message = reader.current;
      // Other subscribers may process other lanes on this caller-owned socket.
      if (message.streamId != 'planner' &&
          !(message is ResponsesErrorEvent && message.streamId == null)) {
        continue;
      }
      if (message case ResponsesStreamEvent(
        event: ResponseCreatedEvent(:final response),
      )) {
        responseId = response.id;
      } else if (message case ResponsesStreamEvent(
        event: OutputItemDoneEvent(
          item: final FunctionCallOutputItemResponse call,
        ),
      )) {
        if (responseId == null) throw StateError('Missing response identity');
        if (!savedCallIds.add(call.callId)) continue;
        final output = await executeTool(
          call,
        ); // The application owns execution.
        pending++;
        connection.inject(
          responseId: responseId,
          input: [
            FunctionCallOutputItem.string(callId: call.callId, output: output),
          ],
        );
      } else if (message is ResponseInjectCreatedEvent ||
          message is ResponseInjectFailedEvent) {
        final target = message is ResponseInjectCreatedEvent
            ? message.responseId
            : (message as ResponseInjectFailedEvent).responseId;
        if (target != responseId || pending == 0) {
          throw StateError('Unexpected injection acknowledgment');
        }
        pending--;
        if (message is ResponseInjectFailedEvent) {
          if (message.error.code !=
              ResponseInjectErrorCode.responseAlreadyCompleted) {
            throw StateError(
              'Injection was not committed; inspect the failure',
            );
          }
          uncommitted.addAll(message.input); // Keep the original raw JSON.
        }
      } else if (message case ResponsesStreamEvent(
        event: ResponseCompletedEvent(:final response),
      )) {
        if (response.id != responseId) {
          throw StateError('Unexpected completion');
        }
        completedResponseId = response.id;
      } else if (message is ResponsesErrorEvent) {
        throw StateError('A WebSocket error interrupted the turn');
      } else if (message case ResponsesStreamEvent(
        event: ResponseFailedEvent() || ResponseIncompleteEvent(),
      )) {
        throw StateError('The response ended unsuccessfully');
      }
      if (completedResponseId != null && pending == 0) {
        return (
          responseId: completedResponseId,
          streamId: 'planner',
          uncommitted: uncommitted,
        );
      }
    }
    throw StateError('Socket ended before completion and every acknowledgment');
  } finally {
    await reader
        .cancel(); // The caller retains the connection for continuation.
  }
}
```

`sendInject(ResponseInjectEvent(...))` sends the same explicit frame. Its wire
fields are exactly `type`, `response_id` and `input`; injection has no `stream_id`
argument because the target determines the lane. Requests retain the existing
broad `List<Item>` surface and enforce the canonical 16,384-item maximum. The
server currently accepts client-owned tool outputs. A nonempty rule or narrower
client tool whitelist is not invented. Both methods require a beta connection.
The shared Item decoder still has legacy subtype/unknown-field limitations; this
integration does not establish complete generated input-union parity.

An accepted acknowledgment has no submission ID or echoed input. Track the count
of submissions for each response and its lane, and read until the response is
terminal and every injection has a created/failed acknowledgment. Calls may
originate from the root or a subagent; existing item/event agent tags remain
available. Hosted `multi_agent_call` and `multi_agent_call_output` are server-owned
and must not be executed or injected as developer tools.

Failed input is now a deeply immutable raw `List<Object?>`, preserving future
metadata and malformed nested values. Its outer value must still be an array.
`response_already_completed` permits the application to choose an explicit new
create with the uncommitted results and completed parent on the original lane.
Validate the saved results first; `ResponseInput.fromOutputItems(validatedMaps)`
preserves their raw fields. Do not send accepted results again or rerun a tool.
`response_not_found` needs identity reconciliation. Unknown error strings survive
in `error.rawCode`; the existing enum remains available. Malformed request frames
can produce a generic status-400 error followed by socket closure; observe both.
Lost acknowledgments or attempted write failures leave delivery unknown and do
not trigger replay. Opt-in recovery queues only newly unsent frames as described
above.

Injection acknowledgments add two sealed WebSocket variants; the SSE dispatcher
is unchanged. See the [migration guide](MIGRATION.md#upcoming-typed-injection-events)
for exhaustive switches, the raw failed-input getter, and stricter known-frame
validation.

The standard browser connector rejects custom headers, including the forced beta
header. Use a backend proxy that authenticates and adds the beta header server
side; wrap an already-open headerless proxy socket with
`ResponsesConnection(proxySocket, beta: true)` or use an explicit proxy connector.
Realtime ephemeral bearer authentication does not apply. See the
[official multi-agent guide](https://developers.openai.com/api/docs/guides/responses-multi-agent).

→ [Runnable offline injection example](example/responses_injection_example.dart)
shows root/subagent function calls, a hosted action, multiple outstanding
injections and an acknowledgment after completion, with one explicit raw-result
continuation, no tool rerun and awaited cleanup for $0.

</details>

### How do I return client-discovered tools?

<details>
<summary><b>Show example</b></summary>

Configure client-side tool search, then return the complete definitions with the
original search call ID:

```dart
final first = await client.responses.create(
  const CreateResponseRequest(
    model: 'gpt-6-sol',
    input: ResponseInput.text('Find the inventory tools.'),
    tools: [
      ToolSearchTool(
        execution: ToolSearchExecutionType.client,
        description: 'Search a local tool catalog.',
        parameters: {
          'type': 'object',
          'properties': {'goal': {'type': 'string'}},
          'required': ['goal'],
          'additionalProperties': false,
        },
      ),
    ],
    parallelToolCalls: false,
  ),
);
final call = first.output.whereType<ToolSearchCallOutputItem>().single;
final callId = call.callId;
if (call.execution != ToolSearchExecutionType.client || callId == null) {
  throw StateError('Expected a client search call with an ID.');
}
// Resolve call.arguments against your catalog; check its JSON type first.
final next = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-sol',
    previousResponseId: first.id,
    input: ResponseInput.items([
      ToolSearchOutputItemParam(
        callId: callId,
        execution: ToolSearchExecutionType.client,
        tools: const [
          NamespaceTool(
            name: 'inventory',
            description: 'Inventory tools from the local catalog.',
            tools: [
              FunctionTool(name: 'get.status'),
              CustomTool(name: 'describe', format: {'type': 'text'}),
            ],
          ),
        ],
        status: ItemStatus.completed,
      ),
    ]),
  ),
);
```

Search outputs preserve complete function/custom definitions, including parameter
and output schemas, formats, allowed callers, deferred loading and async flags.
Nested discovered functions support dotted names and may contain only `type` and
`name`. Top-level discovered functions always serialize the required nullable
`parameters` and `strict` keys. For standalone discovered-definition JSON, use
`ResponseTool.fromToolSearchOutputJson` and `toToolSearchOutputJson`; ordinary
`NamespaceTool.fromJson` uses the narrower request naming rules.

Writable `ToolSearchCallItemParam.arguments` requires a JSON object. Returned
calls use `Object?` because their arguments may be any JSON value, including null
or a list. Check the type before indexing. Returned calls/results preserve null
hosted call IDs and require their execution, status and payload fields. Search
records from `responses.inputItems.list` use `ToolSearchCallResourceItem` and
`ToolSearchOutputResourceItem`; their explicit conversion methods create writable
items, and call conversion rejects non-object arguments. To retain raw output
history, `ResponseInput.fromOutputItems` accepts raw JSON maps.

The [tool-search guide](https://developers.openai.com/api/docs/guides/tools-tool-search)
documents hosted search and client continuation. The canonical writable discovered
namespace schema allows dotted function names, while the returned schema references
ordinary namespaces with narrower names. Search-result parsing deliberately uses
the discovered context to retain loaded definitions; this is a compatibility
interpretation of those sources. The canonical top-level function schema also
requires nullable keys that some guide examples omit.

→ [Runnable offline example](example/tool_search_example.dart), demonstrating two
local requests, the original call ID and complete discovered definitions without
an API key or tool execution. See the [migration guide](MIGRATION.md#upcoming-tool-search-fidelity)
for required constructor arguments and new `Item` variants.

</details>

### How do I select and inspect an access program?

<details>
<summary><b>Show example</b></summary>

Use `AccessProgramsParam` to select a cyber access program and inspect the effective
returned selection through `AccessProgramsBody`:

```dart
const request = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Explain how to validate a patch in a test setup.'),
  accessPrograms: AccessProgramsParam(cyber: CyberAccessProgram.daybreakBlue),
);
final response = await client.responses.create(request);
print(response.accessPrograms?.cyber.toJson() ?? 'Not reported or implicit Standard');
```

`CyberAccessProgram` supports `standard`, `daybreakBlue` and `daybreakRed` with
their exact wire values. Omit `accessPrograms` or use `const AccessProgramsParam()`
to leave selection to the server. No default is inserted by the client. An implicit
Standard selection is reported as null by the server; explicit Standard retains
its returned object. Older responses that omit this metadata remain accepted.

Request JSON rejects supplied null, unsupported keys inside the selection object,
and invalid cyber values. Returned objects require a nonnull known `cyber` value;
extra returned fields remain tolerated. Clearing a Dart selection with
`copyWith(accessPrograms: null)` omits the request key. Ordinary, retrieved,
cancelled and streamed lifecycle responses retain the effective program, including
through `ResponseStreamAccumulator.response`.

Explicit selection requires compatible model and organization/project access; it
does not grant approval. Match the program to the model rather than the approval
level. Follow the current [Daybreak guide](https://developers.openai.com/api/docs/guides/daybreak)
for model eligibility, project setup, omission defaults and 400/403 errors. Usage
tiers such as Build, Launch and Grow are separate from access-program selection.

→ [Runnable offline example](example/access_programs_example.dart), demonstrating
omission, an empty selection and all three explicit values without an API key,
Daybreak provisioning or API charges.

</details>

### How do I observe compaction progress?

<details>
<summary><b>Show example</b></summary>

Enable inline compaction with context management and watch for the typed progress
event while continuing to consume the stream:

```dart
const request = CreateResponseRequest(
  model: 'gpt-6-astra',
  input: ResponseInput.text('Continue the current task.'),
  contextManagement: [
    ContextManagement.compaction(compactThreshold: 200000),
  ],
);
await for (final event in client.responses.createStream(request)) {
  switch (event) {
    case ResponseCompactionCompactingEvent(:final itemId, :final outputIndex):
      print('Compacting $itemId at output index $outputIndex.');
    case ResponseCompletedEvent():
      print('Response completed.');
    default:
      break;
  }
}
```

`ResponseCompactionCompactingEvent` carries required `sequenceNumber`,
`outputIndex` and `itemId`, plus optional beta `agent` metadata. It is nonterminal
and contains no summary or encrypted content. `ResponseStreamAccumulator` exposes
it through `latestEvent` while preserving response, text, reasoning and status.
The final response retains the opaque `CompactionOutputItem`.

The [compaction guide](https://developers.openai.com/api/docs/guides/compaction)
describes automatic threshold-based compaction and standalone `responses.compact`.
For standalone compaction, replay the complete returned output window with
`compacted.toInput()`. Existing context management,
explicit triggers and encrypted replay remain available; future event types still
use `UnknownEvent`.

→ [Runnable offline example](example/compaction_progress_example.dart), with no API
key or large context. See the [migration guide](MIGRATION.md#upcoming-compaction-progress)
when updating exhaustive switches or manual unknown-event handlers.

</details>

### How do I configure hosted shell and return local results?

<details>
<summary><b>Show example</b></summary>

Configure a hosted container, local runtime, or existing container on the shell
tool. Hosted configuration reuses container memory, network and skill models:

```dart
final hostedTool = ResponseTool.shell(
  environment: ShellToolEnvironment.containerAuto(
    memoryLimit: ContainerMemoryLimit.gb4,
    networkPolicy: ContainerNetworkPolicy.disabled,
    skills: const [ContainerSkill.reference(skillId: 'skill_uploaded')],
  ),
);
final localTool = ResponseTool.shell(
  environment: ShellToolEnvironment.local(
    skills: const [
      ShellLocalSkill(
        name: 'csv-summary',
        description: 'Summarize a local CSV dataset.',
        path: '/workspace/skills/csv-summary',
      ),
    ],
  ),
);
final request = CreateResponseRequest(
  model: 'gpt-6-astra',
  input: const ResponseInput.text('Summarize the dataset.'),
  tools: [hostedTool],
  toolChoice: ResponseToolChoice.shell(),
);
```

For a locally executed call, inspect the commands and apply your application's
execution policy. Return captured output on the original call ID and retain the
model's output limit. This snippet supplies synthetic output:

```dart
final continuation = CreateResponseRequest(
  model: 'gpt-6-astra',
  previousResponseId: response.id,
  input: ResponseInput.items([
    ShellCallOutputInputItem(
      callId: call.callId,
      maxOutputLength: call.action.maxOutputLength,
      output: const [
        ShellCallOutputContentInput(
          stdout: 'Synthetic summary: 12 rows.',
          stderr: '',
          outcome: ShellCallExitOutcome(exitCode: 0),
        ),
      ],
    ),
  ]),
);
```

Typed command added/delta/done and output-content delta/done events expose
`commandIndex`, `outputIndex`, sequence and optional agent metadata. Output
fragments carry independent stdout/stderr fields; empty fragments and obfuscation
stay intact. Completed lifecycle responses retain full results. There is no
automatic command runner or generalized shell-output accumulator.

The [shell guide](https://developers.openai.com/api/docs/guides/tools-shell) and
[skills guide](https://developers.openai.com/api/docs/guides/tools-skills) describe
hosted bundles versus local name/description/path skills. Hosted network access
requires organization configuration and an explicit request policy. Server limits
are 50 uploaded file IDs and 200 skills per environment; the SDK documents these
limits and leaves enforcement to the service. `container_auto` belongs on a
definition; direct call history allows only local/reference environments. Returned
local environments have no skills. `toShellCallInputItem()` and
`toShellCallOutputInputItem()` bridge output, input listings and conversation
items while omitting returned-only creator metadata.

→ [Runnable offline example](example/shell_tools_example.dart), with hosted
configuration, local continuation and typed stream events. It requires no API key,
creates no containers and executes no proposed commands. See
[migration guidance](MIGRATION.md#upcoming-shell-alignment) for corrected required
nullable returned keys and distinct writable DTOs.

</details>

### How do I filter web search and inspect image results?

<details>
<summary><b>Show example</b></summary>

`ResponseTool.webSearch()` and `WebSearchTool()` now default to GA `web_search`.
Use domain filters and image settings, then request results and source metadata:

```dart
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    reasoning: const ReasoningConfig(effort: ReasoningEffort.low),
    input: const ResponseInput.text('Find images of the Golden Gate Bridge.'),
    tools: [
      ResponseTool.webSearch(
        filters: WebSearchFilters(
          allowedDomains: const ['nps.gov', 'wikimedia.org'],
          blockedDomains: const ['spam.example'],
        ),
        searchContentTypes: const [SearchContentType.image, SearchContentType.text],
        imageSettings: WebSearchImageSettings(maxResults: 3, caption: true),
      ),
    ],
    toolChoice: ResponseToolChoice.webSearch(),
    include: const [Include.webSearchResults, Include.webSearchActionSources],
  ),
);
for (final call in response.output.whereType<WebSearchCallOutputItem>()) {
  for (final result in call.results ?? <WebSearchResult>[]) {
    if (result case WebSearchImageResult(:final imageUrl, :final sourceWebsiteUrl)) {
      print('$imageUrl from $sourceWebsiteUrl');
    }
  }
}
```

Calls expose `WebSearchCallStatus`, typed search/open-page/find actions, and
`WebSearchActionSearch.sources`. Image results are separate from assistant text
and citations. Future action/result objects retain recursively immutable JSON;
no text-result shape is assumed. Optional null image metadata normalizes to
absence. Input listings and conversation items retain the same metadata, and
`toWebSearchCallItem()` supports typed history replay.

The [official guide](https://developers.openai.com/api/docs/guides/tools-web-search)
documents scheme-free domains (up to 100 in each allow/block list), positive
image counts, and `returnTokenBudget` for GPT-5+ reasoning web search. Use
`WebSearchReturnTokenBudget.unlimited` selectively; it can increase latency and
cost. Omission leaves the server's usual budget unchanged. `externalWebAccess:
false` selects cached content on the real service.

Explicit preview types remain available with `type: 'web_search_preview'` or
`'web_search_preview_2025_03_11'`; GA also accepts `'web_search_2025_08_26'`.
GA-only controls are rejected on preview tools. Block lists, return budgets,
GA image controls/results, and forced GA choice follow the guide ahead of the
canonical schema; these differences stay visible in verification evidence.

→ [Runnable local REST/SSE example](example/web_search_controls_example.dart),
without an API key or charges. See [migration guidance](MIGRATION.md#upcoming-ga-web-search-alignment)
for the GA default and status type changes.

</details>

### How do I use async function and custom tools?

<details>
<summary><b>Show example</b></summary>

Set `async: true` on a Responses function or custom tool to let the model continue
while your application runs that tool. Both tool definitions and returned calls
preserve omitted, false and true flags; `copyWith(async: null)` removes the flag.
The client provides typed contracts; your application owns tool execution and
returning the result.

```dart
final tool = ResponseTool.function(
  name: 'get_weather',
  async: true,
  strict: true,
  parameters: const {
    'type': 'object',
    'properties': {'city': {'type': 'string'}},
    'required': ['city'],
    'additionalProperties': false,
  },
);
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    input: const ResponseInput.text('Look up the weather in Paris.'),
    tools: [tool],
  ),
);
final call = response.output.whereType<FunctionCallOutputItemResponse>().single;
// Run your application tool and keep call.callId associated with its result.
// If other turns happen, replace this with the latest response's ID.
final latestResponseId = response.id;
await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    previousResponseId: latestResponseId,
    tools: [tool],
    input: ResponseInput.items([
      FunctionCallOutputItem.string(
        callId: call.callId,
        output: '{"city":"Paris","celsius":24}',
      ),
    ]),
  ),
);
```

`ResponseTool.custom(async: true, ...)` uses the same execution flag.
`CustomToolCallItem.toCustomToolCallInputItem()` supplies typed custom-call replay;
function replay preserves agent, namespace, caller, status and async metadata.
Custom replay omits output-only status/creator fields. Ordinary output/result
items do not gain an async flag.

The [official async guide](https://developers.openai.com/api/docs/guides/async-tool-calling)
documents support for GPT-6 Astra and later models. Use direct application tools,
not hosted tools or programmatic calls; in Multi-agent mode, do not combine async
with parallel tool calls. There is no dedicated async streaming event: existing
item-added/done and response lifecycle events carry the calls.

→ [Runnable function/custom example](example/async_tools_example.dart), using a
local transport with an intervening turn, no API key and no charges.

</details>

### How do I change reasoning effort during a conversation?

<details>
<summary><b>Show example</b></summary>

Append a `ConfigurationUpdateItem` before the next user message to change effort
for subsequent responses. Keep the request-level `ReasoningConfig` and stable
instructions unchanged so the original prompt prefix remains reusable for caching.

```dart
const baseline = ReasoningConfig(effort: ReasoningEffort.low);
final first = await client.responses.create(
  const CreateResponseRequest(
    model: 'gpt-6-astra',
    reasoning: baseline,
    input: ResponseInput.text('Draft a database migration plan.'),
  ),
);
final next = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    reasoning: baseline,
    previousResponseId: first.id,
    input: ResponseInput.items([
      const ConfigurationUpdateItem(
        reasoning: ConfigurationUpdateReasoning(effort: ReasoningEffort.high),
      ),
      MessageItem.userText('Analyze failure modes and rollback steps.'),
    ]),
  ),
);
print(next.outputText);
```

The server keeps the selected effort until another update replaces it. Continue
with `previousResponseId`, or preserve updates in their original positions when
replaying history. `response.reasoning.effort` still reports request-level effort.

`ConfigurationUpdateReasoning` exposes only `effort`. Omitted reasoning and `{}`
remain distinct. Nullable input IDs and effort values accept null and serialize
as omission; supplied null reasoning is invalid. Responses input listings return
`ConfigurationUpdateItemResponse`; conversation items return
`ConversationConfigurationUpdateItem`. Both require an ID and provide
`toConfigurationUpdateItem()` for typed replay.

The [official reasoning guide](https://developers.openai.com/api/docs/guides/reasoning#change-reasoning-mid-conversation)
documents GPT-6 support in standard, single-agent mode. Avoid adjacent updates,
automatic compaction, automatic truncation, and standalone `/responses/compact`
for histories containing updates. After explicit `compaction_trigger` compaction,
insert a fresh update before the next user message. Normal caching requirements
still apply.

→ [Runnable local example](example/configuration_updates_example.dart) shows
low → high → high → low across four turns, without an API key or charges.

</details>

### How do I prewarm the prompt cache and inspect diagnostics?

<details>
<summary><b>Show example</b></summary>

On supported GPT-5.6 and later models, Responses uses
`ResponsePromptCacheOptionsParam` for mode/TTL, prewarming, and comparison IDs.
Chat and compaction use the narrower `PromptCacheOptionsParam` with mode/TTL only.
A reusable prefix must meet the model's minimum cacheable length (1,024 tokens
for GPT-5.6 and later). Supply your application's stable context as `stablePrefix`;
keep its content and cache-affecting settings stable.

```dart
final baseline = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-luna',
    input: ResponseInput.text(stablePrefix),
    promptCacheOptions: const ResponsePromptCacheOptionsParam(prewarm: true),
  ),
);
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-luna',
    input: ResponseInput.text(stablePrefix),
    promptCacheOptions: ResponsePromptCacheOptionsParam(
      ttl: PromptCacheTtl.minutes30,
      comparisonResponseId: baseline.id,
      prewarm: false,
    ),
  ),
);
if (response.promptCacheDiagnostics case PromptCacheMissDiagnostics(:final reason)) {
  print('Cache miss reason: ${reason.value}');
}
print('Cached tokens: ${response.usage?.inputTokensDetails?.cachedTokens}');
```

Use a recent completed baseline from the same organization. A comparison ID
requests diagnostics; it does not load conversation history or change caching.
Diagnostics can be absent, unavailable, or refer to an expired comparison.
A hit means no miss was detected for the comparison; usage counters measure
actual reuse and billing. Future diagnostic variants and reason strings are
preserved. During streaming, inspect `ResponseCompletedEvent.response`.

The existing retention control is deprecated and expresses a maximum policy;
modern TTL expresses a minimum lifetime. They are independent.
See the [migration guide](MIGRATION.md) for the Responses options type change and
[official diagnostics guide](https://developers.openai.com/api/docs/guides/prompt-caching/diagnostics).

→ [Runnable example with bounded output and cleanup](example/prompt_cache_example.dart)

</details>

### How do I use chat completions?

<details>
<summary><b>Show example</b></summary>

Use `client.chat.completions.create(...)` for multi-turn conversations. The `response.text` convenience getter returns the first choice's message content.

The API's existing `promptCacheRetention` setting is deprecated in favor of `prompt_cache_options.ttl`; cache-options alignment is tracked in [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322). For the existing control, `PromptCacheRetention.h24` emits `24h`, while `inMemory` emits the canonical `in_memory`. GPT-5.5 and newer models support only `h24`; select `inMemory` only for models that support it. Legacy `in-memory` JSON still parses, and reserialization uses `in_memory`.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is the capital of France?'),
    ],
    maxTokens: 100,
    promptCacheRetention: PromptCacheRetention.h24,
  ),
);

// response.text is a convenience extension for the first choice's message content
print('Response: ${response.text}');
print('Finish reason: ${response.choices.first.finishReason}');
print('Usage: ${response.usage?.promptTokens} in, ${response.usage?.completionTokens} out');

// Build message lists fluently with extension methods
final messages = <ChatMessage>[]
  .withSystemMessage('You are helpful')
  .withUserMessage('Hello!');

client.close();
```

→ [Full example](example/chat_example.dart)

</details>

### How do I generate, replay, and stream Chat audio?

<details>
<summary><b>Show example</b></summary>

Use an audio-capable Chat model and request audio output. Complete output exposes
its ID, base64 data, transcript, and replay expiry; text can be null.

```dart
final completion = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-audio-1.5',
    messages: [ChatMessage.user('Say only OK.')],
    modalities: const [ChatModality.text, ChatModality.audio],
    audio: const ChatAudioConfig(
      voice: ChatAudioVoice.alloy,
      format: ChatAudioFormat.wav,
    ),
    maxCompletionTokens: 128,
    store: false,
  ),
);
if (completion.audio case final audio?) {
  final bytes = base64Decode(audio.data); // import dart:convert
  await File('reply.wav').writeAsBytes(bytes); // import dart:io
  print(audio.transcript);
  final reference = ChatMessage.assistant(
    audio: ChatAudio.reference(id: audio.id),
  );
  // Add reference to a later request before audio.expiresAt.
}
```

`ChatAudioReference` is ID-only; `ChatCompletionAudio` requires all four output
fields. You can reuse the returned assistant message directly: actual request
serialization projects its audio to `{id}` without sending data/transcript/expiry.
Local response serialization retains the complete output and provider extensions.

`ChatAudioConfig.voice` accepts existing `ChatAudioVoice` constants (including
marin/cedar), `AudioVoice.named('provider-voice-name')`, or
`AudioVoice.custom('voice_existing_id')`. Availability depends on the model and
project access. `ChatAudioFormat.aac` is supported by the canonical request;
Chat PCM uses `pcm16`, while Speech uses `pcm`. See the
[offline voice/file-audio example](example/existing_audio_example.dart) and
[migration notes](MIGRATION.md#upcoming-chat-voices-and-file-audio-corrections).

Stream with PCM16 output and pass events to `ChatStreamAccumulator`. Each
`ChatDelta.audio` is an independent partial update. `accumulator.audio` and each
`accumulator.choices[i].audio` expose stable `ChatAudioDelta` snapshots with
`isComplete`. Data/transcript fragments append separately; ID and expiry update
when supplied. Decode complete data once after accumulation. Usage-only events
and padding stay separate from audio.

`toChatCompletion()` retains complete audio and throws `StateError` if any choice
has incomplete audio, including after interruption; inspect partial snapshots
instead. Text-only conversion behaves as before. A pure final expiry-only update
can infer `stop` during final conversion when every audio field is present, while
raw event and snapshot finish metadata remain unchanged. Reset clears all audio.

→ [Runnable audio, replay, and streaming example](example/chat_audio_example.dart)

See the [official audio guide](https://developers.openai.com/api/docs/guides/audio-chat-completions)
and [migration guide](MIGRATION.md) for parsing and conversion boundaries.

</details>

### How do I stream responses?

<details>
<summary><b>Show example</b></summary>

Streaming returns content deltas plus metadata as they arrive. Request final usage
with `includeUsage`; its additional chunk has an empty `choices` list. Use
`event.textDelta` to safely handle content and usage-only events.

```dart
final accumulator = ChatStreamAccumulator();
final stream = client.chat.completions.createStream(
  ChatCompletionCreateRequest(
    model: 'gpt-6-luna',
    reasoningEffort: ReasoningEffort.none,
    messages: [ChatMessage.user('Tell me a short story')],
    maxCompletionTokens: 64,
    store: false,
    streamOptions: const StreamOptions(
      includeUsage: true,
      includeObfuscation: true,
    ),
  ),
);
await for (final event in stream) {
  accumulator.add(event);
  stdout.write(event.textDelta ?? '');
}
final completion = accumulator.toChatCompletion();
print(completion.usage?.promptTokensDetails?.cacheWriteTokens);
print(completion.usage?.promptTokensDetails?.textTokens);
print(completion.usage?.promptTokensDetails?.imageTokens);
print(completion.usage?.completionTokensDetails?.textTokens);
```

Prompt details preserve audio, cached, unadjusted cache-write, image, and text
counts. Completion details preserve audio, reasoning, prediction, and text counts.
These details also work on ordinary completions; missing counters remain absent,
and zero remains zero. Interrupted streams can end before final usage arrives.

`includeObfuscation` controls server padding that normalizes streamed payload
sizes. Omit it to keep the server default (enabled), or set it to false to reduce
bandwidth when you trust the network links. `ChatStreamEvent.obfuscation` exposes
padding as metadata, including an empty string. It never becomes accumulated
text, refusal, reasoning, or tool arguments; `textDeltas()` and `collectText()`
also yield content only. The shared options model supports the flag on Responses
requests too; `includeUsage` is Chat-specific. See the
[official streaming reference](https://developers.openai.com/api/reference/resources/chat/subresources/completions/streaming-events)
for the wire contract.

→ [Full example](example/streaming_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Define tools with JSON Schema parameters and pass them in the request. The response indicates when the model wants to call a tool, and you can inspect the function name and arguments.

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
    messages: [
      ChatMessage.user("What's the weather in Tokyo?"),
    ],
    tools: [
      Tool.function(
        name: 'get_weather',
        description: 'Get the current weather for a location',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {'type': 'string', 'description': 'City name'},
          },
          'required': ['location'],
        },
      ),
    ],
  ),
);

if (response.hasToolCalls) {
  for (final toolCall in response.allToolCalls) {
    print('Function: ${toolCall.function.name}');
    print('Arguments: ${toolCall.function.arguments}');
  }
}
```

→ [Full example](example/tool_calling_example.dart)

</details>

### How do I analyze images?

<details>
<summary><b>Show example</b></summary>

Pass image URLs or base64-encoded images as content parts alongside text in a user message.

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
    messages: [
      ChatMessage.user([
        ContentPart.text('What is in this image?'),
        ContentPart.imageUrl('https://example.com/image.jpg'),
      ]),
    ],
  ),
);

print(response.text);
```

→ [Full example](example/vision_example.dart)

</details>

### How do I create embeddings?

<details>
<summary><b>Show example</b></summary>

Use `client.embeddings.create(...)` to generate vector representations of text. You can optionally reduce dimensions for smaller storage.

```dart
final response = await client.embeddings.create(
  EmbeddingRequest(
    model: 'text-embedding-3-small',
    input: EmbeddingInput.text('Hello, world!'),
    dimensions: 256, // Optional: reduce dimensions
  ),
);

final vector = response.firstEmbedding;
print('Embedding dimensions: ${vector.length}');
```

→ [Full example](example/embeddings_example.dart)

</details>

### How do I generate and edit images with GPT Image 2.5?

<details>
<summary><b>Show example</b></summary>

Use `ImageModels.gptImage25Flare` for fast generation and editing, or
`ImageModels.gptImage25Sunburst` for precise edits and detailed creative work.
Both models support `low`, `medium`, `high`, `xhigh`, `max`, and `auto` quality,
custom sizes, and transparent backgrounds with PNG or WebP output.

```dart
import 'dart:convert';
import 'dart:io';

final response = await client.images.generate(
  const ImageGenerationRequest(
    model: ImageModels.gptImage25Flare,
    prompt: 'A cute robot holding a flower',
    size: ImageSize.custom('1536x864'),
    quality: ImageQuality.xhigh,
    background: ImageBackground.transparent,
    outputFormat: ImageOutputFormat.webp,
  ),
);

// GPT image models return base64 image data.
final b64 = response.data.first.b64Json;
if (b64 != null) {
  File('robot.webp').writeAsBytesSync(base64Decode(b64));
}

final edited = await client.images.editJson(
  const ImageEditJsonRequest(
    model: ImageModels.gptImage25Sunburst,
    images: [ImageReference.url('https://example.com/source.png')],
    prompt: 'Change only the flower to a sunflower',
    quality: ImageQuality.max,
    size: ImageSize.custom('1536x864'),
  ),
);
```

`ImageGenerationRequest` and multipart `ImageEditRequest` require an explicit
nonnull `model`, including for `generateStream` and `editStream`. String IDs are
forwarded unchanged; constants are conveniences rather than an allowlist.
`ImageEditJsonRequest` has a distinct optional/nullable model: omission keeps the
server's `gpt-image-2.5-sunburst` default, and an explicit ID overrides it.

Use `client.images.edit(...)` to upload image bytes, or `editJson(...)` for
up to 16 image references (URLs, data URLs, or uploaded file IDs). The streaming
variants are `generateStream`, `editStream`, and `editJsonStream`.
Snapshot constants are also available: `gptImage25Sunburst20260908` and
`gptImage25Flare20260908`.

→ [Full image example](example/images_example.dart) and
[local model-selection example](example/image_model_selection_example.dart)

See the [generation reference](https://developers.openai.com/api/reference/resources/images/methods/generate),
[editing reference](https://developers.openai.com/api/reference/resources/images/methods/edit),
and [migration guide](MIGRATION.md).

</details>

### How do I use audio?

<details>
<summary><b>Show example</b></summary>

Use `client.audio.speech.create(...)` for complete audio bytes,
`createByteStream(...)` for audio chunks, or `createStream(...)` for typed speech
SSE events. All three accept `abortTrigger`. Requests support `instructions`,
all six audio formats, speed 0.25–4, thirteen built-in voice conveniences, open
voice names and custom voice references.

**Buffered speech:**

```dart
const speech = SpeechRequest(
  model: 'gpt-4o-mini-tts',
  input: 'Hello! How are you today?',
  voice: SpeechVoice.marin,
  instructions: 'Speak warmly and clearly.',
  responseFormat: SpeechResponseFormat.mp3,
);
final audioBytes = await client.audio.speech.create(speech);
```

**Audio chunks:**

```dart
await for (final chunk in client.audio.speech.createByteStream(speech)) {
  // Write or play each chunk in delivery order using the requested audio format.
  print('Received ${chunk.length} audio bytes');
}
```

**Typed SSE audio and usage:**

```dart
await for (final event in client.audio.speech.createStream(speech)) {
  switch (event) {
    case SpeechAudioDeltaEvent():
      final bytes = event.decodeAudio(); // Raw Base64 audio, without a data URL.
      print('Received ${bytes.length} audio bytes');
    case SpeechAudioDoneEvent():
      print('Total tokens: ${event.usage.totalTokens}');
    case SpeechUnknownEvent():
      // Future event fields remain available in the immutable event.rawJson.
      print('Received a future speech event');
  }
}
```

`AudioVoice.named('provider-voice-name')` forwards an open name;
`AudioVoice.custom('voice_existing_id')` sends the closed `{id: ...}` reference.
Custom voices require eligible project access and an existing voice.
[Consent management](#how-do-i-manage-voice-consent-recordings) is available;
[sample-derived voice creation](#how-do-i-create-a-custom-voice) uses an explicit
consent and audio sample.
`SpeechVoice` stays an enum, including the original six constants and seven new
ones. See the [migration guide](MIGRATION.md#upcoming-speech-options-and-streaming)
for the widened `SpeechRequest.voice` type and exhaustive-switch updates.

An explicitly incompatible `streamFormat` is rejected before dispatch. Buffered
and byte methods use audio mode, while `createStream` selects SSE. SSE requires a
supporting model and does not work with `tts-1`/`tts-1-hd`. A stream borrows an
injected HTTP client unless `streamClientFactory` supplies an owned client; canceling
one stream leaves a borrowed client usable. Production streams own and dispose a
dedicated client. A valid `speech.audio.done` completes SSE and releases its
transport even if the HTTP body stays open; later events are ignored. An unexpected
EOF before that event reports a stream failure without replaying consumed output.

The [deprecation notice](https://developers.openai.com/api/docs/deprecations)
schedules `tts-1`, `tts-1-hd` and the listed mini-TTS snapshots for January 6,
2027 shutdown. The model page marks the mini-TTS family deprecated; the notice
does not separately list the alias. Moving to the recommended Realtime model
requires its Realtime workflow, rather than changing the model ID on `/audio/speech`.
The January 20, 2027 legacy Audio/Realtime/transcription snapshot sunset and the
February 26, 2027 file-transcription sunset are separate migrations.

**Speech-to-Text:**

```dart
final response = await client.audio.transcriptions.create(
  TranscriptionRequest(
    file: File('audio.mp3').readAsBytesSync(),
    filename: 'audio.mp3',
    model: 'gpt-transcribe',
    languages: ['en'],
    keywords: ['OpenAI'],
  ),
);

print('Transcription: ${response.text}');
```

All 14 existing file-transcription fields are forwarded, including repeated
`keywords`/`languages`, speaker names/data URLs, logprob inclusion and timestamp
options. `fileContentType: 'audio/mpeg'` optionally sets the file MIME header;
it is upload metadata, separate from those form fields. Requests snapshot their
bytes/lists. Use plural `languages` for `gpt-transcribe`; its singular `language`
is rejected, keywords cannot contain angle brackets/CR/LF, and no numeric prompt
limit is published. Only `chunkingStrategy` and `stream` permit explicit null,
which normalizes to omission as in Python; Node rejects null. False remains false,
and `createStream` selects true. Speaker samples are data URLs; audio format and
duration remain server-validated.

Choose `transcriptions.create` for JSON, `createVerbose` for timestamps,
`createDiarized` for speakers, and `createRaw` for text/SRT/VTT with the matching
`responseFormat`. These specialist modes depend on the model. All buffered methods
accept `abortTrigger`. `createStream` yields typed deltas, diarized segments and
done events plus future received variants. A valid `transcript.text.done` releases
the transport promptly; EOF or `[DONE]` before it is a stream error. Streams never
replay consumed output and cancellation preserves injected borrowed clients.

**Translation to English:**

```dart
final request = TranslationRequest(
  file: File('audio.mp3').readAsBytesSync(),
  filename: 'audio.mp3',
  model: 'whisper-1',
);
final verbose = await client.audio.translations.createVerbose(request);
print('${verbose.language}: ${verbose.text}'); // Output language is English.
final subtitles = await client.audio.translations.createRaw(
  request.copyWith(responseFormat: TranslationResponseFormat.vtt),
);
print(subtitles); // Raw text/subtitle whitespace is retained.
```

Translation `create` accepts JSON; verbose responses need no legacy `task` field,
and segments are optional. All translation methods accept `abortTrigger`.
Received JSON is deeply immutable and future metadata is preserved; known malformed
fields fail with safe diagnostics while explicit response data remains available.

The [February 26, 2027 sunset](https://developers.openai.com/api/docs/deprecations)
lists Whisper/GPT-4o file-transcription models and recommends `gpt-transcribe` or
`gpt-live-transcribe`. A replacement must support your translation, diarization,
timestamp or subtitle workflow; currently operational specialist modes remain
available. This date is separate from the January 6 TTS and January 20 legacy
snapshot notices.

→ [Audio example](example/audio_example.dart) and
[offline speech streaming example](example/speech_streaming_example.dart) ($0 API cost)
and [offline file-audio/Chat voice example](example/existing_audio_example.dart).

</details>

### How do I manage voice consent recordings?

<details>
<summary><b>Show example</b></summary>

The cached `client.audio.voiceConsents` resource uploads, lists, retrieves,
renames and deletes consent recordings. Production creation requires an eligible
project, `api.voices.write`, and a recording of the current approved consent phrase.
Keep the consent and later voice sample in the same project and from the same
person. Follow the [official custom voice guide](https://developers.openai.com/api/docs/guides/custom-voices).

```dart
final consent = await client.audio.voiceConsents.create(
  VoiceConsentCreateRequest(
    name: 'Actor consent',
    recording: audioBytes, // Uint8List from an explicitly obtained recording.
    filename: 'consent.webm',
    language: 'en-US',
    recordingContentType: 'audio/webm;codecs=opus',
  ),
);
final page = await client.audio.voiceConsents.list(limit: 20);
final retrieved = await client.audio.voiceConsents.retrieve(consent.id);
final renamed = await client.audio.voiceConsents.update(
  consent.id,
  const VoiceConsentUpdateRequest(name: 'Updated actor label'),
);
// Select pagination and deletion explicitly in your application.
final after = page.lastId;
if (page.hasMore && after != null) {
  final nextPage = await client.audio.voiceConsents.list(after: after, limit: 20);
}
if (deleteRequested) { // Your application's explicit deletion choice.
  final deleted = await client.audio.voiceConsents.delete(consent.id);
}
```

Uploads snapshot the original bytes and normalize MIME parameters to one of the
supported base types: audio/mpeg, audio/wav, audio/x-wav, audio/ogg, audio/aac,
audio/flac, audio/webm or audio/mp4. The maximum is **10 MiB**. A recognized filename
extension can supply omitted MIME metadata; other filenames need an explicit
supported `recordingContentType`. This does not transcode or inspect recording
content. `name` and the BCP 47 `language` are open strings; the service validates
phrases and eligibility. Sample speech minimums belong to later voice creation.

`list` takes only `after` and `limit` (1–100, omitted service default 20).
It returns one page without fetching more or inferring a cursor. `firstId`/`lastId`
and `hasFirstId`/`hasLastId` distinguish omitted, null and supplied cursors; check
`hasMore` and choose the next cursor deliberately. `deleted` preserves the returned
boolean, including false. Rename is a required-name JSON POST; recording bytes
cannot be changed through rename. Opaque IDs are encoded as one path segment.

All five methods accept `abortTrigger` and use shared auth, errors and conservative
retry: multipart creation is sent once, rename follows POST retry rules and
idempotent DELETE follows the configured shared retry policy. Models preserve
immutable receive-only future metadata while rejecting malformed known fields;
update JSON remains closed. Consent IDs, cursors, labels, recordings and echoed
headers stay private in default diagnostics and built-in logging. Explicit error
messages, response bodies, URLs and causes remain available for caller inspection.

→ [Runnable offline lifecycle example](example/voice_consents_example.dart)
(five mock requests by default, six with explicit `--delete`, $0 API cost).
This manages consent recordings; [custom voice creation](#how-do-i-create-a-custom-voice)
is a separate workflow. `GET /audio/consent_phrases` is documented
upstream but has no canonical typed response, so no phrase DTO is invented here.

</details>

### How do I create a custom voice?

<details>
<summary><b>Show example</b></summary>

The cached `client.audio.voices` resource uploads a sample through `create`, using
a previously obtained consent recording. Use an approved project with `api.voices.write` to
create consents/voices and `api.voices.read` to use a voice. The consent and sample
must come from the same person and project; obtain the current consent phrase
before recording. Follow the [official custom voice guide](https://developers.openai.com/api/docs/guides/custom-voices).

```dart
final consent = await client.audio.voiceConsents.create(
  VoiceConsentCreateRequest(
    name: 'Actor consent',
    recording: consentBytes, // Explicitly obtained Uint8List recording.
    filename: 'consent.webm',
    language: 'en-US',
    recordingContentType: 'audio/webm;codecs=opus',
  ),
);
final voice = await client.audio.voices.create(
  CustomVoiceCreateRequest(
    name: 'Actor voice',
    audioSample: sampleBytes, // Uint8List from the same actor/project.
    filename: 'sample.webm',
    consent: consent.id,
    audioSampleContentType: 'audio/webm;codecs=opus',
    // Optional type: 'audio_sample'; omission uses the service default.
  ),
);
final reference = AudioVoice.custom(voice.id);
final referenceJson = reference.toJson(); // {'id': voice.id}
```

Creation is a multipart POST with required `name`, `audio_sample` and `consent`.
The optional `type` accepts only `audio_sample`, and omitted type stays omitted.
Names contain **1–256 Unicode code points**. The sample upload preserves original
bytes/views and filename, supports the same eight base MIME types as consent
uploads, normalizes browser MIME parameters, and enforces **10 MiB**. A recognized
filename extension can supply omitted MIME metadata; other filenames need an
explicit supported `audioSampleContentType`.

Production samples need at least **five seconds of actual speech** and **15
transcribed tokens**, with a maximum of **30 seconds**. Eligibility, consent and
speech content are service checks; the client does not record, transcribe,
transcode or inspect audio quality. Synthetic example bytes are for offline
verification only.

The returned `CustomVoice` validates `object: audio.voice`, `type: audio_sample`,
ID, name and integer creation time. Known malformed fields or future creation
types fail contextually; finite future metadata remains an immutable receive-only
snapshot, with typed fields authoritative. A response name has no request-only
length restriction. The reference above is caller-selected JSON; it does not make
a speech or Live request, and each consuming API retains its own voice contract.

Creation accepts `abortTrigger`, uses shared auth/errors/closed-client guards,
and sends the multipart body once without automatic replay. Samples, consent
context, IDs and echoed headers are private in default diagnostics and built-in
logging; explicit caller model/HTTP/error context remains readable. The API
exposes creation only, with no client voice list/retrieve/update/delete methods.

→ [Runnable offline consent → voice → reference example](example/voices_example.dart)
(two mock requests, $0 API cost).

</details>

### How do I signal Live sessions and control calls?

<details>
<summary><b>Show example</b></summary>

Use the cached `client.live.sessions` resource for Live HTTP signaling and call
controls. Supply SDP from your application's WebRTC peer, then apply the returned
answer to that peer. Your application owns capture, playback and media transport.

```dart
final created = await client.live.sessions.create(
  LiveSessionCreateRequest(
    session: LiveMediaSessionCreateParams(
      model: 'gpt-live-1',
      instructions: 'Help the caller schedule an appointment.',
      store: true,
    ),
    transport: LiveWebRTCTransport(sdp: callerOfferSdp),
  ),
);
final answer = created.transport as LiveWebRTCResponseTransport;
// Apply answer.sdp to your WebRTC peer; retain created.session.id unchanged.

// Once this stored session has finished and its recording is finalized:
final wav = await client.live.sessions.downloadRecording(created.session.id);
final chunks = client.live.sessions.downloadRecordingStream(created.session.id);

final fork = await client.live.sessions.fork(
  created.session.id,
  LiveForkRequest(transport: LiveWebRTCTransport(sdp: newPeerOfferSdp)),
);
// Apply fork.transport.sdp to the new peer. fork.session.id is a new session.
```

Downloads require a finalized stored recording. Storage defaults to false,
requires project policy and is unavailable with Zero Data Retention. Finalized
recordings remain available for 30 days. WAV bytes are preserved, with input on
the left channel and output on the right. A `503` retains its original HTTP
response and `Retry-After` header in `ApiException.cause`; the client does not poll
or enable storage automatically. Stream completion, cancellation and timeouts
release owned transports while preserving an injected shared client.

For outbound SIP, supply `LiveSIPTransport(destination: ..., trunk: ...)` with
an E.164 destination and `LiveSIPTrunk` containing the provider URL, caller number
and `LiveSIPTrunkAuth` Digest credentials. Keep credentials on your server.
Outbound eligibility, a TLS-signaling/Opus/SDES-SRTP trunk and provider setup are
service requirements. A `201` means initialized, before the callee answers.
Outbound SIP bodies are limited to 1 MiB of serialized UTF-8 JSON. The service
limits ringing to three minutes and connected calls to two hours; these limits
cannot be configured in the request.
Each create places a new call; ambiguous timeout/connection/5xx failures are
sent once. A tracing ID does not deduplicate calls.

Verify incoming webhook bytes first and use `LiveTransportIncomingWebhookEvent`
`data.sessionId` for your chosen `accept` or `reject` action. Acceptance requires
`LiveCallAcceptRequest(session: LiveCallAcceptSession(model: ...))`; rejection
requires `LiveCallRejectRequest(statusCode: ...)` from 300 through 699.
`refer(id, LiveCallReferRequest(targetUri: ...))` transfers a SIP call and
`hangup(id)` sends no body. Verification never accepts, rejects or transfers a
call automatically. IDs are opaque and encoded once; only recording download
applies its own documented stored-session ID pattern.

Shared startup models cover text-only history, frontend permissions, audio,
delegation and all 13 canonical Live tool input branches. Live tool configuration
is distinct from Responses tool models; wire coverage does not guarantee runtime
support for every branch. Tool selection has typed scalar modes, 12 specific
choices and an `allowed_tools` set of 1–128 specific choices. Optional nullable
settings preserve omission, explicit null and values; `hasInstructions: true`
with a null value emits null, while `copyWith(clearInstructions: true)` omits it.
Model, voice, initial history, audio format, startup instructions and delegation
mode are immutable after startup; `LiveSessionUpdateParams` changes backend
settings only. History allows 128 messages with one text part each; the 8,192
rendered-token and 16,384 frontend-instruction limits are enforced by the service.

`LiveVoice` supports open names and its own open custom-ID object (1–128 Unicode
characters), independently of Speech's closed custom reference. Primary WebSocket
audio configuration admits PCM16LE at 16/24 kHz or G.711 PCMA/PCMU at 8 kHz.
WebRTC/SIP negotiate media and omit `audio.format`. Frontend capability omission
or `all` allows all events; an empty selection permits none, and restrictions
do not apply to trusted sideband connections. Primary/sideband WebSocket
connections, stored WebSocket forks and transcript helpers are available below.

Models retain finite immutable open JSON and private caller-readable wire data.
Default diagnostics and built-in logging redact SDP, credentials, audio,
instructions, transcripts, identifiers and future private metadata.

→ [Runnable offline Live HTTP example](example/live_http_example.dart)
(seven default mock requests, $0 API cost). Add `--accept-incoming` or
`--reject-incoming` to choose an incoming action, or `--recording-not-ready` to
inspect a simulated `503`. See the [Live guide](https://developers.openai.com/api/docs/guides/live)
and [SIP setup](https://developers.openai.com/api/docs/guides/voice-sip?api=live).

</details>

### How do I use primary and sideband Live WebSockets?

<details>
<summary><b>Show example</b></summary>

Open a fresh primary connection with `client.live.connect()`. It sends no startup
automatically and adds no model query. Install your event listeners, explicitly
start the session, and await `session.started` before sending application work:

```dart
final connection = await client.live.connect();
final captions = connection.events.listen((event) {
  if (event is LiveInputTranscriptDelta) {
    print(event.delta);
  }
});
try {
  await connection.start(
    LiveSessionStartEvent(
      session: LiveSessionCreateParams(
        model: 'gpt-live-1',
        audio: LiveInitialSessionAudioParam(
          format: LiveAudioFormat.pcm(rate: 24000),
        ),
      ),
    ),
  );
  // Supply raw Base64 from caller-owned mono PCM16LE capture at 24 kHz.
  connection.send(LiveInputAudioAppendEvent(audio: base64Pcm16Audio));
  final finalized = await connection.closeSession(
    timeout: const Duration(seconds: 15),
  );
  print(finalized.usage.seconds);
} finally {
  await captions.cancel();
  await connection.close();
}
```

`client.live.attach(sessionId, gracefulClose: true)` attaches a trusted sideband
to an existing WebRTC/SIP session. Its writer accepts nine shared commands and
excludes `session.start` and audio append; primary writers accept eleven. Both
use the complete 22-event received hierarchy, including reflected sideband audio,
DTMF notifications and SIP progress, with immutable raw fallback for future event
types. This resolves the narrower canonical/SDK sideband-union discrepancy.
Reflected sideband audio is mono PCM16LE at 24 kHz; output frames include
`start_ms`/`end_ms`. Keep original bytes, delivery order and timeline gaps.

`LiveResponseEvent.event` retains any finite nested object, including compact
Responses snapshots and objects without `type`. Correlate its outer
`delegationId` with delegation metadata; omission/null remain distinct. The Live
backend accepts `LiveInputItem` adapters for every declared canonical input branch,
including item shapes the ordinary Responses `Item` helper cannot represent.
For function requests, designate one application action owner, submit every
pending result with `LiveResponseItemCreateParam`, then explicitly send one
`LiveResponseCreateParam`. There is no item-create success acknowledgment to
await. Client delegation instead uses transcripts/application state and explicit
thinking/commentary/instruction appends with the received delegation ID.

`closeSession()` stops new work, sends one close request, drains until
`LiveSessionClosed`, and releases owned resources within bounded waits.
`isFinalized` confirms that event; a socket close alone leaves finalization
unconfirmed. `latestUsageSeconds` replaces cumulative snapshots rather than
summing them. Keep delegated backend token usage separately. `close()` releases
the local transport without requesting session finalization. Concurrent event
taps may observe captions and application work; canceling one tap does not close
the connection. There is no automatic reconnect, startup/audio/tool replay or
external action runner. SIP progress may replay only the preceding three seconds
with original IDs; application deduplication is explicit.

Default browser sockets reject every configured handshake header before asking
for credentials. Use trusted server signaling and caller-owned WebRTC media/data
channels, or an explicitly injected backend proxy connector. Live has no client
secret endpoint. Wrap an HTTP-started data channel with
`LivePrimaryConnection(adapter, sessionAlreadyStarted: true, ownsSocket: false)`;
this admits application commands while forbidding duplicate startup and audio
append. Supply `initialSession` when its resolved configuration is known. The
caller retains ownership of the adapter and media.
For a broadcast typed channel, `LiveConnection.dataChannel(callerChannel)`
returns an already-started primary writer and owns only its message tap.

→ [Runnable offline primary/sideband example](example/live_websocket_example.dart)
demonstrates concurrent observers, manual delegation, two function results before
one continuation and confirmed usage, using synthetic peers at $0 API cost.
See [WebSockets](https://developers.openai.com/api/docs/guides/voice-websockets?api=live),
[server controls](https://developers.openai.com/api/docs/guides/voice-server-controls?api=live)
and [session management](https://developers.openai.com/api/docs/guides/live-conversations).

</details>

### How do I fork stored Live sessions and group captions?

<details>
<summary><b>Show example</b></summary>

Finish the original with `store: true`, wait for `session.closed`, and retain its
ID and your application task state. Storage must be enabled and permitted for
the project; ZDR disables it. A WebSocket fork gets a new connection and ID:

```dart
final fork = await client.live.forkConnection(sourceSessionId);
final captions = LiveTranscriptGrouper();
final captionTextById = <String, String>{};
final updates = captions.updates.listen((update) {
  // Each update is a complete snapshot. Replace text instead of appending it.
  captionTextById[update.segment.id] = update.segment.text;
});
final attachment = captions.attach(fork);
try {
  final started = await fork.start(
    LiveForkSessionStartEvent(session: LiveForkSessionConfigParam()),
  );
  print(started.session.id); // Save the new ID for controls and sidebands.
  // Receive application events on an independent fork.events tap. Explicitly
  // finish backend work before requesting session finalization.
  final ended = await fork.closeSession();
  print(ended.usage.seconds);
} finally {
  await attachment.detach();
  captions.close();
  await updates.cancel();
  await fork.close();
}
```

The empty startup object inherits model, voice, frontend instructions and saved
history. New WebSocket writers admit the documented `store`, Responses backend
settings and `audio.format` overrides; WebRTC client permissions and unknown
startup/audio override keys are rejected. The new connection defaults to PCM16
24 kHz independently of the source format. It cannot change delegation ownership.
The shared HTTP fork DTO retains its canonical open metadata contract. A fork
requires a finalized recording; it does not restore or replay external actions.
Check the outcome of previously submitted work before deliberately routing current
results to the new delegation and session.

Dispatch a `LiveResponseEvent` with `LiveResponsesEvent.fromLiveEvent(event)`.
`LiveResponsesLifecycleEvent.response` is a sparse `LiveCompactResponse` view,
preserving omission/null and future data. `LiveResponsesGranularEvent.granularEvent`
uses the ordinary granular codec where compatible. Future nested types, and
source-valid child shapes the ordinary codec cannot represent, remain lossless
`LiveResponsesRawEvent` values. Known malformed fields fail contextually. The
adapter's `type` is the nested discriminator; `source.type` and `toJson()` retain
the complete outer `response.event` frame and correlation.

Keep a call ledger from granular events, not empty lifecycle `output`/`tools`.
Collect every active call through the backend generation's final event, authorize
and submit all results, then send one continuation without an item-create ack
wait. Canceled or stale application outcomes need an explicit policy. Backend
completion, Live finalization and audible playback have separate lifetimes.

Grouping follows the SDK speaker/backchannel policy with defaults of 500 ms turn
separation, 2,000 ms assistant inactivity, 1,000 ms backchannel duration and
2,000 ms isolation, plus a 50 ms speaker settle window. Duplicate IDs are ignored;
timestamp resets end the previous local epoch. Some acknowledgments are suppressed,
so keep raw event taps for a lossless transcript. Segment IDs and close reasons
are local projection values, not server turns or voice activity detection.
`flush()`, `reset(clearSegments: ...)`, `close()` and attachment detachment are
explicit. Each helper owns only its timer and tap; application listeners and other
groupers keep working. `isSessionFinalized` requires observing `session.closed`.

`LiveTranscriptGrouping` offers a pure explicit-time policy. The Dart convenience
`projectLiveTranscriptPlayback(segment, sourceAnchorMs: ..., playbackAnchorMs: ...,
rate: ...)` maps source timing to a caller-supplied playback clock; it schedules no
audio and confirms no audible completion. Hardware playback remains caller-owned.
Reconnect, unsent queues, raw transport escape hatches and full SDK media helpers
remain separate inventory.
The transcript helpers include [upstream attribution and license notices](THIRD_PARTY_NOTICES.md).

→ [Runnable offline fork/transcript example](example/live_workflows_example.dart)
demonstrates both delegation modes, finalized originals, two mock WAV downloads,
inherited state, interleaved/canceled call IDs, caption taps and borrowed-channel
cleanup at $0 cost. See [stored session management](https://developers.openai.com/api/docs/guides/live-conversations)
and [delegation](https://developers.openai.com/api/docs/guides/live-delegation).

</details>

### How do I use the Realtime API?

<details>
<summary><b>Show example</b></summary>

The Realtime API supports two transports: WebSocket for persistent bidirectional streaming, and WebRTC for browser-friendly audio sessions.

**WebSocket:**

```dart
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

final client = OpenAIClient.fromEnvironment();

// Connect to a realtime session via WebSocket
final session = await client.realtime.connect(
  model: 'gpt-realtime-2',
  config: const realtime.RealtimeSessionCreateRequest(
    model: 'gpt-realtime-2',
    audio: realtime.RealtimeAudioConfig(
      output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    ),
    instructions: 'You are a helpful assistant.',
  ),
);

// Send a user text message and process events until the response is complete.
// (Use `session.appendAudioBytes(rawPcmBytes)` to stream raw audio instead.)
session.sendUserMessage('Say hello and nothing else.');

await for (final event in session.events) {
  switch (event) {
    case realtime.SessionCreatedEvent(:final session):
      print('Session created: ${session.id}');
    case realtime.ResponseTextDeltaEvent(:final delta):
      stdout.write(delta);
    case realtime.ResponseDoneEvent():
      await session.close();
    case realtime.ErrorEvent(:final error):
      print('Error: ${error.message}');
      await session.close();
    default:
      break;
  }
}

client.close();
```

**WebRTC:**

> **Note:** For WebRTC peer connections in Flutter, use the
> [`flutter_webrtc`](https://pub.dev/packages/flutter_webrtc) package.

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

final client = OpenAIClient.fromEnvironment();

// 1. Create a peer connection and generate an SDP offer
final pc = await createPeerConnection({'iceServers': []});
final offer = await pc.createOffer();
await pc.setLocalDescription(offer);

// 2. Send the SDP offer to OpenAI and get the SDP answer
final sdpAnswer = await client.realtimeSessions.calls.create(
  realtime.RealtimeCallCreateRequest(
    sdp: offer.sdp!,
    session: const realtime.RealtimeSessionCreateRequest(
      model: 'gpt-realtime-2',
      audio: realtime.RealtimeAudioConfig(
        output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
      ),
    ),
  ),
);

// 3. Set the SDP answer to complete the WebRTC handshake
await pc.setRemoteDescription(RTCSessionDescription(sdpAnswer, 'answer'));

// Call management operations (callId is obtained from your SIP/telephony layer)
const callId = 'call_xxx';

// Accept the call (optionally override the session configuration on accept).
await client.realtimeSessions.calls.accept(
  callId,
  request: const realtime.RealtimeSessionCreateRequest(
    model: 'gpt-realtime-2',
    audio: realtime.RealtimeAudioConfig(
      output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    ),
    instructions: 'Greet the caller in English.',
  ),
);
await client.realtimeSessions.calls.hangup(callId);
await client.realtimeSessions.calls.refer(
  callId,
  realtime.RealtimeCallReferRequest(targetUri: 'tel:+14155550123'),
);
await client.realtimeSessions.calls.reject(
  callId,
  request: realtime.RealtimeCallRejectRequest(statusCode: 486),
);

client.close();
```

→ [Full example](example/realtime_example.dart)

</details>

### How do I generate videos?

<details>
<summary><b>Show example</b></summary>

Use `client.videos.create(...)` to generate videos from text prompts with Sora. Poll with `retrieve` until the video is complete, then download the content.

```dart
final video = await client.videos.create(
  CreateVideoRequest(
    prompt: 'A cat playing piano in a jazz club',
    model: 'sora-2',
    size: VideoSize.size1280x720,
    seconds: VideoSeconds.s8,
  ),
);

final status = await client.videos.retrieve(video.id);
if (status.isCompleted) {
  final content = await client.videos.retrieveContent(video.id);
}
```

→ [Full example](example/videos_example.dart)

</details>

### How do I manage files?

<details>
<summary><b>Show example</b></summary>

Use the files API to upload, list, and retrieve file content. Files are used for fine-tuning, batches, and other workflows.

```dart
final file = await client.files.upload(
  bytes: fileBytes,
  filename: 'training.jsonl',
  purpose: FilePurpose.fineTune,
);

final files = await client.files.list();
final content = await client.files.retrieveContent(file.id);
```

→ [Full example](example/files_example.dart)

</details>

### How do I fine-tune a model?

<details>
<summary><b>Show example</b></summary>

Create a fine-tuning job by specifying a base model and a training file. Poll the job status to monitor progress and retrieve the fine-tuned model name when complete.

```dart
final job = await client.fineTuning.jobs.create(
  CreateFineTuningJobRequest(
    model: 'gpt-4o-mini-2024-07-18',
    trainingFile: 'file-abc123',
  ),
);

final status = await client.fineTuning.jobs.retrieve(job.id);
print('Fine-tuned model: ${status.fineTunedModel}');
```

→ [Full example](example/fine_tuning_example.dart)

</details>

### How do I use batch processing?

<details>
<summary><b>Show example</b></summary>

Batches let you queue many requests for asynchronous processing at lower cost. Create a batch from an input file and poll for completion.

```dart
final batch = await client.batches.create(
  CreateBatchRequest(
    inputFileId: 'file-abc123',
    endpoint: BatchEndpoint.chatCompletions,
    completionWindow: CompletionWindow.hours24,
  ),
);

final status = await client.batches.retrieve(batch.id);
print('Status: ${status.status}');
```

→ [Full example](example/batches_example.dart)

</details>

### How do I evaluate models?

<details>
<summary><b>Show example</b></summary>

Use the evals API to create evaluation definitions with grading criteria, then run them against test data to measure model performance.

```dart
final eval = await client.evals.create(
  CreateEvalRequest(
    name: 'My Evaluation',
    dataSourceConfig: EvalDataSourceConfig.custom(
      itemSchema: {
        'type': 'object',
        'properties': {
          'prompt': {'type': 'string'},
          'expected': {'type': 'string'},
        },
      },
    ),
    testingCriteria: [
      EvalGrader.stringCheck(
        name: 'matches_expected',
        input: '{{sample.output_text}}',
        operation: StringCheckOperation.ilike,
        reference: '%{{item.expected}}%',
      ),
    ],
  ),
);

final run = await client.evals.runs.create(
  eval.id,
  CreateEvalRunRequest(
    dataSource: EvalRunDataSource.jsonlContent([
      {'prompt': 'Say hello', 'expected': 'hello'},
    ]),
  ),
);
```

→ [Full example](example/evals_example.dart)

</details>

### How do I moderate content?

<details>
<summary><b>Show example</b></summary>

Use the moderations API to check whether text violates content policies. The result indicates whether the input was flagged.

```dart
final result = await client.moderations.create(
  ModerationRequest(
    input: ModerationInput.text('Check this text'),
  ),
);
print('Flagged: ${result.results.first.flagged}');
```

→ [Full example](example/moderation_example.dart)

</details>

### How do I check content provenance?

<details>
<summary><b>Show example</b></summary>

Use the content provenance checks API to detect OpenAI C2PA/SynthID signals in an uploaded image or audio file. Results are a sealed union — dispatch on the concrete type to read the fields specific to each signal.

```dart
final check = await client.contentProvenanceChecks.create(
  bytes: File('image.png').readAsBytesSync(),
  filename: 'image.png',
);

for (final result in check.results) {
  switch (result) {
    case C2PAProvenanceResult():
      print('C2PA: ${result.outcome}, trust: ${result.validationState}');
    case SynthIDProvenanceResult():
      print('SynthID: ${result.outcome}');
    case UnknownProvenanceResult():
      print('Unrecognized signal: ${result.type}');
  }
}
```

→ [Full example](example/content_provenance_checks_example.dart)

</details>

### How do I receive signed webhooks?

Use the original request bytes and headers with `WebhookVerifier.unwrapBytes`.
The standalone verifier needs only a signing secret. On a trusted receiver,
`WebhookVerifier.fromEnvironment()` reads `OPENAI_WEBHOOK_SECRET` without requiring
an API key. An existing client also exposes these local methods through
`client.webhooks`, using `OpenAIConfig(webhookSecret: ...)` or a per-call `secret`.
Local verification remains available after the client closes.

```dart
import 'package:openai_dart/openai_dart.dart';

WebhookEvent receiveDelivery(
  List<int> originalBytes,
  Map<String, String> headers,
  String signingSecret,
) {
  final verifier = WebhookVerifier(secret: signingSecret);
  // Verification happens before UTF-8, JSON or model parsing.
  return verifier.unwrapBytes(originalBytes, headers);
}
```

The 26 received event variants include Responses, Batch, Evals, fine-tuning,
Agent sessions, incoming Live/Realtime calls and safety notifications. Dispatch on
concrete types such as `ResponseCompletedWebhookEvent`. Future event types,
including video notifications without a published inbound schema, become
`UnknownWebhookEvent` and retain their raw JSON. Parsed known events also preserve
finite future metadata. Replacing a typed child uses that child's complete JSON;
metadata from the previous child is not restored. Optional `object` stays omitted
when absent, while Agent and safety events require `object: "event"`.

`verifySignature`/`unwrap` accept an untouched string; their `Bytes` counterparts
preserve exact original bytes. Required signed headers are case-insensitive,
nonempty and unambiguous. A `whsec_` secret uses canonical padded standard Base64;
other secrets are literal UTF-8 keys. Signature candidates accept `v1,<Base64>` or
bare canonical Base64, including rotation lists. The default five-minute timestamp
tolerance has inclusive past/future bounds. Timestamp text must be ASCII decimal
in 0..2^53−1; leading zeros retain their signed spelling. These strict policies
intentionally reject the loose timestamp/Base64 coercions used by some official
SDK helpers. An empty per-call secret fails instead of falling back.

Catch `InvalidWebhookSignatureException` for invalid signatures/timestamps,
`FormatException` for authenticated malformed event bodies, and `ArgumentError`
for invalid secret/tolerance configuration. This signature exception is separate
from HTTP `OpenAIException`. The verifier performs no automatic acknowledgment,
deduplication, API lookup or workflow action. Applications persist/queue their own
work and acknowledge promptly. Return a `2xx` status for successful receipt. The
provider retries failed or timed-out deliveries for up to 72 hours with exponential
backoff and treats `3xx` redirects as failures. Duplicate deliveries can use the
authenticated `webhook-id` as an idempotency key. Safety webhook contracts also
specify `410 Gone` as a signal to stop retries. These are delivery policies owned
by the receiver, with no SDK scheduler. Signing secrets belong on trusted infrastructure;
JavaScript/Wasm runtime support does not make browser deployment of secrets safe.

→ [Runnable offline signed receiver](example/webhooks_example.dart), which sends
three loopback deliveries (valid, duplicate, tampered) and makes no API calls.
See the [official Webhooks guide](https://developers.openai.com/api/docs/guides/webhooks).

### How do I investigate verified safety notifications?

Verify the original delivery bytes, then use `data.id` for an explicit lookup.
Project alerts need `api.safety.alerts.read`; organization cases need
`api.safety.read` on a key for the notified organization. Select separately scoped
clients on trusted infrastructure.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> inspectSafetyNotice(
  List<int> originalBytes,
  Map<String, String> headers,
  String signingSecret,
  OpenAIClient projectClient,
  OpenAIClient organizationClient,
) async {
  final event = WebhookVerifier(
    secret: signingSecret,
  ).unwrapBytes(originalBytes, headers);
  switch (event) {
    case SafetyAlertCreatedWebhookEvent():
      final alert = await projectClient.safety.alerts.retrieve(event.data.id);
      print('Block registered: ${alert.requestPaused}');
    case SafetyWarningIssuedWebhookEvent(:final data) ||
        SafetyDeactivationIssuedWebhookEvent(:final data):
      final safetyCase = await organizationClient.safety.cases.retrieve(
        data.id,
      );
      print('Notice: ${safetyCase.notice.type.name}');
    case SafetyOrgAlertCreatedWebhookEvent():
      print(
        'Workspace notice requires a separately scoped administrator lookup.',
      );
    default:
      break;
  }
}
```

`event.id` identifies the notification. `data.id` identifies the alert or case;
`entityIdentifier` is the application's safety identifier. `requestPaused` reports
block registration, without confirming execution stopped or earlier effects were
reversed. Both detail types retain required `reason: null`; alert reasons can be
null for Zero Data Retention requests. The models preserve open response metadata
in deeply immutable `rawJson`. Future received enum strings use `unknown` with
`rawErrorType` or `rawType`, preserving their exact spelling on serialization.
Model diagnostics redact reasons, explanations, identifiers and future values.

Project alerts also expose optional nullable `detailedExplanation` with
`hasDetailedExplanation` to distinguish an omitted key from an explicit null.
Empty text remains a present value. The service temporarily provides generated
explanations for eligible Zero Data Retention alerts and omits them when
unavailable. A null `reason` does not establish eligibility or availability.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> inspectSafetyExplanation(
  OpenAIClient projectClient,
  String alertId,
) async {
  final alert = await projectClient.safety.alerts.retrieve(alertId);
  switch ((alert.hasDetailedExplanation, alert.detailedExplanation)) {
    case (false, _):
      print('Explanation omitted by the service.');
    case (true, null):
      print('Explanation explicitly null.');
    case (true, final String explanation):
      // Access the actual text explicitly; default model diagnostics redact it.
      print('Explanation received: ${explanation.length} characters.');
  }

  final explicitNull = alert.copyWith(detailedExplanation: null);
  final omitted = alert.copyWith(hasDetailedExplanation: false);
  print('Null retained: ${explicitNull.hasDetailedExplanation}');
  print('Key omitted: ${!omitted.hasDetailedExplanation}');
}
```

`copyWith()` preserves the value and presence. Explicit null retains the key;
`hasDetailedExplanation: false` removes it from serialized JSON. Known raw
values are validated and cannot override explicit typed
fields or resurrect a cleared explanation. `rawJson` remains a detached received
snapshot and can still contain the original explanation; `toJson()` represents
the effective typed fields. Constructor omission can adopt a valid explanation
from legacy raw-only construction. This response field is separate from the
nonnull optional explanation in Responses monitoring errors.

→ [Runnable offline explanation example](example/safety_explanations_example.dart):
four explicit mock GETs cover absent, null, text and empty text, plus copy/clear and
private diagnostics. No API key or charges. See the
[official Safety alert retrieve reference](https://developers.openai.com/api/reference/resources/safety/subresources/alerts/methods/retrieve).

These are two GET operations with no list or enforcement action. ID maxima are
38 and 128 Unicode characters respectively; IDs are encoded once. Empty and dot
segments are rejected because they cannot address an individual resource through
Dart's URI path normalization. Normal HTTP exceptions and request IDs apply.

Workspace `safety.org_alert.created` uses
`https://api.chatgpt.com/v1/safety/alerts/{id}` with a workspace administrator key
and `chatgpt.enterprise.safety_alerts.read`. That separate lookup remains in the
Administration inventory. The webhook parser performs no automatic GET.

→ [Runnable offline safety example](example/safety_example.dart): two scoped
MockClient GETs after signature verification, duplicate/tampered delivery checks,
and explicit workspace routing. No API key or charges. Applications own durable
queuing, prompt acknowledgment and deduplication before background investigation.
See [Misalignment monitoring](https://developers.openai.com/api/docs/guides/safety-checks/misalignment-monitoring)
and [Safety enforcement notifications](https://developers.openai.com/api/docs/guides/safety-enforcement).

### How do I inspect monitoring failures?

HTTP failures expose passive `ApiException.misalignment`, including a 403 received
before streaming starts. Failed Responses expose `response.error?.misalignment`;
WebSocket errors use `event.error.misalignment`. All share
`ResponsesMisalignmentDetails` and `ResponsesMisalignmentSteer`, retaining their
existing WebSocket names and direct imports.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> inspectMonitoringFailure(OpenAIClient client) async {
  try {
    await for (final event in client.responses.createStream(
      const CreateResponseRequest(
        model: 'gpt-6-sol',
        input: ResponseInput.text('Run the requested task.'),
      ),
    )) {
      switch (event) {
        case ErrorEvent():
          print('Flat error: code present=${event.hasCode}; '
              'code is null=${event.code == null}.');
        case ResponseFailedEvent(:final response):
          print('Failed response: monitoring details present='
              '${response.error?.misalignment != null}.');
        default:
          break;
      }
    }
  } on PermissionDeniedException catch (error) {
    print('HTTP ${error.statusCode}: monitoring details present='
        '${error.misalignment != null}.');
    // Original code, requestId and body remain readable for trusted investigation.
  }
}
```

Details retain an open `errorType`, optional explanation/steer and an opaque
nullable `reviewTarget`; `hasReviewTarget` distinguishes omission from explicit
null. Nonnull targets require 1–96 ASCII letters, digits or `._~:-` characters,
without newlines. Parsed future
metadata is finite and deeply immutable. HTTP optional malformed details return
null while preserving the original exception/status/code/request ID/body and retry
classification; malformed supplied details on failed Responses or WS models fail
contextually. Default diagnostics and automatic monitoring response logs redact
sensitive explanations, instructions, tokens and identifiers. Caller-readable
values remain intact; avoid printing raw bodies or opaque strings.

Flat SSE `ErrorEvent` keeps nullable `code`/`param` and sequence presence; it does
not declare typed misalignment or headers. Failed `ResponseError` keeps its
distinct code/message/misalignment shape and emits no invented legacy type/param.
Legacy input/const constructor compatibility and the targeted output corrections
are described in the [migration guide](MIGRATION.md#upcoming-structured-monitoring-errors).

A policy 403 is not retried. Inspect failures without automatic reconnect,
replay, tool execution or continuation; one blocked WS response does not close
other multiplexed lanes. Existing opt-in recovery for unrelated transport failures
remains available. Use IDs from trusted verified notices for separately scoped
alert/case retrieval as shown above. `reviewTarget` is not a safety resource ID,
and `steer.message` is not an instruction to execute. The API offers no generic
resume/unblock method or monitoring configuration parameter.

→ [Runnable offline monitoring example](example/monitoring_errors_example.dart):
HTTP 403 before output, flat error/failed response after output, then two explicit
scoped GETs from signed notices. Five MockClient requests, no real API key or charges.

### How do I manage webhook endpoints?

The authenticated project API exposes `client.webhooks.create`, `list`, `retrieve`,
`update`, `delete`, `rotateSecret` and `test`, plus `eventTypes.list()` to discover webhook event types.
Create/update/test use the 23 canonical `WebhookEventType` choices, including
video. Returned endpoint/discovery strings stay open to future values. Discovery
alone does not make a future string admissible in a typed writable request.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<int> configureProjectWebhook(
  OpenAIClient client,
  Future<void> Function(String endpointId, String secret) saveSecret,
) async {
  final created = await client.webhooks.create(WebhookEndpointCreateRequest(
    name: 'Completed responses',
    url: 'https://receiver.example/webhook',
    eventTypes: const [WebhookEventType.responseCompleted],
  ));
  await saveSecret(created.id, created.signingSecret);
  final rotated = await client.webhooks.rotateSecret(created.id,
    request: WebhookEndpointRotateSecretRequest(
      keepOldSecretActiveFor24Hours: true,
    ),
  );
  await saveSecret(rotated.id, rotated.signingSecret);
  final tested = await client.webhooks.test(created.id,
    WebhookEndpointTestRequest(eventType: WebhookEventType.responseCompleted),
  );
  // success:true means the test request completed. Check the receiver separately.
  return tested.statusCode;
}
```

Create requires a 1–256 character name, an HTTPS-prefixed URL of at most 2,048
characters and a nonempty event list. Update uses POST, accepts any subset including
`WebhookEndpointUpdateRequest()` and replaces the complete event set when supplied.
Use `list(limit: ..., after: ...)` with the returned `lastId` cursor and `hasMore`;
there is no inferred cursor, `before` or ordering parameter. Limits are 1–100,
with server default 20. Required nullable signing hints/page cursors remain explicit
nulls, while optional `updatedAt` stays omitted when absent.

Create/rotate return `WebhookEndpointWithSecret`. Store the returned key securely;
ordinary endpoint retrieval never returns it. Rotation with no request body or
with the default false option invalidates the old key immediately. Explicit true
allows a 24-hour overlap. Applications coordinate stored keys and receiver updates;
rotation does not mutate `OpenAIConfig.webhookSecret`. `test` sends a real delivery:
its `success: true` result may still report a 4xx/5xx `statusCode` from the receiver.
Endpoint HTTP methods use normal auth, cancellation, closed-client checks and retry
policy; local verification remains independent of HTTP/client lifetime.

Built-in response logging redacts `signing_secret` structurally before truncation,
including nested/escaped keys and short/raw-looking values. Safe default error
messages and diagnostics omit secret values; raw response/model JSON and exception
body remain available to the caller. Error codes/types/parameters and quota retry
classification remain intact. As with existing client logging, configure
`hierarchicalLoggingEnabled = true` when setting a nonroot client logger level.
Custom logging of raw responses or `toJson()` remains caller-owned.

→ [Offline endpoint lifecycle example](example/webhook_endpoints_example.dart),
which uses MockClient for all eight operations, returned cursor/event discovery,
secret storage/rotation and a completed test with receiver status 500. It makes
no API calls and sends no external test delivery.
See the [official Webhooks reference](https://developers.openai.com/api/reference/resources/webhooks).

## Error Handling

<details>
<summary><b>Handle retries, validation failures, and request aborts</b></summary>

`openai_dart` throws typed exceptions so retry logic and validation handling stay explicit. Catch `ApiException` and its subclasses first, then fall back to `OpenAIException` for other transport or parsing failures.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('Ping'),
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Rate/quota error ${error.code ?? error.type}: ${error.message}');
    stderr.writeln('Server retry hint: ${error.retryAfter}');
    // Billing/spend/quota errors require action before resending.
  } on InternalServerException catch (error) {
    stderr.writeln('Server error ${error.statusCode}; hint: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('OpenAI API error ${error.statusCode}: ${error.message}');
  } on OpenAIException catch (error) {
    stderr.writeln('OpenAI client error: $error');
  } finally {
    client.close();
  }
}
```

Regular cloneable requests retry transient 429 responses and retry
5xx/timeouts/connections only for idempotent methods. Structured billing/spend/quota
429 codes and `insufficient_quota` type require action and stop automatic retries.
Unknown provider 429 bodies retain the existing fallback. POST 5xx, multipart
requests, and streams are not automatically replayed.

`retry-after-ms` takes precedence when valid; otherwise `Retry-After` accepts
seconds or HTTP dates. Fractional hints remain precise, scheduled waits round
up, and past dates mean zero. A valid hint above twice `RetryPolicy.maxDelay`
returns the original error immediately with its full `retryAfter`; shorter
automatic replay would violate the server minimum. This hint is exposed on
both `RateLimitException` and `InternalServerException`, including before a
stream starts. `maxRetries: 0` disables automatic retries for application-owned
retry loops. Cancellation can interrupt permitted waits.

→ [Error-handling example](example/error_handling_example.dart) and
[local retry/quota example](example/retry_guidance_example.dart)

See the [official retry guidance](https://developers.openai.com/api/docs/guides/rate-limits)
and [migration guide](MIGRATION.md) for exact boundaries.

</details>

## Examples

See the [example/](example/) directory for complete examples:

| Example | Description |
|---------|-------------|
| [`agent_environments_example.dart`](example/agent_environments_example.dart) | Offline template CRUD and owned hosted environment prewarming, pagination and safe inspection |
| [`vaults_example.dart`](example/vaults_example.dart) | Offline Vault CRUD and write-only credential create/rotate with safe inspection |
| [`agent_session_history_example.dart`](example/agent_session_history_example.dart) | Offline root/turn history and published OTLP trace pagination |
| [`agent_sessions_example.dart`](example/agent_sessions_example.dart) | Offline durable sessions, persistent observation, manual function result and explicit cancellation |
| [`saved_agents_example.dart`](example/saved_agents_example.dart) | Offline saved-agent CRUD, all six persisted tools, pagination, replacement and clear/reset |
| [`monitoring_errors_example.dart`](example/monitoring_errors_example.dart) | Offline typed HTTP/SSE monitoring failures and explicit scoped investigation |
| [`safety_example.dart`](example/safety_example.dart) | Offline verified notifications and separately scoped alert/case retrieval |
| [`safety_explanations_example.dart`](example/safety_explanations_example.dart) | Offline project alert explanation presence, copy/clear and private diagnostics |
| [`webhook_endpoints_example.dart`](example/webhook_endpoints_example.dart) | Offline project endpoint lifecycle, pagination, discovery, rotation and test status |
| [`webhooks_example.dart`](example/webhooks_example.dart) | Offline signed receiver, acknowledgment and caller-owned deduplication |
| [`chat_example.dart`](example/chat_example.dart) | Chat completions, multi-turn conversations, and legacy cache retention |
| [`streaming_example.dart`](example/streaming_example.dart) | Content streaming, detailed final usage, and obfuscation controls |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Function calling with tool definitions |
| [`vision_example.dart`](example/vision_example.dart) | Image analysis with vision models |
| [`responses_example.dart`](example/responses_example.dart) | Responses API with built-in tools |
| [`async_tools_example.dart`](example/async_tools_example.dart) | Local async function/custom jobs, original call IDs and latest-response continuation |
| [`prompt_cache_example.dart`](example/prompt_cache_example.dart) | Responses prewarming, comparison diagnostics, and narrow Chat cache options |
| [`decisions_example.dart`](example/decisions_example.dart) | Typed Decisions questions, refusals, usage, and inline images |
| [`decision_image_urls_example.dart`](example/decision_image_urls_example.dart) | Offline HTTP(S)/data image references, exact mixed input and one mock POST |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings with dimension control |
| [`image_model_selection_example.dart`](example/image_model_selection_example.dart) | Local generation/multipart/JSON-edit model contracts without API calls |
| [`images_example.dart`](example/images_example.dart) | GPT Image generation |
| [`videos_example.dart`](example/videos_example.dart) | Sora video generation, editing, and extension |
| [`audio_example.dart`](example/audio_example.dart) | Text-to-speech and transcription |
| [`speech_streaming_example.dart`](example/speech_streaming_example.dart) | Offline buffered/byte/SSE speech, voice references and usage |
| [`existing_audio_example.dart`](example/existing_audio_example.dart) | Offline modern file fields, verbose/raw translation, open/custom Chat voices and AAC |
| [`voice_consents_example.dart`](example/voice_consents_example.dart) | Offline upload/list/retrieve/rename/delete consent lifecycle and explicit pagination |
| [`voices_example.dart`](example/voices_example.dart) | Offline explicit consent and sample upload, then caller-selected custom voice reference |
| [`live_http_example.dart`](example/live_http_example.dart) | Offline WebRTC/SIP signaling, explicit call controls, verified incoming notice, WAV downloads and REST fork |
| [`live_websocket_example.dart`](example/live_websocket_example.dart) | Offline primary/sideband Live, concurrent event taps, manual delegation and graceful finalization |
| [`live_workflows_example.dart`](example/live_workflows_example.dart) | Offline stored forks, inherited state, compact Responses, caption grouping and borrowed-channel cleanup |
| [`chat_audio_example.dart`](example/chat_audio_example.dart) | Chat audio output, ID-only replay, and partial stream accumulation |
| [`files_example.dart`](example/files_example.dart) | File upload and management |
| [`conversations_example.dart`](example/conversations_example.dart) | Conversations API for state management |
| [`containers_example.dart`](example/containers_example.dart) | Container memory/network configuration, Code Interpreter IDs, and files |
| [`chatkit_example.dart`](example/chatkit_example.dart) | ChatKit sessions and threads |
| [`assistants_example.dart`](example/assistants_example.dart) | Assistants API (deprecated) |
| [`evals_example.dart`](example/evals_example.dart) | Model evaluation and testing |
| [`retry_guidance_example.dart`](example/retry_guidance_example.dart) | Local transient, permanent-quota, and long-hint scenarios without API calls |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`models_example.dart`](example/models_example.dart) | Model listing and retrieval |
| [`batches_example.dart`](example/batches_example.dart) | Batch processing for async jobs |
| [`moderation_example.dart`](example/moderation_example.dart) | Content moderation |
| [`content_provenance_checks_example.dart`](example/content_provenance_checks_example.dart) | Content provenance (C2PA/SynthID) detection |
| [`web_search_example.dart`](example/web_search_example.dart) | Web search with Responses API |
| [`web_search_controls_example.dart`](example/web_search_controls_example.dart) | Local GA filters, image results, sources, and REST/SSE parsing without API calls |
| [`shell_tools_example.dart`](example/shell_tools_example.dart) | Offline hosted configuration, synthetic local continuation, and typed shell stream events |
| [`compaction_progress_example.dart`](example/compaction_progress_example.dart) | Offline nonterminal compaction progress and opaque final output preservation |
| [`access_programs_example.dart`](example/access_programs_example.dart) | Offline access-program selection, server defaults and effective returned metadata |
| [`tool_search_example.dart`](example/tool_search_example.dart) | Offline client tool-search continuation with the original call ID and complete discovered definitions |
| [`responses_websocket_example.dart`](example/responses_websocket_example.dart) | Offline warm-up, two persistent lanes and incremental continuation with awaited cleanup |
| [`realtime_example.dart`](example/realtime_example.dart) | Realtime API (WebSocket and WebRTC) |
| [`fine_tuning_example.dart`](example/fine_tuning_example.dart) | Fine-tuning job management |
| [`completions_example.dart`](example/completions_example.dart) | Legacy completions API |
| [`uploads_example.dart`](example/uploads_example.dart) | Large file multipart uploads |
| [`skills_example.dart`](example/skills_example.dart) | Skills management |
| [`input_tokens_example.dart`](example/input_tokens_example.dart) | Input token counting |
| [`openai_dart_example.dart`](example/openai_dart_example.dart) | Quick-start overview |

## API Coverage

| API | Status |
|-----|--------|
| Agents | Saved agent CRUD and durable session CRUD, JSON/SSE creation, persistent event observation and manual inputs; root/turn history and published OTLP traces; owned hosted environments and template CRUD; live files and published artifacts; child inspection and item/turn history |
| Vaults | Vault CRUD and write-only OAuth, bearer and hosted environment-variable credential management |
| Chat Completions | Supported; stored-completion management pending |
| Responses API | Supported with persistent WebSockets, mid-turn steering, opt-in recovery and beta tool-result injection; additional tool/configuration details pending |
| Decisions API | ✅ Full |
| Embeddings | ✅ Full |
| Images | ✅ Full |
| Videos (Sora) | ✅ Full |
| Audio (Speech, Transcription, Translation, Custom Voices) | Buffered/streamed speech and file transcription; explicit JSON/verbose/raw translation, current options/open/custom references, all five consent operations and sample-derived voice creation; guide-only consent phrase lookup remains untyped |
| Live | All seven HTTP operations, recordings, shared configuration/tools, primary/sideband/fork WebSockets, complete event codecs, compact Responses dispatch and transcript helpers; reconnect/queue/media convenience parity remains inventoried |
| Files | ✅ Full |
| Uploads | ✅ Full |
| Batches | ✅ Full |
| Models | ✅ Full |
| Moderations | ✅ Full |
| Fine-tuning | Supported; some job/grader/checkpoint operations pending |
| Evals | ✅ Full |
| Conversations | ✅ Full |
| Containers | Supported with memory, network policies/domain secrets, and skill configuration |
| Content Provenance Checks | ✅ Full |
| ChatKit Beta | ✅ Full |
| Realtime | ✅ Full (separate import) |
| Webhooks | Local signed verification, 26 typed received events and all eight project endpoint/discovery operations |
| Safety | Read-only project alerts with typed explanation presence, organization cases and shared HTTP/Responses/WS monitoring details; workspace lookup remains separate |
| Assistants (Deprecated) | ✅ Full (separate import) |
| Threads (Deprecated) | ✅ Full (separate import) |
| Messages (Deprecated) | ✅ Full (separate import) |
| Runs (Deprecated) | ✅ Full (separate import) |
| Vector Stores (Deprecated) | ✅ Full (separate import) |
| Completions (Legacy) | ✅ Full |

Remaining Agents and Vaults operations belong to the bounded [API alignment roadmap](specs/api-alignment/README.md). Administration and retained SDK transport/media conveniences are deferred inventory.

## Official Documentation

- [API reference](https://pub.dev/documentation/openai_dart/latest/)
- [OpenAI API docs](https://platform.openai.com/docs/api-reference)
- [OpenAI Python SDK](https://github.com/openai/openai-python)
- [OpenAI Node.js SDK](https://github.com/openai/openai-node)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by OpenAI.
