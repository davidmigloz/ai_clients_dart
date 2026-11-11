import 'dart:async';

import '../errors/exceptions.dart';
import '../extensions/message_extensions.dart';
import '../models/beta/config/container.dart';
import '../models/messages/input_message.dart';
import '../models/messages/message.dart';
import '../models/messages/message_create_request.dart';
import '../models/messages/message_thread_param.dart';
import '../models/metadata/stop_reason.dart';
import '../models/streaming/message_stream_accumulator.dart';
import '../models/streaming/message_stream_event.dart';
import 'messages_resource.dart';

const _threadsBeta = 'message-threads-2026-08-12';

/// Convenience methods for server-held Messages conversations.
extension MessageThreadResource on MessagesResource {
  /// Creates a local handle for a beta Messages thread.
  ///
  /// The first turn sends [request] with the full conversation. Later turns
  /// send only new messages and preserve the original request settings.
  ///
  /// Set [replayOnThreadError] to replay history once when the server reports
  /// that a continuation cannot use its previous response ID. Replay can
  /// resend earlier messages to the API. By default, these errors reach the
  /// caller and no replay is attempted.
  MessageThread createThread(
    MessageCreateRequest request, {
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
    bool replayOnThreadError = false,
  }) {
    ensureNotClosed?.call();
    if (request.thread != null || request.compaction != null) {
      throw ArgumentError(
        'createThread requires a request without thread or compaction',
      );
    }
    final configuredBetas = requestBuilder.buildHeaders()['anthropic-beta'];
    return MessageThread._(
      resource: this,
      request: request,
      betas: {
        if (betas.isEmpty)
          ...?configuredBetas
              ?.split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty),
        ...betas,
        _threadsBeta,
      }.toList(growable: false),
      userProfileId: userProfileId,
      workspaceId: workspaceId,
      replayOnThreadError: replayOnThreadError,
    );
  }
}

/// Local state for a server-held Messages conversation (beta).
///
/// Use [MessageThreadResource.createThread] to construct this handle. Read
/// streams to completion before starting a new turn. A stream that ends early
/// invalidates [previousMessageId] and retains the received conversation so
/// the next turn can start a new thread.
final class MessageThread {
  MessageThread._({
    required this._resource,
    required MessageCreateRequest request,
    required this._betas,
    required this._userProfileId,
    required this._workspaceId,
    required this._replayOnThreadError,
    List<InputMessage> history = const [],
  }) : _request = request.copyWith(messages: const []),
       _history = List.of(history),
       _staged = List.of(request.messages),
       _container = request.container;

  final MessagesResource _resource;
  final MessageCreateRequest _request;
  final List<String> _betas;
  final String? _userProfileId;
  final String? _workspaceId;
  final bool _replayOnThreadError;
  List<InputMessage> _history;
  final List<InputMessage> _staged;
  _ThreadTurn? _activeTurn;
  _ThreadTurn? _interruptedTurn;
  String? _previousMessageId;
  Message? _lastMessage;
  ContainerParam? _container;

  /// Completed response ID available for a continuation, if any.
  String? get previousMessageId => _previousMessageId;

  /// Most recent completed reply kept in the conversation.
  Message? get lastMessage => _lastMessage;

  /// Conversation history and messages staged for the next turn.
  List<InputMessage> get messages =>
      List.unmodifiable([..._history, ..._staged]);

  /// Request settings and the full local conversation.
  MessageCreateRequest get params =>
      _request.copyWith(messages: messages, container: _container);

  /// Adds messages to the next turn without making a request.
  void append(Iterable<InputMessage> messages) {
    _ensureIdle();
    _staged.addAll(messages);
  }

  /// Copies the conversation into a handle that starts a new server thread.
  MessageThread fork() {
    _ensureIdle();
    return MessageThread._(
      resource: _resource,
      request: _request.copyWith(messages: _staged, container: _container),
      betas: _betas,
      userProfileId: _userProfileId,
      workspaceId: _workspaceId,
      replayOnThreadError: _replayOnThreadError,
      history: _history,
    );
  }

