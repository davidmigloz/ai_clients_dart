import 'dart:math';

/// Generates a unique request ID for tracking purposes.
///
/// Format: `chroma-{timestamp}-{random}`
/// Example: `chroma-1699541234567-a1b2c3d4`
String generateRequestId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
  return 'chroma-$timestamp-$random';
}
