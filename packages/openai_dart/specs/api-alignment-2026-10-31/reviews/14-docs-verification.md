# Frozen October API alignment verification (#427)

Status: source/accounting preparation reviewed; final helper merges, integrated
validation and exact-head CI remain required. Parent #413 is not closed by this
preparation commit. No version, changelog, publication or release is included.

## Authority and provenance

The canonical OpenAPI is the fixed October 31 source commit
`2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`. Raw source SHA-256 is
`73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`;
normalizing JSON produces the checked-in canonical hash
`5ff86e04f91cfa85158340ed8edcd9a352ad11b108743222851661606f35aeaa`.
The two hashes describe the same parsed document, not different API revisions.
Python 3.42.0 (`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`) and Node 7.47.0
(`c717857c3151bde92e07e4d396301a9c67163e68`) remain the helper references.
Existing metadata history is retained; the archived prior source keeps its actual
October 9 fetch date. The current timestamp describes local candidate promotion.

The final source has 376 operations and 2,206 schemas. The original baseline has
358 operations and 2,039 schemas: 18 added operations, 170 added/124 changed/three
removed schemas. Documentation and metadata are included in these counts. They
are not counts of implementation defects, complete SDK support or new tickets.

## Complete bounded accounting

The machine-readable inventory now gives all 297 schema rows a source hash and
explicit disposition, and all 18 added operations an actual method/path/operation
ID, success status, body contract, Dart resource method and implementation PR.
The [closure manifest](14-docs-verification-manifest.json) retains the feature
receipts and contextual bindings without inventing object DTOs for array/scalar
schemas or collapsing separate input/output/stored carriers.

| Disposition | Schema count |
| --- | ---: |
| Implemented real component bindings | 248 |
| Contextual arrays/scalars/raw envelopes | 27 |
| Documentation/metadata only | 15 |
| Open model-ID string suggestions | 2 |
| Removed contracts | 3 |
| Explicit bounded Admin exclusions | 2 |

The 18 operations are ten Agent automation/invocation methods, seven Admin
methods and voice deletion. Five existing external-storage prerequisites are
implemented and separately recorded in #426; they are not counted as newly
added operations. No resource-filename heuristic is used as method/field proof.

Project `PublicProjectResidency`'s 15 storage/processing values belong to deferred
project CRUD, separately from four SDK-named runtime endpoint choices. Older
`UsageCompletionsResult` is conditionally outside #426 because this package had
no supported older Admin completion-usage model; Decisions usage implements its
own 30-minute write counter. These are named decisions, not hidden mappings.
All other historical Admin/legacy exclusions remain unchanged.

The three removed components have no stale global manifest entries. No new skip,
coverage exclusion or suppression is added. Closed Decisions request enums retain
their real rejection behavior rather than introducing a writable unknown value.
Contextual error envelopes use the existing concrete HTTP exceptions and retain
object/string permission bodies; no fabricated success DTO is introduced.

Independent review checked 359 existing scoped bindings and 92 pinned SDK source
hashes, all 297 unique inventory rows and source hashes, exact operation contracts,
legitimate multiple carriers, removal keys and metadata history. The final audit
corrected the image receipt's beta usage binding to its actual Responses runtime
carrier (`ImageGenOutputTokensDetails`), reusing #415. Ordinary Images usage is an
equivalent shape in a separate context and is not substituted as that binding.
A separate bounded correction completes typed/validated image failure replay in
Live's shared InputItem context; its runtime/receipt must merge before closure.

## Consumer documentation

Responses remains the first Usage topic, with every Usage example collapsible.
Model IDs stay strings; current access and account controls are documented without
inventing SDK entitlements. Account usage tiers are distinct from request service
levels. Historical API/model availability is linked to official guidance, and
retained Evals/Videos examples now display offline notices rather than invoking
retired or read-only workflows. Legacy anchors remain. Live initial-history docs
now describe the configured token limit with its 8,192 default, while the 128-item
wire bound is unchanged. Upcoming migration notes remain separate from generated
release changelogs.

## Verification status and limits

Initial promoted-source verification: implementation **1,154 errors, 262 warnings,
350 infos**; consistency **zero errors/127 warnings**; exports **zero findings**;
docs/README **zero findings** before the final consumer guidance additions. This
is an advisory global inventory with historical gaps and lexical limitations,
not a passing parity gate. Assigned diagnostics are being reconciled against
actual source contexts; unknown gaps will not be suppressed to make it green.
The closed writable request enum fallback policy is a verifier limitation.

The toolkit's enum-completeness fix is reviewed/merged in #461. Its 189 command
and 21 lexer tests pass, while the complete suite retains five independently
proven pre-existing real-contract failures. Eight managed docs/README gates have
no errors; newly exposed Google/Mistral/Anthropic enum gaps remain visible and do
not change those unrelated package APIs.

Scoped formatting/fixes and fatal-info package analysis pass after the consumer
documentation changes. Legacy example entrypoints were inspected to contain only
notice output, with no client creation or API calls. They were not executed:
automatic approval review flagged the historical Evals filename/body as potentially
live, and source/static checks provided the safer verification path. No billable
API or integration suite was run. Final integrated unit/browser checks and final
source/coverage receipts will replace this preparation status before merge.

HTTP/2 #408 remains the separately gated follow-up from the bounded plan. This
round does not change transport dependencies, publish or deploy a client version.
