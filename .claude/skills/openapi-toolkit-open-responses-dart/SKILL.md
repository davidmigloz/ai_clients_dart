---
name: openapi-toolkit-open-responses-dart
description: Automates updating open_responses_dart when OpenResponses OpenAPI spec changes. Fetches latest spec, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for API updates, (2) Generating implementation plans for spec changes, (3) Creating new models/endpoints from spec, (4) Syncing local spec with upstream. Triggers: "update api", "sync openapi", "new endpoints", "api changes", "check for updates", "update spec", "api version", "fetch spec", "compare spec", "what changed in the api", "implementation plan".
---

# OpenAPI Toolkit (open_responses_dart)

Uses shared scripts from [openapi-toolkit](../../shared/openapi-toolkit/README.md) with open_responses_dart-specific configuration.

## Prerequisites

- Working directory: Repository root
- Python 3
- No API key required to fetch spec (it's public)
- For integration tests: `OPENAI_API_KEY` environment variable

## Spec Registry

| Spec | Description | Auth Required |
|------|-------------|---------------|
| `main` | OpenResponses unified LLM API | No |

## Workflow

### 1. Fetch Latest Spec

```bash
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config
```

Output: `/tmp/openapi-toolkit-open-responses-dart/latest-main.json`

### 2. Analyze Changes

```bash
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config \
  packages/open_responses_dart/specs/openapi.json \
  /tmp/openapi-toolkit-open-responses-dart/latest-main.json \
  --format all \
  --changelog-out /tmp/openapi-toolkit-open-responses-dart/changelog.md \
  --plan-out /tmp/openapi-toolkit-open-responses-dart/plan.md
```

Generates:
- `changelog.md` - Human-readable change summary
- `plan.md` - Prioritized implementation plan (P0-P4)

### 3. Implement Changes

Before implementing, read `references/implementation-patterns.md` for:
- Model class structure and conventions
- Sealed class patterns for polymorphic types
- Streaming event handling
- JSON serialization patterns

Use templates from `../../shared/openapi-toolkit/assets/`.

### 3.5 Update Documentation (MANDATORY)

Before running the review checklist, update all documentation:

1. **README.md** - Add/update new features
2. **example/** - Create/update example files
3. **CHANGELOG.md** - Add entry for new features/changes

### 4. Review & Validate (MANDATORY)

Perform the multi-pass review documented in `references/REVIEW_CHECKLIST.md`:

```bash
# Pass 2: Barrel file verification
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config

# Pass 3: Documentation completeness
python3 .claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config
python3 .claude/shared/openapi-toolkit/scripts/verify_examples.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config

# Pass 4: Property-level verification
python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config

# Dart quality checks
cd packages/open_responses_dart && dart analyze --fatal-infos && dart format --set-exit-if-changed . && mcp__dart__run_tests()
```

### 5. Finalize

```bash
# Copy fetched spec to persisted location
cp /tmp/openapi-toolkit-open-responses-dart/latest-main.json packages/open_responses_dart/specs/openapi.json
```

## Package-Specific References

- [Package Guide](references/package-guide.md) - Package structure, naming conventions
- [Implementation Patterns](references/implementation-patterns.md) - Model conventions, serialization patterns
- [Review Checklist](references/REVIEW_CHECKLIST.md) - Multi-pass validation process

## External References

### Specification
- [OpenResponses Home](https://www.openresponses.org/)
- [OpenResponses Specification](https://www.openresponses.org/specification)
- [OpenResponses Changelog](https://www.openresponses.org/changelog)
- [OpenResponses OpenAPI Spec](https://www.openresponses.org/openapi/openapi.json)

### Provider Documentation
- [OpenAI Responses API](https://platform.openai.com/docs/api-reference/responses)
- [Vercel AI Gateway](https://vercel.com/docs/ai-gateway/openresponses)
- [vLLM OpenResponses](https://docs.vllm.ai/en/latest/examples/online_serving/openai_responses_client/)
- [vLLM MCP Tools](https://docs.vllm.ai/en/latest/examples/online_serving/openai_responses_client_with_mcp_tools/)
- [OpenRouter Responses](https://openrouter.ai/docs/api/reference/responses/overview)
- [OpenRouter Reasoning](https://openrouter.ai/docs/api/reference/responses/reasoning)
- [OpenRouter Tool Calling](https://openrouter.ai/docs/api/reference/responses/tool-calling)
- [HuggingFace Responses](https://huggingface.co/docs/inference-providers/guides/responses-api)
- [Ollama Compatibility](https://docs.ollama.com/api/openai-compatibility)
- [LM Studio](https://lmstudio.ai/blog/lmstudio-v0.3.29)

## Troubleshooting

- **Network errors**: Check connectivity; retry after a few seconds
- **No changes detected**: Summary shows all zeros; no action needed
- **Integration test failures**: Set `OPENAI_API_KEY` environment variable
