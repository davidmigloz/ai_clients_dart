# Align Files, Skills, memory, vaults and deployments

[GitHub issue #485](https://github.com/davidmigloz/ai_clients_dart/issues/485).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `08-agent-resources` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Reconcile existing GA Files/Skills and the Managed Agents ancillary resources with the current wire contract and public beta aliases.

## Dependencies

- #478
- #479

## Acceptance

- [ ] Verify all supported upload/download and multipart flows using deterministic local bytes, media types and failure metadata.
- [ ] Cover current memory stores, memories, versions, vault credentials, dreams, deployments and deployment-run changes, including list filters and gated endpoints.
- [ ] Document legacy beta headers, GA aliases and availability, and preserve earlier callers across current and legacy responses.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
