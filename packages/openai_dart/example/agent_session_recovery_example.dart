/// Restores an application view using current state and persisted item IDs.
/// This example is fully offline and never replays tasks, tools or approvals.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final bytes = StreamController<List<int>>();
  final buffered = Completer<void>();
  var reads = 0;
  final transport = MockClient.streaming((request, _) async {
    if (request.method != 'GET') {
      throw StateError('Recovery must not replay input');
    }
    if (request.url.path.endsWith('/events')) {
      return http.StreamedResponse(
        bytes.stream,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (request.url.path.endsWith('/items')) {
      final second = request.url.queryParameters['after'] == 'saved';
      final id = second ? 'second' : 'saved';
      return _json({
        'object': 'list',
        'data': [_item(id)],
        'first_id': id,
        'last_id': id,
        'has_more': !second,
      });
    }
    if (++reads == 1) {
      bytes
        ..add(_event(_delta('same', 'saved', 'stale delta')))
        ..add(_event(_delta('same', 'saved', 'stale delta')))
        ..add(_event(_delta('new', 'live', 'new text')))
        ..add(
          _event({
            'type': 'agent.session.requires_action',
            'event_id': 'old-form',
            'session': recoverySessionFixture(requestId: 'old-request'),
          }),
        );
      await buffered.future;
    }
    return _json(
      recoverySessionFixture(
        requestId: reads == 1 ? 'old-request' : 'current-request',
      ),
    );
  });
  final client = OpenAIClient(httpClient: transport);
  final sessions = client.agents.sessions;
  final ready = Completer<void>();
  final abort = Completer<void>();
  final pending = <AgentSessionEvent>[];
  final finalItems = <String, Map<String, dynamic>>{};
  final partialText = <String, String>{};
  final recentIds = <String>{};
  var recovering = true;
  var closing = false;
  Object? observerFailure;
  var pendingBytes = 0;

  void failObservation(Object error) {
    observerFailure ??= error;
    if (!ready.isCompleted) ready.completeError(error);
    if (!abort.isCompleted) abort.complete();
  }

  void checkObservation() {
    if (observerFailure != null) {
      throw StateError('Observation lost; refresh current state again.');
    }
  }

  void checkViewBudget() {
    if (finalItems.length + partialText.length > 256 ||
        utf8.encode(jsonEncode([finalItems, partialText])).length >
            1024 * 1024) {
      throw StateError(
        'Application view budget exceeded; close and choose a narrower view.',
      );
    }
  }

  void apply(AgentSessionEvent event) {
    final eventId = event.toJson()['event_id'] as String;
    if (!recentIds.add(eventId)) return;
    if (recentIds.length > 1024) recentIds.remove(recentIds.first);
    if (event case final AgentSessionTurnOutputTextDeltaEvent delta) {
      if (!finalItems.containsKey(delta.itemId)) {
        partialText.update(
          delta.itemId,
          (text) => text + delta.delta,
          ifAbsent: () => delta.delta,
        );
      }
    } else if (event case final AgentSessionTurnItemDoneEvent done) {
      final item = done.item.toJson();
      final id = item['id'] as String;
      if (!finalItems.containsKey(id)) {
        finalItems[id] = item;
        partialText.remove(id);
      }
    } else if (event is AgentSessionFailedEvent) {
      throw StateError('The saved session failed; stop reconnecting.');
    }
    // Browser forms come from retrieve().requiredActions, not historical items.
    checkViewBudget();
  }

  final subscription = sessions.events
      .stream('session', onReady: ready.complete, abortTrigger: abort.future)
      .listen(
        (event) {
          try {
            if (recovering) {
              pendingBytes += utf8.encode(jsonEncode(event.toJson())).length;
              if (pending.length >= 256 || pendingBytes > 1024 * 1024) {
                throw StateError(
                  'Recovery buffer exceeded; close and start a fresh observation.',
                );
              }
              pending.add(event);
              if (pending.length == 4 && !buffered.isCompleted) {
                buffered.complete();
              }
            } else {
              apply(event);
            }
          } catch (error) {
            failObservation(error);
          }
        },
        onError: failObservation,
        onDone: () {
          if (!closing) {
            failObservation(
              StateError('Observer ended; EOF does not prove turn completion.'),
            );
          }
        },
      );
  try {
    // Readiness is successful headers, never a timer or the first SSE event.
    await ready.future;
    var current = await sessions.retrieve(
      'session',
      abortTrigger: abort.future,
    );
    if (current.status.value == 'failed') {
      throw StateError('Stop reconnecting to a failed session.');
    }
    String? cursor;
    final cursors = <String>{};
    var pages = 0;
    do {
      if (++pages > 32) {
        throw StateError(
          'History page budget exceeded; choose a narrower view.',
        );
      }
      final page = await sessions.items.list(
        'session',
        order: AgentListOrder.asc,
        after: cursor,
        abortTrigger: abort.future,
      );
      for (final item in page.data) {
        final wire = item.toJson();
        final id = wire['id'];
        if (id is String &&
            const ['completed', 'incomplete'].contains(wire['status'])) {
          finalItems[id] = wire;
        }
        checkViewBudget();
      }
      if (!page.hasMore) break;
      cursor = page.lastId;
      if (cursor == null || !cursors.add(cursor)) {
        throw StateError('Invalid history page cursor');
      }
    } while (true);
    checkObservation();
    pending
      ..forEach(apply)
      ..clear();
    pendingBytes = 0;
    recovering = false;
    // Refresh current forms after restoring output. Repeat immediately before a
    // user response too, because the service can replace a pending request.
    current = await sessions.retrieve('session', abortTrigger: abort.future);
    checkObservation();
    if (current.status.value == 'failed') {
      throw StateError('The saved session failed; stop reconnecting.');
    }
    final action =
        current.requiredActions.single
            as AgentSessionComputerUseApprovalRequiredAction;
    if (action.requestId != 'current-request' ||
        partialText.containsKey('saved')) {
      throw StateError(
        'A stale item update or action survived reconciliation.',
      );
    }
    bytes.add(_event(_delta('later', 'live', ' continued')));
    await _until(() => partialText['live'] == 'new text continued');
    stdout
      ..writeln(
        'Restored ${finalItems.length} final items and current actions; resumed live updates.',
      )
      ..writeln(
        'Observer close does not cancel/delete the durable session or shut down compute.',
      );
    // Session status, selected turn completion, and environment connection/state
    // are independent. Published artifacts survive the environment lifetime.
  } finally {
    closing = true;
    if (!abort.isCompleted) abort.complete();
    await subscription.cancel();
    pending.clear();
    await bytes.close();
    client.close();
    transport.close();
  }
}

/// Synthetic current-state fixture used only by these offline workflow examples.
Map<String, dynamic> recoverySessionFixture({
  required String requestId,
  String status = 'requires_action',
  Map<String, dynamic>? request,
}) => {
  'object': 'agent.session',
  'id': 'session',
  'created_at': 0,
  'last_active_at': 0,
  'agent': {
    'id': 'synthetic-agent',
    'instructions': null,
    'model': 'synthetic-model',
    'multi_agent': {'enabled': false, 'max_concurrent_subagents': null},
    'name': null,
    'reasoning': {'effort': null, 'summary': null},
    'service_tier': 'auto',
    'text': {
      'format': {'type': 'text'},
      'verbosity': 'low',
    },
    'tools': [
      {'type': 'computer_use', 'include_screenshots': false},
    ],
  },
  'environment': {
    'type': 'openai_hosted',
    'id': 'synthetic-environment',
    'capability_directories': <String>[],
    'desktop': {'enabled': true},
    'network': {'access': 'enabled', 'allowed_domains': <String>[]},
    'packages': {'npm': <String>[], 'python': <String>[], 'system': <String>[]},
    'files': <Object?>[],
    'plugins': <Object?>[],
    'skills': <Object?>[],
  },
  'error': null,
  'metadata': <String, String>{},
  'usage': null,
  'vault_ids': <String>[],
  'status': status,
  'required_actions': status == 'requires_action'
      ? [
          {
            'type': 'computer_use_approval_request',
            'request_id': requestId,
            'turn_id': 'turn',
            'request':
                request ??
                {
                  'type': 'browser_origin_access',
                  'origin': 'https://site.invalid',
                  'reason': null,
                },
          },
        ]
      : <Object?>[],
};
http.StreamedResponse _json(Object body) => http.StreamedResponse(
  Stream.value(utf8.encode(jsonEncode(body))),
  200,
  headers: {'content-type': 'application/json'},
);
List<int> _event(Object body) => utf8.encode('data: ${jsonEncode(body)}\n\n');
Map<String, dynamic> _delta(String id, String itemId, String text) => {
  'type': 'agent.session.turn.output_text.delta',
  'event_id': id,
  'session_id': 'session',
  'turn_id': 'turn',
  'item_id': itemId,
  'output_index': 0,
  'content_index': 0,
  'delta': text,
};
Map<String, dynamic> _item(String id) => {
  'type': 'message',
  'role': 'assistant',
  'id': id,
  'turn_id': 'turn',
  'phase': null,
  'status': 'completed',
  'content': [
    {'type': 'output_text', 'text': 'Final output'},
  ],
};
Future<void> _until(bool Function() test) async {
  for (var n = 0; n < 1000; n++) {
    if (test()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  throw StateError('Synthetic example did not settle');
}
