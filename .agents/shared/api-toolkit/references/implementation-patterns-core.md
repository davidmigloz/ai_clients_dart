# Core Implementation Patterns

- Keep specs checked in under package `specs/` and compare them against fetched scratch specs.
- Keep Dart serialization handwritten and deterministic.
- Prefer low-freedom workflows: fetch, review, scaffold, verify.
- Use `manifest.json` for type mapping, placement, and verification intent.

## Manifest `kind` Values

| Kind | Use for |
|------|---------|
| `object` | Standalone classes (no sealed parent) |
| `sealed_parent` | Base sealed class with discriminator |
| `sealed_variant` | Concrete subclass of a sealed parent (has `parent` field). Auto-excludes discriminator fields from all ancestor sealed parents during verification. **Always use this for sealed children — never `object`.** |
| `extension` | Dart-only subclass with no spec schema (schema is `null`) |
| `enum` | Enum types |
| `skip` | Entries excluded from verification (with `note` explaining why) |

## Type Safety Patterns

### `oneOf` / `anyOf` Spec Fields → Sealed Dart Types

When a spec property uses `oneOf` or `anyOf` with multiple `$ref` items or
mixed types, the Dart field should use a sealed union type, not `Object?` or
`dynamic`. The toolkit `verify --checks implementation` warns when it detects
`Object` or `dynamic` for fields that reference specific schema types or unions.

### Sibling Sealed Variants Must Have Consistent Field Patterns

All variants of a sealed parent should use consistent nullability and types
for fields with the same name. The toolkit `verify --checks consistency`
warns on mismatches. For example, if most `*Delta` variants declare `id`
as `String?`, a single variant with non-nullable `id` is flagged.

### Discriminator Key Choice

When implementing `fromJson` dispatch for sealed types, prefer always-required
fields like `type` as the discriminator. Avoid optional fields like `role`
that may not be present in all variants.

### Resource Method Parameters (Future)

Resource method signatures vary across packages (typed request objects,
decomposed named params, positional args). A future toolkit enhancement
will validate resource parameters against Params/Request models once a
deterministic mapping source is established in the manifest.

## `toString` Convention

Every `@immutable` model class should include **all fields** in its `toString`
output so that the toolkit verifier can confirm completeness. To keep output
readable, truncate or summarize noisy values:

- **Lists**: show count — `tools: ${tools.length} items`
- **Maps**: show count — `metadata: ${metadata.length} entries`
- **Long strings**: first N chars — `instructions: ${instructions?.substring(0, 50)}...`
- **Nested objects**: use their own toString or show a summary field
