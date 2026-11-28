import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'GenerateContent sends typed inline and referenced media selections',
    () async {
      final client = GoogleAIClient(
        config: const GoogleAIConfig(apiVersion: ApiVersion.v1beta),
        httpClient: MockClient((request) async {
          expect(
            request.url.path,
            '/v1beta/models/gemini-4-hydrogen:generateContent',
          );
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['contents'], [
            {
              'parts': [
                {
                  'inlineData': {
                    'mimeType': 'application/pdf',
                    'data': 'AQI=',
                    'displayName': 'guide',
                  },
                  'documentMetadata': {
                    'startPage': 2,
                    'endPage': 4,
                    'contentLayers': ['PAGE_TEXT'],
                  },
                },
                {
                  'fileData': {
                    'fileUri': 'files/recording',
                    'mimeType': 'audio/wav',
                  },
                  'audioMetadata': {'startOffset': '1.5s', 'endOffset': '4s'},
                },
                {
                  'fileData': {
                    'fileUri': 'files/video',
                    'mimeType': 'video/mp4',
                  },
                  'mediaProcessing': 'STATIC',
                  'videoMetadata': {
                    'startOffset': '1s',
                    'endOffset': '7s',
                    'contentLayers': ['AUDIO'],
                  },
                },
              ],
            },
          ]);
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'fileData': {
                          'fileUri': 'files/video',
                          'mimeType': 'video/mp4',
                        },
                        'mediaProcessing': 'FUTURE_MODE',
                        'videoMetadata': {
                          'fps': 2,
                          'contentLayers': ['FRAMES', 'FUTURE_LAYER'],
                          'startOffset': '3s',
                        },
                      },
                    ],
                  },
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);
      final request = GenerateContentRequest(
        contents: [
          const Content(
            parts: [
              InlineDataPart(
                Blob(
                  mimeType: 'application/pdf',
                  data: 'AQI=',
                  displayName: 'guide',
                ),
                documentMetadata: DocumentMetadata(
                  startPage: 2,
                  endPage: 4,
                  contentLayers: [DocumentContentLayer.pageText],
                ),
              ),
              FileDataPart(
                FileData(fileUri: 'files/recording', mimeType: 'audio/wav'),
                audioMetadata: AudioMetadata(
                  startOffset: '1.5s',
                  endOffset: '4s',
                ),
              ),
              FileDataPart(
                FileData(fileUri: 'files/video', mimeType: 'video/mp4'),
                mediaProcessing: MediaProcessing.static,
                videoMetadata: VideoMetadata(
                  startOffset: '1s',
                  endOffset: '7s',
                  contentLayers: [VideoContentLayer.audio],
                ),
              ),
            ],
          ),
        ],
      );
      final result = await client.models.generateContent(
        model: 'gemini-4-hydrogen',
        request: request,
      );
      final part =
          result.candidates!.single.content!.parts.single as FileDataPart;
      expect(part.mediaProcessing?.toJson(), 'FUTURE_MODE');
      expect(part.videoMetadata!.fps, 2.0);
      expect(part.videoMetadata!.contentLayers!.last.toJson(), 'FUTURE_LAYER');
      final updated = part.copyWith(
        audioMetadata: const AudioMetadata(endOffset: '1s'),
      );
      expect(updated.videoMetadata?.startOffset, '3s');
      expect(updated.copyWith(videoMetadata: null).toJson(), {
        'fileData': {'fileUri': 'files/video', 'mimeType': 'video/mp4'},
        'mediaProcessing': 'FUTURE_MODE',
        'audioMetadata': {'endOffset': '1s'},
      });
    },
  );

  test(
    'GenerateContent sends file-based cropped function results and inline data',
    () async {
      final client = GoogleAIClient(
        config: const GoogleAIConfig(apiVersion: ApiVersion.v1beta),
        httpClient: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['contents'], [
            {
              'role': 'user',
              'parts': [
                {
                  'functionResponse': {
                    'name': 'select_report',
                    'response': {'spreadsheet': 'sales'},
                    'parts': [
                      {
                        'fileData': {
                          'fileUri': 'files/sales',
                          'mimeType':
                              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                          'displayName': 'sales',
                        },
                        'spreadsheetMetadata': {
                          'sheetIndex': 2,
                          'visibleCells': 'A4:F20',
                          'contentLayers': ['DATA', 'FORMULAS'],
                        },
                      },
                      {
                        'inlineData': {
                          'mimeType': 'audio/wav',
                          'data': 'aGk=',
                          'displayName': 'comment',
                        },
                        'audioMetadata': {
                          'startOffset': '0.5s',
                          'endOffset': '4s',
                        },
                      },
                    ],
                  },
                },
              ],
            },
          ]);
          return http.Response('{}', 200);
        }),
      );
      addTearDown(client.close);
      await client.models.generateContent(
        model: 'gemini-4-hydrogen',
        request: const GenerateContentRequest(
          contents: [
            Content(
              role: 'user',
              parts: [
                FunctionResponsePart(
                  FunctionResponse(
                    name: 'select_report',
                    response: {'spreadsheet': 'sales'},
                    parts: [
                      FunctionResponseInlinePart(
                        fileData: FileData(
                          fileUri: 'files/sales',
                          mimeType:
                              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                          displayName: 'sales',
                        ),
                        spreadsheetMetadata: SpreadsheetMetadata(
                          sheetIndex: 2,
                          visibleCells: 'A4:F20',
                          contentLayers: [
                            SpreadsheetContentLayer.data,
                            SpreadsheetContentLayer.formulas,
                          ],
                        ),
                      ),
                      FunctionResponseInlinePart(
                        inlineData: FunctionResponseBlob(
                          mimeType: 'audio/wav',
                          data: 'aGk=',
                          displayName: 'comment',
                        ),
                        audioMetadata: AudioMetadata(
                          startOffset: '0.5s',
                          endOffset: '4s',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  test('preserves legacy raw media options and checks typed collisions', () {
    const part = InlineDataPart(
      Blob(mimeType: 'application/pdf', data: 'AQI='),
      additionalProperties: {
        'documentMetadata': {'startPage': 2},
        'extension': 'value',
      },
    );
    final wire = part.toJson();
    final parsed = Part.fromJson(wire) as InlineDataPart;
    expect(parsed.documentMetadata?.startPage, 2);
    expect(parsed.additionalProperties, {'extension': 'value'});
    expect(parsed.toJson(), wire);
    expect(
      () => part
          .copyWith(documentMetadata: const DocumentMetadata(startPage: 3))
          .toJson(),
      throwsArgumentError,
    );
    final video = VideoMetadata.fromJson({'videoDuration': '3s'});
    expect(video.copyWith().toJson(), {'videoDuration': '3s'});
  });
}
