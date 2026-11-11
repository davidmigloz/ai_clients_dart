# Add Models capabilities and workspace routing

[GitHub issue #479](https://github.com/davidmigloz/ai_clients_dart/issues/479).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `02-models-routing` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Expose current model capabilities, lifecycle, model lines and explicit workspace and beta header routing.

## Dependencies

- #478

## Acceptance

- [ ] Verify list/retrieve plus beta Models headers, repeated lifecycle query values and page boundaries.
- [ ] Preserve older response fixtures, unknown wire values and arbitrary model identifiers.
- [ ] Wire workspace routing through applicable Messages, count, batch, Files, Skills, Models and Managed Agents surfaces via per-request options or the shared configuration; document which authentication schemes use it.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
