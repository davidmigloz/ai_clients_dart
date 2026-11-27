# November 2026 Gemini API alignment

The cutoff is November 28, 2026 in Europe/Madrid. This cycle covers the public
Gemini Developer API and Gemini Enterprise Agent Platform from the
`googleai_dart` package. See [alignment epic #635](https://github.com/davidmigloz/ai_clients_dart/issues/635).
The OpenAI cycle supplies the repository workflow.
[OpenAI epic #568](https://github.com/davidmigloz/ai_clients_dart/issues/568) ·
[Closeout PR #591](https://github.com/davidmigloz/ai_clients_dart/pull/591)

## Baseline and source pins

The released package and fresh baseline are 13.1.0 and
`36a0c21803b969a9942bc42f84ac0658a6cb2f19`. The August 2 alignment added
Environments, Triggers, agent settings and ASR config. Later changes expanded
Part coverage, corrected regional Vertex routing and fixed stalled stream
cancellation. The open issue and PR lists had no outstanding Gemini entries
before this epic. [August alignment #286](https://github.com/davidmigloz/ai_clients_dart/pull/286) ·
[Part #292](https://github.com/davidmigloz/ai_clients_dart/pull/292) ·
[Routing #306](https://github.com/davidmigloz/ai_clients_dart/pull/306) ·
[Cancellation #434](https://github.com/davidmigloz/ai_clients_dart/pull/434)

| Source | Baseline | Candidate or advisory reference |
| --- | --- | --- |
| Developer core discovery (main) | `openapi.json`, v1beta revision 20260731, 91 operations / 245 schemas, SHA-256 `2df072464dc16334f5e30c5e226bc5d7b9891270e1f6f554d76a873d9ddb9da2` | v1beta revision 20261126, 94 / 251, SHA-256 `0fd965903a2e57b27bc8da78dec2c47c748d3901ac6f6e2f7d7383926a03e1df`. [Authenticated discovery source](https://generativelanguage.googleapis.com/$discovery/OPENAPI3_0?version=v1beta) |
| Developer core discovery (v1 comparison) | Stable routes independently checked for this cycle | v1 revision 20261126, 48 / 166, SHA-256 `4743c8548012c47227f6d73c9dfd91cf9e5fe2b18582af2df020ecfaa9d8dcba`. [Authenticated discovery source](https://generativelanguage.googleapis.com/$discovery/OPENAPI3_0?version=v1) |
| Interactions OpenAPI | `openapi-interactions.json`, v1beta, 26 / 179, SHA-256 `89573b4fcdae9203bf18cd019953955c1fb83cd134111e9ee591d2594ef7cf81` | v1beta superset, 38 / 213, SHA-256 `76210b6440354784c0dec1c92d0013b3e7bfe24e6b1a324b62eed91bf58e5fa2`. Use the stable operation reference to check v1 availability separately. [OpenAPI source](https://aistudio.google.com/api-reference/interactions.openapi.json) · [v1 reference](https://aistudio.google.com/api-reference/interactions-api?api-version=v1) |
| Live WebSocket | `live-api-schema.json` and `live-api-schema.source.json`, identical SHA-256 `16b54f24866ce7772dc939b3b0c2adbba9f9a44d424b1329809aa9295e7df49d` | Reconcile the local source with the public protocol, backend routes and pinned Live converters. [Developer protocol](https://aistudio.google.com/api-reference/live) · [Cloud protocol](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/start-manage-session) |
| Python SDK | | v3.6.1, `aa813f8bf805b6f4f3e57abb8f04b91d769e23e6`. [Release](https://github.com/googleapis/python-genai/releases/tag/v3.6.1) · [Pinned source](https://github.com/googleapis/python-genai/tree/aa813f8bf805b6f4f3e57abb8f04b91d769e23e6) |
| JavaScript and TypeScript SDK | | v3.6.1, `719dffc91dbf38f8a5f2d90bf93efa5dc8207999`. [Release](https://github.com/googleapis/js-genai/releases/tag/v3.6.1) · [Pinned source](https://github.com/googleapis/js-genai/tree/719dffc91dbf38f8a5f2d90bf93efa5dc8207999) |

The older `specs/main.json` is a March snapshot at revision 20260310 with
SHA-256 `4c7c36c80432861200125cac36c211e95caa10f79ed3786515302f1adcd5db6f`.
The OpenAPI skill verifies `openapi.json` as the core baseline.

Start with the Developer changelog, then check the dated announcements against
the public guides and the pinned SDK transport code. Keep the Developer and
Cloud contracts distinct. [Developer changelog](https://aistudio.google.com/docs/changelog) ·
[API reference](https://aistudio.google.com/api-reference) ·
[Cloud release notes](https://docs.cloud.google.com/gemini-enterprise-agent-platform/release-notes)

## Backend and feature decisions

| Surface | Verified baseline and target |
| --- | --- |
| Developer Interactions | `v1` is GA for standard model calls. Dart already supports setting the client to v1 and models the `steps` response. The official SDKs now default to v1. Preserve existing Dart client-wide and explicit beta behavior, and make stable Interactions easy to select independently of beta-only resources. Confirm streaming negotiation, GET replay, continuation and required fields from the v1 reference and pinned SDKs. [Version matrix](https://aistudio.google.com/api-reference/api-versions) · [Migration](https://aistudio.google.com/docs/migrate-to-interactions) |
| Managed agents | Developer managed agents, webhooks and preview agent features use `v1beta`. Existing Dart already has agent, environment, trigger and webhook resources and unary agent Interactions. Reconcile API model deltas and public beta streams before refreshing examples. [Agents reference](https://aistudio.google.com/api-reference/agents) |
| Cloud Interactions | OAuth-backed project/location routes omit `publishers/google`. Public model calls and regional host guidance have a distinct Cloud reference. List is Cloud-specific. Preview/long-decode capability and managed-agent geography must follow the Cloud guide, with model and version limitations documented by capability. Preserve the dedicated US and EU hostnames and other existing Cloud traffic. The GA Deferred tier uses `service_tier: deferred` on global with `background: true` and `store: true`. Dart needs create, poll, stream and cancel coverage. [November 16 Cloud release notes](https://docs.cloud.google.com/gemini-enterprise-agent-platform/release-notes#November_16_2026) [Cloud REST](https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/models/interactions-api) · [Developer guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/capabilities/interactions/developer-guide) · [Managed agents](https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/managed-agents/interact-with-agents) |
| Decisions | Verified Developer `POST /v1beta/decisions` and released support in both pinned SDKs. Decisions is a separate Dart resource and its types belong to the Interactions/GAOS source even though it is not a model interaction request. [Decisions reference](https://aistudio.google.com/api-reference/decisions) · [Guide](https://aistudio.google.com/docs/decisions-api) |
| Tool retrieval | Developer `v1beta` preview on the Interactions API. Includes tool selection on the server or client and deferred function and MCP definitions. Preserve the public distinction from GenerateContent. Test request, result and step variants. [Tool retrieval](https://aistudio.google.com/docs/tool-retrieval) |
| Multimodal processing | Compare document, spreadsheet, audio and video selection in user input and function results across both REST surfaces. Preserve inline and uploaded file forms. Verify feature-specific backend rules. [Documents](https://aistudio.google.com/docs/document-processing#customize-document-processing) · [Function results](https://aistudio.google.com/docs/function-calling#file-inspection-options) |
| Live and transcription | Developer Bidi over `v1beta`, including the dedicated transcription model, distinct interim and final fields, and voice editing. Existing Dart already sends audio and decodes ordinary transcription, but its transcription configuration is empty. Check constrained Developer tokens separately from Cloud bearer setup on `LlmBidiService`. Use offline socket frames to validate lifecycle. [Live overview](https://aistudio.google.com/docs/live-api) · [Transcription](https://aistudio.google.com/docs/live-api/live-transcribe) · [Cloud setup](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/start-manage-session) |
| Live Music | Developer `v1beta` provides the experimental `lyria-realtime-exp` model through `BidiGenerateMusic`. Dart lacks that dedicated transport. [Live Music guide](https://aistudio.google.com/docs/realtime-music-generation) |
| Genie 4 | The model is GA on the Developer paid tier. It starts with a `v1beta` Interactions request and uses a dedicated WebSocket or WebRTC connection. Verify scoped credentials, signaling, control messages, media and explicit completion. Its transport is tracked independently of Gemini Live. [Genie guide](https://aistudio.google.com/docs/genie) |
| Deprecations | Use the May steps migration for beta compatibility and the published retirement dates to refresh example IDs. Preserve client symbols still useful with supported server routes and migration guidance for any deliberate removal. [May Interactions migration](https://aistudio.google.com/docs/interactions-breaking-changes-may-2026) · [Deprecations](https://aistudio.google.com/docs/deprecations) |

## Detailed inventory

- [Core REST deltas](core.json)
- [Interactions REST deltas](interactions.json)
- [Gemini Live and Genie 4 protocol inventory](live.md)

## Baseline verification

Dart 3.13.7 formatted all 590 files as checked in. Strict package analysis
reported no issues. Offline unit tests passed 1,749 with 7 environment-related
skips. A repeat with a dummy environment key exposed a pre-existing test
that always expects the default key to be absent. Reconcile that fixture when
updating environment configuration. From the package directory, Chrome JS
and Wasm each passed 13 targeted platform and Interactions tests. The baseline
main tests and CodeQL are green.
[Tests](https://github.com/davidmigloz/ai_clients_dart/actions/runs/46076460092) ·
[CodeQL](https://github.com/davidmigloz/ai_clients_dart/actions/runs/46076460128)

| Toolkit verification | Errors | Warnings | Notes |
| --- | ---: | ---: | --- |
| Core `main` | 1 | 1 | Existing missing `ACTIVITY_HANDLING_UNSPECIFIED` mapping. Documentation checks are partial. |
| `interactions` | 0 | 13 | Eleven consistency warnings, one implementation warning and one partial documentation warning. |
| WebSocket `live` | 0 | 0 | The narrow existing manifest covers four named types. |

Use the skills' full toolkit verification and repeat the same Dart checks
after promoting the canonical snapshots. Exercise relevant browser paths on
Chrome JS and Wasm. A package publication dry run and merged main CI are
closeout requirements. All hosted API integration tests require separate
authorization. The authenticated discovery fetch does not execute a model.

## Delivery order

The GitHub epic tracks native sub-issues, dependencies and acceptance criteria.

| Work | Ticket | Depends on |
| --- | --- | --- |
| Publish the November Gemini contract inventory | [#636](https://github.com/davidmigloz/ai_clients_dart/issues/636) | — |
| Align Interactions GA routing, streams and continuation | [#637](https://github.com/davidmigloz/ai_clients_dart/issues/637) | #636 |
| Align managed agents, environments, triggers and webhooks | [#638](https://github.com/davidmigloz/ai_clients_dart/issues/638) | #637 |
| Add tool retrieval, file slicing and Interactions model updates | [#639](https://github.com/davidmigloz/ai_clients_dart/issues/639) | #637 |
| Add the Gemini Decisions API | [#640](https://github.com/davidmigloz/ai_clients_dart/issues/640) | #636 |
| Update GenerateContent, media, files and remaining core REST | [#641](https://github.com/davidmigloz/ai_clients_dart/issues/641) | #636 |
| Add public Vertex Interactions and verify regional routing | [#642](https://github.com/davidmigloz/ai_clients_dart/issues/642) | #637 |
| Align Gemini Live and speech transcription | [#643](https://github.com/davidmigloz/ai_clients_dart/issues/643) | #636, #641 |
| Add Genie 4 interaction sessions and transport support | [#644](https://github.com/davidmigloz/ai_clients_dart/issues/644) | #637 |
| Add Gemini Live Music generation | [#647](https://github.com/davidmigloz/ai_clients_dart/issues/647) | #636, #643 |
| Verify Gemini alignment and document release readiness | [#645](https://github.com/davidmigloz/ai_clients_dart/issues/645) | #638, #639, #640, #641, #642, #643, #644, #647 |

Publish this inventory first, then start with GA routing and stream behavior.
Separate the implementation of other feature groups when it keeps the public
changes independently reviewable. Attach the independent review finding
resolution and exact-head CI evidence to each PR before squash-merging.

During closeout, reconcile the inventory with merged implementation and update
the canonical snapshot filenames, source metadata, manifest, README, example
index, runnable examples, `llms.txt` and the migration guide as applicable.
Record what is ready to release, any confirmed follow-ups and the proposed
semantic version. Approval for version changes and publication is separate.
