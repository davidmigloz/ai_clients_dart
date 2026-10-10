# Live environment files and published artifacts acceptance

Status: local implementation for [#390](https://github.com/davidmigloz/ai_clients_dart/issues/390), [ticket 38](../tickets/38-files-artifacts.md). Independent published-head reviews, exact-head CI and the user-authorized merge are complete.

## Frozen sources and delivered scope

Wire authority remains immutable [OpenAPI 0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Pinned [Python 3.26.1/c511a771](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) and [Node 7.31.0/37af8fc9](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156), plus the frozen [files guide](https://developers.openai.com/api/docs/guides/agents-api/environments/files), provide independent workflow cross-checks. No source adoption, live request, key or paid execution is needed ($0).

Six owned operations are exposed under `client.agents.environments.files` and `client.agents.sessions.artifacts`: live list/copy; artifact list/retrieve/delete/content. Copy returns HTTP 201; the other paths require HTTP 200. Existing file-ID/inline request variants are reused directly, with plain standard-base64, 5 MiB decoded per inline file and absolute destinations under `/workspace`. No local filesystem path, upload helper or environment creation is imposed.

Live pages have `object: page`, opaque `next`/`page` and required nullable `next`. Retain directory/order/limit across pages. Artifact lists use ID cursors, nullable environment filtering, and required nullable first/last IDs. Null query arguments omit their fields. SDK nullable artifact after/limit does not override canonical optional-nonnull wire authority. Metadata preserves full ownership/path/size/publication time; canonical timestamps admit signed values and sizes have no upper metadata cap. Files API and publication size limits remain service-owned. Six exact shared contracts and six new real components cover the full 12-component closure.

Artifacts are immutable copies published by completed hosted turns under `/workspace/outputs`. Published copies survive environment expiry; unpublished outputs may not survive cancellation/session deletion. Download anything to retain before deleting a session. Artifact deletion leaves the live file intact, and stopping local download/observation is a different action. Self-hosted file access uses the provider's filesystem API.

## Binary transport and privacy

`download` buffers exact bytes in memory; `downloadStream` yields incremental owned byte chunks using the existing private transport. NUL, non-UTF8, empty and JSON-looking bytes stay binary. Both force octet-stream Accept and Agents beta, remove Content-Type and retain authenticated organization/project context. Byte streams do not replay or execute interceptors. Header and active body-read timeouts apply; pausing suspends successful-body idle timeout while failed responses retain their total deadline.

Injected HTTP transports are borrowed; distinct factory transports are operation-owned. Abort/subscription cancellation releases only this request, including pending headers and late ignored response bodies, without deleting artifacts or cancelling work. The closed-client guard is eager for stream creation.

Independent engineering review caught external connector errors that could leak through private downloads. A scoped artifact opt-in now sanitizes provider/factory/send/body/subscription-start exceptions at their external origins, keeping original causes explicitly accessible and preserving locally generated HTTP/parse/timeout/abort classes. Failed responses bind error privacy to the actual artifact request rather than a connector-supplied unrelated request. Other byte transports retain their existing default policy.

All new value types use strict known-field parsing, required nullable keys, finite detached future metadata, full typed copies/equality/hash and private diagnostics. Reused unknown file-input variants remain readable but unwritable. No default diagnostic includes file contents, hosted paths or future metadata.

## Runtime and consumer evidence

Independent requirements witnesses cover all 24 canonical minimal/full values, five enum/union decisions, 78 malformed/missing known inputs and 30 model boundary decisions. Separate query-boundary witnesses cover 30 decisions. Three new integer fields have 27 parser/constructor/copy regressions for NaN and both infinities, including browser JavaScript dynamic-number behavior. Typed copies cover 23 actual nonconstant fields.

The independent exported-client harness captures 19 actual requests with 270 canonical assertions across all six operations, including encoded opaque IDs, separate pagination, null-query omission, beta/media/auth/project precedence, private JSON errors and exact downloads. A separate borrowed-transport witness proves bytes before EOF and local cancellation without replay/close. Engineering probes additionally cover external SDK exceptions, foreign response requests, synchronous subscription errors, owned/borrowed cleanup, paused bytes and failed-body total deadlines.

The runnable [offline example](../../../example/agent_files_artifacts_example.dart) uses nine mock requests to stage input, page live files, inspect completed-turn metadata, download bytes twice after mocked environment expiry and delete the artifact. The literal README example executes nine mock calls with 105 canonical assertions and explains publication/lifetime/size/transport limits. The counterfactual independently verifies 346 library blobs from base `08f9594dc73703e521aae4cb070a0be34509642a`; actual compilation fails at missing `OpenAIClient.agents`, proving these exported capabilities are absent there. llms documentation counts all 66 actual referenced sources (156,540 tokens, ~157k); its token receipt is regenerated from the final source bytes.

## Quality and retained diagnostics

168 focused tests pass on VM, real Chrome JavaScript and real Chrome Wasm. Independent shared speech/session transport regressions also pass 144 cases. Ordered stable formatting, Dart fixes and fatal-info analysis pass; the full package unit suite passes 24,634 tests with two existing environment-dependent skips. Independent combined reviews are recorded in the retained audit before publication.

All 1,398 prior manifest entries remain unchanged; six real mappings bring the total to 1,404. No new exclusion, skip or verifier relaxation is introduced. Toolkit diagnostics remain visible: implementation 984 errors / 126 warnings / 278 infos and 115 consistency warnings. Every prior finding identity remains; the sole addition is the scalar-wrapper scanner's `No spec fields found for EnvironmentFilePageObjectResource`. The actual Dart string wrapper and container validation have independent canonical/runtime coverage. Docs, README and exports checks have no errors.

Audit directory: `/tmp/openai-alignment-audit/38-files-artifacts`. Independent local approvals bind final inventory bytes; remote GitHub blob/head/tree reviews and CI are subsequent immutable receipts. No future publication, CI or merge is fabricated here.

## Published acceptance and merge

Merged in [PR #405](https://github.com/davidmigloz/ai_clients_dart/pull/405) at `7fcfb3f797347e16165f14eabd6381fc5c3ca07b` on `2026-10-10T07:34:16Z` after both independent published content/CI approvals and all 14 exact-head contexts completed (13 successes/standard skip). Reviewed head: `92f7cb3acc32737eb98758f503bf4f405f791146`.

Published requirements/engineering content receipts: `cf2f5bf7d38b8d4ec22d10064fc51a3ef421840c94a90b609b11ff92e51c7a43` / `979513fd695b0bbad6b9e9a2a6a5a3cd99dd384fa0244624a11c866880a6c840`. CI supplements: `b39c5d2bc7fc04de027316d2e7aee47a15618d1f7316f0e84c9e3cadf0a5d5a2` / `4d7cfa51dcf54430dd63a78a81a487c74b412f785a264ab058afc190b9e40310`. Root immutable CI receipt: `9a40fcf243f2a68ea23150394b22dd3bd6ea98dff561d462ae38313b7d4a2fad`.
