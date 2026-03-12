import '../copy_with_sentinel.dart';

/// Request to register files.
class RegisterFilesRequest {
  /// Required. The URIs of the files to register.
  final List<String> uris;

  /// Creates a [RegisterFilesRequest].
  const RegisterFilesRequest({required this.uris});

  /// Creates a [RegisterFilesRequest] from JSON.
  factory RegisterFilesRequest.fromJson(Map<String, dynamic> json) =>
      RegisterFilesRequest(
        uris: (json['uris'] as List).map((e) => e as String).toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'uris': uris};

  /// Creates a copy with replaced values.
  RegisterFilesRequest copyWith({Object? uris = unsetCopyWithValue}) {
    return RegisterFilesRequest(
      uris: uris == unsetCopyWithValue ? this.uris : uris! as List<String>,
    );
  }

  @override
  String toString() => 'RegisterFilesRequest(uris: $uris)';
}
