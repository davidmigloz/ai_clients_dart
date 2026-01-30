/// Realtime API for OpenAI.
///
/// Provides WebSocket-based real-time conversations with audio streaming.
///
/// Import with prefix to avoid naming conflicts with Responses API:
/// ```dart
/// import 'package:openai_dart/openai_dart.dart';
/// import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
///
/// // Responses API event
/// final event = ResponseCreatedEvent(...);
///
/// // Realtime API event
/// final rtEvent = realtime.ResponseCreatedEvent(...);
/// ```
library;

// Models - Realtime
export 'src/models/realtime/realtime.dart';
