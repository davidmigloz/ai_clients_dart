part of 'agent_session_run.dart';

/// A local function implementation, separate from its canonical tool definition.
///
/// Returns text, a JSON object, supported input content (or its typed output
/// union), or null. Arguments are a detached object for this invocation. No
/// callback is serialized, and arbitrary application Futures require cooperative
/// cancellation even when the local run has already stopped waiting.
typedef AgentToolHandler =
    FutureOr<Object?> Function(Map<String, dynamic> arguments);

/// An optional local observer of a tool failure; never called for HTTP failures.
/// Observer errors do not replace or prevent the generic model-visible result.
typedef AgentToolErrorObserver =
    FutureOr<void> Function(AgentToolError failure);

/// Local stage at which a registered function failed.
enum AgentToolErrorStage {
  /// Arguments were not a valid JSON object.
  arguments,

  /// The application callback failed.
  execution,

  /// The callback output could not be encoded as a supported wire value.
  output,
}

/// Explicit private failure details for the optional local error observer.
///
/// No automatic logging occurs. Default diagnostics print none of the cause,
/// arguments, tool name, or routing identifiers.
final class AgentToolError {
  const AgentToolError._({
    required this.error,
    required this.stackTrace,
    required this.stage,
    required this.sessionId,
    required this.turnId,
    required this.callId,
    required this.toolName,
  });

  /// Original application/argument/output failure, for explicit inspection.
  final Object error;

  /// Original failure stack, for explicit inspection.
  final StackTrace stackTrace;

  /// Failure stage, independent of backend session or turn state.
  final AgentToolErrorStage stage;

  /// Captured durable session identity.
  final String sessionId;

  /// Captured call's turn identity, including a possible child turn.
  final String turnId;

  /// Captured function call identity.
  final String callId;

  /// Captured registered function name.
  final String toolName;

  @override
  String toString() => 'AgentToolError(stage: $stage, [REDACTED])';
}

final class _AgentToolDispatcher {
  _AgentToolDispatcher(
    this.run,
    Map<String, AgentToolHandler> handlers,
    this.observer,
  ) : handlers = Map<String, AgentToolHandler>.unmodifiable(handlers);

  final AgentSessionRun run;
  Map<String, AgentToolHandler> handlers;
  AgentToolErrorObserver? observer;
  final calls = <(String, String)>{};

  bool canHandle(String name) => handlers.containsKey(name);

  Future<void> Function()? prepare(AgentSessionEvent event) {
    if (event is! AgentSessionTurnItemAddedEvent ||
        event.item is! AgentSessionFunctionCallItemResource) {
      return null;
    }
    final call = event.item as AgentSessionFunctionCallItemResource;
    final handler = handlers[call.name];
    if (handler == null) return null;
    final sessionId = run.observedSessionId;
    if (sessionId == null ||
        event.sessionId != sessionId ||
        (event.turnId != null && event.turnId != call.turnId)) {
      throw StateError(
        'Function call routing does not match the observed session',
      );
    }
    final identity = (call.turnId, call.callId);
    if (calls.contains(identity)) return null;
    if (calls.length >= run.maxToolCalls) {
      throw const StreamException(
        message: 'Agent session run tool call budget exceeded its local limit',
        redactDiagnostics: true,
      );
    }
    calls.add(identity);
    // The DTO snapshot also protects against user-defined/mutable event sources.
    final captured = AgentSessionFunctionCallItemResource.fromJson(
      call.toJson(),
    );
    return () => _dispatch(sessionId, captured, handler);
  }

  Future<void> _dispatch(
    String sessionId,
    AgentSessionFunctionCallItemResource call,
    AgentToolHandler handler,
  ) async {
    run._throwFailure();
    var stage = AgentToolErrorStage.arguments;
    late AgentSessionInput result;
    try {
      final encoded = call.arguments is String
          ? call.arguments! as String
          : jsonEncode(call.arguments);
      final parsed = jsonDecode(encoded);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('Function arguments must be a JSON object');
      }
      stage = AgentToolErrorStage.execution;
      final output = await run._race(
        Future<Object?>.sync(() => handler(parsed)),
      );
      run._throwFailure();
      stage = AgentToolErrorStage.output;
      AgentSessionFunctionOutput? value;
      if (output is Map) {
        value = AgentSessionFunctionOutput.text(jsonEncode(output));
      } else if (output is AgentSessionFunctionOutput) {
        value = AgentSessionFunctionOutput.fromJson(output.toJson());
      } else if (output is List<AgentSessionInputContent>) {
        value = AgentSessionFunctionOutput.fromJson(
          output.map((item) => item.toJson()).toList(),
        );
      } else if (output != null) {
        value = AgentSessionFunctionOutput.fromJson(output);
      }
      result = AgentSessionInput.toolResult(
        callId: call.callId,
        turnId: call.turnId,
        success: true,
        output: value,
        clearOutput: value == null,
      );
      // Fail unsupported/cyclic values inside the generic failure boundary.
      jsonEncode(result.toJson());
    } catch (error, stack) {
      run._throwFailure();
      final notify = observer;
      if (notify != null) {
        try {
          await run._race(
            Future<void>.sync(
              () => notify(
                AgentToolError._(
                  error: error,
                  stackTrace: stack,
                  stage: stage,
                  sessionId: sessionId,
                  turnId: call.turnId,
                  callId: call.callId,
                  toolName: call.name,
                ),
              ),
            ),
          );
        } catch (_) {
          run._throwFailure();
        }
      }
      run._throwFailure();
      result = AgentSessionInput.toolResult(
        callId: call.callId,
        turnId: call.turnId,
        success: false,
        error: 'Tool handler failed.',
      );
    }
    run._throwFailure();
    final body = CreateAgentSessionEventsRequest.fromJson({
      'events': [result.toJson()],
    });
    var key = _inputKey(
      null,
      null,
    ).replaceFirst('agent-input-', 'agent-result-');
    while (key == run.inputKey) {
      key = _inputKey(null, null).replaceFirst('agent-input-', 'agent-result-');
    }
    final headers = run._headers;
    for (var attempt = 0; ; attempt++) {
      run._throwFailure();
      try {
        await run._race(
          run._sessions.events.create(
            sessionId,
            body,
            idempotencyKey: key,
            additionalHeaders: headers,
            abortTrigger: run._abortSignal.future,
            allowRetries: false,
          ),
        );
        return;
      } on BadRequestException catch (error) {
        final envelope = error.body?['error'];
        final actual = envelope is Map ? envelope : error.body;
        if (attempt == 3 ||
            error.statusCode != 400 ||
            (actual?['code'] ?? error.code) != 'invalid_request_error' ||
            actual?['message'] != 'Unknown pending tool call: ${call.callId}') {
          rethrow;
        }
        await _delay(const [100, 300, 600][attempt]);
      }
    }
  }

  Future<void> _delay(int milliseconds) async {
    final elapsed = Completer<void>();
    final timer = Timer(Duration(milliseconds: milliseconds), elapsed.complete);
    try {
      await run._race(elapsed.future);
    } finally {
      timer.cancel();
    }
  }

  void clear() {
    handlers = const {};
    observer = null;
    calls.clear();
  }
}
