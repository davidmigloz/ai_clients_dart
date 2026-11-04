import 'package:meta/meta.dart';

import '../../errors/exceptions.dart';
import '../../models/agents/agents.dart';
import '../../models/common/copy_with_sentinel.dart';
import '../../models/common/equality_helpers.dart';

/// Prepared hosted references and upload IDs explicitly owned by the caller.
///
/// No file deletion is automatic. A partial failure can contain more observed
/// IDs than usable references if a successful upload could not be mapped.
@immutable
final class PreparedAgentFiles {
  /// Snapshots both collections; IDs preserve order and are never fabricated.
  PreparedAgentFiles({
    List<AgentSessionHostedEnvironmentFileConfigFileId> files = const [],
    List<String> uploadedFileIds = const [],
  }) : files = List.unmodifiable(files),
       uploadedFileIds = List.unmodifiable(uploadedFileIds) {
    for (final file in this.files) {
      file.validate();
    }
    if (this.uploadedFileIds.any((id) => id.isEmpty)) {
      throw const FormatException(
        'Prepared agent files: expected observed nonempty upload IDs.',
      );
    }
  }

  /// Validated `file_id` references for explicit hosted workspace destinations.
  final List<AgentSessionHostedEnvironmentFileConfigFileId> files;

  /// Successful upload IDs actually observed, for explicit caller cleanup.
  final List<String> uploadedFileIds;

  /// Copies and detaches replacement collections.
  PreparedAgentFiles copyWith({
    List<AgentSessionHostedEnvironmentFileConfigFileId>? files,
    List<String>? uploadedFileIds,
  }) => PreparedAgentFiles(
    files: files ?? this.files,
    uploadedFileIds: uploadedFileIds ?? this.uploadedFileIds,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreparedAgentFiles &&
          listsEqual(other.files, files) &&
          listsEqual(other.uploadedFileIds, uploadedFileIds);
  @override
  int get hashCode =>
      Object.hash(Object.hashAll(files), Object.hashAll(uploadedFileIds));
  @override
  String toString() =>
      'PreparedAgentFiles(${uploadedFileIds.length} caller-owned uploads; [REDACTED])';
}

/// A staged live file and its separately owned Files API upload.
@immutable
final class StagedAgentFile {
  /// Creates an immutable observation; staging never transfers upload ownership.
  StagedAgentFile({required this.uploadedFileId, required this.file}) {
    if (uploadedFileId.isEmpty) {
      throw const FormatException(
        'Staged agent file: expected an observed upload ID.',
      );
    }
    file.validate();
  }

  /// The caller-owned Files API upload ID.
  final String uploadedFileId;

  /// The returned mutable live environment-file view.
  final AgentEnvironmentFile file;

  /// Copies either observation without modifying any remote resource.
  StagedAgentFile copyWith({
    String? uploadedFileId,
    AgentEnvironmentFile? file,
  }) => StagedAgentFile(
    uploadedFileId: uploadedFileId ?? this.uploadedFileId,
    file: file ?? this.file,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StagedAgentFile &&
          other.uploadedFileId == uploadedFileId &&
          other.file == file;
  @override
  int get hashCode => Object.hash(uploadedFileId, file);
  @override
  String toString() => 'StagedAgentFile([REDACTED])';
}

/// Preparation/staging failed; observed successful uploads remain caller-owned.
///
/// Printable diagnostics omit bytes, names, paths, IDs and cause payloads.
/// [cause] retains explicit typed failure access, including HTTP status/errors.
@immutable
final class AgentFilePreparationException implements Exception {
  /// Snapshots the known outcome. No cleanup or upload-ID inference occurs.
  AgentFilePreparationException({
    required PreparedAgentFiles prepared,
    this.cause,
  }) : prepared = prepared.copyWith();

  /// Detached observed successful IDs and usable references at failure time.
  final PreparedAgentFiles prepared;

  /// Explicit original typed cause; never rendered by automatic diagnostics.
  final Object? cause;

  /// Whether cancellation caused this preparation to stop.
  bool get wasAborted => cause is AbortedException;

  /// Copies observations; explicit null clears the retained cause.
  AgentFilePreparationException copyWith({
    PreparedAgentFiles? prepared,
    Object? cause = unsetCopyWithValue,
  }) => AgentFilePreparationException(
    prepared: prepared ?? this.prepared,
    cause: identical(cause, unsetCopyWithValue) ? this.cause : cause,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentFilePreparationException &&
          other.prepared == prepared &&
          other.cause == cause;
  @override
  int get hashCode => Object.hash(prepared, cause);
  @override
  String toString() =>
      'AgentFilePreparationException(${prepared.uploadedFileIds.length} caller-owned uploads; [REDACTED])';
}
