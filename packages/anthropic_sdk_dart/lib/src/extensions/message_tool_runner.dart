import 'dart:async';

import '../errors/exceptions.dart';
import '../models/beta/config/container.dart';
import '../models/common/equality_helpers.dart';
import '../models/content/content_block.dart';
import '../models/content/input_content_block.dart';
import '../models/messages/input_message.dart';
import '../models/messages/message.dart';
import '../models/messages/message_create_request.dart';
import '../models/messages/message_role.dart';
import '../models/metadata/stop_reason.dart';
import '../models/streaming/message_stream_event.dart';
import '../models/tools/tool.dart';
import '../models/tools/tool_change_reference.dart';
import '../models/tools/tool_definition.dart';
import '../resources/message_thread.dart';
import '../resources/messages_resource.dart';
import '../utils/request_id.dart';
import 'message_extensions.dart';
import 'stream_extensions.dart';

/// A callable custom Messages tool and its typed input decoder.
///
/// Set [Tool.strict] on [definition] to request schema-constrained tool calls.
/// The decoder is the local validation boundary. It receives the tool use's
/// JSON object and should reject inputs the callback cannot safely handle.
final class RunnableMessageTool<T> {
  /// Binds a tool declaration and decoder to an application callback.
  RunnableMessageTool({
    required Tool definition,
    required T Function(Map<String, dynamic> input) decode,
    required FutureOr<MessageToolResult> Function(T input, MessageToolCall call)
    run,
  }) : definition = Tool.fromJson(deepUnmodifiableMap(definition.toJson())),
       _invoke = ((call, admitHandler) async {
         final input = decode(call.toolUse.input);
         // A synchronous decoder can signal cancellation before returning.
         await Future<void>.value();
         admitHandler();
         return run(input, call);
       });

  /// Definition sent to Claude.
  final Tool definition;

  final Future<MessageToolResult> Function(
    MessageToolCall call,
    void Function() admitHandler,
  )
  _invoke;
}

/// A completed assistant tool request supplied to an application callback.
final class MessageToolCall {
  const MessageToolCall._(this.toolUse, this.abortTrigger);

  /// Tool name, call ID, decoded JSON input and caller metadata.
  final ToolUseBlock toolUse;

  /// The runner's abort signal. Asynchronous callbacks can use it to stop
  /// their own work and release any resources.
  final Future<void>? abortTrigger;
}

/// Application output for an individual tool use.
final class MessageToolResult {
  /// Creates a result from typed tool result blocks.
  MessageToolResult(List<ToolResultContent> content, {this.isError = false})
    : content = List.unmodifiable(content);

  /// Creates a text result. Set [isError] for a model-safe failure message.
  factory MessageToolResult.text(String text, {bool isError = false}) =>
      MessageToolResult([ToolResultContent.text(text)], isError: isError);

  /// Result content to include in the next turn.
  final List<ToolResultContent> content;

  /// Whether the result reports a tool failure.
  final bool isError;
}

/// The last reply and state of a completed or budget-limited tool run.
final class MessageToolRunResult {
  MessageToolRunResult._(
    this.message,
    List<InputMessage> history,
    this.iterations,
    this.iterationLimitReached,
    this.thread,
  ) : history = List.unmodifiable(history);

  /// Final raw reply. Inspect it for refusals or pending tool calls.
  final Message message;

  /// Full replay history preceding [message].
  final List<InputMessage> history;

  /// Number of assistant requests completed.
  final int iterations;

  /// Whether another iteration was needed but the budget was exhausted.
  final bool iterationLimitReached;

  /// The continuation handle when the run opted into beta Messages threads.
  final MessageThread? thread;
}

