# Retry guidance review and acceptance evidence

Reviewed October 7, 2026 against RETRY-01–06 in the
[Phase 2 specification](../correctness.md).
Tracking: [#325](https://github.com/davidmigloz/ai_clients_dart/issues/325),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `fix/openai-retry-guidance`.
Implementation [PR #332](https://github.com/davidmigloz/ai_clients_dart/pull/332)
merged at `aa6ebfaaa34192fa18985d5816cd846bd3dfbe95` after all CI checks passed, closing #325.

## Outcome and contracts

Structured HTTP 429 permanent credit/spend/usage/quota codes, or broad
insufficient_quota type, stop automatic retries. Classification inspects exact
code/type strings in the error envelope, independently of message/param. Invalid,
missing, and unknown provider envelopes retain transient-status fallback. Valid
metadata survives malformed sibling fields in the typed exceptions.

A valid server hint is a minimum. Hints within twice RetryPolicy.maxDelay are
honored fully, subject to the initial minimum and positive bounded jitter. Larger
representable hints return the original response immediately without waiting or
replaying early. Retry budgets, cancellation, and current cloneability/verb policy
remain: regular http.Request only; 429 can retry POST; 5xx/timeouts/connections are
idempotent-only. No new 408/409, multipart, or streaming transport retries.

One internal parser serves retries, ordinary errors, and pre-stream errors.
Header names are case-insensitive; valid retry-after-ms takes precedence, invalid
milliseconds fall back to Retry-After seconds/HTTP dates. Exact decimal parsing
supports finite nonnegative fractional values without floating-point under-rounding.
Metadata ceilings to microseconds; past dates yield zero. Negative/nonfinite/
unrepresentable hints are invalid. The common native/web bound is 2^53−1
microseconds (over 285 years); values beyond it are explicitly unsupported, not
silently shortened. Timer waits ceil to whole milliseconds to avoid Dart's
truncation, and jitter uses remaining fractional headroom rather than floor-based
extra headroom.

InternalServerException gains optional retryAfter, and the exception factory
forwards it alongside all existing metadata. RateLimit/InternalServer diagnostics
retain precise fractional hints, while no-hint InternalServer diagnostics remain
unchanged. Exceptions keep their existing identity behavior and do not acquire
invented API-wire serialization/copy/value contracts.

JSON and pre-stream errors include full hints and status-specific exceptions even
for malformed/non-JSON bodies. Shared SSE entrypoints and multipart image editing
forward headers. After-output stream failures are never replayed. The public
parseStreamError method keeps its three existing positional parameters, with an
optional headers argument added.

## Sources and workflow

A fresh fetch/review is semantically identical to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
No spec promotion, history update, new schema, or model scaffold was needed:
this slice changes transport/error behavior. Existing exports cover exceptions;
the shared parser is internal and intentionally not exported as a public API.

The [error guide](https://developers.openai.com/api/docs/guides/error-codes)
and [rate-limit guide](https://developers.openai.com/api/docs/guides/rate-limits)
establish action-needed quota errors and full server-delay minima.
[Python 3.26 retries](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/_base_client.py)
and [Node 7.30 retries](https://github.com/openai/openai-node/blob/v7.30.0/src/client.ts)
provide useful millisecond/fractional header handling, but still broadly retry 429
and differ on long hints. This implementation follows the documented API contract
rather than those fallback discrepancies. The existing Dart timer implementation
converts via inMilliseconds, motivating final upward timer rounding.

## Validation

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed, zero changes on final run |
| `dart fix --apply` | Nothing to fix |
| `dart analyze --fatal-infos` | Passed, no issues |
| `dart test --reporter=failures-only test/unit/` | 2,454 passed, two existing environment-dependent skips |
| Focused helper/error/stream/exception suite | 154 passed |
| Focused retry wrapper/public controlled-timer suite | 82 passed |
| Existing streaming/image regressions | 29 passed |
| Public fixtures | Every permanent code/type; malformed/unknown provider bodies; exact request replay; GET/POST503; 408/409 exclusions; disabled/exhausted retry budgets; hint parsing and eligibility; cancellation; JSON/multipart pre-stream errors and no after-output replay |
| Timing | Both abort paths ceil fractional waits; no replay before minima; initial minimum, bounded fractional jitter, exact/over wait bound, full date/numeric hints |
| Exceptions | Const constructors, every existing metadata/cause field, factory forwarding, precise fractional diagnostics and unchanged no-hint diagnostics |
| Toolkit `verify --checks all --scope all` | Exports/docs/README pass; unchanged wider diagnostics recorded below |
| `generate-llms-txt` | Example descriptions/token estimates refreshed |
| Runnable local example | Passed, no network/API cost |
| `git diff --check` and final format check | Passed |

There are 172 additional deterministic unit tests relative to merged #331.
Controlled test-only Zone timers exercise the actual public client/transport path,
including Dart's millisecond-floor behavior, without real long waits or a new
production clock/configuration framework. No new dependency was added.

The local example `example/retry_guidance_example.dart` executed successfully with
MockClient: a transient GET overload recovered in two attempts, a permanent POST
project quota failed after one, and a one-hour hint returned after one with its
complete duration. It needs no key/network and incurred no API cost. The existing
live error-handling example was updated but not executed. No live integration test
or quota/overload trigger was attempted; controlled fixtures establish the exact
behavior without API charges or real long waits.

Dart commands run from `packages/openai_dart`; toolkit commands run from the
repository root with
`--config-dir packages/openai_dart/.agents/skills/openapi-openai/config`.

## Independent reviews and resolved findings

A requirements reviewer authored none of this slice. Retry and error authors
cross-review each other's source/fixtures and root's README, migration guidance,
config dartdoc, and local example. Reported corrections include:

- Classify structured permanent code/type independently of malformed message or
  param, and retain valid metadata on the thrown exception.
- Use eligible hints in the permanent-code fixtures so a separate long-hint
  refusal cannot mask a broken quota classification.
- Make shared retry-header parsing case-insensitive for injected HTTP clients.
- Ceil final timer waits to whole milliseconds, preserving exact exception hints.
- Calculate jitter headroom from the actual fractional duration, keeping the
  existing maximum-jitter intent.
- Replace the old test that expected a one-second hint to be clamped by a
  100ms policy with immediate original-response return; controlled fixtures cover
  permitted full integer-second waits separately.
- Preserve status-specific exception/hint metadata through non-JSON pre-stream
  errors rather than generic fallback that loses the hint.
- Remove blind manual429 retry advice from exception dartdoc and live examples;
  explain account/limit action and non-idempotent operation checks.

The independent requirements reviewer and both cross-author engineering
reviewers approved the complete implementation, public fixtures, docs, helper
scope, and local example. Root final package checks passed. No validated findings
remain unresolved.

## Wider diagnostics and boundaries

Toolkit reports 39 implementation errors, ten implementation warnings, 88 infos,
and one consistency warning, unchanged from merged #331. Exports/docs/README
checks pass. No manifest skips or verification-scope reductions were added.
Older metadata/annotations/typed legacy function-call gaps,
provider exceptions, and helper limitations remain in the complete-parity inventory.

The required sibling check found corresponding defects in open_responses:
status-only 429 retries, shorter clamped server hints, no millisecond header support,
and an error parser using DateTime.parse for HTTP dates/accepting negative values.
These separate-package/provider follow-ups are recorded without applying
OpenAI-specific permanent codes indiscriminately to other providers. No sibling
implementation was changed.

Image requiredness #326 follows. Remaining API families, Administration, package
versioning, and release remain separate milestones.
