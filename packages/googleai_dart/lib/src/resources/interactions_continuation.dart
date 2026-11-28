part of 'interactions_resource.dart';

const _maxReconnectsWithoutProgress = 3;

typedef _ContinuationCheckpoint = ({String token, String? ownerId});

T _decodeInteractionResponse<T>(T Function() decode) {
  try {
    return decode();
  } on TypeError {
    throw const FormatException('Invalid Interactions response field type');
  }
}

InteractionEvent _decodeInteractionEvent(Map<String, dynamic> json) =>
    _decodeInteractionResponse(() => InteractionEvent.fromJson(json));

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
  Future<Interaction> Function(Map<String, dynamic>, ContinuationAbort) send, {
  required Duration timeout,
  Future<void>? abortTrigger,
}) async {
  final abort = ContinuationAbort(
    'Interaction continuation',
    timeout,
    abortTrigger,
  );
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
        final hop = await abort.race(
          send(
            checkpoint == null
                ? original
                : _continuationBody(original, checkpoint),
            abort,
          ),
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
  return continuationStream(
    operation: 'Interaction continuation',
    timeout: timeout,
    abortTrigger: abortTrigger,
    run: (abort) => _runInteractionStream(buildBody, send, abort),
  );
}

Stream<InteractionEvent> _runInteractionStream(
  Map<String, dynamic> Function() buildBody,
  Stream<InteractionEvent> Function(Map<String, dynamic>, Future<void>) send,
  ContinuationAbort abort,
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
          // Frames after an authoritative completion cannot add to this hop.
          // Keep a terminal error visible and let it block another request.
          if (hop.completed && event is! ErrorEvent) continue;
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
      if (failure == null &&
          canResume &&
          !hop.completed &&
          hop.outputAfterCheckpoint) {
        failure = (
          const StreamException(
            message: 'The interaction stream ended before the hop completed.',
          ),
          StackTrace.current,
        );
      }
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
  bool completed = false;
  bool statusUnrecognized = false;

  _InteractionStreamHop(this.checkpoint, {required this.stored});

  bool get isResumable =>
      !failed &&
      !statusUnrecognized &&
      (status == InteractionStatus.requiresContinuation ||
          (!completed &&
              (status == null || status == InteractionStatus.inProgress)));

  void observe(InteractionEvent event, Set<String> ids) {
    switch (event) {
      case InteractionCreatedEvent(:final interaction):
        status = interaction.status;
        statusUnrecognized = interaction.unrecognizedStatus != null;
        _recordId(interaction.id, ids);
        _recordToken(interaction.continuationToken);
      case InteractionStatusUpdateEvent(
        :final interactionId,
        :final status,
        :final unrecognizedStatus,
        :final continuationToken,
      ):
        _recordId(interactionId, ids);
        if (status != null || unrecognizedStatus != null) {
          this.status = status;
          statusUnrecognized = unrecognizedStatus != null;
        }
        _recordToken(continuationToken);
      case InteractionCompletedEvent(:final interaction):
        completed = true;
        status = interaction.status;
        statusUnrecognized = interaction.unrecognizedStatus != null;
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
    errors: hops.any((hop) => hop.errors != null)
        ? [for (final hop in hops) ...?hop.errors]
        : null,
    maxTotalTokens: hops.map((hop) => hop.maxTotalTokens).nonNulls.lastOrNull,
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
