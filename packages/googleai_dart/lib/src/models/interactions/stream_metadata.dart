import '../copy_with_sentinel.dart';
import 'usage.dart';

/// Optional metadata accompanying any streamed interaction event.
class StreamMetadata {
  /// Token usage statistics for the interaction so far.
  final InteractionUsage? usage;

  /// Creates a [StreamMetadata] instance.
  const StreamMetadata({this.usage});

  /// Creates a [StreamMetadata] from JSON.
  factory StreamMetadata.fromJson(Map<String, dynamic> json) => StreamMetadata(
    usage: json['usage'] != null
        ? InteractionUsage.fromJson(json['usage'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// Creates a copy with replaced values.
  StreamMetadata copyWith({Object? usage = unsetCopyWithValue}) {
    return StreamMetadata(
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as InteractionUsage?,
    );
  }
}
