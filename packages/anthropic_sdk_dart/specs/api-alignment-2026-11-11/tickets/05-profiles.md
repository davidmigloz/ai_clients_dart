# Add generally available User Profiles workflows

[GitHub issue #482](https://github.com/davidmigloz/ai_clients_dart/issues/482).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `05-profiles` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Expose the GA profile routes and current enforcement fields, filtering, action URLs and events while preserving the previous beta access path.

## Dependencies

- #478

## Acceptance

- [ ] Verify six GA operations and overlapping beta routes on their documented paths with exact headers.
- [ ] Test cursor progression, repeated filters, nullable and unknown enforcement values, safe write semantics and webhook decoding.
- [ ] Document account access and the distinction between a profile ID header and creating or managing profiles.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
