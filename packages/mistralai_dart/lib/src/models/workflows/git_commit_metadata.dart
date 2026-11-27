import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Author details for a deployment build commit.
@immutable
class GitCommitAuthor {
  /// Web URL for the author.
  final String? htmlUrl;

  /// Displayed author name.
  final String? name;

  /// Username on the Git host.
  final String? username;

  /// Creates a [GitCommitAuthor].
  const GitCommitAuthor({this.htmlUrl, this.name, this.username});

  /// Creates a [GitCommitAuthor] from JSON.
  factory GitCommitAuthor.fromJson(Map<String, dynamic> json) {
    final htmlUrl = json['html_url'] as String?;
    final name = json['name'] as String?;
    final username = json['username'] as String?;
    return GitCommitAuthor(htmlUrl: htmlUrl, name: name, username: username);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (htmlUrl != null) 'html_url': htmlUrl,
    if (name != null) 'name': name,
    if (username != null) 'username': username,
  };

  /// Creates a copy with the given fields replaced.
  GitCommitAuthor copyWith({
    Object? htmlUrl = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? username = unsetCopyWithValue,
  }) => GitCommitAuthor(
    htmlUrl: htmlUrl == unsetCopyWithValue ? this.htmlUrl : htmlUrl as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    username: username == unsetCopyWithValue
        ? this.username
        : username as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitCommitAuthor &&
          htmlUrl == other.htmlUrl &&
          name == other.name &&
          username == other.username;

  @override
  int get hashCode => Object.hash(htmlUrl, name, username);

  @override
  String toString() =>
      'GitCommitAuthor(htmlUrl: $htmlUrl, name: $name, username: $username)';
}

/// Resolved commit used to build a deployment worker.
@immutable
class GitCommitMetadata {
  /// Author of the commit.
  final GitCommitAuthor? author;

  /// Web URL for the commit.
  final String? htmlUrl;

  /// Commit message.
  final String? message;

  /// Resolved commit SHA.
  final String sha;

  /// Creates a [GitCommitMetadata].
  const GitCommitMetadata({
    this.author,
    this.htmlUrl,
    this.message,
    required this.sha,
  });

  /// Creates a [GitCommitMetadata] from JSON.
  factory GitCommitMetadata.fromJson(Map<String, dynamic> json) {
    final author = json['author'] == null
        ? null
        : GitCommitAuthor.fromJson(json['author'] as Map<String, dynamic>);
    final htmlUrl = json['html_url'] as String?;
    final message = json['message'] as String?;
    final sha = json['sha'] as String?;
    if (sha == null) {
      throw const FormatException('GitCommitMetadata: missing required "sha"');
    }
    return GitCommitMetadata(
      author: author,
      htmlUrl: htmlUrl,
      message: message,
      sha: sha,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (author != null) 'author': author!.toJson(),
    if (htmlUrl != null) 'html_url': htmlUrl,
    if (message != null) 'message': message,
    'sha': sha,
  };

  /// Creates a copy with the given fields replaced.
  GitCommitMetadata copyWith({
    Object? author = unsetCopyWithValue,
    Object? htmlUrl = unsetCopyWithValue,
    Object? message = unsetCopyWithValue,
    String? sha,
  }) => GitCommitMetadata(
    author: author == unsetCopyWithValue
        ? this.author
        : author as GitCommitAuthor?,
    htmlUrl: htmlUrl == unsetCopyWithValue ? this.htmlUrl : htmlUrl as String?,
    message: message == unsetCopyWithValue ? this.message : message as String?,
    sha: sha ?? this.sha,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitCommitMetadata &&
          author == other.author &&
          htmlUrl == other.htmlUrl &&
          message == other.message &&
          sha == other.sha;

  @override
  int get hashCode => Object.hash(author, htmlUrl, message, sha);

  @override
  String toString() =>
      'GitCommitMetadata(author: $author, htmlUrl: $htmlUrl, message: $message, sha: $sha)';
}
