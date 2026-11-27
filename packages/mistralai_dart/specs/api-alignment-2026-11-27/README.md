# Mistral API alignment for November 27, 2026

[Epic #595](https://github.com/davidmigloz/ai_clients_dart/issues/595) tracks
Mistral's public API and official SDKs through November 27. The Dart baseline is
`mistralai_dart` 8.3.0 at
[`78c1c7b1`](https://github.com/davidmigloz/ai_clients_dart/commit/78c1c7b1ad8448f752d02a98850a46ae9e5f933d),
including the streamed content chunk fix in [#594](https://github.com/davidmigloz/ai_clients_dart/pull/594).
The August 2 snapshot was promoted in [#287](https://github.com/davidmigloz/ai_clients_dart/pull/287).

## Source pins

| Source | Pin |
| --- | --- |
| [Published OpenAPI YAML](https://docs.mistral.ai/openapi.yaml) | Retrieved November 27, 17:34 UTC. Raw SHA-256 `acf0efcbee4617601df77fc40185516ed6aae4369ce090034099317d5866b2db` |
| Toolkit-normalized candidate | SHA-256 `0b0b3a3d5b5e5a026a4e76bf1dae28b334bc5004fd473728c3b41fa904502140` |
| August 2 baseline | SHA-256 `5569018c9b0cc44507ecc1da7eb499d654b8634e38a947d3e39d2f62793cc5b4` |
| [Python v3.9.0](https://github.com/mistralai/client-python/releases/tag/v3.9.0) | [`6e9e31ac6f982c1fdfe177787ded223f458c9f69`](https://github.com/mistralai/client-python/tree/6e9e31ac6f982c1fdfe177787ded223f458c9f69) |
| [TypeScript v3.5.0](https://github.com/mistralai/client-ts/releases/tag/v3.5.0) | [`d1cf81b7e4795692689559f13ac920d1af7a26d1`](https://github.com/mistralai/client-ts/tree/d1cf81b7e4795692689559f13ac920d1af7a26d1) |
| Supplemental TypeScript main | [`3e87497eea3ae73f482cd683b043469e72f12389`](https://github.com/mistralai/client-ts/tree/3e87497eea3ae73f482cd683b043469e72f12389) |

Both OpenAPI documents advertise version 1.0.0. The downloaded YAML
parses to the same structure as the toolkit candidate. The November pin
includes 345 operation records and 1,117 named schemas. The August pin
contains 293 operation records and 719 schemas. A fragment such as
`#stream` on a spec path identifies an alternate shape of the HTTP
operation. The client sends the physical path.

The [inventory](inventory.json) lists 103 added, 77 changed, 51 removed,
and 165 unchanged operation records. It also records 480 added, 190
changed, and 82 removed schema records. It links each record to a ticket.
Use operation and model fixtures to verify the route candidates. Shared
schema ownership follows its earliest listed consumer, with the other
affected tickets linked for regression checks. Where a source describes an
API outside OpenAPI, the supplemental records link its disposition to a
ticket.

## Implementation order

| Issue | Outcome | Dependencies |
| --- | --- | --- |
| [#596](https://github.com/davidmigloz/ai_clients_dart/issues/596) | Chat, Agent and FIM sampling, reasoning, logprobs, chunks and structured FIM response | Planning |
| [#597](https://github.com/davidmigloz/ai_clients_dart/issues/597) | Stateless Responses JSON, SSE and counting | #596 |
| [#598](https://github.com/davidmigloz/ai_clients_dart/issues/598) | OCR, embeddings, moderation, classifications and model cards | #596 |
| [#599](https://github.com/davidmigloz/ai_clients_dart/issues/599) | Voxtral file transcription, speech and voices | Planning |
| [#600](https://github.com/davidmigloz/ai_clients_dart/issues/600) | Realtime STT/TTS WebSocket protocols and client session tokens | #599 |
| [#601](https://github.com/davidmigloz/ai_clients_dart/issues/601) | Voice Agents, sessions, LiveKit credentials and documented transport | #599 |
| [#602](https://github.com/davidmigloz/ai_clients_dart/issues/602) | Beta Agents and Conversation history, messages and streams | #596 |
| [#603](https://github.com/davidmigloz/ai_clients_dart/issues/603) | Files, batch, fine-tuned models, libraries, prompts and skills | Planning |
| [#604](https://github.com/davidmigloz/ai_clients_dart/issues/604) | Connector sharing, scoped credentials, tools and metadata | #602 |
| [#605](https://github.com/davidmigloz/ai_clients_dart/issues/605) | Managed Search and legacy RAG | Planning |
| [#606](https://github.com/davidmigloz/ai_clients_dart/issues/606) | Workflow archives, workers, tags and execution changes | Planning |
| [#607](https://github.com/davidmigloz/ai_clients_dart/issues/607) | Observability datasets, evaluations, projects, scorers, logs, spans and traces | Planning |
| [#608](https://github.com/davidmigloz/ai_clients_dart/issues/608) | Identity, workspace billing, service accounts, triggers and webhooks | #606 |
| [#609](https://github.com/davidmigloz/ai_clients_dart/issues/609) | Admin credentials, users, groups, workspaces and SCIM | Planning |
| [#610](https://github.com/davidmigloz/ai_clients_dart/issues/610) | Admin usage, limits, analytics, keys and audit logs | #609 |
| [#611](https://github.com/davidmigloz/ai_clients_dart/issues/611) | Snapshot promotion, integrated verification and release readiness | #596–#610 |

No relevant open issue predated this cycle. [#593](https://github.com/davidmigloz/ai_clients_dart/issues/593)
closed with the fix in #594. [#304](https://github.com/davidmigloz/ai_clients_dart/pull/304),
[#314](https://github.com/davidmigloz/ai_clients_dart/pull/314),
[#410](https://github.com/davidmigloz/ai_clients_dart/pull/410) and
[#438](https://github.com/davidmigloz/ai_clients_dart/pull/438) cover existing
audio uploads, browser request headers, token details and stalled streaming
cancellation. Preserve the behavior exercised there.

## Public announcements and documented scope

| Audit lead | November disposition |
| --- | --- |
| [Mistral Large 4](https://docs.mistral.ai/resources/release-note/2026-10-06-mistral-large-4-public-preview), [priority tier](https://docs.mistral.ai/inference/priority-tier), and [reasoning](https://docs.mistral.ai/inference/conversations/reasoning) | Dart accepts model strings and streamed reasoning parts. Align sampling, tiers, new `max` reasoning member and logprobs. The valid effort set depends on the model. |
| [Responses](https://docs.mistral.ai/inference/conversations/responses) and [migration](https://docs.mistral.ai/resources/migration-guides) | Public create and input token count. Stateless, with caller-supplied history and no background mode. Support the smaller Mistral wire surface including SSE. |
| [OCR 4.1](https://docs.mistral.ai/resources/release-note/2026-08-31-ocr-4-1-general-availability), [block confidence](https://docs.mistral.ai/resources/release-note/2026-07-16-ocr-api-block-confidence-scores), and [OCR 4.0 retirement](https://docs.mistral.ai/resources/release-note/2026-09-29-ocr-4-0-deprecation) | Keep page ranges and existing OCR output. Add per-block score coverage and update model guidance. OCR 4.0 retired September 30. |
| [Voxtral 3](https://docs.mistral.ai/resources/release-note/2026-10-20-voxtral-3-audio-family-release) and [Voxtral migration](https://docs.mistral.ai/studio/audio/migrate-from-voxtral-2) | Public Preview. Dart has HTTP speech, voices, and upload transcription and SSE. Add current options, pagination and sample fetch. Keep optional word timestamps for supported Voxtral 2 requests. Existing Voxtral 2 aliases retire April 30, 2027. |
| [Realtime transcription](https://docs.mistral.ai/studio/audio/speech-to-text/transcribe-in-realtime) and [realtime speech](https://docs.mistral.ai/studio/audio/text-to-speech/speak-in-realtime) | Documented WebSocket APIs with no Dart transport. Browser transcription uses short-lived credential subprotocols. TTS specifies bearer authentication. |
| [Voice Agents](https://docs.mistral.ai/resources/release-note/2026-10-20-voice-agents-release) and [browser integration](https://docs.mistral.ai/studio/audio/voice-agents/browser) | Add public agent and session REST, LiveKit handoff and events. SIP is Enterprise access. Dedicated phone number and webhook provisioning needs stable public contract evidence. |
| [Managed Search](https://docs.mistral.ai/resources/release-note/2026-10-30-managed-search-index-a-managed-vector-index-for-agents-and-workflows) | Mistral-hosted Public Preview, scoped to workspace credentials and permissions. New context routes are independent of legacy external index registration. |
| [Managed Deployments](https://docs.mistral.ai/resources/release-note/2026-10-09-managed-deployments-public-preview) and [Workflows](https://docs.mistral.ai/studio/workflows) | Dart already has most stable SDK operations. Add confirmed archives, workers, tags and unhardening. Deployment availability is distinct from API namespace stability. |
| [Admin authentication](https://docs.mistral.ai/admin/admin-api/authentication), [Admin Panel](https://docs.mistral.ai/resources/release-note/2026-09-10-user-and-permissions-management-in-the-admin-panel), and [key expiration](https://docs.mistral.ai/resources/release-note/2026-08-20-api-key-expiration-policies-and-notifications) | Public Enterprise Preview routes use a separate Admin key. Follow the authentication guide. UI-only features require independent endpoint evidence. |
| [Observability](https://docs.mistral.ai/studio/observability) and [deprecated features](https://docs.mistral.ai/resources/deprecated) | Enterprise Public Preview. Keep compatibility with old paths until a removal is confirmed and mark their status. Fine-tuning jobs were already removed from Dart. |

The wire decision follows the public spec and endpoint contract where the SDK
lags. Use the guides for access conditions and socket event contracts. Use
both pinned SDKs and the referenced fixtures for cases where sources conflict.
The inventory records the specific decisions, including Chat's erroneous
required `data` property, multipart speaker references, Voice Agent PATCH,
NDJSON Search summaries, and Admin authentication.

## Baseline and release gate

The starting VM suite passed 2,387 tests with three environment-dependent
skips. Strict analysis and formatting passed. Toolkit docs, README, exports
and consistency passed. Implementation verification found one pre-existing
error for `BatchJobStatus.TIMEOUT_EXCEEDED`, 11 warnings and 120 infos. The
candidate review reports 1,534 errors and 221 warnings before implementation
or manifest reconciliation. These counts flag work for the tickets and can
differ from structural deltas.

For each slice, exercise the public Dart entry point in offline fixtures and
validate browser behavior where applicable. Require independent review and
green CI on the same commit. Closeout reconciles the frozen inventory, pins
the reviewed snapshot, compares toolkit checks and verifies the merged
commit and publication dry run. A later release workflow owns version bumps,
changelogs, tags and publication.
