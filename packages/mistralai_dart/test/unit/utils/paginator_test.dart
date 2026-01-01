import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Paginator', () {
    group('items', () {
      test('streams all items from single page', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final items = await paginator.items().toList();
        expect(items, [1, 2, 3]);
      });

      test('streams items from multiple pages', () async {
        var callCount = 0;
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async {
            callCount++;
            if (page == 0) return [1, 2, 3];
            if (page == 1) return [4, 5, 6];
            return [];
          },
          getItems: (response) => response,
          hasMore: (response, page, _) => page < 1,
        );

        final items = await paginator.items().toList();
        expect(items, [1, 2, 3, 4, 5, 6]);
        expect(callCount, 2);
      });

      test('uses default hasMore based on pageSize', () async {
        var callCount = 0;
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async {
            callCount++;
            if (page == 0) return [1, 2]; // Full page (pageSize = 2)
            if (page == 1) return [3]; // Partial page - stops here
            return [];
          },
          getItems: (response) => response,
          pageSize: 2,
        );

        final items = await paginator.items().toList();
        expect(items, [1, 2, 3]);
        expect(callCount, 2);
      });

      test('respects startPage parameter', () async {
        var firstPageFetched = -1;
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async {
            if (firstPageFetched == -1) firstPageFetched = page;
            return [page];
          },
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
          startPage: 5,
        );

        await paginator.items().toList();
        expect(firstPageFetched, 5);
      });
    });

    group('pages', () {
      test('streams page responses', () async {
        final paginator = Paginator<Map<String, dynamic>, int>(
          fetcher: (page, pageSize) async => {
            'page': page,
            'items': [page * 10, page * 10 + 1],
          },
          getItems: (response) => response['items'] as List<int>,
          hasMore: (_, page, pageSize) => page < 1,
        );

        final pages = await paginator.pages().toList();
        expect(pages, hasLength(2));
        expect(pages[0]['page'], 0);
        expect(pages[1]['page'], 1);
      });
    });

    group('collect', () {
      test('collects all items into a list', () async {
        final paginator = Paginator<List<String>, String>(
          fetcher: (page, pageSize) async => ['a', 'b', 'c'],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.collect();
        expect(result, ['a', 'b', 'c']);
      });
    });

    group('take', () {
      test('collects only specified number of items', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3, 4, 5],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.take(3);
        expect(result, [1, 2, 3]);
      });

      test('returns all items if fewer than requested', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.take(10);
        expect(result, [1, 2]);
      });
    });

    group('firstWhere', () {
      test('finds matching item', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3, 4, 5],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.firstWhere((item) => item > 3);
        expect(result, 4);
      });

      test('returns null when no match', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.firstWhere((item) => item > 10);
        expect(result, isNull);
      });

      test('searches across pages', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async {
            if (page == 0) return [1, 2];
            if (page == 1) return [3, 4];
            return [];
          },
          getItems: (response) => response,
          hasMore: (_, page, pageSize) => page < 1,
        );

        final result = await paginator.firstWhere((item) => item == 4);
        expect(result, 4);
      });
    });

    group('count', () {
      test('counts all items', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async {
            if (page == 0) return [1, 2, 3];
            if (page == 1) return [4, 5];
            return [];
          },
          getItems: (response) => response,
          hasMore: (_, page, pageSize) => page < 1,
        );

        final result = await paginator.count();
        expect(result, 5);
      });
    });

    group('any', () {
      test('returns true when any match', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.any((item) => item == 2);
        expect(result, isTrue);
      });

      test('returns false when no match', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.any((item) => item > 10);
        expect(result, isFalse);
      });
    });

    group('every', () {
      test('returns true when all match', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [2, 4, 6],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.every((item) => item.isEven);
        expect(result, isTrue);
      });

      test('returns false when not all match', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [2, 3, 4],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.every((item) => item.isEven);
        expect(result, isFalse);
      });
    });

    group('map', () {
      test('transforms items', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.map((item) => item * 2).toList();
        expect(result, [2, 4, 6]);
      });
    });

    group('where', () {
      test('filters items', () async {
        final paginator = Paginator<List<int>, int>(
          fetcher: (page, pageSize) async => [1, 2, 3, 4, 5],
          getItems: (response) => response,
          hasMore: (response, page, size) => false,
        );

        final result = await paginator.where((item) => item.isEven).toList();
        expect(result, [2, 4]);
      });
    });

    group('real-world simulation', () {
      test('paginates FileList-like responses', () async {
        // Simulate FileList pagination
        final paginator = Paginator<Map<String, dynamic>, Map<String, String>>(
          fetcher: (page, pageSize) async {
            if (page == 0) {
              return {
                'object': 'list',
                'data': [
                  {'id': 'file-1', 'name': 'train.jsonl'},
                  {'id': 'file-2', 'name': 'valid.jsonl'},
                ],
              };
            }
            if (page == 1) {
              return {
                'object': 'list',
                'data': [
                  {'id': 'file-3', 'name': 'test.jsonl'},
                ],
              };
            }
            return {'object': 'list', 'data': <Map<String, String>>[]};
          },
          getItems: (response) =>
              (response['data'] as List).cast<Map<String, String>>(),
          pageSize: 2,
          startPage: 0,
        );

        final files = await paginator.collect();
        expect(files, hasLength(3));
        expect(files[0]['name'], 'train.jsonl');
        expect(files[2]['name'], 'test.jsonl');
      });
    });
  });
}
