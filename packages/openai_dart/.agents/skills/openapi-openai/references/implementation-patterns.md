# Implementation Patterns

- Extend the shared core patterns in [implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md).
- Keep package-specific layering consistent with `packages/openai_dart/lib/src/`.
- Use `describe` before adding new manifest entries or scaffolds.

## OpenAI-Specific Patterns

### Multi-Model Response Shapes

The OpenAI API has multiple model families that return different response shapes
(e.g., `text-moderation-*` vs `omni-moderation-*`). Fields only returned by
newer models **must** be nullable so responses from older models parse without
throwing.

Check the OpenAPI spec examples and the Python SDK for which fields are truly
required across all model variants vs only present in specific ones.
