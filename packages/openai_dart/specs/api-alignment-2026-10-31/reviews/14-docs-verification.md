# Frozen October API alignment verification (#427)

All 21 bounded feature/carry-over implementations are merged. This closure records
the promoted source, independent review, integrated validation and remaining
limits. The closure PR supplies the final CI/parent closeout; publishing remains
a later user-approved workflow. No version, changelog, tag or publication changes
are included.

## Authority and provenance

Canonical OpenAPI is the fixed October 31 source commit
`2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`. Raw source SHA-256 is
`73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`;
normalized checked-in JSON hashes to
`5ff86e04f91cfa85158340ed8edcd9a352ad11b108743222851661606f35aeaa`.
Both represent the same parsed document. Python 3.42.0
(`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`) and Node 7.47.0
(`c717857c3151bde92e07e4d396301a9c67163e68`) are the fixed SDK references.
Source metadata retains all 16 prior history entries and the archived October 9
fetch date. Its promotion timestamp describes local promotion, not upstream release.

The canonical source has 376 operations and 2,206 schemas. The original baseline
has 358 operations and 2,039 schemas: 18 added operations and 170 added/124
changed/three removed schemas. Metadata/descriptions contribute to these counts;
they are not 297 implementation defects or a claim of historical SDK parity.
Independent review freshly verified all 128 recorded SDK source references and
424 scoped/reused Dart declarations, plus every inventory component hash.

## Complete bounded accounting

The [inventory](../inventory.json) accounts for all 297 unique schema rows and
all 18 new operations. Operations have exact method/path/operation ID, success
status, body contract, actual Dart resource method and merged implementation PR.
The [closure manifest](14-docs-verification-manifest.json) preserves legitimate
multiple carriers and contextual bindings. The
[merged evidence](14-merged-implementation-evidence.json) records implementation
head/merge commits; the [roadmap](../README.md) maps them to the closed issues.

| Disposition | Schemas |
| --- | ---: |
| Implemented real component bindings | 248 |
| Contextual arrays/scalars/raw envelopes | 27 |
| Documentation/metadata only | 15 |
| Open model-ID string suggestions | 2 |
| Removed contracts | 3 |
| Named bounded Admin exclusions | 2 |

The 18 operations are ten automation/invocation methods, seven Admin methods and
voice deletion. Five existing external-storage prerequisites are separately
recorded under #426. Helpers #394–397 add no canonical operation or wire schema.
A resource filename alone is never evidence of complete method/field parity.

`PublicProjectResidency`'s 15 project settings belong to deferred project CRUD,
separately from four SDK-named runtime endpoint choices. Older
`UsageCompletionsResult` is conditionally outside #426 because this package had
no supported older Admin completion-usage model; Decisions usage implements its
own 30-minute write counter. Historical Admin/legacy exclusions stay explicit.
No new skip, coverage exclusion or diagnostic suppression is introduced.

Final review corrected the beta image usage receipt to its actual Responses
`ImageGenOutputTokensDetails` carrier, rather than equivalent ordinary Images
usage. It also replaced ten incorrect whole-object mappings for inline image
wrappers with exact contextual pointers, and mapped scalar Live fidelity to its
actual enum schema. Live's current 27-case server discriminator map replaces the
removed server DTMF name and includes Decisions/audio-fixture events; the narrower
25-case sideband contract and documented audio reflections remain distinct.

The audit fixed real assigned runtime gaps in #462 (typed/validated Live image
error replay) and #464 (Live breakpoint TTLs and optional-nullable find URLs).
All nine assigned components in the embedded Live InputItem validation closure
now match the frozen contract after reference/default normalization. Canonical
URL requiredness differs from the pinned SDK receive declarations; the source
receipt documents the deliberate canonical choice. Closed writable Decisions
enums retain rejection behavior without an invented writable unknown sentinel.

## Consumer documentation

Common Responses calls remain first, and all 68 Usage topics are collapsible.
New API/helper examples and concise README/llms guidance use actual public names.
Targeted migrations include contributor image-tool option corrections and the
new custom-choice variant as well as Decisions, runtime snapshots, Agent settings,
webhooks, image errors, Live/Realtime, MCP/reasoning and recovery corrections.
The shared OpenResponses nullable-error change has its own migration guidance.