/// Executes application callbacks for completed Messages tool turns.
extension MessageToolRunner on MessagesResource {
  /// Runs a Messages loop with registered custom [tools].
  ///
  /// Tool definitions are added to the supplied request. Other definitions,
  /// routing options and beta headers are preserved. Tool callbacks run in
  /// response order after a complete `tool_use` turn. An unregistered custom
  /// call returns an error block. A toolset member call hands the raw reply
  /// back to the application for manual handling of the whole turn.
  ///
  /// [maxIterations] caps assistant requests. A tool call in the last
  /// allowed response is returned pending so a side effect cannot run without
  /// a follow-up request. [onTurn] observes each completed response.
  ///
  /// Set [stream] or supply [onEvent] to receive responses over SSE. Set
  /// [useThread] to opt into beta server-held history. Raw thread and on-demand
  /// compaction parameters belong to individual requests. Threshold compaction
  /// configured through `context_management` is passed through.
  /// Expired thread continuation errors are returned to the caller. Choose
  /// stateless mode for providers and context edits that require full history.
  ///
  /// Tool exceptions become generic error results, with the original error
  /// available to [onToolError]. The [abortTrigger] applies to all requests and
  /// prevents new callbacks. An active callback must cooperate to cancel its
  /// own work.
  Future<MessageToolRunResult> runTools(
    MessageCreateRequest request, {
    required List<RunnableMessageTool<Object?>> tools,
    int? maxIterations,
    bool stream = false,
    bool useThread = false,
    Future<void>? abortTrigger,
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
    void Function(Message message)? onTurn,
    void Function(MessageStreamEvent event)? onEvent,
    void Function(MessageToolCall call, Object error, StackTrace stackTrace)?
    onToolError,
  }) async {
    if (maxIterations != null && maxIterations < 1) {
      throw ArgumentError.value(
        maxIterations,
        'maxIterations',
        'Must be positive',
      );
    }
    if (request.thread != null || request.compaction != null) {
      throw ArgumentError('runTools manages thread and compaction parameters');
    }
    final registered = <String, RunnableMessageTool<Object?>>{};
    for (final tool in tools) {
      if (tool.definition.type case final String type when type != 'custom') {
        throw ArgumentError('A runnable custom tool must have type custom');
      }
      if (registered.containsKey(tool.definition.name)) {
        throw ArgumentError('A tool name can only have one callback');
      }
      registered[tool.definition.name] = tool;
    }
    final configured = request.copyWith(
      tools: _toolDefinitions(request.tools, registered),
    );
    final activeBetas = List<String>.of(betas);
    final thread = useThread
        ? createThread(
            configured,
            betas: activeBetas,
            userProfileId: userProfileId,
            workspaceId: workspaceId,
          )
        : null;
    final abort = _ToolRunAbort(abortTrigger);
    // Let an already-completed signal take effect before the first request.
    await Future<void>.value();
    final history = List<InputMessage>.of(configured.messages);
    var settings = configured;
    var nextInputs = <InputMessage>[];

    for (var iteration = 1; ; iteration++) {
      abort.check();
      final turnRequest = settings.copyWith(messages: history);
      final Message message;
      if (stream || onEvent != null) {
        final events = thread != null
            ? thread.stream(messages: nextInputs, abortTrigger: abortTrigger)
            : createStream(
                turnRequest,
                abortTrigger: abortTrigger,
                betas: activeBetas,
                userProfileId: userProfileId,
                workspaceId: workspaceId,
              );
        message =
            await (onEvent == null
                    ? events
                    : events.map((event) {
                        onEvent(event);
                        return event;
                      }))
                .finalMessage();
      } else {
        message = thread != null
            ? await thread.send(
                messages: nextInputs,
                abortTrigger: abortTrigger,
              )
            : await create(
                turnRequest,
                abortTrigger: abortTrigger,
                betas: activeBetas,
                userProfileId: userProfileId,
                workspaceId: workspaceId,
              );
      }

      abort.check();
      if (message.role != MessageRole.assistant) {
        throw const FormatException('Expected an assistant tool run response.');
      }
      if (onTurn != null) {
        onTurn(message);
        if (abortTrigger != null) await Future<void>.value();
        abort.check();
      }
      final calls = message.stopReason == StopReason.toolUse
          ? message.content.whereType<ToolUseBlock>().toList()
          : const <ToolUseBlock>[];
      final resume =
          message.stopReason == StopReason.pauseTurn ||
          message.stopReason == StopReason.compaction;
      final canContinue =
          resume ||
          (calls.isNotEmpty && calls.every((call) => call.toolsetName == null));
      if (!canContinue || iteration == maxIterations) {
        return MessageToolRunResult._(
          message,
          history,
          iteration,
          canContinue && iteration == maxIterations,
          thread,
        );
      }

      // Validate the assistant replay and call IDs before executing any tool.
      final reply = message.toInputMessage();
      final ids = <String>{};
      for (final call in calls) {
        if (call.id.isEmpty || _invalidToolUseIdCharacter.hasMatch(call.id)) {
          throw const FormatException(
            'A tool turn included an invalid tool use ID.',
          );
        }
        if (!ids.add(call.id)) {
          throw const FormatException('A tool turn repeated a tool use ID.');
        }
      }
      nextInputs = [];
      if (calls.isNotEmpty) {
        final available = _availableTools(registered, [...history, reply]);
        final results = <ToolResultInputBlock>[];
        for (final toolUse in calls) {
          final tool = available.contains(toolUse.name)
              ? registered[toolUse.name]
              : null;
          results.add(
            await _runTool(tool, toolUse, abort, ensureNotClosed, onToolError),
          );
        }
        nextInputs.add(InputMessage.userBlocks(results));
      }
      history.addAll([reply, ...nextInputs]);
      if (thread == null) {
        settings = settings.copyWith(
          fallbackCreditToken: null,
          container: _reuseContainer(settings.container, message.container),
        );
      }
    }
  }
}

