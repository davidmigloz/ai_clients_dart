# Review Checklist (ollama_dart)


## Contents

- [Pre-Review](#pre-review)
- [PASS 1: Implementation Verification](#pass-1-implementation-verification)
  - [P0: Breaking Changes](#p0-breaking-changes)
  - [P1: New Endpoints](#p1-new-endpoints)
  - [P2: New Schemas](#p2-new-schemas)
  - [P3: Modified Schemas](#p3-modified-schemas)
- [PASS 2: Ollama-Specific Checks](#pass-2-ollama-specific-checks)
  - [Streaming](#streaming)
  - [Tool Calling](#tool-calling)
  - [Thinking Mode](#thinking-mode)
  - [Context Memory](#context-memory)
  - [Model Options](#model-options)
- [PASS 3: Barrel File Completeness](#pass-3-barrel-file-completeness)
- [PASS 4: Documentation Completeness](#pass-4-documentation-completeness)
  - [README.md](#readmemd)
  - [CHANGELOG.md](#changelogmd)
  - [Examples](#examples)
- [PASS 5: Quality Gates](#pass-5-quality-gates)
- [Common Gaps to Check](#common-gaps-to-check)
- [Review Output Template](#review-output-template)
- [Review Summary](#review-summary)
  - [Changes Verified](#changes-verified)
  - [Quality Checks](#quality-checks)
  - [Issues Found](#issues-found)
  - [Recommendations](#recommendations)

Extends [REVIEW_CHECKLIST-core.md](../../../../../../.agents/shared/openapi-toolkit/references/REVIEW_CHECKLIST-core.md).

---

## Pre-Review

Before reviewing changes, refresh the analysis:

```bash
# Fetch latest spec
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config

# Generate fresh analysis
python3 .agents/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config \
  packages/ollama_dart/specs/openapi.json /tmp/openapi-ollama-dart/latest-main.json \
  --format all
```

---

## PASS 1: Implementation Verification

### P0: Breaking Changes

- [ ] API signature changes handled with deprecation warnings
- [ ] Removed fields handled gracefully
- [ ] Type changes are backward compatible

### P1: New Endpoints

- [ ] Resource method added
- [ ] Request model implemented
- [ ] Response model implemented
- [ ] Streaming variant added (if applicable)
- [ ] Integration test added

### P2: New Schemas

For each new schema:
- [ ] File created in correct directory
- [ ] All properties implemented
- [ ] fromJson factory complete
- [ ] toJson method complete
- [ ] copyWith method complete
- [ ] Equality operators implemented
- [ ] Unit tests added
- [ ] Exported in barrel file

### P3: Modified Schemas

For each modified schema:
- [ ] New properties added
- [ ] Deprecated properties marked (if any)
- [ ] Tests updated
- [ ] Documentation updated

---

## PASS 2: Ollama-Specific Checks

### Streaming

- [ ] NDJSON parsing implemented correctly
- [ ] Stream returns individual response chunks
- [ ] `done` field indicates completion
- [ ] Error handling in stream

### Tool Calling

- [ ] `tools` parameter supported in chat
- [ ] `tool_calls` parsed in response message
- [ ] `ToolCall` and `ToolCallFunction` models complete
- [ ] Tool result message handled (role: tool)

### Thinking Mode

- [ ] `think` parameter accepted (bool or string)
- [ ] `thinking` field in response parsed
- [ ] Thinking content in Message handled

### Context Memory

- [ ] `context` parameter accepted in generate
- [ ] `context` returned in response
- [ ] Can pass context back for continuation

### Model Options

- [ ] `RequestOptions` includes all parameters
- [ ] Temperature, top_k, top_p, etc.
- [ ] GPU/VRAM options included
- [ ] Mirostat settings included

---

## PASS 3: Barrel File Completeness

```bash
python3 .agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
```

- [ ] All new models exported
- [ ] All enums exported
- [ ] No duplicate exports
- [ ] Organized by category

---

## PASS 4: Documentation Completeness

### README.md

- [ ] New features documented
- [ ] New examples added
- [ ] API coverage table updated

### CHANGELOG.md

- [ ] Breaking changes noted
- [ ] New features listed
- [ ] Bug fixes documented

### Examples

- [ ] Working examples for new features
- [ ] Examples compile and run

---

## PASS 5: Quality Gates

```bash
# Analysis
mcp__dart__analyze_files()

# Formatting
mcp__dart__dart_format()

# Tests
mcp__dart__run_tests()

# Verification
python3 .agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config

python3 .agents/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
```

All must pass:
- [ ] Zero analyzer warnings
- [ ] Code formatted
- [ ] All tests pass
- [ ] All exports verified
- [ ] Critical models verified

---

## Common Gaps to Check

1. **Streaming endpoints** - Both sync and stream variants
2. **Progress responses** - Pull/Push/Create streaming
3. **Model metrics** - Timing fields in responses
4. **Remote model fields** - remote_model, remote_host
5. **Image handling** - base64 images in messages
6. **Format options** - JSON and JSON schema
7. **Keep alive** - Duration string parsing

---

## Review Output Template

```markdown
## Review Summary

### Changes Verified
- [ ] New schemas: X
- [ ] Modified schemas: X
- [ ] New endpoints: X

### Quality Checks
- [ ] Analysis: PASS/FAIL
- [ ] Format: PASS/FAIL
- [ ] Tests: PASS/FAIL
- [ ] Exports: PASS/FAIL
- [ ] Properties: PASS/FAIL

### Issues Found
1. [Issue description]

### Recommendations
1. [Recommendation]
```
