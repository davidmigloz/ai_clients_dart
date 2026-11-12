import 'dart:convert';

import '../beta/config/container.dart';
import '../content/content_block.dart';
import '../messages/context_management.dart';
import '../messages/diagnostics.dart';
import '../messages/input_transformation.dart';
import '../messages/message.dart';
import '../messages/message_role.dart';
import '../metadata/stop_reason.dart';
import '../metadata/usage.dart';
import 'content_block_delta.dart';
import 'message_delta.dart';
import 'message_stream_event.dart';

/// Internal per-block state holder for accumulating streaming deltas.
class _AccumulatedContentBlock {
  _AccumulatedContentBlock(this.initialBlock);

  final ContentBlock initialBlock;

  // Type-specific buffers (only the relevant one is used per block type).
  final StringBuffer textBuffer = StringBuffer();
  final StringBuffer thinkingBuffer = StringBuffer();
  final StringBuffer inputJsonBuffer = StringBuffer();
  CompactionBlock? compaction;

  // Signature (overwrite semantics — not appended).
  String? signature;

  // Citations (appended from CitationsDelta).
  final List<Citation> citations = [];
}

/// Accumulates [MessageStreamEvent]s into a complete [Message].
///
/// Use this class to incrementally build a [Message] from streaming events:
///
/// ```dart
/// final accumulator = MessageStreamAccumulator();
/// await for (final event in stream) {
///   accumulator.add(event);
/// }
/// final message = accumulator.toMessage();
/// ```
///
/// The accumulator handles all event and delta types, including text,
/// thinking, tool use, citations, signatures, and compaction blocks.
///
/// Calling [toMessage] mid-stream returns a snapshot that is not affected
/// by further calls to [add].
class MessageStreamAccumulator {
  String? _id;
  String? _model;
  MessageRole? _role;
  Usage? _usage;
  StopReason? _stopReason;
  RefusalStopDetails? _stopDetails;
  String? _stopSequence;
  Container? _container;
  Diagnostics? _diagnostics;
  ContextManagementResult? _contextManagement;
  bool _hasContextManagement = false;
  bool _receivedStop = false;
  ErrorEvent? _streamError;
  List<InputTransformation>? _inputTransformations;
  final List<_AccumulatedContentBlock> _blocks = [];

  /// Adds a streaming event to the accumulator.
  void add(MessageStreamEvent event) {
    if (_receivedStop &&
        event is! PingEvent &&
        event is! UnknownMessageStreamEvent &&
        event is! ErrorEvent) {
      throw StateError('Message stream changed after message_stop');
    }
    switch (event) {
      case MessageStartEvent(:final message):
        if (_id != null) {
          throw StateError(
            'Message stream contained multiple message_start events',
          );
        }
        _id = message.id;
        _model = message.model;
        _role = message.role;
        _usage = message.usage;
        _container = message.container;
        _diagnostics = message.diagnostics;
        _contextManagement = message.contextManagement;
        _hasContextManagement = message.hasContextManagement;
        _inputTransformations = message.inputTransformations;
      case ContentBlockStartEvent(:final contentBlock):
        _blocks.add(_AccumulatedContentBlock(contentBlock));
      case ContentBlockDeltaEvent(:final index, :final delta):
        if (index >= 0 && index < _blocks.length) {
          _addDelta(_blocks[index], delta);
        }
      case ContentBlockStopEvent():
        break;
      case MessageDeltaEvent(
        :final delta,
        :final usage,
        :final inputTransformations,
        :final contextManagement,
        :final hasContextManagement,
      ):
        _stopReason = delta.stopReason ?? _stopReason;
        _stopDetails = delta.stopDetails ?? _stopDetails;
        _stopSequence = delta.stopSequence ?? _stopSequence;
        _container = delta.container ?? _container;
        _inputTransformations = inputTransformations ?? _inputTransformations;
        _contextManagement = contextManagement ?? _contextManagement;
        _hasContextManagement = hasContextManagement || _hasContextManagement;
        _mergeUsage(usage);
      case MessageStopEvent():
        if (_id == null) {
          throw StateError(
            'Message stream received message_stop before message_start',
          );
        }
        _receivedStop = true;
      case PingEvent():
      case UnknownMessageStreamEvent():
        break;
      case ErrorEvent():
        _streamError = event;
    }
  }

  void _addDelta(_AccumulatedContentBlock block, ContentBlockDelta delta) {
    switch (delta) {
      case TextDelta(:final text):
        block.textBuffer.write(text);
      case ThinkingDelta(:final thinking):
        block.thinkingBuffer.write(thinking);
      case InputJsonDelta(:final partialJson):
        block.inputJsonBuffer.write(partialJson);
      case SignatureDelta(:final signature):
        block.signature = signature;
      case CitationsDelta(:final citation):
        block.citations.add(citation);
      case CompactionDelta():
        if (block.initialBlock case final CompactionBlock initial) {
          final current = block.compaction ?? initial;
          block.compaction = current.copyWith(
            content: delta.content,
            encryptedContent: delta.hasEncryptedContent
                ? delta.encryptedContent
                : current.encryptedContent,
          );
        }
      case UnknownContentBlockDelta():
        break; // Unknown deltas are ignored during accumulation
    }
  }

