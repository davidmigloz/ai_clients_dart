# Phase 4 Webhooks and safety planning review

Status: independent planning reviews complete; validated findings resolved.
Scope: [specification](../webhooks-safety.md), repository tickets 20–23 and roadmap.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Tickets #357–#360 are native sub-issues of #317; #359 is blocked by #357 and
#360 by #359. Endpoint management #358 has no prerequisite. Planning PR creation
is pending.

## Baseline and source evidence

[PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356) merged October 8, 2026
at `1e63d6b93bdf0028eb6925d45371b1f36deb5d7b`, closing #344. All applicable checks
passed on final head `7e39acc4821d950327e4e8f4b251a88bd7e5cfa6` (14 contexts,
13 successes and standard Test(all) skip). This completes all eleven specified
Phase 3 implementation tickets. Prior injection evidence records 11,448 passing
unit tests/two existing skips, 656 focused VM/Chrome JS/Wasm cases and clean quality;
those are the merged implementation baseline, not a new Phase 4 runtime test run.

Fresh toolkit fetch/candidate agrees with independently fetched pinned OpenAPI
506aff0a; it has 356 operations/2,009 schemas. All component schemas, webhook
entries and Phase 4 paths match canonical 3c4759c1. Independent parameter-identity
comparison finds five Agents/Vault pagination changes despite toolkit review
reporting zero changes. They are recorded in Phase 6 inventory. Canonical and
actual fetch metadata remain unchanged in this documentation-only plan.
Fresh Python b9bc5c14/3.26.0 and Node 3edaf0f3/7.30.0 have unchanged relevant webhook
verification/resource/event and safety/error source files. References are pinned
in the specification; guides/reference pages were opened and compared.

Three read-only audits cover webhook transport/models/verification, safety/error
contracts and integration architecture. The official synthetic golden signature
was independently recomputed with Python stdlib HMAC against its exact original
payload/key; this validates a source fixture, not an implemented Dart verifier.
No API key or paid external API is involved.

## Decisions and resolved source boundaries

- Combined receiver models/verification is a usable first signed receiver. Local
  helpers have no network/auth/client-lifetime dependency; endpoint management
  remains independently demonstrable. Four tickets/17 requirement IDs establish
  the dependency graph and public fixture boundaries.
- Twenty-six received variants differ from 23 project subscription enum values.
  Video incoming shapes and Python-only safety_identifier.blocked remain unknown
  raw values; Live and organization/workspace safety variants do not widen writable
  project admission. No full Agents/Live client prerequisite is invented.
- Object:event is required only for nine Agent/safety envelopes; the other 17 must
  retain omitted-object presence. Agent environment/media-security text remains
  open; SIP headers preserve order and duplicates. Legacy Live alias remains typed.
- Exact original bytes are authenticated before UTF-8/JSON/known-model parsing.
  Raw UTF-8 bare secrets differ from whsec_ Base64 suffixes. Strict canonical
  encoding/header/timestamp policy and fractional tolerance are explicit departures
  from conflicting SDK quirks, with shared golden-vector interoperability.
- The verifier exception stays outside sealed OpenAIException to keep it additive.
  One body HMAC covers any rotation-candidate count; safe diagnostics and browser
  fixtures are required. Signing secrets stay on trusted infrastructure.
- Create/update/rotation/list constraints follow canonical; empty updates are
  allowed. Endpoint test success:true does not mean a 2xx receiver response.
  Returned/discovered strings are open while writable project choices are closed.
  Deletion's deleted field is a boolean, not an invented fixed true discriminator.
- Create/rotate signing_secret must be structurally redacted before built-in
  enabled response logging truncates it. Wire/body/toJson remains available to the
  caller; no broad unrelated logging change is requested.
- Project alert and organization case permissions/IDs differ; nullable reasons
  are required despite Python omission defaults. request_paused means successful
  block registration, not confirmed stop/rollback. Unknown receive-only enum policy
  is explicit rather than coercing to other/warning.
- A source-location discrepancy was resolved: the top-level workspace webhook
  operation, rather than its component, explicitly specifies api.chatgpt.com,
  backing-organization administrator key and chatgpt.enterprise.safety_alerts.read.
  Phase 4 types the notification; workspace administration/auth/response integration
  remains Phase 7 inventory, with no silent cross-host credential routing.
- HTTP Error/failed ResponseError are typed monitoring gaps. Existing WS detail
  types are reused with old public compatibility. Malformed optional HTTP details
  cannot mask original status/code/request-ID/retry information.
- Flat SSE canonical errors are a targeted breaking fix with migration/legacy
  input handling; they have no declared typed misalignment. Video Error-2 headers
  and Agents/Live errors remain distinct. No request monitoring parameter or
  generic resume/unblock method is invented.

## Independent reviews and validation

Independent webhook-contract, safety-contract and engineering/requirements
planning reviews approve the final combined specification, four tickets and
roadmap. All validated findings are resolved, including source-location precision
for delivery responses, required deletion bool, secret-logging redaction, passive
workspace credentials and unrelated-lane recovery preservation. No actionable
planning findings remain.

Validation confirms 17 unique requirement IDs, all 26 actual event/schema pairs,
23 writable subscription choices, all eight endpoint operations, two safety GETs and
four ticket families with an acyclic dependency graph. All 22 distinct specification
URLs return HTTP 200 and 54 local Markdown links resolve. Source schema/webhook and
independent parameter-delta comparisons pass. Git whitespace checks pass; final
CI will be reported separately. Only Markdown planning/tracking files change;
no runtime source/model/example/test/dependency/manifest change, publication or
version bump is included. No new runtime acceptance is claimed. The exact
create-pr template will retain its literal five Test Plan lines; implementation-
specific items are not applicable to this planning change and remain unchecked.

The merged toolkit baseline remains 229 implementation errors/74 warnings/213 infos
and 32 consistency warnings, with exports/docs/README checks clear. Planning does
not suppress those gaps or require repeated unrelated implementation checks.
