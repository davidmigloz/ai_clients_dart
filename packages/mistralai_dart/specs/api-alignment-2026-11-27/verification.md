# November Mistral client alignment verification

[Epic #595](https://github.com/davidmigloz/ai_clients_dart/issues/595)
tracks the public contract through November 27, 2026. The
[source inventory](inventory.json) carries every operation and schema delta
against the August snapshot and assigns it to the implementation below.
The package started at 8.3.0. The proposed release is **9.0.0**.
See [MIGRATION.md](../../MIGRATION.md) for before-and-after examples.

## Promoted sources

The checked-in [snapshot](../openapi.json) is the pinned November candidate.
The [metadata](../spec_metadata.json) records both digests, retrieval time,
and SDK revisions. Recompute the normalized bytes with Mike Farah yq
4.53.3 and Python JSON sorting.

```sh
yq -o=json '.' openapi.yaml | python3 -c 'import json, sys; print(json.dumps(json.load(sys.stdin), sort_keys=True, indent=2))' > openapi.json
shasum -a 256 openapi.yaml openapi.json
```

The raw YAML SHA-256 is
`acf0efcbee4617601df77fc40185516ed6aae4369ce090034099317d5866b2db`.
The normalized JSON SHA-256 is
`bfc5e48ee2299075592422b120a2a069e1fb65834a5cfb80ffca72f8b4f89260`.
The independently reproduced file has those exact normalized bytes.
Three Admin maxima written as `1e+06` in YAML survive as JSON numbers.

- [Python v3.9.0](https://github.com/mistralai/client-python/tree/6e9e31ac6f982c1fdfe177787ded223f458c9f69) at `6e9e31ac6f982c1fdfe177787ded223f458c9f69`.
- [TypeScript v3.5.0](https://github.com/mistralai/client-ts/tree/d1cf81b7e4795692689559f13ac920d1af7a26d1) at `d1cf81b7e4795692689559f13ac920d1af7a26d1`.
- [Supplemental TypeScript](https://github.com/mistralai/client-ts/tree/3e87497eea3ae73f482cd683b043469e72f12389) at `3e87497eea3ae73f482cd683b043469e72f12389` for room and SDK helper details.

## Merged implementation and evidence

Each ticket and PR links its literal offline fixtures, source disagreements,
and any compatibility decisions. All implementation PRs were independently
reviewed and passed CI on the reviewed commit before squash merge.

| Ticket | PR | Public behavior verified |
| --- | --- | --- |
| [#596](https://github.com/davidmigloz/ai_clients_dart/issues/596) | [#613](https://github.com/davidmigloz/ai_clients_dart/pull/613) | Chat and Agent controls, token scores, reasoning, resource parts, structured FIM and streamed chunks |
| [#597](https://github.com/davidmigloz/ai_clients_dart/issues/597) | [#618](https://github.com/davidmigloz/ai_clients_dart/pull/618) | Stateless Responses input, output, counting, function tools, and all SSE events |
| [#598](https://github.com/davidmigloz/ai_clients_dart/issues/598) | [#619](https://github.com/davidmigloz/ai_clients_dart/pull/619), [#633](https://github.com/davidmigloz/ai_clients_dart/pull/633) | OCR 4.1 confidence, mixed embeddings, moderation, classifiers and model cards |
| [#599](https://github.com/davidmigloz/ai_clients_dart/issues/599) | [#615](https://github.com/davidmigloz/ai_clients_dart/pull/615) | Voxtral multipart file transcription, speech, voice pagination and samples |
| [#600](https://github.com/davidmigloz/ai_clients_dart/issues/600) | [#620](https://github.com/davidmigloz/ai_clients_dart/pull/620) | Realtime transcription, speech, client token minting, native and browser loopback |
| [#601](https://github.com/davidmigloz/ai_clients_dart/issues/601) | [#624](https://github.com/davidmigloz/ai_clients_dart/pull/624) | Eleven REST operations, LiveKit handoff, room events/RPCs, signed lifecycle deliveries |
| [#602](https://github.com/davidmigloz/ai_clients_dart/issues/602) | [#621](https://github.com/davidmigloz/ai_clients_dart/pull/621) | Legacy Agent lists, Conversation history, messages, tool entries and all three SSE paths |
| [#603](https://github.com/davidmigloz/ai_clients_dart/issues/603) | [#614](https://github.com/davidmigloz/ai_clients_dart/pull/614), [#631](https://github.com/davidmigloz/ai_clients_dart/pull/631) | Files, batches, fine-tuned models, libraries, sharing, prompts and skills |
| [#604](https://github.com/davidmigloz/ai_clients_dart/issues/604) | [#629](https://github.com/davidmigloz/ai_clients_dart/pull/629) | Connector lifecycle, authentication, tool catalogs, scoped credentials and sharing |
| [#605](https://github.com/davidmigloz/ai_clients_dart/issues/605) | [#616](https://github.com/davidmigloz/ai_clients_dart/pull/616), [#630](https://github.com/davidmigloz/ai_clients_dart/pull/630) | Managed indexes, document ingest, search, streaming summaries and typed query errors |
| [#606](https://github.com/davidmigloz/ai_clients_dart/issues/606) | [#617](https://github.com/davidmigloz/ai_clients_dart/pull/617) | Workflow archives, workers, tags, execution logs, batches and cancellation |
| [#607](https://github.com/davidmigloz/ai_clients_dart/issues/607) | [#623](https://github.com/davidmigloz/ai_clients_dart/pull/623) | Published traces, datasets, evaluation runs, scorers and pipelines |
| [#608](https://github.com/davidmigloz/ai_clients_dart/issues/608) | [#625](https://github.com/davidmigloz/ai_clients_dart/pull/625), [#632](https://github.com/davidmigloz/ai_clients_dart/pull/632) | Caller identity, memberships, service accounts, billing, triggers and workflow webhooks |
| [#609](https://github.com/davidmigloz/ai_clients_dart/issues/609) | [#622](https://github.com/davidmigloz/ai_clients_dart/pull/622) | Thirty-five Admin directory routes, dedicated key, pagination and typed SCIM conflict |
| [#610](https://github.com/davidmigloz/ai_clients_dart/issues/610) | [#626](https://github.com/davidmigloz/ai_clients_dart/pull/626) | Fourteen Admin usage, audit, key and Vibe routes, secret-safe diagnostics |

## Reconciled scope

- The 396 operation records are the union of both snapshots. The 345 current
  records include alternate streaming shapes represented by `#stream` in
  the spec. Dart sends the physical paths. Replaced Connector scope
  templates preserve the corresponding caller methods. The older Vespa
  index and Observability APIs retain compatibility while upstream support
  for individual routes remains unconfirmed.
- The 752 changed schema records include additions, edits, and 82
  removals. The manifest maps DTOs and records wire-equivalent inline
  forms, including public streaming wrappers, multipart bodies and
  registry query aliases. Removed Vespa schema mappings record their older
  snapshot and compatibility rationale. The inventory links removed
  records to the relevant implementation ticket.
- The deprecated Admin workspace provision endpoint has a current
  group-assignment replacement. The old Voxtral offset voice list retains
  its published March 31, 2027 sunset. OCR examples use OCR 4.1.
- Browser speech access needs a documented public credential and handshake.
  The Voice Agents provisioning follow-up covers self-serve Enterprise SIP,
  voice-specific endpoint/subscription management, and the worker
  control-plane contract. Dart handles the documented LiveKit and signed
  event delivery surfaces. [Browser speech #628](https://github.com/davidmigloz/ai_clients_dart/issues/628) · [Voice Agents provisioning #627](https://github.com/davidmigloz/ai_clients_dart/issues/627)

## Integrated verification

- The full offline VM suite passed 2,649 tests with three conditional
  environment skips. The same three tests passed with a synthetic environment
  key. They exercise configuration without sending requests.
- Chrome JavaScript and Wasm passed 406 targeted tests total, with two
  native-only network fixtures skipped. The VM suite ran those loopback
  fixtures. Coverage includes streaming cancellation, WebSocket handshakes,
  signed webhooks, multipart compatibility, and secret redaction.
- The formatter checked 883 files without changes. Strict Dart analysis
  passed. The package publication dry run reported zero warnings.
- Toolkit documentation, README, exports, and consistency checks passed
  at both scopes. The review matched all 685 selected schema records to
  manifest entries. The baseline `BatchJobStatus.TIMEOUT_EXCEEDED` diagnostic
  is resolved.

| Toolkit implementation | Errors | Warnings | Infos |
| --- | ---: | ---: | ---: |
| August baseline | 1 | 11 | 120 |
| November full scope | 6 | 45 | 355 |
| November changed scope | 2 | 35 | 249 |

Five full-scope diagnostics request `copyWith` on existing `Agent`,
`ToolCall`, `LibraryList`, `SharingRequest`, and `SharingDeleteRequest`
classes. Their wire fields are verified. The other diagnostic comes from
grouping all `/v1/admin` routes under a single resource name. Independent
fixtures verify all 49 current Admin operations through the dedicated
client. The changed scope repeats the `Agent` and Admin diagnostics.
The remaining warnings concern concise diagnostic output, historical
identity-based equality, and intentionally open or heterogeneous values
that round-trip through JSON. The final merged-main run and publication
dry-run result are linked from the epic.

## Release approval

The semver proposal is **9.0.0**. Migration includes typed streamed parts,
structured FIM data, public union additions, classification messages
and targets, updated Conversation request and history contracts,
library sharing deletion returning nullable data, and Connector
credential aliases. Use the migration examples for existing clients.
The release workflow owns the version, changelog, tag, and publication.
