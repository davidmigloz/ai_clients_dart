/// Image detail level for multimodal inputs.
enum ImageDetail {
  /// Unknown detail level (fallback for unrecognized values).
  unknown('unknown'),

  /// Low detail - faster processing.
  low('low'),

  /// High detail - better quality analysis.
  high('high'),

  /// Automatic selection based on image size.
  auto('auto');

  /// The JSON value for this detail level.
  final String value;

  const ImageDetail(this.value);

  /// Creates an [ImageDetail] from a JSON value.
  factory ImageDetail.fromJson(String json) {
    return ImageDetail.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ImageDetail.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
