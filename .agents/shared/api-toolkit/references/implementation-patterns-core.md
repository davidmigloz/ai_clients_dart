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
