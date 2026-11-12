# Align official Claude cloud provider transports

[GitHub issue #494](https://github.com/davidmigloz/ai_clients_dart/issues/494).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `16-providers` of the fixed November alignment.

Align provider-specific routing and authentication exposed by the pinned official SDKs. Dart currently supports a custom base URL and an API key, which covers some wire-compatible routes and leaves transport and credential gaps.

## Dependencies

- #478 for the API-version contract.
- #487 for scoped Bearer credentials and token transport.

## Acceptance

- [ ] Account for Claude Platform on AWS, Amazon Bedrock Runtime and Mantle, Anthropic-managed Google Cloud, Google-managed Vertex and Microsoft Foundry against the pinned client source and platform docs.
- [ ] Verify provider URL construction, credential/header placement, path escaping, supported APIs and applicable API versions through deterministic local fixtures.
- [ ] Verify provider-specific body/version transformation and stream decoding for Bedrock Runtime and Vertex. Cover signing or documented credential-provider injection without accessing live services.
- [ ] Keep cloud-vendor credential acquisition isolated from the first-party client. Document any external dependency or access blocker with its exact unblock condition.
- [ ] Add runnable examples and release migration notes where provider selection affects the API contract.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

## References

- [Claude platform access](https://platform.claude.com/docs/en/api/overview)
- [Pinned Python platform clients](https://github.com/anthropics/anthropic-sdk-python/tree/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/lib)
- [Pinned TypeScript platform packages](https://github.com/anthropics/anthropic-sdk-typescript/tree/590783078cd961a0df698d9fddc0275c65ff3afd/packages)

## Bedrock source decisions

Both Bedrock transports reject server-held thread creation and raw thread
requests, matching the pinned SDK capability. Mantle preserves configured and
per-call workspace IDs, while Runtime moves model and API version into the
AWS request shape. [AWS workspace routing](https://docs.aws.amazon.com/bedrock/latest/userguide/workspaces.html) · [Pinned TypeScript Bedrock adapters](https://github.com/anthropics/anthropic-sdk-typescript/tree/590783078cd961a0df698d9fddc0275c65ff3afd/packages/bedrock-sdk)

Mantle uses `Authorization: Bearer` for the configured Bedrock API key, as
both pinned SDKs do. The public guide also describes sending the separately
minted short-lived Mantle key in `x-api-key`. An explicitly authenticated
custom gateway can use `skipAuth` with its required headers.
[Claude on Bedrock Mantle](https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock)

Runtime accepts conformant AWS EventStream frame sizes and validates the
prelude and message checksums. Partial transport reads reset the body idle
timeout while a frame is assembled. [AWS EventStream format](https://smithy.io/2.0/aws/amazon-eventstream.html#message-format)
