/// Quantization implementation for SPANN vector index.
///
/// Controls how vectors are compressed for storage and search performance.
enum Quantization {
  /// No quantization applied.
  none('none'),

  /// 4-bit RaBitQ with micro-search quantization.
  fourBitRabitQWithUSearch('four_bit_rabit_q_with_u_search'),

  /// Unknown or unsupported quantization value.
  unknown('unknown');

  const Quantization(this.value);

  /// The API string value.
  final String value;

  /// Creates a [Quantization] from an API string value.
  ///
  /// Returns [Quantization.unknown] for unrecognized values.
  factory Quantization.fromJson(String value) {
    return Quantization.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Quantization.unknown,
    );
  }

  /// Converts this quantization to its API string value.
  String toJson() => value;
}
