---
name: openapi-open-responses
description: Automates updating open_responses_dart when OpenResponses OpenAPI spec changes. Fetches latest spec, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for API updates, (2) Generating implementation plans for spec changes, (3) Creating new models/endpoints from spec, (4) Syncing local spec with upstream. Triggers: "update api", "sync openapi", "new endpoints", "api changes", "check for updates", "update spec", "api version", "fetch spec", "compare spec", "what changed in the api", "implementation plan".
---

# OpenAPI Toolkit (open_responses_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.claude/shared/openapi-toolkit/README.md) with open_responses_dart-specific configuration.

## Prerequisites

- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`
- No API key required to fetch spec (it's public)
- For integration tests: `OPENAI_API_KEY` environment variable

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.claude/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/open_responses_dart`) |

## Spec Registry

| Spec | Description | Auth Required |
|------|-------------|---------------|
| `main` | OpenResponses unified LLM API | No |

## Workflow

### 1. Fetch Latest Spec (REPO ROOT)

```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/open_responses_dart/.claude/skills/openapi-open-responses/config
```

Output: `/tmp/openapi-open-responses-dart/latest-main.json`

### 1.5. Analyze Changes (REPO ROOT)

Compare old spec vs new spec to find what changed. **Specs are auto-located** from config:

```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/open_responses_dart/.claude/skills/openapi-open-responses/config \
  --format all
```

### 2. Check API Coverage (CRITICAL - PACKAGE ROOT)

**Always run coverage check.** This catches APIs that exist in the spec but were never implemented. **Spec is auto-located**:

```bash
cd "$(git rev-parse --show-toplevel)/packages/open_responses_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-open-responses/config --verbose
```

If missing resources are found, prioritize implementing them before other updates.

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

### 4. Review & Validate (MANDATORY - PACKAGE ROOT)

Perform the multi-pass review documented in `references/REVIEW_CHECKLIST.md`:

```bash
# Pass 2: Barrel file verification
cd "$(git rev-parse --show-toplevel)/packages/open_responses_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-open-responses/config

# Pass 3: Documentation completeness
cd "$(git rev-parse --show-toplevel)/packages/open_responses_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-open-responses/config

cd "$(git rev-parse --show-toplevel)/packages/open_responses_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_examples.py \
  --config-dir .claude/skills/openapi-open-responses/config

# Pass 4: Property-level verification
cd "$(git rev-parse --show-toplevel)/packages/open_responses_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-open-responses/config \
  --spec specs/openapi.json

# Dart quality checks
cd "$(git rev-parse --show-toplevel)/packages/open_responses_dart" && \
dart analyze --fatal-infos && dart format --set-exit-if-changed . && dart test
```

### 5. Finalize (REPO ROOT)

```bash
cd "$(git rev-parse --show-toplevel)" && \
cp /tmp/openapi-open-responses-dart/latest-main.json packages/open_responses_dart/specs/openapi.json
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
