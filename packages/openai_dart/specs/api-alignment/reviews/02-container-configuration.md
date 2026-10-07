# Container implementation review and acceptance evidence

Reviewed October 7, 2026 against [CONT-01–CONT-09](../containers.md).
Tracking: [#320](https://github.com/davidmigloz/ai_clients_dart/issues/320),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `fix/openai-container-configuration`.
PR #327 merged October 7, 2026 after all CI checks passed, closing #320.

## Implemented outcome

Standalone and automatic Code Interpreter configuration share typed memory
strings and correct network policies. Allowlist secrets and standalone reference/
inline skills are supported. Creation requires a name, responses preserve optional
configuration and partial expiration, and listing can filter by name. Public
exports and the previous Code Interpreter import path expose the shared types.

Changed models have defensive snapshots, complete value equality/hash, copy
methods with nullable clearing, and redacted diagnostics. Unknown variants retain
deeply immutable JSON, including dynamically typed nested maps. The example,
README, migration guidance, agent-facing index, and manifest reflect the feature.
Targeted breaking corrections are documented; no version bump or release is made.

## Validation

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed |
| `dart fix --apply` | No remaining fixes |
| `dart analyze --fatal-infos` | Passed, no issues |
| `dart test --reporter=failures-only test/unit/` | 1,841 passed, two existing environment-dependent skips |
| Initial focused container/Responses unit check | 394 passed; the final full suite includes subsequent review regressions |
| `dart test --reporter=failures-only test/integration/container_configuration_test.dart` | Revised bounded live lifecycle passed; first attempt's immediate list assertion failed, with cleanup successful |
| Toolkit `verify --checks all --scope all` | Exports/docs/README pass; visible diagnostics below |
| `generate-llms-txt` | Refreshed descriptions and measured token estimates |
| `git diff --check` | Passed |

Dart commands run from `packages/openai_dart`; toolkit commands run from the
repository root with
`--config-dir packages/openai_dart/.agents/skills/openapi-openai/config`.

The candidate was fetched and reviewed again. It is semantically identical to
the promoted ee483b4 snapshot, so canonical specification bytes and fetch history
remain unchanged. A `CreateContainerBody` scaffold dry-run followed manifest
registration; hand implementation accounts for unions, response-specific shapes,
and the scalar memory wrapper. Eight beta aliases have identical normalized
contracts and map to the same implementations.

Public-import fixtures assert independently specified JSON for all memory tiers,
allowlists/secrets, mixed reference and inline skills, minimal/partial responses,
unknown/malformed variants, ordered collections, null clearing and untyped empty
list copies, redaction, equality/hash, and defensive snapshots. Mock HTTP fixtures
exercise create/retrieve/list, URL/auth/custom headers, name/after filtering,
automatic Responses configuration, and using an existing container ID.

## Independent reviews and resolved findings

The requirements reviewer authored none of this slice and inspected actual new
source, fixtures, schema aliases, migration guidance, and the live-test boundary.
CONT-01–CONT-09 pass after refreshing the agent-facing example index.

Standards review used two reviewers with disjoint author exclusions: one inspected
standalone request/response models; the other inspected shared configuration,
Code Interpreter models, helpers, transport/barrels, documentation, examples, and
tests. Neither reviewed their own authored implementation as independent evidence.
Final follow-ups approved the resolved source and cleanup behavior.

Resolved findings:

- Sentinel list copies initially rejected natural `copyWith(skills: [])` calls
  because empty literals arrived as `List<dynamic>`. Typed copying now accepts
  empty lists; regression fixtures cover all five nullable list slots.
- Fixed list `object` and request/response expiration anchor parsers accepted
  arbitrary strings. They now validate `list` and `last_active_at`, respectively,
  with rejection fixtures. Container `object` correctly remains schema-open.
- Unknown snapshots initially retained dynamically typed nested maps by reference.
  Nested maps are normalized and frozen recursively; all four unknown variants
  test nested mutation, deep equality/hash, and rejection of nonstring JSON keys.
- Disabled-policy equality accepted external subclasses while hashes included
  runtime type. Equality now checks runtime type; a subclass regression verifies
  symmetry and matching hashes for equal values.
- The example had an unused helper and printed absent expiration members as null.
  The helper was removed and each returned member is checked before display.
- Final packaging review found two historical roadmap bullets still described
  container configuration as missing. They now record the implemented #320 slice
  and its pending merge status.
- Cleanup depended entirely on capturing a successful creation ID. If no ID is
  available after an attempted creation, the test now makes up to four bounded
  name lookups and deletes only exact matches, without repeating creation.

No validated findings remain unresolved for this ticket.

## Live evidence and cost boundary

The user's existing authorization permits low-cost live API tests. Only this
tagged file was run; the full integration suite was never run. Each invocation
makes one 1 GB creation at the fixed official host, with network disabled,
20-minute expiration, retries disabled, and 30-second request timeouts. No model
calls, file uploads, skill bundles, or domain secrets are transmitted.

The first invocation passed create/retrieve and deletion but failed because its
immediate filtered list was empty. The revised test allows four read attempts
with one-second delays and passed the lifecycle. This observation motivates
bounded polling; it does not establish a general list consistency guarantee.
Both containers were deleted through the public API. Optional returned settings
are checked when present. Test credentials, headers, and raw responses are not
logged; injected transport closure is protected by nested `finally` blocks.

There were two total creations. At the published
[1 GB price of $0.03 per 20-minute session](https://developers.openai.com/api/docs/pricing),
the conservative session estimate is $0.06 total. Eligible minute billing may
reduce this amount. Billing records were not inspected; this is an estimate,
not a measured invoice charge. No additional paid attempts were made.

## Visible toolkit diagnostics and compatibility exceptions

The report has 21 implementation errors, four implementation warnings,
86 informational findings, and one consistency warning. No new exclusions hide
the remaining backlog, and this is not a full-parity report.

Nineteen errors and all warnings are the previously recorded Decisions baseline:
image-generation model requiredness; missing cache-comparison fields; shared usage
requiredness/copy methods; the existing strict ImageDetail enum; and missing
Agents, Live, safety, vaults, and webhook resource families. The consistency warning
concerns intentionally distinct Decisions choice/score probability element types.
See the [Decisions evidence](01-decisions-implementation.md) for the breakdown.

Two new requiredness diagnostics concern `ContainerList.firstId` and `lastId`.
They deliberately remain nullable and accept omitted/null IDs for empty pages and
existing provider compatibility, rather than inventing pagination cursors.
This exception is recorded in the specification and manifest. New informational
type suggestions cannot express the memory scalar wrapper or future-compatible
sealed skill-source parent; exact fixtures and manual source review verify them.

The Node client's void DELETE return differs from the canonical schema and public
reference. Deletion was left unchanged; the successful live cleanup confirmed the
current typed JSON response works for this test. Hosted shell, retry redesign,
publishing, and later parity milestones remain separate tickets.
