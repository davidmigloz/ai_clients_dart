import 'package:meta/meta.dart';

/// Selection of pages to process in an OCR request.
///
/// The OCR API accepts pages either as:
/// - [OcrPagesList]: an explicit list of 0-indexed page numbers, or
/// - [OcrPagesString]: a string of comma-separated numbers and ranges
///   (e.g. `'0,1,2'`, `'0-5'`, or `'0,2-4'`).
///
/// ## Example
///
/// ```dart
/// // Explicit page numbers
/// final list = OcrPages.list([0, 1, 2]);
///
/// // Comma-separated numbers and ranges
/// final range = OcrPages.string('0,2-4');
/// ```
@immutable
sealed class OcrPages {
  const OcrPages();

  /// Creates [OcrPages] from JSON.
  ///
  /// Accepts either a [String] or a [List] of integers.
  ///
  /// Throws a [FormatException] if the value is neither, or if a list element
  /// is not an integer.
  factory OcrPages.fromJson(Object json) {
    if (json is String) return OcrPagesString(json);
    if (json is List) {
      return OcrPagesList(
        json.map((e) {
          if (e is int) return e;
          throw FormatException(
            'Expected int in pages list, got ${e.runtimeType}',
          );
        }).toList(),
      );
    }
    throw FormatException(
      'Expected String or List<int> for OcrPages, got ${json.runtimeType}',
    );
  }

  /// Creates pages from a comma-separated string of numbers and ranges.
  const factory OcrPages.string(String value) = OcrPagesString;

  /// Creates pages from an explicit list of 0-indexed page numbers.
  const factory OcrPages.list(List<int> values) = OcrPagesList;

  /// Converts to the JSON format expected by the API.
  Object toJson();
}

/// A comma-separated string of page numbers and ranges (e.g. `'0,2-4'`).
@immutable
class OcrPagesString extends OcrPages {
  /// Creates an [OcrPagesString].
  const OcrPagesString(this.value);

  /// The comma-separated page selection (numbers and ranges).
  final String value;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrPagesString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'OcrPagesString($value)';
}

/// An explicit list of 0-indexed page numbers.
@immutable
class OcrPagesList extends OcrPages {
  /// Creates an [OcrPagesList].
  const OcrPagesList(this.values);

  /// The 0-indexed page numbers to process.
  final List<int> values;

  @override
  Object toJson() => values;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OcrPagesList) return false;
    if (values.length != other.values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != other.values[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() => 'OcrPagesList(${values.length} pages)';
}
