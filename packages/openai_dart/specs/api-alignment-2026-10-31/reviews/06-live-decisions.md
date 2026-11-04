# Native Live Decisions review

Issue #419; parent #413. Reviewed November 4, 2026, after #414's Decisions GA
alignment. Frozen source cutoff remains October 31; no later release expands
this slice.

## Source authority and coverage

- OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`.
- Python 3.42.0, `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`.
- Node 7.47.0, `c717857c3151bde92e07e4d396301a9c67163e68`.
- Frozen official Decisions/voice guide, with source hashes in the adjacent
  manifest. No Decisions alpha header is introduced.

All 58 assigned schema deltas are accounted for: 56 real type/contextual aliases
and two structural shapes. `LiveDecisionJsonObject` is the validated open JSON
object/object-array data in LiveDecisionInputJsonParam; `triggers` is the typed
0–2 array on the five eligible session parents. Neither requires a fabricated
standalone DTO. No new HTTP operation is introduced.

Five native part classes serve question/message/tool contexts. Equivalent user
text/image aliases share their native codecs. One role-aware message model has
four named role factories and validates each role's content/phase contract.
Four typed tool-history variants cover function/custom calls and results. A
stored-item wrapper delegates the same native validation and requires a nonnull
ID, preserving the flat wire shape without eight duplicate stored classes.
These aliases retain source constraints and do not reuse narrower standalone
request parsers.

## Deliberate distinctions and preserved behavior

Native Live question groups allow 1–64 questions; standalone DecisionRequest
retains 1–400. Native questions support predicate/choice/score, exact string or
nonempty part instructions, boolean/string choices, 2–255 choices and 2–10 score
levels. Plain instructions have no standalone aggregate string/part-count cap.
Part text has its own 10,485,760-character limit; image URLs have the native
20,971,520-character/prefix constraints and optional nullable detail, including
original. JSON parts require finite immutable objects/object arrays without the
standalone JSON depth/value/byte quotas. Native function/custom inputs likewise
retain their own published limits. Optional/null/absent metadata and future
finite JSON survive typed parsing, copies and serialization.

The primitive DecisionChoiceValue string/boolean union is shared safely. A
fromDecisionQuestion/fromDecisionInputItem adapter converts already constructed
standalone values, but native decoding does not pass through those adapters.
The nested completed result directly references canonical DecisionResponse, so
that existing typed response/answer/usage model is reused. LiveDecisionCompleted
retains an immutable authoritative native JSON snapshot and provides a freshly
parsed DecisionResponse view; future native metadata is not lost on round trip.

Canonical/Node require all four nullable decision.event correlation keys:
delegation_id, trigger_id, source_event_type and source_event_id. Python's
Optional defaults tolerate omission. Dart follows canonical/Node, and abbreviated
guide snippets are not treated as complete response fixtures. IDs are never
inferred; transcript-trigger results preserve arrival order even when source IDs
refer to earlier deltas. Unknown outer server events retain the existing fallback.
WebRTC filtering must allow decision.event and its configured transcript source.
The existing session.input_transcript.delta and session.output_transcript.delta
codecs already match the frozen sources; no invented renaming/alias is added.

Startup/update Decisions delegation settings have direction-specific required
fields. Optional nonnull acknowledgment delay (0–800 ms) is available consistently
for client, Responses and Decisions owners. Delegation owner stays immutable,
including null/client transitions. Triggers are independent of delegation: at
most one per input/output transcript event, omitted updates retain state, lists
replace it and an empty list disables it. Trigger objects are closed as declared.
All five primary/media/resolved/update/accept session models support them.
Fork startup overrides remain Responses-only and do not accept known triggers
through rawJson; update a running fork after startup instead.

The three Decision commands are admitted on primary, sideband and fork channels.
Manual decision.create requires an explicit nonempty 1–256-character event ID;
uniqueness is a service/session rule, with no invented local ID or replay helper.
Shared item creation/deletion does not evaluate questions or change voice context.
Native Responses commands require Responses delegation. Nonnull commentary reply
IDs are allowed for Decisions, as explicitly shown in the frozen guide; the
existing nonnull reply-ID restriction applies to Responses. No tool/application
action, ordering policy, state reconciliation or replay is automated.

## Independent review and regressions

Separate reviews covered the native item/question contracts, configuration/events
and public connection behavior. They found and verified fixes for:

- A provisional mode guard that rejected the guide's Decisions commentary reply.
  The public reproduction originally failed before a write and now sends once;
  fixtures cover positive Decisions replies on all three channels while retaining
  the existing Responses restrictions.
- Stale assistant phase metadata reappearing after changing a copied message's
  role with clearPhase. Explicit clearing now removes the raw phase for user,
  developer and system role changes, retaining unrelated future metadata.

No remaining engineering or requirements finding was identified. Migration
instructions cover new sealed-union branches and unsupported fork trigger
startup overrides.

## Validation and toolkit handoff

- Full OpenAI unit suite: **25,892 passed, two skipped, no failures**.
- Chrome: **121 new model/public-path tests passed**.
- Independent config/events/questions/public selection: 86 passed; new item
  selection after the copy correction: 35 passed. Adjacent legacy event codecs
  and config/ownership suites were also exercised.
- Public fixtures configure/create/accept over HTTP and configure/update/send/
  receive over primary, sideband and fork WebSockets. They include shared items,
  native typed results, required nullable correlations, both current transcript
  names, out-of-order source results and unknown events.
- The runnable offline example completes native delegation, acknowledged updates,
  shared item creation/deletion, a transcript trigger and graceful finalization.
  It makes no external API requests, media sessions or application actions.
- Package formatting, dart fix and fatal-info analysis pass. No version/changelog edits or live integration tests are included.

The toolkit fetched/reviewed/described the frozen candidate and scaffolded a
question preview in dry-run mode. Promotion is isolated in
/tmp/openai-issue419-contract; canonical source/global manifest promotion remains
#427. All checks were run with no new exclusions or suppressed mappings.

Frozen-overlay verification reports implementation 1116 errors, 150 warnings and
293 infos; consistency zero errors/116 warnings; eight existing export findings.
Docs/readme have no findings, with 55 collapsible usage topics. This is not a
claim of a globally green implementation audit. Scoped lexical diagnostics are
retained explicitly: common inherited tool fields/serializers, flat stored-item
wrappers and role-context aliases are not fully traced by the scanner; fixed
optional message discriminators retain their actual omission flag; existing
open model IDs, nullable contextual fields and JSON unions are represented by
native Dart values. Public canonical round-trip/copy/field/value fixtures and
independent source review validate these representations. No JSON binary or
nonexistent component is fabricated to silence verification.
