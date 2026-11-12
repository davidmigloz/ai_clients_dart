import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

const int _maxPayloadBytes = 16 * 1024 * 1024;
const int _maxHeaderBytes = 128 * 1024;
const _preludeBytes = 12;
const _checksumBytes = 4;

/// Converts AWS Bedrock Runtime response frames to the Claude SSE format.
http.StreamedResponse bedrockEventStreamResponse(
  http.StreamedResponse response,
) {
  final headers = {
    for (final entry in response.headers.entries)
      entry.key.toLowerCase(): entry.value,
  };
  final contentType = headers['content-type']?.split(';').first.trim();
  if (contentType?.toLowerCase() != 'application/vnd.amazon.eventstream') {
    return response;
  }
  headers
    ..remove('content-length')
    ..['content-type'] = 'text/event-stream; charset=utf-8';
  return http.StreamedResponse(
    _eventStreamToSse(response.stream),
    response.statusCode,
    request: response.request,
    headers: headers,
    persistentConnection: response.persistentConnection,
    reasonPhrase: response.reasonPhrase,
  );
}

Stream<List<int>> _eventStreamToSse(Stream<List<int>> bytes) {
  final frame = BytesBuilder();
  var length = _preludeBytes;
  var headerLength = 0;
  return bytes.transform(
    StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (chunk, sink) {
        if (chunk.isEmpty) return;
        // The downstream byte-idle timer must see activity while a frame is
        // incomplete. An empty UTF-8 chunk does not produce an SSE event.
        sink.add(const []);
        var offset = 0;
        while (offset < chunk.length) {
          final remaining = length - frame.length;
          final end = offset + remaining < chunk.length
              ? offset + remaining
              : chunk.length;
          frame.add(chunk.sublist(offset, end));
          offset = end;
          if (frame.length != length) continue;

          if (length == _preludeBytes) {
            final prelude = frame.toBytes();
            final data = ByteData.sublistView(prelude);
            length = data.getUint32(0);
            headerLength = data.getUint32(4);
            if (_crc32(prelude, 0, 8) != data.getUint32(8) ||
                length < _preludeBytes + _checksumBytes ||
                headerLength > _maxHeaderBytes ||
                headerLength > length - _preludeBytes - _checksumBytes ||
                length - _preludeBytes - _checksumBytes - headerLength >
                    _maxPayloadBytes) {
              throw const FormatException('Invalid AWS event stream prelude');
            }
            continue;
          }

          final data = frame.takeBytes();
          final event = _decodeFrame(data, headerLength);
          length = _preludeBytes;
          if (event == null) continue;
          sink.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
          if (event['type'] == 'error') {
            sink.close();
            return;
          }
        }
      },
      handleDone: (sink) {
        if (frame.isNotEmpty) {
          sink.addError(
            const FormatException('Truncated AWS event stream frame'),
          );
        }
        sink.close();
      },
    ),
  );
}

Map<String, dynamic>? _decodeFrame(Uint8List frame, int headerLength) {
  final data = ByteData.sublistView(frame);
  final checksumOffset = frame.length - _checksumBytes;
  if (_crc32(frame, 0, checksumOffset) != data.getUint32(checksumOffset)) {
    throw const FormatException('Invalid AWS event stream checksum');
  }
  final payloadOffset = _preludeBytes + headerLength;
  final headers = _decodeHeaders(data, frame, payloadOffset);
  final payload = Uint8List.sublistView(frame, payloadOffset, checksumOffset);
  final messageType = headers[':message-type'];
  if (messageType == 'exception' || messageType == 'error') {
    final type =
        headers[':exception-type'] ?? headers[':error-code'] ?? 'api_error';
    var message = headers[':error-message'];
    if (message == null && payload.isNotEmpty) {
      try {
        if (jsonDecode(utf8.decode(payload)) case {
          'message': final String text,
        }) {
          message = text;
        }
      } on FormatException {
        // Preserve the service error discriminator with a safe message.
      }
    }
    return {
      'type': 'error',
      'error': {'type': type, 'message': message ?? 'Bedrock stream error'},
    };
  }
  if (messageType != 'event' || headers[':event-type'] != 'chunk') return null;

  final envelope = jsonDecode(utf8.decode(payload));
  if (envelope case {'bytes': final String encoded}) {
    final decoded = jsonDecode(utf8.decode(base64Decode(encoded)));
    if (decoded case final Map<String, dynamic> json
        when json['type'] is String) {
      return json;
    }
    return null;
  }
  throw const FormatException('AWS event stream chunk is missing bytes');
}

Map<String, String> _decodeHeaders(ByteData data, Uint8List frame, int end) {
  final headers = <String, String>{};
  var offset = _preludeBytes;
  while (offset < end) {
    final nameLength = data.getUint8(offset++);
    if (offset + nameLength >= end) {
      throw const FormatException('Invalid AWS event stream header name');
    }
    final name = utf8.decode(
      Uint8List.sublistView(frame, offset, offset + nameLength),
    );
    offset += nameLength;
    final kind = data.getUint8(offset++);
    if ((kind == 6 || kind == 7) && offset + 2 > end) {
      throw const FormatException('Invalid AWS event stream header length');
    }
    final valueLength = switch (kind) {
      0 || 1 => 0,
      2 => 1,
      3 => 2,
      4 => 4,
      5 || 8 => 8,
      6 || 7 => data.getUint16(offset),
      9 => 16,
      _ => throw const FormatException('Unknown AWS event stream header type'),
    };
    if (kind == 6 || kind == 7) offset += 2;
    if (offset + valueLength > end) {
      throw const FormatException('Invalid AWS event stream header value');
    }
    if (kind == 7) {
      headers[name] = utf8.decode(
        Uint8List.sublistView(frame, offset, offset + valueLength),
      );
    }
    offset += valueLength;
  }
  return headers;
}

final _crcTable = List<int>.generate(256, (value) {
  var crc = value;
  for (var i = 0; i < 8; i++) {
    crc = (crc >>> 1) ^ (crc.isOdd ? 0xedb88320 : 0);
  }
  return crc;
}, growable: false);

int _crc32(Uint8List bytes, int start, int end) {
  var crc = 0xffffffff;
  for (var offset = start; offset < end; offset++) {
    crc = (crc >>> 8) ^ _crcTable[(crc ^ bytes[offset]) & 0xff];
  }
  return (crc ^ 0xffffffff).toUnsigned(32);
}
