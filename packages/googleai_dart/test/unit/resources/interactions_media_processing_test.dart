import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _audio = AudioContent(
  data: 'AAE=',
  mimeType: 'audio/wav',
  processing: InteractionAudioProcessing.clip(
    startOffset: '10.5s',
    endOffset: '15s',
  ),
);

const _document = DocumentContent(
  uri: 'https://example.test/report.pdf',
  mimeType: 'application/pdf',
  processing: InteractionDocumentProcessing.select(
    pageOptions: InteractionPageProcessingOptions(
      startPage: 2,
      endPage: 4,
      contentLayers: [InteractionPageLayer.text],
    ),
  ),
);

const _sheet = DocumentContent(
  uri: 'https://example.test/forecast.xlsx',
  mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  processing: InteractionDocumentProcessing.select(
    spreadsheetOptions: InteractionSpreadsheetProcessingOptions(
      sheetIndex: 2,
      visibleCells: 'A1:D10',
      contentLayers: [
        InteractionSpreadsheetLayer.data,
        InteractionSpreadsheetLayer.formulas,
      ],
    ),
  ),
);

const _video = VideoContent(
  uri: 'https://example.test/video.mp4',
  mimeType: 'video/mp4',
  name: 'Quarterly update',
  processing: InteractionVideoProcessing.clip(
    startOffset: '30s',
    endOffset: '60s',
    fps: 0.5,
    contentLayers: [
      InteractionVideoLayer.frames,
      InteractionVideoLayer.transcript,
    ],
  ),
);

const List<Map<String, Object>> _contentWire = [
  {
    'type': 'audio',
    'data': 'AAE=',
    'mime_type': 'audio/wav',
    'processing': {
      'type': 'static',
      'start_offset': '10.5s',
      'end_offset': '15s',
    },
  },
  {
    'type': 'document',
    'uri': 'https://example.test/report.pdf',
    'mime_type': 'application/pdf',
    'processing': {
      'type': 'static',
      'page_options': {
        'start_page': 2,
        'end_page': 4,
        'content_layers': ['page_text'],
      },
    },
  },
  {
    'type': 'document',
    'uri': 'https://example.test/forecast.xlsx',
    'mime_type':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'processing': {
      'type': 'static',
      'spreadsheet_options': {
        'sheet_index': 2,
        'visible_cells': 'A1:D10',
        'content_layers': ['data', 'formulas'],
      },
    },
  },
  {
    'type': 'video',
    'uri': 'https://example.test/video.mp4',
    'mime_type': 'video/mp4',
    'name': 'Quarterly update',
    'processing': {
      'type': 'static',
      'start_offset': '30s',
      'end_offset': '60s',
      'fps': 0.5,
      'content_layers': ['frames', 'transcript'],
    },
  },
];

GoogleAIClient _makeClient(
  Future<http.Response> Function(http.Request) handler,
) {
  final transport = MockClient(handler);
  final client = GoogleAIClient(
    config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
    httpClient: transport,
  );
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

http.Response _interactionResponse(List<Map<String, Object>> steps) =>
    http.Response(
      jsonEncode({
        'id': 'interaction-1',
        'status': 'completed',
        'steps': steps,
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  test(
    'sends and reads exact media selectors in an Interactions prompt',
    () async {
      final client = _makeClient((request) async {
        expect(request.url.path, '/v1/interactions');
        expect(jsonDecode(request.body), {
          'model': 'gemini-4-hydrogen',
          'input': _contentWire,
        });
        return _interactionResponse([
          {'type': 'user_input', 'content': _contentWire},
        ]);
      });

      final response = await client.interactions.create(
        model: 'gemini-4-hydrogen',
        input: const InteractionInput.contentList([
          _audio,
          _document,
          _sheet,
          _video,
        ]),
      );

      final step = response.steps?.single as UserInputStep?;
      expect(step?.content?.map((item) => item.toJson()), _contentWire);
      final audio = step?.content?.first as AudioContent?;
      expect(audio?.processing?.startOffset, '10.5s');
      expect(audio?.copyWith(processing: null).toJson(), {
        'type': 'audio',
        'data': 'AAE=',
        'mime_type': 'audio/wav',
      });
    },
  );

  test(
    'passes sliced media in a function result and reads MCP media',
    () async {
      final client = _makeClient((request) async {
        expect(jsonDecode(request.body), {
          'model': 'gemini-4-hydrogen',
          'previous_interaction_id': 'previous-1',
          'input': [
            {
              'type': 'function_result',
              'call_id': 'call-1',
              'name': 'retrieve_files',
              'result': _contentWire,
            },
          ],
        });
        return _interactionResponse([
          {
            'type': 'mcp_server_tool_result',
            'call_id': 'remote-1',
            'result': _contentWire,
          },
        ]);
      });

      final response = await client.interactions.create(
        model: 'gemini-4-hydrogen',
        previousInteractionId: 'previous-1',
        input: const InteractionInput.steps([
          FunctionResultStep(
            callId: 'call-1',
            name: 'retrieve_files',
            result: ToolResult.contentList([
              FunctionResultSubcontentAudio(_audio),
              FunctionResultSubcontentDocument(_document),
              FunctionResultSubcontentDocument(_sheet),
              FunctionResultSubcontentVideo(_video),
            ]),
          ),
        ]),
      );

      final step = response.steps?.single as McpServerToolResultStep?;
      final result = step?.result as ToolResultContentList?;
      expect(result?.items.first, isA<FunctionResultSubcontentAudio>());
      expect(result?.items.last, isA<FunctionResultSubcontentVideo>());
      expect(result?.toJson(), _contentWire);
    },
  );

  test('round-trips shorthand, new processing values and unknown content', () {
    expect(InteractionVideoProcessing.fromJson('agentic').toJson(), 'agentic');
    expect(const InteractionAudioProcessing.staticMode().toJson(), 'static');
    expect(const InteractionDocumentProcessing.staticMode().toJson(), 'static');
    const unknownProcessing = {'type': 'future', 'setting': true};
    expect(
      InteractionVideoProcessing.fromJson(unknownProcessing).toJson(),
      unknownProcessing,
    );

    const unknownContent = {
      'type': 'future_content',
      'metadata': {'enabled': true},
    };
    final item = FunctionResultSubcontent.fromJson(unknownContent);
    expect(item, isA<UnknownFunctionResultSubcontent>());
    expect(item.toJson(), unknownContent);
  });
}
