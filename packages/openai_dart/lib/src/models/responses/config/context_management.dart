import 'package:meta/meta.dart';

/// Context management configuration for responses requests.
@immutable
class ContextManagement {
  /// Entry type. Currently `compaction`.
  final String type;

  /// Token threshold at which compaction should be triggered.
  final int? compactThreshold;

  /// Creates a [ContextManagement].
  const ContextManagement({required this.type, this.compactThreshold});

  /// Creates a compaction configuration entry.
  const ContextManagement.compaction({this.compactThreshold})
    : type = 'compaction';

  /// Creates a [ContextManagement] from JSON.
  factory ContextManagement.fromJson(Map<String, dynamic> json) {
    return ContextManagement(
      type: json['type'] as String,
      compactThreshold: json['compact_threshold'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (compactThreshold != null) 'compact_threshold': compactThreshold,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextManagement &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          compactThreshold == other.compactThreshold;

  @override
  int get hashCode => Object.hash(type, compactThreshold);

  @override
  String toString() =>
      'ContextManagement(type: $type, compactThreshold: $compactThreshold)';
}
