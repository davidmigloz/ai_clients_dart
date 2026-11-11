# Add usage and cost analytics and legacy reports

[GitHub issue #488](https://github.com/davidmigloz/ai_clients_dart/issues/488).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `11-analytics` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Support both generations of public usage/cost reporting and Enterprise Analytics with the documented scope.

## Dependencies

- #486

## Acceptance

- [ ] Verify cursor and bucket responses, repeated filter/group keys, actor/organization dimensions, and decimal cost values.
- [ ] Cover new analytics routes, Claude Tag summary metrics and the 2026-10-21 email_address/data compatibility rules.
- [ ] Keep supported legacy routes usable and provide migration examples.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
