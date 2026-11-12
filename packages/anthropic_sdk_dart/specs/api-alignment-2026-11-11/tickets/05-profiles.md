# Add generally available User Profiles workflows

[GitHub issue #482](https://github.com/davidmigloz/ai_clients_dart/issues/482).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `05-profiles` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Expose the GA profile routes and current enforcement fields, filtering, action URLs and events while preserving the previous beta access path.

## Dependencies

- #478

## Acceptance

- [ ] Verify six GA operations and overlapping beta routes on their documented paths with exact headers.
- [ ] Test cursor progression, repeated filters, nullable and unknown enforcement values, and safe write semantics. Profile webhook decoding is owned by #490.
- [ ] Document account access and the distinction between a profile ID header and creating or managing profiles.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.

## Legacy response and beta flags

The legacy selector keeps the required `user-profiles-2026-08-18` flag and
accepts other feature flags. A nonempty per-call list supplies the request flags.
Otherwise, the client's configured flags apply. Both access paths filter
profile selectors that would switch their wire contract.

Legacy list responses preserve an explicit null `next_page`, and profile
responses preserve an explicit null `external_user_onboarded_at`. Historical
responses that omitted the fields still round-trip. Equality distinguishes
omission and explicit null. Passing null to the corresponding `copyWith`
argument writes an explicit null field.
[Pinned Python beta profiles](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/resources/beta/user_profiles/user_profiles.py) · [Pinned TypeScript beta profiles](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/beta/user-profiles/user-profiles.ts)
