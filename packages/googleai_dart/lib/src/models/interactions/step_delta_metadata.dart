import '../copy_with_sentinel.dart';
import 'usage.dart';

/// Optional metadata accompanying a `step.delta` streamed event.
class StepDeltaMetadata {
  /// Total token usage statistics for the interaction so far.
  final InteractionUsage? totalUsage;

  /// Creates a [StepDeltaMetadata] instance.
  const StepDeltaMetadata({this.totalUsage});

  /// Creates a [StepDeltaMetadata] from JSON.
  factory StepDeltaMetadata.fromJson(Map<String, dynamic> json) =>
      StepDeltaMetadata(
        totalUsage: json['total_usage'] != null
            ? InteractionUsage.fromJson(
                json['total_usage'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (totalUsage != null) 'total_usage': totalUsage!.toJson(),
  };

  /// Creates a copy with replaced values.
  StepDeltaMetadata copyWith({Object? totalUsage = unsetCopyWithValue}) {
    return StepDeltaMetadata(
      totalUsage: totalUsage == unsetCopyWithValue
          ? this.totalUsage
          : totalUsage as InteractionUsage?,
    );
  }
}
