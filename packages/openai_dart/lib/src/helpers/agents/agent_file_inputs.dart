import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../models/common/equality_helpers.dart';

/// Opens an explicitly selected portable file source once for preparation.
///
/// The application owns factory state. Preparation reads one file at a time
/// into a bounded byte buffer and cancels the source on failure or abort.
typedef AgentFileStreamSource = Stream<List<int>> Function();

/// Explicit portable data and its caller-chosen hosted destination.
///
/// Subtypes are [AgentFileInputBytes] and [AgentFileInputStream]. No local path
/// or directory selection is performed. Payload diagnostics are always private.
@immutable
sealed class AgentFileInput {
  const AgentFileInput();

  /// Snapshots caller-selected bytes and metadata.
  factory AgentFileInput.bytes({
    required List<int> bytes,
    required String filename,
    required String destination,
  }) = AgentFileInputBytes;

  /// Selects a lazy stream with a declared length for upfront byte budgeting.
  ///
  /// This is a portable input source, not a promise of constant-memory upload:
  /// preparation materializes one file at a time before calling the Files API.
  factory AgentFileInput.stream({
    required AgentFileStreamSource open,
    required int length,
    required String filename,
    required String destination,
  }) = AgentFileInputStream;

  /// Multipart filename; independent of the hosted destination.
  String get filename;

  /// Exact non-reserved absolute POSIX file path under `/workspace`.
  String get destination;

  /// Declared byte length, including zero-length files.
  int get length;

  /// Validates metadata without opening a stream or contacting an API.
  void validate() {
    if (filename.isEmpty || filename.contains(RegExp(r'[\x00\r\n]'))) {
      throw const FormatException(
        'Agent file: expected a header-safe filename.',
      );
    }
    if (!length.isFinite || length < 0) {
      throw const FormatException(
        'Agent file: expected a finite nonnegative byte length.',
      );
    }
    final parts = destination.split('/');
    if (!destination.startsWith('/workspace/') ||
        destination.contains(r'\') ||
        destination.contains('\u0000') ||
        destination.runes.length > 4096 ||
        parts
            .skip(1)
            .any((part) => part.isEmpty || part == '.' || part == '..') ||
        parts.length < 3 ||
        parts[2] == '.codex' ||
        parts[2] == '.managed-agents' ||
        parts[2].startsWith('.managed-agents-') ||
        destination == '/workspace/outputs') {
      throw const FormatException(
        'Agent file: expected a non-reserved /workspace file destination.',
      );
    }
  }

  @override
  String toString() => 'AgentFileInput([REDACTED])';
}

/// Detached immutable bytes for one selected upload.
@immutable
final class AgentFileInputBytes extends AgentFileInput {
  /// Creates an immutable snapshot; invalid byte values are never truncated.
  AgentFileInputBytes({
    required List<int> bytes,
    required this.filename,
    required this.destination,
  }) : bytes = _snapshotBytes(bytes) {
    validate();
  }

  /// Exact detached input bytes, exposed as a read-only view.
  final Uint8List bytes;
  @override
  final String filename;
  @override
  final String destination;
  @override
  int get length => bytes.length;

  /// Copies metadata or snapshots replacement bytes.
  AgentFileInputBytes copyWith({
    List<int>? bytes,
    String? filename,
    String? destination,
  }) => AgentFileInputBytes(
    bytes: bytes ?? this.bytes,
    filename: filename ?? this.filename,
    destination: destination ?? this.destination,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentFileInputBytes &&
          other.filename == filename &&
          other.destination == destination &&
          listsEqual(other.bytes, bytes);
  @override
  int get hashCode => Object.hash(filename, destination, Object.hashAll(bytes));
}

/// Lazy caller-owned stream factory plus immutable upload metadata.
@immutable
final class AgentFileInputStream extends AgentFileInput {
  /// Creates a validated selection without invoking [open].
  AgentFileInputStream({
    required this.open,
    required this.length,
    required this.filename,
    required this.destination,
  }) {
    validate();
  }

  /// Opens this selected source. Preparation invokes it only after preflight.
  final AgentFileStreamSource open;
  @override
  final int length;
  @override
  final String filename;
  @override
  final String destination;

  /// Copies metadata; omitted factory retains its application-owned identity.
  AgentFileInputStream copyWith({
    AgentFileStreamSource? open,
    int? length,
    String? filename,
    String? destination,
  }) => AgentFileInputStream(
    open: open ?? this.open,
    length: length ?? this.length,
    filename: filename ?? this.filename,
    destination: destination ?? this.destination,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentFileInputStream &&
          identical(other.open, open) &&
          other.length == length &&
          other.filename == filename &&
          other.destination == destination;
  @override
  int get hashCode =>
      Object.hash(identityHashCode(open), length, filename, destination);
}

Uint8List _snapshotBytes(List<int> bytes) {
  if (bytes.any((byte) => !byte.isFinite || byte < 0 || byte > 255)) {
    throw const FormatException('Agent file: expected unsigned byte values.');
  }
  return Uint8List.fromList(bytes).asUnmodifiableView();
}
