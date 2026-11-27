part of 'interactions_resource.dart';

const _maxReconnectsWithoutProgress = 3;

typedef _ContinuationCheckpoint = ({String token, String? ownerId});

String? _nonEmpty(String? value) =>
    value == null || value.isEmpty ? null : value;

Map<String, dynamic> _continuationBody(
  Map<String, dynamic> original,
  _ContinuationCheckpoint checkpoint,
) => {
  for (final entry in original.entries)
    if (entry.key != 'input' || checkpoint.ownerId == null)
      entry.key: entry.value,
  if (checkpoint.ownerId != null) 'previous_interaction_id': checkpoint.ownerId,
  'continuation_token': checkpoint.token,
};

Future<Interaction> _continueInteraction(
  Map<String, dynamic> Function() buildBody,
  Future<Interaction> Function(Map<String, dynamic>, Future<void>) send, {
  required Duration timeout,
  Future<void>? abortTrigger,
}) async {
  final abort = _ContinuationAbort(timeout, abortTrigger);
  try {
    await Future<void>.value();
    abort.check();
    final original = buildBody();
    final stored = original['store'] != false;
    final hops = <Interaction>[];
    final sentTokens = <String>{
      ?_nonEmpty(original['continuation_token'] as String?),
    };
    _ContinuationCheckpoint? next;
    while (true) {
      final checkpoint = next;
      try {
        abort.check();
        final hop = await send(
          checkpoint == null
              ? original
              : _continuationBody(original, checkpoint),
          abort.future,
        );
        hops.add(hop);
      } on Exception catch (error, trace) {
        final failure = abort.resolveFailure(error);
        if (failure is AbortedException || checkpoint == null) {
          Error.throwWithStackTrace(failure, trace);
        }
        final partial = _mergeInteractionHops(hops);
        Error.throwWithStackTrace(
          InteractionContinuationInterruptedException(
            message:
                'Automatic continuation stopped before the next hop completed.',
            cause: failure,
            stackTrace: trace,
            partialInteraction: partial,
            continuationToken: checkpoint.token,
            interactionId: checkpoint.ownerId,
            continuationIds: partial.continuationIds ?? const [],
          ),
          trace,
        );
      }
      final hop = hops.last;
      final token = _nonEmpty(hop.continuationToken);
      final ownerId = stored ? _nonEmpty(hop.id) : null;
      if (hop.status != InteractionStatus.requiresContinuation ||
          token == null ||
          (stored && ownerId == null) ||
          !sentTokens.add(token)) {
        return _mergeInteractionHops(hops);
      }
      next = (token: token, ownerId: ownerId);
    }
  } finally {
    abort.close();
  }
}

