// ignore_for_file: avoid_print
/// GA web search controls and returned images using a local transport.
///
/// This example makes no live API calls and requires no API key.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final tool = ResponseTool.webSearch(
    externalWebAccess: false,
    filters: WebSearchFilters(
      allowedDomains: const ['nps.gov', 'wikimedia.org'],
      blockedDomains: const ['spam.example'],
    ),
    searchContentTypes: const [SearchContentType.image, SearchContentType.text],
    imageSettings: WebSearchImageSettings(maxResults: 3, caption: true),
  );
  final request = CreateResponseRequest(
    model: 'gpt-6-astra',
    reasoning: const ReasoningConfig(effort: ReasoningEffort.low),
    input: const ResponseInput.text('Find images of the Golden Gate Bridge.'),
    tools: [tool],
    toolChoice: ResponseToolChoice.webSearch(),
    include: const [Include.webSearchResults, Include.webSearchActionSources],
  );
  final call = WebSearchCallOutputItem(
    id: 'ws_local',
    status: WebSearchCallStatus.completed,
    action: WebSearchActionSearch(
      queries: const ['Golden Gate Bridge images'],
      sources: const [WebSearchActionSource(url: 'https://www.nps.gov/goga/')],
    ),
    results: [
      const WebSearchImageResult(
        imageUrl: 'https://example.com/bridge.jpg',
        sourceWebsiteUrl: 'https://www.nps.gov/goga/',
        caption: 'Golden Gate Bridge at sunset.',
      ),
      UnknownWebSearchResult(
        type: 'future_result',
        data: const {
          'type': 'future_result',
          'metadata': {'rank': 2},
        },
      ),
    ],
  );
  final responseJson = <String, dynamic>{
    'id': 'resp_local',
    'object': 'response',
    'created_at': 1,
    'status': 'completed',
    'model': 'gpt-6-astra',
    'output': [call.toJson()],
    'access_programs': null,
    'error': null,
    'incomplete_details': null,
    'instructions': null,
    'tools': [tool.toJson()],
    'parallel_tool_calls': false,
    'metadata': <String, dynamic>{},
    'tool_choice': request.toolChoice!.toJson(),
    'temperature': 1.0,
    'top_p': 1.0,
    'reasoning': request.reasoning!.toJson(),
  };
  var requests = 0;
  final transport = MockClient((httpRequest) async {
    requests++;
    if (httpRequest.method != 'POST' ||
        httpRequest.url.path != '/v1/responses') {
      throw StateError('Unexpected local example request');
    }
    final body = jsonDecode(httpRequest.body) as Map<String, dynamic>;
    final expected = request.toJson();
    if (body['stream'] == true) expected['stream'] = true;
    if (jsonEncode(body) != jsonEncode(expected)) {
      throw StateError(
        'The local request must preserve all configured controls',
      );
    }
    if (body['stream'] != true) {
      return http.Response(
        jsonEncode(responseJson),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    final events = [
      {
        'type': 'response.output_item.added',
        'sequence_number': 0,
        'output_index': 0,
        'item': call
            .copyWith(status: WebSearchCallStatus.searching, results: null)
            .toJson(),
      },
      {
        'type': 'response.output_item.done',
        'sequence_number': 1,
        'output_index': 0,
        'item': call.toJson(),
      },
      {
        'type': 'response.completed',
        'sequence_number': 2,
        'response': responseJson,
      },
    ];
    return http.Response(
      '${events.map((event) => 'data: ${jsonEncode(event)}\n\n').join()}data: [DONE]\n\n',
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  try {
    final response = await client.responses.create(request);
    _showCall(response.output.whereType<WebSearchCallOutputItem>().single);
    var completed = false;
    await for (final event in client.responses.createStream(request)) {
      if (event is ResponseCompletedEvent) {
        _showCall(
          event.response.output.whereType<WebSearchCallOutputItem>().single,
        );
        completed = true;
      }
    }
    if (!completed || requests != 2) {
      throw StateError('Incomplete local example');
    }
    print('Completed REST and SSE; $requests local requests, no API cost.');
  } finally {
    client.close();
    transport.close();
  }
}

void _showCall(WebSearchCallOutputItem call) {
  print('Search status: ${call.status?.value}.');
  if (call.action case WebSearchActionSearch(:final sources)) {
    for (final source in sources ?? <WebSearchActionSource>[]) {
      print('Source: ${source.url}');
    }
  }
  for (final result in call.results ?? <WebSearchResult>[]) {
    switch (result) {
      case WebSearchImageResult(
        :final imageUrl,
        :final sourceWebsiteUrl,
        :final caption,
      ):
        print('Image: $imageUrl; source: $sourceWebsiteUrl; caption: $caption');
      case UnknownWebSearchResult(:final type):
        print('Preserved future result: $type');
    }
  }
}
