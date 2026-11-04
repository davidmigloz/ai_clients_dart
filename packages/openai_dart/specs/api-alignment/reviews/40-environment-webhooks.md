# Environment webhook implementation receipt (#392)

Status: implementation and local validation complete; independent review and exact-head CI remain merge gates. Reactivated under #413; #317 remains completed. This slice adds zero HTTP operations.

## Contract and ownership

Wire authority is OpenAPI commit `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`, SHA-256 `73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`. Official reference clients are Python 3.42.0 (`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`) and Node 7.47.0 (`c717857c3151bde92e07e4d396301a9c67163e68`). Both agree with the four canonical event envelopes and required fields. Exact SDK file hashes and real Dart bindings are in [the scoped manifest handoff](40-environment-webhooks-manifest.json).

Each `WebhookAgentEnvironmentReady/Failed/Suspended/Expired` maps to its actual public `AgentEnvironment*WebhookEvent` subtype. Canonical `WebhookAgentSessionEnvelope` requires `id`, `object: event`, `created_at`, `type` and `data`; its existing Dart name remains unchanged. Canonical `AgentEnvironmentEvent` is exactly the existing `WebhookIdData` required-string ID payload, including the allowed empty ID. No duplicate facade, invented identifier prefix, or stricter length bound was added. The immutable received metadata policy is shared with existing signed webhooks; typed fields override stale raw values, and child replacement removes previous child metadata.

Endpoint subscriptions add the four canonical `agent.environment.*` values. Existing endpoint operations, project selection, auth, response verification and signature transport remain unchanged. Ready/failed describe hosted prewarm setup before attachment; suspended can resume a snapshot, while expired cannot. These notifications are separate from session SSE and do not expose or invoke a provisioning/lifecycle route. Application acknowledgment and repeated-ID deduplication remain caller-owned.

Global manifest and canonical-spec promotion belong to #427. This PR contains the adjacent scoped receipt only; it does not prematurely promote the global manifest or replace the committed canonical spec.

## Local validation

All tests use deterministic local mocks or original-byte signed fixtures; no API key, live call or provisioning was used.

- 1,555 webhook model, endpoint, verification and public-resource regression tests passed.
- 40 final focused new model/public-resource and secret-logging tests passed after per-field copy assertions were added.
- The 18 new tests passed in actual Chrome JavaScript and Chrome Wasm runners.
- The public offline example passed: four kinds, repeated-ID suppression, explicit project endpoint creation and selected environment retrieval; zero external requests.
- Full package formatting reported 797 files and no changes; full package analysis reported no issues. The final test-only refinement was formatted and exercised by the 40-test run.
- Constructor/parser/required/null/wrong-type failures, immutable source/output ownership, copy replacement, equality/hash, private diagnostics, malformed known events and finite unknown fallback are covered. Public fixtures cover all four endpoint subscriptions, authentic original bytes, mutated bodies, wrong signatures and expired timestamps. Existing session notifications remain covered by the regression suite.

The scratch manifest overlay passed the envelope implementation and README checks. The toolkit's textual scanner reports inherited `toJson` as missing for the four variants and reused `WebhookIdData`; the actual public `_WebhookValue.toJson` inheritance is proven by the round-trip fixtures on all three runtimes. Its export scan also reports eight existing private helper parts outside this slice. No new export is missing: the existing public barrel exports both modified webhook model files, and new public-resource tests import only `package:openai_dart/openai_dart.dart`. These scanner limitations are handed to #427 rather than hidden by redundant methods or exclusions.

## Review and CI

Independent requirements/engineering review and final-head CI are required before merge. The offline example, README, llms guidance and migration note describe the actual typed API and retain signed-byte verification before handling.
