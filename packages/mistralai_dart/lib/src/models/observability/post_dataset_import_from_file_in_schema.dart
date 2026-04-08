import 'package:meta/meta.dart';

/// Request to import dataset records from a file.
@immutable
class PostDatasetImportFromFileInSchema {
  /// The file ID to import from.
  final String fileId;

  /// Creates a [PostDatasetImportFromFileInSchema].
  const PostDatasetImportFromFileInSchema({required this.fileId});

  /// Creates a [PostDatasetImportFromFileInSchema] from JSON.
  factory PostDatasetImportFromFileInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PostDatasetImportFromFileInSchema(
    fileId: json['file_id'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'file_id': fileId};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetImportFromFileInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return fileId == other.fileId;
  }

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'PostDatasetImportFromFileInSchema(fileId: $fileId)';
}
