// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating JSON mode and structured output.
///
/// JSON mode ensures the model outputs valid JSON, making it
/// easier to parse and process responses programmatically.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Basic JSON mode
    await basicJsonMode(client);

    // Example 2: JSON schema validation
    await jsonSchemaMode(client);

    // Example 3: Extracting structured data
    await structuredExtraction(client);
  } finally {
    client.close();
  }
}

/// Basic JSON object response format.
Future<void> basicJsonMode(MistralClient client) async {
  print('=== Basic JSON Mode ===\n');

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'You are a helpful assistant that responds in JSON format.',
        ),
        ChatMessage.user(
          'List the top 3 programming languages in 2024 with their key features.',
        ),
      ],
      responseFormat: const ResponseFormatJsonObject(),
    ),
  );

  print('Raw response: ${response.text}\n');

  // Parse the JSON response
  try {
    final data = jsonDecode(response.text!);
    print('Parsed JSON: ${const JsonEncoder.withIndent('  ').convert(data)}');
  } catch (e) {
    print('Failed to parse JSON: $e');
  }

  print('');
}

/// Using JSON schema for structured output.
Future<void> jsonSchemaMode(MistralClient client) async {
  print('=== JSON Schema Mode ===\n');

  // Define a schema for the expected output
  const schema = ResponseFormatJsonSchema(
    name: 'product_info',
    description: 'Product information schema',
    schema: {
      'type': 'object',
      'properties': {
        'name': {'type': 'string', 'description': 'Product name'},
        'price': {'type': 'number', 'description': 'Price in USD'},
        'category': {'type': 'string', 'description': 'Product category'},
        'features': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'List of key features',
        },
        'in_stock': {'type': 'boolean', 'description': 'Availability status'},
      },
      'required': ['name', 'price', 'category'],
    },
  );

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.user(
          'Generate product information for a wireless gaming mouse. '
          'Make up reasonable details.',
        ),
      ],
      responseFormat: schema,
    ),
  );

  print('Schema-validated response:');
  try {
    final data = jsonDecode(response.text!);
    print(const JsonEncoder.withIndent('  ').convert(data));
  } catch (e) {
    print('Response: ${response.text}');
  }

  print('');
}

/// Extracting structured data from unstructured text.
Future<void> structuredExtraction(MistralClient client) async {
  print('=== Structured Data Extraction ===\n');

  const unstructuredText = r'''
  Hi, I'm Sarah Johnson and I'd like to place an order. My email is
  sarah.j@example.com and phone is 555-123-4567. I want to order:
  - 2x Blue Widget (SKU: BW-001) at $29.99 each
  - 1x Red Gadget (SKU: RG-042) at $49.99
  Please ship to 123 Main Street, Anytown, CA 90210.
  ''';

  const extractionSchema = ResponseFormatJsonSchema(
    name: 'order_extraction',
    description: 'Extracted order information',
    schema: {
      'type': 'object',
      'properties': {
        'customer': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'email': {'type': 'string'},
            'phone': {'type': 'string'},
          },
        },
        'items': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
              'sku': {'type': 'string'},
              'quantity': {'type': 'integer'},
              'unit_price': {'type': 'number'},
            },
          },
        },
        'shipping_address': {
          'type': 'object',
          'properties': {
            'street': {'type': 'string'},
            'city': {'type': 'string'},
            'state': {'type': 'string'},
            'zip': {'type': 'string'},
          },
        },
        'total_amount': {'type': 'number'},
      },
    },
  );

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'Extract structured order information from the text. '
          'Calculate the total amount.',
        ),
        ChatMessage.user(unstructuredText),
      ],
      responseFormat: extractionSchema,
    ),
  );

  print('Input text:\n$unstructuredText\n');
  print('Extracted data:');
  try {
    final data = jsonDecode(response.text!);
    print(const JsonEncoder.withIndent('  ').convert(data));
  } catch (e) {
    print('Response: ${response.text}');
  }
}
