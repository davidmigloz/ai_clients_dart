import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A single file to upload as part of a skill or skill version.
///
/// All files that make up a Skill must share one top-level directory that
/// contains a `SKILL.md` file (e.g. `my-skill/SKILL.md`). [path] is that
/// file's path relative to the upload root, including the top-level
/// directory name (e.g. `my-skill/SKILL.md` or `my-skill/scripts/run.py`).
@immutable
class SkillFile {
  /// Path of this file relative to the upload root, including the top-level
  /// skill directory (e.g. `my-skill/SKILL.md`).
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

  @override
  int get hashCode => Object.hash(path, listHash(bytes), mimeType);

  @override
  String toString() =>
      'SkillFile(path: $path, bytes: ${bytes.length} bytes, '
      'mimeType: $mimeType)';
}
