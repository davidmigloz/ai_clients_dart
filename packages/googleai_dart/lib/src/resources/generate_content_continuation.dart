part of 'models_resource.dart';

const _generateContentContinuationName = 'GenerateContent continuation';
const _maxGenerationReconnects = 3;

Map<String, dynamic> _snapshotGenerateContentRequest(
  GenerateContentRequest request,
) => jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

String? _generationToken(String? token) =>
    token == null || token.trim().isEmpty ? null : token;

bool _captureGenerationTokens(
  GenerateContentResponse response,
  Set<String> knownCheckpoints,
) {
  var discovered = false;
  for (final candidate in response.candidates ?? const <Candidate>[]) {
    final token = _generationToken(candidate.continuationToken);
    if (token != null) discovered |= knownCheckpoints.add(token);
  }
  return discovered;
}

Map<String, dynamic> _generationHopBody(
  Map<String, dynamic> original,
  String? token,
) => token == null ? original : {...original, 'continuationToken': token};

Future<GenerateContentResponse> _continueGenerateContent(
  GenerateContentRequest request,
  Future<GenerateContentResponse> Function(
    Map<String, dynamic>,
    Set<String>,
    ContinuationAbort,
  )
  send, {
  required Duration timeout,
  Future<void>? abortTrigger,
}) async {
  final abort = ContinuationAbort(
    _generateContentContinuationName,
    timeout,
    abortTrigger,
  );
  try {
    await Future<void>.value();
    abort.check();
    final original = _snapshotGenerateContentRequest(request);
    final sentTokens = {?_generationToken(request.continuationToken)};
    final knownCheckpoints = {...sentTokens};
    GenerateContentResponse? accumulated;
    String? nextToken;
    while (true) {
      abort.check();
      final hop = await abort.race(
        send(_generationHopBody(original, nextToken), knownCheckpoints, abort),
      );
      _captureGenerationTokens(hop, knownCheckpoints);
      accumulated = _mergeGenerationResponse(accumulated, hop);
      final first = hop.candidates?.firstOrNull;
      nextToken = _generationToken(first?.continuationToken);
      if (hop.promptFeedback != null ||
          !_generationCanContinue(first?.finishReason) ||
          nextToken == null ||
          !sentTokens.add(nextToken)) {
        return accumulated;
      }
    }
  } on Exception catch (error, trace) {
    Error.throwWithStackTrace(abort.resolveFailure(error), trace);
  } finally {
    abort.close();
  }
}

bool _generationCanContinue(FinishReason? reason) =>
    reason == null || reason == FinishReason.continuation;

