import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../client/openai_client.dart';
import '../../errors/exceptions.dart';
import '../../models/agents/agents.dart';
import '../../resources/agent_environment_files_resource.dart';
import '../../utils/diagnostic_label.dart';
import 'agent_file_abort.dart';
import 'agent_session_run.dart';

/// An awaited portable binary sink; each chunk is detached and read-only.
///
/// The caller owns sink close/flush/abort. Returning a Future applies
/// backpressure. Source cancellation does not forcibly stop callback-owned work.
typedef AgentArtifactByteSink = FutureOr<void> Function(Uint8List bytes);

/// Why an exact completed-turn artifact selection could not be made.
enum AgentArtifactSelectionFailure {
  /// No row matched the exact session, selected turn and hosted path.
  notFound,

  /// Multiple rows matched; the helper never silently chooses one.
  multiple,

  /// A unique legacy row had no usable observed content identifier.
  missingIdentifier,

  /// The actual server cursor was missing, repeated or nonadvancing.
  pagination,
}

/// Private, contextual failure to select one immutable published artifact.
@immutable
final class AgentArtifactSelectionException implements Exception {
  /// Retains explicit selection metadata, without printing it automatically.
  const AgentArtifactSelectionException({
    required this.reason,
    required this.sessionId,
    required this.turnId,
    required this.path,
  });

  /// Selection failure category, without payload-dependent messages.
  final AgentArtifactSelectionFailure reason;

  /// Explicit owning session ID.
  final String sessionId;

  /// Explicit completed-turn ID.
  final String turnId;

  /// Exact hosted path, never used as a local output destination.
  final String path;

  /// Copies selection metadata without changing any remote resource.
  AgentArtifactSelectionException copyWith({
    AgentArtifactSelectionFailure? reason,
    String? sessionId,
    String? turnId,
    String? path,
  }) => AgentArtifactSelectionException(
    reason: reason ?? this.reason,
    sessionId: sessionId ?? this.sessionId,
    turnId: turnId ?? this.turnId,
    path: path ?? this.path,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentArtifactSelectionException &&
          other.reason == reason &&
          other.sessionId == sessionId &&
          other.turnId == turnId &&
          other.path == path;
  @override
  int get hashCode => Object.hash(reason, sessionId, turnId, path);
  @override
  String toString() =>
      'AgentArtifactSelectionException(${reason.name}; [REDACTED])';
}

/// Immutable published artifacts scoped to an identified completed session turn.
///
/// Lookup compares exact session/turn/path across every page, using the actual
/// opaque last_id and no environment filter. Expired environment availability is
/// irrelevant. No tool execution, directory sync, remote deletion or automatic
/// local destination selection occurs.
final class AgentResultArtifacts {
  /// Captures a client's resource generation and the actual completed root turn.
  /// Raw and parsed run results share this contract; parsing does not change
  /// artifact identity. No session or environment lookup is performed here.
  factory AgentResultArtifacts({
    required OpenAIClient client,
    required AgentSessionRunResult result,
  }) {
    final turn = AgentSessionTurn.fromJson(result.turn.toJson());
    if (turn.status.value != 'completed' ||
        turn.subagentId != null ||
        turn.sessionId.isEmpty ||
        turn.id.isEmpty) {
      throw const FormatException(
        'Artifact lookup requires an identified completed root turn.',
      );
    }
    _validateArtifactRoutingId(turn.sessionId);
    return AgentResultArtifacts._(
      client.agents.sessions.artifacts,
      turn.sessionId,
      turn.id,
    );
  }

  AgentResultArtifacts._(this._resource, this.sessionId, this.turnId);
  final AgentSessionArtifactsResource _resource;

  /// Captured owning session ID, not printed by diagnostics.
  final String sessionId;

  /// Captured completed-turn ID, not inferred from a path or cursor.
  final String turnId;

  AgentArtifactSelectionException _failure(
    AgentArtifactSelectionFailure reason,
    String path,
  ) => AgentArtifactSelectionException(
    reason: reason,
    sessionId: sessionId,
    turnId: turnId,
    path: path,
  );

