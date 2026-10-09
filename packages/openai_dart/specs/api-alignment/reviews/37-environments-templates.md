# Owned environments and templates acceptance

Status: implementation for [#389](https://github.com/davidmigloz/ai_clients_dart/issues/389),
[ticket 37](../tickets/37-environments-templates.md). Published-head reviews, exact-head CI and the user-authorized merge are complete.

## Frozen source and delivered scope

Wire authority is immutable [OpenAPI 0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
Pinned [Python 3.26.1 / c511a771](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and [Node 7.31.0 / 37af8fc9](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156)
are workflow cross-checks. The source revision, normalized specification and
metadata remain unchanged. Official guides remain the frozen planning snapshots.

All eight owned environment/template operations use the exported
`client.agents.environments` and `.templates`, with shared authentication, project,
HTTP policy and caller-owned transport. Prewarm creation and template creation
require HTTP 201; six other operations require HTTP 200. There is no environment
suspend/resume/reset/delete method, session helper, local environment-state cache
or executor. Resource accessors are cached; returned environment state is not.

The 49-component closure contains 30 exact canonical contracts already mapped
by earlier tickets and 19 new real contracts. Prewarming is hosted-only, excludes
session `environment_id`/`container_size`, and limits nullable vault IDs to ten.
Template file/skill references remain distinct from installed metadata, preserving
required nullable names/version selectors and required nonnull desktop.
Canonical public lifecycle status has all seven states despite narrower SDK enums;
request hosting type is hosted-only while received type can be self-hosted.

All optional nullable settings preserve omission/null/value through parsers and
copies. Desktop null on create inherits/defaults, desktop null on template update
disables, and update network null resets. Omitted network defaults remain service
version-owned. Template policy applies before inline settings and cannot be broadened;
package/setup preparation precedes runtime network policy.

Setup commands, environment values and inline file/ZIP data remain confidential
request inputs. Safe received resources reject known hidden readback keys, including
nested reused components injected through constructors/copies, and retain unrelated
finite future metadata with private diagnostics. No hidden data is restored locally.

Idempotency keys retain 1–256 Unicode codepoints and explicit/caller header precedence
against provider conflicts. The service owns 24-hour organization/project/creator
scope, same-JSON deduplication, current-state returns, HTTP 409 for mismatched or
incomplete creation, retained deleted-key behavior and fresh creation after retention.
No local deduplication cache or new retry policy is introduced.

## Runtime and consumer evidence

Permanent focused fixtures cover 49 canonical minimal/full shapes, all request and
received variants, required nullable keys, optional-nonnull and tri-state presence,
finite owned extras/cycles, equality/hash and 110 actual typed field replacements.
All eight public request paths, auth/media/header context, Unicode opaque IDs/cursors,
list filters, private logs, abort before dispatch, surfaced 409 and configured 429 replay
are checked. Requests use UTF8 bodies even with conflicting caller/provider charset.
The reviewed three new integer fields and two reused file metadata fields have
45 parser/constructor/copy nonfinite regressions across NaN and both infinities.

The frozen [files guide](https://developers.openai.com/api/docs/guides/agents-api/environments/files)
requires 5 MiB decoded per inline file and 10 MiB aggregate per submitted creation
configuration. A targeted shared hosted-file fix enforces these values for sessions,
prewarming and templates. The boundary test proves that 5 MiB+1 can share the legal
encoded string length, and that two 5 MiB files fit while a third byte exceeds the
aggregate. Inherited combined configurations, Files API sizes and archive contents
remain service validation; no filesystem or remote file is read.

The runnable [offline example](../../../example/agent_environments_example.dart)
demonstrates all eight operations with a caller-selected key. README contains the
same real public lifecycle, beta eligibility, safe views, replacement/reset semantics
and independent session/environment/provider/artifact lifetimes. llms documentation
counts all 65 actual referenced sources (154,518 tokens, ~155k). No API key, live request or paid prewarming
is needed: all tests/examples cost $0.

## Quality and retained verification

412 focused tests pass on VM, real Chrome JavaScript and real Chrome Wasm.
Ordered stable formatting, Dart fixes and fatal-info analysis pass. Full package
unit suite passed 24,466 tests with two existing environment-dependent skips.
Independent combined reviews are recorded before publication.

Honest mappings preserve all 1,379 old entries and add 19 actual contracts, for 1,398.
Real example bindings were added without new exclusions or verifier policy changes.
Toolkit diagnostics remain nonzero and visible: implementation 983 errors / 126 warnings /
278 infos plus 115 consistency warnings. The identity comparison retains every existing
finding and adds exactly three scalar-wrapper scanner diagnostics (`No spec fields
found` for EnvironmentStatusResource, EnvironmentTypeParam and EnvironmentTypeResource).
These actual Dart string-wrapper classes preserve received future values rather than
losing strings in enums; canonical/runtime tests validate them. Docs, README and exports
checks have no errors. No rule, skip or exclusion was relaxed to hide findings.

## Independent review record

Requirements and engineering reviews bind the final complete inventory and byte
fingerprints. The engineering draft caught a direct typed nested readback bypass;
constructor/copy resource validation now checks the entire effective JSON and its
private reproducer fails correctly. Final local review receipts and published exact
head/tree/blob reviews are separate immutable audit evidence, followed by exact-head
CI. GitHub tracking receives those receipts after publication; this document does
not fabricate future CI or merge results.

Audit directory: `/tmp/openai-alignment-audit/37-environments-templates`.

## Published acceptance and merge

Merged in [PR #404](https://github.com/davidmigloz/ai_clients_dart/pull/404) at `435b4cf04155b665ebe8a8a6909dc8bce364a49b` on `2026-10-09T21:15:29Z` after both independent published content/CI approvals and all 14 exact-head contexts completed (13 successes/standard skip). Reviewed head: `48ac187f104e29644a28da8825bafe21fe3c4a05`.

Published requirements/engineering content receipts: `7b3000d0a4f18e75b636e37a047d8550d5f8fd396fcc5db9a7440ec19c7c3cdb` / `c9a04ee2a170ac2c2556296363ec08bcdece3fd0bc2bbac13172280862c0eab4`. CI supplements: `95b24a5c250630d615a43ac6e01edfd6b39310e16b5ea2e20e5e60295cc8d6cb` / `fc5c37103f75c21622fd313dfc3ed67fb757690fae39ce8abc15c08173195d82`. Root immutable CI receipt: `fe87dd6327d5589fa6486c22f587955555bb2129c7b60c5c09d5ed3b77ce49cd`.