  /// Sends a turn and records the response.
  ///
  /// Call with no new messages to resume a paused response or retry the
  /// previous turn after an interrupted stream.
  Future<Message> send({
    List<InputMessage> messages = const [],
    Future<void>? abortTrigger,
  }) async {
    final turn = _beginTurn(messages);
    try {
      Message reply;
      try {
        reply = await _create(_turnRequest(turn), abortTrigger);
      } on ApiException catch (error) {
        if (!_canReplay(turn, error)) rethrow;
        _previousMessageId = null;
        reply = await _create(_turnRequest(turn, replay: true), abortTrigger);
      }
      _recordReply(turn, reply);
      return reply;
    } finally {
      _finishTurn(turn);
    }
  }

  /// Streams a turn. The turn starts when the stream is listened to.
  Stream<MessageStreamEvent> stream({
    List<InputMessage> messages = const [],
    Future<void>? abortTrigger,
  }) {
    final staged = List<InputMessage>.unmodifiable(messages);
    final listenerAbort = Completer<void>();
    StreamSubscription<MessageStreamEvent>? subscription;
    var listenerCanceled = false;
    late final StreamController<MessageStreamEvent> controller;
    controller = StreamController(
      onListen: () {
        final trigger = abortTrigger == null
            ? listenerAbort.future
            : Future.any([listenerAbort.future, abortTrigger]);
        subscription = _stream(staged, trigger).listen(
          controller.add,
          onError: (Object error, StackTrace stackTrace) {
            if (!listenerCanceled) controller.addError(error, stackTrace);
          },
          onDone: () => unawaited(controller.close()),
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        listenerCanceled = true;
        if (!listenerAbort.isCompleted) listenerAbort.complete();
        try {
          await subscription?.cancel();
        } on AbortedException {
          // Canceling the listener deliberately aborts the underlying request.
        }
      },
    );
    return controller.stream;
  }

  Stream<MessageStreamEvent> _stream(
    List<InputMessage> messages,
    Future<void>? abortTrigger,
  ) async* {
    final turn = _beginTurn(messages);
    final accumulator = MessageStreamAccumulator();
    final completedBlocks = <int>{};
    var replayed = false;
    var completed = false;
    try {
      while (true) {
        try {
          final stream = _resource.createStream(
            _turnRequest(turn, replay: replayed),
            betas: _betas,
            userProfileId: _userProfileId,
            workspaceId: _workspaceId,
            abortTrigger: abortTrigger,
          );
          await for (final event in stream) {
            accumulator.add(event);
            if (event case ContentBlockStopEvent(:final index)) {
              completedBlocks.add(index);
            }
            if (event is MessageStopEvent && !completed) {
              completed = true;
              try {
                _recordReply(turn, accumulator.toFinalMessage());
              } catch (_) {
                _markInterrupted(turn);
                rethrow;
              } finally {
                _finishTurn(turn);
              }
            }
            yield event;
            if (event is ErrorEvent) break;
          }
          break;
        } on ApiException catch (error) {
          if (replayed || accumulator.id != null || !_canReplay(turn, error)) {
            rethrow;
          }
          _previousMessageId = null;
          replayed = true;
        }
      }
    } finally {
      try {
        if (!completed && accumulator.id != null) {
          _recordPartial(
            turn,
            accumulator.toMessage().copyWith(
              content: accumulator.replayablePartialContent(completedBlocks),
            ),
          );
        }
      } finally {
        _finishTurn(turn);
      }
    }
  }

  Future<Message> _create(MessageCreateRequest request, Future<void>? abort) =>
      _resource.create(
        request,
        betas: _betas,
        userProfileId: _userProfileId,
        workspaceId: _workspaceId,
        abortTrigger: abort,
      );

  void _ensureIdle() {
    if (_activeTurn != null) {
      throw StateError('A Messages thread turn is already in progress');
    }
  }

  _ThreadTurn _beginTurn(List<InputMessage> messages) {
    _ensureIdle();
    final interrupted = _interruptedTurn;
    final turn = messages.isEmpty && _staged.isEmpty && interrupted != null
        ? _ThreadTurn(interrupted.history, interrupted.inputs, null)
        : _ThreadTurn(_history, [..._staged, ...messages], _previousMessageId);
    _activeTurn = turn;
    return turn;
  }

  void _finishTurn(_ThreadTurn turn) {
    if (identical(_activeTurn, turn)) _activeTurn = null;
  }

  MessageCreateRequest _turnRequest(_ThreadTurn turn, {bool replay = false}) {
    final previousId = turn.previousMessageId;
    if (previousId != null && !replay) {
      return _request.copyWith(
        messages: turn.inputs,
        system: null,
        tools: null,
        thread: MessageThreadParam.continueFrom(previousId),
        container: _container,
      );
    }
    return _request.copyWith(
      messages: [
        for (final message in turn.history)
          InputMessage.fromJson(_withoutCacheControl(message.toJson())),
        ...turn.inputs,
      ],
      thread: const MessageThreadParam.create(),
      container: _container,
    );
  }

  bool _canReplay(_ThreadTurn turn, ApiException error) =>
      _replayOnThreadError &&
      turn.previousMessageId != null &&
      switch ((error.statusCode, error.errorCode)) {
        (404, 'thread_not_found') ||
        (
          400,
          'thread_already_continued' || 'thread_continue_in_flight',
        ) => true,
        _ => false,
      };

  void _recordReply(_ThreadTurn turn, Message reply) {
    if (reply.stopReason == StopReason.refusal) {
      _dropRefusedTurn(turn);
      return;
    }
    final fellBack = reply.usage.iterations?.any(
      (iteration) => iteration.type == 'fallback_message',
    );
    final input = _replayInput(turn, reply);
    _history = [...turn.history, ...turn.inputs, input];
    _staged.clear();
    _interruptedTurn = null;
    _lastMessage = reply;
    if (reply.container case final returned?) {
      _container = switch (_container) {
        null => ContainerParam.id(returned.id),
        ContainerParamConfig(:final params) when params.id == null =>
          ContainerParam.config(params.copyWith(id: returned.id)),
        _ => _container,
      };
    }
    _previousMessageId = fellBack == true ? null : reply.id;
  }

  void _recordPartial(_ThreadTurn turn, Message reply) {
    if (reply.stopReason == StopReason.refusal) {
      _dropRefusedTurn(turn);
      return;
    }
    InputMessage? partial;
    if (reply.content.isNotEmpty) {
      try {
        partial = reply.toInputMessage();
      } catch (_) {
        // Keep the original stream error and discard the unreplayable reply.
      }
    }
    _history = [...turn.history, ...turn.inputs, ?partial];
    _markInterrupted(turn);
  }

  InputMessage _replayInput(_ThreadTurn turn, Message reply) {
    try {
      return reply.toInputMessage();
    } catch (_) {
      _markInterrupted(turn);
      rethrow;
    }
  }

  void _markInterrupted(_ThreadTurn turn) {
    _previousMessageId = null;
    _interruptedTurn = turn;
    _staged.clear();
  }

  void _dropRefusedTurn(_ThreadTurn turn) {
    _history = turn.history;
    _interruptedTurn = null;
    _previousMessageId = null;
  }
}

class _ThreadTurn {
  const _ThreadTurn(this.history, this.inputs, this.previousMessageId);

  final List<InputMessage> history;
  final List<InputMessage> inputs;
  final String? previousMessageId;
}

Map<String, dynamic> _withoutCacheControl(Map<String, dynamic> value) {
  final copy = {...value}..remove('cache_control');
  for (final key in const [
    'content',
    'source',
    'tool',
    'definition',
    'tool_references',
  ]) {
    switch (copy[key]) {
      case final Map<String, dynamic> nested:
        copy[key] = _withoutCacheControl(nested);
      case final List<Object?> items:
        copy[key] = [
          for (final item in items)
            if (item is Map<String, dynamic>)
              _withoutCacheControl(item)
            else
              item,
        ];
    }
  }
  return copy;
}
