import 'dart:math';
import 'dart:typed_data';

/// Utility methods for the OpenAI Realtime API client.
class RealtimeUtils {
  /// Default model for OpenAI Realtime API.
  static const defaultModel = 'gpt-4o-realtime-preview';

  /// Concatenates two [Uint8List] instances into a single list.
  static Uint8List mergeUint8Lists(Uint8List left, Uint8List right) {
    final result = Uint8List(left.length + right.length)
      ..setRange(0, left.length, left)
      ..setRange(left.length, left.length + right.length, right);
    return result;
  }

  /// Generates a random alphanumeric ID with the given [prefix] and [length].
  static String generateId({String prefix = 'evt_', int length = 21}) {
    const chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final random = Random();
    final str = List.generate(
      length - prefix.length,
      (_) => chars[random.nextInt(chars.length)],
    ).join('');
    return '$prefix$str';
  }
}
