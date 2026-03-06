# Implementation Patterns

- Extend the shared core patterns in [implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md).
- Keep package-specific layering consistent with `packages/openai_dart/lib/src/`.
- Use `describe` before adding new manifest entries or scaffolds.

## Equality / hashCode Contract

Every `@immutable` class that overrides `==` and `hashCode` **must** compare and
hash the same set of fields. Violating this contract causes undefined behavior
when instances are used in `Set`, `Map`, or compared in tests.

```dart
// CORRECT — same fields in both
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is MyClass &&
        runtimeType == other.runtimeType &&
        fieldA == other.fieldA &&
        fieldB == other.fieldB;

@override
int get hashCode => Object.hash(fieldA, fieldB);

// WRONG — == ignores fields but hashCode uses them
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is MyClass && runtimeType == other.runtimeType;

@override
int get hashCode => Object.hash(fieldA, fieldB); // contract violation!
```

For `List` fields, use a helper like `_listEquals` in `==` and `Object.hashAll`
in `hashCode`.

## Model-Specific Field Nullability

When the OpenAI API has multiple model families that return different response
shapes (e.g., `text-moderation-*` vs `omni-moderation-*`), fields only returned
by newer models **must** be nullable so that responses from older models parse
without throwing.

Check the OpenAPI spec examples and the Python SDK for which fields are truly
required across all model variants vs only present in specific ones.
