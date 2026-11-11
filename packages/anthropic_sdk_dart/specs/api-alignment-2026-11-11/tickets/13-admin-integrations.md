# Add Admin plugins, webhooks, telemetry and Claude Tag

[GitHub issue #490](https://github.com/davidmigloz/ai_clients_dart/issues/490).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `13-admin-integrations` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Expose the pinned public enterprise integration endpoints with explicit availability boundaries.

## Dependencies

- #486
- #482

## Acceptance

- [ ] Verify plugin marketplace validation, plugin versions/content and settings, webhook subscriptions and secret rotation, telemetry destination lifecycle, and Claude Tag Slack/bundle settings.
- [ ] Assert each endpoint’s actual header gate and wire method, with tests for multipart, binary data, list cursors and no-content responses.
- [ ] Verify webhook event coverage, redaction, and the distinct Claude Enterprise permissions and opt-ins.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