Stream<GenerateContentResponse> _continueGenerateContentStream(
  GenerateContentRequest request,
  Stream<GenerateContentResponse> Function(
    Map<String, dynamic>,
    Set<String>,
    Future<void>,
  )
  open,
  ContinuationAbort abort,
) async* {
  try {
    await Future<void>.value();
    abort.check();
    final original = _snapshotGenerateContentRequest(request);
    var nextToken = _generationToken(request.continuationToken);
    final sentTokens = {?nextToken};
    final knownCheckpoints = {...sentTokens};
    UsageMetadata? previousUsage;
    (Exception, StackTrace)? lastFailure;
    var reconnects = 0;

    while (true) {
      final startToken = nextToken;
      final hop = _GenerationStreamHop();
      final boundary = <GenerateContentResponse>[];
      (Exception, StackTrace)? failure;
      try {
        abort.check();
        await for (final chunk in open(
          _generationHopBody(original, startToken),
          knownCheckpoints,
          abort.future,
        )) {
          hop.observe(chunk);
          final presented = chunk.usageMetadata == null
              ? chunk
              : chunk.copyWith(
                  usageMetadata: _mergeGenerationUsage(
                    previousUsage,
                    chunk.usageMetadata,
                  ),
                );
          if (boundary.isNotEmpty ||
              chunk.candidates?.firstOrNull?.finishReason ==
                  FinishReason.continuation) {
            // Keep terminal metadata visible if no safe follow-up can start.
            boundary.add(presented);
          } else {
            yield presented;
          }
        }
      } on Exception catch (error, trace) {
        failure = (abort.resolveFailure(error), trace);
      }
      // A caller can abort in response to the last event delivered above.
      await Future<void>.value();
      abort.check();

      nextToken = null;
      final checkpoint = hop.token;
      final canResume =
          !hop.hasPromptFeedback &&
          _generationCanContinue(hop.finishReason) &&
          (failure == null || _isGenerationConnectionFailure(failure.$1));
      if (canResume &&
          checkpoint != null &&
          !hop.outputAfterCheckpoint &&
          sentTokens.add(checkpoint)) {
        nextToken = checkpoint;
        reconnects = 0;
        lastFailure = null;
      } else if (canResume &&
          hop.finishReason == null &&
          !hop.sawOutput &&
          (checkpoint == null || checkpoint == startToken) &&
          startToken != null &&
          reconnects < _maxGenerationReconnects) {
        nextToken = startToken;
        reconnects++;
        lastFailure = failure ?? lastFailure;
      }

      for (final chunk in boundary) {
        abort.check();
        yield nextToken == null ? chunk : _clearGenerationBoundary(chunk);
      }
      if (nextToken == null) {
        abort.check();
        final reportedFailure =
            failure ??
            (hop.finishReason == null && !hop.hasPromptFeedback
                ? lastFailure
                : null);
        if (reportedFailure != null) {
          Error.throwWithStackTrace(reportedFailure.$1, reportedFailure.$2);
        }
        if (hop.finishReason == null &&
            !hop.hasPromptFeedback &&
            hop.outputAfterCheckpoint &&
            checkpoint != null) {
          throw const StreamException(
            message: 'The generation stream ended after its last checkpoint.',
          );
        }
        return;
      }
      previousUsage = _mergeGenerationUsage(previousUsage, hop.usage);
      // A paused or canceled listener must never cause a speculative request.
      await Future<void>.value();
      abort.check();
    }
  } on AbortedException {
    if (!abort.subscriptionCancelled) rethrow;
  } finally {
    abort.close();
  }
}

bool _isGenerationConnectionFailure(Exception error) {
  final cause = error is StreamException ? error.cause : error;
  return cause is http.ClientException &&
      cause is! http.RequestAbortedException;
}

class _GenerationStreamHop {
  String? token;
  FinishReason? finishReason;
  UsageMetadata? usage;
  bool hasPromptFeedback = false;
  bool sawOutput = false;
  bool outputAfterCheckpoint = false;

  void observe(GenerateContentResponse chunk) {
    hasPromptFeedback |= chunk.promptFeedback != null;
    usage = chunk.usageMetadata ?? usage;
    final candidates = chunk.candidates;
    final first = candidates?.firstOrNull;
    if (candidates?.any(
          (candidate) => candidate.content?.parts.isNotEmpty ?? false,
        ) ??
        false) {
      sawOutput = true;
      outputAfterCheckpoint = true;
    }
    finishReason = first?.finishReason ?? finishReason;
    final candidateToken = _generationToken(first?.continuationToken);
    if (candidateToken != null && candidateToken != token) {
      token = candidateToken;
      outputAfterCheckpoint = false;
    }
  }
}

GenerateContentResponse _clearGenerationBoundary(
  GenerateContentResponse chunk,
) {
  final candidates = chunk.candidates;
  final first = candidates?.firstOrNull;
  if (first?.finishReason != FinishReason.continuation) return chunk;
  return chunk.copyWith(
    candidates: [
      first!.copyWith(finishReason: null, finishMessage: null),
      ...candidates!.skip(1),
    ],
  );
}

GenerateContentResponse _mergeGenerationResponse(
  GenerateContentResponse? previous,
  GenerateContentResponse next,
) {
  if (previous == null) return next;
  return next.copyWith(
    candidates: _mergeGenerationCandidates(
      previous.candidates,
      next.candidates,
    ),
    promptFeedback: next.promptFeedback ?? previous.promptFeedback,
    usageMetadata: _mergeGenerationUsage(
      previous.usageMetadata,
      next.usageMetadata,
    ),
    modelVersion: next.modelVersion ?? previous.modelVersion,
    responseId: next.responseId ?? previous.responseId,
    modelStatus: next.modelStatus ?? previous.modelStatus,
  );
}

