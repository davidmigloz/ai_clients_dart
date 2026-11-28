part of 'environments.dart';

/// A page of directory entries or the metadata of a single environment file.
class GetEnvironmentFilesResponse {
  /// Entries within the directory, or one entry for a requested file.
  final List<EnvironmentFile>? files;

  /// Pagination token for listing a directory.
  final String? nextPageToken;

  /// Creates an environment file listing.
  const GetEnvironmentFilesResponse({this.files, this.nextPageToken});

  /// Parses a response from JSON.
  factory GetEnvironmentFilesResponse.fromJson(Map<String, dynamic> json) =>
      GetEnvironmentFilesResponse(
        files: (json['files'] as List<dynamic>?)
            ?.map(
              (entry) =>
                  EnvironmentFile.fromJson(entry as Map<String, dynamic>),
            )
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts the file listing to JSON.
  Map<String, dynamic> toJson() => {
    'files': ?files?.map((entry) => entry.toJson()).toList(),
    'next_page_token': ?nextPageToken,
  };

  /// Creates a copy with replaced values.
  GetEnvironmentFilesResponse copyWith({
    Object? files = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) => GetEnvironmentFilesResponse(
    files: files == unsetCopyWithValue
        ? this.files
        : files as List<EnvironmentFile>?,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );
}
