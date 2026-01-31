// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

/// Example demonstrating the Containers API for isolated execution environments.
///
/// The Containers API allows you to:
/// - Create isolated execution environments
/// - Upload and manage files within containers
/// - Download file content from containers
///
/// Containers are useful for running code with access to specific files
/// and dependencies in an isolated environment.
///
/// To run this example, set the OPENAI_API_KEY environment variable:
/// ```bash
/// export OPENAI_API_KEY=your-api-key
/// dart run example/containers_example.dart
/// ```
Future<void> main() async {
  // Create client from environment variables
  final client = OpenAIClient.fromEnvironment();

  try {
    await listContainersExample(client);
    await containerLifecycleExample(client);
    await containerFilesExample(client);
  } finally {
    client.close();
  }
}

/// Example: List existing containers.
Future<void> listContainersExample(OpenAIClient client) async {
  print('=== List Containers Example ===\n');

  // List all containers
  final containers = await client.containers.list();

  print('Total containers found: ${containers.data.length}');
  print('Has more: ${containers.hasMore}');
  print('');

  // Display each container
  for (final container in containers.data) {
    print('Container: ${container.id}');
    print('  Name: ${container.name}');
    print('  Status: ${container.status}');
    print('  Created: ${container.createdAtDateTime}');
    if (container.lastActiveAt != null) {
      print('  Last active: ${container.lastActiveAtDateTime}');
    }
    if (container.expiresAfter != null) {
      print(
        '  Expires after: ${container.expiresAfter!.minutes} minutes '
        '(anchor: ${container.expiresAfter!.anchor})',
      );
    }
    print('');
  }

  // Example with pagination
  if (containers.hasMore && containers.lastId != null) {
    print('Fetching next page...');
    final nextPage = await client.containers.list(
      limit: 5,
      after: containers.lastId,
    );
    print('Next page has ${nextPage.data.length} containers');
  }
  print('');
}

/// Example: Container lifecycle (create, retrieve, delete).
Future<void> containerLifecycleExample(OpenAIClient client) async {
  print('=== Container Lifecycle Example ===\n');

  // Create a container with expiration
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final container = await client.containers.create(
    CreateContainerRequest(
      name: 'example-container-$timestamp',
      expiresAfter: const ContainerExpiration(
        anchor: 'last_active_at',
        minutes: 20, // Maximum allowed
      ),
    ),
  );

  print('Created container: ${container.id}');
  print('Name: ${container.name}');
  print('Status: ${container.status}');
  print('Created at: ${container.createdAtDateTime}');
  print('');

  try {
    // Retrieve the container
    final retrieved = await client.containers.retrieve(container.id);
    print('Retrieved container: ${retrieved.id}');
    print('Name matches: ${retrieved.name == container.name}');
    print('');
  } finally {
    // Delete the container
    final deleted = await client.containers.delete(container.id);
    print('Deleted container: ${deleted.deleted}');
    print('');
  }
}

/// Example: Working with files in a container.
Future<void> containerFilesExample(OpenAIClient client) async {
  print('=== Container Files Example ===\n');

  // Create a container for file operations
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final container = await client.containers.create(
    CreateContainerRequest(name: 'files-example-$timestamp'),
  );

  print('Created container: ${container.id}');
  print('');

  try {
    // Upload a Python script
    print('Uploading files...');
    const scriptContent = '''
def greet(name):
    return f"Hello, {name}!"

if __name__ == "__main__":
    print(greet("World"))
''';

    final scriptFile = await client.containers.files.create(
      container.id,
      bytes: utf8.encode(scriptContent),
      filename: '/app/script.py',
    );
    print('Uploaded script: ${scriptFile.id}');
    print('  Path: ${scriptFile.path}');
    print('  Size: ${scriptFile.bytes} bytes');

    // Upload a config file
    const configContent = '''
{
  "name": "example-app",
  "version": "1.0.0",
  "debug": true
}
''';

    final configFile = await client.containers.files.create(
      container.id,
      bytes: utf8.encode(configContent),
      filename: '/app/config.json',
    );
    print('Uploaded config: ${configFile.id}');
    print('  Path: ${configFile.path}');
    print('  Size: ${configFile.bytes} bytes');
    print('');

    // List files in the container
    print('Listing files...');
    final files = await client.containers.files.list(container.id);
    print('Container has ${files.data.length} files:');
    for (final file in files.data) {
      print('  - ${file.path} (${file.bytes} bytes)');
    }
    print('');

    // Retrieve file metadata
    print('Retrieving file metadata...');
    final fileMetadata = await client.containers.files.retrieve(
      container.id,
      scriptFile.id,
    );
    print('File: ${fileMetadata.id}');
    print('  Container: ${fileMetadata.containerId}');
    print('  Created: ${fileMetadata.createdAtDateTime}');
    print('');

    // Download file content
    print('Downloading file content...');
    final downloadedContent = await client.containers.files.retrieveContent(
      container.id,
      scriptFile.id,
    );
    print('Downloaded ${downloadedContent.length} bytes');
    print(
      'Content matches: ${utf8.decode(downloadedContent) == scriptContent}',
    );
    print('');

    // Delete a specific file
    print('Deleting config file...');
    final fileDeleted = await client.containers.files.delete(
      container.id,
      configFile.id,
    );
    print('Deleted file: ${fileDeleted.deleted}');

    // Verify file is deleted
    final remainingFiles = await client.containers.files.list(container.id);
    print('Remaining files: ${remainingFiles.data.length}');
    print('');
  } finally {
    // Clean up the container
    final deleted = await client.containers.delete(container.id);
    print('Cleaned up container: ${deleted.deleted}');
    print('');
  }
}