List<Candidate>? _mergeGenerationCandidates(
  List<Candidate>? previous,
  List<Candidate>? next,
) {
  if (previous == null || previous.isEmpty) return next ?? previous;
  if (next == null || next.isEmpty) {
    // A final hop can contain only usage or prompt feedback.
    return [
      for (final candidate in previous)
        candidate.copyWith(
          finishReason: null,
          finishMessage: null,
          continuationToken: null,
        ),
    ];
  }
  final candidates = <int, Candidate>{
    for (final (position, candidate) in previous.indexed)
      candidate.index ?? position:
          _generationCanContinue(candidate.finishReason) &&
              candidate.continuationToken != null
          ? candidate.copyWith(
              finishReason: null,
              finishMessage: null,
              continuationToken: null,
            )
          : candidate,
  };
  for (final (position, candidate) in next.indexed) {
    final index = candidate.index ?? position;
    final earlier = candidates[index];
    candidates[index] = earlier == null
        ? candidate
        : _mergeGenerationCandidate(earlier, candidate);
  }
  return candidates.values.toList();
}

Candidate _mergeGenerationCandidate(Candidate previous, Candidate next) {
  final previousContent = previous.content;
  final nextContent = next.content;
  return next.copyWith(
    content: previousContent != null && nextContent != null
        ? Content(
            parts: [...previousContent.parts, ...nextContent.parts],
            role: nextContent.role ?? previousContent.role,
          )
        : nextContent ?? previousContent,
    safetyRatings: _mergeGenerationSafety(
      previous.safetyRatings,
      next.safetyRatings,
    ),
    citationMetadata: _mergeGenerationCitations(
      previous.citationMetadata,
      next.citationMetadata,
    ),
    tokenCount: _sumGenerationTokens(previous.tokenCount, next.tokenCount),
    index: next.index ?? previous.index,
    avgLogprobs: next.avgLogprobs ?? previous.avgLogprobs,
    logprobsResult: _mergeGenerationLogprobs(
      previous.logprobsResult,
      next.logprobsResult,
    ),
    groundingMetadata: _mergeGenerationGrounding(
      previous.groundingMetadata,
      next.groundingMetadata,
      previousContent?.parts.length ?? 0,
    ),
    groundingAttributions: _appendGenerationLists(
      previous.groundingAttributions,
      next.groundingAttributions,
    ),
    urlContextMetadata: _mergeGenerationUrlContext(
      previous.urlContextMetadata,
      next.urlContextMetadata,
    ),
  );
}

UsageMetadata? _mergeGenerationUsage(
  UsageMetadata? previous,
  UsageMetadata? next,
) {
  if (previous == null || next == null) return next ?? previous;
  return UsageMetadata(
    promptTokenCount: _sumGenerationTokens(
      previous.promptTokenCount,
      next.promptTokenCount,
    ),
    initialPromptTokenCount:
        previous.initialPromptTokenCount ?? next.initialPromptTokenCount,
    candidatesTokenCount: _sumGenerationTokens(
      previous.candidatesTokenCount,
      next.candidatesTokenCount,
    ),
    totalTokenCount: _sumGenerationTokens(
      previous.totalTokenCount,
      next.totalTokenCount,
    ),
    cachedContentTokenCount: _sumGenerationTokens(
      previous.cachedContentTokenCount,
      next.cachedContentTokenCount,
    ),
    thoughtsTokenCount: _sumGenerationTokens(
      previous.thoughtsTokenCount,
      next.thoughtsTokenCount,
    ),
    toolUsePromptTokenCount: _sumGenerationTokens(
      previous.toolUsePromptTokenCount,
      next.toolUsePromptTokenCount,
    ),
    cacheTokensDetails: _mergeGenerationModality(
      previous.cacheTokensDetails,
      next.cacheTokensDetails,
    ),
    candidatesTokensDetails: _mergeGenerationModality(
      previous.candidatesTokensDetails,
      next.candidatesTokensDetails,
    ),
    promptTokensDetails: _mergeGenerationModality(
      previous.promptTokensDetails,
      next.promptTokensDetails,
    ),
    toolUsePromptTokensDetails: _mergeGenerationModality(
      previous.toolUsePromptTokensDetails,
      next.toolUsePromptTokensDetails,
    ),
    serviceTier: next.serviceTier ?? previous.serviceTier,
  );
}

