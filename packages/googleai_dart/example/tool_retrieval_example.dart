// ignore_for_file: avoid_print
/// Returns schemas from a local catalog when Gemini requests tool retrieval.
library;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment(
    interactionsApiVersion: ApiVersion.v1beta,
  );
  const model = 'gemini-4-hydrogen';
  const tools = [
    ToolSearchTool(
      execution: ToolSearchExecution.client,
      name: 'search_catalog',
      description: 'Find a tool in the local inventory catalog.',
      parameters: {
        'type': 'object',
        'properties': {
          'query': {'type': 'string'},
        },
        'required': ['query'],
      },
    ),
  ];
  const inventoryTool = FunctionTool(
    name: 'lookup_inventory',
    description: 'Returns available inventory for a product SKU.',
    parameters: {
      'type': 'object',
      'properties': {
        'sku': {'type': 'string'},
      },
      'required': ['sku'],
    },
  );

  try {
    final first = await client.interactions.create(
      model: model,
      tools: tools,
      input: const InteractionInput.text(
        'Search the catalog for a function to check the stock of SKU A123, '
        'then call that function.',
      ),
    );

    for (final call in first.functionCallSteps) {
      if (call.name != 'search_catalog') continue;
      final followup = await client.interactions.create(
        model: model,
        tools: tools,
        previousInteractionId: first.id,
        input: InteractionInput.steps([
          FunctionResultStep(
            callId: call.id,
            name: call.name,
            result: const ToolResult.contentList([
              FunctionResultSubcontentFunction(inventoryTool),
            ]),
          ),
        ]),
      );
      for (final discoveredCall in followup.functionCallSteps) {
        print('Discovered ${discoveredCall.name}: ${discoveredCall.arguments}');
      }
      break;
    }
  } finally {
    client.close();
  }
}
