/// Deprecated Assistants API for OpenAI.
///
/// **DEPRECATED**: The Assistants API is being phased out by OpenAI.
/// Use the Responses API instead: `import 'package:openai_dart/openai_dart.dart'`
///
/// This entry point provides access to:
/// - Assistants
/// - Threads
/// - Messages
/// - Runs
/// - Vector Stores
///
/// Usage with import prefix to avoid conflicts:
/// ```dart
/// import 'package:openai_dart/openai_dart.dart';
/// import 'package:openai_dart/openai_dart_assistants.dart' as assistants;
///
/// // Use Responses API (modern)
/// final tool = CodeInterpreterTool();
///
/// // Use Assistants API (deprecated)
/// final assistantTool = assistants.CodeInterpreterTool();
/// ```
@Deprecated(
  'Use Responses API instead. Import package:openai_dart/openai_dart.dart',
)
library;

// Models - Assistants
export 'src/models/assistants/assistants.dart';
// Models - Runs
export 'src/models/runs/runs.dart';
// Models - Threads
export 'src/models/threads/threads.dart';
// Models - Vector Stores
export 'src/models/vector_stores/vector_stores.dart';