  void _mergeUsage(MessageDeltaUsage delta) {
    final base = _usage;
    if (base == null) {
      _usage = Usage(
        inputTokens: delta.inputTokens ?? 0,
        outputTokens: delta.outputTokens,
        outputTokensDetails: delta.outputTokensDetails,
        cacheCreationInputTokens: delta.cacheCreationInputTokens,
        cacheReadInputTokens: delta.cacheReadInputTokens,
        serverToolUse: delta.serverToolUse,
        iterations: delta.iterations,
        speed: delta.speed,
      );
      return;
    }
    _usage = Usage(
      inputTokens: delta.inputTokens ?? base.inputTokens,
      outputTokens: delta.outputTokens,
      outputTokensDetails:
          delta.outputTokensDetails ?? base.outputTokensDetails,
      cacheCreationInputTokens:
          delta.cacheCreationInputTokens ?? base.cacheCreationInputTokens,
      cacheReadInputTokens:
          delta.cacheReadInputTokens ?? base.cacheReadInputTokens,
      serverToolUse: delta.serverToolUse ?? base.serverToolUse,
      iterations: delta.iterations ?? base.iterations,
      speed: delta.speed ?? base.speed,
      // Fields only in Usage (not in MessageDeltaUsage) — preserved.
      cacheCreation: base.cacheCreation,
      cacheRead: base.cacheRead,
      serviceTier: base.serviceTier,
      inferenceGeo: base.inferenceGeo,
    );
  }

  // -- Convenience getters ---------------------------------------------------

  /// The message ID from the `message_start` event.
  String? get id => _id;

  /// The model name from the `message_start` event.
  String? get model => _model;

  /// The accumulated usage statistics.
  Usage? get usage => _usage;

  /// The stop reason from the `message_delta` event.
  StopReason? get stopReason => _stopReason;

  /// Structured refusal details, only populated when
  /// [stopReason] is [StopReason.refusal].
  RefusalStopDetails? get stopDetails => _stopDetails;

  /// The stop sequence from the `message_delta` event.
  String? get stopSequence => _stopSequence;

  /// The container metadata from the `message_delta` event.
  Container? get container => _container;

  /// The input transformations, from `message_start` or a later
  /// `message_delta` (after a mid-stream server-side fallback).
  List<InputTransformation>? get inputTransformations => _inputTransformations;

  /// Returns the concatenated text from all text blocks.
  String get text {
    final buffer = StringBuffer();
    for (final block in _blocks) {
      if (block.initialBlock case final TextBlock initial) {
        buffer
          ..write(initial.text)
          ..write(block.textBuffer);
      }
    }
    return buffer.toString();
  }

  /// Returns the concatenated thinking content from all thinking blocks.
  String get thinking {
    final buffer = StringBuffer();
    for (final block in _blocks) {
      if (block.initialBlock case final ThinkingBlock initial) {
        buffer
          ..write(initial.thinking)
          ..write(block.thinkingBuffer);
      }
    }
    return buffer.toString();
  }

  /// Returns `true` if any thinking block has non-empty content.
  bool get hasThinking {
    return _blocks.any(
      (b) => switch (b.initialBlock) {
        ThinkingBlock(:final thinking) =>
          thinking.isNotEmpty || b.thinkingBuffer.isNotEmpty,
        _ => false,
      },
    );
  }

  /// Returns all accumulated text blocks.
  List<TextBlock> get textBlocks {
    return [
      for (final block in _blocks)
        if (block.initialBlock is TextBlock) _buildBlock(block) as TextBlock,
    ];
  }

  /// Returns all accumulated thinking blocks.
  List<ThinkingBlock> get thinkingBlocks {
    return [
      for (final block in _blocks)
        if (block.initialBlock is ThinkingBlock)
          _buildBlock(block) as ThinkingBlock,
    ];
  }

  /// Returns all accumulated tool use blocks.
  List<ToolUseBlock> get toolUseBlocks {
    return [
      for (final block in _blocks)
        if (block.initialBlock is ToolUseBlock)
          _buildBlock(block) as ToolUseBlock,
    ];
  }

  /// Returns `true` if any tool use block has been accumulated.
  bool get hasToolUse => _blocks.any((b) => b.initialBlock is ToolUseBlock);

  /// Returns `true` if the stop reason is [StopReason.maxTokens].
  bool get isMaxTokens => _stopReason == StopReason.maxTokens;

  /// Returns `true` if the stop reason is [StopReason.endTurn].
  bool get isEndTurn => _stopReason == StopReason.endTurn;

  /// Returns `true` if the stop reason is [StopReason.toolUse].
  bool get isToolUse => _stopReason == StopReason.toolUse;