final _invalidToolUseIdCharacter = RegExp(r'[^a-zA-Z0-9_-]');

List<ToolDefinition>? _toolDefinitions(
  List<ToolDefinition>? existing,
  Map<String, RunnableMessageTool<Object?>> registered,
) {
  if (registered.isEmpty) return existing;
  final added = Map.of(registered);
  final definitions = <ToolDefinition>[];
  for (final definition in existing ?? const <ToolDefinition>[]) {
    final json = definition.toJson();
    final tool = registered[json['name']];
    if (tool == null) {
      definitions.add(definition);
      continue;
    }
    if (!_sameCustomDefinition(json, tool.definition) ||
        added.remove(tool.definition.name) == null) {
      throw ArgumentError('The request has conflicting definitions for a tool');
    }
    definitions.add(ToolDefinition.fromJson(deepUnmodifiableMap(json)));
  }
  return [
    ...definitions,
    for (final tool in added.values) ToolDefinition.custom(tool.definition),
  ];
}

bool _sameCustomDefinition(Map<String, dynamic> json, Tool tool) =>
    (json['type'] == null || json['type'] == 'custom') &&
    mapsDeepEqual({...json}..remove('type'), tool.toJson()..remove('type'));

Set<String> _availableTools(
  Map<String, RunnableMessageTool<Object?>> registered,
  List<InputMessage> history,
) {
  final available = registered.keys.toSet();
  final incompatible = <String>{};

  void apply(InputContentBlock block) {
    switch (block) {
      case ToolRemovalInputBlock(tool: ToolChangeToolReference(:final name)):
        available.remove(name);
      case ToolAdditionInputBlock(tool: ToolChangeToolReference(:final name))
          when registered.containsKey(name) && !incompatible.contains(name):
        available.add(name);
      case ToolAdditionInputBlock(:final tool):
        // Handles the preserved wire shape on older input models and the
        // typed by-value definition on current models.
        if (tool.toJson() case {
          'type': 'tool_definition',
          'definition': final Map<String, dynamic> definition,
        }) {
          final name = definition['name'] as String?;
          final runnable = registered[name];
          if (name != null && runnable != null) {
            if (_sameCustomDefinition(definition, runnable.definition)) {
              incompatible.remove(name);
              available.add(name);
            } else {
              // A model may still emit this name after the caller changes its
              // schema. Never route the replacement to the old decoder.
              incompatible.add(name);
              available.remove(name);
            }
          }
        }
      default:
        break;
    }
  }

  for (final message in history) {
    if (message.content case BlocksMessageContent(:final blocks)) {
      for (final block in blocks) {
        if (message.role == MessageRole.system) {
          apply(block);
        } else if (message.role == MessageRole.assistant &&
            block is CompactionInputBlock) {
          for (final change in block.toolChanges ?? const []) {
            apply(InputContentBlock.fromJson(change));
          }
        }
      }
    }
  }
  return available;
}

