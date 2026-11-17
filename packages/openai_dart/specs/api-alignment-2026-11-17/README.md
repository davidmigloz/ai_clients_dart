# OpenAI API alignment for November 17, 2026

[Epic #568](https://github.com/davidmigloz/ai_clients_dart/issues/568) tracks the
changes shipped between the October 31 and November 17 source cutoffs. The
Dart baseline is `openai_dart` 12.0.0 plus Chat Completions `extraBody` at
[`0770be9f`](https://github.com/davidmigloz/ai_clients_dart/commit/0770be9fc76b56fbf3528d5ba7f3f276e18877be).
The [October alignment](../api-alignment-2026-10-31/README.md) provides the
starting spec and records historical gaps.

## Source pins

- [OpenAI API changelog](https://developers.openai.com/api/docs/changelog)
  through November 17, 2026. See also the
  [deprecations](https://developers.openai.com/api/docs/deprecations).
- [OpenAPI `b2fe5a5`](https://github.com/openai/openai-openapi/blob/b2fe5a5d9eb3a580da5aed1d3ff2a03b3853e4f8/openapi.json).
  The downloaded toolkit candidate equals the pinned JSON structurally. The
  upstream file has SHA-256
  `0e4f742c62eac450b2d169250ac04831a048998cf9bdf7bbc47d9ec2f6819896`.
  The toolkit-formatted candidate has SHA-256
  `04f87e2fc53cc499388d593c8d957e7da9303bb31c4657faefea42f47db1dd51`.
- [Python 3.42.0 through 3.53.0](https://github.com/openai/openai-python/compare/v3.42.0...v3.53.0),
  ending at [`793cb76`](https://github.com/openai/openai-python/tree/793cb761332de34fc4832668c12e6298e7ed2043).
- [Node 7.47.0 through 7.58.0](https://github.com/openai/openai-node/compare/v7.47.0...v7.58.0),
  ending at [`68ae47c`](https://github.com/openai/openai-node/tree/68ae47ce196b2885a2f5efa6e9df89444efcca88).

Use OpenAPI and endpoint references for wire shape, guides for availability and
workflow constraints, and the official SDKs for helper behavior. When sources
disagree, record the discrepancy and the contract the Dart public path follows.

## Work plan

| Issue | Outcome | Prerequisites |
| --- | --- | --- |
| [#569](https://github.com/davidmigloz/ai_clients_dart/issues/569) | Responses completion windows, continuation IDs, input transformations and per-TTL cache accounting | Independent |
| [#570](https://github.com/davidmigloz/ai_clients_dart/issues/570) | Image 2.6 SVG/GIF/complexity, SVG accounting and Responses image context compression | Coordinate shared Responses models with #569 |
| [#571](https://github.com/davidmigloz/ai_clients_dart/issues/571) | Model-specific image classifier results and existing moderation compatibility | Independent |
| [#572](https://github.com/davidmigloz/ai_clients_dart/issues/572) | Agent SSE options, lifecycle/errors, session budget/cache accounting and automation pause reasons | Independent |
| [#573](https://github.com/davidmigloz/ai_clients_dart/issues/573) | Agent async tool flags and MCP approvals across inputs, events and webhooks | #572 |
| [#574](https://github.com/davidmigloz/ai_clients_dart/issues/574) | Live delegation, safety IDs, transport webhooks and Realtime/Translation compatibility | Independent |
| [#575](https://github.com/davidmigloz/ai_clients_dart/issues/575) | Two project service-tier endpoints and OCI external keys | Independent |
| [#576](https://github.com/davidmigloz/ai_clients_dart/issues/576) | Ten Admin workload identity provider and federation rule endpoints | Independent |
| [#577](https://github.com/davidmigloz/ai_clients_dart/issues/577) | Regional URLs, spend-limit retry behavior, model shutdown metadata and shared wire corrections | Independent |
| [#578](https://github.com/davidmigloz/ai_clients_dart/issues/578) | Toolkit extraction, verification and scaffold for nullable enums | Independent |
| [#579](https://github.com/davidmigloz/ai_clients_dart/issues/579) | Canonical spec and manifest promotion, current docs and integrated verification | #569–#578 |

The [verification record](verification.md) links each issue to its merged PR,
public-path evidence and final checks. The [inventory](inventory.json) assigns
a primary owner to every changed HTTP operation, webhook and schema. A shared type can have secondary
consumers. Validate the affected callers under its owner and coordinate where
two tickets touch the same public path.

## Public changelog

| Announcement | Dart disposition |
| --- | --- |
| Nov 17 GPT-6.2 Astra and Sol | Existing string model IDs accept both. Update examples and compatible endpoint guidance in #579. |
| Nov 17 Responses completion windows | Implement the HTTP background options in #569. Existing retrieval and cancellation are the starting point. |
| Nov 16 image classifier | Implement the documented model-specific moderation shape in #571 with synthetic metadata fixtures. |
| Nov 5 GPT-6 Cyber | Account access and model availability announcement. Existing client request shapes accept model strings. |
| Nov 4 GPT-Image 2.6 Sunburst and Flare | Add the new typed format controls and accounting in #570 and keep existing markup coverage. |
| Nov 2 outbound SIP availability | `live.create` already accepts SIP transport. Preserve it in #574's regression checks. |

#579 also rechecks the November 30 sunset of Evals, reusable prompts and Agent
Builder, the December image migrations, and the newly scheduled February model
retirements. Use the dated deprecation entries and current model references.

## Contract notes

- The optional `background_options` object is request-only on HTTP create.
  Its two fields are optional and non-nullable when sent. Discounted
  `2h`/`8h` windows require `background: true`, a nonstreaming request
  and Standard service. Use `default` explicitly, or let the project select
  Standard when the tier is automatic or omitted. Preserve the existing
  response status, retrieval, cancellation and guide-defined storage behavior.
  Keep per-TTL cache-write counts distinct from aggregate usage. Chat and
  Decisions retain distinct TTL contracts. Live Responses lifecycle snapshots
  preserve applied TTLs and per-TTL accounting.
  [Background guide](https://developers.openai.com/api/docs/guides/background#use-discounted-completion-windows)
- The image generation guide and pinned edits reference disagree on SVG editing.
  Check the endpoint wire contract and bracketed multipart fields against both
  SDKs. GIF can have different constraints for hosted image tools and standalone
  Images operations. [Image guide](https://developers.openai.com/api/docs/guides/image-generation#gpt-image-26) ·
  [Edit reference](https://developers.openai.com/api/reference/resources/images/methods/edit)
- The classifier guide supplies result keys that the generic moderation schema
  omits. Preserve the existing general moderation contract and test the
  classifier separately with synthetic JSON.
  [Classifier guide](https://developers.openai.com/api/docs/guides/csam-classifier)
- Agent stream errors already have a typed Dart path. Verify envelope variants,
  terminal behavior and helper propagation. The pinned OpenAPI defines the
  budget-reached event. Agent compaction docs need to describe the pinned SDK's
  blocking default while preserving omitted and null request values.
- Existing Responses WebSocket isolation already handles lane overflow. Rich
  incremental progress snapshots in the official SDKs are optional SDK
  conveniences. #569 will record whether any shared behavior is missing and
  defer extra helper surface unless needed by the pinned protocol.
- Admin owns the federation management resources in #576. Provider-specific
  runtime assertion acquisition remains a separate historical gap. The
  existing credential extension points are part of this round's documentation.
- The new API-key expiry audit field belongs to the existing audit-log endpoint,
  which Dart has yet to expose. #575 records the field alongside that deferred
  endpoint. The 12 new Admin operations remain in scope.
- [HTTP/2 #408](https://github.com/davidmigloz/ai_clients_dart/issues/408) retains
  its existing released-version and cancellation, SSE and buffering
  compatibility requirements. It can remain open when this epic closes.

## Review diagnostics and completion

The candidate has 388 HTTP operations and 2,283 schemas. The previous pin
had 376 HTTP operations and 2,206 schemas. All 12 new HTTP operations are Admin
APIs. The new Live transport notification is also declared as an OpenAPI webhook.
See the inventory for raw and normalized comparisons.

Stock toolkit review crashes when it sorts the new top-level `complexity`
enum containing strings and JSON null. A local in-memory sort override
preserved the source and produced diagnostic counts. This provisional review
found 155 changed toolkit-visible schema types, 83 missing manifest entries,
582 errors and 52 warnings. The [final verification](verification.md#integrated-checks) uses the toolkit
fix from #578 and compares with the October baseline.

Use public-path offline fixtures and independent adversarial review for each
implementation. Run Dart formatting, analysis and unit tests. Check
`open_responses` for shared model changes and managed packages for shared toolkit
changes. Keep common Responses usage first, keep usage topics collapsible, and
include runnable examples and migration guidance where applicable.

The [closeout issue](https://github.com/davidmigloz/ai_clients_dart/issues/579)
records the reviewed CI head. This alignment covers upstream changes through
November 17, 2026.
