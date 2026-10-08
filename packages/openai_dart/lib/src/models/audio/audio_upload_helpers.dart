import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

/// Maximum file size for consent recordings and custom voice samples: 10 MiB.
const int audioUploadMaxBytes = 10 * 1024 * 1024;

/// Takes an immutable snapshot of the provided file view after size admission.
Uint8List snapshotAudioUploadBytes(Uint8List bytes, String context) {
  _validateAudioUploadBytes(bytes, context);
  return Uint8List.fromList(bytes).asUnmodifiableView();
}

/// Normalizes supported MIME metadata without retaining browser parameters.
String? normalizeAudioUploadContentType(String? contentType, String context) {
  if (contentType == null) return null;
  final String base;
  try {
    base = MediaType.parse(contentType).mimeType;
  } on FormatException {
    throw FormatException(
      '$context: expected a valid supported audio MIME type',
    );
  }
  if (!_supportedMimeTypes.contains(base)) {
    throw FormatException('$context: unsupported audio MIME type');
  }
  return base;
}

/// Resolves MIME metadata or infers it from a recognized filename extension.
String resolveAudioUploadContentType(
  String filename,
  String? contentType,
  String context,
) {
  if (contentType != null) return contentType;
  final extensionStart = filename.lastIndexOf('.');
  final extension = extensionStart < 0
      ? null
      : filename.substring(extensionStart + 1).toLowerCase();
  final inferred = _mimeExtensions[extension];
  if (inferred == null) {
    throw FormatException(
      '$context: provide a supported audio MIME type '
      'for an unrecognized filename extension',
    );
  }
  return inferred;
}

/// Checks size and MIME admission before authentication or multipart dispatch.
void validateAudioUpload(
  Uint8List bytes, {
  required String filename,
  required String? contentType,
  required String bytesContext,
  required String contentTypeContext,
}) {
  _validateAudioUploadBytes(bytes, bytesContext);
  final resolved = resolveAudioUploadContentType(
    filename,
    contentType,
    contentTypeContext,
  );
  if (!_supportedMimeTypes.contains(resolved)) {
    throw FormatException('$contentTypeContext: unsupported audio MIME type');
  }
}

void _validateAudioUploadBytes(Uint8List bytes, String context) {
  if (bytes.length > audioUploadMaxBytes) {
    throw FormatException('$context: maximum size is 10 MiB');
  }
}

const _supportedMimeTypes = {
  'audio/mpeg',
  'audio/wav',
  'audio/x-wav',
  'audio/ogg',
  'audio/aac',
  'audio/flac',
  'audio/webm',
  'audio/mp4',
};

const _mimeExtensions = {
  'mp3': 'audio/mpeg',
  'mpeg': 'audio/mpeg',
  'mpga': 'audio/mpeg',
  'wav': 'audio/wav',
  'ogg': 'audio/ogg',
  'oga': 'audio/ogg',
  'aac': 'audio/aac',
  'flac': 'audio/flac',
  'webm': 'audio/webm',
  'mp4': 'audio/mp4',
  'm4a': 'audio/mp4',
};