Stream<InteractionEvent> _continueInteractionStream(
  Map<String, dynamic> Function() buildBody,
  Stream<InteractionEvent> Function(Map<String, dynamic>, Future<void>) send, {
  required Duration timeout,
  Future<void>? abortTrigger,
}) {
  late final StreamController<InteractionEvent> controller;
  StreamSubscription<InteractionEvent>? subscription;
  _ContinuationAbort? active;
  controller = StreamController<InteractionEvent>(
    // A listener may abort as soon as a continuation boundary arrives.
    sync: true,
    onListen: () {
      final abort = _ContinuationAbort(timeout, abortTrigger);
      active = abort;
      subscription = _runInteractionStream(buildBody, send, abort).listen(
        controller.add,
        onError: controller.addError,
        onDone: () => unawaited(controller.close()),
      );
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () {
      // Cancel the pending HTTP read before waiting for the async generator.
      active?.cancelSubscription();
      return subscription?.cancel();
    },
  );
  return controller.stream;
}

Stream<InteractionEvent> _runInteractionStream(
  Map<String, dynamic> Function() buildBody,
  Stream<InteractionEvent> Function(Map<String, dynamic>, Future<void>) send,
  _ContinuationAbort abort,
) async* {
  try {
    await Future<void>.value();
    abort.check();
    final original = buildBody();
    final stored = original['store'] != false;
    final initialToken = _nonEmpty(original['continuation_token'] as String?);
    final sentTokens = <String>{?initialToken};
    final ids = <String>{};
    var next = initialToken == null
        ? null
        : (token: initialToken, ownerId: null as String?);
    var retriesWithoutProgress = 0;
    (Exception, StackTrace)? lastFailure;
    while (true) {
      final hop = _InteractionStreamHop(next, stored: stored);
      (Exception, StackTrace)? failure;
      try {
        abort.check();
        await for (final event in send(
          next == null ? original : _continuationBody(original, next),
          abort.future,
        )) {
          hop.observe(event, ids);
          yield event;
        }
        // Let an abort triggered by the last event settle before another hop.
        await Future<void>.value();
        abort.check();
      } on Exception catch (error, trace) {
        final cause = abort.resolveFailure(error);
        if (cause is AbortedException) {
          Error.throwWithStackTrace(cause, trace);
        }
        failure = (cause, trace);
      }

      final checkpoint = hop.checkpoint;
      final token = checkpoint?.token;
      final canResume =
          hop.isResumable &&
          checkpoint != null &&
          (!stored || checkpoint.ownerId != null || token == initialToken);
      final freshToken = token != null && token != next?.token;
      final canRetry =
          canResume &&
          !hop.outputAfterCheckpoint &&
          (failure == null || _canReconnectInteractionStream(failure.$1));
      final knownToken = freshToken && sentTokens.contains(token);
      if (!canRetry ||
          knownToken ||
          (hop.status == InteractionStatus.requiresContinuation &&
              !freshToken)) {
        if (failure != null) {
          _throwStreamContinuationFailure(
            failure,
            canResume ? checkpoint : null,
            initialToken,
            ids,
          );
        }
        return;
      }

      if (freshToken) {
        retriesWithoutProgress = 0;
        lastFailure = null;
        sentTokens.add(token);
      } else {
        retriesWithoutProgress++;
      }
      lastFailure = failure ?? lastFailure;
      if (retriesWithoutProgress > _maxReconnectsWithoutProgress) {
        if (lastFailure != null) {
          _throwStreamContinuationFailure(
            lastFailure,
            checkpoint,
            initialToken,
            ids,
          );
        }
        return;
      }
      next = checkpoint;
    }
  } on AbortedException {
    if (!abort.subscriptionCancelled) rethrow;
  } finally {
    abort.close();
  }
}

bool _canReconnectInteractionStream(Exception error) =>
    error is http.ClientException && error is! http.RequestAbortedException;

Never _throwStreamContinuationFailure(
  (Exception, StackTrace) failure,
  _ContinuationCheckpoint? checkpoint,
  String? initialToken,
  Set<String> ids,
) {
  final (cause, trace) = failure;
  if (checkpoint == null || checkpoint.token == initialToken) {
    Error.throwWithStackTrace(cause, trace);
  }
  Error.throwWithStackTrace(
    InteractionContinuationInterruptedException(
      message:
          'Automatic streaming continuation stopped. Resume from the '
          'checkpoint only after discarding any output received after it.',
      cause: cause,
      stackTrace: trace,
      continuationToken: checkpoint.token,
      interactionId: checkpoint.ownerId,
      continuationIds: ids.toList(),
    ),
    trace,
  );
}

class _InteractionStreamHop {
  _ContinuationCheckpoint? checkpoint;
  final bool stored;
  InteractionStatus? status;
  String? interactionId;
  bool outputAfterCheckpoint = false;
  bool failed = false;

  _InteractionStreamHop(this.checkpoint, {required this.stored});

  bool get isResumable =>
      !failed &&
      (status == null ||
          status == InteractionStatus.inProgress ||
          status == InteractionStatus.requiresContinuation);

  void observe(InteractionEvent event, Set<String> ids) {
    switch (event) {
      case InteractionCreatedEvent(:final interaction):
        status = interaction.status;
        _recordId(interaction.id, ids);
        _recordToken(interaction.continuationToken);
      case InteractionStatusUpdateEvent(
        :final interactionId,
        :final status,
        :final continuationToken,
      ):
        _recordId(interactionId, ids);
        this.status = status ?? this.status;
        _recordToken(continuationToken);
      case InteractionCompletedEvent(:final interaction):
        status = interaction.status;
        _recordId(interaction.id, ids);
        // A terminal snapshot is authoritative even if it omits the token.
        if (_nonEmpty(interaction.continuationToken) == null) checkpoint = null;
        _recordToken(interaction.continuationToken);
        outputAfterCheckpoint = false;
      case ErrorEvent():
        failed = true;
        checkpoint = null;
      default:
        // Unknown events may carry output too. Replaying them is unsafe.
        outputAfterCheckpoint = true;
    }
  }

  void _recordId(String? value, Set<String> ids) {
    final id = _nonEmpty(value);
    if (id == null) return;
    interactionId = id;
    ids.add(id);
  }

  void _recordToken(String? value) {
    final token = _nonEmpty(value);
    if (token == null || token == checkpoint?.token) return;
    checkpoint = (token: token, ownerId: stored ? interactionId : null);
    outputAfterCheckpoint = false;
  }
}

class _ContinuationAbort {
  final Duration timeout;
  final Stopwatch _elapsed = Stopwatch()..start();
  final Completer<void> _abort = Completer<void>();
  late final Timer _timer;
  bool _closed = false;
  Exception? _failure;
  bool subscriptionCancelled = false;

  _ContinuationAbort(this.timeout, Future<void>? trigger) {
    _timer = Timer(timeout, _timeOut);
    if (trigger != null) {
      unawaited(
        trigger.then(
          (_) => abort(AbortionStage.beforeRequest),
          onError: (Object _, StackTrace _) {},
        ),
      );
    }
  }

  void abort(AbortionStage stage) => _stop(
    AbortedException(
      message: 'Interaction continuation aborted by user',
      correlationId: generateRequestId(),
      timestamp: DateTime.now(),
      stage: stage,
    ),
  );

  void cancelSubscription() {
    subscriptionCancelled = true;
    abort(AbortionStage.duringStream);
  }

  Future<void> get future => _abort.future;

  void check() {
    if (_elapsed.elapsed >= timeout) _timeOut();
    final current = _failure;
    if (current != null) throw current;
  }

  void _timeOut() => _stop(
    TimeoutException(
      message: 'The interaction continuation deadline elapsed',
      timeout: timeout,
      elapsed: _elapsed.elapsed,
    ),
  );

  Exception resolveFailure(Exception error) => switch (_failure) {
    final TimeoutException timeout => timeout,
    _ when error is AbortedException => error,
    final failure => failure ?? error,
  };

  void _stop(Exception error) {
    if (_closed || _failure != null) return;
    _failure = error;
    _abort.complete();
  }

  void close() {
    _closed = true;
    _timer.cancel();
  }
}

Interaction _mergeInteractionHops(List<Interaction> hops) {
  final first = hops.first;
  final last = hops.last;
  final ids = <String>{
    for (final hop in hops) ...[
      ...?hop.continuationIds?.where((id) => id.isNotEmpty),
      if (hop.id.isNotEmpty) hop.id,
    ],
  };
  if (hops.length == 1) {
    return first.copyWith(
      continuationIds: ids.toList(),
      usage: _mergeInteractionUsage(hops),
    );
  }
  return last.copyWith(
    input: first.input,
    created: first.created,
    previousInteractionId: first.previousInteractionId,
    continuationIds: ids.toList(),
    steps: <InteractionStep>[
      ...?first.steps,
      for (final hop in hops.skip(1))
        ...?hop.steps?.skipWhile((step) => step is UserInputStep),
    ],
    usage: _mergeInteractionUsage(hops),
  );
}

InteractionUsage? _mergeInteractionUsage(List<Interaction> hops) {
  const usageBreakdowns = {
    'cached_tokens_by_modality': ('modality', 'tokens'),
    'input_tokens_by_modality': ('modality', 'tokens'),
    'output_tokens_by_modality': ('modality', 'tokens'),
    'tool_use_tokens_by_modality': ('modality', 'tokens'),
    'grounding_tool_count': ('type', 'count'),
  };
  final usages = hops.map((hop) => hop.usage).nonNulls;
  if (usages.isEmpty) return null;
  final totals = <String, int>{};
  final breakdowns = <String, Map<Object?, Map<String, dynamic>>>{};
  for (final usage in usages) {
    for (final entry in usage.toJson().entries) {
      if (entry.key == 'initial_input_tokens') continue;
      final value = entry.value;
      if (value is int) {
        totals.update(entry.key, (sum) => sum + value, ifAbsent: () => value);
      } else if (value is List) {
        final keys = usageBreakdowns[entry.key];
        if (keys == null) continue;
        final (key, count) = keys;
        final sums = breakdowns.putIfAbsent(entry.key, () => {});
        for (final item in value.cast<Map<String, dynamic>>()) {
          final previous = sums[item[key]];
          final previousCount = previous?[count] as int?;
          final currentCount = item[count] as int?;
          sums[item[key]] = previous == null
              ? item
              : <String, dynamic>{
                  ...previous,
                  if (previousCount != null && currentCount != null)
                    count: previousCount + currentCount,
                };
        }
      }
    }
  }
  final first = hops.first.usage;
  return InteractionUsage.fromJson({
    ...totals,
    'initial_input_tokens':
        ?(first?.initialInputTokens ?? first?.totalInputTokens),
    for (final breakdown in breakdowns.entries)
      breakdown.key: breakdown.value.values.toList(),
  });
}
