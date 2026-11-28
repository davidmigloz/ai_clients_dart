// ignore_for_file: avoid_print

/// Summarizes selected PDF pages through the Gemini Developer API.
library;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    print('Usage: dart run example/interactions_media_slicing.dart FILE_URI');
    return;
  }

  final client = GoogleAIClient.fromEnvironment(
    interactionsApiVersion: ApiVersion.v1,
  );
  try {
    final interaction = await client.interactions.create(
      model: 'gemini-4-hydrogen',
      input: InteractionInput.contentList([
        DocumentContent(
          uri: args.single,
          mimeType: 'application/pdf',
          processing: const InteractionDocumentProcessing.select(
            pageOptions: InteractionPageProcessingOptions(
              startPage: 1,
              endPage: 2,
              contentLayers: [InteractionPageLayer.text],
            ),
          ),
        ),
        const TextContent(text: 'Summarize the selected pages.'),
      ]),
    );
    print(interaction.outputText);
  } finally {
    client.close();
  }
}
