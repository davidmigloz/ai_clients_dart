import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A single file to upload as part of a skill or skill version.
///
/// Include `SKILL.md` at the upload root or in one enclosing directory.
/// [path] is relative to the upload root, for example `SKILL.md` or
/// `my-skill/scripts/run.py`.
@immutable
class SkillFile {
  /// Path of this file relative to the upload root.
  final String path;

  /// Raw contents of the file.
  final Uint8List bytes;

  /// MIME type of the file. Optional; inferred by the server when omitted.
  final String? mimeType;

  /// Creates a [SkillFile].
  const SkillFile({required this.path, required this.bytes, this.mimeType});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillFile &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          listsEqual(bytes, other.bytes) &&
          mimeType == other.mimeType;

  // Hashes the byte length rather than every byte (files can be large);
  // equality above still compares the exact bytes.
  @override
  int get hashCode => Object.hash(path, bytes.length, mimeType);

  @override
  String toString() =>
      'SkillFile(path: $path, bytes: ${bytes.length} bytes, '
      'mimeType: $mimeType)';
}
