# Live WebSocket acceptance

Status: merged in [PR #379](https://github.com/davidmigloz/ai_clients_dart/pull/379), closing #371.
Reviewed head `9e886dc75c04a3bf9b1909e62a7064d2ba6649cc` passed all 14 CI
contexts (13 successes, standard Test(all) skip). User-authorized merge on
October 9 at 05:02:13 UTC produced squash
`d00ee5cfc4a61df04b4e7c59c6ea4e8e34c79648`. External full review was skipped
for unavailable credits; independent local requirements/engineering approvals
supplied the review evidence.
[#371](https://github.com/davidmigloz/ai_clients_dart/issues/371),
[ticket 29](../tickets/29-live-websockets.md), LIVE-WS-01–04,
LIVE-EVENT-01–04 and LIVE-WORK-01–02. Live HTTP
[PR #378](https://github.com/davidmigloz/ai_clients_dart/pull/378) merged at
`98b32e699bd61532c948a910ad9869e91fb23a73`, closing #370.

## Sources and exact contracts

The adopted [OpenAPI f6f80b90](https://github.com/openai/openai-openapi/blob/f6f80b90bb96d74c22b05a68295af6e7359a48a6/openapi.json)
has 356 operations and 2,027 schemas. Fresh toolkit fetch/review and independent
comparison against immutable
[c7224137](https://github.com/openai/openai-openapi/blob/c72241375fbe33a7192f5660b173e541b56e4b2f/openapi.json)
confirm all 287 components reachable from primary/sideband/fork commands,
received unions and InputItem, and all seven Live HTTP path objects, unchanged.
The candidate has 358 operations and 2,035 schemas; its actual fetch receipt
remains separate. Adopted canonical bytes and original metadata are unchanged.
Publication-time toolkit fetch/review and immutable
[fd15e7a8](https://github.com/openai/openai-openapi/blob/fd15e7a8c492008db728bd079d936b7b7bf13e23/openapi.json)
comparison reconfirm the same 287 components and seven paths unchanged. Relative
to c722, eight leaves broaden Decisions images to HTTP(S) URLs and add optional
nullable SafetyAlertResource.detailed_explanation, with associated prose. These
new contracts remain explicit [follow-up inventory](../README.md#decisions),
without implying completion by the earlier Decisions/Safety implementations.
Later Agents environment operations and project lifecycle enum additions remain
[Phase 6 inventory](../README.md#late-agents-environment-inventory).

[Python 8e1fd258 / 3.26.1](https://github.com/openai/openai-python/tree/8e1fd2587deae364367e791385997ab45aa2a520)
and [Node bc6c0bfb / 7.30.1](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5)
heads remain unchanged. Ten successfully fetched immutable runtime/type files
include the actual Node sideband implementation, beyond its index barrel.
Canonical received aliases resolve to 22 full, 18 sideband variants; both SDK
sideband unions have 15. The full received codecs support documented reflected
audio/DTMF and SIP progress, while retaining exact directional constraints.
Optional SDK reconnect and outgoing queue helpers remain inventoried; this slice
provides explicit application-controlled connections without replay.

The source InputItem exclusive `oneOf` overlaps EasyInputMessage with structured
Item messages, and optional/nullable item references with open message metadata.
Normal described messages can therefore satisfy more than one root branch.
Admission validates an exact declared branch, selects the specific valid known
message/reference shape, and preserves finite open metadata. Strict root witnesses
and branch-only overlap compatibility witnesses are counted separately. Of the 38 `oneOf` paths in the newly implemented command/input components,
this is the only overlap: all others have disjoint tags,
JSON kinds, or message role/required-field contracts. Canonical exclusivity is not
rewritten and compatible overlaps are not reported as strict-root validation.

All 168 named input-component validation projections independently equal the
canonical source. Structural validation covers every active keyword family;
string `format` annotations do not introduce an optional local URI checker.
The two canonical required keys without a property definition (`call_id` on local
shell output and `request_id` on MCP approval response) require presence and finite
JSON, without inventing a string type. Existing Item/OutputItem conversions detach
their serialized values only when the declared Live branch fits; standalone
Responses helpers remain unchanged.

## Requirement evidence

| Requirement | Observable acceptance |
| --- | --- |
| LIVE-WS-01 | `client.live.connect()` opens an unstarted primary at `/live/sessions`; `attach(id, gracefulClose: ...)` uses the exact encoded attach route without startup/audio. Custom prefixes, scheme conversion, normalized auth/org/project/version/override headers, trace IDs, abort and client-closed guards have public fixtures. Three-second SIP progress replay preserves original IDs with explicit application deduplication. |
| LIVE-WS-02 | Closed primary/sideband writers admit 11/9 commands, with distinct reusable fork startup. All command fields, nullable/omitted event correlation, Unicode 512 limit, required nullable append delegation and mode-aware updates are tested. No commit or writable DTMF command. |
| LIVE-WS-03 | Native and conditional browser seams compile on VM/JavaScript/Wasm. Browser defaults reject every configured header before provider auth/connect. Explicit injected proxy and HTTP-started borrowed data-channel adapters preserve ownership; already-started media rejects duplicate startup/audio append. No minted Live client secret or automatic replay/action runner. |
| LIVE-WS-04 | Final tracking is installed at construction; `closeSession()` blocks work synchronously before its first await, sends at most one request, drains the confirming event and releases owned resources. Immediate final frames, active final snapshots, premature close, bounded socket-close/reader-cancel, timeout/abort, late sockets, opening overflow and borrowed ownership are covered. Transport peer facts remain distinct from local cleanup. |
| LIVE-EVENT-01 | The public received hierarchy has all 22 concrete branches plus immutable future fallback and five payload models. Known malformed values reject contextually; audio frames do not acquire a fabricated event_id. Full allOf/fork/sideband alias roots use the genuine shared hierarchy. |
| LIVE-EVENT-02 | Primary and reflected sideband audio follow their directional contracts. Sideband reflection is mono PCM16LE 24 kHz, with output start/end timestamps. Original Base64, delivery order and real gaps remain intact; no sorting, resampling or byte sniffing. |
| LIVE-EVENT-03 | Response.event retains any finite nested object, including typeless objects and compact lifecycle snapshots. Outer event_id is required nonnull, client_event_id optional nonnull and delegation_id optional nullable, with exact absence/null/copy behavior. No strict standalone Response conversion discards context. |
| LIVE-EVENT-04 | Live errors remain ordinary events, distinct from HTTP/SSE/transport errors. LiveLiveError required-present code:null is the narrow guide compatibility case; missing/wrong known values reject and transport-call code remains string. Command errors do not close the session. Cumulative duration replaces snapshots, and confirmed final duration remains separate from backend token usage. |
| LIVE-WORK-01 | The offline primary example assigns one action owner, uses transcripts/application state with received delegation metadata, and sends explicit thinking/commentary with the correct ID. Helpers never execute or cancel external work; acknowledgments do not promise playback or transaction completion. |
| LIVE-WORK-02 | The offline sideband example retains delegation, response and call IDs, authorizes only synthetic functions, submits both pending results, then sends one continuation without waiting for a nonexistent item-create acknowledgment. Concurrent taps observe events independently of action ownership and transport lifetime. |

## Models, mappings and review findings

The manifest preserves all 680 prior bindings and all top-level policies. There
are 391 additions: 29 received bindings and 362 command/input bindings. Every
non-helper binding names an actual canonical component; inline payloads and typed
branch wrappers identify their exact containing-component JSON pointer. The only
schema-null entry is the genuine Dart-only sealed LiveInputValue shared base.
Fork command aliasing binds the actual shared LiveClientEvent.fromForkJson rather
than fabricating a class or component. No checker edits, new skips or exclusions.
The current slice has 183 genuine client/input and 31 received describe/scaffold
dry-run receipts; temporary discovery configurations were removed.

Review corrected message dispatch based on incidental id/status metadata,
nullable reference/message overlap, recursive copy cycles, and schema projection
that accidentally removed real description/title property keys. Direct public
fixtures now protect each case. Final concrete writable leaves prevent external
subclass overrides from bypassing role/type admission. Runtime review corrected
synchronous closing admission, authoritative omitted/null/client resolved
delegation, finite JS integer options, bounded cancellation and browser listener
cleanup without invented peer facts.
Final review also corrected automatic browser diagnostics that exposed arbitrary
caller header names. The explicit actionable message remains available, while
default diagnostics redact private names and values. Common handshake, browser
pre-auth and actual DOM connector fixtures cover the correction. Two stable-SDK
constructor forwarding fixes preserve the existing named types and defaults.

No existing public constructor/enum/sealed hierarchy changes or version bump;
this is an additive API and no breaking migration is invented.

## Validation and publication gates

Received models pass 688 cases on each of VM, Chrome JavaScript and Chrome Wasm.
Runtime passes 117 VM and 122 on each Chrome compiler (112 common, five native,
four browser policy and six browser DOM connector cases), using pinned stable
Dart 3.13.5. Model platform fixtures and the 824 retained
Live HTTP/Responses/Realtime regressions pass. The received canonical corpus has
368 actual public assertions over exactly 98 components; its six guide-only
compatibility rows remain separately classified.

Client/input models pass 2,882 cases on each compiler: 133 command, 1,794 named
component, 921 alias/typed-branch and 34 regression cases. Positive changed-copy
fixtures cover all nonfixed command payloads and shared scalar/list/map/nested
input conversion mechanisms. The independent public consumer reads 513 typed
getters on 130 object models and exercises 210 presence/clear contracts.

The full actual public corpus has 1,019 passing canonical component/path
assertions over exactly all 287 closure components: 639 client/input, 368 received
and 12 retained outputs for six shared components. Another 63 InputItem root
witnesses pass exclusive validation. Three multiple-match input witnesses remain
branch-only compatibility; six received guide-only cases remain separate. There
are no suppressed failures, fake components or invented JSON interfaces.

The final stable Dart 3.13.5 package pipeline formats 621 files with no changes,
applies the two constructor forwarding fixes, and reports clean fatal-info
analysis. The full unit suite passes 20,654 cases, with two existing
environment-dependent skips. The slice adds 3,687 VM cases;
all 3,682 common cases pass each Chrome compiler, plus ten browser-specific
cases. Client/input and runtime VM/Chrome fixtures use pinned stable Dart 3.13.5.
Received model VM/Chrome fixtures and the 824 retained focused regressions used
supported Dart 3.12.2; the full stable 3.13.5 suite rechecks all VM fixtures.
The runnable offline example
and literal README workflow pass at $0 API
cost; relevant local documentation links resolve.

Full toolkit verification retains visible diagnostics: 912 errors / 126 warnings
/ 277 infos and 103 consistency warnings, compared with baseline 288 / 120 / 234
and 38. Exact multiset comparison adds 698 implementation identities and removes
25 alias-name suggestion infos; all previous errors/warnings and all previous
consistency identities remain. Of 624 new errors, 622 concern lexical inspection
of scalar/union adapters, inherited constructors/serialization or exact inline
mappings represented by their genuine containing component. Two reflect LiveLiveError required-present code:null receive compatibility and
genuinely unconstrained required MCP execution content. New suggestion infos and sibling warnings reflect real
variant/alias contracts. Public getters/copies, direct helper/branch fixtures,
canonical pointer validation and independent descriptor equality supply the
contract evidence the flat inspector lacks. Docs/exports/README are clean;
coverage-gap lists, endpoint-action mismatches and all 52 existing skips are
unchanged. Toolkit exits with existing and classified diagnostics; no checker, policy or skip
was changed.

Independent engineering reviews approve the frozen received, client/input and
runtime slices. Independent requirements/publication review approves the final
combined diff with no open findings, including the resolved browser diagnostic
privacy correction and publication-time source disposition. These are local
implementation gates, distinct from published-head CI and merge recorded later
in the PR/issue.

Stored WebSocket forks, transcript state helpers and contextual compact Responses
views remain [#372](https://github.com/davidmigloz/ai_clients_dart/issues/372).
Every test/example in this slice is offline; no paid live acceptance is required.