Model IDs remain strings. GPT-6.1 Terra/Rosalind access, account credits and
project controls are documented without inventing client-side entitlements.
Build/Launch/Grow account tiers remain distinct from request service-tier values.
Image/audio/model sunsets follow official guidance. Assistants and Videos are
retired; Evals is read-only before November 30, 2026. Historical example entrypoints
print offline notices. Their notice-only entrypoints were inspected and statically
analyzed; they were not run after automatic review flagged the historical Evals
workflow as potentially live. No billable API call was needed.

The Live initial-history comment now describes the configured token limit and
its 8,192 default rather than claiming a universal hard cap; the 128-item wire
bound remains. Older anchors and separately available Vector Stores are retained.

## Integrated validation

- Full serial OpenAI unit suite: **26,813 passed**, two environment-dependent
  skips. This includes all merged runtime work and the promoted canonical source.
- Format: 862 Dart files, zero changes; automatic fixes: nothing to fix;
  fatal-info package analysis: no issues.
- Shared OpenResponses: **547 passed**, three environment-dependent skips;
  nullable-error fixtures: **three Chrome JavaScript and three Wasm passes**;
  fatal-info analysis: no issues.
- Agent dispatch/result additions were exercised on actual Chrome JavaScript and
  Wasm. Final files/artifacts: 67 portable fixtures and two shared admission
  regressions pass on each browser compiler; 50 isolated filesystem fixtures pass
  on VM. Root independently ran all 117 new file/IO VM fixtures; 204 ordinary
  shared-pipeline regressions also pass. Offline helper examples use mocks/local
  files, including the five-request completed-result artifact workflow.
- All eight managed docs/README configurations have zero errors. The unchanged
  warnings are one Google documentation warning and four Ollama README warnings.
  OpenAI has 68 valid collapsible topics and zero docs/README warnings.
- Toolkit enum/checkout fixes (#461, #468) include independent regression review.
  The full pinned Python suite runs 290 tests with the same five known migrated
  contract failures, zero errors and two skips; no unrelated API/configuration or
  expectation repair is hidden in this round.

## Truthful global verification limits

With corrected discovery, promoted-source implementation verification reports
**1,040 errors, 246 warnings and 351 infos**. A fresh copy of the same final
runtime against the previous canonical source reports **1,011 errors, 128
warnings and 281 infos**. The historical initial 1,010-error comparison is kept
separately; the extra old-source diagnostic is the final nullable Live URL checked
against its former required schema.

All 1,040 implementation errors are retained in the
[machine-readable disposition](14-verification-diagnostics.json), with
[explanation and categories](14-verification-diagnostics.md): 210 assigned-context
findings and 830 outside the bounded delta, zero unclassified assigned errors.
Categories distinguish shared/inherited/flattened codecs and fixed discriminators
from genuine unchanged historical omissions. The 12 real image/TTL diagnostics
were fixed, and URL nullability required an additional structural comparison.

Consistency has zero errors/127 warnings. Export verification reports the same
ten internal helper modules in both source comparisons: nine function-only
JSON/audio/codec utility files and the internal `AdminJsonValue` base module.
They are retained as file-scanner findings rather than exported or suppressed.
An absolute-path filter previously hid these checks beneath `.codex`; #468 makes
all three Dart/export/Python scans relative to their selected source root.
Ten previously hidden untracked OpenAI enums are now actually checked, with no
change to the implementation diagnostic array. There is no global-green claim.

## Release boundary

[Release readiness](14-release-readiness.md) proposes openai_dart 12.0.0 and
open_responses 0.7.0 under normal semver rules, with actual versions unchanged.
The later approved release workflow owns final version/changelog preparation,
publication checks, publishing and tags. HTTP/2 #408 remains separately gated;
no transport dependency, account setting, real schedule or hosted execution is
changed. New upstream releases do not reopen or expand this completed scope.
