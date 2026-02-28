import 'dart:convert';

import '../beta/config/container.dart';
import '../content/content_block.dart';
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
  final StringBuffer compactionBuffer = StringBuffer();

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
  String? _stopSequence;
  Container? _container;
  final List<_AccumulatedContentBlock> _blocks = [];

  /// Adds a streaming event to the accumulator.
  void add(MessageStreamEvent event) {
    switch (event) {
      case MessageStartEvent(:final message):
        _id = message.id;
        _model = message.model;
        _role = message.role;
        _usage = message.usage;
      case ContentBlockStartEvent(:final contentBlock):
        _blocks.add(_AccumulatedContentBlock(contentBlock));
      case ContentBlockDeltaEvent(:final index, :final delta):
        if (index < _blocks.length) {
          _addDelta(_blocks[index], delta);
        }
      case ContentBlockStopEvent():
        break;
      case MessageDeltaEvent(:final delta, :final usage):
        _stopReason = delta.stopReason ?? _stopReason;
        _stopSequence = delta.stopSequence ?? _stopSequence;
        _container = delta.container ?? _container;
        _mergeUsage(usage);
      case MessageStopEvent():
        break;
      case PingEvent():
        break;
      case ErrorEvent():
        break;
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
      case CompactionDelta(:final content):
        if (content != null) block.compactionBuffer.write(content);
    }
  }

  void _mergeUsage(MessageDeltaUsage delta) {
    final base = _usage;
    if (base == null) {
      _usage = Usage(
        inputTokens: delta.inputTokens ?? 0,
        outputTokens: delta.outputTokens,
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

  /// The stop sequence from the `message_delta` event.
  String? get stopSequence => _stopSequence;

  /// The container metadata from the `message_delta` event.
  Container? get container => _container;

  /// Returns the concatenated text from all text blocks.
  String get text {
    final buffer = StringBuffer();
    for (final block in _blocks) {
      if (block.initialBlock is TextBlock) {
        buffer.write(block.textBuffer);
      }
    }
    return buffer.toString();
  }

  /// Returns the concatenated thinking content from all thinking blocks.
  String get thinking {
    final buffer = StringBuffer();
    for (final block in _blocks) {
      if (block.initialBlock is ThinkingBlock) {
        buffer.write(block.thinkingBuffer);
      }
    }
    return buffer.toString();
  }

  /// Returns `true` if any thinking block has non-empty content.
  bool get hasThinking {
    return _blocks.any(
      (b) => b.initialBlock is ThinkingBlock && b.thinkingBuffer.isNotEmpty,
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

  /// Returns all accumulated content blocks.
  List<ContentBlock> get contentBlocks {
    return [for (final block in _blocks) _buildBlock(block)];
  }

  // -- Building & resetting --------------------------------------------------

  /// Builds an immutable [Message] from the accumulated state.
  ///
  /// Throws [StateError] if no `message_start` event has been received
  /// (i.e. [id] or [model] is `null`), or if [usage] is `null`.
  Message toMessage() {
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
      content: contentBlocks,
      stopReason: _stopReason,
      stopSequence: _stopSequence,
      usage: _usage!,
      container: _container,
    );
  }

  /// Resets all accumulated state.
  void reset() {
    _id = null;
    _model = null;
    _role = null;
    _usage = null;
    _stopReason = null;
    _stopSequence = null;
    _container = null;
    _blocks.clear();
  }

  // -- Internals -------------------------------------------------------------

  ContentBlock _buildBlock(_AccumulatedContentBlock acc) {
    final initial = acc.initialBlock;
    return switch (initial) {
      TextBlock() => TextBlock(
        text: acc.textBuffer.toString(),
        citations: acc.citations.isEmpty ? null : List.of(acc.citations),
      ),
      ThinkingBlock() => ThinkingBlock(
        thinking: acc.thinkingBuffer.toString(),
        signature: acc.signature ?? '',
      ),
      ToolUseBlock() => ToolUseBlock(
        id: initial.id,
        name: initial.name,
        input: _parseJson(acc.inputJsonBuffer),
        caller: initial.caller,
      ),
      CompactionBlock() => CompactionBlock(
        content: acc.compactionBuffer.isEmpty
            ? initial.content
            : acc.compactionBuffer.toString(),
      ),
      _ => initial,
    };
  }

  static Map<String, dynamic> _parseJson(StringBuffer buffer) {
    final str = buffer.toString();
    if (str.isEmpty) return const {};
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } on FormatException {
      return const {};
    }
  }
}
