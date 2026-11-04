import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../models/agents/agent_file_models.dart';
import 'agent_file_inputs.dart';
import 'agent_result_artifacts.dart';

/// A local filesystem failure with explicit private path/cause access.
final class AgentFileSystemException implements Exception {
  /// Creates a failure without exposing paths or native error text in logs.
  const AgentFileSystemException({
    required this.operation,
    required this.path,
    this.cause,
  });

  /// The failed operation, for explicit inspection.
  final String operation;

  /// The explicitly selected path, omitted from automatic diagnostics.
  final String path;

  /// Original native failure, when available; never printed automatically.
  final Object? cause;

  @override
  String toString() => 'AgentFileSystemException([REDACTED])';
}

/// Explicit local sources and new destinations beneath an application root.
///
/// Uses no overwrite, directory synchronization, directory creation or automatic
/// deletion. Symlinks at/below the selected root and nonregular leaves reject.
/// System aliases above the root are resolved once. Relative selections contain
/// no empty, dot, parent, backslash or colon-bearing components. The stricter
/// colon policy also prevents Windows drive-relative/alternate-stream names.
///
/// This is not a filesystem sandbox. Public `dart:io` has no handle-level
/// inode/device metadata or atomic no-follow/open-at operation. Canonical paths,
/// size, mode, change/modify times and held-handle lengths detect ordinary
/// changes, but cannot prove identity against same-metadata replacement. Checks,
/// exclusive creation and non-truncating opening are separate operations.
/// Callers must keep the application-owned root and selected directories stable.
final class AgentFileSystem {
  AgentFileSystem._(this._originalRoot, this._root);

  final String _originalRoot;
  final String _root;

  /// Selects an existing, nonsymlink application-owned root directory.
  ///
  /// Parent aliases, such as a platform's system temporary-directory alias,
  /// may resolve above the selected root. No root directory is created.
  static Future<AgentFileSystem> open(Directory appOwnedRoot) {
    final supplied = appOwnedRoot.path;
    return _io('open_root', supplied, () async {
      if (supplied.isEmpty ||
          supplied.contains('\u0000') ||
          supplied.split(RegExp(r'[/\\]')).contains('..')) {
        throw AgentFileSystemException(operation: 'open_root', path: supplied);
      }
      final absolute = appOwnedRoot.absolute.uri.normalizePath().toFilePath();
      final original = _trimTrailingSeparators(absolute);
      if (FileSystemEntity.typeSync(original, followLinks: false) !=
          FileSystemEntityType.directory) {
        throw AgentFileSystemException(operation: 'open_root', path: supplied);
      }
      final canonical = await Directory(original).resolveSymbolicLinks();
      final selected = AgentFileSystem._(original, canonical);
      await selected._checkRoot();
      return selected;
    });
  }

  /// Captures one regular file's metadata without reading its content.
  ///
  /// The returned portable stream opens lazily and owns a read handle until
  /// completion/cancellation. Preparation's ordinary per-file byte budget still
  /// applies. The filename comes from the explicitly selected local leaf;
  /// [destination] is an independent hosted `/workspace` file path.
  Future<AgentFileInputStream> selectFile(
    String relativePath, {
    required String destination,
  }) async {
    final parts = _relativeParts(relativePath);
    final observed = await _inspectFile(relativePath, parts);
    return AgentFileInputStream(
      open: () => _read(relativePath, parts, observed),
      length: observed.info.size,
      filename: parts.last,
      destination: destination,
    );
  }

