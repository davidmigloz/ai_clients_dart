import 'package:meta/meta.dart';

/// Reference to a training file.
@immutable
class TrainingFile {
  /// The file ID.
  final String fileId;

  /// Weight for this training file (for multi-file training).
  final double? weight;

  /// Creates a [TrainingFile].
  const TrainingFile({required this.fileId, this.weight});

  /// Creates a [TrainingFile] from JSON.
  factory TrainingFile.fromJson(Map<String, dynamic> json) => TrainingFile(
    fileId: json['file_id'] as String? ?? '',
    weight: (json['weight'] as num?)?.toDouble(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'file_id': fileId,
    if (weight != null) 'weight': weight,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingFile &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId &&
          weight == other.weight;

  @override
  int get hashCode => Object.hash(fileId, weight);

  @override
  String toString() => 'TrainingFile(fileId: $fileId, weight: $weight)';
}
