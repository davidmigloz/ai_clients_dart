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

## Workload identity source decisions

Baseline `6c0b26d1960c5c83e03b1a13d02df055c5a44b4b`. The exchange is HTTP-only and absent from the pinned OpenAPI.

- The public WIF reference requires the service-account ID. The Python and TypeScript transports accept omission and omit the field when absent. Dart requires it for the documented workload setup. The exchange workspace is optional, and the server chooses it or reports the reason it cannot.
- The reference describes the JSON JWT-bearer grant. Both pinned SDKs add `anthropic-beta: oauth-2025-04-20,oidc-federation-2026-04-01` to the exchange, and append only `oauth-2025-04-20` to API requests using OAuth. Dart follows both. The exchange has no API key, bearer, version header, inherited query, or redirect handling.
- The exchange transport shares the client base URL and underlying HTTP client. Require HTTPS outside loopback and prevent redirects. Cap assertion and response sizes, bound the timeout, and cancel stalled response subscriptions. Errors retain status, header/body provider request ID and retry timing without exposing assertion or response body text.
- The pinned SDKs use two-tier refresh at 120 and 30 seconds. Dart refreshes in the background inside the advisory window with a 5-second backoff on failure, and blocks for the shared refresh inside the mandatory window. The callback acquires a fresh JWT for every exchange. Explicit headers bypass exchange. A WIF request rejects workspace-header overrides before exchange because the token is bound at minting.
- The factory configures explicit workload identity. Ambient profile discovery, CLI-managed OAuth refresh-token grants, and automatic retry following rejected API credentials remain separate helper decisions. The runnable example shows environment-based acquisition of a projected identity token without binding SDK transport to a provider.
- The exchange follows the documented maximum token lifetime of 86400 seconds, requires a positive integer expires_in, and accepts absent token_type or scope as upstream does. If token_type is present, it must be Bearer case-insensitively.

Sources
- [Pinned Python exchange](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/lib/credentials/_workload.py)
- [Pinned TypeScript exchange](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/lib/credentials/oidc-federation.ts)
- [WIF HTTP contract](https://platform.claude.com/docs/en/manage-claude/wif-reference)

## Federation rules source decisions

The pinned HTTP response includes nullable `workspace_id` and `attributes`.
The GA Python and TypeScript rule types omit those fields. Dart accepts the
GA SDK projection and serializes the HTTP shape with explicit null fields.
Rule listing uses a cursor. The workspace binding list returns explicit
bindings with a null cursor and accepts the compatibility page parameters.
[WIF Admin guide](https://platform.claude.com/docs/en/manage-claude/wif-admin-api) · [Pinned Python rules](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/resources/organization/federation/rules/rules.py) · [Pinned TypeScript rule workspaces](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/organization/federation/rules/workspaces.ts)
