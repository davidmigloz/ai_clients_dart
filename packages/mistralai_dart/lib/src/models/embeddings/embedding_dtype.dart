/// Data type for embedding output.
///
/// Controls the format of the embedding vectors returned by the API.
/// Different dtypes offer trade-offs between precision and storage size.
enum EmbeddingDtype {
  /// Full precision floating point (default).
  float('float'),

  /// 8-bit signed integer quantization.
  int8('int8'),

  /// 8-bit unsigned integer quantization.
  uint8('uint8'),

  /// Binary quantization (1-bit per dimension).
  binary('binary'),

  /// Unsigned binary quantization.
  ubinary('ubinary');

  const EmbeddingDtype(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  ///
  /// Returns [EmbeddingDtype.float] as default if value is null or unknown.
  static EmbeddingDtype fromString(String? value) {
    if (value == null) return EmbeddingDtype.float;
    return EmbeddingDtype.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EmbeddingDtype.float,
    );
  }
}
