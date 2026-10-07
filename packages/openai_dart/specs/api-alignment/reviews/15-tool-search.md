# Tool-search fidelity acceptance

Status: merged in PR #352; #340 closed.
Implementation [PR #352](https://github.com/davidmigloz/ai_clients_dart/pull/352)
merged after green CI on October 7, 2026 at 21:06:42 UTC.
Merge commit: `9944b421e7bad565e0be20bc04e314e4571dd50e`.
Tracking: [#340](https://github.com/davidmigloz/ai_clients_dart/issues/340),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-SEARCH-01–02](../responses.md#tool-search).
Implementation branch: `fix/openai-tool-search-fidelity`.

## Directional item contracts

Writable `ToolSearchCallItemParam.arguments` is a required nonnull JSON object.
Writable search call/output metadata remains optional: nullable id/call ID/status
and beta agent normalize null to omission, whereas supplied execution is nonnull.
An empty argument object, an empty output tool list, supplied empty optional
identifiers, false flags and empty description/schema values retain their values.
The client inserts no execution or status default.

Returned `ToolSearchCallOutputItem` and `ToolSearchOutputItem` require id, call ID,
execution, status and arguments/tools. Call ID is required nullable. Call arguments
are required arbitrary JSON: null, strings, integers, doubles, booleans, lists and
nested maps survive parsing and serialization. Missing arguments are distinct from
explicit null. Returned beta agent and creator are optional nonnull JSON fields;
wrong types or explicit null fail contextually. Existing unknown execution/status
strings retain their enum fallback and normalize to `unknown`.

The canonical ItemResource/BetaItemResource unions reference these returned
contracts. `Item.fromResourceJson` now routes to distinct
`ToolSearchCallResourceItem`/`ToolSearchOutputResourceItem` variants, preserving
arbitrary arguments, required nullable call ID, full tools, creator and beta agent.
`Item.fromJson` continues to parse writable parameter contracts. Conversation
call/output variants likewise use the GA returned contracts and now retain
`createdBy`; their existing `ItemStatus` type is preserved.

Every changed variant has full serialization, copy/clear, deep equality/hash,
runtime-type symmetry and safe diagnostic coverage. Const constructors and
caller-owned constructor collection behavior remain available. Parsed arguments,
definition JSON and tool lists take recursively unmodifiable snapshots.
Object-shaped resource calls can convert to
writable input; non-object arguments throw a contextual StateError in that explicit
conversion. Raw `ResponseInput.fromOutputItems` history preserves arbitrary returned
JSON without routing it through the stricter writable call DTO. Stored-result
conversion omits returned-only creator metadata.

## Definition contexts and compatibility decisions

`ResponseTool.fromToolSearchOutputJson` and `toToolSearchOutputJson` provide an
explicit discovered-definition context without changing ordinary factory
signatures or factory tear-offs. Top-level function definitions require nullable
parameters and strict keys and emit those keys even when null. Nested discovered
functions require only type/name and accept dotted names. Ordinary namespaces
retain their narrower nested naming contract. Known malformed function/custom
definitions fail contextually with list indices; future namespace-only tool
definitions remain `UnknownNamespaceTool` with raw JSON, deep value/hash behavior,
copy semantics and safe diagnostics. No global unknown ResponseTool type is added.

Nested function/custom async, defer-loading, allowed callers, descriptions,
applicable parameters/strict, output schemas and custom formats remain intact.
NamespaceTool and ToolSearchTool receive complete copy/value/diagnostic contracts;
search parameters use deep comparison/hash. Previous async-definition behavior
is retained rather than replacing definitions with incomplete discovery stubs.

Two source discrepancies are explicit:

- Returned ToolSearchOutput.tools references ordinary Tool/NamespaceToolParam in
  the canonical schema, while writable discovered namespace definitions and SDK
  string typing permit dotted, minimally defined functions. The guide establishes
  loaded-tool continuation. Applying the discovered context to returned
  namespaces is a compatibility inference from those sources. It is not a claim
  that the guide explicitly documents dotted names or that the canonical returned
  namespace reference itself names a separate discovered schema.
- Guide top-level function examples omit strict, whereas canonical FunctionTool
  requires nullable parameters/strict keys. The implementation keeps the canonical
  top-level requiredness; fixture/example definitions supply these keys explicitly.
  Nested discovery retains its own optional fields.

This is a targeted breaking correction. Writable call constructors now require
arguments; returned constructors require their contextual fields and broaden
arguments to Object?. New resource variants extend sealed Item and replace
writable parameter subtypes in input-list results. Migration must cover manually
constructed models, casts and exhaustive switches, plus typed versus raw replay.
README, migration guidance and the runnable offline example document these
boundaries without changing the package version.

## Public transport fixtures

3,491 deterministic public fixtures pass through the exported package API. Exact
method/path/auth/header/query/body assertions cover Responses create/retrieve,
input-items listing and conversation creation/items create/retrieve/list. GA/beta
Responses paths retain required/null keys, optional owner metadata and complete
discovered definitions. Input-list fixtures assert the concrete new resource
subtypes through the public import.

Both output-item added/done events and all six response lifecycle events retain
the returned shapes. Plain and accumulated SSE exercise created, queued,
in-progress, completed, failed and incomplete responses. Mixed added/done streams
expose typed search events while leaving accumulated content unchanged until the
terminal response supplies the complete tool lists. No transport rewrite or new
search event is introduced.

Hosted server fixtures retain explicit null call IDs. Client continuation echoes
the original search call ID with execution:client and the complete discovered
tools. Raw history replay retains all arbitrary argument shapes. Writable request
factories preserve empty tool lists and normalize nullable optional metadata.
Malformed required fields, wrong shapes and nested definitions fail with contextual
FormatException; future nested tools and existing unknown enum normalization remain
compatible. Every fixture uses MockClient; no API calls or provisioning occur.

## Official sources and manifest audit

The fresh source review retains pinned
[OpenAPI 234829e](https://github.com/openai/openai-openapi/blob/234829e2b634b8fb159df7fcddbffad204173ffd/openapi.json),
with 356 operations, 2,010 schemas and no new wire changes. Canonical contents and
their existing provenance are unchanged. Official clients remain
[Python 3.26.0 / 4e152cd](https://github.com/openai/openai-python/tree/4e152cdefe1844c2d5d78653310e9b9c0195c44e)
and [Node 7.30.0 / a4942ba](https://github.com/openai/openai-node/tree/a4942ba48e999f9f637f81c5c925ed91b326343f).

The [tool-search guide](https://developers.openai.com/api/docs/guides/tools-tool-search),
[Python discovered namespace](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/tool_search_output_namespace_tool.py),
[Python returned call](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_tool_search_call.py)
and [Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts)
establish hosted/client continuation and the discovered context. Writable object
arguments follow canonical EmptyModelParam; official clients' broader inline
object/unknown annotations do not establish an equally precise JSON object
restriction.

The manifest adds 27 entries: real GA/beta request/returned/resource, namespace,
discovered function, callable-definition and enum mappings; conversation mappings
reuse the real GA returned schemas. The existing unknown namespace fallback is
registered as an extension without an invented upstream schema. No new exclusions
hide contextual mismatches.

Full toolkit verification remains diagnostic and exits 1: implementation reports
135 errors, 22 warnings and 199 infos; consistency reports 26 warnings. The previous
baseline was 126/22/167 and 19 consistency warnings. All nine additional errors
reflect scanner limitations against exercised contracts:

- Five GA/beta output/resource and GA conversation call mappings report required
  arbitrary arguments as nullable because Dart represents arbitrary JSON as
  Object?. The parsers enforce key presence and retain explicit null, as required
  by the unconstrained canonical arguments property.
- Four GA/beta ordinary/discovered NamespaceTool mappings report missing field
  references because their fixed-signature factory delegates to contextual
  parsing. Tests exercise every required namespace field and the delegation.

The 32 additional infos describe shared status enums, EmptyModelParam represented
as JSON maps, tool unions reused as ResponseTool, and shared beta agent/caller
types. New consistency comparisons expose deliberate request/returned nullability
and type differences; older type/requiredness findings remain visible. Both
independent reviewers checked this classification. Docs, exports and README
verification have no issues. No new exclusions or suppressed diagnostics were
introduced, and the global result is not described as a clean verifier pass.

The sibling audit was refreshed with `rg -n 'tool_search|ToolSearch'` over
`packages/open_responses/lib` and `packages/open_responses/specs`; it returned no
matches. The implementation and published schema contain no tool-search contracts,
so no speculative sibling feature is introduced. The older
`apply_patch` branch remains absent from the ResponseTool union and outside this
slice. Older parent-model gaps, existing pagination requiredness tolerance and
other complete-parity findings remain visible in the roadmap. This work does not
claim complete Responses or ToolSearchOutputTool union parity.

## Final validation and independent reviews

- 376 new item-model cases pass, covering eight directional variants and their
  full copy/value/hash/diagnostic and conversion boundaries.
- 133 new definition cases pass, covering contextual definitions, preserved
  async/options and future namespace fallback.
- 3,491 new public HTTP/SSE fixtures pass; 4,000 new tests in total. The public
  fixture file has clean scoped formatting, fatal-info analysis and diff checks.
- Final package formatting checks 476 files with zero changes after automatic
  fixes. Full fatal-info analysis and diff checks pass.
- Full package unit suite: 10,152 tests pass, two existing environment-dependent
  skips. Existing async-definition and access-program fixtures remain in the
  regression suite.
- README/llms and migration guidance reflect the public API. The exact README
  usage block compiles in a temporary Dart function with clean fatal-info analysis;
  the scratch file was removed. The offline example
  runs successfully with two injected local requests, the original call ID and
  complete discovered definitions. Retries are disabled and resources close;
  no API key, provisioning, tool execution or live acceptance test is needed.
  API cost is $0. No publishing or version bump occurred.
- Full toolkit scope retains the classified diagnostics above; docs, exports and
  README checks have no issues.
- Independent requirements and engineering reviewers approve the final combined
  runtime, tests, manifest, README/llms, migration, example and evidence. The
  engineering review corrected a migration Before constructor to include the
  previously required execution; the requirements review added
  `parallelToolCalls: false` to README usage that selects a single call and
  clarified source attribution for dotted names. All findings are resolved.
  Reviewers independently reran model/public tests, clean scoped analysis and
  the offline example, and verified the toolkit diagnostic classification.
- Implementation [PR #352](https://github.com/davidmigloz/ai_clients_dart/pull/352)
  uses the create-pr skill template, with validation/tracking under Details and
  exactly the five checklist items at the end. The complete final GitHub
  workflow and all checks passed before PR #352 merged, closing #340; Responses WebSocket sessions #341 follow this slice.
