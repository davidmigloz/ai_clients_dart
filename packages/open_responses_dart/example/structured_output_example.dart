// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:open_responses_dart/open_responses_dart.dart';

/// Structured output example using the OpenResponses API.
///
/// This example demonstrates:
/// - Using JSON Schema for structured responses
/// - Strict mode for guaranteed schema compliance
/// - Parsing structured output
///
/// Set the OPENAI_API_KEY environment variable before running.
void main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider(
        Platform.environment['OPENAI_API_KEY'] ?? '',
      ),
    ),
  );

  try {
    // Example 1: Simple structured output
    print('=== Simple Structured Output ===\n');

    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input:
            'List 3 popular programming languages with their main use cases.',
        text: TextConfig(
          format: JsonSchemaFormat(
            name: 'programming_languages',
            description: 'A list of programming languages',
            schema: {
              'type': 'object',
              'properties': {
                'languages': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'name': {'type': 'string'},
                      'useCase': {'type': 'string'},
                      'popularity': {
                        'type': 'string',
                        'enum': ['high', 'medium', 'low'],
                      },
                    },
                    'required': ['name', 'useCase', 'popularity'],
                    'additionalProperties': false,
                  },
                },
              },
              'required': ['languages'],
              'additionalProperties': false,
            },
            strict: true,
          ),
        ),
      ),
    );

    print('Raw output: ${response.outputText}\n');

    // Parse the JSON output
    final data = jsonDecode(response.outputText!) as Map<String, dynamic>;
    final languages = data['languages'] as List<dynamic>;

    print('Parsed languages:');
    for (final lang in languages) {
      final l = lang as Map<String, dynamic>;
      print(
        '  - ${l['name']}: ${l['useCase']} (${l['popularity']} popularity)',
      );
    }

    // Example 2: Complex nested structure
    print('\n=== Complex Nested Structure ===\n');

    final recipeResponse = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: 'Create a simple recipe for chocolate chip cookies.',
        text: TextConfig(
          format: JsonSchemaFormat(
            name: 'recipe',
            schema: {
              'type': 'object',
              'properties': {
                'title': {'type': 'string'},
                'servings': {'type': 'integer'},
                'prepTimeMinutes': {'type': 'integer'},
                'ingredients': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'name': {'type': 'string'},
                      'amount': {'type': 'string'},
                      'unit': {'type': 'string'},
                    },
                    'required': ['name', 'amount'],
                    'additionalProperties': false,
                  },
                },
                'steps': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
              },
              'required': [
                'title',
                'servings',
                'prepTimeMinutes',
                'ingredients',
                'steps',
              ],
              'additionalProperties': false,
            },
            strict: true,
          ),
        ),
      ),
    );

    final recipe =
        jsonDecode(recipeResponse.outputText!) as Map<String, dynamic>;
    print('Recipe: ${recipe['title']}');
    print('Servings: ${recipe['servings']}');
    print('Prep time: ${recipe['prepTimeMinutes']} minutes');
    print('\nIngredients:');
    for (final ing in recipe['ingredients'] as List) {
      final i = ing as Map<String, dynamic>;
      final unit = i['unit'] ?? '';
      print('  - ${i['amount']} $unit ${i['name']}'.trim());
    }
    print('\nSteps:');
    var stepNum = 1;
    for (final step in recipe['steps'] as List) {
      print('  $stepNum. $step');
      stepNum++;
    }

    // Example 3: Enum constraints
    print('\n=== Enum Constraints ===\n');

    final sentimentResponse = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input:
            'Analyze the sentiment of these reviews:\n'
            '1. "This product is amazing! Best purchase ever!"\n'
            '2. "Terrible quality, broke after one day."\n'
            '3. "It works okay, nothing special."',
        text: TextConfig(
          format: JsonSchemaFormat(
            name: 'sentiment_analysis',
            schema: {
              'type': 'object',
              'properties': {
                'reviews': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'text': {'type': 'string'},
                      'sentiment': {
                        'type': 'string',
                        'enum': ['positive', 'negative', 'neutral'],
                      },
                      'confidence': {
                        'type': 'number',
                        'minimum': 0,
                        'maximum': 1,
                      },
                    },
                    'required': ['text', 'sentiment', 'confidence'],
                    'additionalProperties': false,
                  },
                },
              },
              'required': ['reviews'],
              'additionalProperties': false,
            },
            strict: true,
          ),
        ),
      ),
    );

    final analysis =
        jsonDecode(sentimentResponse.outputText!) as Map<String, dynamic>;
    print('Sentiment Analysis:');
    for (final review in analysis['reviews'] as List) {
      final r = review as Map<String, dynamic>;
      final emoji = switch (r['sentiment']) {
        'positive' => '😊',
        'negative' => '😞',
        _ => '😐',
      };
      final confidence = (r['confidence'] as num) * 100;
      print('  $emoji ${r['sentiment']} (${confidence.toInt()}%)');
      print('     "${r['text']}"');
    }

    // Example 4: Using plain text format
    print('\n=== Plain Text Format ===\n');

    final textResponse = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: 'Say hello in one sentence.',
        text: TextConfig(format: TextResponseFormat()),
      ),
    );

    print('Plain text output: ${textResponse.outputText}');
  } finally {
    client.close();
  }
}
