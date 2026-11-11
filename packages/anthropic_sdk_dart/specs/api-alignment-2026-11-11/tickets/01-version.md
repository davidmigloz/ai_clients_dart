# Adopt API version 2026-10-21 with a legacy opt-out

[GitHub issue #478](https://github.com/davidmigloz/ai_clients_dart/issues/478).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `01-version` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Make the latest header the default after accounting for incompatible Messages inputs. Keep the 2023-06-01 request path available and retain the API-key header accepted by Claude for existing gateways.

## Dependencies

- Can start after the planning PR merges.

## Acceptance

- [ ] Verify the effective version and legacy override through ordinary Messages, SSE, token counts and each batch entry.
- [ ] Reject the documented incompatible inputs in the new version without editing or discarding caller data. Preserve valid assistant citations, nested documents and the legacy sampling fields.
- [ ] Publish before-and-after migration examples and review the SDK-only changes separately from the server contract.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