  /// Finds exactly one immutable artifact, including page-two matches.
  ///
  /// Legacy missing/null row IDs can be traversed using last_id, but a selected
  /// row must have a usable ID. Empty/nonadvancing/cyclic server cursors fail;
  /// no row ID, first_id or hosted path is substituted for missing metadata.
  Future<AgentSessionArtifact> find(
    String path, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    final headers = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    final gate = AgentFileAbortGate(abortTrigger);
    final cursors = <String>{};
    String? after;
    AgentArtifactLookupCandidate? selected;
    try {
      await Future<void>.value();
      gate.check();
      while (true) {
        gate.check();
        final signal = gate.bind();
        final AgentArtifactLookupPage page;
        try {
          page = await _resource.listForLookup(
            sessionId,
            limit: 100,
            order: AgentListOrder.asc,
            after: after,
            additionalHeaders: headers,
            abortTrigger: signal.future,
          );
        } finally {
          signal.dispose();
        }
        gate.check();
        for (final row in page.data) {
          if (row.sessionId == sessionId &&
              row.turnId == turnId &&
              row.path == path) {
            if (selected != null) {
              throw _failure(AgentArtifactSelectionFailure.multiple, path);
            }
            selected = row;
          }
        }
        if (!page.hasMore) break;
        final cursor = page.lastId;
        if (cursor == null ||
            cursor.isEmpty ||
            !_isLosslessArtifactCursor(cursor) ||
            !cursors.add(cursor)) {
          throw _failure(AgentArtifactSelectionFailure.pagination, path);
        }
        after = cursor;
      }
      if (selected == null) {
        throw _failure(AgentArtifactSelectionFailure.notFound, path);
      }
      if (selected.id == null || selected.id!.isEmpty) {
        throw _failure(AgentArtifactSelectionFailure.missingIdentifier, path);
      }
      _validateArtifactRoutingId(selected.id!);
      return selected.requireArtifact();
    } finally {
      gate.dispose();
    }
  }

  /// Downloads exact binary chunks to an explicit portable sink callback.
  ///
  /// [sink] owns its own close/flush semantics; hosted [path] never selects a
  /// local destination. Abort and sink failure end this local operation and
  /// release upstream best effort, without awaiting an idle/uncooperative source
  /// or a never-completing sink Future. Late callback failures are observed.
  Future<AgentSessionArtifact> downloadTo(
    String path, {
    required AgentArtifactByteSink sink,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    final headers = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    final selected = await find(
      path,
      additionalHeaders: headers,
      abortTrigger: abortTrigger,
    );
    final gate = AgentFileAbortGate(abortTrigger);
    try {
      // Establish cancellation before any error-producing outcome/listener is
      // created, so startup abort has exactly one observed failure Future.
      await Future<void>.value();
      gate.check();
    } catch (_) {
      gate.dispose();
      rethrow;
    }
    final signal = gate.bind();
    final outcome = Completer<AgentSessionArtifact>();
    // The cancel helper releases it immediately without awaiting an idle peer.
    // ignore: cancel_subscriptions
    StreamSubscription<Uint8List>? subscription;
    var ended = false;
    void cancel() {
      final active = subscription;
      subscription = null;
      try {
        active?.cancel().ignore();
      } catch (_) {
        /* Best-effort source release. */
      }
    }

    void fail(Object error, {bool fromSink = false}) {
      if (ended) return;
      ended = true;
      signal.dispose();
      cancel();
      final Object failure;
      if (error is AbortedException ||
          error is RequestTimeoutException ||
          (!fromSink && error is OpenAIException)) {
        markPrivateDiagnostics(error);
        failure = error;
      } else {
        failure = ConnectionException(
          message: fromSink
              ? 'Artifact byte sink failed'
              : 'Artifact byte source failed',
          cause: error,
          redactDiagnostics: true,
        );
      }
      outcome.completeError(failure, StackTrace.current);
    }

    final removeAbort = gate.listen(
      () => fail(
        const AbortedException(
          stage: AbortionStage.duringStream,
          redactDiagnostics: true,
        ),
      ),
    );
    try {
      final source = _resource.downloadStream(
        sessionId,
        selected.id,
        additionalHeaders: headers,
        abortTrigger: signal.future,
      );
      subscription = source.listen(
        (chunk) {
          if (ended) return;
          subscription?.pause();
          unawaited(
            Future<void>.sync(
              () => sink(Uint8List.fromList(chunk).asUnmodifiableView()),
            ).then((_) {
              if (!ended) subscription?.resume();
            }, onError: (Object error) => fail(error, fromSink: true)),
          );
        },
        // Optional named arguments on fail are not a Stream error-handler type.
        // ignore: unnecessary_lambdas
        onError: (Object error) => fail(error),
        onDone: () {
          if (ended) return;
          ended = true;
          subscription = null;
          outcome.complete(selected);
        },
      );
      if (ended) cancel();
      return await outcome.future;
    } finally {
      removeAbort();
      signal.dispose();
      gate.dispose();
      if (!ended) cancel();
    }
  }

  @override
  String toString() => 'AgentResultArtifacts([REDACTED])';
}

void _validateArtifactRoutingId(String id) {
  try {
    if (Uri.decodeComponent(Uri.encodeComponent(id)) == id) return;
  } on ArgumentError {
    // Report no received identifier or URI text.
  }
  throw const FormatException(
    'Artifact lookup requires a losslessly encodable identifier.',
  );
}

bool _isLosslessArtifactCursor(String cursor) {
  try {
    return Uri.decodeQueryComponent(Uri.encodeQueryComponent(cursor)) == cursor;
  } on ArgumentError {
    return false;
  }
}
