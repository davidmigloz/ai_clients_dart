// ignore_for_file: avoid_print, unused_local_variable
/// Metadata filtering examples with where and whereDocument clauses.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    // Create a collection with sample data
    final collection = await client.getOrCreateCollection(
      name: 'filtering-example',
    );

    // Add sample documents with various metadata
    await collection.add(
      ids: ['doc1', 'doc2', 'doc3', 'doc4', 'doc5', 'doc6'],
      embeddings: [
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
        [1.0, 1.0, 0.0],
        [0.0, 1.0, 1.0],
        [1.0, 0.0, 1.0],
      ],
      documents: [
        'Machine learning basics',
        'Advanced neural networks',
        'Introduction to Python programming',
        'Data science with pandas',
        'Web development fundamentals',
        'Cloud computing overview',
      ],
      metadatas: [
        {'category': 'ai', 'level': 'beginner', 'year': 2023, 'popular': true},
        {'category': 'ai', 'level': 'advanced', 'year': 2024, 'popular': true},
        {
          'category': 'programming',
          'level': 'beginner',
          'year': 2022,
          'popular': true,
        },
        {
          'category': 'data',
          'level': 'intermediate',
          'year': 2023,
          'popular': false,
        },
        {
          'category': 'web',
          'level': 'beginner',
          'year': 2021,
          'popular': false,
        },
        {
          'category': 'cloud',
          'level': 'intermediate',
          'year': 2024,
          'popular': true,
        },
      ],
    );
    print('Added 6 documents\n');

    // Equality filter
    print(r'--- Equality Filter ($eq) ---');
    final eqResults = await collection.get(
      where: {
        'category': {r'$eq': 'ai'},
      },
    );
    print('Category = "ai":');
    for (final doc in eqResults.documents ?? []) {
      print('  - $doc');
    }

    // Not equal filter
    print('\n--- Not Equal Filter (\$ne) ---');
    final neResults = await collection.get(
      where: {
        'level': {r'$ne': 'beginner'},
      },
    );
    print('Level != "beginner":');
    for (final doc in neResults.documents ?? []) {
      print('  - $doc');
    }

    // Greater than filter
    print('\n--- Greater Than Filter (\$gt) ---');
    final gtResults = await collection.get(
      where: {
        'year': {r'$gt': 2022},
      },
    );
    print('Year > 2022:');
    for (final doc in gtResults.documents ?? []) {
      print('  - $doc');
    }

    // Greater than or equal filter
    print('\n--- Greater Than or Equal Filter (\$gte) ---');
    final gteResults = await collection.get(
      where: {
        'year': {r'$gte': 2023},
      },
    );
    print('Year >= 2023:');
    for (final doc in gteResults.documents ?? []) {
      print('  - $doc');
    }

    // Less than filter
    print('\n--- Less Than Filter (\$lt) ---');
    final ltResults = await collection.get(
      where: {
        'year': {r'$lt': 2023},
      },
    );
    print('Year < 2023:');
    for (final doc in ltResults.documents ?? []) {
      print('  - $doc');
    }

    // In filter
    print('\n--- In Filter (\$in) ---');
    final inResults = await collection.get(
      where: {
        'category': {
          r'$in': ['ai', 'data'],
        },
      },
    );
    print('Category in ["ai", "data"]:');
    for (final doc in inResults.documents ?? []) {
      print('  - $doc');
    }

    // Not in filter
    print('\n--- Not In Filter (\$nin) ---');
    final ninResults = await collection.get(
      where: {
        'category': {
          r'$nin': ['ai', 'data'],
        },
      },
    );
    print('Category not in ["ai", "data"]:');
    for (final doc in ninResults.documents ?? []) {
      print('  - $doc');
    }

    // Logical AND
    print('\n--- Logical AND (\$and) ---');
    final andResults = await collection.get(
      where: {
        r'$and': [
          {
            'category': {r'$eq': 'ai'},
          },
          {
            'level': {r'$eq': 'beginner'},
          },
        ],
      },
    );
    print('Category = "ai" AND Level = "beginner":');
    for (final doc in andResults.documents ?? []) {
      print('  - $doc');
    }

    // Logical OR
    print('\n--- Logical OR (\$or) ---');
    final orResults = await collection.get(
      where: {
        r'$or': [
          {
            'category': {r'$eq': 'ai'},
          },
          {
            'category': {r'$eq': 'cloud'},
          },
        ],
      },
    );
    print('Category = "ai" OR Category = "cloud":');
    for (final doc in orResults.documents ?? []) {
      print('  - $doc');
    }

    // Boolean filter
    print('\n--- Boolean Filter ---');
    final boolResults = await collection.get(
      where: {
        'popular': {r'$eq': true},
      },
    );
    print('Popular = true:');
    for (final doc in boolResults.documents ?? []) {
      print('  - $doc');
    }

    // Document content filter - contains
    print('\n--- Document Contains Filter ---');
    final containsResults = await collection.get(
      whereDocument: {r'$contains': 'learning'},
    );
    print('Document contains "learning":');
    for (final doc in containsResults.documents ?? []) {
      print('  - $doc');
    }

    // Document content filter - not contains
    print('\n--- Document Not Contains Filter ---');
    final notContainsResults = await collection.get(
      whereDocument: {r'$not_contains': 'learning'},
    );
    print('Document does not contain "learning":');
    for (final doc in notContainsResults.documents ?? []) {
      print('  - $doc');
    }

    // Combined metadata and document filter
    print('\n--- Combined Filters ---');
    final combinedResults = await collection.get(
      where: {
        'year': {r'$gte': 2023},
      },
      whereDocument: {r'$contains': 'learning'},
    );
    print('Year >= 2023 AND contains "learning":');
    for (final doc in combinedResults.documents ?? []) {
      print('  - $doc');
    }

    // Clean up
    await client.deleteCollection(name: 'filtering-example');
  } finally {
    client.close();
  }
}
