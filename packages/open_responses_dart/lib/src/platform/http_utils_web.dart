/// Web implementation that manually parses RFC 1123 HTTP dates.
///
/// Supports the preferred RFC 1123 format: "Wed, 21 Oct 2015 07:28:00 GMT"
/// Other formats (RFC 850, ANSI C) will throw [FormatException].
DateTime parseHttpDate(String value) {
  // RFC 1123 format: "Wed, 21 Oct 2015 07:28:00 GMT"
  // Example: "Mon, 15 Jan 2024 10:30:45 GMT"
  final trimmed = value.trim();

  try {
    // Try to use DateTime.parse with HTTP date format
    // RFC 1123 dates need to be converted to ISO 8601 for DateTime.parse
    final parts = trimmed.split(' ');
    if (parts.length != 6) {
      throw FormatException('Invalid HTTP date format: $value');
    }

    // parts: ["Wed,", "21", "Oct", "2015", "07:28:00", "GMT"]
    final day = int.parse(parts[1]);
    final monthStr = parts[2];
    final year = int.parse(parts[3]);
    final timeParts = parts[4].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = int.parse(timeParts[2]);

    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final month = months[monthStr];
    if (month == null) {
      throw FormatException('Invalid month in HTTP date: $monthStr');
    }

    return DateTime.utc(year, month, day, hour, minute, second);
  } catch (e) {
    if (e is FormatException) rethrow;
    throw FormatException('Invalid HTTP date format: $value');
  }
}

/// Web implementation - socket exceptions don't exist in browsers.
///
/// On web, network errors are surfaced as [http.ClientException].
bool isSocketException(Object error) => false;
