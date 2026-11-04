/// Optional VM filesystem adapter for explicitly selected Agent files.
///
/// Requires stable application-owned directories. The portable main library
/// remains usable in browsers and WebAssembly without importing `dart:io`.
library;

export 'openai_dart.dart';
export 'src/helpers/agents/agent_file_system.dart';
