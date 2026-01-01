/// Loss function for classifier fine-tuning.
enum FTClassifierLossFunction {
  /// Single-class classification (one label per sample).
  singleClass('single_class'),

  /// Multi-class classification (multiple labels per sample).
  multiClass('multi_class');

  const FTClassifierLossFunction(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  static FTClassifierLossFunction fromString(String? value) {
    return FTClassifierLossFunction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FTClassifierLossFunction.singleClass,
    );
  }
}
