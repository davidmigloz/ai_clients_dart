# Review Checklist (anthropic_sdk_dart)

Extends [REVIEW_CHECKLIST-core.md](../../../shared/openapi-toolkit/references/REVIEW_CHECKLIST-core.md).

## Pre-Review Setup

```bash
# Fetch latest spec
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-toolkit-anthropic-dart/config

# Analyze changes
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-toolkit-anthropic-dart/config \
  packages/anthropic_sdk_dart/specs/openapi.yaml \
  /tmp/openapi-toolkit-anthropic-dart/latest-main.yaml \
  --format all
```

## Review Passes

### Pass 1: Implementation Verification

- [ ] Breaking changes identified and documented
- [ ] New endpoints implemented with correct HTTP methods
- [ ] New schemas implemented with all properties
- [ ] Modified schemas updated with new/changed properties
- [ ] Removed APIs properly deprecated or removed

### Pass 2: Anthropic-Specific Checks

- [ ] `x-api-key` header used (not Bearer token)
- [ ] `anthropic-version` header set on all requests
- [ ] `anthropic-beta` header used for beta features
- [ ] **Beta header values verified from TypeScript SDK** (see table in implementation-patterns.md)
- [ ] SSE streaming implemented correctly
- [ ] Content blocks use sealed class pattern
- [ ] Tool use/result blocks handle all variants
- [ ] Nested resources work (`messages.batches`)
- [ ] Stop reasons mapped correctly

### Pass 2b: Resources Using Direct httpClient.send()

For streaming and multipart resources:
- [ ] `_applyAuthentication()` helper exists
- [ ] Auth applied before `httpClient.send()` call
- [ ] Error handling maps HTTP errors to typed exceptions
- [ ] `content-type` header removed for multipart (boundary set automatically)

### Pass 3: Barrel File Verification

```bash
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-anthropic-dart/config
```

- [ ] All public types exported
- [ ] No internal types exposed
- [ ] Exports organized by feature area

### Pass 4: Documentation

- [ ] README.md updated with new features
- [ ] CHANGELOG.md updated
- [ ] Example files work and demonstrate new features
- [ ] API documentation comments complete

### Pass 5: Quality Gates

```bash
dart analyze --fatal-infos
dart format --set-exit-if-changed .
mcp__dart__run_tests()
```

- [ ] Zero analyzer warnings
- [ ] Code formatted
- [ ] All tests pass
- [ ] Model properties match spec

```bash
python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-anthropic-dart/config
```

## Common Gaps

### Model Issues
- [ ] Missing `copyWith` on models with nullable fields
- [ ] Missing enum fallback values
- [ ] Missing `==` and `hashCode` implementations
- [ ] Missing `@immutable` annotations
- [ ] Streaming events not handling all types

### Beta API Issues
- [ ] Beta header not passed for beta features
- [ ] **Wrong beta header value** (verify from TypeScript SDK!)
- [ ] Beta header using outdated date format

### Authentication Issues (Direct HTTP Requests)
- [ ] Streaming resource missing `_applyAuthentication()` call
- [ ] Multipart upload missing `_applyAuthentication()` call
- [ ] Auth applied after headers (should be before `send()`)

### Integration Test Issues
- [ ] Invalid inline test data (e.g., tiny base64 images)
- [ ] Missing graceful skip for unavailable dependencies
- [ ] Hard-coded values that change (use env vars or fetch)

## Anthropic-Specific Patterns

### Content Block Types
- `text` - Text content
- `image` - Base64 or URL image
- `tool_use` - Tool invocation
- `tool_result` - Tool result

### Stop Reasons
- `end_turn` - Natural end
- `max_tokens` - Token limit reached
- `stop_sequence` - Stop sequence hit
- `tool_use` - Tool use requested

### Stream Event Types
- `message_start`
- `content_block_start`
- `content_block_delta`
- `content_block_stop`
- `message_delta`
- `message_stop`
- `ping`
- `error`
