# Image safety identifiers, markup and tool failures

Issue #424; parent #413. Reviewed against the fixed October 31, 2026 cutoff.

## Authority and accounting

The adjacent receipt accounts for all 18 assigned canonical components: 17 DTO/
enum bindings and the real scalar `markup` binary component in its multipart
field context. GA and beta share the same image-call/error/moderation shapes;
the existing output-token detail object and tool configuration are reused.
No HTTP operation is added. Image accounting remains owned by #415.

Sources are OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`, Python 3.42.0
`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`, and Node 7.47.0
`c717857c3151bde92e07e4d396301a9c67163e68`. The receipt hashes eleven SDK
files and the official image guide. Global canonical/manifest promotion remains
#427. No new exclusion or suppression is introduced.

## Wire contracts and compatibility

Generation, JSON edits, multipart edits, ordinary responses and both completed
SSE event variants carry nullable `safety_identifier`. Request bounds count up
to 128 Unicode code points; received identifiers have no invented request bound.
The legacy `user` field remains serializable and is marked deprecated. Nonempty
safety identifiers take precedence; omitted, null or empty identifiers leave
legacy fallback to the service. The client does not synthesize that fallback.

JSON edits accept `markup` as a file ID or image URL; multipart edits send owned
PNG bytes in a `markup` part. Mask and markup are mutually exclusive. References
validate exact one-of selection and known bounds before authentication. The guide
requires overlay dimensions to match the first image after orientation and
transparent unmarked pixels. Binary decoding, dimensions, valid image contents
and model-specific support remain service checks; no superficial local PNG
validation claims otherwise. `input_fidelity` guidance is model-specific, and
runnable examples use current explicit model IDs. GPT Image 1's October 23
shutdown annotation is attached to the correct constant; the prior 1.5 deprecation
notice is retained without assigning it Image 1's shutdown.

Image tool calls preserve canonical required status and required nullable result,
plus revised prompt, action, size/quality/background/format and typed failures.
Error code and param are required nullable keys; optional moderation details reject
explicit null. Moderation stage and call status preserve exact future strings.
Categories and finite future error metadata are deeply owned, typed fields cannot
be shadowed by extras, copies revalidate, and automatic diagnostics omit payloads.
All error details remain explicitly readable.

`ImagesResponse.data` is canonically optional. The existing nonnullable data getter
returns an empty list when absent; `hasData` retains absence versus a present empty
array for round trips and equality. Explicit wire null is invalid. Edit request
bytes/reference lists and response data are defensively owned. These constructors
are no longer const. Image-call direct construction now requires the image-specific
status type and an explicit nullable result. MIGRATION.md gives before/after
examples for both targeted breaking corrections.

## HTTP, streaming and privacy

Public JSON/multipart/SSE paths retain configured base/auth behavior and force
selected media types after provider headers. JSON streams encode UTF-8 independently
of a provider's conflicting charset. Invalid requests fail before authentication.
Private route classification includes image generation, editing and legacy
variations; logs omit request/response bodies, query values, headers and correlation
values. Callback and raw stream failures are wrapped only at their external origin,
retaining explicit causes. HTTP status exceptions, timeout/abort behavior and normal
retry policy retain their concrete semantics. Received request metadata cannot
mislabel an image error as a public route; the actual sent request context wins.
Inline SSE failures preserve explicit message/partial data but redact diagnostics.
Malformed response parsing retains private body access through ParseException.

Independent engineering review checked all 18 components and reproduced two privacy
edge cases: malformed legacy variation JSON and injected incorrect response request
metadata. Both are corrected with public regressions. It also corrected the misplaced
model annotation. No API call, upload or real image generation was performed.

## Documentation and validation

README usage stays concise and collapsible, with Responses remaining first. The
new offline example demonstrates both JSON and multipart markup edits and an SSE
safety identifier using two synthetic calls and no API key or cost. It is linked
from README and llms.txt. No version or changelog file is edited.

- 555 focused existing/new model, JSON/multipart/header/retry/SSE regression tests
  passed before review corrections.
- 31 final new model/public-resource tests pass on the VM after review corrections;
  the original 27 also passed in actual Chrome. The four additional privacy probes
  are included in the final browser rerun and exact-head CI gate.
- Fatal-info package analysis, formatting, whitespace validation and the offline
  example pass. Complete integrated serial verification follows in #427.
- Independent model/HTTP/requirements review is recorded before merge. This is a
  library with no running debug app; verification uses fresh CLI processes.

## Toolkit handoff

Frozen fetch/review, describe and scaffold dry run use the isolated package under
`/tmp/openai-issue424-contract`. The normalized candidate and scoped real bindings
are promoted only inside that scratch package; repository canonical schemas and
global manifest stay unchanged for #427. Verification reports implementation
**1017 errors, 158 warnings, 322 infos**; consistency **zero errors/114 warnings**;
and **nine export scanner findings** (eight existing internal helpers plus the new
internal image JSON helper). Docs/README have **zero findings**, with 62 collapsible
topics. This is not a globally green parity claim.

Scoped diagnostics are explicit: multipart bytes serialize through ImagesResource,
not fabricated JSON methods; fixed type tags/inherited dispatch and effective-JSON
value semantics are not recognized by lexical member checks; reused token/tool
models retain existing copy-method gaps; terse diagnostics intentionally omit some
ordinary fields. Alias names, inline wrappers and real sibling differences account
for informational/consistency messages. The image-call/error/moderation/value and
public transport fixtures directly verify the affected contracts. No suppression
is added to hide residual global or scanner findings; #246 and #427 own their
bounded tooling and promotion work.
