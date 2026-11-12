import 'dart:async';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

typedef _Page = ({List<int> data, String? next, bool hasMore});

void main() {
  test(
    'batch pagination keeps request options on each public request',
    () async {
      final transport = MockHttpClient()
        ..queueJsonResponse({
          'data': [MockResponses.messageBatch(id: 'msgbatch_1')],
          'has_more': true,
          'first_id': 'msgbatch_1',
          'last_id': 'msgbatch_1',
        })
        ..queueJsonResponse({
          'data': [MockResponses.messageBatch(id: 'msgbatch_2')],
          'has_more': false,
          'first_id': 'msgbatch_2',
          'last_id': 'msgbatch_2',
        });
      final client = AnthropicClient(
        config: const AnthropicConfig(authProvider: ApiKeyProvider('fixture')),
        httpClient: transport,
      );
      addTearDown(client.close);

      final paginator =
          CursorPagination<MessageBatchListResponse, MessageBatch>(
            initialCursor: 'msgbatch_start',
            fetchPage: (cursor, abortTrigger) => client.messages.batches.list(
              afterId: cursor,
              limit: 1,
              workspaceId: 'wrkspc_fixture',
              betas: const ['fixture-beta'],
              abortTrigger: abortTrigger,
            ),
            nextCursor: (page) => page.hasMore ? page.lastId : null,
            selectItems: (page) => page.data,
          );
      final stream = paginator.items();
      expect(transport.requests, isEmpty);
      expect(await stream.map((batch) => batch.id).toList(), [
        'msgbatch_1',
        'msgbatch_2',
      ]);
      expect(transport.requests.map((request) => request.url.path), [
        '/v1/messages/batches',
        '/v1/messages/batches',
      ]);
      expect(transport.requests.map((request) => request.url.queryParameters), [
        {'limit': '1', 'after_id': 'msgbatch_start'},
        {'limit': '1', 'after_id': 'msgbatch_1'},
      ]);
      for (final request in transport.requests) {
        expect(request.headers['anthropic-workspace-id'], 'wrkspc_fixture');
        expect(request.headers['anthropic-beta'], 'fixture-beta');
        expect(request.headers['x-api-key'], 'fixture');
      }
    },
  );

  test(
    'empty pages may continue and terminal markers win over cursors',
    () async {
      const opaque =
          r'  /+=%?$'
          '\t';
      final cursors = <String?>[];
      final paginator = _paginator((cursor, _) async {
        cursors.add(cursor);
        return cursor == null
            ? (data: <int>[], next: opaque, hasMore: true)
            : (data: [1], next: 'ignored', hasMore: false);
      });

      final pages = await paginator.pages().toList();
      expect(pages.map((page) => page.data), [
        <int>[],
        [1],
      ]);
      expect(cursors, [null, opaque]);
      expect(await paginator.items().toList(), [1]);
      expect(cursors, [null, opaque, null, opaque]);
    },
  );

  test('breaking out of items leaves later pages unfetched', () async {
    var requests = 0;
    final paginator = _paginator((cursor, _) async {
      requests++;
      return (data: [1], next: 'later', hasMore: true);
    });

    await for (final item in paginator.items()) {
      expect(item, 1);
      break;
    }
    await Future<void>.delayed(Duration.zero);
    expect(requests, 1);
  });

  test('pausing after the last item defers dispatch until resume', () async {
    final paused = Completer<void>();
    final completed = Completer<void>();
    final cursors = <String?>[];
    final items = <int>[];
    final paginator = _paginator((cursor, _) async {
      cursors.add(cursor);
      return cursor == null
          ? (data: [1, 2], next: 'second', hasMore: true)
          : (data: [3], next: null, hasMore: false);
    });

    late StreamSubscription<int> subscription;
    subscription = paginator.items().listen((item) {
      items.add(item);
      if (item == 2) {
        subscription.pause();
        paused.complete();
      }
    }, onDone: completed.complete);
    addTearDown(subscription.cancel);

    await paused.future;
    await Future<void>.delayed(Duration.zero);
    expect(cursors, [null]);
    expect(items, [1, 2]);
    subscription.resume();
    await completed.future;
    expect(cursors, [null, 'second']);
    expect(items, [1, 2, 3]);
  });

  test('pending cancellation suppresses the initial dispatch', () async {
    var requests = 0;
    final paginator = _paginator((cursor, _) async {
      requests++;
      return (data: [1], next: null, hasMore: false);
    });
    final subscription = paginator.pages().listen(
      (_) => fail('Unexpected page'),
    );
    await subscription.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(requests, 0);
  });

  test(
    'cancellation queued by the page listener suppresses the next fetch',
    () async {
      var requests = 0;
      final stopped = Completer<void>();
      final paginator = _paginator((cursor, _) async {
        requests++;
        return (data: [1], next: 'later', hasMore: true);
      });

      late StreamSubscription<_Page> subscription;
      subscription = paginator.pages().listen((page) {
        expect(requests, 1);
        scheduleMicrotask(() async {
          await subscription.cancel();
          stopped.complete();
        });
      });
      addTearDown(subscription.cancel);

      await stopped.future;
      await Future<void>.delayed(Duration.zero);
      expect(requests, 1);
    },
  );

  test('canceling during cursor selection suppresses dispatch', () async {
    var requests = 0;
    final stopped = Completer<void>();
    late StreamSubscription<_Page> subscription;
    final paginator = CursorPagination<_Page, int>(
      fetchPage: (cursor, _) async {
        requests++;
        return (data: [1], next: 'later', hasMore: true);
      },
      nextCursor: (page) {
        unawaited(subscription.cancel().then(stopped.complete));
        return page.next;
      },
      selectItems: (page) => page.data,
    );
    subscription = paginator.pages().listen((_) {});
    addTearDown(subscription.cancel);

    await stopped.future;
    await Future<void>.delayed(Duration.zero);
    expect(requests, 1);
  });

  test('canceling items aborts a pending public batch request', () async {
    final transport = _PendingTransport();
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    final paginator = CursorPagination<MessageBatchListResponse, MessageBatch>(
      fetchPage: (cursor, abortTrigger) =>
          client.batches.list(afterId: cursor, abortTrigger: abortTrigger),
      nextCursor: (page) => page.hasMore ? page.lastId : null,
      selectItems: (page) => page.data,
    );

    final subscription = paginator.items().listen(
      (_) => fail('Unexpected item'),
      onError: (Object error) =>
          fail('Unexpected error after cancellation: $error'),
    );
    addTearDown(subscription.cancel);
    final request = await transport.started.future;
    expect(request.url.path, '/v1/messages/batches');
    expect(request, isA<http.Abortable>());
    await subscription.cancel();
    await transport.aborted.future;
    await Future<void>.delayed(Duration.zero);
  });

  for (final lazy in [false, true]) {
    test(
      'an item ${lazy ? 'iterator' : 'selector'} error ends traversal',
      () async {
        final fetched = <String?>[];
        final errors = <Object>[];
        final failure = StateError('item selection failed');
        final paginator = CursorPagination<int, int>(
          fetchPage: (cursor, _) async {
            fetched.add(cursor);
            return cursor == null ? 1 : 2;
          },
          nextCursor: (page) => page == 1 ? 'next' : null,
          selectItems: (page) {
            if (page != 1) return [page];
            if (lazy) return _partlyFailingItems(page, failure);
            throw failure;
          },
        );

        // Recovering the error in a downstream listener must not advance pages.
        final items = await paginator.items().handleError(errors.add).toList();
        expect(errors, [same(failure)]);
        expect(items, lazy ? [1] : isEmpty);
        expect(fetched, [null]);
      },
    );
  }

  test('an empty initial cursor fails before dispatch', () async {
    final paginator = _paginator(
      (cursor, _) async => fail('Unexpected fetch'),
      initialCursor: '',
    );
    await expectLater(
      paginator.pages(),
      emitsInOrder([emitsError(isA<FormatException>()), emitsDone]),
    );
  });

  for (final invalid in ['', 'already-seen']) {
    test(
      'invalid continuation ${invalid.isEmpty ? 'empty' : 'repeated'} stops dispatch',
      () async {
        const initial = 'already-seen';
        final cursors = <String?>[];
        final paginator = _paginator((cursor, _) async {
          cursors.add(cursor);
          return (data: [1], next: invalid, hasMore: true);
        }, initialCursor: initial);
        await expectLater(
          paginator.items(),
          emitsInOrder([1, emitsError(isA<FormatException>()), emitsDone]),
        );
        expect(cursors, [initial]);
      },
    );
  }

  test(
    'second-page failures preserve the original error and prior items',
    () async {
      final failure = StateError('second-page fixture');
      final cursors = <String?>[];
      final paginator = _paginator((cursor, _) async {
        cursors.add(cursor);
        if (cursor != null) throw failure;
        return (data: [1], next: 'second', hasMore: true);
      });
      await expectLater(
        paginator.items(),
        emitsInOrder([1, emitsError(same(failure)), emitsDone]),
      );
      expect(cursors, [null, 'second']);
    },
  );
}

CursorPagination<_Page, int> _paginator(
  Future<_Page> Function(String?, Future<void>) fetch, {
  String? initialCursor,
}) => CursorPagination<_Page, int>(
  fetchPage: fetch,
  initialCursor: initialCursor,
  nextCursor: (page) => page.hasMore ? page.next : null,
  selectItems: (page) => page.data,
);

class _PendingTransport extends http.BaseClient {
  final started = Completer<http.BaseRequest>();
  final aborted = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    started.complete(request);
    await (request as http.Abortable).abortTrigger!;
    aborted.complete();
    throw http.RequestAbortedException(request.url);
  }
}

Iterable<int> _partlyFailingItems(int item, Error failure) sync* {
  yield item;
  throw failure;
}
