import '../platform/http_utils.dart';

/// Largest delay whose microsecond count is exact on native and web platforms.
const _maxRetryAfterMicroseconds = 9007199254740991; // 2^53 - 1.

/// Parses server retry guidance without rounding a positive delay down.
///
/// A valid `retry-after-ms` takes precedence over `retry-after`, which accepts
/// fractional seconds or a platform-supported HTTP date. Invalid millisecond
/// values fall back to the standard header. Past dates permit zero delay.
/// Delays beyond 2^53 - 1 microseconds are ignored because their microsecond
/// count cannot be represented exactly across native and web runtimes.
Duration? parseRetryAfter(Map<String, String> headers, {DateTime? now}) {
  final milliseconds = _parseNumericDelay(
    _headerValue(headers, 'retry-after-ms'),
    decimalPlaces: 3,
  );
  if (milliseconds != null) return milliseconds;

  final value = _headerValue(headers, 'retry-after')?.trim();
  if (value == null || value.isEmpty) return null;
  final seconds = _parseNumericDelay(value, decimalPlaces: 6);
  if (seconds != null) return seconds;

  try {
    final date = parseHttpDate(value);
    final current = now ?? DateTime.now();
    if (!date.isAfter(current)) return Duration.zero;
    // Bound the coarse difference before computing microseconds, which may
    // overflow on native runtimes for dates at opposite DateTime extremes.
    final milliseconds =
        date.millisecondsSinceEpoch - current.millisecondsSinceEpoch;
    if (milliseconds > _maxRetryAfterMicroseconds ~/ 1000 + 1) return null;
    final delay = date.difference(current);
    if (delay.inMicroseconds > _maxRetryAfterMicroseconds) return null;
    return delay;
  } catch (_) {
    return null;
  }
}

String? _headerValue(Map<String, String> headers, String name) {
  final value = headers[name];
  if (value != null) return value;
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == name) return entry.value;
  }
  return null;
}

final _numericDelayPattern = RegExp(
  r'^([+-]?)(?:(\d+)(?:\.(\d*))?|\.(\d+))(?:[eE]([+-]?\d+))?$',
);

Duration? _parseNumericDelay(String? value, {required int decimalPlaces}) {
  if (value == null) return null;
  final trimmed = value.trim();
  final match = _numericDelayPattern.firstMatch(trimmed);
  if (match == null) return null;

  final fraction = match[3] ?? match[4] ?? '';
  final digits = '${match[2] ?? ''}$fraction'.replaceFirst(RegExp(r'^0+'), '');
  if (digits.isEmpty) return Duration.zero;
  if (match[1] == '-') return null;

  final rawExponent = match[5] ?? '0';
  final exponent = int.tryParse(rawExponent);
  // Extremely large exponents need no powers or unbounded integer allocation.
  // A positive nonzero fraction below a microsecond still requires one tick.
  if (exponent == null) {
    return rawExponent.startsWith('-') ? const Duration(microseconds: 1) : null;
  }
  if (exponent > trimmed.length + 20) return null;
  if (exponent < -trimmed.length - 20) {
    return const Duration(microseconds: 1);
  }

  final scale = exponent + decimalPlaces - fraction.length;
  String whole;
  var roundUp = false;
  if (scale >= 0) {
    if (digits.length + scale > 16) return null;
    whole = '$digits${'0' * scale}';
  } else {
    final wholeLength = digits.length + scale;
    if (wholeLength <= 0) return const Duration(microseconds: 1);
    if (wholeLength > 16) return null;
    whole = digits.substring(0, wholeLength);
    roundUp = digits.substring(wholeLength).contains(RegExp('[1-9]'));
  }
  final microseconds = int.parse(whole) + (roundUp ? 1 : 0);
  if (microseconds > _maxRetryAfterMicroseconds) return null;
  return Duration(microseconds: microseconds);
}
