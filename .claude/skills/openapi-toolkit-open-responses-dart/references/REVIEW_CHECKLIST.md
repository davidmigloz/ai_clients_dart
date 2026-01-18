# Review Checklist (open_responses_dart)

Extends [REVIEW_CHECKLIST-core.md](../../../shared/openapi-toolkit/references/REVIEW_CHECKLIST-core.md).

## Contents

1. [Pre-Review](#pre-review)
2. [Pass 1: Implementation Verification](#pass-1-implementation-verification)
3. [Pass 2: OpenResponses-Specific Checks](#pass-2-openresponses-specific-checks)
4. [Pass 3: Barrel File Verification](#pass-3-barrel-file-verification)
5. [Pass 4: Documentation Completeness](#pass-4-documentation-completeness)
6. [Pass 5: Property-Level Verification](#pass-5-property-level-verification)
7. [Pass 6: Quality Gates](#pass-6-quality-gates)
8. [Common Gaps](#common-gaps)
9. [OpenResponses-Specific Patterns](#openresponses-specific-patterns)

---

## Pre-Review

Re-run the analysis to get a fresh spec comparison:

```bash
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config \
  packages/open_responses_dart/specs/openapi.json \
  /tmp/openapi-toolkit-open-responses-dart/latest-main.json \
  --format all
```

---

## Pass 1: Implementation Verification

### Breaking Changes (P0)
- [ ] Code deleted (not commented out)
- [ ] No orphaned references
- [ ] Barrel exports updated
- [ ] Related tests removed

### New Endpoints (P1)
- [ ] Resource method exists with correct HTTP verb
- [ ] URL path matches spec exactly
- [ ] Request/response types match spec schemas

### New Schemas (P2)
- [ ] All properties from spec
- [ ] Correct types
- [ ] `fromJson` handles all fields
- [ ] `toJson` includes all fields
- [ ] `copyWith` uses sentinel pattern
- [ ] Exported in barrel file
- [ ] Unit test exists

### Modified Schemas (P4)
- [ ] New properties added to class
- [ ] `fromJson`/`toJson`/`copyWith` updated
- [ ] Tests updated

---

## Pass 2: OpenResponses-Specific Checks

### Authentication
- [ ] Bearer token authentication via `Authorization` header
- [ ] AuthProvider pattern used consistently
- [ ] Streaming requests apply auth manually

### Streaming
- [ ] SSE streaming implemented correctly
- [ ] All 20+ event types handled in `StreamingEvent.fromJson`
- [ ] Terminal event `[DONE]` handled
- [ ] Streaming bypasses interceptor chain
- [ ] Auth applied before `httpClient.send()`

### Sealed Classes
- [ ] `Item` handles all input item types
- [ ] `OutputItem` handles all output item types
- [ ] `Tool` handles FunctionTool and McpTool
- [ ] `InputContent` handles all input content types
- [ ] `OutputContent` handles all output content types
- [ ] `StreamingEvent` handles all event types

### Input Format
- [ ] `CreateResponseRequest.input` handles both String and List<Item>

### Multi-Provider
- [ ] Works with OpenAI endpoint
- [ ] Works with Ollama endpoint (integration tests)
- [ ] Works with HuggingFace endpoint (integration tests)

---

## Pass 3: Barrel File Verification

```bash
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config
```

- [ ] All public types exported
- [ ] No internal types exposed
- [ ] Exports organized by feature area

---

## Pass 4: Documentation Completeness

```bash
python3 .claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config
python3 .claude/shared/openapi-toolkit/scripts/verify_examples.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config
```

- [ ] README.md updated with new features
- [ ] CHANGELOG.md updated
- [ ] Example files work and demonstrate new features
- [ ] API documentation comments complete

---

## Pass 5: Property-Level Verification

```bash
python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-open-responses-dart/config \
  --spec packages/open_responses_dart/specs/openapi.json
```

Critical models checked:
- [ ] `ResponseResource` - all response fields
- [ ] `CreateResponseRequest` - all request parameters
- [ ] `Item` - all item type variants
- [ ] `OutputItem` - all output item variants
- [ ] `Tool` - FunctionTool and McpTool
- [ ] `StreamingEvent` - all event types
- [ ] `InputContent` - all input content types
- [ ] `OutputContent` - all output content types

---

## Pass 6: Quality Gates

```bash
# Static analysis
cd packages/open_responses_dart && dart analyze --fatal-infos

# Formatting
cd packages/open_responses_dart && dart format --set-exit-if-changed .

# Tests
mcp__dart__run_tests(roots: [{root: "file:///path/to/packages/open_responses_dart"}])
```

- [ ] Zero analyzer warnings
- [ ] Code formatted
- [ ] All tests pass

---

## Common Gaps

| Gap | Check | How to Verify |
|-----|-------|---------------|
| Missing streaming event type | New event not in switch | Compare spec event types |
| Missing Item variant | New item type | Compare spec item types |
| Missing content type | New content format | Compare spec content types |
| Extension method outdated | Helpers don't work with new fields | Test extensions |
| Ollama-specific event | Provider-specific event | Check provider docs |

---

## OpenResponses-Specific Patterns

### Streaming Event Types (20+)

| Event | Class |
|-------|-------|
| `response.created` | `ResponseCreatedEvent` |
| `response.queued` | `ResponseQueuedEvent` |
| `response.in_progress` | `ResponseInProgressEvent` |
| `response.completed` | `ResponseCompletedEvent` |
| `response.failed` | `ResponseFailedEvent` |
| `response.incomplete` | `ResponseIncompleteEvent` |
| `response.output_item.added` | `OutputItemAddedEvent` |
| `response.output_item.done` | `OutputItemDoneEvent` |
| `response.content_part.added` | `ContentPartAddedEvent` |
| `response.content_part.done` | `ContentPartDoneEvent` |
| `response.output_text.delta` | `OutputTextDeltaEvent` |
| `response.output_text.done` | `OutputTextDoneEvent` |
| `response.output_text.annotation.added` | `OutputTextAnnotationAddedEvent` |
| `response.refusal.delta` | `RefusalDeltaEvent` |
| `response.refusal.done` | `RefusalDoneEvent` |
| `response.function_call_arguments.delta` | `FunctionCallArgumentsDeltaEvent` |
| `response.function_call_arguments.done` | `FunctionCallArgumentsDoneEvent` |
| `response.reasoning.delta` | `ReasoningDeltaEvent` |
| `response.reasoning.done` | `ReasoningDoneEvent` |
| `response.reasoning_summary_part.added` | `ReasoningSummaryPartAddedEvent` |
| `response.reasoning_summary_part.done` | `ReasoningSummaryPartDoneEvent` |
| `response.reasoning_summary.delta` | `ReasoningSummaryDeltaEvent` |
| `response.reasoning_summary.done` | `ReasoningSummaryDoneEvent` |
| `error` | `ErrorEvent` |

### Item Types

| Type | Class |
|------|-------|
| `message` | `MessageItem` |
| `function_call` | `FunctionCallItem` |
| `function_call_output` | `FunctionCallOutputItem` |
| `item_reference` | `ItemReference` |

### Response Status Values

| Value | Enum |
|-------|------|
| `in_progress` | `ResponseStatus.inProgress` |
| `completed` | `ResponseStatus.completed` |
| `failed` | `ResponseStatus.failed` |
| `incomplete` | `ResponseStatus.incomplete` |
| `queued` | `ResponseStatus.queued` |

### Message Roles

| Value | Enum |
|-------|------|
| `user` | `MessageRole.user` |
| `assistant` | `MessageRole.assistant` |
| `system` | `MessageRole.system` |
| `developer` | `MessageRole.developer` |

### Tool Types

| Type | Class |
|------|-------|
| `function` | `FunctionTool` |
| `mcp` | `McpTool` |
