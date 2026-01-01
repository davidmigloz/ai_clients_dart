// ignore_for_file: avoid_unused_constructor_parameters

import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/files/file_delete_response.dart';
import '../models/files/file_list_response.dart';
import '../models/files/file_metadata.dart';

/// Stub resource for the Files API (unsupported platforms).
///
/// This resource throws [UnsupportedError] on platforms that don't support
/// file operations (e.g., web without proper multipart support).
class FilesResource {
  /// Creates a [FilesResource].
  FilesResource({
    required Object chain,
    required Object requestBuilder,
    required http.Client httpClient,
  });

  /// Uploads a file.
  ///
  /// This method is not supported on the current platform.
  Future<FileMetadata> upload({required String filePath, String? mimeType}) {
    throw UnsupportedError(
      'File upload is not supported on this platform. '
      'Use a platform that supports dart:io.',
    );
  }

  /// Uploads a file from bytes.
  ///
  /// This method is not supported on the current platform.
  Future<FileMetadata> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    throw UnsupportedError(
      'File upload is not supported on this platform. '
      'Use a platform that supports dart:io.',
    );
  }

  /// Lists uploaded files.
  ///
  /// This method is not supported on the current platform.
  Future<FileListResponse> list({
    int? limit,
    String? beforeId,
    String? afterId,
  }) {
    throw UnsupportedError(
      'Files API is not supported on this platform. '
      'Use a platform that supports dart:io.',
    );
  }

  /// Gets metadata for a specific file.
  ///
  /// This method is not supported on the current platform.
  Future<FileMetadata> retrieve({required String fileId}) {
    throw UnsupportedError(
      'Files API is not supported on this platform. '
      'Use a platform that supports dart:io.',
    );
  }

  /// Deletes a file.
  ///
  /// This method is not supported on the current platform.
  Future<FileDeleteResponse> deleteFile({required String fileId}) {
    throw UnsupportedError(
      'Files API is not supported on this platform. '
      'Use a platform that supports dart:io.',
    );
  }

  /// Downloads file content.
  ///
  /// This method is not supported on the current platform.
  Future<Uint8List> download({required String fileId}) {
    throw UnsupportedError(
      'File download is not supported on this platform. '
      'Use a platform that supports dart:io.',
    );
  }
}
