---
name: openapi-openai
description: >-
Update openai_dart from OpenAI OpenAPI changes. Fetch and compare specs, generate changelogs and prioritized implementation plans, and guide endpoint/model synchronization. Use for update api, sync openapi, compare spec changes, new endpoints, or implementation plan requests.
---


# OpenAPI Toolkit (openai_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.agents/shared/openapi-toolkit/README.md).

## Prerequisites

- `OPENAI_API_KEY` environment variable set (for integration tests)
- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Preflight (1 command)

Run this first to check pinned-vs-latest spec drift before fetching:

```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/openai_dart/.agents/skills/openapi-openai/config \
  --preflight-only
```

## ⚠️ CRITICAL: Working Directory Requirements

**Scripts MUST be run from the correct directory or they will fail.**

| Script | Run From | Command Prefix |
|--------|----------|----------------|
| `fetch_spec.py` | **REPO ROOT** | `python3 .agents/shared/...` |
| `analyze_changes.py` | **REPO ROOT** | `python3 .agents/shared/...` |
| `verify_*.py` | **PACKAGE ROOT** | `cd packages/openai_dart && python3 ../../.agents/shared/...` |
| `generate_*.py` | **PACKAGE ROOT** | `cd packages/openai_dart && python3 ../../.agents/shared/...` |

**Key paths:**
- Repository root: `$(git rev-parse --show-toplevel)`
- Package root: `$(git rev-parse --show-toplevel)/packages/openai_dart`
- Scripts dir: `.agents/shared/openapi-toolkit/scripts/`
- Config dir: `packages/openai_dart/.agents/skills/openapi-openai/config` (from repo root) or `.agents/skills/openapi-openai/config` (from package)

### Common Mistake

❌ **WRONG** - Running fetch_spec.py with package-relative path:
```bash
cd packages/openai_dart
python3 ../../.agents/shared/openapi-toolkit/scripts/fetch_spec.py  # FAILS!
```

✅ **CORRECT** - Running fetch_spec.py from repo root:
```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/openai_dart/.agents/skills/openapi-openai/config
```

## Quick Start

All commands below use explicit directory changes to work from anywhere:

```bash
# === REPO ROOT COMMANDS ===
# Fetch latest spec
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/openai_dart/.agents/skills/openapi-openai/config

# Analyze changes (specs auto-located from config)
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/openai_dart/.agents/skills/openapi-openai/config \
  --format all

# === PACKAGE ROOT COMMANDS ===
# Check API coverage (spec auto-located)
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-openai/config --verbose

# Verify all models are exported (auto-discovers all 3 barrel files)
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .agents/skills/openapi-openai/config

# Verify model properties match spec
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .agents/skills/openapi-openai/config
```

## Update Workflow (Recommended)

When updating the client to a new API version, follow this workflow to avoid missing new APIs:

### Step 1: Fetch Latest Spec
```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/openai_dart/.agents/skills/openapi-openai/config
```

### Step 2: Analyze Changes
Compare old spec vs new spec to find what changed. Specs are auto-located from config:

```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/openai_dart/.agents/skills/openapi-openai/config \
  --format all
```

### Step 3: Check Coverage (CRITICAL)
**Always run coverage check.** This catches APIs that exist in the spec but were never implemented:

```bash
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-openai/config --verbose
```

If auto-location fails, provide the spec explicitly:

```bash
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-openai/config \
  --spec specs/openapi.json --verbose
```

If missing resources are found, prioritize implementing them before other updates.

### Step 4: Implement & Verify
After implementation, verify completeness. Barrel files are auto-discovered:

```bash
# Check all models are exported (auto-discovers all 3 barrel files)
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .agents/skills/openapi-openai/config

# Check model properties match spec
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .agents/skills/openapi-openai/config

# Re-run coverage to confirm
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-openai/config
```

**Expected success output:**
- Coverage: `✓ Full API coverage achieved!`
- Exports: `✓ All model files are exported.`
- Properties: `✓ All critical models have complete properties.`

If all checks pass and no spec changes were found, the package is up-to-date.

## Large Spec Inspection (jq-first)

Use `jq` first for structured inspection, then `rg` for targeted text searches:

```bash
# List top-level paths quickly
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
jq -r '.paths | keys[]' specs/openapi.json | head -120

# Inspect a specific endpoint request/response schemas
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
jq '.paths["/responses/compact"].post' specs/openapi.json

# Inspect one schema deeply
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
jq '.components.schemas.CompactResponseMethodPublicBody' specs/openapi.json

# Then narrow text search to exact new fields/types
cd "$(git rev-parse --show-toplevel)/packages/openai_dart" && \
rg -n 'context_management|compact_threshold|shell_call|skill|local_shell' specs/openapi.json
```

## Configuration Files

- `config/specs.json` - Spec URLs and output paths
- `config/package.json` - Package structure and naming
- `config/schemas.json` - Model categorization rules
- `config/coverage.json` - Coverage exclusions (intentionally unimplemented APIs)

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)

## External References

- [Official OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [Official OpenAI Python SDK](https://github.com/openai/openai-python)
- [Official OpenAI Node SDK](https://github.com/openai/openai-node)
- [OpenAI OpenAPI Spec](https://storage.googleapis.com/stainless-sdk-openapi-specs/openai%2Fopenai-9442fa9212dd61aac2bb0edd19744bee381e75888712f9098bc6ebb92c52b557.yml)

## API Resources Overview

The OpenAI API includes the following major resources:

### Core AI
- **Responses** - Unified response API with built-in tools (web search, file search, code interpreter) - **RECOMMENDED**
- **Chat** - Chat completions (GPT-4, GPT-3.5, o1, etc.)
- **Completions** - Legacy text completions (deprecated)
- **Embeddings** - Text embeddings
- **Audio** - Speech synthesis (TTS), transcription, translation
- **Images** - DALL-E image generation
- **Videos** - Sora video generation

### File Management
- **Files** - File uploads and management
- **Uploads** - Multipart file uploads
- **Batches** - Batch processing
- **Containers** - Container management

### Model Information
- **Models** - List and describe models
- **Moderations** - Content moderation

### Assistants API (Beta)
- **Assistants** - AI assistant management
- **Threads** - Conversation threads
- **Messages** - Thread messages
- **Runs** - Assistant execution
- **Run Steps** - Execution steps
- **Vector Stores** - Document storage for RAG

### Fine-tuning
- **Fine-tuning Jobs** - Custom model training
- **Checkpoints** - Training checkpoints
- **Evals** - Model evaluation

### Real-time
- **Realtime API** - WebSocket-based real-time conversations

### Conversations (New)
- **Conversations** - Conversation state management
- **Chatkit** - Chat UI toolkit API

### Admin (Optional)
- **Organization** - Organization management (typically excluded)
- **Projects** - Project management (typically excluded)
