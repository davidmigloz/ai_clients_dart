import 'package:meta/meta.dart';

/// Export result for a dataset, containing the URL to download the file.
@immutable
class DatasetExport {
  /// URL of the exported file.
  final String fileUrl;

  /// Creates a [DatasetExport].
  const DatasetExport({required this.fileUrl});

  /// Creates a [DatasetExport] from JSON.
  factory DatasetExport.fromJson(Map<String, dynamic> json) =>
      DatasetExport(fileUrl: json['file_url'] as String? ?? '');

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'file_url': fileUrl};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DatasetExport) return false;
    if (runtimeType != other.runtimeType) return false;
    return fileUrl == other.fileUrl;
  }

  @override
  int get hashCode => fileUrl.hashCode;

  @override
  String toString() => 'DatasetExport(fileUrl: $fileUrl)';
}
