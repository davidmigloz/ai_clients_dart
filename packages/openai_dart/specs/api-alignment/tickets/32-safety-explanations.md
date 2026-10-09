# Preserve typed Safety alert explanations

Status: implemented and independently approved; exact published-head CI and merge pending.
GitHub: [#382](https://github.com/davidmigloz/ai_clients_dart/issues/382).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Source refinements](../image-safety-followups.md), SAFETY-EXPLANATION-01–06.
Dependency: merged #359; independent of the other refinement.

## Acceptance criteria

- [x] Typed accessor/presence and JSON preserve absent/null/string for the actual SafetyAlertResource field.
- [x] Constructor/parser/copy reject malformed known values; raw metadata cannot override or resurrect cleared fields.
- [x] Copy/clear, immutable ownership, equality/hash and private diagnostics cover every presence state.
- [x] Actual public mock GET and offline example show service retrieval without invented eligibility/retention/caching/control behavior.
- [x] README/llms/manifest and source evidence are complete; nonnull Responses explanation remains unchanged.
- [ ] Supported quality/focused fixtures/package suite and independent final reviews pass; exact final-head CI is green before user-authorized merge.

All tests/examples are deterministic offline fixtures. No API key or live API
call is required. No release/version bump or unrelated API-family implementation.

The [acceptance review](../reviews/32-safety-explanations.md) records actual source,
public/canonical assertions, supported-platform checks and honest retained toolkit
diagnostics. Independent requirements and engineering reviews pass. Exact
published-head CI remains the last gate before a user-authorized merge.
