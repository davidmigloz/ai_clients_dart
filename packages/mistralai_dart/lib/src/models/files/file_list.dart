import 'package:meta/meta.dart';

import 'file_object.dart';

/// Response from listing files.
@immutable
class FileList {
  /// The object type (always "list").
  final String object;

  /// List of file objects.
  final List<FileObject> data;

  /// Total number of files.
  final int? total;

  /// Creates a [FileList].
  const FileList({required this.object, required this.data, this.total});

  /// Creates a [FileList] from JSON.
  factory FileList.fromJson(Map<String, dynamic> json) => FileList(
    object: json['object'] as String? ?? 'list',
    data:
        (json['data'] as List?)
            ?.map((e) => FileObject.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    total: json['total'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    if (total != null) 'total': total,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          total == other.total;

  @override
  int get hashCode => Object.hash(object, data, total);

  @override
  String toString() => 'FileList(count: ${data.length}, total: $total)';
}