  /// Downloads one uniquely selected result artifact to a new local file.
  ///
  /// [path] is the hosted artifact path; [destination] is an explicit relative
  /// local file beneath this root. Parents must already exist. Any existing
  /// leaf, including a dangling symlink, rejects without modification.
  /// Exclusive creation is followed by a non-truncating held write handle.
  /// Failed/aborted downloads may leave a partial caller-owned file; it is never
  /// deleted automatically. A pending local write settles before handle close.
  Future<AgentSessionArtifact> downloadFile(
    AgentResultArtifacts artifacts, {
    required String path,
    required String destination,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    final headers = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    final parts = _relativeParts(destination);
    final local = await _checkedParents(destination, parts);
    final file = File(local);
    await _io('create_destination', destination, () async {
      if (FileSystemEntity.typeSync(local, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw AgentFileSystemException(
          operation: 'create_destination',
          path: destination,
        );
      }
      await file.create(exclusive: true);
    });
    var observed = await _inspectFile(destination, parts);
    if (observed.info.size != 0) {
      throw AgentFileSystemException(
        operation: 'open_destination',
        path: destination,
      );
    }
    final handle = await _io(
      'open_destination',
      destination,
      () => file.open(mode: FileMode.writeOnlyAppend),
    );
    Object? failure;
    Future<void>? pendingWrite;
    var written = 0;
    try {
      await _assertSame(destination, parts, observed, handle);
      final artifact = await artifacts.downloadTo(
        path,
        additionalHeaders: headers,
        abortTrigger: abortTrigger,
        sink: (Uint8List bytes) {
          final owned = Uint8List.fromList(bytes);
          final write = _io('write_destination', destination, () async {
            await _assertSame(destination, parts, observed, handle);
            await handle.writeFrom(owned);
            written += owned.length;
            final after = await _inspectFile(destination, parts);
            if (after.info.size != written ||
                after.info.mode != observed.info.mode ||
                await handle.length() != written) {
              throw AgentFileSystemException(
                operation: 'write_destination',
                path: destination,
              );
            }
            observed = after;
          });
          pendingWrite = write;
          return write;
        },
      );
      await _io('flush_destination', destination, handle.flush);
      await _assertSame(destination, parts, observed, handle);
      return artifact;
    } catch (error) {
      failure = error;
      rethrow;
    } finally {
      try {
        await pendingWrite;
      } catch (_) {
        // The portable downloader already observes the sink failure.
      }
      try {
        await _io('close_destination', destination, handle.close);
      } catch (_) {
        if (failure == null) rethrow;
      }
    }
  }

  Stream<List<int>> _read(
    String relative,
    List<String> parts,
    _FileObservation selected,
  ) async* {
    final before = await _inspectFile(relative, parts);
    if (!selected.matches(before)) {
      throw AgentFileSystemException(operation: 'open_source', path: relative);
    }
    final handle = await _io(
      'open_source',
      relative,
      () => File(selected.canonical).open(),
    );
    Object? failure;
    try {
      await _assertSame(relative, parts, selected, handle);
      var received = 0;
      while (received < selected.info.size) {
        final remaining = selected.info.size - received;
        final bytes = await _io(
          'read_source',
          relative,
          () => handle.read(remaining < 65536 ? remaining : 65536),
        );
        if (bytes.isEmpty) {
          throw AgentFileSystemException(
            operation: 'read_source',
            path: relative,
          );
        }
        received += bytes.length;
        yield bytes;
      }
      await _assertSame(relative, parts, selected, handle);
    } catch (error) {
      failure = error;
      rethrow;
    } finally {
      try {
        await _io('close_source', relative, handle.close);
      } catch (_) {
        if (failure == null) rethrow;
      }
    }
  }

  Future<void> _assertSame(
    String relative,
    List<String> parts,
    _FileObservation selected,
    RandomAccessFile handle,
  ) => _io('verify_file', relative, () async {
    final current = await _inspectFile(relative, parts);
    if (!selected.matches(current) ||
        await handle.length() != selected.info.size) {
      throw AgentFileSystemException(operation: 'verify_file', path: relative);
    }
  });

  Future<_FileObservation> _inspectFile(
    String relative,
    List<String> parts,
  ) => _io('inspect_file', relative, () async {
    final path = await _checkedParents(relative, parts);
    if (FileSystemEntity.typeSync(path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw AgentFileSystemException(operation: 'inspect_file', path: relative);
    }
    final canonical = await File(path).resolveSymbolicLinks();
    final info = File(path).statSync();
    if (!_samePath(canonical, path) ||
        info.type != FileSystemEntityType.file ||
        info.size < 0 ||
        FileSystemEntity.typeSync(path, followLinks: false) !=
            FileSystemEntityType.file) {
      throw AgentFileSystemException(operation: 'inspect_file', path: relative);
    }
    return _FileObservation(canonical, info);
  });

  Future<String> _checkedParents(String relative, List<String> parts) =>
      _io('inspect_parents', relative, () async {
        await _checkRoot();
        var current = _root;
        for (final part in parts.take(parts.length - 1)) {
          current = _join(current, part);
          if (FileSystemEntity.typeSync(current, followLinks: false) !=
                  FileSystemEntityType.directory ||
              !_samePath(
                await Directory(current).resolveSymbolicLinks(),
                current,
              )) {
            throw AgentFileSystemException(
              operation: 'inspect_parents',
              path: relative,
            );
          }
        }
        return _join(current, parts.last);
      });

  Future<void> _checkRoot() => _io('inspect_root', _originalRoot, () async {
    if (FileSystemEntity.typeSync(_originalRoot, followLinks: false) !=
            FileSystemEntityType.directory ||
        FileSystemEntity.typeSync(_root, followLinks: false) !=
            FileSystemEntityType.directory ||
        !_samePath(
          await Directory(_originalRoot).resolveSymbolicLinks(),
          _root,
        )) {
      throw AgentFileSystemException(
        operation: 'inspect_root',
        path: _originalRoot,
      );
    }
  });

  @override
  String toString() => 'AgentFileSystem([REDACTED])';
}

final class _FileObservation {
  const _FileObservation(this.canonical, this.info);
  final String canonical;
  final FileStat info;
  bool matches(_FileObservation other) =>
      _samePath(canonical, other.canonical) &&
      info.type == other.info.type &&
      info.size == other.info.size &&
      info.mode == other.info.mode &&
      info.modified == other.info.modified &&
      info.changed == other.info.changed;
}

List<String> _relativeParts(String path) {
  final parts = path.split('/');
  if (path.contains('\u0000') ||
      path.contains(r'\') ||
      path.contains(':') ||
      parts.any((part) => part.isEmpty || part == '.' || part == '..')) {
    throw AgentFileSystemException(operation: 'select_path', path: path);
  }
  return List.unmodifiable(parts);
}

String _trimTrailingSeparators(String path) {
  var result = path;
  while (result.endsWith(Platform.pathSeparator) &&
      result.length > 1 &&
      !RegExp(r'^[A-Za-z]:[\\/]$').hasMatch(result)) {
    result = result.substring(0, result.length - 1);
  }
  return result;
}

String _join(String parent, String child) =>
    '${parent.endsWith(Platform.pathSeparator) ? parent : '$parent${Platform.pathSeparator}'}$child';

bool _samePath(String a, String b) =>
    Platform.isWindows ? a.toLowerCase() == b.toLowerCase() : a == b;

Future<T> _io<T>(
  String operation,
  String path,
  Future<T> Function() work,
) async {
  try {
    return await work();
  } on AgentFileSystemException {
    rethrow;
  } catch (error) {
    throw AgentFileSystemException(
      operation: operation,
      path: path,
      cause: error,
    );
  }
}
