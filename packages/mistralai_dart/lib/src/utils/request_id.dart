import 'dart:math';

/// Generates a unique request ID.
///
/// Format: `mistral-{timestamp}-{random}`
String generateRequestId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
  return 'mistral-$timestamp-$random';
}
