import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';

/// Stop sequences for completions.
///
/// Can be a single string or a list of strings where the
/// model will stop generating further tokens.
///
/// ## Example
///
/// ```dart
/// // Single stop sequence
/// final stop = StopSequence.single('\n');
///
/// // Multiple stop sequences
/// final stop = StopSequence.multiple(['\n', 'END', '###']);
/// ```
sealed class StopSequence {
  const StopSequence();

  /// Creates a single stop sequence.
  const factory StopSequence.single(String stop) = StopSequenceSingle;

  /// Creates multiple stop sequences.
  const factory StopSequence.multiple(List<String> stops) =
      StopSequenceMultiple;

  /// Creates from JSON.
  factory StopSequence.fromJson(Object json) {
    if (json is String) {
      return StopSequenceSingle(json);
    }
    if (json is List) {
      return StopSequenceMultiple(json.cast<String>());
    }
    throw FormatException('Invalid StopSequence: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// A single stop sequence.
@immutable
class StopSequenceSingle extends StopSequence {
  /// Creates a [StopSequenceSingle].
  const StopSequenceSingle(this.stop);

  /// The stop sequence.
  final String stop;

  @override
  Object toJson() => stop;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopSequenceSingle &&
          runtimeType == other.runtimeType &&
          stop == other.stop;

  @override
  int get hashCode => stop.hashCode;

  @override
  String toString() => 'StopSequence.single($stop)';
}

/// Multiple stop sequences.
@immutable
class StopSequenceMultiple extends StopSequence {
  /// Creates a [StopSequenceMultiple].
  const StopSequenceMultiple(this.stops);

  /// The list of stop sequences.
  final List<String> stops;

  @override
  Object toJson() => stops;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopSequenceMultiple &&
          runtimeType == other.runtimeType &&
          listsEqual(stops, other.stops);

  @override
  int get hashCode => Object.hashAll(stops);

  @override
  String toString() => 'StopSequence.multiple($stops)';
}
