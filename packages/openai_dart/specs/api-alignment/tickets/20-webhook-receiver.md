# Verify and parse signed webhook notifications

Status: specified and independently reviewed; implementation pending.
GitHub: [#357](https://github.com/davidmigloz/ai_clients_dart/issues/357).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 4 Webhooks and safety](../webhooks-safety.md), WH-VERIFY-01–03, WH-EVENT-01–03.
Dependencies: None.

## Demonstrable outcome

A trusted receiver verifies exact original payload bytes, obtains a typed source-backed event and acknowledges without performing an automatic workflow action.

## Acceptance criteria

- [ ] Public standalone verifier/string+bytes methods and client.webhooks wrappers require no API key, HTTP/auth-provider call or client lifetime. Config/environment/override secret precedence and safe exception types match the selected additive contract.
- [ ] External official golden vectors and independently generated receipts prove exact header/body HMAC bytes, raw UTF-8 versus whsec_ secret keys, canonical Base64 policy, candidate versions/rotation positions, nonempty case-insensitive unambiguous headers, safe timestamp integers and inclusive/fractional tolerance boundaries.
- [ ] Invalid signature precedes JSON/UTF-8/model parsing. Verify-only accepts arbitrary signed bytes; unwrap decodes strictly after verification. Errors never expose payloads, header values, digests, secrets or decoder causes.
- [ ] Large-body/many-candidate fixtures prove one HMAC regardless of candidate count; every valid-length signature compares all 32 bytes without shared-prefix early exit. Matches beyond 32 remain valid and malformed candidates do not hide later valid ones.
- [ ] All 26 canonical event variants preserve exact required/optional object envelopes, full payloads, repeated ordered SIP headers, open environment/media strings, Agent summaries and deprecated Live aliases. Unknown/video/legacy Python-only safety events retain deeply immutable raw JSON.
- [ ] Input subscription choices stay independent from received types. No full Agents/Live dependency, automatic lookup/call acceptance/tool execution/deduplication/replay. Offline signed receiver shows prompt200 acknowledgment and caller-owned investigation/persistence.
- [ ] All relevant cases run on VM and real Chrome JavaScript/Wasm. Declare cryptography directly; no browser-secret deployment advice, existing sealed exception expansion or invented schema mappings.

- [ ] Changed models have contextual serialization, requiredness/null/absence, complete copy/clear/replacement, equality/hash, immutable parsed ownership and redacted diagnostics across all old/new fields. Known malformed variants fail and documented receive-only tolerance stays explicit.
- [ ] Public factories/resources/parsers, exports and real manifest mappings are verified; no fake components or exclusions. README/llms, a runnable offline example and any migration guidance are complete.
- [ ] Relevant focused VM/browser fixtures, format → fix → fatal-info analysis, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible and classified.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive local helper/new event hierarchy. Signature exception implements Exception outside sealed OpenAIException. Document deliberate SDK timestamp/base64/empty-secret differences; no existing Dart webhook behavior is replaced.

Use deterministic MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement, API key, endpoint test
delivery or paid API action. Any later live smoke uses the existing bounded-cost
authorization with explicit scope; never run the full integration suite. Package
publishing/version bumps and unrelated API families are outside this ticket.

## Completion evidence

Implementation, runtime verification and independent implementation review remain
pending. Link its acceptance evidence and PR when complete; close the issue only
after implementation merge. The planning review does not claim runtime acceptance. Planning [PR #361](https://github.com/davidmigloz/ai_clients_dart/pull/361) is open for review.
