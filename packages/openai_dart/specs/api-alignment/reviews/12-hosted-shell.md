# Hosted/local shell acceptance

Status: implementation, validation and independent reviews complete; merge pending.
Tracking: [#337](https://github.com/davidmigloz/ai_clients_dart/issues/337),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-SHELL-01–03](../responses.md#shell).
Implementation branch: `feat/openai-hosted-shell`.

## Outcome and directional contracts

`ShellTool` and `ResponseTool.shell()` support optional nullable environment and
allowed callers. `ShellToolEnvironment` distinguishes automatic hosted containers,
local runtime and existing container reference. Auto configuration emits
`container_auto`, reuses merged memory/network/hosted-skill leaves, and retains
optional files, nullable memory, network policy and skills without defaults.
Local configuration has distinct required name/description/path skills. New
collection-bearing environments freeze their lists; future environment JSON is
recursively immutable. Existing ShellTool const construction and caller-owned
allowed-callers lists remain compatible; parsed lists are unmodifiable.

`ResponseToolChoice.shell()` supports the canonical specific-shell discriminator.
Existing modes, function, allowed, GA/preview web search and programmatic choices
remain available. Fixed type, copies, value/hash and diagnostics are verified.

Direct writable history uses `ShellCallInputItem`, `ShellCallActionInput`,
`ShellCallOutputInputItem` and `ShellCallOutputContentInput`. Commands and
stdout/stderr/outcome are required. Input IDs, status, action/output limits, caller
and beta agent are optional nullable and normalize null to omission. Input local
environments can retain skill descriptors; reference environments require their
container ID. Direct input rejects auto environments both when parsing and
serializing, including an attempted future-wrapper bypass.

Returned calls require ID, call ID, action, status and a nullable environment key.
Returned action requires both nullable timeout/max-output keys. Returned results
require ID, call ID, status, output and nullable max-output key. These keys always
serialize, including null. Existing returned DTO names and const constructors
remain; nullable arguments and result status are now explicitly required, with
migration guidance. Returned environments stay separate: local has no skills,
reference retains its container ID, and auto is rejected. Exit requires exit code;
timeout has its fixed discriminator. Future outcomes retain immutable raw JSON.

Optional nonnull creator metadata survives returned calls, results and output
content. Caller metadata retains nullable direct/program contexts. Existing
output DTO agent-null normalization stays compatible; newly typed returned input
list/conversation DTOs follow optional nonnull agent contracts and reject null.
All known malformed required/supplied members report contextual FormatException.

Responses input listings use `ShellCallResourceItem`/`ShellCallOutputResourceItem`.
Stored conversations use `ConversationShellCallItem`/
`ConversationShellCallOutputItem`. All six returned variants bridge to writable
input with `toShellCallInputItem()`/`toShellCallOutputInputItem()`, retaining
input-supported fields and omitting returned-only creators, including output
content creators. Input/output union parsers, input-resource parsing, conversation
parsers and all public request paths use the appropriate directional models.

Every old/new field participates in serialization, copy/clear, equality/hash and
safe diagnostics. Existing caller-owned list semantics remain where const
compatibility requires them; new collection models and parsed collections freeze
their lists. Commands, stdout/stderr, agent/creator metadata, skill paths/
descriptions, padding and future raw JSON are summarized in diagnostics.

## Stream events and example

All five exact events parse through `ResponseStreamEvent` and public SSE:
command added/delta/done, and output-content delta/done. They require sequence,
output index and command index. Only content events require item ID. Command
delta supports optional nonnull obfuscation; content delta uses
`ShellCallOutputDelta` with independently optional nonnull stdout/stderr. Empty
objects/fragments survive. All event beta agents are optional nonnull. Done
content uses returned output chunks, including creators and exit/timeout outcomes.
Final completed lifecycle responses and the existing accumulator retain full
shell metadata; no generalized shell-fragment accumulator or transport is added.

The offline example configures hosted memory/network/skills, describes a local
skill, inspects a proposed call and returns synthetic output on its original
call ID with the model's output limit and latest previous response ID. A local
MockClient emits typed events and a complete terminal response. It executes no
proposed commands, creates no containers, uses no API key and makes no API calls.

## Official sources and boundaries

Fresh October 7 toolkit fetch/review is JSON-equal to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json)
(356 operations, 2,010 schemas). No semantic promotion was needed; metadata-only
fetch churn was restored. Describe/scaffold dry-run reviewed the real shell
definition after contextual mappings were registered.

