# Review Checklist (mistralai_dart)

Extends [REVIEW_CHECKLIST-core.md](../../../shared/openapi-toolkit/references/REVIEW_CHECKLIST-core.md).

---

## Pre-Review

Before reviewing changes, refresh the analysis:

```bash
# Fetch latest spec
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config

# Generate fresh analysis
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config \
  packages/mistralai_dart/specs/openapi.json /tmp/openapi-toolkit-mistralai-dart/latest-main.json \
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

## PASS 2: Mistral-Specific Checks

### Streaming

- [ ] SSE parsing implemented correctly
- [ ] Stream returns individual response chunks
- [ ] `[DONE]` marker indicates completion
- [ ] Error handling in stream

### Tool Calling

- [ ] `tools` parameter supported in chat
- [ ] `tool_calls` parsed in response
- [ ] `ToolCall` and `FunctionCall` models complete
- [ ] Tool result message handled (role: tool)
- [ ] `tool_choice` sealed class with all options

### Multimodal (Vision)

- [ ] `UserMessage` accepts text or `List<ContentPart>`
- [ ] `TextContentPart` implemented
- [ ] `ImageUrlContentPart` implemented
- [ ] Round-trip serialization works

### Response Format

- [ ] `ResponseFormat` sealed class implemented
- [ ] Text format supported
- [ ] JSON object format supported
- [ ] JSON schema format supported (structured outputs)

### Mistral-Specific Parameters

- [ ] `safe_prompt` parameter supported
- [ ] `prediction` parameter for speculative decoding
- [ ] `prompt_mode` for reasoning models
- [ ] `random_seed` for determinism

---

## PASS 3: Barrel File Completeness

```bash
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config
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
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config

python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config
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
2. **Tool calling** - Tools, tool_calls, tool_choice
3. **Multimodal** - Text and image_url content parts
4. **Response format** - text, json_object, json_schema
5. **Safety features** - safe_prompt parameter
6. **Reasoning models** - prompt_mode parameter
7. **Structured outputs** - JSON schema support

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
