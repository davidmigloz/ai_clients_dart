# Add Admin service accounts and federation resources

[GitHub issue #487](https://github.com/davidmigloz/ai_clients_dart/issues/487).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `10-admin-identity` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Expose service accounts and workspace membership, federation issuers and rules, and customer-managed external keys. Audit the separate token exchange workflow.

## Dependencies

- #486

## Acceptance

- [ ] Verify all pinned GA/beta method pairs, path parameters, repeated filters, archive/validation routes and permissions.
- [ ] Use public wire contracts for token exchange and bearer credentials, test with local fixtures, and separate cloud credential acquisition from token transport.
- [ ] Ensure secret-bearing models and errors avoid logging credentials.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
