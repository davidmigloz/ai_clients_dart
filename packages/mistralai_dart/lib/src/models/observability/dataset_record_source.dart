/// Source of a dataset record.
enum DatasetRecordSource {
  /// From the event explorer.
  explorer('EXPLORER'),

  /// From an uploaded file.
  uploadedFile('UPLOADED_FILE'),

  /// From direct input.
  directInput('DIRECT_INPUT'),

  /// From the playground.
  playground('PLAYGROUND'),

  /// Unknown source (forward-compatible fallback).
  unknown('UNKNOWN');

  const DatasetRecordSource(this.value);

  /// The string value of this source.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [DatasetRecordSource] from a JSON value.
  static DatasetRecordSource fromJson(String? value) => fromString(value);

  /// Creates a [DatasetRecordSource] from a string value.
  static DatasetRecordSource fromString(String? value) {
    if (value == null) return DatasetRecordSource.unknown;
    return DatasetRecordSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DatasetRecordSource.unknown,
    );
  }
}