  /// Returns `true` if the stop reason is [StopReason.refusal].
  bool get isRefusal => _stopReason == StopReason.refusal;

  /// Whether the server completed the message without an error event.
  bool get isComplete => _receivedStop && _streamError == null;

  /// Returns all accumulated content blocks.
  List<ContentBlock> get contentBlocks {
    return [for (final block in _blocks) _buildBlock(block)];
  }

  /// Returns blocks safe to replay after an interrupted stream.
  ///
  /// Include completed blocks with valid tool input and any received text.
  /// Incomplete non-text blocks and malformed tool arguments are omitted.
  List<ContentBlock> replayablePartialContent(Set<int> completedIndices) {
    final content = <ContentBlock>[];
    for (final (index, block) in _blocks.indexed) {
      final completed = completedIndices.contains(index);
      if (!completed && block.initialBlock is! TextBlock) continue;
      try {
        final decoded = _buildBlock(block, strict: true);
        if (completed || decoded is TextBlock && decoded.text.isNotEmpty) {
          content.add(decoded);
        }
      } on FormatException {
        // Incomplete tool inputs cannot be replayed.
      }
    }
    return content;
  }

  // -- Building & resetting --------------------------------------------------

  /// Builds an immutable [Message] from the accumulated state.
  ///
  /// Throws [StateError] if no `message_start` event has been received
  /// (i.e. [id] or [model] is `null`), or if [usage] is `null`.
  Message toMessage() => _buildMessage(strict: false);

  Message _buildMessage({required bool strict}) {
    if (_id == null || _model == null) {
      throw StateError(
        'Cannot build Message: no message_start event received.',
      );
    }
    if (_usage == null) {
      throw StateError('Cannot build Message: no usage information available.');
    }
    return Message(
      id: _id!,
      model: _model!,
      role: _role ?? MessageRole.assistant,
      content: [
        for (final block in _blocks) _buildBlock(block, strict: strict),
      ],
      stopReason: _stopReason,
      stopDetails: _stopDetails,
      stopSequence: _stopSequence,
      usage: _usage!,
      container: _container,
      diagnostics: _diagnostics,
      contextManagement: _contextManagement,
      hasContextManagement: _hasContextManagement,
      inputTransformations: _inputTransformations,
    );
  }

  /// Builds a complete message for use as conversation history.
  ///
  /// Throws [StateError] if the stream ended before `message_stop` or sent
  /// an [ErrorEvent], or [FormatException] when tool input is malformed.
  /// Use [toMessage] to inspect a partial snapshot.
  Message toFinalMessage() {
    if (_streamError case final error?) {
      throw MessageStreamFailure(error);
    }
    if (!_receivedStop) {
      throw StateError('Message stream ended before message_stop');
    }
    return _buildMessage(strict: true);
  }

  /// Resets all accumulated state.
  void reset() {
    _id = null;
    _model = null;
    _role = null;
    _usage = null;
    _stopReason = null;
    _stopDetails = null;
    _stopSequence = null;
    _container = null;
    _diagnostics = null;
    _contextManagement = null;
    _hasContextManagement = false;
    _receivedStop = false;
    _streamError = null;
    _inputTransformations = null;
    _blocks.clear();
  }

  // -- Internals -------------------------------------------------------------

  ContentBlock _buildBlock(
    _AccumulatedContentBlock acc, {
    bool strict = false,
  }) {
    final initial = acc.initialBlock;
    return switch (initial) {
      TextBlock() => initial.copyWith(
        text: '${initial.text}${acc.textBuffer}',
        citations: acc.citations.isEmpty
            ? initial.citations
            : [...?initial.citations, ...acc.citations],
      ),
      ThinkingBlock() => initial.copyWith(
        thinking: '${initial.thinking}${acc.thinkingBuffer}',
        signature: acc.signature ?? initial.signature,
      ),
      ToolUseBlock() => initial.copyWith(
        input: _toolInput(acc.inputJsonBuffer, initial.input, strict: strict),
      ),
      ServerToolUseBlock() => initial.copyWith(
        input: _toolInput(acc.inputJsonBuffer, initial.input, strict: strict),
      ),
      MCPToolUseBlock() => initial.copyWith(
        input: _toolInput(acc.inputJsonBuffer, initial.input, strict: strict),
      ),
      CompactionBlock() => acc.compaction ?? initial,
      _ => initial,
    };
  }

  static Map<String, dynamic> _toolInput(
    StringBuffer buffer,
    Map<String, dynamic> initial, {
    required bool strict,
  }) {
    if (buffer.isEmpty) return initial;
    try {
      final json = jsonDecode(buffer.toString());
      if (json is Map<String, dynamic>) return json;
      throw const FormatException('Expected a JSON object for tool input');
    } on FormatException {
      if (strict) throw const FormatException('Malformed tool input in stream');
      return const {};
    }
  }
}
