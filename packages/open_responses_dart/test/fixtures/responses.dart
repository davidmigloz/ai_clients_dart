/// Common test fixtures for response JSON payloads.
library;

/// A basic completed response.
Map<String, dynamic> basicCompletedResponse({
  String id = 'resp_123',
  String model = 'gpt-4o',
  String outputText = 'Hello! How can I help you?',
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': model,
    'status': 'completed',
    'output': [
      {
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': outputText},
        ],
      },
    ],
    'usage': {'input_tokens': 10, 'output_tokens': 5, 'total_tokens': 15},
  };
}

/// A response with function calls.
Map<String, dynamic> functionCallResponse({
  String id = 'resp_123',
  String model = 'gpt-4o',
  String functionName = 'get_weather',
  String arguments = '{"location": "San Francisco"}',
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': model,
    'status': 'completed',
    'output': [
      {
        'type': 'function_call',
        'id': 'call_001',
        'call_id': 'call_abc123',
        'name': functionName,
        'arguments': arguments,
      },
    ],
    'usage': {'input_tokens': 15, 'output_tokens': 20, 'total_tokens': 35},
  };
}

/// A failed response.
Map<String, dynamic> failedResponse({
  String id = 'resp_123',
  String errorCode = 'server_error',
  String errorMessage = 'An internal error occurred',
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': 'gpt-4o',
    'status': 'failed',
    'error': {'code': errorCode, 'message': errorMessage},
  };
}

/// An in-progress response.
Map<String, dynamic> inProgressResponse({
  String id = 'resp_123',
  String model = 'gpt-4o',
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': model,
    'status': 'in_progress',
    'output': <Map<String, dynamic>>[],
  };
}

/// An incomplete response.
Map<String, dynamic> incompleteResponse({
  String id = 'resp_123',
  String reason = 'max_output_tokens',
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': 'gpt-4o',
    'status': 'incomplete',
    'incomplete_details': {'reason': reason},
    'output': [
      {
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': 'Partial response...'},
        ],
      },
    ],
  };
}

/// A response with multiple text parts in a single message.
Map<String, dynamic> multiTextResponse({
  String id = 'resp_123',
  String model = 'gpt-4o',
  List<String> texts = const ['Hello', ' world', '!'],
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': model,
    'status': 'completed',
    'output': [
      {
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': [
          for (final text in texts) {'type': 'output_text', 'text': text},
        ],
      },
    ],
    'usage': {'input_tokens': 10, 'output_tokens': 15, 'total_tokens': 25},
  };
}

/// A response with mixed output types (text and function call).
Map<String, dynamic> mixedOutputResponse({
  String id = 'resp_123',
  String text = 'Here is the result:',
  String functionName = 'get_data',
  String arguments = '{}',
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': 'gpt-4o',
    'status': 'completed',
    'output': [
      {
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': text},
        ],
      },
      {
        'type': 'function_call',
        'id': 'call_001',
        'call_id': 'call_abc123',
        'name': functionName,
        'arguments': arguments,
      },
    ],
    'usage': {'input_tokens': 15, 'output_tokens': 25, 'total_tokens': 40},
  };
}

/// A response with multiple function calls.
Map<String, dynamic> multipleFunctionCallsResponse({
  String id = 'resp_123',
  List<(String name, String arguments)> functions = const [
    ('get_weather', '{"location": "NYC"}'),
    ('get_time', '{"timezone": "EST"}'),
  ],
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': 'gpt-4o',
    'status': 'completed',
    'output': [
      for (var i = 0; i < functions.length; i++)
        {
          'type': 'function_call',
          'id': 'call_00${i + 1}',
          'call_id': 'call_abc${i + 1}',
          'name': functions[i].$1,
          'arguments': functions[i].$2,
        },
    ],
    'usage': {'input_tokens': 20, 'output_tokens': 30, 'total_tokens': 50},
  };
}

/// A response with reasoning items.
Map<String, dynamic> reasoningResponse({
  String id = 'resp_123',
  String model = 'o1-preview',
  String summaryText = 'Step by step reasoning...',
  String? encryptedContent,
}) {
  return {
    'id': id,
    'object': 'response',
    'created_at': 1700000000,
    'model': model,
    'status': 'completed',
    'output': [
      {
        'type': 'reasoning',
        'id': 'reasoning_001',
        'summary': [
          {'type': 'summary_text', 'text': summaryText},
        ],
        'encrypted_content': ?encryptedContent,
      },
      {
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': 'The answer is 42.'},
        ],
      },
    ],
    'usage': {
      'input_tokens': 10,
      'output_tokens': 50,
      'total_tokens': 60,
      'output_tokens_details': {'reasoning_tokens': 40},
    },
  };
}

/// Streaming events for a basic text response.
List<Map<String, dynamic>> basicStreamingEvents({
  String responseId = 'resp_123',
  String outputText = 'Hello!',
}) {
  return [
    {
      'type': 'response.created',
      'response': {
        'id': responseId,
        'object': 'response',
        'created_at': 1700000000,
        'model': 'gpt-4o',
        'status': 'in_progress',
        'output': <Map<String, dynamic>>[],
      },
    },
    {
      'type': 'response.output_item.added',
      'output_index': 0,
      'item': {
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': <Map<String, dynamic>>[],
      },
    },
    {
      'type': 'response.content_part.added',
      'item_id': 'msg_001',
      'output_index': 0,
      'content_index': 0,
      'part': {'type': 'output_text', 'text': ''},
    },
    {
      'type': 'response.output_text.delta',
      'item_id': 'msg_001',
      'output_index': 0,
      'content_index': 0,
      'delta': outputText,
    },
    {
      'type': 'response.output_text.done',
      'item_id': 'msg_001',
      'output_index': 0,
      'content_index': 0,
      'text': outputText,
    },
    {
      'type': 'response.completed',
      'response': {
        'id': responseId,
        'object': 'response',
        'created_at': 1700000000,
        'model': 'gpt-4o',
        'status': 'completed',
        'output': [
          {
            'type': 'message',
            'id': 'msg_001',
            'role': 'assistant',
            'content': [
              {'type': 'output_text', 'text': outputText},
            ],
          },
        ],
        'usage': {'input_tokens': 10, 'output_tokens': 5, 'total_tokens': 15},
      },
    },
  ];
}
