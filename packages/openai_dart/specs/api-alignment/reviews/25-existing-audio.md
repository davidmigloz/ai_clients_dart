# Chat voices and file audio acceptance

Status: implementation verified; independent requirements and cross-author
engineering reviews approve.
Runtime [PR #375](https://github.com/davidmigloz/ai_clients_dart/pull/375) merged
October 8, 2026 at 19:31:30 UTC, squash `98e67ac93bc524a6a40a49ffb04a3c38c00f89ec`;
#367 is closed. Issue [#367](https://github.com/davidmigloz/ai_clients_dart/issues/367),
[ticket 25](../tickets/25-existing-audio.md), [Phase 5](../audio-live.md),
AUDIO-EXISTING-01–04. Prerequisite #366 is closed by merged PR #374.

## Sources and real mappings

Reviewed OpenAPI [239c481c](https://github.com/openai/openai-openapi/blob/239c481c5fd75052acb3e93cf72c15a7b4a45e74/openapi.json),
published October 8, 2026 at 17:10:28 UTC, is promoted to canonical with its actual
fetch timestamp and immutable URL. Adopted 239c candidate and canonical bytes match. Python
9301e319 (3.26.1) and Node bc6c0bfb (7.30.1) are unchanged. An independent semantic
closure comparison proves all nine Audio operations/40 component references and
all six Chat Completions operations/82 component references unchanged from the
merged Speech pin. The two affected file-Audio operations/27-reference subset
also matches. Ten normalized changes elsewhere are five Agents spend-control
changes and five OCI storage changes, retained in Phases 6/7 inventory.

Describe/scaffold dry-runs cover 22 actual affected roots. Chat's audio config is
inline in CreateChatCompletionRequest, not an invented standalone component.
Five real manifest mappings add CreateTranslationRequest (multipart skip with
public implementation), both translation response components, TranscriptionSegment
and TranscriptionWord. Existing CreateTranscriptionRequest remains an explicitly
acknowledged multipart mapping. Its 14 fields already existed; fileContentType is
new client-side file-part MIME metadata outside the canonical form-field count.
Inline logprobs/input-token details stay inline. There are no new exclusions,
checker edits, fake components or claims of implemented Admin/OCI APIs.

A final fetch/review of [b2751c66](https://github.com/openai/openai-openapi/commit/b2751c6625493c9c64db21b1b26a4d9300e589e3),
published at 17:55:47 UTC, finds only VoiceResource.type narrowing to audio_sample
(three normalized leaf changes), now agreeing with SDKs. Toolkit review reports
zero changed types; independent normalized comparison catches the change. The
file-Audio 27-reference and Chat 82-reference closures remain identical. This
pending custom-voice #369 contract is updated in its specification/ticket; the
later candidate is reviewed without promoting it. Adopted 239c canonical and
its actual fetch/source metadata remain byte-exact. All-Audio is unchanged from
506 to adopted 239c, not from 239c to the later b275 source.

## Requirement evidence

| Requirement | Observable acceptance |
| --- | --- |
| AUDIO-EXISTING-01 | ChatAudioConfig accepts shared typed open/custom voice references, retains all original eleven named conveniences/indices and const calls, appends marin/cedar and AAC, and preserves Chat pcm16 versus Speech pcm. Exact string/closed object admission, all 13×6 round trips and actual buffered/streamed Chat request fixtures verify wire identity. Availability remains provider/model-specific. |
| AUDIO-EXISTING-02 | Exact public multipart fixtures exercise all 14 existing transcription fields, repeated arrays, snapshot bytes, MIME, nullable omission/false/forced true and collection limits. Guide constraints are scoped to gpt-transcribe; no global model whitelist or invented prompt/tokenizer limit. JSON/verbose/diarized/raw text/SRT/VTT and three SSE variants preserve usage, logprobs, timestamps, speakers and future metadata. REST logprob bytes admit numeric fractions; SSE bytes require integers. |
| AUDIO-EXISTING-03 | All four buffered transcription methods and every translation method accept abort. Pre-auth admission/closed-client checks are eager; stream authentication/transport starts on listen. Buffered native mid-body abort, pending-header stream cancellation, late body discard, owned/borrowed lifetime, throwing cleanup, terminal held-open done, ignored late data and concurrent isolated owned streams have public fixtures; no consumed-data replay. ParseException messages/causes/default logs are safe while caller responseBody and original HTTP response context remain available. Translation create admits JSON only; createVerbose selects verbose JSON and createRaw admits text/SRT/VTT while preserving whitespace. Verbose translation requires language/duration/text, with optional task/segments; language denotes English output. Text/segments affect equality/hash and copies snapshot their data. |
| AUDIO-EXISTING-04 | README/llms/migration and the runnable offline five-request example cover actual corrected contracts, widened voice/task getters, appended enum cases, immutable collection constructors and workflow-specific January/February sunsets. |

Every changed model has field/variant/absence/null/type, immutable ownership,
copy/clear/replacement, effective-JSON equality/hash and safe diagnostic fixtures.
Known malformed discriminators fail; future strings remain received variants with
immutable raw JSON. Writable unknown enum sentinels fail. Explicit fresh parent
metadata wins over stale nested extras while typed values remain authoritative.
Speaker references accept syntactically valid data URLs including percent encoding;
actual clip formats/duration are server-validated. Filename extension and optional
MIME metadata aid identification without inventing model or MIME whitelists.

## Review findings resolved

- Buffered multipart methods lacked abort propagation; native abortable requests
  now preserve bytes/media and support pre-auth and mid-body cancellation.
- File transcription's async generator could wait indefinitely for response headers.
  Explicit controllers cancel promptly, retire the pending timer, discard late
  bodies, dispose owned transports once and retain borrowed clients.
- Typed transcript.text.done now delivers before prompt completion on held-open
  HTTP bodies. EOF/[DONE] before a valid done fails rather than implying complete
  output. This client policy follows the guide/canonical completion semantics;
  it is not a claim about generic SDK SSE parsers.
- Configured mixed-case media headers could corrupt multipart/Accept selection.
  Required resource headers win before authentication copies the body.
- Decoder errors and response headers could expose transcripts/filenames in
  automatic logs. Audio diagnostics use safe contextual messages, response headers
  and provider request-ID echoes are redacted, and successful binary/body content
  is never decoded for logging. Original inline provider error messages remain
  caller-readable; an explicit diagnostic-redaction flag keeps automatic
  StreamException output private without losing message/partialData.
- Verbose translation incorrectly required legacy task and ignored text/segments
  in value identity. Requiredness and complete owned copy/value contracts now match.
- Base64-only speaker validation incorrectly narrowed the canonical data URL
  contract. Percent-encoded data URLs are admitted without inventing clip rules.
- Parent raw overrides lost to stale grandchild metadata; schema-aware nested
  merging gives fresh extras priority while retaining typed counter authority.
- Nullable numeric copy parameters rejected valid integer literals; numeric
  coercion now follows each declared wire contract without rounding.

## Validation

- Dart 3.13.5 package format → fix → fatal-info analysis passes: all 567 files
  format unchanged and fix has nothing to apply. All 2,690 repository Dart files
  also format unchanged. The full package unit suite passes **14,482 tests** with
  two existing skips after the final shared logging/error corrections.
- All **668 new focused cases** pass VM, real Chrome JavaScript and Chrome Wasm:
  282 file-model, 280 public resource and 106 Chat cases. Existing Audio and
  shared monitoring regressions pass; none uses a live API/key.
- An independent public-factory/schema corpus passes **207 rows / 720 assertions**:
  75 canonical outputs, 130 strict factory rejections and two explicitly
  receive-only future variants. Actual inline Chat and REST/SSE logprob bindings
  are validated, without inventing standalone schemas.
- Both literal new README blocks compile and run against three mock requests;
  all four migration After blocks compile and run against two mock requests.
  All **344 local documentation links/anchors** resolve. The runnable offline
  example makes five synthetic requests, verifies retained future metadata,
  optional task, raw whitespace and open/custom AAC wire values, at **$0 API cost**.
- No live API request, real recording upload, package release/version bump or
  dependency change is made. The existing low-cost authorization remains available
  for later selected tests; this bounded acceptance is fully offline.

Independent final full toolkit all/all reports **275 implementation errors,
112 warnings, 215 infos** and **35 consistency warnings**, against merged Speech
275/84/213 and 35. Exact identity delta: 30 additions, zero removals, 572 unchanged
implementation diagnostics; all 35 consistency identities match. Added diagnostics
are 28 equality/hash scanner warnings across fourteen effective-JSON models and
two TranslationRequest infos for binary Uint8List and closed format enum. Public
field-sensitive equality/hash fixtures verify the helper-based implementation.
Exports/docs/README have no issues. Unrelated missing APIs remain visible.

Independent requirements, resource/shared-HTTP/Chat engineering and
model/docs/manifest engineering reviews approve the final combined change with no
open findings. Final reviewed head `47baee607ba4feea48b5965354b39202a20a1190` passed
[workflow 37827335113](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37827335113):
14 contexts, 13 successes and the standard Test(all) skip. The actual merge receipt
above closes #367; #368 voice consent management is next.
