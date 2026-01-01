import 'package:meta/meta.dart';

/// Response when a file is deleted.
@immutable
class FileDeleteResponse {
  /// ID of the deleted file.
  final String id;

  /// Deleted object type. Always "file_deleted".
  final String type;

  /// Creates a [FileDeleteResponse].
  const FileDeleteResponse({required this.id, this.type = 'file_deleted'});

  /// Creates a [FileDeleteResponse] from JSON.
  factory FileDeleteResponse.fromJson(Map<String, dynamic> json) {
    return FileDeleteResponse(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'file_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  FileDeleteResponse copyWith({String? id, String? type}) {
    return FileDeleteResponse(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDeleteResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'FileDeleteResponse(id: $id, type: $type)';
}
