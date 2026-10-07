# Phase 3 Responses planning review

Status: independent planning reviews complete; validated findings resolved.
Planning PR #345 merged October 7, 2026 after all checks passed, commit
`4542d04ce2845d646e9401ecfa6d0c7ac2e091f6`. Tickets #334–#344 are native
sub-issues of #317; their implementation evidence is recorded separately.
Scope: [specification](../responses.md), repository tickets 09–19 and roadmap.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).

## Evidence baseline

Merged image-model correction #333 has commit
`5eae6db755775d904cfe19df3f22e1bd26dedb73`, closing #326 and completing Phase 2.
All CI checks passed on final PR head `6d8664e57e3cfc1409ba8b00d2991d65234c15e4`.

October 7 toolkit fetch/review confirms semantic equality with canonical
OpenAPI ee483b4 (356 operations, 2,010 schemas). Source audit checked pinned
Python 3.26.0/4e152cd and Node 7.30.0/a4942ba plus current changelog-linked guides.
No candidate promotion is necessary; fetch-only metadata churn is restored.

Three read-only audits covered async/config/access/tool search, web search/shell/
compaction, and WS/steering/recovery/injection. They found field/union gaps despite
unchanged OpenAPI. The specification records guide/schema discrepancies and
keeps request/response/conversation/WS contexts distinct.

## Scope corrections made during audit

- Configuration updates belong to request/list-input/conversation, not output or
  a newly invented stream event; reasoning exposes effort only.
- Async custom input replay is missing, and function replay drops existing agent.
- GA web search needs exact statuses/actions/results and canonical includes;
  guide-only budget/images/filter extensions need explicit authority.
- Shell needs directional environment/action requiredness, typed replay and
  conversation bridges, creator metadata, forced choice and five progress events.
- Compaction progress is independently useful and does not require forcing a
  large-context paid generation.
- WS warm-up generate is guide-only; lane metadata uses envelopes. Browser direct
  header authentication is unsupported, with Responses-specific proxy guidance.
- WS event/close buffering, request errors and owned connection lifecycle require
  explicit contracts; do not copy current Realtime event-loss behavior.
- SDK recovery helpers and beta injection are separate usable tickets, so basic
  transport does not falsely claim complete parity.
- The multi-agent guide resolves beta WS opt-in: plain Responses URL with an
  explicit beta header, distinct from HTTP beta query conventions.

## Independent review and validation

Requirements and cross-author tools reviews approve the revised requirements,
contexts, source policies and ticket boundaries. Engineering review approves the
final combined revision after its validated clarifications were resolved.
No actionable planning findings remain.

Resolved findings:

- Omitted access-program selection follows model/access-dependent server defaults;
  authorized mainline callers may receive Blue and Red models default to Red.
  Explicit selection does not grant access.
- Canonical error code/param keys are nullable-required, while guide-valid WS
  limit errors omit param. Preserve absent/null compatibly with exact fixtures.
- Handshakes retain apiVersion/OpenAI-Version. Caller close validation uses code
  1000 or 3000–4999 and 123 UTF-8 bytes; observed other server close codes remain
  available to recovery.
- Recovery requires a preparation callback, with explicit pinned Node timing and
  jitter policy. Strict queue bytes match Python and differ from Node's oversized
  first-frame exception.
- Queue snapshots serialized UTF-8 bytes; attempted failed writes have unknown
  delivery and never replay. Only never-attempted remainder is reported unsent.

Validation checks all 27 distinct specification source URLs (HTTP 200), local
Markdown links, all 27 unique requirement IDs, all 11 ticket families, explicit
dependency edges, absence of placeholders and git whitespace checks. No findings
remain in the reviewed tool or transport contracts.
No source models, examples or integration tests change in this planning PR;
no API key is read and no live API call is made. The prior implementation evidence
(2,537 unit tests, two existing skips and clean analysis) belongs to #333 and is
not claimed as a new Phase 3 implementation test run.

Wider toolkit implementation diagnostics from #333 remain 41 errors, ten warnings,
103 infos and one consistency warning. This docs-only plan neither suppresses
those gaps nor requires repeated unrelated implementation checks. The planning PR reports CI checks on its final head. No runtime tests are
claimed for the new capabilities.
