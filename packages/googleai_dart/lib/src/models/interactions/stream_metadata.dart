import '../copy_with_sentinel.dart';
import 'usage.dart';

/// Optional metadata accompanying any streamed interaction event.
class StreamMetadata {
  /// Total token usage statistics for the interaction so far.
  final InteractionUsage? totalUsage;

  /// Creates a [StreamMetadata] instance.
  const StreamMetadata({this.totalUsage});

  /// Creates a [StreamMetadata] from JSON.
  factory StreamMetadata.fromJson(Map<String, dynamic> json) => StreamMetadata(
    totalUsage: json['total_usage'] != null
        ? InteractionUsage.fromJson(json['total_usage'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (totalUsage != null) 'total_usage': totalUsage!.toJson(),
  };

  /// Creates a copy with replaced values.
  StreamMetadata copyWith({Object? totalUsage = unsetCopyWithValue}) {
    return StreamMetadata(
      totalUsage: totalUsage == unsetCopyWithValue
          ? this.totalUsage
          : totalUsage as InteractionUsage?,
    );
  }
}
