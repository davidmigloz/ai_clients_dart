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
