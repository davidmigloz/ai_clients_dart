# Add Admin RBAC, spend limits and sign-out

[GitHub issue #489](https://github.com/davidmigloz/ai_clients_dart/issues/489).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `12-admin-governance` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Cover RBAC groups, group members and roles, spend-limit requests and limits, and Enterprise member sign-out.

## Dependencies

- #486

## Acceptance

- [ ] Verify new/legacy response names, filter serialization, beta and scope gates and each route including no-content cases.
- [ ] Use organization versus workspace scope as documented and verify list/approve/deny operations with fixtures.
- [ ] Document the consequences and restrictions of write operations.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