Revalidated [Python definition](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/function_shell_tool_param.py),
[Python returned call](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_function_shell_tool_call.py)
and [Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts).
Python's optional annotations/defaults tolerate absent required nullable keys and
null creators more broadly; canonical and Node establish the directional key
presence and optional nonnull creator contracts implemented here. Node's named
output-content helper lacks creator metadata present on its nested returned-output
shape; canonical returned content establishes preservation in this client.

The [shell guide](https://developers.openai.com/api/docs/guides/tools-shell) and
[skills guide](https://developers.openai.com/api/docs/guides/tools-skills) describe
hosted configuration versus local skill directories and result continuation.
The shell guide abbreviates returned-call examples without all required IDs/
environment keys; complete fixtures follow canonical instead. Canonical service
limits (50 uploaded files and 200 skills per applicable environment) are documented
and left to service enforcement, consistent with existing container leaves.
Hosted outbound access needs organization configuration and an explicit policy;
no automatic execution, broad validation framework or model allowlist is added.

The sibling `open_responses` published implementation has no shell equivalents
requiring matching changes. Later WebSocket transport will reuse the shared event
decoder; no WebSocket integration is claimed in this ticket.

## Manifest and full verification

Seventy-two mappings were added: 66 real GA/beta contextual schemas and six
explicit inline-union/future extensions. Reused container leaves keep their real
existing mappings. No new exclusions or skipped schemas conceal gaps. Exports,
docs and README checks pass.

Full implementation verification reports 82 errors, ten warnings and 133 infos;
consistency reports 19 warnings. Baseline #348 was 66/10/118 with three consistency
warnings. The 16 newly exposed implementation errors are parser scanner false
positives across GA/beta action, content, reference, exit and delta aliases: its
method-body extractor selects named context-parameter braces instead of the
factory body. Actual parsers read all reported fields and focused/public fixtures
verify preservation and malformed-member errors. New infos concern shared caller,
agent and outcome aliases. The 16 additional consistency warnings compare
heterogeneous action/status/environment/content/skill/delta shapes across sealed
variants and directional DTOs; these differences are source-backed contracts.
Wider unrelated errors remain visible in the complete-parity backlog.

## Validation and reviews

- Package unit suite: 5,163 passing, two existing environment-dependent skips.
- 1,260 new deterministic tests: 138 tool/environment, 380 call/input/resource/
  conversation/value contracts, 197 stream-event, eight choice and 537 public
  REST/SSE/conversation fixtures.
- Format: 463 Dart files, final zero changes. Dart fix: nothing to fix. Package
  fatal-info analysis is clean. Existing generic, agent and caller shell fixtures
  now include the corrected required nullable arguments.
- Exact new README and migration after-snippets compile with fatal-info analysis.
  README examples table, migration, llms and public documentation match the APIs.
- Offline example passes three MockClient requests with exact bodies and typed
  completion checks. No API key use, live requests, containers or charges.
- Public fixtures cover GA/beta request protocol, all environments, statuses,
  outcomes, creators, directional replay, input listings and conversations.
  Interleaved event indices, independent fragments, empty deltas, padding and
  terminal metadata survive public SSE and accumulation. Malformed fixtures cover
  every public parsing path; request reuse remains unchanged.
- Independent engineering review found two runtime-type equality/hash issues and
  a removed exit-outcome equality guard. Guards and three subclass regression
  tests resolve the findings. Requirements/engineering reviews found an event
  agent-diagnostics documentation mismatch; all five diagnostics now summarize
  agent names, with five regression cases verifying JSON preservation.

Both reviewers rechecked the final combined diff and acceptance record and approve
with no remaining actionable findings. Issue #337 stays open until implementation
merge; compaction progress #338 is next.
