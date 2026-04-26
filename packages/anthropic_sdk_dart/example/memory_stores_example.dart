// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Memory Stores API example (Beta).
///
/// Memory Stores let you persist named memories that can be mounted into
/// agent sessions. This example demonstrates the full lifecycle:
///
/// 1. Create a memory store
/// 2. Create memories within the store
/// 3. Update a memory with an optional precondition
/// 4. List memories (with directory-style prefix rollup)
/// 5. List memory versions
/// 6. Redact a sensitive version
/// 7. Archive and delete the store
///
/// Note: Memory Stores are a beta feature and require the
/// `anthropic-beta: managed-agents-2026-04-01` header (sent automatically by
/// the SDK).
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // 1. Create a memory store.
    print('=== Create Memory Store ===');
    final store = await client.memoryStores.create(
      CreateMemoryStoreParams(
        name: 'user-preferences',
        description: 'User-facing preferences captured across sessions.',
        metadata: const {'team': 'platform'},
      ),
    );
    print('Created store: ${store.id} (${store.name})');

    // 2. Create memories within the store.
    print('\n=== Create Memories ===');
    final notes = client.memoryStores.memories(store.id);

    final greetingMemory = await notes.create(
      const CreateMemoryParams(
        path: '/preferences/greeting.md',
        content: '# Greeting\nPrefer "Hi"',
      ),
      view: MemoryView.full,
    );
    print(
      'Created memory: ${greetingMemory.id} '
      '(${greetingMemory.path}, sha256=${greetingMemory.contentSha256})',
    );

    // 3. Update with a precondition that requires the SHA-256 to match.
    print('\n=== Update Memory (with precondition) ===');
    final updated = await notes.update(
      greetingMemory.id,
      UpdateMemoryParams(
        content: '# Greeting\nPrefer "Hello"',
        precondition: ContentSha256Precondition(
          contentSha256: greetingMemory.contentSha256,
        ),
      ),
      view: MemoryView.full,
    );
    print('Updated to version: ${updated.memoryVersionId}');

    // 4. List memories under a path prefix, rolled up to depth=1.
    print('\n=== List Memories ===');
    final memoryList = await notes.list(pathPrefix: '/preferences', depth: 1);
    for (final item in memoryList.data) {
      switch (item) {
        case Memory(:final path, :final contentSizeBytes):
          print('  memory: $path ($contentSizeBytes bytes)');
        case MemoryPrefix(:final path):
          print('  prefix: $path');
        case UnknownMemoryListItem():
          print('  unknown item');
      }
    }

    // 5. List memory versions for the store.
    print('\n=== List Memory Versions ===');
    final versions = client.memoryStores.memoryVersions(store.id);
    final versionList = await versions.list(memoryId: greetingMemory.id);
    for (final v in versionList.data) {
      print('  version ${v.id}: ${v.operation.value} at ${v.createdAt}');
    }

    // 6. Redact a memory version (removes its content while preserving the
    //    version record).
    print('\n=== Redact Memory Version ===');
    final firstVersionId = versionList.data.first.id;
    final redacted = await versions.redact(firstVersionId);
    print('Redacted version: ${redacted.id} at ${redacted.redactedAt}');

    // 7. Archive and delete the store.
    print('\n=== Archive Memory Store ===');
    final archived = await client.memoryStores.archive(store.id);
    print('Archived at: ${archived.archivedAt}');

    print('\n=== Delete Memory Store ===');
    final deleted = await client.memoryStores.delete(store.id);
    print('Deleted store: ${deleted.id}');
  } finally {
    client.close();
  }
}
