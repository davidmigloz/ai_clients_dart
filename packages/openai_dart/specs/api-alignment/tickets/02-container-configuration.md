# Correct container configuration contracts

Status: merged in [PR #327](https://github.com/davidmigloz/ai_clients_dart/pull/327); issue closed.
GitHub: [#320](https://github.com/davidmigloz/ai_clients_dart/issues/320).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Containers](../containers.md), CONT-01 through CONT-09.
Blockers: none. Shared cache-write usage is already merged in Decisions #319.

## Demonstrable outcome

Configure and create a standalone container, inspect its returned settings, list it
by name, and pass its ID to Code Interpreter. Automatic Code Interpreter containers
send correct memory/network configuration. This includes all necessary models,
exports, fixtures, examples, migration guidance, and coverage registration.

## Acceptance criteria

- [x] CONT-01: all four memory strings and unknown future strings survive; no integer
  MB is emitted; optional-nullable automatic memory accepts null as absence.
- [x] CONT-02/03: network allowlists emit `allowed_domains`, preserve ordered domain
  secrets, reject malformed known JSON, and redact secrets in diagnostics.
- [x] CONT-04/05: creation requires name and sends memory/policy/files/expiration/
  typed reference and inline skills; version strings and fixed source members are exact.
- [x] CONT-06: create/retrieve/list retain optional returned configuration and valid
  partial response policy/expiration; required fields fail clearly; active helper
  handles current running and legacy active statuses.
- [x] CONT-07: public imports and old Code Interpreter import path work; exact
  Responses and Containers transport fixtures pass; name filtering is transmitted.
- [x] CONT-08: defensive snapshots, full equality/hash, nullable clearing, and deep
  unknown-variant preservation work at public boundaries.
- [x] CONT-09: examples compile, README/agent index and manifest reflect the feature,
  and targeted breaking corrections have accurate migration guidance.
- [x] Format/fix/analyze, package unit suite, applicable toolkit checks, and both
  independent reviews are recorded; validated findings are resolved.

## Compatibility and exclusions

Targeted breaking fixes are authorized: integer memory becomes a shared value
class, allowlist named property becomes `allowedDomains`, name is required, response
expiration uses a separate optional-member shape, and list-copying models become
nonconst. Document exact migrations without silently rounding unsupported sizes.

Exclude hosted-shell environments, Live/Agents-specific container shapes, retry
changes, file-transfer redesign, package release, and DELETE contract changes.
Keep remaining source discrepancies visible in the parent roadmap.

## Completion evidence

Implemented on `fix/openai-container-configuration`. All acceptance criteria are
verified. See the [review and acceptance evidence](../reviews/02-container-configuration.md):
1,841 unit tests pass with two existing skips; analysis is clean; the revised
bounded live lifecycle passed and both test containers were deleted. The
conservative published session estimate for two attempts is $0.06. Wider toolkit
gaps and nullable pagination compatibility remain explicitly recorded. No package
release was performed. PR #327 merged October 7, 2026 after all CI checks passed,
closing issue #320.
