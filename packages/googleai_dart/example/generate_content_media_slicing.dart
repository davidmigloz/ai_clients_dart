// ignore_for_file: avoid_print

import 'dart:io' as io;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    print(
      'Usage: dart run example/generate_content_media_slicing.dart path/to/file.pdf',
    );
    return;
  }

  final bytes = await io.File(args.single).readAsBytes();
  final client = GoogleAIClient.fromEnvironment();
  try {
    final response = await client.models.generateContent(
      model: 'gemini-4-hydrogen',
      request: GenerateContentRequest(
        contents: [
          Content(
            parts: [
              Part.text('Summarize the selected pages.'),
              InlineDataPart(
                Blob.fromBytes('application/pdf', bytes),
                documentMetadata: const DocumentMetadata(
                  startPage: 1,
                  endPage: 2,
                  contentLayers: [DocumentContentLayer.pageText],
                ),
              ),
            ],
          ),
        ],
      ),
    );
    print(response.text);
  } finally {
    client.close();
  }
}
