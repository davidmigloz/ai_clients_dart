import 'package:tavily_dart/tavily_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'search requests preserve wire defaults and nullable copy semantics',
    () {
      final request = SearchRequest.fromJson({
        'query': 'Dart code generation',
        'include_domains': ['dart.dev'],
      });
      expect(request.toJson(), {
        'query': 'Dart code generation',
        'search_depth': 'basic',
        'include_images': false,
        'include_answer': false,
        'include_raw_content': false,
        'max_results': 5,
        'include_domains': ['dart.dev'],
      });
      final copy = request.copyWith(includeDomains: null, includeAnswer: true);
      expect(copy.toJson().containsKey('include_domains'), isFalse);
      expect(copy.toJson()['include_answer'], isTrue);
      expect(request.includeDomains, ['dart.dev']);
    },
  );

  test('search request collections remain immutable and compare by value', () {
    SearchRequest makeRequest() => SearchRequest.fromJson({
      'query': 'Dart',
      'include_domains': ['dart.dev'],
    });
    final first = makeRequest();
    final second = makeRequest();
    expect(identical(first, second), isFalse);
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(
      () => first.includeDomains!.add('example.com'),
      throwsUnsupportedError,
    );
    expect(SearchRequest.fromJson(first.toJson()), first);
  });
}
