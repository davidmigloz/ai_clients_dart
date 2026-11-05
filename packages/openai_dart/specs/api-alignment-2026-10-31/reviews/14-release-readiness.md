# Release readiness after the October alignment

The bounded implementation is merged. The source/docs closure and integrated
verification are recorded in [the final audit](14-docs-verification.md), with
[merged PR evidence](14-merged-implementation-evidence.json). Publication remains
a separate user-approved release workflow. Versions, changelogs and tags have not
been changed by this alignment round.

| Package | Current pubspec / last release tag | Proposed next version | Reason |
| --- | --- | --- | --- |
| openai_dart | 11.0.1 / openai_dart-v11.0.1 | 12.0.0 | Reviewed breaking contracts and exhaustive-switch additions alongside new APIs/helpers |
| open_responses | 0.6.0 / open_responses-v0.6.0 | 0.7.0 | Pre-1.0 breaking nullable provider error type from #440, plus #433 streaming cancellation fix |

The proposed versions follow the repository's normal semver policy; release
approval can change scope or versions. The minimum Dart SDK remains 3.12.
[OpenAI migration guidance](../../../MIGRATION.md) covers Decisions content/history,
runtime snapshots, Agent spend-control removal/review settings, webhook/event/tool
variants, image tool options/errors, Live DTMF/Decisions, Realtime nullable deltas,
reasoning/MCP replay, cache/errors and recovery budgets. The shared package has
[separate nullable-error migration guidance](../../../../open_responses/MIGRATION.md).

The release workflow still owns version/changelog generation, package publication
checks, publishing, tags and GitHub release notes after approval. No account tier,
permission, credential, schedule, hosted job or production deployment is changed.
HTTP/2 #408 remains the separately gated transport follow-up; its adoption is not
required for this release. Historical global verifier findings remain documented
rather than being hidden or interpreted as newly implemented full SDK parity.
