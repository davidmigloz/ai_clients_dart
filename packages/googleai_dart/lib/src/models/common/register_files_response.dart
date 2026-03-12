import '../copy_with_sentinel.dart';
import '../files/file.dart';

/// Response from registering files.
class RegisterFilesResponse {
  /// Optional. The registered files.
  final List<File>? files;

  /// Creates a [RegisterFilesResponse].
  const RegisterFilesResponse({this.files});

  /// Creates a [RegisterFilesResponse] from JSON.
  factory RegisterFilesResponse.fromJson(Map<String, dynamic> json) =>
      RegisterFilesResponse(
        files: (json['files'] as List?)
            ?.map((e) => File.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (files != null) 'files': files!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  RegisterFilesResponse copyWith({Object? files = unsetCopyWithValue}) {
    return RegisterFilesResponse(
      files: files == unsetCopyWithValue ? this.files : files as List<File>?,
    );
  }

  @override
  String toString() => 'RegisterFilesResponse(files: $files)';
}
