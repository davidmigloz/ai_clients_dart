import 'package:meta/meta.dart';

/// A file that has been uploaded to OpenAI.
///
/// Files can be used for fine-tuning, assistants, batch processing, and more.
///
/// ## Example
///
/// ```dart
/// final files = await client.files.list();
///
/// for (final file in files.data) {
///   print('${file.filename}: ${file.bytes} bytes');
/// }
/// ```
@immutable
class FileObject {
  /// Creates a [FileObject].
  const FileObject({
    required this.id,
    required this.object,
    required this.bytes,
    required this.createdAt,
    required this.filename,
    required this.purpose,
    this.status,
    this.statusDetails,
  });

  /// Creates a [FileObject] from JSON.
  factory FileObject.fromJson(Map<String, dynamic> json) {
    return FileObject(
      id: json['id'] as String,
      object: json['object'] as String,
      bytes: json['bytes'] as int,
      createdAt: json['created_at'] as int,
      filename: json['filename'] as String,
      purpose: FilePurpose.fromJson(json['purpose'] as String),
      status: json['status'] != null
          ? FileStatus.fromJson(json['status'] as String)
          : null,
      statusDetails: json['status_details'] as String?,
    );
  }

  /// The file identifier.
  final String id;

  /// The object type (always "file").
  final String object;

  /// The size of the file in bytes.
  final int bytes;

  /// The Unix timestamp when the file was created.
  final int createdAt;

  /// The name of the file.
  final String filename;

  /// The intended purpose of the file.
  final FilePurpose purpose;

  /// The processing status (deprecated, but still returned).
  final FileStatus? status;

  /// Additional details about the status (if any).
  final String? statusDetails;

  /// The file creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'bytes': bytes,
    'created_at': createdAt,
    'filename': filename,
    'purpose': purpose.toJson(),
    if (status != null) 'status': status!.toJson(),
    if (statusDetails != null) 'status_details': statusDetails,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileObject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FileObject(id: $id, filename: $filename)';
}

/// A list of files.
@immutable
class FileList {
  /// Creates a [FileList].
  const FileList({required this.object, required this.data});

  /// Creates a [FileList] from JSON.
  factory FileList.fromJson(Map<String, dynamic> json) {
    return FileList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => FileObject.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of files.
  final List<FileObject> data;

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of files.
  int get length => data.length;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((f) => f.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          data.length == other.data.length;

  @override
  int get hashCode => Object.hash(object, data.length);

  @override
  String toString() => 'FileList(${data.length} files)';
}

/// The response from deleting a file.
@immutable
class DeleteFileResponse {
  /// Creates a [DeleteFileResponse].
  const DeleteFileResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteFileResponse] from JSON.
  factory DeleteFileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteFileResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted file.
  final String id;

  /// The object type (always "file").
  final String object;

  /// Whether the file was successfully deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteFileResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(id, deleted);

  @override
  String toString() => 'DeleteFileResponse(id: $id, deleted: $deleted)';
}

/// The intended purpose of a file.
enum FilePurpose {
  /// For fine-tuning.
  fineTune._('fine-tune'),

  /// For fine-tuning results.
  fineTuneResults._('fine-tune-results'),

  /// For the Assistants API.
  assistants._('assistants'),

  /// For Assistants API output.
  assistantsOutput._('assistants_output'),

  /// For batch API input.
  batch._('batch'),

  /// For batch API output.
  batchOutput._('batch_output'),

  /// For vision (deprecated).
  vision._('vision'),

  /// For evaluations.
  evals._('evals');

  const FilePurpose._(this._value);

  /// Creates from JSON string.
  factory FilePurpose.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown purpose: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// File processing status.
enum FileStatus {
  /// File is being uploaded.
  uploaded._('uploaded'),

  /// File is being processed.
  processed._('processed'),

  /// File processing resulted in an error.
  error._('error');

  const FileStatus._(this._value);

  /// Creates from JSON string.
  factory FileStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
