import 'dart:math';

/// Random number generator for request IDs.
final _random = Random();

/// Generates a unique request ID.
///
/// Format: `req_{timestamp}_{random}`
///
/// The ID includes:
/// - A prefix `req_` for easy identification
/// - A timestamp component for ordering
/// - A random component for uniqueness
///
/// ## Example
///
/// ```dart
/// final id = generateRequestId();
/// // Returns something like: req_1234567890_a1b2c3d4
/// ```
String generateRequestId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomPart = _random
      .nextInt(0xFFFFFFFF)
      .toRadixString(16)
      .padLeft(8, '0');
  return 'req_${timestamp}_$randomPart';
}

/// Generates a unique correlation ID for request tracing.
///
/// This is similar to [generateRequestId] but with a different prefix
/// to distinguish correlation IDs from request IDs.
///
/// Format: `cor_{timestamp}_{random}`
String generateCorrelationId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomPart = _random
      .nextInt(0xFFFFFFFF)
      .toRadixString(16)
      .padLeft(8, '0');
  return 'cor_${timestamp}_$randomPart';
}
