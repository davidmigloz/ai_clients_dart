import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

/// Regression for the `_notSet` tri-state sentinel pattern.
///
/// Clearable fields are stored as `Object?`. Passing an untyped empty literal
/// (`[]` / `{}` — the natural "clear to empty" / full-replacement case) infers
/// a dynamic-typed collection, which previously threw a runtime `TypeError` on
/// the direct `as List<T>?` / `as Map<K,V>?` cast in the getters and `toJson`.
/// The getters now use `(x as List?)?.cast<T>()` / `(x as Map?)?.cast<K,V>()`,
/// so these must not throw and must serialize to empty collections.
void main() {
  group('Update*Params untyped empty literals do not throw', () {
    test('UpdateSessionParams', () {
      const p = UpdateSessionParams(metadata: {}, vaultIds: []);
      expect(p.metadata, isEmpty);
      expect(p.vaultIds, isEmpty);
      final j = p.toJson();
      expect(j['metadata'], isEmpty);
      expect(j['vault_ids'], isEmpty);
    });

    test('UpdateAgentParams', () {
      const p = UpdateAgentParams(
        version: 1,
        tools: [],
        mcpServers: [],
        skills: [],
        metadata: {},
      );
      expect(p.tools, isEmpty);
      expect(p.mcpServers, isEmpty);
      expect(p.skills, isEmpty);
      expect(p.metadata, isEmpty);
      final j = p.toJson();
      expect(j['tools'], isEmpty);
      expect(j['mcp_servers'], isEmpty);
      expect(j['skills'], isEmpty);
      expect(j['metadata'], isEmpty);
    });

    test('UpdateVaultParams', () {
      const p = UpdateVaultParams(metadata: {});
      expect(p.metadata, isEmpty);
      expect(p.toJson()['metadata'], isEmpty);
    });

    test('UpdateMemoryStoreParams', () {
      const p = UpdateMemoryStoreParams(metadata: {});
      expect(p.metadata, isEmpty);
      expect(p.toJson()['metadata'], isEmpty);
    });

    test('UpdateCredentialParams', () {
      const p = UpdateCredentialParams(metadata: {});
      expect(p.metadata, isEmpty);
      expect(p.toJson()['metadata'], isEmpty);
    });

    // Note: UpdateUserProfileRequest is also hardened with the same `.cast`
    // fix, but its constructor asserts `metadata is Map<String, String>`, so
    // the untyped-`{}` input is rejected at construction in debug/test mode
    // (the `.cast` guard only matters in release, where asserts are stripped) —
    // it can't be exercised the same way here.
  });
}
