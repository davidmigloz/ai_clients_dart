// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:convert' show utf8;
import 'dart:io' as io;
import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

/// Integration tests for FileSearchStores operations.
///
/// These tests require a real API key set in the GEMINI_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  String? apiKey;
  GoogleAIClient? client;
  String? storeName;

  setUpAll(() {
    final key = io.Platform.environment['GEMINI_API_KEY'];
    apiKey = (key != null && key.isNotEmpty) ? key : null;
    if (apiKey == null) {
      print(
        '  GEMINI_API_KEY not set. Integration tests will be skipped.\n'
        '   To run these tests, export GEMINI_API_KEY=your_api_key',
      );
    } else {
      client = GoogleAIClient(
        config: GoogleAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() async {
    // Clean up: force-delete cascades to documents and chunks
    if (storeName != null && client != null) {
      try {
        await client!.fileSearchStores.delete(name: storeName!, force: true);
        print('Cleaned up file search store: $storeName');
      } catch (e) {
        print('Failed to clean up store: $e');
      }
    }
    client?.close();
  });

  group('FileSearchStores - Integration', () {
    test('creates a file search store', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final store = await client!.fileSearchStores.create(
        displayName: 'Dart SDK Integration Test Store',
      );

      storeName = store.name;

      expect(store, isNotNull);
      expect(store.name, isNotEmpty);
      expect(store.displayName, equals('Dart SDK Integration Test Store'));
      expect(store.createTime, isNotNull);

      print('Created store: ${store.name}');
    });

    test('lists file search stores', () async {
      if (apiKey == null || storeName == null) {
        markTestSkipped('API key or store not available');
        return;
      }

      final response = await client!.fileSearchStores.list(pageSize: 10);

      expect(response, isNotNull);
      expect(response.fileSearchStores, isNotNull);
      expect(response.fileSearchStores, isNotEmpty);

      print('Listed ${response.fileSearchStores!.length} stores');
    });

    test('gets file search store', () async {
      if (apiKey == null || storeName == null) {
        markTestSkipped('API key or store not available');
        return;
      }

      final store = await client!.fileSearchStores.get(name: storeName!);

      expect(store, isNotNull);
      expect(store.name, equals(storeName));
      expect(store.displayName, equals('Dart SDK Integration Test Store'));

      print('Retrieved store: ${store.name}');
    });

    test('uploads a file to the store', () async {
      if (apiKey == null || storeName == null) {
        markTestSkipped('API key or store not available');
        return;
      }

      const content =
          'Dart is a client-optimized language for fast apps '
          'on any platform. It is developed by Google and used to build '
          'mobile, desktop, server, and web applications.';
      final bytes = utf8.encode(content);

      final response = await client!.fileSearchStores.upload(
        parent: storeName!,
        bytes: bytes,
        fileName: 'test_document.txt',
        mimeType: 'text/plain',
        request: const UploadToFileSearchStoreRequest(
          displayName: 'Test Document',
        ),
      );

      expect(response, isNotNull);
      print('Upload response: $response');
    });

    test('lists documents in the store', () async {
      if (apiKey == null || storeName == null) {
        markTestSkipped('API key or store not available');
        return;
      }

      // Documents may take time to process after upload
      final response = await client!.fileSearchStores.listDocuments(
        parent: storeName!,
        pageSize: 10,
      );

      expect(response, isNotNull);
      print('Listed ${response.documents?.length ?? 0} documents');
    });

    test('deletes the file search store', () async {
      if (apiKey == null || storeName == null) {
        markTestSkipped('API key or store not available');
        return;
      }

      // Force-delete cascades to documents and chunks
      await client!.fileSearchStores.delete(name: storeName!, force: true);
      print('Deleted store: $storeName');

      // Verify deletion
      try {
        await client!.fileSearchStores.get(name: storeName!);
        fail('Expected store to be deleted');
      } catch (e) {
        expect(e, isA<GoogleAIException>());
        print('Confirmed deletion: Store not found');
      }

      // Clear so tearDownAll doesn't try again
      storeName = null;
    });
  });
}
