# Implementation Review Checklist (Core)

Generic verification patterns for Dart API client packages. See your package's `references/REVIEW_CHECKLIST.md` for package-specific checks.

## Verification by Category

### Breaking Changes (P0)
For each removed endpoint/schema:
- [ ] Code deleted (not commented out)
- [ ] No orphaned references in other files
- [ ] Barrel exports updated
- [ ] Related tests removed

### New Endpoints (P1)
For each new endpoint:
- [ ] Resource method exists with correct HTTP verb
- [ ] URL path matches spec exactly
- [ ] Request/response types match spec schemas
- [ ] Added to client (if top-level resource)

### New Schemas (P2)
For each new schema, verify the model file has:
- [ ] All properties from spec
- [ ] Correct types (see Type Mappings in implementation-patterns-core.md)
- [ ] Required vs optional matches spec
- [ ] `fromJson` handles all fields with correct casting
- [ ] `toJson` includes all fields with null checks
- [ ] `copyWith` uses sentinel pattern for all fields
- [ ] `toString` includes all fields
- [ ] Exported in barrel file
- [ ] Unit test with round-trip serialization test

### Modified Schemas (P4)
For each schema with new/changed properties:
- [ ] New properties added to class
- [ ] `fromJson` updated
- [ ] `toJson` updated
- [ ] `copyWith` updated
- [ ] `toString` updated
- [ ] Tests updated for new fields

### Streaming Resources
For resources with streaming methods:
- [ ] Uses `StreamingResource` mixin (not duplicated helpers)
- [ ] Mixin methods are package-internal (not exported)
- [ ] `prepareStreamingRequest()` applies auth and logging
- [ ] `sendStreamingRequest()` handles HTTP errors before streaming
- [ ] Abort monitoring tested (if applicable)

### Multipart Upload Resources
For resources with file uploads using `MultipartRequest`:
- [ ] Has `_applyAuthentication()` helper method
- [ ] Calls `_applyAuthentication(request)` before `httpClient.send()`
- [ ] Removes `content-type` header (multipart sets its own boundary)
- [ ] Handles HTTP errors with proper exception mapping
- [ ] Imports `AuthProvider` and credential types

---

## Cross-Reference Verification

### Sealed Classes
Check these sealed classes handle all their variants:
- [ ] All sealed classes with `factory fromJson` handle all subtypes
- [ ] New variants added to switch statements

### Nested References
- [ ] All nested object types are imported
- [ ] `List<T>` uses correct element type
- [ ] Enum converters exist for all enum types

### Parent Model Updates
**CRITICAL:** Parent models often need updates when new schemas are added.

Run the property verification script:
```bash
python3 {core}/scripts/verify_model_properties.py --config-dir {ext}/config
```

---

## Four-Pass Review

### Pass 1: Implementation Completeness
Compare implementation against the generated plan:
- [ ] All P0 items addressed
- [ ] All P1 items addressed
- [ ] All P2 items addressed
- [ ] All P4 items addressed

### Pass 2: Barrel File Completeness

```bash
python3 {core}/scripts/verify_exports.py --config-dir {ext}/config
```

Verifies:
- All `.dart` files in models directory are exported
- Transitive dependencies are exported
- No unexported public API types

### Pass 3: Documentation Completeness

```bash
python3 {core}/scripts/verify_readme.py --config-dir {ext}/config
python3 {core}/scripts/verify_examples.py --config-dir {ext}/config
python3 {core}/scripts/verify_readme_code.py --config-dir {ext}/config
```

Checks:
- All resources are documented in README
- All tool properties are documented
- Example files exist for each resource
- README code examples are accurate

### Pass 4: Property-Level Verification

```bash
python3 {core}/scripts/verify_model_properties.py --config-dir {ext}/config
```

Compares Dart model classes against OpenAPI spec:
- Missing properties in critical parent models
- Properties that exist in spec but not in Dart class

### Pass 5: Deep Schema Verification

This pass is optional but strongly recommended for thorough verification.

```bash
python3 {core}/scripts/verify_schema_deep.py \
  --config-dir {ext}/config \
  --spec {package}/specs/openapi.json
```

Performs comprehensive schema verification beyond property names:
- Property presence validation (all spec properties exist in Dart)
- Required/optional (nullable) validation
- All nested schemas have complete properties
- All sealed class variants have correct properties

Note: Full type validation is not yet implemented; the script currently
focuses on property presence and nullability checks.

Recommended for:
- Initial implementation reviews
- Major spec updates affecting critical models
- Debugging serialization issues

Configuration in `models.json`:
- `nested_schemas`: Additional schemas to verify (not just critical_models)
- `sealed_classes`: Sealed class hierarchies with all variants
- `type_mappings`: Override default OpenAPI-to-Dart type mappings

---

## Quality Gates

All must pass before finalization:

```bash
# Static analysis (zero issues)
dart analyze --fatal-infos

# Formatting check
dart format --set-exit-if-changed .

# Unit tests
dart test test/unit/

# Verification scripts
python3 {core}/scripts/verify_exports.py --config-dir {ext}/config
python3 {core}/scripts/verify_readme.py --config-dir {ext}/config
python3 {core}/scripts/verify_examples.py --config-dir {ext}/config
python3 {core}/scripts/verify_model_properties.py --config-dir {ext}/config
python3 {core}/scripts/verify_readme_code.py --config-dir {ext}/config

# Optional: Deep schema verification (recommended for major changes)
python3 {core}/scripts/verify_schema_deep.py \
  --config-dir {ext}/config \
  --spec {package}/specs/openapi.json
```

---

## Fix Loop Process

If gaps were found:

1. **Fix each gap** using patterns from `implementation-patterns-core.md`
2. **Re-run quality gates**
3. **Re-run review** from Pass 1
4. **Repeat** until all items verified

### Common Fix Patterns

| Gap Type | Fix |
|----------|-----|
| Missing property | Add field, update fromJson/toJson/copyWith/toString |
| Missing export | Add to barrel file |
| Sealed class variant | Add case to `fromJson` factory switch |
| Missing test | Create using `assets/test_template.dart` |
| Type mismatch | Check Type Mappings in implementation-patterns-core.md |

---

## Review Output Template

Document findings in this format:

### Verified
- [x] Model complete with all fields
- [x] Tests pass

### Gaps Found
- [ ] Missing property in parent model
- [ ] Schema not implemented

### Recommendation
- [ ] Proceed to finalize
- [x] Fix gaps first

---

## Updating Config Files

When adding new features, update your config files:

| Feature Type | Config File | What to Add |
|--------------|-------------|-------------|
| New Tool property | `documentation.json` | Add to `tool_properties` |
| New critical model | `models.json` | Add to `critical_models` |
| New nested schema | `models.json` | Add to `nested_schemas` |
| New sealed class | `models.json` | Add to `sealed_classes` with variants |
| New drift pattern | `documentation.json` | Add to `drift_patterns` |
| Removed API | `documentation.json` | Add to `removed_apis` |

### models.json Extended Format

```json
{
  "critical_models": [...],
  "nested_schemas": [
    {"name": "SchemaName", "file": "path/to/file.dart", "spec_schema": "SpecSchemaName"}
  ],
  "sealed_classes": [
    {
      "name": "SealedClassName",
      "file": "path/to/file.dart",
      "variants": [
        {"dart_class": "VariantA", "spec_schema": "SpecVariantA"},
        {"dart_class": "VariantB", "spec_schema": null, "extension": true}
      ]
    }
  ],
  "type_mappings": {...},
  "excluded_properties": {"global": [], "SpecificSchema": ["prop"]}
}
```
