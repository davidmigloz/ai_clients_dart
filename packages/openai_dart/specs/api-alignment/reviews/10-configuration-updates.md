# Persistent reasoning configuration update acceptance

Status: implementation, validation, and independent reviews complete; merge pending.
[PR #347](https://github.com/davidmigloz/ai_clients_dart/pull/347) is open for review.
Tracking: [#335](https://github.com/davidmigloz/ai_clients_dart/issues/335),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-CONFIG-01–02](../responses.md#configuration-updates).
Implementation branch: `feat/openai-configuration-updates`.

## Outcome and contextual contracts

`ConfigurationUpdateItem` supplies typed request input with optional nullable ID,
optional nonnull reasoning, and nullable beta agent metadata. The narrow
`ConfigurationUpdateReasoning` exposes only optional nullable effort, using the
existing `ReasoningEffort` enum and unknown-value fallback. Summary, context, and
mode stay on request-level `ReasoningConfig`.

`ConfigurationUpdateItemResponse` requires ID on Responses input-list responses;
`ConversationConfigurationUpdateItem` requires ID on stored conversation items.
Both provide `toConfigurationUpdateItem()` retaining every input-supported field.
Returned beta agent metadata is optional nonnull. Supplied malformed discriminators,
required IDs, reasoning objects, effort values, and agent objects/names fail with
contextual errors. Shared `AgentTag` parsing is unchanged.

Omitted reasoning and `{}` remain distinct. Nullable input IDs, effort, and input
agent values accept null and normalize it to omission, following existing package
patterns. Explicit null reasoning is rejected. No source establishes null effort
as a reset operation; the client does not invent one.

`Item.fromResourceJson` selects the required-ID configuration parser while retaining
existing parsing for other returned input variants. Public Responses REST and SSE
request paths, input listings, conversation creation, and conversation item
create/list/retrieve use the contextual DTOs. No `OutputItem` or dedicated stream
event is invented. The existing `InputItemList` now has full copy/clear, structural
equality/hash, and all-field count diagnostics. New models and the list retain
const construction; existing caller-owned list behavior remains compatible.

## Official sources and service behavior

Fresh October 7 toolkit fetch/review matches canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json)
semantically (356 operations, 2,010 schemas). No candidate promotion is needed;
fetch metadata-only churn was restored. Describe and scaffold dry-run reviewed
the real input schema; implementation uses a narrow typed object and fixed
discriminator instead of the scaffold's generic map and writable discriminator.

Revalidated [Python input](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_configuration_update_item_param_param.py),
[Python returned item](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_configuration_update_item.py),
and [Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts)
confirm the contextual contracts. Python returned optional annotations accept
null more broadly; canonical and Node optional nonnull object shapes establish
the supplied-object validation required by this ticket.

The [reasoning guide](https://developers.openai.com/api/docs/guides/reasoning#change-reasoning-mid-conversation)
documents GPT-6 standard single-agent support. Updates precede the next user
message and remain active until replacement. Request-level effort and stable
instructions stay unchanged for prefix reuse; returned `response.reasoning.effort`
still reports request-level effort. Preserve update positions through previous
response IDs or manual history. Adjacent updates, automatic compaction/truncation,
and standalone compact histories are unsupported. Explicit compaction triggers
require a fresh subsequent update. Documentation reflects these service rules;
no SDK model allowlist or automatic history rewriting is added.

The sibling `open_responses` published schema has no configuration update
contract; no speculative sibling addition is made.

## Manifest and remaining gaps

Six contextual mappings use the four real GA/beta configuration schemas. The
reasoning helper maps as an extension because its object is inline and has no
named upstream schema. Two real GA/beta `ResponseItemList` mappings cover the
changed list DTO. No new exclusions or skipped schemas hide gaps.

Full toolkit exports/docs/README checks pass. Wider implementation diagnostics
are 52 errors, ten warnings, 115 infos; consistency reports two warnings.
Baseline #346 was 48/10/113 plus one consistency warning. Four newly exposed
errors concern pre-existing optional/nullable pagination `first_id` and `last_id`
in GA/beta list wrappers. That constructor/provider tolerance remains unchanged
and is distinct from strict configuration item IDs. New infos describe the beta
agent alias and the existing shared `List<Item>` wrapper type. The added
consistency warning reflects the intentional optional input ID versus required
returned ID. Remaining unrelated gaps stay in the complete-parity inventory.

## Verification

- Format: 443 Dart files, zero changes; dart fix: nothing to fix.
- Package fatal-info analysis: no issues.
- Unit suite: 3,269 passing, two existing environment-dependent skips.
- 366 new deterministic tests: 17 narrow reasoning, 107 contextual item models,
  224 public REST/SSE/conversation fixtures, and 18 input-list contracts.
- All changed fields have full copy/clear, JSON/value/hash, and diagnostic tests.
  Fixtures distinguish omission, empty objects, accepted nullable values, and
  contextual malformed supplied or required members.
- Public tests verify all supported effort values, GA/beta headers, exact request
  bodies, returned variants, replay, malformed fields, and immutable request reuse.
  Response fixtures include every canonical required field.
- Exact new README snippet compiles with fatal-info analysis. README, migration,
  public docs, and llms match the implementation.
- Runnable local example passes four MockClient requests: low → high → high → low
  while request-level effort stays low and previous response IDs advance. Its
  transport explicitly simulates service persistence; no live behavior is claimed.
- No live API requests, API key usage, or charges.

## Independent reviews

Requirements review identified missing value/copy contracts on the parser-changed
`InputItemList`; complete contracts and 18 focused fixtures resolve the finding.
Engineering review identified incomplete public response fixtures; all canonical
required fields are now included in shared REST/SSE fixtures. Both reviewers
rechecked the final combined source/tests/docs/mappings and approve with no
remaining actionable findings. Issue #335 stays open until implementation merge.
