// ignore_for_file: avoid_print

/// Creates a stable Gemini Developer API interaction.
///
/// Set GOOGLE_GENAI_API_KEY, then run `dart run example/example.dart`.
library;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment(
    interactionsApiVersion: ApiVersion.v1,
  );

  try {
    final interaction = await client.interactions.create(
      model: 'gemini-4-hydrogen',
      input: const InteractionInput.text(
        'Explain why Dart works well for APIs.',
      ),
    );

    print(interaction.outputText);
  } finally {
    client.close();
  }
}
