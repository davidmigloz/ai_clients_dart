# Add the public Compliance HTTP API

[GitHub issue #491](https://github.com/davidmigloz/ai_clients_dart/issues/491).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `14-compliance` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Cover the 39 public Compliance HTTP operations, using the HTTP reference and guides for contracts absent from the pinned SDKs.

## Dependencies

- #478

## Acceptance

- [ ] Verify activities, organization/groups, content, sessions and artifacts with deterministic pagination, download and deletion fixtures.
- [ ] Verify Compliance Access Key scoping, binary vs JSON behavior, product restrictions and schema evolution of activity records.
- [ ] Document enterprise-only access, separate user-data permissions and beta Security Posture and user-preference behavior.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
