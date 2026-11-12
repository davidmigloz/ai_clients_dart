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

## Source decisions

- RBAC models serialize `role_ids`, `rbac_group_id` and `display_name`. They also read legacy `roles`, `group_id` and `name` when the current key is absent. An explicit current `role_ids: null` takes precedence over a legacy list.
- The Enterprise guide supports writing per-user spend overrides. The pinned request schema and both SDKs also allow organization and workspace scope. Dart models those scopes and sends only their accepted wire fields. Console writes are in early access and require a numeric monthly cap. A null cap is available for Enterprise user overrides. Configured spend-limit list requires `spend-limit-reads-2026-09-26`; the remaining routes use their own contracts.
- The Enterprise sign-out endpoint requires `admin-user-sign-out-2026-10-08` and a scoped Admin credential. It returns the existing user record. The documentation covers account-wide session revocation and the narrower organization OAuth scope.

[Migration](https://platform.claude.com/docs/en/api/migration-2026-10-21) · [Enterprise user management](https://platform.claude.com/docs/en/manage-claude/user-management) · [Enterprise spend limits](https://platform.claude.com/docs/en/manage-claude/spend-limits-api)
