# Live HTTP acceptance

Status: implementation verified; independent requirements and cross-author
engineering reviews approve. Published-head CI and actual merge remain separate gates. [#370](https://github.com/davidmigloz/ai_clients_dart/issues/370),
[ticket 28](../tickets/28-live-http.md), LIVE-HTTP-01–04 and LIVE-CONFIG-01–04.
Custom voices [PR #377](https://github.com/davidmigloz/ai_clients_dart/pull/377)
merged, closing #369; Live has no dependency on custom voice creation.

## Sources and complete closure

Reviewed [OpenAPI f6f80b90](https://github.com/openai/openai-openapi/blob/f6f80b90bb96d74c22b05a68295af6e7359a48a6/openapi.json)
contains 356 operations and 2,027 schemas. Its actual fetch timestamp and immutable
source URL are adopted; prior b275 metadata retains its original receipt. Sixteen
normalized changes add 14 tool-choice components and change two tool_choice
unions; all 13 tool input schemas and seven HTTP operations are unchanged.
Both independent source downloads equal the adopted canonical JSON. The normalized
JSON digest and downloaded-byte digest are recorded separately.

[Python 8e1fd258 / 3.26.1](https://github.com/openai/openai-python/tree/8e1fd2587deae364367e791385997ab45aa2a520)
and [Node bc6c0bfb / 7.30.1](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5)
runtime heads are unchanged. Six pinned runtime files confirm their narrower
WebRTC creation helpers; canonical governs full WebRTC/SIP creation and detailed
tool selection. The [SIP guide](https://developers.openai.com/api/docs/guides/voice-sip?api=live)
says 200 for outbound creation, while the canonical/method reference specify
201 after initialization. Exact canonical status is used. Guide constraints add
the 1 MiB SIP body limit and service-owned three-minute ringing/two-hour call limits.

All 100 real transitive components have describe/scaffold dry-run receipts and
independent source closure checks (309 assertions). A removed temporary discovery
configuration allowed actual unregistered components to be described; no scaffold
was applied. Eighty-nine named-component mappings and 13 inline aggregates bind
actual components/containing components with exact union paths. Primitive aliases
are verified through real public parent output rather than fabricated DTOs.
All 578 prior manifest entries and top-level policies are unchanged.

A final check found [978d0571](https://github.com/openai/openai-openapi/commit/978d0571e61ab2b18b80a84d17276f05403aace7)
(358 operations, 2,035 schemas): 15 unrelated Agents environment changes. Two new
operations, hosted configuration/reference/status changes and two lifecycle
webhooks are [inventoried for Phase 6](../README.md#late-agents-environment-inventory).
Independent late checks pass 109 assertions: the same 100 Live components, same
transitive closure and all seven path objects are unchanged. The later candidate
and actual fetch receipt remain separate; adopted f6 bytes/metadata are preserved.

## Requirement evidence

| Requirement | Observable acceptance |
| --- | --- |
| LIVE-HTTP-01 | Cached client.live.sessions supports all seven operations. Closed create uses WebRTC offers or outbound SIP with E.164 destination/caller, TLS provider and Digest credentials. Distinct received transports retain WebRTC answer or type-only SIP plus finite future metadata. SIP 201 initializes before answer. Exact UTF-8 JSON bodies admit 1 MiB−1/exact and reject +1 before auth; WebRTC is unaffected. Ambiguous timeout/connection/socket/5xx sends once, including tracing headers. Eligible rejected 429 retains existing retry policy; permanent quota and abort do not replay. |
| LIVE-HTTP-02 | Accept uses fixed live startup; reject admits 300–699; refer preserves a nonblank target; hangup sends no body. Custom base prefixes, encoded opaque IDs, auth/project/organization, pre-auth abort, native abort and closed-client guards have public fixtures. Verified current live.transport.incoming uses data.sessionId; notice/event/delivery IDs stay distinct and no automatic call action follows verification. |
| LIVE-HTTP-03 | Buffered and streamed 200 audio/wav preserve original bytes/chunks, including MIME parameters. Unexpected 2xx status/media/body fails safely; all non-2xx, including 1xx/3xx and plain-text 503, preserve shared status/headers/request ID/charset/raw response and Retry-After. Downloads apply only their own stored-ID pattern. Owned completion/error/cancel/header/body-timeout cleanup and paused idle timing preserve borrowed clients. Storage false/ZDR/project policy/finalized 30-day stereo recordings are documented; no polling/storage change. |
| LIVE-HTTP-04 | WebRTC REST fork preserves omitted/empty overrides and returns a new ID/answer. Application media/state/tool effects remain caller-owned. No invented list/retrieve/update/delete endpoint or WS connection/event implementation. |
| LIVE-CONFIG-01 | Complete startup/media/fork/snapshot/history fields, active status and opaque ID/expiry. Three initial roles each carry one typed text part, at most 128 messages; 8,192 rendered-token and 16,384 instruction limits remain service checks. Required/optional/null/absence, Unicode constraints, immutable ownership, copy/clear and safe diagnostics are tested. |
| LIVE-CONFIG-02 | Primary WS PCM16LE 16/24 kHz and G.711 PCMA/PCMU 8 kHz are distinct from negotiated WebRTC/SIP media. Voice names are open; Live custom ID objects are open with 1–128 characters, independently of Speech references. Fork format is WS-only and client overrides WebRTC-only. Known inherited startup/voice changes through root or nested raw JSON are rejected; unrelated future extras remain intact. |
| LIVE-CONFIG-03 | Distinct client/Responses delegation startup and backend-only updates preserve mode and nullable settings. Thirteen independent Live tool inputs plus shell/environment/network/skill helpers cover exact canonical constraints. Scalar choice modes, 12 specific object choices and allowed_tools 1–128 are typed; no arbitrary/recursive/namespace choice fallback. Guide runtime support may be narrower than wire coverage. |
| LIVE-CONFIG-04 | Omission/all/empty frontend permissions and nested response.event selectors preserve constraints and trusted-sideband scope. Provider URI/phone/UTF-8 credential/body validation avoids DNS probing or invented URI limits. Default model/error diagnostics and FINEST request/response/error logs redact private IDs, SDP, credentials, instructions, transcripts, audio and future metadata while explicit caller context remains readable. |

## Shared corrections and reviews

- Private bodyless auth cloning preserves deliberately absent Content-Type.
  Private buffered responses from injected transports retain the actual sent
  request when the transport omits it, including non-2xx authenticated tracing.
  Other routes retain their existing policy.
- Live recording streams reuse the existing owned/borrowed byte transport with
  GET routing, strict successful headers, idle timeout, native cancellation and
  value-safe connection diagnostics. Existing Speech timing and connector/abort
  exception types remain unchanged; dedicated bytes/SSE/socket regressions prove it.
- Review resolved inherited fork root/audio overflow, SIP aggregate byte admission,
  known-tag bypass in UnknownLiveResponseTransport and exact inline manifest paths.
  Known WebRTC/SIP values cannot bypass required fields through the unknown helper.
- Nested malformed fields preserve safe field/index context without source/offset
  or private content. Full combined validation includes tools using the final
  shared helper, beyond each author's earlier isolated platform runs.
- No existing public constructor/enum/sealed union changes or package version bump;
  no breaking migration is invented. The offline example owns synthetic transport,
  preserves 48 stereo WAV bytes and never makes a real call or media request.

## Validation and remaining gates

Format reports 602 unchanged Dart files; fix has nothing to apply and fatal-info
package analysis reports no issues. The full package suite passes 16,934 cases,
with two existing environment-dependent skips. There are 1,945 new VM cases:
567 core, 642 tools, 728 HTTP/native regressions and eight logging cases. All
1,941 common cases pass real Chrome JavaScript and Wasm; four native socket/Speech
identity cases are VM-only. Retained Audio/error regressions pass 889 cases.

Independent requirements and both cross-author engineering reviews approve the
final combined change after all findings are resolved. The final shared-helper
run preserves both strict nested-index assertions; no tests were weakened.
Published-head CI and actual merge are recorded separately in the PR/issue.
Every run in this slice is offline and costs $0.

The actual public canonical corpus contains 243 outputs covering all 100 closure
components: tools, core/HTTP, real scalar/container aliases and existing shared
error/misalignment values obtained through a public mocked HTTP parser. All 243
Draft 2020-12 schema assertions pass. The literal README code independently runs
with four mocks; the standalone example runs 7/8/8/6 mocks for default, explicit
accept, explicit reject and not-finalized recording. Relevant local links resolve.

Full toolkit verification reports 288 errors / 120 warnings / 234 infos and
38 consistency warnings; baseline was 281 / 120 / 217 / 35. Exact multiset delta
adds 25 implementation identities, removes only the genuine missing Live resource
error, and adds three consistency warnings. All 617 other implementation and all
35 previous consistency identities remain unchanged. Docs/exports/README are clean.

- Eight new errors demand unknown enum fallback values despite closed writable
  canonical enums; strict admission is verified instead of inventing sentinels.
- Seventeen infos compare real scalar/container aliases, optional fixed-type
  presence or separate received WebRTC transport against their wire equivalents.
- Three consistency warnings reflect genuine heterogeneous history parts, shell
  skills and nullable MCP choice name versus required function/custom names.

No new diagnostic exclusions, skipped schemas, fake fields/components, sentinel
values or checker changes were added. Toolkit limitations and remaining unrelated
parity gaps stay visible. #370 remains open until its runtime PR merges; next are
#371 Live WebSockets and #372 forks/delegation/transcript workflows.
