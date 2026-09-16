# Migration Guide

This guide covers breaking changes between versions of `tavily_dart`.

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).

---

## Migrating from v0.2.x to v0.3.0

v0.3.0 raises the minimum Dart SDK from 3.9 to 3.12. Applications and packages using Dart 3.9–3.11 must upgrade their toolchain before adopting this release.

### 1) Upgrade the Dart or Flutter SDK

Use Dart 3.12 or later. For Flutter projects, use a Flutter SDK that bundles Dart 3.12 or later; check the bundled version with `flutter --version`.

### 2) Update your pubspec

Before:

```yaml
environment:
  sdk: ">=3.9.0 <4.0.0"

dependencies:
  tavily_dart: ^0.2.5
```

After:

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  tavily_dart: ^0.3.0
```

Run `dart pub get` and your tests after updating. Flutter projects should use `flutter pub get` and `flutter test`.

---
