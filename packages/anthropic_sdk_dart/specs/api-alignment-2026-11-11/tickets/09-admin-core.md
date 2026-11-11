# Add core Organization Admin API resources

[GitHub issue #486](https://github.com/davidmigloz/ai_clients_dart/issues/486).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `09-admin-core` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Implement organization info, members, invitations, workspaces, API keys, rate limits and compliance settings with the correct credential boundary.

## Dependencies

- #478

## Acceptance

- [ ] Cover GA and documented beta aliases without duplicating wire transport. Test full resource paths, mutation bodies, pagination and errors.
- [ ] Decode 2026-10-21 scope and rate-limit shapes while accepting documented older fields. Preserve workspace filter and include_default semantics.
- [ ] Verify administrative auth, URL and scope guidance, and add a safe runnable read-only example.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
