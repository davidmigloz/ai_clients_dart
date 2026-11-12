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

## Telemetry destinations

The nine destination and workspace operations use
`telemetry-destinations-2026-08-11` and opaque `next_page` cursors. The Dart
resource adds the required beta after resolving caller overrides. Destination
filters send repeated `workspace_ids[]` as specified by the HTTP guide.
Dart treats an empty cursor as exhausted, like both SDKs.

The generated types allow a null top-level `headers` field, while their
descriptions and the HTTP guide allow null only for individual header values.
Dart omits the field when absent and uses per-header nulls to remove values.
It keeps workspace selector omission distinct from an explicitly empty list.
The API reports test span delivery failure as a result in HTTP 200.

[Pinned Python telemetry resource](https://github.com/anthropics/anthropic-sdk-python/tree/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/resources/beta/organization/telemetry_destinations) · [Pinned TypeScript telemetry resource](https://github.com/anthropics/anthropic-sdk-typescript/tree/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/beta/organization/telemetry-destinations) · [OpenTelemetry export](https://platform.claude.com/docs/en/manage-claude/opentelemetry/api)

## Claude Tag

The fourteen Slack workspace, channel, bundle and attachment operations use
API version `2026-10-21` and beta `experimental-claude-tag-2026-10-21`.
Claude Enterprise access and distinct read and write scopes apply. Anthropic
must enable writes separately. Filters use Slack's identifiers; retrieve,
update and attachment paths use IDs returned by the API.

The guide lists five settings. The pinned snapshot and both SDKs include
`reply_mode` as a sixth. Dart supports it and accepts responses where it is
omitted. Omitted update settings stay unchanged. Explicit null clears the
other nullable settings to inherit a value. The API rejects clearing an
existing channel reply mode and sending a non-null workspace reply mode.
`automatic` restores default channel behavior. A partially successful channel
setup leaves the channel configured with unset settings and returns its
`slack_channel_id` in the error details.

[Pinned Python Claude Tag resource](https://github.com/anthropics/anthropic-sdk-python/tree/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/resources/beta/organization/claude_tag) · [Pinned TypeScript Claude Tag resource](https://github.com/anthropics/anthropic-sdk-typescript/tree/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/beta/organization/claude-tag) · [Claude Tag API](https://platform.claude.com/docs/en/manage-claude/claude-tag-api)