int? _sumGenerationTokens(int? previous, int? next) =>
    previous == null || next == null ? next ?? previous : previous + next;

List<ModalityTokenCount>? _mergeGenerationModality(
  List<ModalityTokenCount>? previous,
  List<ModalityTokenCount>? next,
) {
  if (previous == null || next == null) return next ?? previous;
  final counts = <String?, int>{};
  for (final item in [...previous, ...next]) {
    final count = item.tokenCount ?? 0;
    counts.update(
      item.modality,
      (previous) => previous + count,
      ifAbsent: () => count,
    );
  }
  return [
    for (final entry in counts.entries)
      ModalityTokenCount(modality: entry.key, tokenCount: entry.value),
  ];
}

List<T>? _appendGenerationLists<T>(List<T>? previous, List<T>? next) =>
    previous == null || next == null
    ? next ?? previous
    : [...previous, ...next];

Map<String, dynamic>? _mergeGenerationUrlContext(
  Map<String, dynamic>? previous,
  Map<String, dynamic>? next,
) {
  if (previous == null || next == null) return next ?? previous;
  final previousUrls = previous['urlMetadata'];
  final nextUrls = next['urlMetadata'];
  return {
    ...previous,
    ...next,
    if (previousUrls is List<Object?> && nextUrls is List<Object?>)
      'urlMetadata': [...previousUrls, ...nextUrls],
  };
}

List<SafetyRating>? _mergeGenerationSafety(
  List<SafetyRating>? previous,
  List<SafetyRating>? next,
) {
  if (previous == null || next == null) return next ?? previous;
  return {
    for (final rating in [...previous, ...next]) rating.category: rating,
  }.values.toList();
}

CitationMetadata? _mergeGenerationCitations(
  CitationMetadata? previous,
  CitationMetadata? next,
) => previous == null || next == null
    ? next ?? previous
    : CitationMetadata(
        citationSources: _appendGenerationLists(
          previous.citationSources,
          next.citationSources,
        ),
      );

LogprobsResult? _mergeGenerationLogprobs(
  LogprobsResult? previous,
  LogprobsResult? next,
) => previous == null || next == null
    ? next ?? previous
    : LogprobsResult(
        topCandidates: _appendGenerationLists(
          previous.topCandidates,
          next.topCandidates,
        ),
        chosenCandidates: _appendGenerationLists(
          previous.chosenCandidates,
          next.chosenCandidates,
        ),
      );

GroundingMetadata? _mergeGenerationGrounding(
  GroundingMetadata? previous,
  GroundingMetadata? next,
  int partOffset,
) {
  if (next == null) return previous;
  final chunkOffset = previous?.groundingChunks?.length ?? 0;
  final shifted = next.groundingSupports?.map((support) {
    final segment = support.segment;
    return support.copyWith(
      segment: segment == null || partOffset == 0
          ? segment
          : segment.copyWith(partIndex: (segment.partIndex ?? 0) + partOffset),
      groundingChunkIndices: support.groundingChunkIndices
          ?.map((index) => index + chunkOffset)
          .toList(),
      renderedParts: support.renderedParts
          ?.map((index) => index + partOffset)
          .toList(),
    );
  }).toList();
  return next.copyWith(
    searchEntryPoint: next.searchEntryPoint ?? previous?.searchEntryPoint,
    groundingChunks: _appendGenerationLists(
      previous?.groundingChunks,
      next.groundingChunks,
    ),
    groundingSupports: _appendGenerationLists(
      previous?.groundingSupports,
      shifted,
    ),
    retrievalMetadata: next.retrievalMetadata ?? previous?.retrievalMetadata,
    webSearchQueries: _appendGenerationLists(
      previous?.webSearchQueries,
      next.webSearchQueries,
    ),
    googleMapsWidgetContextToken:
        next.googleMapsWidgetContextToken ??
        previous?.googleMapsWidgetContextToken,
    imageSearchQueries: _appendGenerationLists(
      previous?.imageSearchQueries,
      next.imageSearchQueries,
    ),
  );
}
