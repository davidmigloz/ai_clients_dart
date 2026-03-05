/// The detail level for file input processing.
///
/// Note: This is distinct from [ImageDetail] which includes additional values.
enum FileInputDetail {
  /// Unknown detail level (fallback for unrecognized values).
  unknown('unknown'),

  /// High detail processing.
  high('high'),

  /// Low detail processing.
  low('low');

  /// The JSON value for this detail level.
  final String value;

  const FileInputDetail(this.value);

  /// Creates a [FileInputDetail] from a JSON value.
  factory FileInputDetail.fromJson(String json) {
    return FileInputDetail.values.firstWhere(
      (e) => e.value == json,
      orElse: () => FileInputDetail.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
