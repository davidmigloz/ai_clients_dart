# Migration Guide

This guide covers breaking changes between versions of `vertex_ai`.

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).

---

## Migrating from v0.2.x to v0.3.0

v0.3.0 requires `googleapis ^17.0.0` instead of `^16.0.0`. This changes dependency compatibility even though the Vertex AI wrapper methods are unchanged. The Dart SDK minimum remains 3.9.

### 1) Align dependencies on `googleapis` 17

If your application depends directly on `googleapis`, update that constraint alongside `vertex_ai`:

```yaml
# Before
dependencies:
  vertex_ai: ^0.2.5
  googleapis: ^16.0.0
```

```yaml
# After
dependencies:
  vertex_ai: ^0.3.0
  googleapis: ^17.0.0
```

Run `dart pub get` after updating the constraints. If another dependency still requires `googleapis` 16, upgrade that dependency to a compatible version or remain on `vertex_ai` 0.2.5 until the constraints can be aligned. Avoid forcing an incompatible version with `dependency_overrides`.

Public API constructors such as `VertexAITextModelApi` accept resource objects from `googleapis/aiplatform/v1.dart`; those objects must come from the resolved 17.x client. If your application also uses other Google APIs, review the [googleapis 17 release notes](https://github.com/google/googleapis.dart/releases/tag/googleapis-v17.0.0) for removed APIs and deprecations.

The dependency constraint is maintained in the repository's root Melos bootstrap configuration and propagated to this package by `melos bootstrap`.

---
