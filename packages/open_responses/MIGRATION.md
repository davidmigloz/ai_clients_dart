# Migration Guide

This guide covers breaking changes between major versions of `open_responses`.

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).

---

## Migrating from v0.4.x to v0.5.0

v0.5.0 raises the minimum Dart SDK from 3.9 to 3.12. Applications and packages using Dart 3.9–3.11 must upgrade their toolchain before adopting this release.

### 1) Upgrade the Dart or Flutter SDK

Use Dart 3.12 or later. For Flutter projects, use a Flutter SDK that bundles Dart 3.12 or later; check the bundled version with `flutter --version`.

### 2) Update your pubspec

Before:

```yaml
environment:
  sdk: ">=3.9.0 <4.0.0"

dependencies:
  open_responses: ^0.4.3
```

After:

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  open_responses: ^0.5.0
```

Run `dart pub get` and your tests after updating. Flutter projects should use `flutter pub get` and `flutter test`.

---

## Migrating from v0.3.x to v0.4.0

v0.4.0 retypes `MessageOutputItem.content` from `List<OutputContent>` to `List<MessageContentPart>`, a new marker interface implemented by both `InputContent` and `OutputContent`. The change exists so that echoed-back user messages in stored or compacted response history (which carry `input_*` content parts per the spec) parse correctly. Type guards on leaf classes still narrow correctly; only intermediate list type declarations need updating.

### 1) `MessageOutputItem.content` Type Changed

```dart
// Before (v0.3.x)
final List<OutputContent> parts = item.content;
for (final c in parts) {
  if (c is OutputTextContent) print(c.text);
}

// After (v0.4.0) — declare List<MessageContentPart> (or use whereType)
final List<MessageContentPart> parts = item.content;
for (final c in parts.whereType<OutputTextContent>()) {
  print(c.text);
}
```

Direct type checks on leaf classes (`item.content.whereType<OutputTextContent>()`, `content[0] is RefusalContent`) continue to work unchanged.

---

## Migrating from v0.2.x to v0.3.0

v0.3.0 changes `InputFileContent.data()` to require a `mediaType` parameter for proper data URL construction.

### 1) `InputFileContent.data()` / `InputContent.fileData()` Signature Change

These factories now require a `mediaType` parameter and automatically construct the data URL format expected by the API.

```dart
// Before (v0.2.x)
InputFileContent.data(data: base64String)

// After (v0.3.0)
InputFileContent.data(data: base64String, mediaType: 'application/pdf')
```

---

## Migrating from v0.1.x to v0.2.0

v0.2.0 replaces the `ServiceTier` enum with an extensible class to align with the provider-agnostic OpenResponses specification.

### 1) `ServiceTier` Enum → Extensible Class

`ServiceTier` is now a class instead of an enum. This preserves provider-specific tier values on round-trip serialization instead of mapping unknown values to a lossy `unknown` fallback.

```dart
// Before (v0.1.x)
switch (tier) {
  case ServiceTier.auto: ...
  case ServiceTier.unknown: ...  // lossy — original value was lost
}

// After (v0.2.0)
if (tier == ServiceTier.auto) { ... }
// or switch with wildcard:
switch (tier) {
  case ServiceTier.auto: ...
  case _: print(tier.value); // preserves original string
}
```

Key changes:
- `ServiceTier.unknown` removed — unknown values are represented by their actual string
- `ServiceTier.values` no longer exists (enum-only API)
- `switch` on `ServiceTier` is no longer exhaustive — requires a wildcard `_` case
