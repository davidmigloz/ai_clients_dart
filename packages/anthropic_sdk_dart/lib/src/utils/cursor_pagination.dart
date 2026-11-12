import 'dart:async';

/// Lazily visits pages from an existing list operation.
///
/// The `fetchPage` callback receives the current cursor and a future that
/// completes if the subscription is canceled during that fetch. Forward it to
/// the list operation's `abortTrigger` to cancel the request. Capture any
/// filters and routing options in the same callback so they apply to every page.
///
/// The `nextCursor` callback selects the next cursor. Return null when the
/// endpoint's continuation rules say to stop, even if a cursor is present.
/// An empty or repeated cursor ends the stream with a [FormatException].
final class CursorPagination<Page, Item> {
  /// Creates a lazy paginator, optionally starting from [initialCursor].
  factory CursorPagination({
    required Future<Page> Function(String? cursor, Future<void> abortTrigger)
    fetchPage,
    required String? Function(Page page) nextCursor,
    required Iterable<Item> Function(Page page) selectItems,
    String? initialCursor,
  }) {
    Stream<Page> pages() =>
        _paginatePages(fetchPage, nextCursor, initialCursor);
    return CursorPagination._(
      pages,
      () =>
          pages().asyncExpand((page) => Stream.fromIterable(selectItems(page))),
    );
  }

  const CursorPagination._(this._pages, this._items);

  final Stream<Page> Function() _pages;
  final Stream<Item> Function() _items;

  /// Returns a single-subscription stream of complete responses.
  ///
  /// Each call starts a new traversal. Pausing the subscription defers the
  /// next fetch. Fetch and cursor errors terminate that traversal.
  Stream<Page> pages() => _pages();

  /// Returns a fresh stream of the selected items in page order.
  ///
  /// An empty page can still continue when the cursor selector returns a cursor.
  /// An item selector or iterator error ends the traversal.
  Stream<Item> items() => _items().transform(
    StreamTransformer<Item, Item>.fromHandlers(
      handleError: (error, stackTrace, sink) => sink
        ..addError(error, stackTrace)
        ..close(),
    ),
  );
}

Stream<Page> _paginatePages<Page>(
  Future<Page> Function(String?, Future<void>) fetchPage,
  String? Function(Page) nextCursor,
  String? initialCursor,
) {
  final seen = <String>{};
  late final StreamController<Page> controller;
  late Page previousPage;
  Completer<void>? activeAbort;
  var firstPage = true;
  var advancing = false;
  var canceled = false;

  bool canAdvance() =>
      !canceled &&
      !controller.isClosed &&
      controller.hasListener &&
      !controller.isPaused;

  void scheduleNext() {
    if (advancing || !canAdvance()) return;
    advancing = true;

    // Let a listener's queued pause or cancellation settle before dispatch.
    unawaited(
      Future<void>(() async {
        try {
          if (!canAdvance()) return;
          final cursor = firstPage ? initialCursor : nextCursor(previousPage);
          if (!canAdvance()) return;
          if (!firstPage && cursor == null) {
            unawaited(controller.close());
            return;
          }
          if (cursor != null) {
            if (cursor.isEmpty) {
              throw const FormatException('Pagination cursor is empty');
            }
            if (!seen.add(cursor)) {
              throw const FormatException('Pagination cursor repeated');
            }
          }

          final abort = Completer<void>();
          activeAbort = abort;
          final page = await fetchPage(cursor, abort.future);
          activeAbort = null;
          if (canceled) return;
          firstPage = false;
          previousPage = page;
          controller.add(page);
        } catch (error, stackTrace) {
          activeAbort = null;
          if (!canceled) {
            controller.addError(error, stackTrace);
            unawaited(controller.close());
          }
        } finally {
          advancing = false;
          scheduleNext();
        }
      }),
    );
  }

  controller = StreamController<Page>(
    sync: true,
    onListen: scheduleNext,
    onResume: scheduleNext,
    onCancel: () {
      canceled = true;
      activeAbort?.complete();
    },
  );
  return controller.stream;
}
