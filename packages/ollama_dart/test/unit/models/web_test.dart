import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  test('search limit participates in all model contracts', () {
    const request = WebSearchRequest(query: 'Dart', maxResults: 5);
    expect(WebSearchRequest.fromJson(request.toJson()), request);
    expect(request.copyWith(maxResults: 10), isNot(request));
    expect(request.copyWith(), request);
    expect(request.copyWith().hashCode, request.hashCode);
    expect(request.copyWith(maxResults: null).toJson(), {'query': 'Dart'});
    expect(request.toString(), contains('maxResults: 5'));
  });

  test('every search result field participates in equality', () {
    const result = WebSearchResult(
      title: 'Dart',
      url: 'dart.dev',
      content: 'Language',
    );
    expect(WebSearchResult.fromJson(result.toJson()), result);
    expect(result.copyWith(title: 'New'), isNot(result));
    expect(result.copyWith(content: 'New'), isNot(result));
    expect(result.copyWith(url: 'New'), isNot(result));
    expect(result.copyWith().hashCode, result.hashCode);
    expect(result.copyWith(content: null).toJson(), {
      'title': 'Dart',
      'url': 'dart.dev',
    });
    expect(result.toString(), contains('content: Language'));
  });

  test('fetch response compares content and links by value', () {
    const response = WebFetchResponse(
      title: 'Dart',
      content: 'Language',
      links: ['dart.dev'],
    );
    final roundTrip = WebFetchResponse.fromJson(response.toJson());
    expect(roundTrip, response);
    expect(roundTrip.hashCode, response.hashCode);
    expect(response.copyWith(content: 'New'), isNot(response));
    expect(response.copyWith(links: ['new']), isNot(response));
    expect(response.copyWith(links: null).toJson(), {
      'title': 'Dart',
      'content': 'Language',
    });
    expect(response.toString(), contains('links: [dart.dev]'));
  });
}