ContainerParam? _reuseContainer(ContainerParam? config, Container? returned) {
  if (returned == null) return config;
  return switch (config) {
    null => ContainerParam.id(returned.id),
    ContainerParamConfig(:final params) when params.id == null =>
      ContainerParam.config(params.copyWith(id: returned.id)),
    _ => config,
  };
}

Future<ToolResultInputBlock> _runTool(
  RunnableMessageTool<Object?>? tool,
  ToolUseBlock use,
  _ToolRunAbort abort,
  void Function()? ensureNotClosed,
  void Function(MessageToolCall, Object, StackTrace)? onError,
) async {
  abort.check();
  ensureNotClosed?.call();
  if (tool == null) {
    return ToolResultInputBlock.text(
      toolUseId: use.id,
      text: 'The requested tool has no available callback.',
      isError: true,
    );
  }
  final call = MessageToolCall._(
    use.copyWith(input: deepUnmodifiableMap(use.input)),
    abort.trigger,
  );
  final MessageToolResult result;
  try {
    result = await abort.run(
      () => tool._invoke(call, () {
        abort.check();
        ensureNotClosed?.call();
      }),
    );
  } catch (error, stackTrace) {
    abort.check();
    ensureNotClosed?.call();
    onError?.call(call, error, stackTrace);
    return ToolResultInputBlock.text(
      toolUseId: use.id,
      text: 'The tool failed to complete.',
      isError: true,
    );
  }
  return ToolResultInputBlock(
    toolUseId: use.id,
    content: result.content,
    isError: result.isError ? true : null,
  );
}

class _ToolRunAbort {
  _ToolRunAbort(this.trigger) {
    final signal = trigger;
    if (signal != null) {
      unawaited(
        signal.then<void>(
          (_) => _abort(),
          onError: (Object error, StackTrace _) => _abort(error),
        ),
      );
    }
  }

  final Future<void>? trigger;
  AbortedException? _failure;
  Completer<MessageToolResult>? _running;

  void _abort([Object? reason]) {
    final failure = AbortedException(
      message: 'Messages tool run aborted by user',
      correlationId: generateRequestId(),
      timestamp: DateTime.now(),
      stage: AbortionStage.beforeRequest,
      reason: reason,
    );
    _failure = failure;
    final running = _running;
    if (running != null && !running.isCompleted) {
      running.completeError(failure);
    }
  }

  void check() {
    if (_failure case final failure?) throw failure;
  }

  Future<MessageToolResult> run(
    FutureOr<MessageToolResult> Function() invoke,
  ) async {
    check();
    if (trigger == null) return invoke();
    final running = Completer<MessageToolResult>();
    _running = running;
    unawaited(
      Future.sync(invoke).then<void>(
        (result) {
          if (!running.isCompleted) running.complete(result);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!running.isCompleted) running.completeError(error, stackTrace);
        },
      ),
    );
    try {
      final result = await running.future;
      check();
      return result;
    } finally {
      _running = null;
    }
  }
}
