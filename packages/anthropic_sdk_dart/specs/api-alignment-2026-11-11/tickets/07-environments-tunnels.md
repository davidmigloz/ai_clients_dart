# Add Managed Agents environments and tunnels

[GitHub issue #484](https://github.com/davidmigloz/ai_clients_dart/issues/484).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `07-environments-tunnels` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Add environment lifecycle, self-hosted work endpoints and publicly documented tunnel and certificate flows.

## Dependencies

- #483

## Acceptance

- [ ] Cover every current generated environment and tunnel method, with path, verb, headers, body and documented pagination.
- [ ] Verify ticketing/heartbeat and binary or certificate contracts where applicable, and document access requirements.
- [ ] Account separately for historical organization-prefixed tunnel aliases and surface any genuine access/contract blocker.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
