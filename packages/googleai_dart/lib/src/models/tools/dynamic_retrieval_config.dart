import '../copy_with_sentinel.dart';
import 'dynamic_retrieval_mode.dart';

/// Describes the options to customize dynamic retrieval.
class DynamicRetrievalConfig {
  /// The mode of the predictor to be used in dynamic retrieval.
  ///
  /// - [DynamicRetrievalMode.unspecified]: Always trigger retrieval.
  /// - [DynamicRetrievalMode.dynamic_]: Run retrieval only when system decides
  ///   it is necessary.
  final DynamicRetrievalMode? mode;

  /// The threshold to be used in dynamic retrieval.
  ///
  /// If not set, a system default value is used.
  final double? dynamicThreshold;

  /// Creates a [DynamicRetrievalConfig].
  const DynamicRetrievalConfig({this.mode, this.dynamicThreshold});

  /// Creates a [DynamicRetrievalConfig] from JSON.
  factory DynamicRetrievalConfig.fromJson(Map<String, dynamic> json) =>
      DynamicRetrievalConfig(
        mode: json['mode'] != null
            ? dynamicRetrievalModeFromString(json['mode'] as String)
            : null,
        dynamicThreshold: (json['dynamicThreshold'] as num?)?.toDouble(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (mode != null) 'mode': dynamicRetrievalModeToString(mode!),
    if (dynamicThreshold != null) 'dynamicThreshold': dynamicThreshold,
  };

  /// Creates a copy with replaced values.
  DynamicRetrievalConfig copyWith({
    Object? mode = unsetCopyWithValue,
    Object? dynamicThreshold = unsetCopyWithValue,
  }) {
    return DynamicRetrievalConfig(
      mode: mode == unsetCopyWithValue
          ? this.mode
          : mode as DynamicRetrievalMode?,
      dynamicThreshold: dynamicThreshold == unsetCopyWithValue
          ? this.dynamicThreshold
          : dynamicThreshold as double?,
    );
  }

  @override
  String toString() =>
      'DynamicRetrievalConfig(mode: $mode, dynamicThreshold: $dynamicThreshold)';
}
